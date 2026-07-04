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
const desktopLogPath = path.join(workspaceRoot, "generated", "logs", "desktop.log");
const desktopSettingsPath = path.join(workspaceRoot, "generated", "settings", "desktop.json");
const facebookShimPort = getFacebookShimPort();
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
let swfDebugMode = getEnvBoolean("MCITY_SWF_DEBUG") ?? desktopSettings.swfDebugMode ?? false;
let climateMode = getEnvBoolean("MCITY_USE_CLIMATE") ?? desktopSettings.climateMode ?? false;
let oldItemDesigns = getEnvBoolean("MCITY_OLD_ITEM_DESIGNS") ?? desktopSettings.oldItemDesigns ?? false;
let localProfileSettingsVisible = true;

installFileLogging();

const flashPluginPath = configureFlash(app);

if (process.platform === "linux") {
  app.commandLine.appendSwitch("no-sandbox");
}

app.commandLine.appendSwitch("ignore-certificate-errors");
app.commandLine.appendSwitch("allow-running-insecure-content");

function createWindow(): BrowserWindow {
  const win = new BrowserWindow({
    width: 1280,
    height: 720,
    title: "Millionaire City Private Server",
    icon: appIconPath,
    show: false,
    webPreferences: {
      plugins: true,
      sandbox: false
    }
  });
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
    const ok = await probeHealth();
    if (ok) {
      return;
    }
    await delay(300);
  }
  throw new Error("Timed out waiting for the local server.");
}

function probeHealth(): Promise<boolean> {
  return new Promise((resolve) => {
    const request = https.get(healthUrl, { rejectUnauthorized: false }, (response: IncomingMessage) => {
      response.resume();
      resolve(response.statusCode === 200);
    });

    request.on("error", () => resolve(false));
    request.setTimeout(1000, () => {
      request.destroy();
      resolve(false);
    });
  });
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getFacebookShimPort(): number {
  const port = Number(process.env.MCITY_FACEBOOK_PORT ?? "31805");
  return Number.isInteger(port) && port > 0 && port <= 65535 ? port : 31805;
}

function installFacebookRequestRedirect(): void {
  const filter = {
    urls: ["https://graph.facebook.com/*", "https://api.facebook.com/*"]
  };

  session.defaultSession.webRequest.onBeforeRequest(filter, (details, callback) => {
    const originalUrl = new URL(details.url);
    const redirectURL = `https://127.0.0.1:${facebookShimPort}${originalUrl.pathname}${originalUrl.search}`;
    console.log(`[desktop] Redirecting Facebook request to local shim: ${originalUrl.host}${originalUrl.pathname}`);
    callback({ redirectURL });
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

  serverProcess = spawn(nodeExecutable, [serverDistPath], {
    cwd: workspaceRoot,
    env: {
      ...process.env,
      MCITY_FACEBOOK_PORT: String(facebookShimPort)
    },
    stdio: ["ignore", "pipe", "pipe"]
  });

  serverProcess.stdout?.on("data", (chunk: Buffer | string) => {
    const text = String(chunk).trim();
    if (text) {
      console.log(`[server] ${text}`);
      setStatus(text);
    }
  });

  serverProcess.stderr?.on("data", (chunk: Buffer | string) => {
    const text = String(chunk).trim();
    if (text) {
      console.error(`[server] ${text}`);
      setStatus(text);
    }
  });

  await waitForServer();
  setStatus("Local backend ready. Loading Flash client...");
  await mainWindow?.loadURL(getLauncherUrl());
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.show();
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
  if (serverProcess && !serverProcess.killed) {
    serverProcess.kill();
    serverProcess = null;
  }
}

app.whenReady().then(async () => {
  installFacebookRequestRedirect();
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
