import fs from "fs";
import path from "path";
import { spawnSync } from "child_process";
import { getServerConfig, type ServerConfig } from "../config.js";

interface ClientPatch {
  className: string;
  sourcePath: string;
  note: string;
  errorMessage: string;
}

const config = getServerConfig("current");
const originalConfig = getServerConfig("original");
const clientPatchSourcesDir = path.join(config.workspaceRoot, "client-patch-sources");
const FFDEC_VERSION = "26.0.0";
const FFDEC_ARCHIVE_URL = `https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version${FFDEC_VERSION}/ffdec_${FFDEC_VERSION}.zip`;
const ffdecDir = path.join(config.workspaceRoot, "generated", "tools", `ffdec-${FFDEC_VERSION}`);
const ffdecJarPath = path.join(ffdecDir, "ffdec.jar");
const ffdecZipPath = path.join(ffdecDir, `ffdec_${FFDEC_VERSION}.zip`);

const clientPatches: ClientPatch[] = [
  {
    className: "Config",
    sourcePath: path.join(clientPatchSourcesDir, "Config.as"),
    note: "Config patched to use local server-backed Facebook/fan data and allow local runtime toggles.",
    errorMessage: "Failed to patch Config in the private client SWF."
  },
  {
    className: "Dollars",
    sourcePath: path.join(clientPatchSourcesDir, "Dollars.as"),
    note: "Dollars patched to enable original debug mode, climate particles, and classic item designs from launcher FlashVars.",
    errorMessage: "Failed to patch Dollars in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.world.items.ItemDefinition",
    sourcePath: path.join(clientPatchSourcesDir, "scripts", "com", "dchoc", "dollars", "world", "items", "ItemDefinition.as"),
    note: "ItemDefinition patched to optionally prefer classic item art symbols before newer *_new exports.",
    errorMessage: "Failed to patch ItemDefinition in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.world.items.ItemObject",
    sourcePath: path.join(clientPatchSourcesDir, "scripts", "com", "dchoc", "dollars", "world", "items", "ItemObject.as"),
    note: "ItemObject patched so live building effect overlays follow the classic item art toggle.",
    errorMessage: "Failed to patch ItemObject in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.world.items.decorations.ItemDecoration",
    sourcePath: path.join(
      clientPatchSourcesDir,
      "scripts",
      "com",
      "dchoc",
      "dollars",
      "world",
      "items",
      "decorations",
      "ItemDecoration.as"
    ),
    note: "ItemDecoration patched so item skins and flags follow the classic item art toggle.",
    errorMessage: "Failed to patch ItemDecoration in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.GUI.PopupGold",
    sourcePath: path.join(clientPatchSourcesDir, "scripts", "com", "dchoc", "dollars", "GUI", "PopupGold.as"),
    note: "PopupGold patched to complete Add Gold purchases without enabling the Facebook Credits HUD.",
    errorMessage: "Failed to patch PopupGold in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.GUI.PopupEmail",
    sourcePath: path.join(clientPatchSourcesDir, "scripts", "com", "dchoc", "dollars", "GUI", "PopupEmail.as"),
    note: "PopupEmail patched to complete local VIP Club confirmation immediately after a valid email is accepted.",
    errorMessage: "Failed to patch PopupEmail in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.utils.metrics.CustomizerManager",
    sourcePath: path.join(
      clientPatchSourcesDir,
      "scripts",
      "com",
      "dchoc",
      "dollars",
      "utils",
      "metrics",
      "CustomizerManager.as"
    ),
    note: "CustomizerManager patched to treat archived cross-promotion app unlocks as completed locally.",
    errorMessage: "Failed to patch CustomizerManager in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.friends.FriendObject",
    sourcePath: path.join(clientPatchSourcesDir, "scripts", "com", "dchoc", "dollars", "friends", "FriendObject.as"),
    note: "FriendObject patched to reload an already-loaded NPC portrait after advisor selection changes it.",
    errorMessage: "Failed to patch FriendObject in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.friends.FriendsBarContentFriend",
    sourcePath: path.join(
      clientPatchSourcesDir,
      "scripts",
      "com",
      "dchoc",
      "dollars",
      "friends",
      "FriendsBarContentFriend.as"
    ),
    note: "FriendsBarContentFriend patched so local player name changes repaint the existing friends bar entry.",
    errorMessage: "Failed to patch FriendsBarContentFriend in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.utils.Mouse.MouseWheelEnabler",
    sourcePath: path.join(clientPatchSourcesDir, "scripts", "com", "dchoc", "dollars", "utils", "Mouse", "MouseWheelEnabler.as"),
    note: "MouseWheelEnabler patched to remove debug console spam and use non-passive wheel listeners.",
    errorMessage: "Failed to patch MouseWheelEnabler in the private client SWF."
  },
  {
    className: "com.dchoc.dollars.server.Server",
    sourcePath: path.join(clientPatchSourcesDir, "scripts", "com", "dchoc", "dollars", "server", "Server.as"),
    note: "Server patched to accept local launcher stat refreshes without reloading the SWF.",
    errorMessage: "Failed to patch Server in the private client SWF."
  }
];

