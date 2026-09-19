import crypto from "crypto";
import fs from "fs";
import path from "path";
import express from "express";
import https from "https";
import selfsigned from "selfsigned";
import { buildCommandEnvelope, buildLoginEnvelope, DEFAULT_SYNC, normalizeIncomingCommandList, SAVE_TAGS } from "@mcity/shared";
import type { PacketCommand } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import type { Server } from "http";
import { getServerConfig, type ServerConfig } from "./config.js";
import { MCityDatabase } from "./database.js";
import { CommandService } from "./commandHandlers.js";
import { startFacebookShim, type FacebookShimHandle, type FacebookShimPicture } from "./facebookShim.js";
import { renderLauncherHtml } from "./launcherHtml.js";
import { SaveRepository } from "./repository.js";
import { loadCashToCoins, loadGoldPackageRewards, loadLevelXpThresholds, type GoldPackageReward } from "./rules.js";
import { encodeAsciiCodes } from "./commandHandlers/encoding.js";
import { DEFAULT_CITY_NAME } from "./saveDefaults/constants.js";

const COMMERCE_ICON_FALLBACK = "commerce_bank.png";
const COMMERCE_TYPE_SWF_FALLBACK = "common.swf";
const LOCAL_PROFILE_NAME_MAX_LENGTH = 32;
const LOCAL_CITY_NAME_MAX_LENGTH = 32;
const LOCAL_PROFILE_PICTURE_FILE_NAME = "profile-picture";
const LOCAL_PROFILE_PICTURE_MAX_BYTES = 2 * 1024 * 1024;
const LOCAL_RESOURCE_ADJUSTMENT_MAX = 999_999_999;
const LOCAL_PROFILE_PICTURE_MIME_META_KEY = "local_profile_picture_mime";
const LOCAL_PROFILE_PICTURE_VERSION_META_KEY = "local_profile_picture_version";
const HEALTH_CHALLENGE_HEADER = "x-mcity-health-challenge";
const HEALTH_PROOF_HEADER = "x-mcity-health-proof";
const LAUNCHER_CONTENT_SECURITY_POLICY = [
  "default-src 'self'",
  "script-src 'self' 'unsafe-inline'",
  "style-src 'self' 'unsafe-inline'",
  "img-src 'self' data: blob:",
  "object-src 'self'",
  "connect-src 'self' https://graph.facebook.com https://api.facebook.com",
  "frame-src 'self'",
  "child-src 'self'",
  "base-uri 'none'",
  "form-action 'self'",
  "frame-ancestors 'none'"
].join("; ");
const TRANSPARENT_GIF = Buffer.from(
  "R0lGODlhAQABAIABAP///wAAACwAAAAAAQABAAACAkQBADs=",
  "base64"
);
const LOCAL_PROFILE_PICTURE_MIME_TYPES = new Set([
  "image/gif",
  "image/jpeg",
  "image/png",
  "image/webp"
]);
const ITEM_RULE_FILES = new Set([
  "commerceDefinitions.xml",
  "decorationDefinitions.xml",
  "itemDefinitions.xml",
  "wonderDefinitions.xml"
]);
const COLLECTIBLE_RULE_FILES = new Set([
  "collectiblesDefinitions.xml",
  "collectiblesGroupsDefinitions.xml",
  "collectiblesRewardDefinitions.xml"
]);
const REWARD_ONLY_ITEM_SKUS = new Set(["commerce_vip"]);

interface ServerApp {
  config: ServerConfig;
  database: MCityDatabase;
  repository: SaveRepository;
  commands: CommandService;
  app: express.Express;
  httpServer?: Server;
  httpsServer?: https.Server;
  facebookShim?: FacebookShimHandle;
  start: () => Promise<{ httpServer: Server; httpsServer: https.Server; facebookShim?: FacebookShimHandle }>;
  stop: () => Promise<void>;
}

interface LocalProfileResponse {
  ok: true;
  userName: string;
  cityName: string;
  hasProfilePicture: boolean;
  profilePictureUrl: string;
}

interface LocalResourcesResponse {
  ok: true;
  money: number;
  gold: number;
  paidGold: number;
  xp: number;
  level: number;
  minXp: number;
  maxXp: number;
  companyValue: number;
}

interface LocalProfilePictureUpload {
  mimeType: string;
  bytes: Buffer;
}

