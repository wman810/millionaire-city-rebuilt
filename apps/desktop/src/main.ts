import crypto from "crypto";
import path from "path";
import fs from "fs";
import http, { type IncomingMessage } from "http";
import https from "https";
import { spawn, spawnSync, type ChildProcess } from "child_process";
import { app, BrowserWindow, dialog, Menu, session, type MenuItem, type MenuItemConstructorOptions } from "electron";
import { configureFlash } from "./flash-loader";

const workspaceRoot = path.resolve(__dirname, "../../..");
const serverDistPath = path.join(workspaceRoot, "apps", "server", "dist", "main.js");
const launcherBaseUrl = "https://127.0.0.1:31804/launcher";
const healthUrl = "https://127.0.0.1:31804/health";
const healthChallengeHeader = "x-mcity-health-challenge";
const healthProofHeader = "x-mcity-health-proof";
const serverLaunchSecret = crypto.randomBytes(32).toString("hex");
const launcherOrigin = new URL(launcherBaseUrl).origin;
const desktopLogPath = path.join(workspaceRoot, "generated", "logs", "desktop.log");
const desktopSettingsPath = path.join(workspaceRoot, "generated", "settings", "desktop.json");
const facebookShimPort = getFacebookShimPort();
const facebookShimOrigin = `https://127.0.0.1:${facebookShimPort}`;
const trustedRuntimeOrigins = new Set([launcherOrigin, facebookShimOrigin]);
const facebookApiHosts = new Set(["graph.facebook.com", "api.facebook.com"]);
const trustedInternalProtocols = new Set([
  "about:",
  "blob:",
  "chrome-devtools:",
  "data:",
  "devtools:"
]);
const localProfileSettingsMenuItemId = "show-local-profile-settings";
const appIconPath = path.join(
  workspaceRoot,
  "apps",
  "desktop",
  "assets",
  "window-icon.ico"
);

interface DesktopSettings {
  swfDebugMode?: boolean;
  climateMode?: boolean;
  oldItemDesigns?: boolean;
}

const desktopSettings = readDesktopSettings();

let mainWindow: BrowserWindow | null = null;
let serverProcess: ChildProcess | null = null;
let serverExitError: Error | null = null;
let localServerAuthenticated = false;
let shuttingDown = false;
let swfDebugMode = getEnvBoolean("MCITY_SWF_DEBUG") ?? desktopSettings.swfDebugMode ?? false;
let climateMode = getEnvBoolean("MCITY_USE_CLIMATE") ?? desktopSettings.climateMode ?? false;
let oldItemDesigns = getEnvBoolean("MCITY_OLD_ITEM_DESIGNS") ?? desktopSettings.oldItemDesigns ?? false;
let localProfileSettingsVisible = true;

installFileLogging();
installCertificatePolicy();

const flashPluginPath = configureFlash(app);

if (process.platform === "linux") {
  app.commandLine.appendSwitch("no-sandbox");
}

function createWindow(): BrowserWindow {
  const win = new BrowserWindow({
    width: 1280,
    height: 720,
    title: "Millionaire City",
    icon: appIconPath,
    show: false,
    webPreferences: {
      plugins: true,
      nodeIntegration: false,
      nodeIntegrationInWorker: false,
      nodeIntegrationInSubFrames: false,
      enableRemoteModule: false,
      contextIsolation: true,
      worldSafeExecuteJavaScript: true,
      nativeWindowOpen: false,
      webviewTag: false,
      webSecurity: true,
      allowRunningInsecureContent: false,
      safeDialogs: true,
      navigateOnDragDrop: false,
      // Pepper Flash requires the legacy unsandboxed renderer in Electron 10.
      sandbox: false
    }
  });
  installRendererGuards(win);
  installAppMenu(win);

  win.maximize();
  win.webContents.on("zoom-changed", (event, zoomDirection) => {
    event.preventDefault();
    applyPageZoom(win, zoomDirection);
  });
  win.webContents.on("did-fail-load", (_event, errorCode, errorDescription, validatedUrl) => {
    const message = `Renderer load failed (${errorCode}) ${errorDescription}: ${validatedUrl}`;
    console.error(message);
    setStatus(message);
  });

  win.webContents.on("console-message", (_event, level, message, line, sourceId) => {
    console.log(`[renderer:${level}] ${message} (${sourceId}:${line})`);
  });
  win.webContents.on("did-finish-load", () => {
    syncLocalProfileSettingsMenuFromPage(win);
  });

  if (process.env.MCITY_OPEN_DEVTOOLS === "1") {
    openDevToolsForWindow(win);
  }

  return win;
}

