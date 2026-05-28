import fs from "fs";
import path from "path";
import { spawnSync } from "child_process";
import { getServerConfig } from "../config.js";

const config = getServerConfig();
const clientDir = path.dirname(config.privateClientSwfPath);
const FFDEC_VERSION = "26.0.0";
const FFDEC_ARCHIVE_URL = `https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version${FFDEC_VERSION}/ffdec_${FFDEC_VERSION}.zip`;
const ffdecDir = path.join(config.workspaceRoot, "generated", "tools", `ffdec-${FFDEC_VERSION}`);
const ffdecJarPath = path.join(ffdecDir, "ffdec.jar");
const ffdecZipPath = path.join(ffdecDir, `ffdec_${FFDEC_VERSION}.zip`);
const dollarsSourcePath = path.join(config.workspaceRoot, "client-patch-sources", "Dollars.as");
const dollarsPatchedSourcePath = path.join(clientDir, "patches", "Dollars.patched.as");
const popupGoldSourcePath = path.join(
  config.workspaceRoot,
  "client-patch-sources",
  "scripts",
  "com",
  "dchoc",
  "dollars",
  "GUI",
  "PopupGold.as"
);
const popupGoldPatchedSourcePath = path.join(clientDir, "patches", "PopupGold.patched.as");
const popupEmailSourcePath = path.join(
  config.workspaceRoot,
  "client-patch-sources",
  "scripts",
  "com",
  "dchoc",
  "dollars",
  "GUI",
  "PopupEmail.as"
);
const popupEmailPatchedSourcePath = path.join(clientDir, "patches", "PopupEmail.patched.as");
const customizerManagerSourcePath = path.join(
  config.workspaceRoot,
  "client-patch-sources",
  "scripts",
  "com",
  "dchoc",
  "dollars",
  "utils",
  "metrics",
  "CustomizerManager.as"
);
const customizerManagerPatchedSourcePath = path.join(clientDir, "patches", "CustomizerManager.patched.as");
const friendObjectSourcePath = path.join(
  config.workspaceRoot,
  "client-patch-sources",
  "scripts",
  "com",
  "dchoc",
  "dollars",
  "friends",
  "FriendObject.as"
);
const friendObjectPatchedSourcePath = path.join(clientDir, "patches", "FriendObject.patched.as");
const crossPromotionDefinitionsPath = path.join(config.assetRoot, "Datas", "rules", "crosspromotionDefinitions.xml");
const popupGoldPatchedSnippet = `         FBCreditsPurchase.getInstance().startPurchaseProcess(this,false);
`;
const dollarsLoaderInfoPattern = / {9}var _loc1_:Object = smStage\.root\.loaderInfo\.parameters;\r?\n/;
const dollarsLoaderInfoSnippet = `         var _loc1_:Object = smStage.root.loaderInfo.parameters;
         if(_loc1_.debugMode == "1" || _loc1_.debugMode == "true")
         {
            Config.DEBUG_MODE = true;
            Config.DEBUG_CONSOLE = true;
         }
`;
const popupGoldPurchaseBranchPattern =
  / {9}if\(Config\.FACEBOOK_CREDITS_TO_BUY_GOLD\)\r?\n {9}\{\r?\n {12}FBCreditsPurchase\.getInstance\(\)\.startPurchaseProcess\(this,false\);\r?\n {9}\}\r?\n {9}else\r?\n {9}\{\r?\n {12}onClose\(null\);\r?\n {9}\}\r?\n/;
const popupEmailCheckMailSentPattern =
  / {15}if\(DollarsGame\.getProfile\(\)\.checkmail == CheckConfirmEmail\.MAIL_UNCHECKED\)\r?\n {15}\{\r?\n {18}DollarsGame\.getProfile\(\)\.checkmail = CheckConfirmEmail\.MAIL_CHECKING;\r?\n {15}\}\r?\n {15}break;\r?\n/;
const popupEmailCheckMailSentSnippet = `               if(DollarsGame.getProfile().checkmail == CheckConfirmEmail.MAIL_UNCHECKED)
               {
                  DollarsGame.getProfile().checkmail = CheckConfirmEmail.MAIL_CHECKING;
               }
               CheckConfirmEmail.getInstance().load();
               break;
`;
const customizerCrossPromotionInitializerPattern = / {9}this\.mUnlockedCrosspromotions = new Array\(\);\r?\n/;
const friendObjectSetPictureUrlPattern =
  / {6}public function setPictureURL\(param1:String\) : void\r?\n {6}\{\r?\n {9}this\.mUrl = param1;\r?\n {6}\}\r?\n/;