const originalClientPatches: ClientPatch[] = [
  {
    className: "Config",
    sourcePath: path.join(clientPatchSourcesDir, "0.338", "Config.as"),
    note: "Config patched to use server-backed social data, disable retired analytics, and allow original-client runtime toggles.",
    errorMessage: "Failed to patch Config in the original 0.338 client SWF."
  },
  {
    className: "Dollars",
    sourcePath: path.join(clientPatchSourcesDir, "0.338", "Dollars.as"),
    note: "Dollars patched to read launcher debug and climate switches without replacing the original startup flow.",
    errorMessage: "Failed to patch Dollars in the original 0.338 client SWF."
  },
  {
    className: "com.dchoc.dollars.GUI.PopupGold",
    sourcePath: path.join(clientPatchSourcesDir, "0.338", "scripts", "com", "dchoc", "dollars", "GUI", "PopupGold.as"),
    note: "PopupGold patched to award archived gold packages locally and persist each purchase exactly once.",
    errorMessage: "Failed to patch PopupGold in the original 0.338 client SWF."
  },
  {
    className: "com.dchoc.dollars.GUI.PopupEmail",
    sourcePath: path.join(clientPatchSourcesDir, "0.338", "scripts", "com", "dchoc", "dollars", "GUI", "PopupEmail.as"),
    note: "PopupEmail patched to complete local VIP Club confirmation after a valid email is accepted.",
    errorMessage: "Failed to patch PopupEmail in the original 0.338 client SWF."
  },
  {
    className: "com.dchoc.dollars.friends.FriendsBarContentFriend",
    sourcePath: path.join(
      clientPatchSourcesDir,
      "0.338",
      "scripts",
      "com",
      "dchoc",
      "dollars",
      "friends",
      "FriendsBarContentFriend.as"
    ),
    note: "FriendsBarContentFriend patched to repaint local names and reload changed profile portraits using the original loader architecture.",
    errorMessage: "Failed to patch FriendsBarContentFriend in the original 0.338 client SWF."
  },
  {
    className: "com.dchoc.dollars.utils.Mouse.MouseWheelEnabler",
    sourcePath: path.join(
      clientPatchSourcesDir,
      "0.338",
      "scripts",
      "com",
      "dchoc",
      "dollars",
      "utils",
      "Mouse",
      "MouseWheelEnabler.as"
    ),
    note: "MouseWheelEnabler patched to remove console spam and support modern non-passive wheel events.",
    errorMessage: "Failed to patch MouseWheelEnabler in the original 0.338 client SWF."
  },
  {
    className: "com.dchoc.dollars.server.Server",
    sourcePath: path.join(clientPatchSourcesDir, "0.338", "scripts", "com", "dchoc", "dollars", "server", "Server.as"),
    note: "Server patched to accept local stat and profile refreshes without reloading the original SWF.",
    errorMessage: "Failed to patch Server in the original 0.338 client SWF."
  }
];

preparePrivateClient(config, clientPatches, "Current 0.501 private client copy isolated from the recovered archive.");
preparePrivateClient(
  originalConfig,
  originalClientPatches,
  "Original 0.338 client with archived developer-path/debug metadata removed and version-adapted local compatibility patches. Classic item art is already native to this client, and its archived rules contain no cross-promotion item locks."
);

function preparePrivateClient(targetConfig: ServerConfig, patches: ClientPatch[], description: string): void {
  fs.mkdirSync(path.dirname(targetConfig.privateClientSwfPath), { recursive: true });
  fs.copyFileSync(targetConfig.sourceClientSwfPath, targetConfig.privateClientSwfPath);
  patchPrivateClientSwf(targetConfig, patches);
  writeClientBuildManifest(targetConfig, patches, description);
  console.log(`[mcity] Prepared private client copy at ${targetConfig.privateClientSwfPath}`);
}

function patchPrivateClientSwf(targetConfig: ServerConfig, patches: ClientPatch[]): void {
  ensureFfdecInstalled();
  for (const patch of patches) {
    replaceClassInPrivateClient(targetConfig, patch);
  }
}