export function createServerApp(config = getServerConfig()): ServerApp {
  const database = new MCityDatabase(config.dbPath);
  const repository = new SaveRepository(database);
  const commands = new CommandService(repository);
  const app = express();
  const goldPackageRewards = loadGoldPackageRewards(path.join(config.assetRoot, "Datas", "rules", "fbcredits.xml"));
  const cashToCoins = loadCashToCoins(path.join(config.assetRoot, "Datas", "rules", "settings.xml"));
  const levelXpThresholds = loadLevelXpThresholds(path.join(config.assetRoot, "Datas", "rules", "XPTable.xml"));
  const archivedItemSwfs = createArchivedItemSwfSet(config);

  repository.ensureDefaultUser();

  app.disable("x-powered-by");
  app.use(express.urlencoded({ extended: false, limit: "5mb" }));
  app.use(express.json({ limit: "5mb" }));
  app.use((req, _res, next) => {
    if (req.path === "/health") {
      next();
      return;
    }
    console.log(`[http] ${req.method} ${req.originalUrl}`);
    next();
  });

  app.get("/health", (req, res) => {
    if (config.launchSecret) {
      const challenge = req.get(HEALTH_CHALLENGE_HEADER);
      if (!challenge || !/^[a-f0-9]{64}$/.test(challenge)) {
        res.status(400).json({ ok: false });
        return;
      }

      const proof = crypto
        .createHmac("sha256", config.launchSecret)
        .update(`mcity-health-v1:${challenge}`)
        .digest("hex");
      res.setHeader(HEALTH_PROOF_HEADER, proof);
    }
    res.json({ ok: true });
  });

  app.all("/event/track", (_req, res) => {
    res.type("text/plain").send("ok");
  });

  app.get("/local/profile", (_req, res) => {
    res.json(createLocalProfileResponse(repository, config));
  });

  app.post("/local/profile", (req, res) => {
    try {
      const payload = req.body as Record<string, unknown>;
      const response = updateLocalProfile(repository, config, payload);
      res.json(response);
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unable to update local profile.";
      res.status(400).json({ ok: false, error: message });
    }
  });

  app.get("/local/resources", (_req, res) => {
    res.json(createLocalResourcesResponse(repository, levelXpThresholds));
  });

  app.post("/local/resources/adjust", (req, res) => {
    try {
      const payload = req.body as Record<string, unknown>;
      const response = adjustLocalResources(repository, levelXpThresholds, cashToCoins, payload);
      res.json(response);
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unable to adjust local resources.";
      res.status(400).json({ ok: false, error: message });
    }
  });

  app.get("/local/profile-picture", (_req, res) => {
    const picture = getLocalProfilePicture(repository, config);
    res.setHeader("cache-control", "no-store");
    if (picture) {
      res.type(picture.mimeType);
      res.sendFile(picture.filePath);
      return;
    }

    res.type("image/gif").send(TRANSPARENT_GIF);
  });

  app.get("/launcher", (req, res) => {
    const appUrl = `https://127.0.0.1:${config.httpsPort}`;
    const debugMode = isTruthyQueryValue(req.query.debug) || process.env.MCITY_SWF_DEBUG === "1";
    const climateMode = isTruthyQueryValue(req.query.climate) || process.env.MCITY_USE_CLIMATE === "1";
    const oldItemDesigns = isTruthyQueryValue(req.query.oldItems) || process.env.MCITY_OLD_ITEM_DESIGNS === "1";
    const localProfile = createLocalProfileResponse(repository, config);
    res.set({
      "Content-Security-Policy": LAUNCHER_CONTENT_SECURITY_POLICY,
      "Referrer-Policy": "no-referrer",
      "X-Content-Type-Options": "nosniff"
    });
    res.type("html").send(
      renderLauncherHtml({
        appUrl,
        assetsBaseUrl: `${appUrl}/mcity/0.501/Datas/`,
        serverBaseUrl: appUrl,
        userId: config.launcherUserId,
        oauthToken: "local-oauth-token",
        gameToken: "bootstrap-token",
        facebookAppId: "315455798286",
        lang: config.launcherLang,
        debugMode,
        climateMode,
        oldItemDesigns,
        localUserName: localProfile.userName,
        localCityName: localProfile.cityName,
        localProfilePictureUrl: localProfile.profilePictureUrl
      })
    );
  });

  app.get("/client/Dollars.private.swf", (_req, res) => {
    res.sendFile(config.privateClientSwfPath);
  });

  app.get("/favicon.ico", (_req, res) => {
    res.type("image/x-icon").sendFile(path.join(config.workspaceRoot, "apps", "desktop", "assets", "window-icon.ico"));
  });

  app.use(
    "/cbar",
    express.static(path.join(config.archiveRoot, "cbar"), {
      fallthrough: true,
      extensions: ["htm", "html", "css", "png"]
    })
  );

  app.get("/crossdomain.xml", (_req, res) => {
    res.type("application/xml").send(`<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <allow-access-from domain="*" />
</cross-domain-policy>`);
  });

  app.get("/mcity/0.501/Datas/rules/TutorialHQPositions.xml", (_req, res) => {
    res.sendFile(config.tutorialHQPositionsPath);
  });

  app.get("/mcity/0.501/Datas/rules/:fileName", (req, res, next) => {
    const fileName = path.basename(String(req.params.fileName ?? ""));
    const patchedXml =
      createAvailableItemRulesXml(config, fileName, archivedItemSwfs) ??
      createAvailableCollectibleRulesXml(config, fileName, archivedItemSwfs);
    if (!patchedXml) {
      next();
      return;
    }

    res.type("application/xml").send(patchedXml);
  });

  app.get("/mcity/0.501/Datas/userData/fan.xml", (_req, res) => {
    res.type("application/xml").send('<fan value="2" bookmark="0" />');
  });

  app.get("/mcity/0.501/Datas/userData/giftsList.xml", (_req, res) => {
    res.type("application/xml").send("<giftsList />");
  });

  app.get("/mcity/0.501/Datas/userData/checkSendMail.xml", (_req, res) => {
    markVipClubEmailSubmitted(repository);
    res.type("application/xml").send("<response><status>0</status></response>");
  });

  app.get("/mcity/0.501/Datas/userData/checkMail.html", (_req, res) => {
    res.type("text/plain").send(isVipClubEmailSubmitted(repository) ? "1" : "0");
  });

  app.get(["/registration/register", "/registration/register/"], (_req, res) => {
    markVipClubEmailSubmitted(repository);
    res.type("application/xml").send("<response><status>0</status></response>");
  });

  app.get(["/registration/isconfirmed", "/registration/isconfirmed/"], (_req, res) => {
    res.type("text/plain").send(isVipClubEmailSubmitted(repository) ? "1" : "0");
  });

  app.get("/mcity/0.501/Datas/splash.swf", (_req, res) => {
    res.sendFile(config.tutorialSplashPath);
  });

  app.use("/mcity/0.501", createCaseInsensitiveAssetMiddleware(config));

  app.get("/mcity/0.501/Datas/feed/:fileName", (req, res, next) => {
    const fileName = path.basename(String(req.params.fileName ?? ""));
    const requestedPath = path.join(config.assetRoot, "Datas", "feed", fileName);
    if (fs.existsSync(requestedPath)) {
      res.sendFile(requestedPath);
      return;
    }

    const extension = path.extname(fileName).toLowerCase();
    if (extension === ".jpg" || extension === ".jpeg") {
      const fallbackPath = path.join(config.assetRoot, "Datas", "feed", "new_feed_upgrades_0.jpg");
      if (fs.existsSync(fallbackPath)) {
        console.warn(`[mcity] Missing feed asset: ${req.originalUrl}; serving ${path.basename(fallbackPath)}`);
        res.sendFile(fallbackPath);
        return;
      }
    }

    if (extension === ".png") {
      const fallbackPath = path.join(config.assetRoot, "Datas", "feed", "newitemimage.png");
      if (fs.existsSync(fallbackPath)) {
        console.warn(`[mcity] Missing feed asset: ${req.originalUrl}; serving ${path.basename(fallbackPath)}`);
        res.sendFile(fallbackPath);
        return;
      }
    }

    next();
  });

  app.get("/mcity/0.501/Datas/Assets/items/CommerceTypes/icons/:fileName", (req, res, next) => {
    const fileName = path.basename(String(req.params.fileName ?? ""));
    if (!fileName.toLowerCase().endsWith(".png")) {
      next();
      return;
    }

    const requestedPath = dataAssetPath(config, "Assets", "items", "CommerceTypes", "icons", fileName);
    if (fs.existsSync(requestedPath)) {
      next();
      return;
    }

    const fallbackPath = dataAssetPath(config, "Assets", "items", "CommerceTypes", "icons", COMMERCE_ICON_FALLBACK);
    if (fs.existsSync(fallbackPath)) {
      console.warn(`[mcity] Missing commerce icon: ${req.originalUrl}; serving ${path.basename(fallbackPath)}`);
      res.sendFile(fallbackPath);
      return;
    }

    next();
  });

  app.get("/mcity/0.501/Datas/Assets/missions/icons/:fileName", (req, res, next) => {
    const fileName = path.basename(String(req.params.fileName ?? ""));
    if (!fileName.toLowerCase().endsWith(".png")) {
      next();
      return;
    }

    const requestedPath = dataAssetPath(config, "Assets", "missions", "icons", fileName);
    if (fs.existsSync(requestedPath)) {
      next();
      return;
    }

    const fallbackPath = dataAssetPath(config, "Assets", "missions", "icons", "build.png");
    if (fs.existsSync(fallbackPath)) {
      console.warn(`[mcity] Missing mission icon: ${req.originalUrl}; serving ${path.basename(fallbackPath)}`);
      res.sendFile(fallbackPath);
      return;
    }

    next();
  });

  app.get("/mcity/0.501/Datas/Assets/items/CommerceTypes/:fileName", (req, res, next) => {
    const fileName = path.basename(String(req.params.fileName ?? ""));
    if (!fileName.toLowerCase().endsWith(".swf")) {
      next();
      return;
    }

    const requestedPath = dataAssetPath(config, "Assets", "items", "CommerceTypes", fileName);
    if (fs.existsSync(requestedPath)) {
      next();
      return;
    }

    const fallbackPath = dataAssetPath(config, "Assets", "items", "CommerceTypes", COMMERCE_TYPE_SWF_FALLBACK);
    if (fs.existsSync(fallbackPath)) {
      console.warn(`[mcity] Missing commerce type SWF: ${req.originalUrl}; serving ${COMMERCE_TYPE_SWF_FALLBACK}`);
      res.sendFile(fallbackPath);
      return;
    }

    next();
  });

  app.use(
    "/mcity/0.501",
    express.static(config.assetRoot, {
      fallthrough: true,
      extensions: ["swf", "xml", "txt", "png", "jpg", "css", "js"]
    })
  );

  app.use("/mcity/0.501", (req, res) => {
    console.warn(`[mcity] Missing asset: ${req.originalUrl}`);
    res.status(404).end();
  });

  app.post("/Game", (req, res) => {
    const user = repository.ensureDefaultUser();
    const uid = String(req.body.uid ?? "");
    const cmd = String(req.body.cmd ?? "");

    if (uid !== user.ext_id && uid !== String(user.id)) {
      console.warn(`[game] Ignoring uid mismatch for private server session: received=${uid} expected=${user.ext_id}/${user.id}`);
    }

    if (cmd === "login") {
      const token = crypto.randomBytes(16).toString("hex");
      repository.setSession(user.id, token, DEFAULT_SYNC);
      console.log("[game] login accepted");
      res.type("application/xml").send(
        buildLoginEnvelope({
          _cmd: "logOK",
          _dat: repository.getLoginResponse(user.id),
          _sync: DEFAULT_SYNC
        })
      );
      return;
    }

    if (cmd === "payments") {
      const paymentData = safeJsonParse<JsonObject>(String(req.body.data ?? "{}"), {});
      const awardedGold = applyOfflinePayment(repository, user.id, paymentData, goldPackageRewards, cashToCoins);
      const sync = awardedGold > 0
        ? repository.incrementSessionSync(user.id)
        : repository.getSession(user.id)?.sync ?? DEFAULT_SYNC;
      res.type("application/xml").send(
        buildCommandEnvelope(
          [
            {
              _cmd: "payments",
              _dat: {
                success: "1",
                unavailableOffline: "1",
                privateServerFreePurchase: "1",
                awardedGold: String(awardedGold)
              }
            }
          ],
          -1,
          sync
        )
      );
      return;
    }

    if (!isSignatureValid(req.body, repository.getSession(user.id)?.token ?? "")) {
      console.warn(`[game] Ignoring signature mismatch for cmd=${cmd}.`);
    }

    if (cmd !== "cmdList") {
      res.type("application/xml").send(
        buildCommandEnvelope(
          [
            {
              _cmd: cmd || "noop",
              _dat: { success: "true", ignored: "1", unsupportedRoot: "1" }
            }
          ],
          -1,
          repository.getSession(user.id)?.sync ?? DEFAULT_SYNC
        )
      );
      return;
    }

    const payload = safeJsonParse<JsonObject>(String(req.body.data ?? "{}"), {});
    const packetCommands = normalizeIncomingCommandList(payload);
    console.log(`[game] cmdList ${packetCommands.map((entry) => entry._cmd).join(", ")}`);
    let msgCount = typeof payload._msgCount === "number" ? payload._msgCount : Number(payload._msgCount ?? -1);

    if (!Number.isFinite(msgCount)) {
      console.warn(`[game] Invalid message count for cmdList, defaulting to -1: ${String(payload._msgCount ?? "")}`);
      msgCount = -1;
    }

    const responses = packetCommands.flatMap((entry) => {
      try {
        return commands.handleCommand(user.id, entry);
      } catch (error) {
        console.warn(`[game] Command handler failed for ${entry._cmd}:`, error);
        return [
          {
            _cmd: entry._cmd,
            _dat: {
              success: "false",
              ignored: "1",
              offlineError: "1"
            },
            _sync: repository.getSession(user.id)?.sync ?? DEFAULT_SYNC
          } satisfies PacketCommand
        ];
      }
    });
    res.type("application/xml").send(buildCommandEnvelope(responses, msgCount, repository.getSession(user.id)?.sync ?? DEFAULT_SYNC));
  });

  let httpServer: Server | undefined;
  let httpsServer: https.Server | undefined;
  let facebookShim: FacebookShimHandle | undefined;

  return {
    config,
    database,
    repository,
    commands,
    app,
    get httpServer() {
      return httpServer;
    },
    get facebookShim() {
      return facebookShim;
    },
    get httpsServer() {
      return httpsServer;
    },
    async start() {
      try {
        ensurePrivateClientExists(config);

        if (config.requireHttpsFacebookShim && !config.useHttpsFacebookShim) {
          throw new Error("The required HTTPS Facebook shim is disabled.");
        }

        if (config.useHttpsFacebookShim) {
          try {
            facebookShim = await startFacebookShim({
              port: config.facebookHttpsPort,
              currentUserId: config.launcherUserId,
              getCurrentUserName: () => getLocalProfile(repository).userName,
              getCurrentUserPicture: () => getLocalProfilePicture(repository, config),
              getCurrentUserPictureVersion: () => getLocalProfilePictureVersion(repository, config)
            });
            config.facebookHttpsPort = getListeningPort(facebookShim.server, config.facebookHttpsPort);
          } catch (error) {
            if (config.requireHttpsFacebookShim) {
              throw error;
            }
            console.warn(`[mcity] Failed to start HTTPS Facebook shim on port ${config.facebookHttpsPort}:`, error);
          }
        }

        await new Promise<void>((resolve, reject) => {
          httpServer = app.listen(config.httpPort, "127.0.0.1");
          httpServer.once("listening", () => resolve());
          httpServer.once("error", reject);
        });
        if (!httpServer) {
          throw new Error("HTTP server failed to initialize.");
        }
        config.httpPort = getListeningPort(httpServer, config.httpPort);

        httpsServer = https.createServer(createLocalhostTlsOptions(), app);
        await new Promise<void>((resolve, reject) => {
          httpsServer?.once("listening", () => resolve());
          httpsServer?.once("error", reject);
          httpsServer?.listen(config.httpsPort, "127.0.0.1");
        });
        config.httpsPort = getListeningPort(httpsServer, config.httpsPort);

        if (!httpsServer) {
          throw new Error("HTTP/HTTPS server failed to initialize.");
        }

        return { httpServer, httpsServer, facebookShim };
      } catch (error) {
        await Promise.all([
          closeListeningServer(httpServer),
          closeListeningServer(httpsServer),
          closeListeningServer(facebookShim?.server)
        ]);
        httpServer = undefined;
        httpsServer = undefined;
        facebookShim = undefined;
        throw error;
      }
    },
    async stop() {
      await Promise.all([
        closeListeningServer(httpServer),
        closeListeningServer(httpsServer),
        closeListeningServer(facebookShim?.server)
      ]);
      database.close();
    }
  };
}

