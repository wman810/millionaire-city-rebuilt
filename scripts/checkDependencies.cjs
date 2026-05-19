const fs = require("node:fs");
const path = require("node:path");

const workspaceRoot = path.resolve(__dirname, "..");
const requestedBins = process.argv.slice(2);

if (requestedBins.length === 0) {
  process.exit(0);
}

const binDirs = [
  path.join(workspaceRoot, "node_modules", ".bin"),
  path.join(process.cwd(), "node_modules", ".bin"),
  path.join(workspaceRoot, "apps", "server", "node_modules", ".bin"),
  path.join(workspaceRoot, "apps", "desktop", "node_modules", ".bin"),
  path.join(workspaceRoot, "packages", "shared", "node_modules", ".bin")
];
const extensions = process.platform === "win32" ? [".cmd", ".exe", ".ps1", ""] : [""];

function hasBinary(name) {
  return binDirs.some((binDir) =>
    extensions.some((extension) => fs.existsSync(path.join(binDir, `${name}${extension}`)))
  );
}

const missingBins = requestedBins.filter((name) => !hasBinary(name));

if (missingBins.length > 0) {
  const installCommand = process.platform === "win32" ? "cmd /c npm install" : "npm install";
  console.error("");
  console.error("[mcity] Project dependencies are not installed.");
  console.error(`[mcity] Missing local npm tools: ${missingBins.join(", ")}`);
  console.error("");
  console.error("Run this once from the repository root:");
  console.error(`  ${installCommand}`);
  console.error("");
  console.error("Then retry the npm command.");
  console.error("");
  process.exit(1);
}