const friendObjectSetPictureUrlSnippet = `      public function setPictureURL(param1:String) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:LoaderContext = null;
         if(this.mUrl == param1)
         {
            return;
         }
         this.mUrl = param1;
         if(this.mLoader != null)
         {
            try
            {
               this.mLoader.unload();
            }
            catch(error:Error)
            {
            }
            if(this.mUrl != null)
            {
               _loc2_ = new URLRequest(this.mUrl);
               _loc3_ = new LoaderContext();
               this.mLoader.load(_loc2_,_loc3_);
            }
         }
      }
`;

fs.mkdirSync(clientDir, { recursive: true });
fs.copyFileSync(config.sourceClientSwfPath, config.privateClientSwfPath);
patchPrivateClientSwf();

const manifestPath = path.join(clientDir, "client-build.json");
fs.writeFileSync(
  manifestPath,
  JSON.stringify(
    {
      source: config.sourceClientSwfPath,
      output: config.privateClientSwfPath,
      preparedAt: new Date().toISOString(),
      notes: [
        "Private client copy isolated from the recovered archive.",
        "Runtime compatibility provided by the local launcher and HTTPS Facebook shim.",
        "Dollars patched to enable the original SWF debug mode when the launcher passes debugMode=1.",
        "PopupGold patched to complete Add Gold purchases without enabling the Facebook Credits HUD.",
        "PopupEmail patched to complete local VIP Club confirmation immediately after a valid email is accepted.",
        "CustomizerManager patched to treat archived cross-promotion app unlocks as completed locally.",
        "FriendObject patched to reload an already-loaded NPC portrait after advisor selection changes it."
      ]
    },
    null,
    2
  )
);

console.log(`[mcity] Prepared private client copy at ${config.privateClientSwfPath}`);

function patchPrivateClientSwf(): void {
  ensureFfdecInstalled();
  writePatchedDollarsSource();
  replaceClassInPrivateClient(
    "Dollars",
    dollarsPatchedSourcePath,
    "Failed to patch Dollars in the private client SWF."
  );
  writePatchedPopupGoldSource();
  replaceClassInPrivateClient(
    "com.dchoc.dollars.GUI.PopupGold",
    popupGoldPatchedSourcePath,
    "Failed to patch PopupGold in the private client SWF."
  );
  writePatchedPopupEmailSource();
  replaceClassInPrivateClient(
    "com.dchoc.dollars.GUI.PopupEmail",
    popupEmailPatchedSourcePath,
    "Failed to patch PopupEmail in the private client SWF."
  );
  writePatchedCustomizerManagerSource();
  replaceClassInPrivateClient(
    "com.dchoc.dollars.utils.metrics.CustomizerManager",
    customizerManagerPatchedSourcePath,
    "Failed to patch CustomizerManager in the private client SWF."
  );
  writePatchedFriendObjectSource();
  replaceClassInPrivateClient(
    "com.dchoc.dollars.friends.FriendObject",
    friendObjectPatchedSourcePath,
    "Failed to patch FriendObject in the private client SWF."
  );
}

function replaceClassInPrivateClient(className: string, patchedSourcePath: string, errorMessage: string): void {
  const temporaryOutputPath = path.join(clientDir, "Dollars.private.tmp.swf");
  if (fs.existsSync(temporaryOutputPath)) {
    fs.rmSync(temporaryOutputPath, { force: true });
  }

  runProcess(
    "java",
    [
      "-jar",
      ffdecJarPath,
      "-replace",
      config.privateClientSwfPath,
      temporaryOutputPath,
      className,
      patchedSourcePath
    ],
    errorMessage
  );
  fs.copyFileSync(temporaryOutputPath, config.privateClientSwfPath);
  fs.rmSync(temporaryOutputPath, { force: true });
}

function writePatchedDollarsSource(): void {
  const source = fs.readFileSync(dollarsSourcePath, "utf8");
  if (!dollarsLoaderInfoPattern.test(source)) {
    throw new Error("Could not find the expected Dollars loaderInfo parameters line in the client patch source.");
  }

  const patchedSource = source.replace(dollarsLoaderInfoPattern, dollarsLoaderInfoSnippet);
  fs.mkdirSync(path.dirname(dollarsPatchedSourcePath), { recursive: true });
  fs.writeFileSync(dollarsPatchedSourcePath, patchedSource);
}

