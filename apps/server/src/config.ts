import path from "path";
import {
  DEFAULT_GAME_VARIANT,
  GAME_VARIANTS,
  GAME_VERSION,
  isGameVariant,
  type GameVariant
} from "@mcity/shared";

const workspaceRoot = path.resolve(__dirname, "../../..");

export interface ServerConfig {
  workspaceRoot: string;
  gameVariant: GameVariant;
  gameVersion: string;
  assetRoute: string;
  dataRoot: string;
  launcherAssetRoot: string;
  sourceClientSwfPath: string;
  privateClientSwfPath: string;
  tutorialHQPositionsPath: string;
  tutorialSplashPath: string;
  assetRoot: string;
  archiveRoot: string;
  httpPort: number;
  httpsPort: number;
  facebookHttpsPort: number;
  dbPath: string;
  launcherUserId: string;
  launcherLang: string;
  useHttpsFacebookShim: boolean;
  requireHttpsFacebookShim: boolean;
  launchSecret?: string;
}

export function getServerConfig(variantOverride?: GameVariant): ServerConfig {
  const gameVariant = variantOverride ?? readGameVariant(process.env.MCITY_GAME_VARIANT);
  const gameVersion = GAME_VARIANTS[gameVariant].gameVersion;
  const archiveRoot = path.join(workspaceRoot, "assets");
  const launcherAssetRoot = path.join(archiveRoot, "dchoc1-a.akamaihd.net", GAME_VERSION, "mcity");
  const assetRoot = path.join(archiveRoot, "dchoc1-a.akamaihd.net", gameVersion, "mcity");
  const dataRoot = path.join(assetRoot, "Datas");
  const isOriginal = gameVariant === "original";

  return {
    workspaceRoot,
    gameVariant,
    gameVersion,
    assetRoute: `/mcity/${gameVersion}`,
    archiveRoot,
    assetRoot,
    dataRoot,
    launcherAssetRoot,
    sourceClientSwfPath: path.join(dataRoot, "Dollars.swf"),
    privateClientSwfPath: isOriginal
      ? path.join(workspaceRoot, "generated", "client", gameVersion, "Dollars.private.swf")
      : path.join(workspaceRoot, "generated", "client", "Dollars.private.swf"),
    tutorialHQPositionsPath: isOriginal
      ? path.join(dataRoot, "rules", "TutorialHQPositions.xml")
      : path.join(workspaceRoot, "assets", "recreations", "TutorialHQPositions.xml"),
    tutorialSplashPath: isOriginal
      ? path.join(dataRoot, "splash_2.swf")
      : path.join(workspaceRoot, "apps", "server", "assets", "splash.swf"),
    httpPort: Number(process.env.MCITY_HTTP_PORT ?? "31803"),
    httpsPort: Number(process.env.MCITY_HTTPS_PORT ?? "31804"),
    facebookHttpsPort: Number(process.env.MCITY_FACEBOOK_PORT ?? "443"),
    dbPath:
      process.env.MCITY_DB_PATH ??
      (isOriginal
        ? path.join(workspaceRoot, "generated", "data", "original", "mcity.sqlite")
        : path.join(workspaceRoot, "generated", "data", "mcity.sqlite")),
    launcherUserId: process.env.MCITY_UID ?? "100000000000001",
    launcherLang: process.env.MCITY_LANG ?? "en_US",
    useHttpsFacebookShim: process.env.MCITY_DISABLE_FB_SHIM === "1" ? false : true,
    requireHttpsFacebookShim: process.env.MCITY_REQUIRE_FB_SHIM === "1",
    launchSecret: process.env.MCITY_LAUNCH_SECRET || undefined
  };
}

export function getActiveDataRoot(): string {
  return getServerConfig().dataRoot;
}

function readGameVariant(value: string | undefined): GameVariant {
  if (value == null || value.trim().length === 0) {
    return DEFAULT_GAME_VARIANT;
  }

  const normalized = value.trim().toLowerCase();
  if (!isGameVariant(normalized)) {
    throw new Error(`Unknown MCITY_GAME_VARIANT: ${value}. Expected "current" or "original".`);
  }
  return normalized;
}