function closeListeningServer(server: Server | https.Server | undefined): Promise<void> {
  return new Promise((resolve) => {
    if (!server?.listening) {
      resolve();
      return;
    }
    server.close(() => resolve());
  });
}

function getListeningPort(server: Server | https.Server, fallback: number): number {
  const address = server.address();
  return address && typeof address === "object" ? address.port : fallback;
}

function ensurePrivateClientExists(config: ServerConfig): void {
  if (fs.existsSync(config.privateClientSwfPath)) {
    return;
  }

  fs.mkdirSync(path.dirname(config.privateClientSwfPath), { recursive: true });
  fs.copyFileSync(config.sourceClientSwfPath, config.privateClientSwfPath);
}

function dataAssetPath(config: ServerConfig, ...segments: string[]): string {
  return path.join(config.assetRoot, "Datas", ...segments);
}

function createCaseInsensitiveAssetMiddleware(config: ServerConfig): express.RequestHandler {
  const assetRoot = path.resolve(config.assetRoot);
  const directoryCache = new Map<string, Map<string, string>>();

  return (req, res, next) => {
    if (req.method !== "GET" && req.method !== "HEAD") {
      next();
      return;
    }

    const resolvedPath = resolveCaseInsensitiveFile(assetRoot, req.path, directoryCache);
    if (!resolvedPath) {
      next();
      return;
    }

    const exactPath = path.resolve(assetRoot, req.path.replace(/^\/+/, ""));
    if (resolvedPath !== exactPath) {
      console.warn(`[mcity] Resolved asset case mismatch: ${req.originalUrl}`);
    }
    res.sendFile(resolvedPath);
  };
}