function installCertificatePolicy(): void {
  app.on(
    "certificate-error",
    (event, contents, rawUrl, error, _certificate, callback) => {
      let trusted = false;

      try {
        const url = new URL(rawUrl);
        trusted =
          localServerAuthenticated &&
          contents === mainWindow?.webContents &&
          error === "net::ERR_CERT_AUTHORITY_INVALID" &&
          url.protocol === "https:" &&
          url.hostname === "127.0.0.1" &&
          url.username === "" &&
          url.password === "" &&
          trustedRuntimeOrigins.has(url.origin);
      } catch {
        trusted = false;
      }

      if (trusted) {
        event.preventDefault();
        callback(true);
        return;
      }

      console.warn(`[desktop] Rejected certificate error (${error}) for ${formatUrlForLog(rawUrl)}`);
      callback(false);
    }
  );
}

function installRendererGuards(win: BrowserWindow): void {
  win.webContents.on("will-navigate", (event, rawUrl) => {
    if (!isTrustedRendererUrl(rawUrl)) {
      console.warn(`[desktop] Blocked renderer navigation to ${formatUrlForLog(rawUrl)}`);
      event.preventDefault();
    }
  });

  win.webContents.on("will-redirect", (event, rawUrl) => {
    if (!isTrustedRendererUrl(rawUrl)) {
      console.warn(`[desktop] Blocked renderer redirect to ${formatUrlForLog(rawUrl)}`);
      event.preventDefault();
    }
  });

  win.webContents.on("new-window", (event, rawUrl) => {
    console.warn(`[desktop] Blocked new window for ${formatUrlForLog(rawUrl)}`);
    event.preventDefault();
  });

  win.webContents.on("will-attach-webview", (event) => {
    console.warn("[desktop] Blocked webview attachment.");
    event.preventDefault();
  });
}

function isTrustedRendererUrl(rawUrl: string): boolean {
  try {
    const url = new URL(rawUrl);
    return url.username === "" && url.password === "" && url.origin === launcherOrigin;
  } catch {
    return false;
  }
}

function formatUrlForLog(rawUrl: string): string {
  try {
    const url = new URL(rawUrl);
    if (url.origin === "null") {
      return url.protocol;
    }
    return `${url.origin}${url.pathname}`;
  } catch {
    return "an invalid URL";
  }
}

function applyPageZoom(win: BrowserWindow, direction: "in" | "out"): void {
  const currentZoom = win.webContents.getZoomFactor();
  const nextZoom =
    direction === "in"
      ? Math.min(3, Number((currentZoom + 0.1).toFixed(2)))
      : Math.max(0.5, Number((currentZoom - 0.1).toFixed(2)));
  win.webContents.setZoomFactor(nextZoom);
}

function openDevToolsForWindow(win: BrowserWindow): void {
  if (!win || win.isDestroyed()) {
    return;
  }

  if (win.webContents.isDevToolsOpened()) {
    win.webContents.focus();
    return;
  }

  win.webContents.openDevTools({ mode: "right" });
}

function getEnvBoolean(name: string): boolean | undefined {
  const value = process.env[name]?.toLowerCase();
  if (value === "1" || value === "true" || value === "yes") {
    return true;
  }
  if (value === "0" || value === "false" || value === "no") {
    return false;
  }
  return undefined;
}

