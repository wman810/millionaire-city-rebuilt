const fs = require("node:fs");
const path = require("node:path");

const workspaceRoot = path.resolve(__dirname, "..");
const sourceNodePath = process.execPath;
const targetDir = path.join(workspaceRoot, "generated", "runtime", "node", `${process.platform}-${process.arch}`);
const targetNodePath = path.join(targetDir, process.platform === "win32" ? "node.exe" : "node");

fs.mkdirSync(targetDir, { recursive: true });
fs.copyFileSync(sourceNodePath, targetNodePath);
if (process.platform !== "win32") {
  fs.chmodSync(targetNodePath, 0o755);
}

if (process.platform === "darwin") {
  const flashExecutablePath = path.join(
    workspaceRoot,
    "apps",
    "desktop",
    "assets",
    "flash",
    "PepperFlashPlayer.plugin",
    "Contents",
    "MacOS",
    "PepperFlashPlayer"
  );
  fs.chmodSync(flashExecutablePath, 0o755);
  console.log(`[mcity] Marked Flash plugin executable at ${flashExecutablePath}`);
}

console.log(`[mcity] Copied Node runtime from ${sourceNodePath} to ${targetNodePath}`);