function writePatchedPopupGoldSource(): void {
  const source = fs.readFileSync(popupGoldSourcePath, "utf8");
  if (!popupGoldPurchaseBranchPattern.test(source)) {
    throw new Error("Could not find the expected PopupGold purchase branch in the client patch source.");
  }

  const patchedSource = source.replace(popupGoldPurchaseBranchPattern, popupGoldPatchedSnippet);
  fs.mkdirSync(path.dirname(popupGoldPatchedSourcePath), { recursive: true });
  fs.writeFileSync(popupGoldPatchedSourcePath, patchedSource);
}

function writePatchedPopupEmailSource(): void {
  const source = fs.readFileSync(popupEmailSourcePath, "utf8");
  if (!popupEmailCheckMailSentPattern.test(source)) {
    throw new Error("Could not find the expected PopupEmail successful mail branch in the client patch source.");
  }

  const patchedSource = source.replace(popupEmailCheckMailSentPattern, popupEmailCheckMailSentSnippet);
  fs.mkdirSync(path.dirname(popupEmailPatchedSourcePath), { recursive: true });
  fs.writeFileSync(popupEmailPatchedSourcePath, patchedSource);
}

function writePatchedCustomizerManagerSource(): void {
  const source = fs.readFileSync(customizerManagerSourcePath, "utf8");
  if (!customizerCrossPromotionInitializerPattern.test(source)) {
    throw new Error("Could not find the expected CustomizerManager cross-promotion initializer in the client patch source.");
  }

  const crossPromotionIds = loadCrossPromotionIds();
  const unlockSnippet = [
    "          this.mUnlockedCrosspromotions = new Array();",
    ...crossPromotionIds.map((sku) => `          this.mUnlockedCrosspromotions.push(${sku});`)
  ].join("\n") + "\n";

  const patchedSource = source.replace(customizerCrossPromotionInitializerPattern, unlockSnippet);
  fs.mkdirSync(path.dirname(customizerManagerPatchedSourcePath), { recursive: true });
  fs.writeFileSync(customizerManagerPatchedSourcePath, patchedSource);
}

function writePatchedFriendObjectSource(): void {
  const source = fs.readFileSync(friendObjectSourcePath, "utf8");
  if (!friendObjectSetPictureUrlPattern.test(source)) {
    throw new Error("Could not find the expected FriendObject setPictureURL method in the client patch source.");
  }

  const patchedSource = source.replace(friendObjectSetPictureUrlPattern, friendObjectSetPictureUrlSnippet);
  fs.mkdirSync(path.dirname(friendObjectPatchedSourcePath), { recursive: true });
  fs.writeFileSync(friendObjectPatchedSourcePath, patchedSource);
}

function loadCrossPromotionIds(): number[] {
  const xml = fs.readFileSync(crossPromotionDefinitionsPath, "utf8");
  const ids: number[] = [];
  for (const match of xml.matchAll(/<Definition\s+sku="([^"]+)"/g)) {
    const sku = Number(match[1] ?? "0");
    if (Number.isInteger(sku) && sku > 0) {
      ids.push(sku);
    }
  }

  if (ids.length === 0) {
    throw new Error(`No cross-promotion definitions found in ${crossPromotionDefinitionsPath}.`);
  }

  return ids;
}

function ensureFfdecInstalled(): void {
  if (fs.existsSync(ffdecJarPath)) {
    return;
  }

  fs.mkdirSync(ffdecDir, { recursive: true });
  runProcess(
    "powershell",
    [
      "-NoProfile",
      "-Command",
      [
        "$ErrorActionPreference='Stop'",
        "$ProgressPreference='SilentlyContinue'",
        `Invoke-WebRequest -Uri '${FFDEC_ARCHIVE_URL}' -OutFile '${ffdecZipPath}'`,
        `Expand-Archive -LiteralPath '${ffdecZipPath}' -DestinationPath '${ffdecDir}' -Force`
      ].join("; ")
    ],
    "Failed to download or extract FFDec."
  );

  if (!fs.existsSync(ffdecJarPath)) {
    throw new Error(`FFDec was installed, but ${ffdecJarPath} was not found.`);
  }
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