function readDesktopSettings(): DesktopSettings {
  if (!fs.existsSync(desktopSettingsPath)) {
    return {};
  }

  try {
    const value = JSON.parse(fs.readFileSync(desktopSettingsPath, "utf8")) as Record<string, unknown>;
    return {
      swfDebugMode: getBooleanSetting(value.swfDebugMode),
      climateMode: getBooleanSetting(value.climateMode),
      oldItemDesigns: getBooleanSetting(value.oldItemDesigns)
    };
  } catch (error) {
    console.warn("[desktop] Failed to read desktop settings:", error);
    return {};
  }
}

function getBooleanSetting(value: unknown): boolean | undefined {
  return typeof value === "boolean" ? value : undefined;
}

function saveDesktopSettings(): void {
  try {
    fs.mkdirSync(path.dirname(desktopSettingsPath), { recursive: true });
    fs.writeFileSync(
      desktopSettingsPath,
      JSON.stringify(
        {
          swfDebugMode,
          climateMode,
          oldItemDesigns
        },
        null,
        2
      )
    );
  } catch (error) {
    console.debug("[desktop] Failed to save desktop settings:", error);
  }
}

function reloadWithCurrentLauncherOptions(win: BrowserWindow): void {
  saveDesktopSettings();
  if (!win.isDestroyed()) {
    void win.loadURL(getLauncherUrl());
  }
}

function getLauncherUrl(): string {
  const params = new URLSearchParams();
  if (swfDebugMode) {
    params.set("debug", "1");
  }
  if (climateMode) {
    params.set("climate", "1");
  }
  if (oldItemDesigns) {
    params.set("oldItems", "1");
  }

  const query = params.toString();
  return query ? `${launcherBaseUrl}?${query}` : launcherBaseUrl;
}

function installAppMenu(win: BrowserWindow): void {
  const viewMenu: MenuItemConstructorOptions = {
    label: "View",
    submenu: [
      {
        label: "SWF Debug Mode",
        type: "checkbox",
        checked: swfDebugMode,
        click: (menuItem) => {
          swfDebugMode = menuItem.checked;
          reloadWithCurrentLauncherOptions(win);
        }
      },
      {
        label: "Snowflake Particles",
        type: "checkbox",
        checked: climateMode,
        click: (menuItem) => {
          climateMode = menuItem.checked;
          reloadWithCurrentLauncherOptions(win);
        }
      },
      {
        label: "Classic Building Designs",
        type: "checkbox",
        checked: oldItemDesigns,
        click: (menuItem) => {
          oldItemDesigns = menuItem.checked;
          reloadWithCurrentLauncherOptions(win);
        }
      },
      {
        id: localProfileSettingsMenuItemId,
        label: "Show Local Profile Settings",
        type: "checkbox",
        checked: localProfileSettingsVisible,
        click: (menuItem) => {
          localProfileSettingsVisible = menuItem.checked;
          applyLocalProfileSettingsVisibility(win, localProfileSettingsVisible);
        }
      },
      { type: "separator" },
      {
        label: "Open DevTools",
        accelerator: "CommandOrControl+Shift+I",
        click: () => openDevToolsForWindow(win)
      },
      {
        label: "Reload",
        accelerator: "F5",
        click: () => {
          if (!win.isDestroyed()) {
            win.webContents.reloadIgnoringCache();
          }
        }
      },
      { type: "separator" },
      { role: "resetZoom" },
      {
        label: "Zoom In (Ctrl+Scroll Up)",
        click: () => applyPageZoom(win, "in")
      },
      {
        label: "Zoom Out (Ctrl+Scroll Down)",
        click: () => applyPageZoom(win, "out")
      },
      { type: "separator" },
      { role: "togglefullscreen" }
    ]
  };

  const menuTemplate: MenuItemConstructorOptions[] =
    process.platform === "darwin"
      ? [
          {
            label: "Millionaire City",
            submenu: [{ role: "about" }, { type: "separator" }, { role: "quit" }]
          },
          viewMenu
        ]
      : [viewMenu];

  Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));
}