function resolveCaseInsensitiveFile(
  root: string,
  requestPath: string,
  directoryCache: Map<string, Map<string, string>>
): string | undefined {
  const segments = parseSafeAssetPathSegments(requestPath);
  if (!segments) {
    return undefined;
  }

  let currentPath = root;
  for (const segment of segments) {
    const exactPath = path.join(currentPath, segment);
    if (fs.existsSync(exactPath)) {
      currentPath = exactPath;
      continue;
    }

    const directoryEntries = getDirectoryEntryMap(currentPath, directoryCache);
    const matchedName = directoryEntries?.get(segment.toLowerCase());
    if (!matchedName) {
      return undefined;
    }
    currentPath = path.join(currentPath, matchedName);
  }

  const resolvedPath = path.resolve(currentPath);
  if (!isPathWithin(root, resolvedPath)) {
    return undefined;
  }

  try {
    return fs.statSync(resolvedPath).isFile() ? resolvedPath : undefined;
  } catch {
    return undefined;
  }
}

function parseSafeAssetPathSegments(requestPath: string): string[] | undefined {
  let decodedPath: string;
  try {
    decodedPath = decodeURIComponent(requestPath);
  } catch {
    return undefined;
  }

  const segments = decodedPath.split(/[\\/]+/).filter(Boolean);
  if (
    segments.length === 0 ||
    segments.some((segment) => segment === "." || segment === ".." || segment.includes("\0"))
  ) {
    return undefined;
  }
  return segments;
}

function getDirectoryEntryMap(
  directoryPath: string,
  directoryCache: Map<string, Map<string, string>>
): Map<string, string> | undefined {
  const resolvedDirectoryPath = path.resolve(directoryPath);
  const cached = directoryCache.get(resolvedDirectoryPath);
  if (cached) {
    return cached;
  }

  try {
    if (!fs.statSync(resolvedDirectoryPath).isDirectory()) {
      return undefined;
    }

    const entries = new Map<string, string>();
    for (const entry of fs.readdirSync(resolvedDirectoryPath, { withFileTypes: true })) {
      entries.set(entry.name.toLowerCase(), entry.name);
    }
    directoryCache.set(resolvedDirectoryPath, entries);
    return entries;
  } catch {
    return undefined;
  }
}

