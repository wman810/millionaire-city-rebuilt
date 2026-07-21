import path from "path";

const workspaceRoot = path.resolve(__dirname, "../../..");

export interface ServerConfig {
  workspaceRoot: string;
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

export function getServerConfig(): ServerConfig {
  const archiveRoot = path.join(workspaceRoot, "assets");
  const assetRoot = path.join(archiveRoot, "dchoc1-a.akamaihd.net", "0.501", "mcity");
  const dataRoot = path.join(assetRoot, "Datas");

  return {
    workspaceRoot,
    archiveRoot,
    assetRoot,
    sourceClientSwfPath: path.join(dataRoot, "Dollars.swf"),
    privateClientSwfPath: path.join(workspaceRoot, "generated", "client", "Dollars.private.swf"),
    tutorialHQPositionsPath: path.join(workspaceRoot, "assets", "recreations", "TutorialHQPositions.xml"),
    tutorialSplashPath: path.join(workspaceRoot, "apps", "server", "assets", "splash.swf"),
    httpPort: Number(process.env.MCITY_HTTP_PORT ?? "31803"),
    httpsPort: Number(process.env.MCITY_HTTPS_PORT ?? "31804"),
    facebookHttpsPort: Number(process.env.MCITY_FACEBOOK_PORT ?? "443"),
    dbPath: process.env.MCITY_DB_PATH ?? path.join(workspaceRoot, "generated", "data", "mcity.sqlite"),
    launcherUserId: process.env.MCITY_UID ?? "100000000000001",
    launcherLang: process.env.MCITY_LANG ?? "en_US",
    useHttpsFacebookShim: process.env.MCITY_DISABLE_FB_SHIM === "1" ? false : true,
    requireHttpsFacebookShim: process.env.MCITY_REQUIRE_FB_SHIM === "1",
    launchSecret: process.env.MCITY_LAUNCH_SECRET || undefined
  };
}
