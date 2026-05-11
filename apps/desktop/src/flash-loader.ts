import path from "path";
import fs from "fs";
import type { App } from "electron";

const FLASH_ASSET_DIR = path.join(__dirname, "..", "assets", "flash");

function getPluginName(): string {
  switch (process.platform) {
    case "win32":
      return getWindowsPluginName();
    case "darwin":
      return "PepperFlashPlayer.plugin";
    case "linux":
      return "libpepflashplayer.so";
    default:
      throw new Error(`Unsupported platform for Pepper Flash: ${process.platform}`);
  }
}

function getWindowsPluginName(): string {
  const prefix = process.arch === "ia32" ? "pepflashplayer32_" : "pepflashplayer64_";
  const preferred = process.env.MCITY_FLASH_DLL;
  if (preferred) {
    return preferred;
  }

  const entries = fs
    .readdirSync(FLASH_ASSET_DIR, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.startsWith(prefix) && entry.name.endsWith(".dll"))
    .map((entry) => entry.name)
    .sort(compareFlashDllNames);

  if (entries.length === 0) {
    throw new Error(`No Pepper Flash DLL found in ${FLASH_ASSET_DIR} for ${process.arch}.`);
  }

  return entries[0];
}

function compareFlashDllNames(left: string, right: string): number {
  const a = parsePluginVersion(left);
  const b = parsePluginVersion(right);

  for (let index = 0; index < Math.max(a.length, b.length); index += 1) {
    const diff = (b[index] ?? 0) - (a[index] ?? 0);
    if (diff !== 0) {
      return diff;
    }
  }

  return left.localeCompare(right);
}

function parsePluginVersion(fileName: string): number[] {
  const match = fileName.match(/_(\d+)_(\d+)_(\d+)_(\d+)\.dll$/i);
  if (!match) {
    return [0, 0, 0, 0];
  }

  return match.slice(1).map((part) => Number(part));
}

function formatPluginVersion(fileName: string): string {
  const version = parsePluginVersion(fileName);
  return version.join(".");
}

export function configureFlash(app: App): string {
  const pluginName = getPluginName();
  const pluginPath = path.isAbsolute(pluginName) ? pluginName : path.join(FLASH_ASSET_DIR, pluginName);
  app.commandLine.appendSwitch("ppapi-flash-path", pluginPath);
  app.commandLine.appendSwitch("ppapi-flash-version", formatPluginVersion(path.basename(pluginPath)));
  return pluginPath;
}