function replaceClassInPrivateClient(targetConfig: ServerConfig, patch: ClientPatch): void {
  if (!fs.existsSync(patch.sourcePath)) {
    throw new Error(`Client patch source not found: ${patch.sourcePath}`);
  }

  const temporaryOutputPath = path.join(path.dirname(targetConfig.privateClientSwfPath), "Dollars.private.tmp.swf");
  if (fs.existsSync(temporaryOutputPath)) {
    fs.rmSync(temporaryOutputPath, { force: true });
  }

  runProcess(
    "java",
    [
      "-jar",
      ffdecJarPath,
      "-replace",
      targetConfig.privateClientSwfPath,
      temporaryOutputPath,
      patch.className,
      patch.sourcePath
    ],
    patch.errorMessage
  );
  fs.copyFileSync(temporaryOutputPath, targetConfig.privateClientSwfPath);
  fs.rmSync(temporaryOutputPath, { force: true });
}

function writeClientBuildManifest(
  targetConfig: ServerConfig,
  patches: ClientPatch[],
  description: string
): void {
  const manifestPath = path.join(path.dirname(targetConfig.privateClientSwfPath), "client-build.json");
  fs.writeFileSync(
    manifestPath,
    JSON.stringify(
      {
        gameVariant: targetConfig.gameVariant,
        gameVersion: targetConfig.gameVersion,
        source: toPortableWorkspacePath(targetConfig.workspaceRoot, targetConfig.sourceClientSwfPath),
        output: toPortableWorkspacePath(targetConfig.workspaceRoot, targetConfig.privateClientSwfPath),
        preparedAt: new Date().toISOString(),
        notes: [
          description,
          "Runtime compatibility provided by the local launcher and HTTPS Facebook shim.",
          ...patches.map((patch) => patch.note)
        ]
      },
      null,
      2
    )
  );
}

function toPortableWorkspacePath(workspaceRoot: string, targetPath: string): string {
  return path.relative(workspaceRoot, targetPath).split(path.sep).join("/");
}

function ensureFfdecInstalled(): void {
  if (fs.existsSync(ffdecJarPath)) {
    return;
  }

  fs.mkdirSync(ffdecDir, { recursive: true });
  downloadFile(FFDEC_ARCHIVE_URL, ffdecZipPath);
  extractZip(ffdecZipPath, ffdecDir);

  if (!fs.existsSync(ffdecJarPath)) {
    throw new Error(`FFDec was installed, but ${ffdecJarPath} was not found.`);
  }
}

function downloadFile(url: string, destinationPath: string): void {
  console.log(`[mcity] Downloading FFDec from ${url}`);
  const temporaryPath = `${destinationPath}.tmp`;
  if (fs.existsSync(temporaryPath)) {
    fs.rmSync(temporaryPath, { force: true });
  }

  downloadFileSync(url, temporaryPath, 0);
  fs.renameSync(temporaryPath, destinationPath);
}

function downloadFileSync(url: string, destinationPath: string, redirectCount: number): void {
  if (redirectCount > 5) {
    throw new Error("Too many redirects while downloading FFDec.");
  }

  const script = `
const fs = require("node:fs");
const https = require("node:https");
const url = ${JSON.stringify(url)};
const destinationPath = ${JSON.stringify(destinationPath)};
const redirectCount = ${redirectCount};
function download(currentUrl, redirects) {
  if (redirects > 5) {
    console.error("Too many redirects while downloading FFDec.");
    process.exit(1);
  }
  https.get(currentUrl, (response) => {
    if ([301, 302, 303, 307, 308].includes(response.statusCode) && response.headers.location) {
      response.resume();
      download(new URL(response.headers.location, currentUrl).toString(), redirects + 1);
      return;
    }
    if (response.statusCode !== 200) {
      console.error("Unexpected HTTP status " + response.statusCode + " while downloading FFDec.");
      process.exit(1);
    }
    const file = fs.createWriteStream(destinationPath);
    response.pipe(file);
    file.on("finish", () => file.close(() => process.exit(0)));
  }).on("error", (error) => {
    console.error(error);
    process.exit(1);
  });
}
download(url, redirectCount);
`;

  runProcess(process.execPath, ["-e", script], "Failed to download FFDec.");
}

function extractZip(zipPath: string, destinationPath: string): void {
  if (process.platform === "win32") {
    runProcess(
      "powershell",
      [
        "-NoProfile",
        "-Command",
        [
          "$ErrorActionPreference='Stop'",
          "$ProgressPreference='SilentlyContinue'",
          `Expand-Archive -LiteralPath '${zipPath}' -DestinationPath '${destinationPath}' -Force`
        ].join("; ")
      ],
      "Failed to extract FFDec."
    );
    return;
  }

  runProcess("unzip", ["-q", "-o", zipPath, "-d", destinationPath], "Failed to extract FFDec.");
}

function runProcess(command: string, args: string[], errorMessage: string): void {
  const result = spawnSync(command, args, {
    cwd: config.workspaceRoot,
    stdio: "inherit"
  });

  if (result.status !== 0) {
    throw new Error(errorMessage);
  }
}
