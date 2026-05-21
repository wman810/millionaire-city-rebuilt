import crypto from "crypto";
import fs from "fs";
import path from "path";
import express from "express";
import https from "https";
import selfsigned from "selfsigned";
import { buildCommandEnvelope, buildLoginEnvelope, DEFAULT_SYNC, normalizeIncomingCommandList } from "@mcity/shared";
import type { PacketCommand } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import type { Server } from "http";
import { getServerConfig, type ServerConfig } from "./config.js";
import { MCityDatabase } from "./database.js";
import { CommandService } from "./commandHandlers.js";
import { startFacebookShim, type FacebookShimHandle } from "./facebookShim.js";
import { renderLauncherHtml } from "./launcherHtml.js";
import { SaveRepository } from "./repository.js";
import { loadCashToCoins, loadGoldPackageRewards, type GoldPackageReward } from "./rules.js";

const COMMERCE_ICON_FALLBACK = "commerce_bank.png";
const COMMERCE_TYPE_SWF_FALLBACK = "common.swf";
const ITEM_RULE_FILES = new Set([
  "commerceDefinitions.xml",
  "decorationDefinitions.xml",
  "itemDefinitions.xml",
  "wonderDefinitions.xml"
]);

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

export function createServerApp(config = getServerConfig()): ServerApp {
  const database = new MCityDatabase(config.dbPath);
  const repository = new SaveRepository(database);
  const commands = new CommandService(repository);
  const app = express();
  const goldPackageRewards = loadGoldPackageRewards(path.join(config.assetRoot, "Datas", "rules", "fbcredits.xml"));
  const cashToCoins = loadCashToCoins(path.join(config.assetRoot, "Datas", "rules", "settings.xml"));
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

  app.get("/health", (_req, res) => {
    res.json({ ok: true });
  });

  app.all("/event/track", (_req, res) => {
    res.type("text/plain").send("ok");
  });

  app.get("/launcher", (req, res) => {
    const appUrl = `https://127.0.0.1:${config.httpsPort}`;
    const debugMode = isTruthyQueryValue(req.query.debug) || process.env.MCITY_SWF_DEBUG === "1";
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
        debugMode
      })
    );
  });

  app.get("/client/Dollars.private.swf", (_req, res) => {
    res.sendFile(config.privateClientSwfPath);
  });

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
    const patchedXml = createAvailableItemRulesXml(config, fileName, archivedItemSwfs);
    if (!patchedXml) {
      next();
      return;
    }

    res.type("application/xml").send(patchedXml);
  });

  app.get("/mcity/0.501/Datas/userData/fan.xml", (_req, res) => {
    res.type("application/xml").send('<fan value="2" bookmark="0" />');
  });

  app.get("/mcity/0.501/Datas/splash.swf", (_req, res) => {
    res.sendFile(config.tutorialSplashPath);
  });

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
      ensurePrivateClientExists(config);

      if (config.useHttpsFacebookShim) {
        try {
          facebookShim = await startFacebookShim({
            port: config.facebookHttpsPort,
            currentUserId: config.launcherUserId,
            currentUserName: "Mayor"
          });
        } catch (error) {
          console.warn(`[mcity] Failed to start HTTPS Facebook shim on port ${config.facebookHttpsPort}:`, error);
        }
      }

      await new Promise<void>((resolve, reject) => {
        httpServer = app.listen(config.httpPort, "127.0.0.1");
        httpServer.once("listening", () => resolve());
        httpServer.once("error", reject);
      });

      httpsServer = https.createServer(createLocalhostTlsOptions(), app);
      await new Promise<void>((resolve, reject) => {
        httpsServer?.once("listening", () => resolve());
        httpsServer?.once("error", reject);
        httpsServer?.listen(config.httpsPort, "127.0.0.1");
      });

      if (!httpServer || !httpsServer) {
        throw new Error("HTTP/HTTPS server failed to initialize.");
      }

      return { httpServer, httpsServer, facebookShim };
    },
    async stop() {
      await Promise.all([
        new Promise<void>((resolve) => {
          if (!httpServer) {
            resolve();
            return;
          }
          httpServer.close(() => resolve());
        }),
        new Promise<void>((resolve) => {
          if (!httpsServer) {
            resolve();
            return;
          }
          httpsServer.close(() => resolve());
        }),
        new Promise<void>((resolve) => {
          if (!facebookShim) {
            resolve();
            return;
          }
          facebookShim.server.close(() => resolve());
        })
      ]);
      database.close();
    }
  };
}

function ensurePrivateClientExists(config: ServerConfig): void {
  fs.mkdirSync(path.dirname(config.privateClientSwfPath), { recursive: true });
  if (!fs.existsSync(config.privateClientSwfPath)) {
    fs.copyFileSync(config.sourceClientSwfPath, config.privateClientSwfPath);
  }
}

function dataAssetPath(config: ServerConfig, ...segments: string[]): string {
  return path.join(config.assetRoot, "Datas", ...segments);
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

    if (!archivedItemSwfs.has(`${sku}.swf`.toLowerCase())) {
      return "";
    }

    const patchedAttributes = isLimitedItemDefinition(attributes)
      ? removeLimitedAvailabilityAttributes(attributes)
      : attributes;
    return `<Definition${patchedAttributes}/>`;
  });
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