function isPathWithin(root: string, candidatePath: string): boolean {
  const relativePath = path.relative(root, candidatePath);
  return relativePath === "" || (!relativePath.startsWith("..") && !path.isAbsolute(relativePath));
}

function isTruthyQueryValue(value: unknown): boolean {
  const firstValue = Array.isArray(value) ? value[0] : value;
  const normalized = String(firstValue ?? "").toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes";
}

function createArchivedItemSwfSet(config: ServerConfig): Set<string> {
  const itemAssetPath = dataAssetPath(config, "Assets", "items");
  if (!fs.existsSync(itemAssetPath)) {
    return new Set();
  }

  return new Set(
    fs
      .readdirSync(itemAssetPath, { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".swf"))
      .map((entry) => entry.name.toLowerCase())
  );
}

function createAvailableItemRulesXml(
  config: ServerConfig,
  fileName: string,
  archivedItemSwfs: Set<string>
): string | null {
  if (!ITEM_RULE_FILES.has(fileName)) {
    return null;
  }

  const rulesPath = dataAssetPath(config, "rules", fileName);
  if (!fs.existsSync(rulesPath)) {
    return null;
  }

  const xml = fs.readFileSync(rulesPath, "utf8");
  return xml.replace(/<Definition\b([^>]*)\/>/g, (definitionTag, attributes: string) => {
    const sku = getXmlAttribute(attributes, "sku")?.trim();
    if (!sku) {
      return definitionTag;
    }

    if (!isArchivedItemDefinitionAvailable(sku, attributes, archivedItemSwfs)) {
      return "";
    }

    let patchedAttributes = isLimitedItemDefinition(attributes)
      ? removeLimitedAvailabilityAttributes(attributes)
      : attributes;
    if (REWARD_ONLY_ITEM_SKUS.has(sku)) {
      patchedAttributes = markRewardOnlyItemDefinition(patchedAttributes);
    }

    return `<Definition${patchedAttributes}/>`;
  });
}

function createAvailableCollectibleRulesXml(
  config: ServerConfig,
  fileName: string,
  archivedItemSwfs: Set<string>
): string | null {
  if (!COLLECTIBLE_RULE_FILES.has(fileName)) {
    return null;
  }

  const rulesPath = dataAssetPath(config, "rules", fileName);
  if (!fs.existsSync(rulesPath)) {
    return null;
  }

  const available = getAvailableCollectibleRules(config, archivedItemSwfs);
  const xml = fs.readFileSync(rulesPath, "utf8");
  return xml.replace(/<Definition\b([^>]*)\/>/g, (definitionTag, attributes: string) => {
    const sku = getXmlAttribute(attributes, "sku")?.trim();
    if (!sku) {
      return definitionTag;
    }

    if (fileName === "collectiblesGroupsDefinitions.xml") {
      return available.groupSkus.has(sku) ? definitionTag : "";
    }

    if (fileName === "collectiblesDefinitions.xml") {
      const collection = getXmlAttribute(attributes, "collection")?.trim();
      return collection && available.groupSkus.has(collection) ? definitionTag : "";
    }

    if (fileName === "collectiblesRewardDefinitions.xml") {
      return available.rewardSkus.has(sku) ? definitionTag : "";
    }

    return definitionTag;
  });
}

function getAvailableCollectibleRules(
  config: ServerConfig,
  archivedItemSwfs: Set<string>
): { groupSkus: Set<string>; rewardSkus: Set<string> } {
  const groupsPath = dataAssetPath(config, "rules", "collectiblesGroupsDefinitions.xml");
  if (!fs.existsSync(groupsPath)) {
    return { groupSkus: new Set(), rewardSkus: new Set() };
  }

  const groupSkus = new Set<string>();
  const rewardSkus = new Set<string>();
  const advisorVariantItemSkus = getAdvisorVariantItemSkus(config);
  const xml = fs.readFileSync(groupsPath, "utf8");
  for (const match of xml.matchAll(/<Definition\b([^>]*)\/>/g)) {
    const attributes = match[1] ?? "";
    const groupSku = getXmlAttribute(attributes, "sku")?.trim();
    const rewardSku = getXmlAttribute(attributes, "reward")?.trim();
    const rewardType = getXmlAttribute(attributes, "rewardType")?.trim().toLowerCase();
    if (!groupSku || !rewardSku) {
      continue;
    }

    if (
      rewardType === "item" &&
      !isArchivedItemSkuAvailable(rewardSku, archivedItemSwfs, advisorVariantItemSkus.has(rewardSku))
    ) {
      continue;
    }

    groupSkus.add(groupSku);
    rewardSkus.add(rewardSku);
  }

  return { groupSkus, rewardSkus };
}

function getAdvisorVariantItemSkus(config: ServerConfig): Set<string> {
  const itemDefinitionsPath = dataAssetPath(config, "rules", "itemDefinitions.xml");
  if (!fs.existsSync(itemDefinitionsPath)) {
    return new Set();
  }

  const advisorSkus = new Set<string>();
  const xml = fs.readFileSync(itemDefinitionsPath, "utf8");
  for (const match of xml.matchAll(/<Definition\b([^>]*)\/>/g)) {
    const attributes = match[1] ?? "";
    const sku = getXmlAttribute(attributes, "sku")?.trim();
    if (sku && getXmlAttribute(attributes, "useAdvisor") != null) {
      advisorSkus.add(sku);
    }
  }

  return advisorSkus;
}

function isArchivedItemDefinitionAvailable(
  sku: string,
  attributes: string,
  archivedItemSwfs: Set<string>
): boolean {
  return isArchivedItemSkuAvailable(sku, archivedItemSwfs, getXmlAttribute(attributes, "useAdvisor") != null);
}

function isArchivedItemSkuAvailable(sku: string, archivedItemSwfs: Set<string>, usesAdvisor: boolean): boolean {
  if (archivedItemSwfs.has(`${sku}.swf`.toLowerCase())) {
    return true;
  }

  return (
    usesAdvisor &&
    archivedItemSwfs.has(`${sku}_Cindy.swf`.toLowerCase()) &&
    archivedItemSwfs.has(`${sku}_Ronald.swf`.toLowerCase())
  );
}

