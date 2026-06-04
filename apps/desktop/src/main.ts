import path from "path";
import fs from "fs";
import http, { type IncomingMessage } from "http";
import https from "https";
import { spawn, spawnSync, type ChildProcess } from "child_process";
import { app, BrowserWindow, dialog, Menu, type MenuItemConstructorOptions } from "electron";
import { configureFlash } from "./flash-loader";

const workspaceRoot = path.resolve(__dirname, "../../..");
const serverDistPath = path.join(workspaceRoot, "apps", "server", "dist", "main.js");
const launcherBaseUrl = "https://127.0.0.1:31804/launcher";
const healthUrl = "https://127.0.0.1:31804/health";

let mainWindow: BrowserWindow | null = null;
let serverProcess: ChildProcess | null = null;
let swfDebugMode = process.env.MCITY_SWF_DEBUG === "1";

const flashPluginPath = configureFlash(app);

if (process.platform === "linux") {
  app.commandLine.appendSwitch("no-sandbox");
}

app.commandLine.appendSwitch(
  "host-resolver-rules",
  "MAP graph.facebook.com 127.0.0.1,MAP api.facebook.com 127.0.0.1"
);
app.commandLine.appendSwitch("ignore-certificate-errors");
app.commandLine.appendSwitch("allow-running-insecure-content");

function createWindow(): BrowserWindow {
  const win = new BrowserWindow({
    width: 1280,
    height: 720,
    title: "Millionaire City Private Server",
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

function getLauncherUrl(): string {
  return swfDebugMode ? `${launcherBaseUrl}?debug=1` : launcherBaseUrl;
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
          if (!win.isDestroyed()) {
            void win.loadURL(getLauncherUrl());
          }
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
    env: process.env,
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
