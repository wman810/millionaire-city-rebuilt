const fs = require("node:fs");
const path = require("node:path");

if (process.platform !== "win32") {
  throw new Error(`Release runtime preparation currently supports Windows only, got ${process.platform}.`);
}

const workspaceRoot = path.resolve(__dirname, "..");
const sourceNodePath = process.execPath;
const targetDir = path.join(workspaceRoot, "generated", "runtime", "node", `${process.platform}-${process.arch}`);
const targetNodePath = path.join(targetDir, "node.exe");

fs.mkdirSync(targetDir, { recursive: true });
fs.copyFileSync(sourceNodePath, targetNodePath);

console.log(`[mcity] Copied Node runtime from ${sourceNodePath} to ${targetNodePath}`);