function isLimitedItemDefinition(attributes: string): boolean {
  return Boolean(
    getXmlAttribute(attributes, "expireTime") ||
      getXmlAttribute(attributes, "releaseTime") ||
      getXmlAttribute(attributes, "shopTab")?.split(",").some((tab) => tab.trim() === "limEd")
  );
}

function removeLimitedAvailabilityAttributes(attributes: string): string {
  let patchedAttributes = attributes;
  patchedAttributes = removeXmlAttribute(patchedAttributes, "expireTime");
  patchedAttributes = removeXmlAttribute(patchedAttributes, "releaseTime");
  patchedAttributes = removeXmlAttribute(patchedAttributes, "unitsAmount");
  patchedAttributes = removeLimEdShopTab(patchedAttributes);
  return patchedAttributes;
}

function getXmlAttribute(attributes: string, name: string): string | undefined {
  const match = attributes.match(new RegExp(`(?:^|\\s)${name}="([^"]*)"`));
  return match?.[1];
}

function removeXmlAttribute(attributes: string, name: string): string {
  return attributes.replace(new RegExp(`\\s+${name}="[^"]*"`, "g"), "");
}

function markRewardOnlyItemDefinition(attributes: string): string {
  return upsertXmlAttribute(attributes, "freeGift", "1");
}

function upsertXmlAttribute(attributes: string, name: string, value: string): string {
  const pattern = new RegExp(`(\\s+)${name}="[^"]*"`);
  if (pattern.test(attributes)) {
    return attributes.replace(pattern, `$1${name}="${value}"`);
  }

  return `${attributes} ${name}="${value}"`;
}

function removeLimEdShopTab(attributes: string): string {
  const shopTab = getXmlAttribute(attributes, "shopTab");
  if (!shopTab) {
    return attributes;
  }

  const remainingTabs = shopTab.split(",").map((tab) => tab.trim()).filter((tab) => tab && tab !== "limEd");
  if (remainingTabs.length === 0) {
    return removeXmlAttribute(attributes, "shopTab");
  }

  return attributes.replace(/(\s+shopTab=")[^"]*(")/, `$1${remainingTabs.join(",")}$2`);
}

function safeJsonParse<T>(value: string, fallback: T): T {
  try {
    return JSON.parse(value) as T;
  } catch {
    return fallback;
  }
}

function isSignatureValid(rawBody: Record<string, unknown>, sessionToken: string): boolean {
  if (!sessionToken) {
    return true;
  }

  const provided = String(rawBody.sig ?? "");
  if (!provided) {
    return false;
  }

  const params = Object.entries(rawBody)
    .filter(([key]) => key !== "sig")
    .map(([key, value]) => ({ key, value: String(value ?? "") }))
    .sort((a, b) => a.key.localeCompare(b.key, undefined, { sensitivity: "base" }));

  const serialized = params.map(({ key, value }) => `${key}=${value}`).join("&");
  const expected = crypto.createHash("md5").update(`${serialized}${sessionToken}Host4h`).digest("hex");
  return expected === provided || provided === "pass";
}

function createLocalhostTlsOptions(): https.ServerOptions {
  const pems = selfsigned.generate(
    [
      { name: "commonName", value: "localhost" },
      { name: "organizationName", value: "Millionaire City Revival" }
    ],
    {
      days: 3650,
      keySize: 2048,
      algorithm: "sha256",
      extensions: [
        {
          name: "subjectAltName",
          altNames: [
            { type: 2, value: "localhost" },
            { type: 7, ip: "127.0.0.1" }
          ]
        }
      ]
    }
  );

  return {
    key: pems.private,
    cert: pems.cert
  };
}

function applyOfflinePayment(
  repository: SaveRepository,
  userId: number,
  payload: JsonObject,
  goldPackageRewards: Map<string, GoldPackageReward>,
  cashToCoins: number
): number {
  if (String(payload.type ?? "").trim().toLowerCase() !== "gold") {
    return 0;
  }

  const sku = String(payload.sku ?? "").trim();
  const reward = goldPackageRewards.get(sku);
  if (!reward) {
    return 0;
  }

  const awardedGold = reward.gold + reward.freeGold;
  if (awardedGold <= 0) {
    return 0;
  }

  const universe = repository.getDocument<JsonObject>(userId, "universe");
  const root = universe.universe;
  if (!Array.isArray(root)) {
    return 0;
  }

  const profile = root.find(
    (entry): entry is JsonObject =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Profile?: unknown }).Profile))
  );
  if (!profile) {
    return 0;
  }

  const currentGold = Number(profile.DCCash ?? "0");
  const currentPaidGold = Number(profile.DCCashPaid ?? "0");
  const currentCompanyValue = Number(profile.companyValue ?? "0");
  profile.DCCash = String((Number.isFinite(currentGold) ? currentGold : 0) + awardedGold);
  profile.DCCashPaid = String((Number.isFinite(currentPaidGold) ? currentPaidGold : 0) + reward.gold);
  profile.companyValue = String((Number.isFinite(currentCompanyValue) ? currentCompanyValue : 0) + awardedGold * cashToCoins);

  repository.setDocument(userId, "universe", universe);
  return awardedGold;
}

function createLocalProfileResponse(repository: SaveRepository, config: ServerConfig): LocalProfileResponse {
  const picture = getLocalProfilePicture(repository, config);
  const localProfile = getLocalProfile(repository);
  return {
    ok: true,
    userName: localProfile.userName,
    cityName: localProfile.cityName,
    hasProfilePicture: Boolean(picture),
    profilePictureUrl: `/local/profile-picture?v=${getLocalProfilePictureVersion(repository, config)}`
  };
}

