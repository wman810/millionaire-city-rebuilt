import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { inflateSync } from "node:zlib";
import { afterAll, afterEach, beforeAll, describe, expect, test } from "vitest";
import { GAME_VERSION, ORIGINAL_GAME_VERSION, STARTUP_COMMANDS, isGameVariant } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";

type ConfigModule = typeof import("../src/config.js");
type ServerAppModule = typeof import("../src/serverApp.js");
type ServerApp = ReturnType<ServerAppModule["createServerApp"]>;

const previousVariant = process.env.MCITY_GAME_VARIANT;
const activeApps: ServerApp[] = [];
let getServerConfig: ConfigModule["getServerConfig"];
let createServerApp: ServerAppModule["createServerApp"];

beforeAll(async () => {
  process.env.MCITY_GAME_VARIANT = "original";
  ({ getServerConfig } = await import("../src/config.js"));
  ({ createServerApp } = await import("../src/serverApp.js"));
});

afterAll(() => {
  if (previousVariant == null) {
    delete process.env.MCITY_GAME_VARIANT;
  } else {
    process.env.MCITY_GAME_VARIANT = previousVariant;
  }
});

afterEach(async () => {
  while (activeApps.length > 0) {
    await activeApps.pop()?.stop();
  }
});

describe("game variants", () => {
  test("maps the current and original clients to separate runtimes and saves", () => {
    const current = getServerConfig("current");
    const original = getServerConfig("original");

    expect(current.gameVersion).toBe(GAME_VERSION);
    expect(original.gameVersion).toBe(ORIGINAL_GAME_VERSION);
    expect(current.assetRoute).toBe("/mcity/0.501");
    expect(original.assetRoute).toBe("/mcity/0.338");
    expect(original.sourceClientSwfPath).not.toBe(current.sourceClientSwfPath);
    expect(original.privateClientSwfPath).not.toBe(current.privateClientSwfPath);

    if (!process.env.MCITY_DB_PATH) {
      expect(original.dbPath).not.toBe(current.dbPath);
      expect(original.dbPath).toContain(path.join("generated", "data", "original"));
    }

    expect(isGameVariant("current")).toBe(true);
    expect(isGameVariant("original")).toBe(true);
    expect(isGameVariant("toString")).toBe(false);
    expect(() => createServerApp(current)).toThrow(/process is configured for original/);
  });

  test("boots the original 0.338 launcher, runtime, protocol commands, and economy", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-original-variant-"));
    const config = {
      ...getServerConfig("original"),
      dbPath: path.join(tempDir, "original.sqlite"),
      httpPort: 0,
      httpsPort: 0,
      useHttpsFacebookShim: false
    };
    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const { RULES_ROOT } = await import("../src/saveDefaults/paths.js");
    expect(RULES_ROOT).toBe(path.join(config.dataRoot, "rules"));

    const launcherResponse = await fetch(`http://127.0.0.1:${config.httpPort}/launcher`);
    expect(launcherResponse.status).toBe(200);
    const launcherHtml = await launcherResponse.text();
    expect(launcherHtml).toContain("game_version=0.338");
    expect(launcherHtml).toContain("xml_version=0.338");
    expect(launcherHtml).toContain("usr_level=1");
    expect(launcherHtml).toContain("/client/0.338/Dollars.private.swf");
    expect(launcherHtml).toContain("%2Fmcity%2F0.338%2FDatas%2F");
    expect(launcherHtml).toContain("/mcity/0.501/Datas/tabs/social_wall/general/logo.png");

    const swfResponse = await fetch(
      `http://127.0.0.1:${config.httpPort}/client/0.338/Dollars.private.swf`
    );
    expect(swfResponse.status).toBe(200);
    expect((await swfResponse.arrayBuffer()).byteLength).toBeGreaterThan(1_000_000);

    const settingsResponse = await fetch(
      `http://127.0.0.1:${config.httpPort}/mcity/0.338/Datas/rules/settings.xml`
    );
    expect(settingsResponse.status).toBe(200);
    expect(await settingsResponse.text()).toContain('initialDCCoins="200000"');

    const wrapperAssetResponse = await fetch(
      `http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/tabs/social_wall/general/logo.png`
    );
    expect(wrapperAssetResponse.status).toBe(200);

    const excludedSocialSample = await fetch(
      `http://127.0.0.1:${config.httpPort}/mcity/0.338/Datas/userData/friendsList.xml`
    );
    expect(excludedSocialSample.status).toBe(404);

    const resourcesResponse = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources`);
    expect(resourcesResponse.status).toBe(200);
    expect(await resourcesResponse.json()).toMatchObject({
      money: 200000,
      gold: 2,
      xp: 0,
      companyValue: 660000
    });

    for (const commandName of STARTUP_COMMANDS) {
      expect(() =>
        serverApp.commands.handleCommand(1, {
          _cmd: commandName,
          _dat: commandName === "get_world" ? { targetUserId: 1 } : {}
        })
      ).not.toThrow();
    }

    const helpResponse = serverApp.commands.handleCommand(1, {
      _cmd: "help_accelerate",
      _dat: { sid: "1" }
    });
    expect(helpResponse[0]._dat as JsonObject).toMatchObject({
      help_id: "null",
      time_passed: "0",
      time_total: "0",
      unavailableOffline: "1"
    });
  });

  test("imports only the curated original runtime files", () => {
    const dataRoot = getServerConfig("original").dataRoot;
    const userDataFiles = fs
      .readdirSync(path.join(dataRoot, "userData"))
      .sort();

    expect(userDataFiles).toEqual([
      "universeAdvisorCity.xml",
      "universeAdvisorCity1_AbuDabhi.xml"
    ]);
    expect(fs.existsSync(path.join(dataRoot, "Assets", "GUI", "collectables.swf"))).toBe(true);
    expect(fs.existsSync(path.join(dataRoot, "Assets", "GUI", "Storage.swf"))).toBe(true);

    const clientSwf = fs.readFileSync(path.join(dataRoot, "Dollars.swf"));
    expect(clientSwf.subarray(0, 3).toString("ascii")).toBe("CWS");
    const uncompressedClient = inflateSync(clientSwf.subarray(8)).toString("latin1");
    expect(uncompressedClient).not.toMatch(/\/Users\/|[A-Za-z]:\\Users\\/);
    const rootTagCodes = readCompressedSwfRootTagCodes(clientSwf);
    expect(rootTagCodes).not.toContain(63); // DebugID
    expect(rootTagCodes).not.toContain(64); // EnableDebugger2

    const disallowedExtensions = new Set([".as", ".css", ".fla", ".html", ".js", ".old", ".psd", ".xls"]);
    const pending = [dataRoot];
    while (pending.length > 0) {
      const directory = pending.pop();
      if (!directory) {
        continue;
      }
      for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
        const entryPath = path.join(directory, entry.name);
        if (entry.isDirectory()) {
          pending.push(entryPath);
        } else {
          expect(disallowedExtensions.has(path.extname(entry.name).toLowerCase()), entryPath).toBe(false);
        }
      }
    }
  });

  test("keeps original-client compatibility patches on the 0.338 APIs", () => {
    const patchRoot = path.join(getServerConfig("original").workspaceRoot, "client-patch-sources", "0.338");
    const dollarsPatch = fs.readFileSync(path.join(patchRoot, "Dollars.as"), "utf8");
    const popupGoldPatch = fs.readFileSync(
      path.join(patchRoot, "scripts", "com", "dchoc", "dollars", "GUI", "PopupGold.as"),
      "utf8"
    );
    const friendsBarPatch = fs.readFileSync(
      path.join(
        patchRoot,
        "scripts",
        "com",
        "dchoc",
        "dollars",
        "friends",
        "FriendsBarContentFriend.as"
      ),
      "utf8"
    );
    const serverPatch = fs.readFileSync(
      path.join(patchRoot, "scripts", "com", "dchoc", "dollars", "server", "Server.as"),
      "utf8"
    );

    expect(dollarsPatch).toContain('flashVars["debugMode"] == "1"');
    expect(dollarsPatch).toContain('flashVars["climateMode"] == "1"');
    expect(popupGoldPatch).toContain('updateMoney("buyGold",{"sku":String(fbObject.sku)})');
    expect(friendsBarPatch).toContain("if(loader != this.mImageLoader)");
    expect(friendsBarPatch).toContain("loader.close()");
    expect(serverPatch).toContain("getCompanyMine().synchronizeDataWithProfile()");
    expect(serverPatch).toContain('tokens[0] == "localStatsUpdate"');
    expect(serverPatch).toContain('task == "localProfileUpdate"');
  });

});

function readCompressedSwfRootTagCodes(clientSwf: Buffer): number[] {
  const body = inflateSync(clientSwf.subarray(8));
  const rectangleBitCount = 5 + (body[0] >> 3) * 4;
  let offset = Math.ceil(rectangleBitCount / 8) + 4;
  const tagCodes: number[] = [];

  while (offset + 2 <= body.length) {
    const header = body.readUInt16LE(offset);
    offset += 2;
    const tagCode = header >> 6;
    let tagLength = header & 0x3f;
    if (tagLength === 0x3f) {
      if (offset + 4 > body.length) {
        throw new Error("Truncated long SWF tag header");
      }
      tagLength = body.readUInt32LE(offset);
      offset += 4;
    }
    if (offset + tagLength > body.length) {
      throw new Error("Truncated SWF tag body");
    }

    tagCodes.push(tagCode);
    offset += tagLength;
    if (tagCode === 0) {
      return tagCodes;
    }
  }

  throw new Error("SWF root timeline has no End tag");
}