function applyLocalProfileSettingsVisibility(win: BrowserWindow, visible: boolean): void {
  if (win.isDestroyed()) {
    return;
  }

  const safeVisible = visible ? "true" : "false";
  void win.webContents
    .executeJavaScript(
      `(() => {
        const visible = ${safeVisible};
        if (typeof window.setLocalProfileSettingsVisible === "function") {
          return window.setLocalProfileSettingsVisible(visible);
        }
        try {
          localStorage.setItem("mcity.localProfileSettingsVisible", visible ? "1" : "0");
        } catch (error) {
        }
        document.documentElement.classList.toggle("local-profile-settings-hidden", !visible);
        const panel = document.getElementById("local_profile_settings");
        if (panel) panel.hidden = !visible;
        return visible;
      })();`,
      true
    )
    .catch((error: unknown) => {
      console.debug("[desktop] Failed to update local profile settings visibility:", error);
    });
}

function syncLocalProfileSettingsMenuFromPage(win: BrowserWindow): void {
  if (win.isDestroyed()) {
    return;
  }

  void win.webContents
    .executeJavaScript(
      `(() => {
        if (typeof window.getLocalProfileSettingsVisible === "function") {
          return window.getLocalProfileSettingsVisible();
        }
        try {
          return localStorage.getItem("mcity.localProfileSettingsVisible") !== "0";
        } catch (error) {
          return true;
        }
      })();`,
      true
    )
    .then((visible: unknown) => {
      localProfileSettingsVisible = visible !== false;
      const item = findMenuItemById(Menu.getApplicationMenu(), localProfileSettingsMenuItemId);
      if (item) {
        item.checked = localProfileSettingsVisible;
      }
    })
    .catch((error: unknown) => {
      console.debug("[desktop] Failed to read local profile settings visibility:", error);
    });
}

function findMenuItemById(menu: Menu | null, id: string): MenuItem | null {
  if (!menu) {
    return null;
  }

  for (const item of menu.items) {
    if (item.id === id) {
      return item;
    }
    const nested = findMenuItemById(item.submenu ?? null, id);
    if (nested) {
      return nested;
    }
  }

  return null;
}

function setStatus(message: string): void {
  if (!mainWindow || mainWindow.isDestroyed()) {
    return;
  }

  const safe = JSON.stringify(message);
  void mainWindow.webContents
    .executeJavaScript(
      `(() => {
        const node = document.getElementById("status");
        if (node) node.textContent = ${safe};
      })();`,
      true
    )
    .catch((error: unknown) => {
      if (!mainWindow || mainWindow.isDestroyed()) {
        return;
      }
      console.debug("[desktop] Failed to update loading status:", error);
    });
}

async function waitForServer(): Promise<void> {
  for (let attempt = 0; attempt < 60; attempt += 1) {
    if (serverExitError) {
      throw serverExitError;
    }
    const ok = await probeHealth();
    if (ok && !serverExitError) {
      localServerAuthenticated = true;
      return;
    }
    await delay(300);
  }
  throw new Error("Timed out waiting for the local server.");
}

function probeHealth(): Promise<boolean> {
  return new Promise((resolve) => {
    const challenge = crypto.randomBytes(32).toString("hex");
    const expectedProof = crypto
      .createHmac("sha256", serverLaunchSecret)
      .update(`mcity-health-v1:${challenge}`)
      .digest("hex");
    const request = https.get(
      healthUrl,
      {
        rejectUnauthorized: false,
        headers: { [healthChallengeHeader]: challenge }
      },
      (response: IncomingMessage) => {
        response.resume();
        resolve(
          response.statusCode === 200 &&
            isExpectedHealthProof(response.headers[healthProofHeader], expectedProof)
        );
      }
    );

    request.on("error", () => resolve(false));
    request.setTimeout(1000, () => {
      request.destroy();
      resolve(false);
    });
  });
}