function updateLocalProfile(
  repository: SaveRepository,
  config: ServerConfig,
  payload: Record<string, unknown>
): LocalProfileResponse {
  const user = repository.ensureDefaultUser();
  const currentProfile = getLocalProfile(repository);
  const userName = payload.userName === undefined
    ? currentProfile.userName
    : sanitizeLocalProfileName(payload.userName);
  const cityName = payload.cityName === undefined
    ? currentProfile.cityName
    : sanitizeLocalCityName(payload.cityName);
  const shouldClearProfilePicture = payload.clearProfilePicture === true || payload.clearProfilePicture === "true";
  const profilePictureUpload = !shouldClearProfilePicture &&
    typeof payload.profilePictureDataUrl === "string" &&
    payload.profilePictureDataUrl.trim().length > 0
    ? parseLocalProfilePicture(payload.profilePictureDataUrl)
    : undefined;

  repository.updateDefaultUserName(userName);
  const universe = repository.getDocument<JsonObject>(user.id, SAVE_TAGS.universe);
  const profile = getUniverseProfile(universe);
  if (profile) {
    profile.userName = userName;
    profile.cityname = cityName;
    profile.cityNameCodes = encodeAsciiCodes(cityName);
    repository.setDocument(user.id, SAVE_TAGS.universe, universe);
  }

  if (shouldClearProfilePicture) {
    clearLocalProfilePicture(repository, config);
  } else if (profilePictureUpload) {
    saveLocalProfilePicture(repository, config, profilePictureUpload);
  }

  return createLocalProfileResponse(repository, config);
}

function getLocalProfile(repository: SaveRepository): { userName: string; cityName: string } {
  const user = repository.ensureDefaultUser();
  try {
    const universe = repository.getDocument<JsonObject>(user.id, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    const userName = sanitizeLocalProfileName(profile?.userName ?? user.name);
    const cityName = sanitizeLocalCityName(profile?.cityname ?? DEFAULT_CITY_NAME);
    return { userName, cityName };
  } catch {
    return {
      userName: sanitizeLocalProfileName(user.name),
      cityName: DEFAULT_CITY_NAME
    };
  }
}

function sanitizeLocalProfileName(value: unknown): string {
  const normalized = String(value ?? "")
    .replace(/[\u0000-\u001F\u007F]/g, "")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, LOCAL_PROFILE_NAME_MAX_LENGTH);
  return normalized.length > 0 ? normalized : "Mayor";
}

function sanitizeLocalCityName(value: unknown): string {
  const normalized = String(value ?? "")
    .replace(/[\u0000-\u001F\u007F]/g, "")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, LOCAL_CITY_NAME_MAX_LENGTH);
  return normalized.length > 0 ? normalized : DEFAULT_CITY_NAME;
}

function createLocalResourcesResponse(repository: SaveRepository, levelXpThresholds: number[]): LocalResourcesResponse {
  const profile = getLocalPlayerUniverseProfile(repository);
  const xp = readWholeNumber(profile.exp, 0);
  const explicitLevel = readWholeNumber(profile.level, 0);
  const level = Math.max(explicitLevel, getLevelFromXp(xp, levelXpThresholds));
  const xpBounds = getLevelXpBounds(level, levelXpThresholds);
  return {
    ok: true,
    money: readWholeNumber(profile.DCCoins, 0),
    gold: readWholeNumber(profile.DCCash, 0),
    paidGold: readWholeNumber(profile.DCCashPaid, 0),
    xp,
    level,
    minXp: xpBounds.minXp,
    maxXp: xpBounds.maxXp,
    companyValue: readWholeNumber(profile.companyValue, 0)
  };
}

function adjustLocalResources(
  repository: SaveRepository,
  levelXpThresholds: number[],
  cashToCoins: number,
  payload: Record<string, unknown>
): LocalResourcesResponse {
  const resource = String(payload.resource ?? "").trim().toLowerCase();
  const delta = parseResourceDelta(payload.delta);
  if (!["money", "gold", "xp"].includes(resource)) {
    throw new Error("Resource must be money, gold, or xp.");
  }

  const user = repository.ensureDefaultUser();
  const universe = repository.getDocument<JsonObject>(user.id, SAVE_TAGS.universe);
  const profile = getUniverseProfile(universe);
  if (!profile) {
    throw new Error("Player profile is missing from the save.");
  }

  if (resource === "money") {
    const previousMoney = readWholeNumber(profile.DCCoins, 0);
    const money = clampWholeNumber(previousMoney + delta);
    profile.DCCoins = String(money);
    profile.companyValue = String(clampWholeNumber(readWholeNumber(profile.companyValue, 0) + money - previousMoney));
  } else if (resource === "gold") {
    const previousGold = readWholeNumber(profile.DCCash, 0);
    const gold = clampWholeNumber(previousGold + delta);
    const paidGold = clampWholeNumber(readWholeNumber(profile.DCCashPaid, 0) + delta);
    profile.DCCash = String(gold);
    profile.DCCashPaid = String(Math.min(paidGold, gold));
    profile.companyValue = String(
      clampWholeNumber(readWholeNumber(profile.companyValue, 0) + (gold - previousGold) * cashToCoins)
    );
  } else {
    const xp = clampWholeNumber(readWholeNumber(profile.exp, 0) + delta);
    const level = getLevelFromXp(xp, levelXpThresholds);
    const explicitLevel = readWholeNumber(profile.level, 0);
    profile.exp = String(xp);
    profile.level = String(delta < 0 ? level : Math.max(explicitLevel, level));
  }

  repository.setDocument(user.id, SAVE_TAGS.universe, universe);
  return createLocalResourcesResponse(repository, levelXpThresholds);
}

function getLocalPlayerUniverseProfile(repository: SaveRepository): JsonObject {
  const user = repository.ensureDefaultUser();
  const universe = repository.getDocument<JsonObject>(user.id, SAVE_TAGS.universe);
  const profile = getUniverseProfile(universe);
  if (!profile) {
    throw new Error("Player profile is missing from the save.");
  }

  return profile;
}

function parseResourceDelta(value: unknown): number {
  const delta = Number(value);
  if (!Number.isFinite(delta) || !Number.isInteger(delta) || delta === 0) {
    throw new Error("Adjustment must be a non-zero whole number.");
  }
  if (Math.abs(delta) > LOCAL_RESOURCE_ADJUSTMENT_MAX) {
    throw new Error(`Adjustment must be between -${LOCAL_RESOURCE_ADJUSTMENT_MAX} and ${LOCAL_RESOURCE_ADJUSTMENT_MAX}.`);
  }

  return delta;
}

function readWholeNumber(value: unknown, fallback: number): number {
  const parsed = Number(value ?? fallback);
  if (!Number.isFinite(parsed)) {
    return fallback;
  }

  return Math.max(0, Math.floor(parsed));
}