function isExpectedHealthProof(value: string | string[] | undefined, expected: string): boolean {
  if (typeof value !== "string" || !/^[a-f0-9]{64}$/.test(value)) {
    return false;
  }

  return crypto.timingSafeEqual(Buffer.from(value, "hex"), Buffer.from(expected, "hex"));
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getFacebookShimPort(): number {
  const port = Number(process.env.MCITY_FACEBOOK_PORT ?? "31805");
  return Number.isInteger(port) && port > 0 && port <= 65535 ? port : 31805;
}

function installDefaultSessionSecurity(): void {
  const runtimeSession = session.defaultSession;

  runtimeSession.setPermissionCheckHandler(() => false);
  runtimeSession.setPermissionRequestHandler((_contents, permission, callback) => {
    console.warn(`[desktop] Denied renderer permission request: ${permission}`);
    callback(false);
  });

  runtimeSession.on("will-download", (event, item) => {
    console.warn(`[desktop] Blocked download from ${formatUrlForLog(item.getURL())}`);
    event.preventDefault();
  });

  // Electron allows only one onBeforeRequest listener, so the Facebook rewrite and
  // the outbound deny policy must remain combined here.
  runtimeSession.webRequest.onBeforeRequest((details, callback) => {
    let url: URL;

    try {
      url = new URL(details.url);
    } catch {
      console.warn(`[desktop] Blocked ${details.resourceType} request with an invalid URL.`);
      callback({ cancel: true });
      return;
    }

    if (
      url.protocol === "https:" &&
      url.port === "" &&
      url.username === "" &&
      url.password === "" &&
      facebookApiHosts.has(url.hostname)
    ) {
      const redirectURL = `${facebookShimOrigin}${url.pathname}${url.search}`;
      console.log(`[desktop] Redirecting Facebook request to local shim: ${url.host}${url.pathname}`);
      callback({ redirectURL });
      return;
    }

    if (
      url.username === "" &&
      url.password === "" &&
      trustedRuntimeOrigins.has(url.origin)
    ) {
      callback({});
      return;
    }

    if (trustedInternalProtocols.has(url.protocol)) {
      callback({});
      return;
    }

    console.warn(
      `[desktop] Blocked ${details.resourceType} request to ${formatUrlForLog(details.url)}`
    );
    callback({ cancel: true });
  });
}

function installFileLogging(): void {
  const originalLog = console.log.bind(console);
  const originalWarn = console.warn.bind(console);
  const originalError = console.error.bind(console);
  const originalDebug = console.debug.bind(console);

  const write = (level: string, data: unknown[]) => {
    try {
      fs.mkdirSync(path.dirname(desktopLogPath), { recursive: true });
      const line = `${new Date().toISOString()} ${level} ${data.map(formatLogValue).join(" ")}\n`;
      fs.appendFileSync(desktopLogPath, line);
    } catch {
      // Logging must never prevent the game from starting.
    }
  };

  console.log = (...data: unknown[]) => {
    originalLog(...data);
    write("INFO", data);
  };
  console.warn = (...data: unknown[]) => {
    originalWarn(...data);
    write("WARN", data);
  };
  console.error = (...data: unknown[]) => {
    originalError(...data);
    write("ERROR", data);
  };
  console.debug = (...data: unknown[]) => {
    originalDebug(...data);
    write("DEBUG", data);
  };

  console.log(`[desktop] Writing logs to ${desktopLogPath}`);
}

function formatLogValue(value: unknown): string {
  if (value instanceof Error) {
    return value.stack ?? value.message;
  }
  if (typeof value === "string") {
    return value;
  }
  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
}

async function startEverything(): Promise<void> {
  if (!fs.existsSync(serverDistPath)) {
    throw new Error(`Server build not found at ${serverDistPath}. Run the workspace build first.`);
  }

  if (!fs.existsSync(flashPluginPath)) {
    throw new Error(`Pepper Flash plugin not found at ${flashPluginPath}.`);
  }

  const nodeExecutable = resolveNodeExecutable();

  serverExitError = null;
  localServerAuthenticated = false;

  const launchedProcess = spawn(nodeExecutable, [serverDistPath], {
    cwd: workspaceRoot,
    env: {
      ...process.env,
      MCITY_DISABLE_FB_SHIM: "0",
      MCITY_FACEBOOK_PORT: String(facebookShimPort),
      MCITY_HTTP_PORT: "31803",
      MCITY_HTTPS_PORT: "31804",
      MCITY_LAUNCH_SECRET: serverLaunchSecret,
      MCITY_REQUIRE_FB_SHIM: "1"
    },
    stdio: ["ignore", "pipe", "pipe"]
  });
  serverProcess = launchedProcess;

  launchedProcess.stdout?.on("data", (chunk: Buffer | string) => {
    const text = String(chunk).trim();
    if (text) {
      console.log(`[server] ${text}`);
      setStatus(text);
    }
  });

  launchedProcess.stderr?.on("data", (chunk: Buffer | string) => {
    const text = String(chunk).trim();
    if (text) {
      console.error(`[server] ${text}`);
      setStatus(text);
    }
  });

  launchedProcess.once("error", (error) => {
    handleServerProcessFailure(`Local backend failed to start: ${error.message}`);
  });
  launchedProcess.once("exit", (code, signal) => {
    if (serverProcess === launchedProcess) {
      serverProcess = null;
    }
    const reason = signal ? `signal ${signal}` : `exit code ${code ?? "unknown"}`;
    handleServerProcessFailure(`Local backend stopped unexpectedly (${reason}).`);
  });

  await waitForServer();
  setStatus("Local backend ready. Loading Flash client...");
  await mainWindow?.loadURL(getLauncherUrl());
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.show();
  }
}

function handleServerProcessFailure(message: string): void {
  if (shuttingDown || serverExitError) {
    return;
  }

  const wasAuthenticated = localServerAuthenticated;
  localServerAuthenticated = false;
  serverExitError = new Error(message);
  console.error(`[desktop] ${message}`);

  if (wasAuthenticated) {
    dialog.showErrorBox("Millionaire City Local Backend", message);
    app.quit();
  }
}

function resolveNodeExecutable(): string {
  const bundledNode = resolveBundledNodeExecutable();
  if (bundledNode) {
    return bundledNode;
  }

  const candidates = [
    process.env.MCITY_NODE_PATH,
    process.env.npm_node_execpath,
    process.execPath,
    ...(process.platform === "win32"
      ? ["C:\\Program Files\\nodejs\\node.exe", "C:\\Program Files (x86)\\nodejs\\node.exe"]
      : [])
  ].filter((value): value is string => Boolean(value));

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  const lookup = spawnSync(process.platform === "win32" ? "where" : "which", ["node"], {
    encoding: "utf8",
    windowsHide: true
  });

  if (lookup.status === 0) {
    const firstMatch = lookup.stdout
      .split(/\r?\n/)
      .map((line) => line.trim())
      .find(Boolean);
    if (firstMatch) {
      return firstMatch;
    }
  }

  throw new Error(
    "Could not find Node.js for the backend server. Set MCITY_NODE_PATH to your Node installation."
  );
}

function resolveBundledNodeExecutable(): string | undefined {
  const executableName = process.platform === "win32" ? "node.exe" : "node";
  const platformArch = `${process.platform}-${process.arch}`;
  const candidate = path.join(workspaceRoot, "generated", "runtime", "node", platformArch, executableName);
  return app.isPackaged && fs.existsSync(candidate) ? candidate : undefined;
}

async function shutdown(): Promise<void> {
  shuttingDown = true;
  localServerAuthenticated = false;
  if (serverProcess && !serverProcess.killed) {
    serverProcess.kill();
    serverProcess = null;
  }
}

app.whenReady().then(async () => {
  installDefaultSessionSecurity();
  mainWindow = createWindow();

  try {
    await startEverything();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    setStatus(message);
    dialog.showErrorBox("Millionaire City Private Server", message);
  }
});

app.on("window-all-closed", async () => {
  await shutdown();
  app.quit();
});

app.on("before-quit", async () => {
  await shutdown();
});