function clampWholeNumber(value: number): number {
  if (!Number.isFinite(value)) {
    return 0;
  }

  return Math.max(0, Math.floor(value));
}

function getLevelFromXp(exp: number, levelXpThresholds: number[]): number {
  if (!Number.isFinite(exp) || exp < 0 || levelXpThresholds.length === 0) {
    return 1;
  }

  let level = 0;
  while (level < levelXpThresholds.length) {
    if (exp < levelXpThresholds[level]) {
      return Math.max(1, level);
    }
    level += 1;
  }

  return Math.max(1, levelXpThresholds.length);
}

function getLevelXpBounds(level: number, levelXpThresholds: number[]): { minXp: number; maxXp: number } {
  if (levelXpThresholds.length === 0) {
    return { minXp: 0, maxXp: 0 };
  }

  const normalizedLevel = Math.max(1, Math.floor(level));
  const minXp = levelXpThresholds[Math.min(normalizedLevel - 1, levelXpThresholds.length - 1)] ?? 0;
  const maxXp = levelXpThresholds[Math.min(normalizedLevel, levelXpThresholds.length - 1)] ?? minXp;
  return {
    minXp: clampWholeNumber(minXp),
    maxXp: Math.max(clampWholeNumber(minXp), clampWholeNumber(maxXp))
  };
}

function parseLocalProfilePicture(dataUrl: string): LocalProfilePictureUpload {
  const match = dataUrl.trim().match(/^data:(image\/(?:gif|jpeg|png|webp));base64,([a-z0-9+/=\r\n]+)$/i);
  if (!match) {
    throw new Error("Profile picture must be a PNG, JPEG, GIF, or WebP image.");
  }

  const mimeType = match[1].toLowerCase();
  if (!LOCAL_PROFILE_PICTURE_MIME_TYPES.has(mimeType)) {
    throw new Error("Profile picture must be a PNG, JPEG, GIF, or WebP image.");
  }

  const bytes = Buffer.from(match[2].replace(/\s/g, ""), "base64");
  if (bytes.length === 0 || bytes.length > LOCAL_PROFILE_PICTURE_MAX_BYTES) {
    throw new Error("Profile picture must be between 1 byte and 2 MB.");
  }

  if (!doesImageMagicMatchMime(bytes, mimeType)) {
    throw new Error("Profile picture data does not match its image type.");
  }

  return { mimeType, bytes };
}

function saveLocalProfilePicture(
  repository: SaveRepository,
  config: ServerConfig,
  upload: LocalProfilePictureUpload
): void {
  fs.mkdirSync(path.dirname(getLocalProfilePicturePath(config)), { recursive: true });
  fs.writeFileSync(getLocalProfilePicturePath(config), upload.bytes);
  repository.setMeta(LOCAL_PROFILE_PICTURE_MIME_META_KEY, upload.mimeType);
  repository.setMeta(LOCAL_PROFILE_PICTURE_VERSION_META_KEY, String(Date.now()));
}

function clearLocalProfilePicture(repository: SaveRepository, config: ServerConfig): void {
  const filePath = getLocalProfilePicturePath(config);
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }

  repository.deleteMeta(LOCAL_PROFILE_PICTURE_MIME_META_KEY);
  repository.setMeta(LOCAL_PROFILE_PICTURE_VERSION_META_KEY, String(Date.now()));
}

function getLocalProfilePicture(repository: SaveRepository, config: ServerConfig): FacebookShimPicture | undefined {
  const filePath = getLocalProfilePicturePath(config);
  const mimeType = repository.getMeta(LOCAL_PROFILE_PICTURE_MIME_META_KEY);
  if (!mimeType || !LOCAL_PROFILE_PICTURE_MIME_TYPES.has(mimeType) || !fs.existsSync(filePath)) {
    return undefined;
  }

  return { filePath, mimeType };
}

function getLocalProfilePicturePath(config: ServerConfig): string {
  return path.join(path.dirname(config.dbPath), LOCAL_PROFILE_PICTURE_FILE_NAME);
}

function getLocalProfilePictureVersion(repository: SaveRepository, config: ServerConfig): string {
  const storedVersion = repository.getMeta(LOCAL_PROFILE_PICTURE_VERSION_META_KEY);
  if (storedVersion) {
    return storedVersion;
  }

  const filePath = getLocalProfilePicturePath(config);
  if (!fs.existsSync(filePath)) {
    return "default";
  }

  return String(Math.floor(fs.statSync(filePath).mtimeMs));
}

function doesImageMagicMatchMime(bytes: Buffer, mimeType: string): boolean {
  if (mimeType === "image/png") {
    return bytes.length >= 8 && bytes.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
  }

  if (mimeType === "image/jpeg") {
    return bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
  }

  if (mimeType === "image/gif") {
    const header = bytes.subarray(0, 6).toString("ascii");
    return header === "GIF87a" || header === "GIF89a";
  }

  if (mimeType === "image/webp") {
    return bytes.length >= 12 &&
      bytes.subarray(0, 4).toString("ascii") === "RIFF" &&
      bytes.subarray(8, 12).toString("ascii") === "WEBP";
  }

  return false;
}

function markVipClubEmailSubmitted(repository: SaveRepository): void {
  const user = repository.ensureDefaultUser();
  const universe = repository.getDocument<JsonObject>(user.id, SAVE_TAGS.universe);
  const profile = getUniverseProfile(universe);
  if (!profile || String(profile.checkmail ?? "0") === "2") {
    return;
  }

  profile.checkmail = "1";
  repository.setDocument(user.id, SAVE_TAGS.universe, universe);
}

function isVipClubEmailSubmitted(repository: SaveRepository): boolean {
  const user = repository.ensureDefaultUser();
  const universe = repository.getDocument<JsonObject>(user.id, SAVE_TAGS.universe);
  const profile = getUniverseProfile(universe);
  return String(profile?.checkmail ?? "0") !== "0";
}

function getUniverseProfile(universe: JsonObject): JsonObject | undefined {
  const root = universe.universe;
  if (!Array.isArray(root)) {
    return undefined;
  }

  return root.find(
    (entry): entry is JsonObject =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Profile?: unknown }).Profile))
  );
}
