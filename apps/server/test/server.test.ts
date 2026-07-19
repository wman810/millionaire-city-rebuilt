import crypto from "node:crypto";
import fs from "node:fs";
import net from "node:net";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, test } from "vitest";
import type { PacketCommand } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createServerApp as createServerAppBase } from "../src/serverApp.js";
import { getServerConfig, type ServerConfig } from "../src/config.js";
import { renderLauncherHtml } from "../src/launcherHtml.js";
import { createEmptyCollectiblesDocument, normalizeCompletedTutorialUniverse } from "../src/saveDefaults.js";
import { RONALD_LAYOUT_ITEMS, RONALD_PLOTS_TYPE } from "../src/saveDefaults/ronaldLayout.js";
import { createStarterDecorationItems } from "../src/saveDefaults/starterDecorations.js";
import { loadCashToCoins } from "../src/rules.js";

const activeApps: Array<ReturnType<typeof createServerApp>> = [];
const HOUSE_COLLECTIBLE_DROP_DIVISOR = 8;
const EXPECTED_STARTER_DECORATION_SKUS = createStarterDecorationItems("1").map((entry) => String(entry.sku));
const EXPECTED_STARTER_DECORATION_VALUE = 299_000;
const archivedAssetTest = hasArchivedAssetFiles() ? test : test.skip;

function createServerApp(config: ServerConfig): ReturnType<typeof createServerAppBase> {
  config.httpPort = 0;
  config.httpsPort = 0;
  if (config.useHttpsFacebookShim) {
    config.facebookHttpsPort = 0;
  }
  return createServerAppBase(config);
}

function hasArchivedAssetFiles(): boolean {
  const config = getServerConfig();
  const requiredFiles = [
    path.join(config.assetRoot, "Datas", "rules", "itemDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "rules", "commerceDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "rules", "decorationDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "rules", "wonderDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "rules", "missionDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "rules", "XPTable.xml"),
    path.join(config.assetRoot, "Datas", "rules", "fbcredits.xml"),
    path.join(config.assetRoot, "Datas", "rules", "collectiblesDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "rules", "collectiblesGroupsDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "rules", "collectiblesRewardDefinitions.xml"),
    path.join(config.assetRoot, "Datas", "feed", "new_feed_upgrades_0.jpg"),
    path.join(config.assetRoot, "Datas", "Assets", "items", "CommerceTypes", "icons", "commerce_bank.png")
  ];

  return requiredFiles.every((filePath) => fs.existsSync(filePath));
}

function stableTestHash(value: string): number {
  let hash = 17;
  for (let index = 0; index < value.length; index += 1) {
    hash = (hash * 31 + value.charCodeAt(index)) | 0;
  }
  return hash;
}

function findCollectibleSavedAt(sid: string, sku: string, contractSku: string, shouldAward: boolean): string {
  for (let offset = 0; offset < 2048; offset += 1) {
    const savedAt = String(1_700_000_000_000 + offset);
    const roll = Math.abs(stableTestHash(`${sid}:${sku}:${contractSku}:${savedAt}`));
    if ((roll % HOUSE_COLLECTIBLE_DROP_DIVISOR === 0) === shouldAward) {
      return savedAt;
    }
  }

  throw new Error(`Unable to find collectible test seed for ${sid}/${sku}/${contractSku}`);
}

afterEach(async () => {
  while (activeApps.length > 0) {
    const app = activeApps.pop();
    if (app) {
      await app.stop();
    }
  }
});

describe("Millionaire City server", () => {
  test("migrates compatible older save schemas without resetting player data", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-schema-migration-"));
    const dbPath = path.join(tempDir, "save.sqlite");
    const config = {
      ...getServerConfig(),
      dbPath,
      useHttpsFacebookShim: false
    };

    const firstApp = createServerApp(config);
    activeApps.push(firstApp);
    const universe = firstApp.repository.getDocument<JsonObject>(1, "universe");
    const profile = (universe.universe as JsonObject[]).find((entry) => Array.isArray(entry.Profile));
    expect(profile).toBeTruthy();
    if (profile) {
      profile.userName = "Preserved Mayor";
    }
    firstApp.repository.setDocument(1, "universe", universe);
    firstApp.repository.setMeta("save_schema_version", "7");
    await firstApp.stop();
    activeApps.pop();

    const restartedApp = createServerApp({ ...config });
    activeApps.push(restartedApp);
    const migratedUniverse = restartedApp.repository.getDocument<JsonObject>(1, "universe");
    const migratedProfile = (migratedUniverse.universe as JsonObject[]).find((entry) => Array.isArray(entry.Profile));
    expect(migratedProfile?.userName).toBe("Preserved Mayor");
    expect(restartedApp.repository.getMeta("save_schema_version")).toBe("8");
  });

  test("rolls back the HTTP listener when HTTPS startup fails", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-startup-rollback-"));
    const blocker = net.createServer();
    await new Promise<void>((resolve, reject) => {
      blocker.once("error", reject);
      blocker.listen(0, "127.0.0.1", () => resolve());
    });
    const address = blocker.address();
    expect(address && typeof address === "object").toBe(true);
    const blockedPort = address && typeof address === "object" ? address.port : 0;
    const serverApp = createServerAppBase({
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      httpPort: 0,
      httpsPort: blockedPort,
      useHttpsFacebookShim: false
    });
    activeApps.push(serverApp);

    try {
      await expect(serverApp.start()).rejects.toMatchObject({ code: "EADDRINUSE" });
      expect(serverApp.httpServer).toBeUndefined();
      expect(serverApp.httpsServer).toBeUndefined();
    } finally {
      await new Promise<void>((resolve) => blocker.close(() => resolve()));
    }
  });

  test("binds the Facebook shim only to the loopback interface", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-fbshim-bind-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: true
    };
    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const address = serverApp.facebookShim?.server.address();
    expect(address && typeof address === "object" ? address.address : undefined).toBe("127.0.0.1");
  });

  test("returns logOK and startup documents", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-login-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const loginCommands = extractCommands(loginPayload);
    expect(loginCommands[0]._cmd).toBe("logOK");
    expect(loginCommands[0]._dat.userExtId).toBe(config.launcherUserId);
    expect(loginCommands[0]._dat.advisorId).toBe("100,101");

    const token = String(loginCommands[0]._dat.token);
    const startupData = JSON.stringify({
      _cmdList: [
        { _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 },
        { _cmd: "get_game_config", _dat: {}, _cnt: 2 }
      ],
      _msgCount: 0,
      _sync: 1
    });

    const signature = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: startupData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );

    const startupPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: startupData,
      flash_version: "WIN 32,0,0,0",
      sig: signature
    });

    const startupCommands = extractCommands(startupPayload);
    expect(startupCommands.map((entry) => entry._cmd)).toEqual(["get_world", "get_game_config"]);
    expect(startupCommands[0]._dat.universe).toBeTruthy();
    const universeRoot = startupCommands[0]._dat.universe as Array<Record<string, unknown>>;
    const worldContainer = universeRoot.find((entry) => Array.isArray(entry.World)) as
      | { World: Array<Record<string, unknown>> }
      | undefined;
    const profileContainer = universeRoot.find((entry) => Array.isArray(entry.Profile)) as
      | { Profile: Array<Record<string, unknown>> }
      | undefined;
    expect(worldContainer).toBeTruthy();
    expect(profileContainer).toBeTruthy();
    const companies = worldContainer?.World.filter((entry) => Array.isArray(entry.Company)) ?? [];
    expect(companies).toHaveLength(2);
    expect(companies.map((entry) => entry.whose)).toEqual(["0", "1"]);
    const mineCompany = companies.find((entry) => entry.whose === "0");
    const mineItems = mineCompany?.Company.filter((entry) => Array.isArray(entry.Item)) ?? [];
    const plots = profileContainer?.Profile.find((entry) => Array.isArray(entry.Plots)) as
      | { type: string }
      | undefined;
    expect(plots?.type).toBe("");
    expect(profileContainer?.tutorialEnd).toBe("0");
    expect(profileContainer?.bossGenre).toBe("0");
    expect(profileContainer?.exp).toBe("0");
    expect(profileContainer?.DCCoins).toBe("380000");
    expect(profileContainer?.DCCash).toBe("0");
    expect(profileContainer?.companyValue).toBe("720000");
    expect(mineCompany?.DCCoins).toBe("380000");
    const rivalCompany = companies.find((entry) => entry.whose === "1");
    const rivalItems = rivalCompany?.Company.filter((entry) => Array.isArray(entry.Item)) ?? [];
    expect(rivalItems.map((entry) => entry.sku)).toEqual([
      "commerce_pizza",
      "houses_002_001",
      "houses_002_002",
      "houses_001_002"
    ]);
    expect(mineItems.map((entry) => entry.sku)).toEqual(EXPECTED_STARTER_DECORATION_SKUS);
    expect(mineItems.every((entry) => entry.Item.some((state: { id?: string }) => state.id === "5"))).toBe(true);
    expect(rivalItems.every((entry) => entry.Item.some((state: { id?: string }) => state.id === "3"))).toBe(true);
    const mapContainer = worldContainer?.World.find((entry) => Array.isArray(entry.Map)) as
      | { Map: Array<Record<string, unknown>> }
      | undefined;
    const terrainChunk = mapContainer?.Map.find((entry) => Array.isArray(entry.Terrain)) as
      | { chunk?: string }
      | undefined;
    const roadChunk = mapContainer?.Map.find((entry) => Array.isArray(entry.Road)) as
      | { chunk?: string }
      | undefined;
    const terrainTiles = new Set(String(terrainChunk?.chunk ?? "").split(",").filter(Boolean));
    const roadTiles = new Set(String(roadChunk?.chunk ?? "").split(",").filter(Boolean));
    expect(terrainTiles.size).toBe(41);
    expect([...terrainTiles].filter((tile) => roadTiles.has(tile))).toEqual([]);
    expect(["0:1", "1:1", "0:2", "1:2", "0:3", "1:3"].filter((tile) => terrainTiles.has(tile))).toEqual([]);
    expect(terrainTiles.has("10:-2")).toBe(false);
    expect(380_000 + EXPECTED_STARTER_DECORATION_VALUE + terrainTiles.size * 1_000).toBe(720_000);
    expect(terrainTiles.has("-1:-3")).toBe(true);
    expect(terrainTiles.has("2:-1")).toBe(true);
    expect(terrainTiles.has("-7:-2")).toBe(true);
    expect(terrainTiles.has("-13:1")).toBe(true);
    expect(terrainTiles.has("-12:2")).toBe(true);
    expect(terrainTiles.has("-4:1")).toBe(true);
    expect(terrainTiles.has("-2:3")).toBe(true);
    expect(terrainTiles.has("9:-3")).toBe(true);
    expect(terrainTiles.has("11:-1")).toBe(true);
    expect(terrainTiles.has("4:2")).toBe(true);
    expect(terrainTiles.has("4:3")).toBe(true);
    expect(roadTiles.has("-7:0")).toBe(true);
    expect(roadTiles.has("11:0")).toBe(true);
    expect(roadTiles.has("-1:4")).toBe(true);
    expect(roadTiles.has("2:4")).toBe(true);
    expect(startupCommands[1]._dat.gameConfig).toEqual([]);
    expect(startupCommands[1]._dat.music).toBe("1");
    expect(startupCommands[1]._dat.sound).toBe("1");
  });

  test("returns distinct NPC neighbor worlds for the advisor city and Sheik city", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-npc-worlds-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);
    const universeAfterLogin = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const worldAfterLogin = (universeAfterLogin.universe as Array<Record<string, unknown>>).find((entry) =>
      Array.isArray(entry.World)
    ) as { World: Array<Record<string, unknown>> };
    const mineAfterLogin = worldAfterLogin.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>> };
    const houseAfterLogin = mineAfterLogin.Company.find((entry: { sid?: string }) => entry.sid === "9020") as
      | { Item?: Array<Record<string, unknown>> }
      | undefined;
    const stateAfterLogin = houseAfterLogin?.Item?.find((entry) => Array.isArray(entry.State)) as
      | Record<string, unknown>
      | undefined;
    if (stateAfterLogin) {
      stateAfterLogin.savedAt = savedAt;
    }
    serverApp.repository.setDocument(1, "universe", universeAfterLogin);
    const playerUniverse = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const playerProfile = (playerUniverse.universe as Array<Record<string, unknown>>).find((entry) => Array.isArray(entry.Profile)) as
      | Record<string, unknown>
      | undefined;
    if (playerProfile) {
      playerProfile.bossGenre = "1";
      playerProfile.tutorialEnd = "1";
      serverApp.repository.setDocument(1, "universe", playerUniverse);
    }
    serverApp.database.db
      .prepare("INSERT INTO users (id, ext_id, name, created_at) VALUES (?, ?, ?, ?)")
      .run(101, "stale-npc-sheik", "Stale Sheik", new Date().toISOString());
    serverApp.repository.setDocument(101, "universe", {
      universe: [
        { Profile: [], cityname: "Stale Local Override" },
        { World: [] }
      ]
    });

    const startupData = JSON.stringify({
      _cmdList: [
        { _cmd: "get_world", _dat: { targetUserId: 100 }, _cnt: 1 },
        { _cmd: "get_world", _dat: { targetUserId: 101 }, _cnt: 2 }
      ],
      _msgCount: 0,
      _sync: 1
    });

    const signature = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: startupData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );

    const startupPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: startupData,
      flash_version: "WIN 32,0,0,0",
      sig: signature
    });

    const startupCommands = extractCommands(startupPayload);
    const advisorUniverse = startupCommands[0]._dat.universe as Array<Record<string, unknown>>;
    const sheikUniverse = startupCommands[1]._dat.universe as Array<Record<string, unknown>>;
    const advisorProfile = advisorUniverse.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    const sheikProfile = sheikUniverse.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    const advisorWorld = advisorUniverse.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
    const sheikWorld = sheikUniverse.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
    const advisorMine = advisorWorld.World.find((entry) => Array.isArray(entry.Company) && entry.whose === "0") as
      | { Company: Array<Record<string, unknown>> }
      | undefined;
    const sheikMine = sheikWorld.World.find((entry) => Array.isArray(entry.Company) && entry.whose === "0") as
      | { Company: Array<Record<string, unknown>> }
      | undefined;
    const sheikPlots = sheikProfile.Profile.find((entry) => Array.isArray((entry as { Plots?: unknown }).Plots)) as
      | { type?: string }
      | undefined;
    const advisorPlots = advisorProfile.Profile.find((entry) => Array.isArray((entry as { Plots?: unknown }).Plots)) as
      | { type?: string }
      | undefined;
    const advisorHq = advisorMine?.Company.find((entry) => entry.sku === "HeadQuarter");
    const sheikHq = sheikMine?.Company.find((entry) => entry.sku === "HeadQuarter");
    const advisorRoadTiles = extractRoadTiles(advisorWorld);
    const sheikRoadTiles = extractRoadTiles(sheikWorld);

    expect(advisorProfile.userName).toBe("Cindy");
    expect(advisorProfile.cityname).toBe("Chocolate Fields");
    expect(advisorProfile.planeSku).toBe("plane_03");
    expect(sheikProfile.cityname).toBe("Sheik&apos;s City");
    expect(advisorHq?.x).toBe("-1");
    expect(advisorHq?.y).toBe("-4");
    expect(sheikHq?.x).toBe("-1");
    expect(sheikHq?.y).toBe("-3");
    expect(advisorMine?.Company).toHaveLength(RONALD_LAYOUT_ITEMS.length);
    expect(sheikMine?.Company).toHaveLength(483);
    expect(advisorPlots?.type).toBe(RONALD_PLOTS_TYPE);
    expect(sheikPlots?.type).toBe("0,2,2,2,0,1,2,2,2,1,1,2,2,2,1,1,2,2,2,1,0,2,2,2,0");
    expect(advisorMine?.Company.some((entry) => entry.sku === "wonder_npc_Ronald")).toBe(true);
    expect(sheikMine?.Company.some((entry) => entry.sku === "commerce_casino")).toBe(true);
    expect(getItemsOverlappingRoads(advisorMine?.Company ?? [], advisorRoadTiles)).toEqual([]);
    expect(getItemsOverlappingRoads(sheikMine?.Company ?? [], sheikRoadTiles)).toEqual([]);

    if (playerProfile) {
      playerProfile.bossGenre = "0";
      serverApp.repository.setDocument(1, "universe", playerUniverse);
    }

    const ronaldData = JSON.stringify({
      _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 100 }, _cnt: 3 }],
      _msgCount: 0,
      _sync: 1
    });
    const ronaldSignature = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: ronaldData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );
    const ronaldPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: ronaldData,
      flash_version: "WIN 32,0,0,0",
      sig: ronaldSignature
    });

    const ronaldUniverse = extractCommands(ronaldPayload)[0]._dat.universe as Array<Record<string, unknown>>;
    const ronaldProfile = ronaldUniverse.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    const ronaldWorld = ronaldUniverse.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
    const ronaldMine = ronaldWorld.World.find((entry) => Array.isArray(entry.Company) && entry.whose === "0") as
      | { Company: Array<Record<string, unknown>> }
      | undefined;
    const ronaldPlots = ronaldProfile.Profile.find((entry) => Array.isArray((entry as { Plots?: unknown }).Plots)) as
      | { type?: string }
      | undefined;
    const ronaldHq = ronaldMine?.Company.find((entry) => entry.sku === "HeadQuarter");
    const ronaldRoadTiles = extractRoadTiles(ronaldWorld);

    expect(ronaldProfile.userName).toBe("Ronald");
    expect(ronaldProfile.cityname).toBe("Chocolate Fields");
    expect(ronaldProfile.planeSku).toBe("plane_03");
    expect(ronaldHq?.x).toBe("-1");
    expect(ronaldHq?.y).toBe("-4");
    expect(ronaldMine?.Company).toHaveLength(RONALD_LAYOUT_ITEMS.length);
    expect(ronaldPlots?.type).toBe(RONALD_PLOTS_TYPE);
    expect(ronaldMine?.Company.some((entry) => entry.sku === "wonder_npc_Ronald")).toBe(true);
    expect(getItemsOverlappingRoads(ronaldMine?.Company ?? [], ronaldRoadTiles)).toEqual([]);
  });

  test("allows up to five daily visitor upgrades per NPC city and persists upgraded buildings", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-npc-upgrades-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);
    const universeAfterLogin = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const worldAfterLogin = (universeAfterLogin.universe as Array<Record<string, unknown>>).find((entry) =>
      Array.isArray(entry.World)
    ) as { World: Array<Record<string, unknown>> };
    const mineAfterLogin = worldAfterLogin.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>> };
    const houseAfterLogin = mineAfterLogin.Company.find((entry: { sid?: string }) => entry.sid === "9024") as
      | { Item?: Array<Record<string, unknown>> }
      | undefined;
    const stateAfterLogin = houseAfterLogin?.Item?.find((entry) => Array.isArray(entry.State)) as
      | Record<string, unknown>
      | undefined;
    if (stateAfterLogin) {
      stateAfterLogin.savedAt = savedAt;
    }
    serverApp.repository.setDocument(1, "universe", universeAfterLogin);
    const playerUniverse = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const playerProfile = (playerUniverse.universe as Array<Record<string, unknown>>).find((entry) => Array.isArray(entry.Profile)) as
      | Record<string, unknown>
      | undefined;
    if (playerProfile) {
      playerProfile.bossGenre = "1";
      playerProfile.tutorialEnd = "1";
      serverApp.repository.setDocument(1, "universe", playerUniverse);
    }

    const initialUpgradeData = JSON.stringify({
      _cmdList: [{ _cmd: "get_upgrades_list", _dat: { userId: 101 }, _cnt: 1 }],
      _msgCount: 0,
      _sync: 1
    });
    const initialSig = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: initialUpgradeData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );
    const initialPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: initialUpgradeData,
      flash_version: "WIN 32,0,0,0",
      sig: initialSig
    });

    const initialUpgrades = extractCommands(initialPayload)[0]._dat;
    expect(initialUpgrades.upgradesUniverseAvailable).toBe("5");
    expect(initialUpgrades.upgradesList).toEqual([]);

    const mutationData = JSON.stringify({
      _cmdList: [
        { _cmd: "add_upgrade_item", _dat: { visitorId: 1, ownerId: 101, sid: "2001", type: "0" }, _cnt: 1 },
        { _cmd: "add_upgrade_item", _dat: { visitorId: 1, ownerId: 101, sid: "4008", type: "0" }, _cnt: 2 },
        { _cmd: "add_upgrade_item", _dat: { visitorId: 1, ownerId: 101, sid: "4030", type: "0" }, _cnt: 3 },
        { _cmd: "add_upgrade_item", _dat: { visitorId: 1, ownerId: 101, sid: "2001", type: "0" }, _cnt: 4 }
      ],
      _msgCount: 0,
      _sync: 1
    });
    const mutationSig = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );
    await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: mutationData,
      flash_version: "WIN 32,0,0,0",
      sig: mutationSig
    });

    const upgradedPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: initialUpgradeData,
      flash_version: "WIN 32,0,0,0",
      sig: initialSig
    });

    const upgraded = extractCommands(upgradedPayload)[0]._dat;
    expect(upgraded.upgradesUniverseAvailable).toBe("2");
    expect((upgraded.upgradesList as Array<Record<string, unknown>>).map((entry) => entry.sid)).toEqual([
      "2001",
      "4008",
      "4030"
    ]);
    expect((upgraded.upgradesList as Array<Record<string, unknown>>).every((entry) => entry.extId === config.launcherUserId)).toBe(true);
  });

  test("persists save mutations across restarts", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-persist-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_profile",
            _dat: { action: "city_name", value: "Revival City" },
            _cnt: 1
          },
          {
            _cmd: "update_item",
            _dat: { action: "build", sid: "2", sku: "houses_001_002", x: 24, y: 20, state: 1 },
            _cnt: 2
          },
          {
            _cmd: "update_profile",
            _dat: { action: "tutorial_completed" },
            _cnt: 3
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const profile = world[0];
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      expect(profile.cityname).toBe("Revival City");
      expect(
        mineCompany.Company.some((item: { sid?: string }) => item.sid === "2")
      ).toBe(true);
    }
  });

  test("persists tutorial-style new_item payloads with their real coordinates", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-tutorial-persist-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_map",
            _dat: { action: "add", type: "Terrain", x: 5, y: 2 },
            _cnt: 1
          },
          {
            _cmd: "update_map",
            _dat: { action: "add", type: "Terrain", x: 5, y: 3 },
            _cnt: 2
          },
          {
            _cmd: "update_item",
            _dat: {
              action: "new_item",
              sid: "10",
              sku: "HeadQuarter",
              item: {
                Item: [{ State: [], id: "4" }],
                sid: "10",
                csid: "1",
                sku: "HeadQuarter",
                x: "-1",
                y: "-3",
                isSuspended: "0"
              }
            },
            _cnt: 3
          },
          {
            _cmd: "update_item",
            _dat: {
              action: "new_item",
              sid: "11",
              sku: "houses_004_001",
              item: {
                Item: [{ State: [], id: "1", mode: "1", time: "0" }],
                sid: "11",
                csid: "1",
                sku: "houses_004_001",
                x: "5",
                y: "2",
                isSuspended: "0"
              }
            },
            _cnt: 4
          },
          {
            _cmd: "update_profile",
            _dat: { action: "tutorial_completed" },
            _cnt: 5
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const profile = world[0];
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const mineItems = mineCompany.Company.filter((item: Record<string, unknown>) => Array.isArray(item.Item));
      const headQuarter = mineItems.find((item: { sid?: string }) => item.sid === "10");
      const tutorialHouse = mineItems.find((item: { sid?: string }) => item.sid === "11");
      const tutorialHouseState = tutorialHouse?.Item?.find((entry: Record<string, unknown>) => Array.isArray(entry.State)) as
        | Record<string, unknown>
        | undefined;
      const mapContainer = worldContainer.World.find((entry: { Map?: Array<Record<string, unknown>> }) => Array.isArray(entry.Map));
      const terrainChunk = mapContainer.Map.find((entry: { Terrain?: Array<Record<string, unknown>> }) => Array.isArray(entry.Terrain));

      expect(profile.tutorialEnd).toBe("1");
      expect(headQuarter?.sku).toBe("HeadQuarter");
      expect(headQuarter?.x).toBe("-1");
      expect(headQuarter?.y).toBe("-3");
      expect(tutorialHouse?.sku).toBe("houses_004_001");
      expect(tutorialHouse?.x).toBe("5");
      expect(tutorialHouse?.y).toBe("2");
      expect(tutorialHouseState?.id).toBe("1");
      expect(tutorialHouseState?.mode).toBe("1");
      expect(terrainChunk?.chunk).toContain("5:2");
      expect(terrainChunk?.chunk).toContain("5:3");
    }
  });

  test("persists new item placement security gains across restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-item-security-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      profile.tutorialEnd = "1";
      profile.exp = "206";
      profile.DCCash = "116";
      profile.DCCoins = "500000";
      profile.companyValue = "550000";
      serverApp.repository.setDocument(1, "universe", universe);

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);
      const commands: PacketCommand[] = [];
      for (let index = 0; index < 5; index += 1) {
        commands.push({
          _cmd: "update_item",
          _dat: {
            action: "new_item",
            sid: String(7000 + index),
            sku: "decorations_special_65",
            item: {
              Item: [{ State: [], id: "5" }],
              sid: String(7000 + index),
              csid: "1",
              sku: "decorations_special_65",
              x: String(index),
              y: "-1",
              isSuspended: "0"
            },
            security: {
              expGain: 550,
              expNow: 206 + (index + 1) * 550,
              coinsGain: 0,
              coinsNow: 500000,
              cashGain: -2,
              cashNow: 116 - (index + 1) * 2,
              compValueGain: 120000,
              compValueNow: 550000 + (index + 1) * 120000
            }
          },
          _cnt: index + 1
        });
      }
      const mutationData = JSON.stringify({
        _cmdList: commands,
        _msgCount: 0,
        _sync: 1
      });
      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>> };

      expect(profile.exp).toBe("2956");
      expect(profile.DCCash).toBe("106");
      expect(profile.companyValue).toBe("1150000");
      expect(mineCompany.Company.filter((item) => item.sku === "decorations_special_65")).toHaveLength(5);
    }
  });

  test("preserves item sku when update payload sends a blank embedded sku", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-blank-sku-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };
    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const mutationData = JSON.stringify({
      _cmdList: [
        {
          _cmd: "update_item",
          _dat: {
            action: "new_item",
            sid: "5090",
            sku: "decorations_tree_01",
            item: {
              Item: [{ State: [], id: "5" }],
              sid: "5090",
              csid: "1",
              sku: "decorations_tree_01",
              x: "12",
              y: "6",
              isSuspended: "0"
            }
          },
          _cnt: 1
        },
        {
          _cmd: "update_item",
          _dat: {
            action: "move",
            sid: "5090",
            item: {
              Item: [{ State: [], id: "5" }],
              sid: "5090",
              csid: "1",
              sku: "",
              x: "14",
              y: "9",
              isSuspended: "0"
            }
          },
          _cnt: 2
        }
      ],
      _msgCount: 0,
      _sync: 1
    });

    await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: mutationData,
      flash_version: "WIN 32,0,0,0",
      sig: signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      )
    });

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const root = universe.universe as Array<Record<string, unknown>>;
    const worldContainer = root.find((entry) => Array.isArray(entry.World)) as
      | { World: Array<Record<string, unknown>> }
      | undefined;
    const mineCompany = worldContainer?.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>> } | undefined;
    const decoration = mineCompany?.Company.find((item: { sid?: string }) => item.sid === "5090");

    expect(decoration?.sku).toBe("decorations_tree_01");
    expect(decoration?.x).toBe("14");
    expect(decoration?.y).toBe("9");
  });

  test("persists rented house contract state across restarts", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-contract-persist-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_profile",
            _dat: { action: "tutorial_completed" },
            _cnt: 1
          },
          {
            _cmd: "update_item",
            _dat: {
              action: "new_item",
              sid: "3001",
              sku: "houses_001_002",
              item: {
                Item: [{ State: [], id: "1", mode: "1", time: "0" }],
                sid: "3001",
                csid: "1",
                sku: "houses_001_002",
                x: "8",
                y: "6",
                isSuspended: "0"
              }
            },
            _cnt: 2
          },
          {
            _cmd: "update_item",
            _dat: {
              action: "new_mode",
              sid: "3001",
              mode: 4,
              time: 28800000,
              contractSku: 5
            },
            _cnt: 3
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const rentedHouse = mineCompany.Company.find((item: { sid?: string }) => item.sid === "3001") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = rentedHouse?.Item?.find((entry) => Array.isArray(entry.State)) as
        | Record<string, unknown>
        | undefined;

      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("4");
      expect(Number(state?.time)).toBeGreaterThan(28_700_000);
      expect(Number(state?.time)).toBeLessThanOrEqual(28_800_000);
      expect(state?.contractSku).toBe("5");
      expect(Number(state?.savedAt)).toBeGreaterThan(0);
    }
  });

  test("does not resurrect collected house rent after restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-rent-collected-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      profile.level = "6";
      mineCompany.Company.push({
        Item: [
          {
            State: [],
            id: "1",
            mode: "5",
            time: "0",
            contractSku: "1",
            savedAt: String(Date.now() - 10_000)
          }
        ],
        sid: "3011",
        csid: String(mineCompany.sid ?? "1"),
        sku: "houses_001_001",
        x: "8",
        y: "6",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_item",
            _dat: {
              action: "new_mode",
              sid: "3011",
              mode: 1,
              time: 0,
              contractSku: 1
            },
            _cnt: 1
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const collectedHouse = mineCompany.Company.find((item: { sid?: string }) => item.sid === "3011") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = collectedHouse?.Item?.find((entry) => Array.isArray(entry.State)) as
        | Record<string, unknown>
        | undefined;

      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("1");
      expect(state?.time).toBe("0");
      expect(state?.contractSku).toBeUndefined();
      expect(state?.savedAt).toBeUndefined();
    }
  });

  test("persists the original late-collection countdown when a house becomes rent-ready", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-rent-ready-countdown-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push({
        Item: [{ State: [], id: "4" }],
        sid: "3020",
        csid: String(mineCompany.sid ?? "1"),
        sku: "HeadQuarter",
        x: "-1",
        y: "-3",
        isSuspended: "0"
      });
      mineCompany.Company.push({
        Item: [
          {
            State: [],
            id: "1",
            mode: "4",
            time: "180000",
            contractSku: "1",
            savedAt: String(Date.now())
          }
        ],
        sid: "3013",
        csid: String(mineCompany.sid ?? "1"),
        sku: "houses_001_001",
        x: "10",
        y: "6",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_item",
            _dat: {
              action: "new_mode",
              sid: "3013",
              mode: 5,
              time: 0,
              contractSku: 1
            },
            _cnt: 1
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const collectedHouse = mineCompany.Company.find((item: { sid?: string }) => item.sid === "3013") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = collectedHouse?.Item?.find((entry) => Array.isArray(entry.State)) as
        | Record<string, unknown>
        | undefined;

      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("5");
      expect(Number(state?.time)).toBeGreaterThan(3_500_000);
      expect(Number(state?.time)).toBeLessThanOrEqual(3_600_000);
      expect(Number(state?.savedAt)).toBeGreaterThan(Date.now() - 10_000);
    }
  });

  test("marks overdue ready rent as abandoned after the original grace period", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-rent-abandoned-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push({
        Item: [{ State: [], id: "4" }],
        sid: "3020",
        csid: String(mineCompany.sid ?? "1"),
        sku: "HeadQuarter",
        x: "-1",
        y: "-3",
        isSuspended: "0"
      });
      mineCompany.Company.push({
        Item: [
          {
            State: [],
            id: "1",
            mode: "4",
            time: "180000",
            contractSku: "1",
            savedAt: String(Date.now() - 4_000_000)
          }
        ],
        sid: "3014",
        csid: String(mineCompany.sid ?? "1"),
        sku: "houses_001_001",
        x: "11",
        y: "6",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const overdueHouse = mineCompany.Company.find((item: { sid?: string }) => item.sid === "3014") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = overdueHouse?.Item?.find((entry) => Array.isArray(entry.State)) as
        | Record<string, unknown>
        | undefined;

      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("7");
      expect(state?.time).toBe("0");
      expect(state?.contractSku).toBe("1");
    }
  });

  test("collapses unsupported house collectible states back to waiting for contract on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-house-collectible-reset-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push({
        Item: [{ State: [], id: "4" }],
        sid: "3020",
        csid: String(mineCompany.sid ?? "1"),
        sku: "HeadQuarter",
        x: "-1",
        y: "-3",
        isSuspended: "0"
      });
      mineCompany.Company.push({
        Item: [
          {
            State: [],
            id: "1",
            mode: "14",
            time: "0",
            contractSku: "1",
            savedAt: String(Date.now() - 10_000)
          }
        ],
        sid: "3012",
        csid: String(mineCompany.sid ?? "1"),
        sku: "houses_001_001",
        x: "9",
        y: "6",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const house = mineCompany.Company.find((item: { sid?: string }) => item.sid === "3012") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = house?.Item?.find((entry) => Array.isArray(entry.State)) as
        | Record<string, unknown>
        | undefined;

      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("1");
      expect(state?.time).toBe("0");
      expect(state?.contractSku).toBeUndefined();
    }
  });

  test("advances offline house contract timers based on saved wall-clock time", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-contract-elapsed-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push({
        Item: [
          {
            State: [],
            id: "1",
            mode: "4",
            time: "600000",
            contractSku: "2",
            savedAt: String(Date.now() - 120000)
          }
        ],
        sid: "3010",
        csid: String(mineCompany.sid ?? "1"),
        sku: "houses_001_001",
        x: "8",
        y: "6",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const rentedHouse = mineCompany.Company.find((item: { sid?: string }) => item.sid === "3010") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = rentedHouse?.Item?.find((entry) => Array.isArray(entry.State));

      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("4");
      expect(Number(state?.time)).toBeGreaterThanOrEqual(470_000);
      expect(Number(state?.time)).toBeLessThanOrEqual(490_000);
      expect(Number(state?.savedAt)).toBeGreaterThan(Date.now() - 10_000);
    }
  });

  test("moves bought rival sale items into the player company", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-rival-buy-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_profile",
            _dat: { action: "tutorial_completed" },
            _cnt: 1
          },
          {
            _cmd: "update_item",
            _dat: { action: "new_mode", sid: "2002", csid: "1", mode: 4, time: 180000 },
            _cnt: 2
          },
          {
            _cmd: "update_item",
            _dat: { action: "new_state", sid: "2002", state: 1, mode: 4, time: 180000, contractSku: 19 },
            _cnt: 3
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const rivalCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "1"
      );
      const mineBought = mineCompany.Company.find((item: { sid?: string }) => item.sid === "2002") as
        | { csid?: string; Item?: Array<Record<string, unknown>> }
        | undefined;
      const rivalBought = rivalCompany.Company.find((item: { sid?: string }) => item.sid === "2002");
      const state = mineBought?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

      expect(mineBought?.csid).toBe("1");
      expect(state?.id).toBe("1");
      expect(state?.contractSku).toBe("19");
      expect(rivalBought).toBeUndefined();
    }
  });

  test("does not reset completed saves after the rival starter properties are bought out", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-rival-bought-out-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };
      const rivalCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "1"
      ) as { Company: Array<Record<string, unknown>> } | undefined;

      profile.tutorialEnd = "1";
      profile.cityname = "Bought Out City";
      profile.cityNameCodes = "66,111,117,103,104,116,32,79,117,116,32,67,105,116,121";

      for (const item of rivalCompany?.Company ?? []) {
        if (!Array.isArray(item.Item)) {
          continue;
        }
        item.csid = String(mineCompany.sid ?? "1");
        const state = item.Item.find((entry: Record<string, unknown>) => Array.isArray(entry.State)) as
          | Record<string, unknown>
          | undefined;
        if (state) {
          state.id = "1";
          state.mode = "4";
          state.time = "180000";
          state.contractSku = "19";
          state.savedAt = String(Date.now());
        }
        mineCompany.Company.push(item);
      }

      if (rivalCompany) {
        rivalCompany.Company = [];
      }

      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const repairedProfile = world.find((entry: { Profile?: Array<Record<string, unknown>> }) => Array.isArray(entry.Profile));
      const repairedWorld = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const repairedMineCompany = repairedWorld.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const repairedRivalCompany = repairedWorld.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "1"
      );

      expect(repairedProfile.cityname).toBe("Bought Out City");
      expect(repairedProfile.tutorialEnd).toBe("1");
      expect(repairedMineCompany.Company.some((item: { sid?: string }) => item.sid === "2001")).toBe(true);
      expect(repairedRivalCompany.Company).toHaveLength(0);
    }
  });

  test("preserves tutorial bungalow contracts and unbought rival sale houses across restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-post-tutorial-restart-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      profile.firstMission = "1";
      mineCompany.Company.push(
        {
          Item: [{ State: [], id: "4" }],
          sid: "1003",
          csid: String(mineCompany.sid ?? "1"),
          sku: "HeadQuarter",
          x: "-1",
          y: "-3",
          isSuspended: "0"
        },
        {
          Item: [
            {
              State: [],
              id: "1",
              mode: "4",
              time: "180000",
              contractSku: "1",
              savedAt: String(Date.now())
            }
          ],
          sid: "1004",
          csid: String(mineCompany.sid ?? "1"),
          sku: "houses_001_001",
          x: "4",
          y: "2",
          isSuspended: "0"
        },
        {
          Item: [{ State: [], id: "5" }],
          sid: "1005",
          csid: String(mineCompany.sid ?? "1"),
          sku: "decorations_tree_01",
          x: "4",
          y: "1",
          isSuspended: "0"
        }
      );
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const repairedWorld = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const repairedMineCompany = repairedWorld.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const repairedRivalCompany = repairedWorld.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "1"
      );
      const tutorialHouse = repairedMineCompany.Company.find((item: { sid?: string }) => item.sid === "1004") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const tutorialHouseState = tutorialHouse?.Item?.find((entry) => Array.isArray(entry.State)) as
        | Record<string, unknown>
        | undefined;
      const rivalSaleItems = repairedRivalCompany.Company.filter((item: { sid?: string }) =>
        ["2002", "2003", "2004"].includes(String(item.sid ?? ""))
      );

      expect(tutorialHouseState?.id).toBe("1");
      expect(tutorialHouseState?.mode).toBe("4");
      expect(tutorialHouseState?.contractSku).toBe("1");
      expect(rivalSaleItems).toHaveLength(3);
      for (const item of rivalSaleItems as Array<{ Item?: Array<Record<string, unknown>> }>) {
        const state = item.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;
        expect(state?.id).toBe("3");
        expect(state?.mode).toBe("2");
      }
    }
  });

  test("merges the legacy duplicate tutorial bungalow back onto the tutorial tile", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-legacy-bungalow-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      profile.firstMission = "1";
      mineCompany.Company.push(
        {
          Item: [{ State: [], id: "4" }],
          sid: "1003",
          csid: String(mineCompany.sid ?? "1"),
          sku: "HeadQuarter",
          x: "-1",
          y: "-3",
          isSuspended: "0"
        },
        {
          Item: [{ State: [], id: "1", mode: "1", time: "0" }],
          sid: "1004",
          csid: String(mineCompany.sid ?? "1"),
          sku: "houses_001_001",
          x: "4",
          y: "2",
          isSuspended: "0"
        },
        {
          Item: [
            {
              State: [],
              id: "1",
              mode: "4",
              time: "180000",
              contractSku: "1",
              savedAt: String(Date.now())
            }
          ],
          sid: "2006",
          csid: String(mineCompany.sid ?? "1"),
          sku: "houses_001_001",
          x: "0",
          y: "0",
          isSuspended: "0"
        }
      );
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const repairedWorld = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const repairedMineCompany = repairedWorld.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const bungalows = repairedMineCompany.Company.filter((item: { sku?: string }) => item.sku === "houses_001_001");
      const tutorialBungalow = bungalows.find((item: { x?: string; y?: string }) => item.x === "4" && item.y === "2") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = tutorialBungalow?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

      expect(bungalows).toHaveLength(1);
      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("4");
      expect(state?.contractSku).toBe("1");
    }
  });

  test("advances offline construction timers based on saved wall-clock time", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-construction-elapsed-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push({
        Item: [
          {
            State: [],
            id: "0",
            mode: "2",
            time: "600000",
            savedAt: String(Date.now() - 120000)
          }
        ],
        sid: "3020",
        csid: String(mineCompany.sid ?? "1"),
        sku: "houses_003_001",
        x: "9",
        y: "6",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const item = mineCompany.Company.find((entry: { sid?: string }) => entry.sid === "3020") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = item?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

      expect(state?.id).toBe("0");
      expect(state?.mode).toBe("2");
      expect(Number(state?.time)).toBeGreaterThanOrEqual(470_000);
      expect(Number(state?.time)).toBeLessThanOrEqual(490_000);
      expect(Number(state?.savedAt)).toBeGreaterThan(Date.now() - 10_000);
    }
  });

  test("keeps zero-time construction saves finished on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-construction-reset-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push(
        {
          Item: [{ State: [], id: "4" }],
          sid: "3020",
          csid: String(mineCompany.sid ?? "1"),
          sku: "HeadQuarter",
          x: "-1",
          y: "-3",
          isSuspended: "0"
        },
        {
          Item: [
            {
              State: [],
              id: "0",
              mode: "2",
              time: "0"
            }
          ],
          sid: "3021",
          csid: String(mineCompany.sid ?? "1"),
          sku: "houses_001_001",
          x: "9",
          y: "6",
          isSuspended: "0"
        }
      );
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const item = mineCompany.Company.find((entry: { sid?: string }) => entry.sid === "3021") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = item?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

      expect(state?.id).toBe("0");
      expect(state?.mode).toBe("2");
      expect(state?.time).toBe("0");
      expect(state?.savedAt).toBeUndefined();
    }
  });

  test("does not reset offline-finished construction timers on repeated normalization", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-construction-finished-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push(
        {
          Item: [{ State: [], id: "4" }],
          sid: "3030",
          csid: String(mineCompany.sid ?? "1"),
          sku: "HeadQuarter",
          x: "-1",
          y: "-3",
          isSuspended: "0"
        },
        {
          Item: [
            {
              State: [],
              id: "0",
              mode: "2",
              time: "600000",
              savedAt: String(Date.now() - 900_000)
            }
          ],
          sid: "3031",
          csid: String(mineCompany.sid ?? "1"),
          sku: "houses_001_001",
          x: "9",
          y: "6",
          isSuspended: "0"
        }
      );
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>> };
      const item = mineCompany.Company.find((entry: { sid?: string }) => entry.sid === "3031") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = item?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

      expect(state?.id).toBe("0");
      expect(state?.mode).toBe("2");
      expect(state?.time).toBe("0");

      const normalizedAgain = normalizeCompletedTutorialUniverse(universe as JsonObject, Date.now());
      const normalizedState = item?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

      expect(normalizedAgain).toBe(false);
      expect(normalizedState?.time).toBe("0");
    }
  });

  test("stamps savedAt for live construction item mutations", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-construction-mutation-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const mutationData = JSON.stringify({
      _cmdList: [
        {
          _cmd: "update_item",
          _dat: {
            action: "new_item",
            sid: "3022",
            sku: "houses_001_001",
            item: {
              Item: [{ State: [], id: "0", mode: "2", time: "600000" }],
              sid: "3022",
              csid: "1",
              sku: "houses_001_001",
              x: "9",
              y: "6",
              isSuspended: "0"
            }
          },
          _cnt: 1
        }
      ],
      _msgCount: 0,
      _sync: 1
    });

    const sig = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );

    await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: mutationData,
      flash_version: "WIN 32,0,0,0",
      sig
    });

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const root = universe.universe as Array<Record<string, unknown>>;
    const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
    const mineCompany = worldContainer.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>> };
    const item = mineCompany.Company.find((entry: { sid?: string }) => entry.sid === "3022") as
      | { Item?: Array<Record<string, unknown>> }
      | undefined;
    const state = item?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

    expect(state?.id).toBe("0");
    expect(state?.mode).toBe("2");
    expect(state?.time).toBe("600000");
    expect(Number(state?.savedAt)).toBeGreaterThan(Date.now() - 10_000);
  });

  test("persists mission completion and poll manager progress across restarts", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-missions-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_pollmanager",
            _dat: { action: "add", type: "build", parameter: "houses_001_002" },
            _cnt: 1
          },
          {
            _cmd: "update_pollmanager",
            _dat: { action: "update", type: "bonus", parameter: "houses_001", value: "2" },
            _cnt: 2
          },
          {
            _cmd: "update_missions",
            _dat: {
              action: "update",
              sku: "6",
              security: {
                expGain: -170,
                coinsGain: -60000,
                cashGain: 0,
                compValueGain: 0
              }
            },
            _cnt: 3
          },
          {
            _cmd: "update_profile",
            _dat: { action: "tutorial_completed" },
            _cnt: 4
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const profile = world.find((entry) => Array.isArray(entry.Profile)) as { Profile: Array<Record<string, unknown>> };
      const missions = profile.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const pollManager = profile.Profile.find((entry) => Array.isArray(entry.PollManager)) as
        | { PollManager: Array<Record<string, unknown>> }
        | undefined;
      const given = missions?.Missions.find((entry) => Array.isArray(entry.Given)) as { chunk?: string } | undefined;
      const count = pollManager?.PollManager.find((entry) => Array.isArray(entry.Count)) as { chunk?: string } | undefined;

      expect(given?.chunk).toBe("6");
      expect(count?.chunk).toContain("bonushouses_001/2");
      expect(count?.chunk).toContain("buildhouses_001_002/1");
    }
  });

  test("resets incomplete tutorial progress on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-tutorial-reset-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_profile",
            _dat: { action: "city_name", value: "Broken Tutorial Save" },
            _cnt: 1
          },
          {
            _cmd: "update_item",
            _dat: { action: "build", sid: "99", sku: "HeadQuarter", x: 1, y: -4, state: 4 },
            _cnt: 2
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const profile = world[0];
      const worldContainer = world.find((entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World));
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const mineItems = mineCompany?.Company.filter((item: Record<string, unknown>) => Array.isArray(item.Item)) ?? [];

      expect(profile.cityname).toBe("Chocolate Fields");
      expect(profile.tutorialEnd).toBe("0");
      expect(mineItems.map((item) => item.sku)).toEqual(EXPECTED_STARTER_DECORATION_SKUS);
      expect(mineItems.some((item) => item.sku === "HeadQuarter")).toBe(false);
    }
  });

  test("removes tutorial-placed map tiles and cypress tree from incomplete tutorial saves on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-tutorial-map-cleanup-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };
      const mapContainer = worldContainer.World.find((entry) => Array.isArray(entry.Map)) as {
        Map: Array<Record<string, unknown>>;
      };
      const terrain = mapContainer.Map.find((entry) => Array.isArray(entry.Terrain)) as { chunk?: string };
      const road = mapContainer.Map.find((entry) => Array.isArray(entry.Road)) as { chunk?: string };
      const terrainTiles = new Set(String(terrain.chunk ?? "").split(",").filter((tile) => tile.length > 0));
      const roadTiles = new Set(String(road.chunk ?? "").split(",").filter((tile) => tile.length > 0));

      terrainTiles.add("5:2");
      terrainTiles.add("5:3");
      roadTiles.add("3:4");
      roadTiles.add("4:4");
      terrain.chunk = Array.from(terrainTiles).join(",");
      road.chunk = Array.from(roadTiles).join(",");
      mineCompany.Company.push({
        Item: [{ State: [], id: "5" }],
        sid: "5098",
        csid: String(mineCompany.sid ?? "1"),
        sku: "decorations_tree_01",
        x: "4",
        y: "1",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>> };
      const mapContainer = worldContainer.World.find((entry) => Array.isArray(entry.Map)) as {
        Map: Array<Record<string, unknown>>;
      };
      const terrain = mapContainer.Map.find((entry) => Array.isArray(entry.Terrain)) as { chunk?: string };
      const road = mapContainer.Map.find((entry) => Array.isArray(entry.Road)) as { chunk?: string };
      const terrainTiles = new Set(String(terrain.chunk ?? "").split(",").filter((tile) => tile.length > 0));
      const roadTiles = new Set(String(road.chunk ?? "").split(",").filter((tile) => tile.length > 0));

      expect(profile.tutorialEnd).toBe("0");
      expect(terrainTiles.has("4:2")).toBe(true);
      expect(terrainTiles.has("4:3")).toBe(true);
      expect(terrainTiles.has("5:2")).toBe(false);
      expect(terrainTiles.has("5:3")).toBe(false);
      expect(roadTiles.has("3:4")).toBe(false);
      expect(roadTiles.has("4:4")).toBe(false);
      expect(mineCompany.Company.some((item) => item.sid === "5098" && item.sku === "decorations_tree_01")).toBe(false);
    }
  });

  test("preserves decoration-only incomplete tutorial saves on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-decoration-tutorial-preserve-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.cityname = "Decor Test";
      mineCompany.Company.push({
        Item: [{ State: [], id: "5" }],
        sid: "5099",
        csid: String(mineCompany.sid ?? "1"),
        sku: "decorations_tree_01",
        x: "4",
        y: "5",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>> };

      expect(profile.cityname).toBe("Decor Test");
      expect(profile.tutorialEnd).toBe("0");
      expect(mineCompany.Company.some((item) => item.sid === "5099" && item.sku === "decorations_tree_01")).toBe(true);
    }
  });

  test("repairs broken completed tutorial saves on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-tutorial-repair-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const universeRoot = universe.universe as Array<Record<string, unknown>>;
      const profile = universeRoot.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = universeRoot.find((entry) => Array.isArray(entry.World)) as
        | { World: Array<Record<string, unknown>> }
        | undefined;
      const mineCompany = worldContainer?.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string } | undefined;

      profile.tutorialEnd = "1";
      delete profile.bossGenre;
      profile.DCCash = "50";
      profile.companyValue = "550000";
      mineCompany?.Company.push(
        {
          Item: [{ State: [], id: "5", mode: "1", time: "0" }],
          sid: "2006",
          csid: String(mineCompany?.sid ?? "1"),
          sku: "houses_001_001",
          x: "0",
          y: "0",
          isSuspended: "0"
        },
        {
          Item: [{ State: [], id: "5" }],
          sid: "2007",
          csid: String(mineCompany?.sid ?? "1"),
          sku: "decorations_tree_01",
          x: "4",
          y: "1",
          isSuspended: "0"
        },
        {
          Item: [{ State: [], id: "5", mode: "4", time: "28800000", contractSku: "2" }],
          sid: "2008",
          csid: String(mineCompany?.sid ?? "1"),
          sku: "houses_001_002",
          x: "8",
          y: "6",
          isSuspended: "0"
        }
      );
      serverApp.repository.setDocument(1, "universe", universe);

      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe;
      const repairedProfile = world[0];
      const repairedWorldContainer = world.find(
        (entry: { World?: Array<Record<string, unknown>> }) => Array.isArray(entry.World)
      );
      const repairedMineCompany = repairedWorldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      );
      const repairedMineItems =
        repairedMineCompany?.Company.filter((item: Record<string, unknown>) => Array.isArray(item.Item)) ?? [];
      const repairedMap = repairedWorldContainer.World.find(
        (entry: { Map?: Array<Record<string, unknown>> }) => Array.isArray(entry.Map)
      ) as { Map: Array<Record<string, unknown>> };
      const repairedTerrain = repairedMap.Map.find((entry) => Array.isArray(entry.Terrain)) as
        | { chunk?: string }
        | undefined;
      const repairedRoad = repairedMap.Map.find((entry) => Array.isArray(entry.Road)) as
        | { chunk?: string }
        | undefined;
      const repairedHq = repairedMineItems.find((item) => item.sku === "HeadQuarter");
      const repairedHouse = repairedMineItems.find((item) => item.sku === "houses_001_001");
      const repairedBrokenRentHouse = repairedMineItems.find((item) => item.sid === "2008");
      const repairedBrokenRentState = repairedBrokenRentHouse?.Item.find((entry: Record<string, unknown>) =>
        Array.isArray(entry.State)
      ) as Record<string, unknown> | undefined;
      const repairedMissions = (repairedProfile.Profile as Array<Record<string, unknown>>).find((entry) =>
        Array.isArray(entry.Missions)
      ) as { Missions: Array<Record<string, unknown>> } | undefined;
      const repairedPollManager = (repairedProfile.Profile as Array<Record<string, unknown>>).find((entry) =>
        Array.isArray(entry.PollManager)
      ) as { PollManager: Array<Record<string, unknown>> } | undefined;
      const repairedUp = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Up)) as
        | { chunk?: string }
        | undefined;
      const repairedCount = repairedPollManager?.PollManager.find((entry) => Array.isArray(entry.Count)) as
        | { chunk?: string }
        | undefined;

      expect(repairedProfile.tutorialEnd).toBe("1");
      expect(repairedProfile.bossGenre).toBe("0");
      expect(repairedProfile.DCCash).toBe("0");
      expect(repairedProfile.firstMission).toBe("1");
      expect(repairedHq?.x).toBe("-1");
      expect(repairedHq?.y).toBe("-3");
      expect(repairedHouse?.x).toBe("4");
      expect(repairedHouse?.y).toBe("2");
      expect(repairedTerrain?.chunk).toContain("5:2");
      expect(repairedTerrain?.chunk).toContain("5:3");
      expect(repairedRoad?.chunk).toContain("3:4");
      expect(repairedRoad?.chunk).toContain("4:4");
      expect(repairedUp?.chunk).toBe("1,10,2,5");
      expect(repairedCount?.chunk).toBe("");
      expect(repairedHouse?.Item.find((entry: Record<string, unknown>) => Array.isArray(entry.State))?.id).toBe("1");
      expect(repairedHouse?.Item.find((entry: Record<string, unknown>) => Array.isArray(entry.State))?.mode).toBe("1");
      expect(repairedHouse?.Item.find((entry: Record<string, unknown>) => Array.isArray(entry.State))?.time).toBe("0");
      expect(repairedBrokenRentState?.id).toBe("1");
      expect(repairedBrokenRentState?.mode).toBe("4");
      expect(Number(repairedBrokenRentState?.time)).toBeGreaterThan(28_700_000);
      expect(Number(repairedBrokenRentState?.time)).toBeLessThanOrEqual(28_800_000);
      expect(repairedBrokenRentState?.contractSku).toBe("2");
    }
  });

  test("reconciles early completed missions from saved poll progress", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-mission-reconcile-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as { Profile: Array<Record<string, unknown>> } & Record<string, unknown>;
      const missions = profile.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const pollManager = profile.Profile.find((entry) => Array.isArray(entry.PollManager)) as
        | { PollManager: Array<Record<string, unknown>> }
        | undefined;
      const up = missions?.Missions.find((entry) => Array.isArray(entry.Up)) as Record<string, unknown> | undefined;
      const reached = missions?.Missions.find((entry) => Array.isArray(entry.Reached)) as Record<string, unknown> | undefined;
      const given = missions?.Missions.find((entry) => Array.isArray(entry.Given)) as Record<string, unknown> | undefined;
      const count = pollManager?.PollManager.find((entry) => Array.isArray(entry.Count)) as Record<string, unknown> | undefined;

      profile.tutorialEnd = "1";
      profile.firstMission = "0";
      profile.cityname = "Renamed City";
      profile.cityNameCodes = "82,101,110,97,109,101,100,32,67,105,116,121";
      if (up) {
        up.chunk = "1,10,2,5";
      }
      if (reached) {
        reached.chunk = "";
      }
      if (given) {
        given.chunk = "";
      }
      if (count) {
        count.chunk = "buycommerce_pizza/1,checkInfluencecommerce_pizza/1,instantBuild/1";
      } else if (pollManager) {
        pollManager.PollManager.push({ Count: [], chunk: "buycommerce_pizza/1,checkInfluencecommerce_pizza/1,instantBuild/1" });
      }

      serverApp.repository.setDocument(1, "universe", universe);
      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const repairedProfile = world.find((entry) => Array.isArray(entry.Profile)) as
        | ({ Profile: Array<Record<string, unknown>> } & Record<string, unknown>)
        | undefined;
      const repairedMissions = repairedProfile?.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const repairedUp = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Up)) as
        | { chunk?: string }
        | undefined;
      const repairedGiven = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Given)) as
        | { chunk?: string }
        | undefined;
      const givenSkus = (repairedGiven?.chunk ?? "").split(",").filter(Boolean);
      const upSkus = (repairedUp?.chunk ?? "").split(",").filter(Boolean);

      expect(repairedProfile?.firstMission).toBe("0");
      expect(givenSkus).toContain("1");
      expect(givenSkus).toContain("2");
      expect(givenSkus).toContain("5");
      expect(givenSkus).toContain("18");
      expect(upSkus).toContain("10");
      expect(upSkus).toContain("31");
      expect(upSkus).not.toContain("1");
      expect(upSkus).not.toContain("2");
      expect(upSkus).not.toContain("5");
      expect(upSkus).not.toContain("18");
    }
  });

  test("marks the city-name mission completed once the city is renamed", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-name-mission-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as { Profile: Array<Record<string, unknown>> } & Record<string, unknown>;
      const missions = profile.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const up = missions?.Missions.find((entry) => Array.isArray(entry.Up)) as Record<string, unknown> | undefined;
      const reached = missions?.Missions.find((entry) => Array.isArray(entry.Reached)) as Record<string, unknown> | undefined;
      const given = missions?.Missions.find((entry) => Array.isArray(entry.Given)) as Record<string, unknown> | undefined;

      profile.tutorialEnd = "1";
      profile.firstMission = "1";
      profile.cityname = "Renamed City";
      profile.cityNameCodes = "82,101,110,97,109,101,100,32,67,105,116,121";
      if (up) {
        up.chunk = "1,10,2,5";
      }
      if (reached) {
        reached.chunk = "";
      }
      if (given) {
        given.chunk = "";
      }

      serverApp.repository.setDocument(1, "universe", universe);
      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);
      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });
      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );
      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const repairedProfile = world.find((entry) => Array.isArray(entry.Profile)) as
        | ({ Profile: Array<Record<string, unknown>> } & Record<string, unknown>)
        | undefined;
      const repairedMissions = repairedProfile?.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const repairedUp = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Up)) as
        | { chunk?: string }
        | undefined;
      const repairedGiven = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Given)) as
        | { chunk?: string }
        | undefined;
      const givenSkus = (repairedGiven?.chunk ?? "").split(",").filter(Boolean);
      const upSkus = (repairedUp?.chunk ?? "").split(",").filter(Boolean);

      expect(repairedProfile?.firstMission).toBe("0");
      expect(givenSkus).toContain("1");
      expect(upSkus).not.toContain("1");
    }
  });

  archivedAssetTest("settles stale early bonus missions from saved poll progress on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-bonus-missions-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as { Profile: Array<Record<string, unknown>> } & Record<string, unknown>;
      const missions = profile.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const pollManager = profile.Profile.find((entry) => Array.isArray(entry.PollManager)) as
        | { PollManager: Array<Record<string, unknown>> }
        | undefined;
      profile.tutorialEnd = "1";
      profile.level = "12";
      if (missions) {
        missions.Missions = [
          { Up: [], chunk: "1,2,10,25" },
          { Reached: [], chunk: "" },
          { Given: [], chunk: "5" }
        ];
      }
      if (pollManager) {
        pollManager.PollManager = [
          { Count: [], chunk: "bonushouses_001/2,buildDecorations_tree/8" }
        ];
      }

      serverApp.repository.setDocument(1, "universe", universe);
      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);
      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });
      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );
      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const repairedProfile = world.find((entry) => Array.isArray(entry.Profile)) as
        | ({ Profile: Array<Record<string, unknown>> } & Record<string, unknown>)
        | undefined;
      const repairedMissions = repairedProfile?.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const repairedUp = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Up)) as
        | { chunk?: string }
        | undefined;
      const repairedGiven = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Given)) as
        | { chunk?: string }
        | undefined;
      const upSkus = (repairedUp?.chunk ?? "").split(",").filter(Boolean);
      const givenSkus = (repairedGiven?.chunk ?? "").split(",").filter(Boolean);

      expect(upSkus).not.toContain("10");
      expect(upSkus).not.toContain("25");
      expect(givenSkus).toContain("10");
      expect(givenSkus).toContain("25");
      expect(givenSkus).toContain("26");
    }
  });

  test("persists mission reward claims even when the claim update has no negative security delta", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-mission-claim-persist-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as { Profile: Array<Record<string, unknown>> } & Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };
      const missions = profile.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;

      profile.tutorialEnd = "1";
      profile.level = "6";
      mineCompany.Company.push({
        Item: [{ State: [], id: "4" }],
        sid: "9904",
        csid: String(mineCompany.sid ?? "1"),
        sku: "HeadQuarter",
        x: "1",
        y: "-1",
        isSuspended: "0"
      });
      if (missions) {
        missions.Missions = [
          { Up: [], chunk: "39" },
          { Reached: [], chunk: "" },
          { Given: [], chunk: "" }
        ];
      }

      serverApp.repository.setDocument(1, "universe", universe);

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_missions",
            _dat: {
              action: "update",
              sku: "39",
              security: {
                expGain: 0,
                coinsGain: 0,
                cashGain: 0,
                compValueGain: 0
              }
            },
            _cnt: 1
          },
          {
            _cmd: "update_missions",
            _dat: {
              action: "update",
              sku: "39",
              security: {
                expGain: 0,
                coinsGain: 0,
                cashGain: 0,
                compValueGain: 0
              }
            },
            _cnt: 2
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);
      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });
      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );
      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const repairedProfile = world.find((entry) => Array.isArray(entry.Profile)) as
        | ({ Profile: Array<Record<string, unknown>> } & Record<string, unknown>)
        | undefined;
      const repairedMissions = repairedProfile?.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const repairedReached = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Reached)) as
        | { chunk?: string }
        | undefined;
      const repairedGiven = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Given)) as
        | { chunk?: string }
        | undefined;
      const reachedSkus = (repairedReached?.chunk ?? "").split(",").filter(Boolean);
      const givenSkus = (repairedGiven?.chunk ?? "").split(",").filter(Boolean);

      expect(reachedSkus).not.toContain("39");
      expect(givenSkus).toContain("39");
    }
  });

  test("applies delayed mission reward security gains once when expNow is stale", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-mission-reward-security-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };
    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const root = universe.universe as Array<Record<string, unknown>>;
    const profile = root.find((entry) => Array.isArray(entry.Profile)) as
      | ({ Profile: Array<Record<string, unknown>> } & Record<string, unknown>)
      | undefined;
    const missions = profile?.Profile.find((entry) => Array.isArray(entry.Missions)) as
      | { Missions: Array<Record<string, unknown>> }
      | undefined;

    expect(profile).toBeTruthy();
    if (!profile || !missions) {
      throw new Error("Expected starter profile and missions containers.");
    }

    profile.tutorialEnd = "1";
    profile.exp = "756";
    profile.DCCoins = "1000";
    profile.DCCash = "10";
    profile.companyValue = "550000";
    missions.Missions = [
      { Up: [], chunk: "" },
      { Reached: [], chunk: "39" },
      { Given: [], chunk: "" }
    ];
    serverApp.repository.setDocument(1, "universe", universe);

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);
    const security = {
      expGain: 2134,
      expNow: 756,
      coinsGain: 2500,
      coinsNow: 1000,
      cashGain: 5,
      cashNow: 10,
      compValueGain: 3000,
      compValueNow: 550000
    };
    const mutationData = JSON.stringify({
      _cmdList: [
        { _cmd: "update_missions", _dat: { action: "update", sku: "39", security }, _cnt: 1 },
        { _cmd: "update_missions", _dat: { action: "update", sku: "39", security }, _cnt: 2 }
      ],
      _msgCount: 0,
      _sync: 1
    });
    const sig = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );

    await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: mutationData,
      flash_version: "WIN 32,0,0,0",
      sig
    });

    const saved = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const savedProfile = (saved.universe as Array<Record<string, unknown>>).find((entry) =>
      Array.isArray(entry.Profile)
    ) as { Profile: Array<Record<string, unknown>> } & Record<string, unknown>;
    const savedMissions = savedProfile.Profile.find((entry) => Array.isArray(entry.Missions)) as
      | { Missions: Array<Record<string, unknown>> }
      | undefined;
    const given = savedMissions?.Missions.find((entry) => Array.isArray(entry.Given)) as
      | { chunk?: string }
      | undefined;

    expect(savedProfile.exp).toBe("2890");
    expect(savedProfile.DCCoins).toBe("3500");
    expect(savedProfile.DCCash).toBe("15");
    expect(savedProfile.companyValue).toBe("553000");
    expect(given?.chunk).toBe("39");
  });

  archivedAssetTest("removes impossible poll-driven reward state on restart and respects the level derived from xp", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-mission-sanitize-invalid-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as { Profile: Array<Record<string, unknown>> } & Record<string, unknown>;
      const missions = profile.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const pollManager = profile.Profile.find((entry) => Array.isArray(entry.PollManager)) as
        | { PollManager: Array<Record<string, unknown>> }
        | undefined;

      profile.tutorialEnd = "1";
      profile.exp = "100";
      delete profile.level;
      if (missions) {
        missions.Missions = [
          { Up: [], chunk: "39" },
          { Reached: [], chunk: "26,39" },
          { Given: [], chunk: "1,25" }
        ];
      }
      if (pollManager) {
        pollManager.PollManager = [
          { Count: [], chunk: "buildDecorations_tree/2,visitCity/1" }
        ];
      }

      serverApp.repository.setDocument(1, "universe", universe);
      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);
      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });
      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );
      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const repairedProfile = world.find((entry) => Array.isArray(entry.Profile)) as
        | ({ Profile: Array<Record<string, unknown>> } & Record<string, unknown>)
        | undefined;
      const repairedMissions = repairedProfile?.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const repairedUp = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Up)) as
        | { chunk?: string }
        | undefined;
      const repairedReached = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Reached)) as
        | { chunk?: string }
        | undefined;
      const upSkus = (repairedUp?.chunk ?? "").split(",").filter(Boolean);
      const reachedSkus = (repairedReached?.chunk ?? "").split(",").filter(Boolean);

      expect(upSkus).not.toContain("39");
      expect(reachedSkus).not.toContain("26");
      expect(reachedSkus).not.toContain("39");
    }
  });

  archivedAssetTest("demotes saved poll-driven reached missions back to up on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-mission-demote-reached-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as { Profile: Array<Record<string, unknown>> } & Record<string, unknown>;
      const missions = profile.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const pollManager = profile.Profile.find((entry) => Array.isArray(entry.PollManager)) as
        | { PollManager: Array<Record<string, unknown>> }
        | undefined;

      profile.tutorialEnd = "1";
      profile.level = "2";
      if (missions) {
        missions.Missions = [
          { Up: [], chunk: "" },
          { Reached: [], chunk: "39" },
          { Given: [], chunk: "1" }
        ];
      }
      if (pollManager) {
        pollManager.PollManager = [
          { Count: [], chunk: "visitCity/1" }
        ];
      }

      serverApp.repository.setDocument(1, "universe", universe);
      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };
      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);
      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });
      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );
      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const repairedProfile = world.find((entry) => Array.isArray(entry.Profile)) as
        | ({ Profile: Array<Record<string, unknown>> } & Record<string, unknown>)
        | undefined;
      const repairedMissions = repairedProfile?.Profile.find((entry) => Array.isArray(entry.Missions)) as
        | { Missions: Array<Record<string, unknown>> }
        | undefined;
      const repairedUp = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Up)) as
        | { chunk?: string }
        | undefined;
      const repairedReached = repairedMissions?.Missions.find((entry) => Array.isArray(entry.Reached)) as
        | { chunk?: string }
        | undefined;
      const upSkus = (repairedUp?.chunk ?? "").split(",").filter(Boolean);
      const reachedSkus = (repairedReached?.chunk ?? "").split(",").filter(Boolean);

      expect(upSkus).toContain("39");
      expect(reachedSkus).not.toContain("39");
    }
  });

  archivedAssetTest("serves placeholder feed art for missing mission images", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-feed-fallback-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const response = await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/feed/mission_build.jpg`);
    expect(response.status).toBe(200);
    expect(response.headers.get("content-type")).toContain("image/jpeg");
    const buffer = await response.arrayBuffer();
    expect(buffer.byteLength).toBeGreaterThan(0);
  });

  archivedAssetTest("serves archived assets with case-insensitive path matching", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-case-insensitive-assets-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const response = await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/datas/locale/en.txt`);
    expect(response.status).toBe(200);
    expect(response.headers.get("content-type")).toContain("text/plain");
    expect(await response.text()).toContain("Millionaire City");
  });

  archivedAssetTest("keeps locale text assets LF-only for Flash text parsing", () => {
    const localePath = path.join(getServerConfig().assetRoot, "Datas", "Locale", "EN.txt");
    const localeText = fs.readFileSync(localePath, "utf8");
    const localeLines = localeText.split("\n");

    expect(localeText).not.toContain("\r\n");
    expect(localeLines[48]).toBe(",");
    expect(localeLines[49]).toBe(".");
    expect(localeLines[795]).toBe("$");
  });

  test("does not serve item SWF fallbacks for missing main item assets", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-item-fallback-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const response = await fetch(
      `http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/Assets/items/houses_definitely_missing.swf`
    );
    expect(response.status).toBe(404);

    const missingMainSwfCases = [
      "houses_015_002.swf",
      "houses_012_003.swf",
      "decorations_statue_03.swf",
      "decorations_shop_01.swf",
      "decorations_halloween_03.swf"
    ];
    for (const requested of missingMainSwfCases) {
      const missingResponse = await fetch(
        `http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/Assets/items/${requested}`
      );
      expect(missingResponse.status).toBe(404);
    }
  });

  archivedAssetTest("serves only archived item definitions and makes archived limited-time items permanent", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-limited-item-rules-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const itemDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/itemDefinitions.xml`)
    ).text();
    const commerceDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/commerceDefinitions.xml`)
    ).text();
    const decorationDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/decorationDefinitions.xml`)
    ).text();
    const wonderDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/wonderDefinitions.xml`)
    ).text();
    const missionDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/missionDefinitions.xml`)
    ).text();

    const archivedLimitedHouse = extractDefinitionTag(itemDefinitions, "houses_014_001");
    const vipClub = extractDefinitionTag(commerceDefinitions, "commerce_vip");
    const vipMission = extractDefinitionTag(missionDefinitions, "64");
    const archivedLimEdWonder = extractDefinitionTag(wonderDefinitions, "wonder_buda");
    const advisorVariantRewardHouse = extractDefinitionTag(itemDefinitions, "houses_037_001");

    expect(archivedLimitedHouse).not.toContain("expireTime=");
    expect(vipClub).not.toContain("expireTime=");
    expect(vipClub).toContain('freeGift="1"');
    expect(vipMission).toContain('rewardType="commerce_vip"');
    expect(advisorVariantRewardHouse).toContain('useAdvisor="1"');
    expect(findDefinitionTag(itemDefinitions, "houses_015_001")).toBeUndefined();
    expect(findDefinitionTag(commerceDefinitions, "commerce_bollywood")).toBeUndefined();
    expect(findDefinitionTag(decorationDefinitions, "decorations_halloween_03")).toBeUndefined();
    expect(findDefinitionTag(wonderDefinitions, "wonder_dracula_castle")).toBeUndefined();
    expect(archivedLimEdWonder).not.toContain('shopTab="limEd"');
    expect(archivedLimEdWonder).not.toContain("releaseTime=");
    expect(archivedLimEdWonder).not.toContain("unitsAmount=");
  });

  archivedAssetTest("keeps collectible collections with advisor-variant item rewards", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-collectible-rules-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const groupDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/collectiblesGroupsDefinitions.xml`)
    ).text();
    const collectibleDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/collectiblesDefinitions.xml`)
    ).text();
    const rewardDefinitions = await (
      await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/rules/collectiblesRewardDefinitions.xml`)
    ).text();

    expect(extractDefinitionTag(groupDefinitions, "15")).toContain('reward="houses_037_001"');
    expect(extractDefinitionTag(collectibleDefinitions, "gift_057")).toContain('collection="15"');
    expect(extractDefinitionTag(rewardDefinitions, "houses_037_001")).toContain('useAdvisor="1"');
    expect(extractDefinitionTag(groupDefinitions, "7")).toContain('reward="decorations_christmas_07"');
    expect(extractDefinitionTag(collectibleDefinitions, "gift_025")).toContain('collection="7"');
    expect(extractDefinitionTag(rewardDefinitions, "decorations_christmas_07")).toContain('rewardType="item"');
  });

  archivedAssetTest("serves the bank commerce icon for missing commerce icons", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-commerce-icon-fallback-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const response = await fetch(
      `http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/Assets/items/CommerceTypes/icons/commerce_definitely_missing.png`
    );
    expect(response.status).toBe(200);
    expect(response.headers.get("content-type")).toContain("image/png");
    const buffer = await response.arrayBuffer();
    const fallbackPath = path.join(
      config.assetRoot,
      "Datas",
      "Assets",
      "items",
      "CommerceTypes",
      "icons",
      "commerce_bank.png"
    );
    expect(buffer.byteLength).toBe(fs.statSync(fallbackPath).size);
  });

  test("accepts local VIP Club email registration and exposes confirmation", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-vip-email-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const before = await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/userData/checkMail.html`);
    expect(await before.text()).toBe("0");

    const submit = await fetch(
      `http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/userData/checkSendMail.xml?email=mayor%40example.com`
    );
    expect(await submit.text()).toContain("<status>0</status>");

    const after = await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/userData/checkMail.html`);
    expect(await after.text()).toBe("1");
  });

  test("serves an empty generated gifts list for client startup", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-gifts-list-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const response = await fetch(`http://127.0.0.1:${config.httpPort}/mcity/0.501/Datas/userData/giftsList.xml`);

    expect(response.headers.get("content-type")).toContain("application/xml");
    expect(await response.text()).toBe("<giftsList />");
  });

  test("accepts WCRM VIP Club registration and exposes WCRM confirmation", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-vip-wcrm-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const before = await fetch(`http://127.0.0.1:${config.httpPort}/registration/isconfirmed/?fb_user_id=123`);
    expect(await before.text()).toBe("0");

    const submit = await fetch(
      `http://127.0.0.1:${config.httpPort}/registration/register/?fb_user_id=123&email=mayor%40example.com&project_id=7`
    );
    expect(await submit.text()).toContain("<status>0</status>");

    const after = await fetch(`http://127.0.0.1:${config.httpPort}/registration/isconfirmed/?fb_user_id=123`);
    expect(await after.text()).toBe("1");
  });

  test("accepts invalid signatures in offline mode", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-sig-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });

    const data = JSON.stringify({
      _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
      _msgCount: 0,
      _sync: 1
    });

    const payload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data,
      flash_version: "WIN 32,0,0,0",
      sig: "bad-signature"
    });

    const response = extractCommands(payload)[0];
    expect(response._cmd).toBe("get_world");
    expect(response._dat.universe).toBeTruthy();
  });

  test("sanitizes startup XML-backed values before sending them to the client", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-xml-sanitize-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const universeRoot = universe.universe as Array<Record<string, unknown>>;
    const profile = universeRoot.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    profile.cityname = 'Mayor "Test"\u0000';
    profile.userName = 'The "Boss"\u0000';
    profile.cityNameCodes = "77,97,121,111,114,32,34,84,101,115,116,34,0,";
    profile.tutorialEnd = "1";
    serverApp.repository.setDocument(1, "universe", universe);

    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const worldData = JSON.stringify({
      _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
      _msgCount: 0,
      _sync: 1
    });

    const sig = signPayload(
      {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0"
      },
      token
    );

    const payload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: worldData,
      flash_version: "WIN 32,0,0,0",
      sig
    });

    const world = extractCommands(payload)[0]._dat.universe;
    const returnedProfile = world[0];
    expect(returnedProfile.cityname).toBe("Mayor &quot;Test&quot;");
    expect(returnedProfile.userName).toBe("The &quot;Boss&quot;");
    expect(returnedProfile.cityNameCodes).toBe("77,97,121,111,114,32,34,84,101,115,116,34");
    expect(returnedProfile.cityname.includes("\u0000")).toBe(false);
    expect(returnedProfile.userName.includes("\u0000")).toBe(false);
  });

  test("returns free-purchase success for frictionless payments", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-payments-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const paymentData = JSON.stringify({
      type: "buytool",
      sku: "signator_1",
      price: 1
    });
    const paymentRequest = {
      uid: config.launcherUserId,
      cmd: "payments",
      version: "0.501",
      data: paymentData,
      flash_version: "WIN 32,0,0,0"
    };

    const paymentPayload = await postForm(config.httpPort, {
      ...paymentRequest,
      sig: signPayload(paymentRequest, token)
    });
    const paymentCommands = extractCommands(paymentPayload);

    expect(paymentCommands).toHaveLength(1);
    expect(paymentCommands[0]._cmd).toBe("payments");
    expect(paymentCommands[0]._dat.success).toBe("1");
    expect(paymentCommands[0]._dat.privateServerFreePurchase).toBe("1");
    expect(paymentCommands[0]._dat.awardedGold).toBe("0");
  });

  archivedAssetTest("persists purchased gold across restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-gold-persist-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_money",
            _dat: {
              action: "buyGold",
              sku: "3",
              security: {
                expGain: 0,
                coinsGain: 0,
                cashGain: 115,
                compValueGain: 6_900_000,
                expNow: 0,
                coinsNow: 380_000,
                cashNow: 115,
                compValueNow: 7_620_000
              }
            },
            _cnt: 1
          }
        ],
        _msgCount: 0,
        _sync: 1
      });
      const mutationRequest = {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0"
      };

      const mutationPayload = await postForm(config.httpPort, {
        ...mutationRequest,
        sig: signPayload(mutationRequest, token)
      });
      const mutationCommands = extractCommands(mutationPayload);

      expect(mutationCommands).toHaveLength(1);
      expect(mutationCommands[0]._cmd).toBe("update_money");

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const sig = signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: worldData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      );

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const profile = world.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown> | undefined;

      expect(profile?.DCCash).toBe("115");
      expect(profile?.DCCashPaid).toBe("100");
      expect(profile?.companyValue).toBe("7620000");
    }
  });

  test("persists first friend visit prompt dismissal across restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-first-visit-persist-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const mutationData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_profile",
            _dat: { action: "tutorial_completed" },
            _cnt: 1
          },
          {
            _cmd: "update_money",
            _dat: { action: "first_visit", value: 1 },
            _cnt: 2
          }
        ],
        _msgCount: 0,
        _sync: 1
      });
      const mutationRequest = {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: mutationData,
        flash_version: "WIN 32,0,0,0"
      };

      const mutationPayload = await postForm(config.httpPort, {
        ...mutationRequest,
        sig: signPayload(mutationRequest, token)
      });
      const mutationCommands = extractCommands(mutationPayload);

      expect(mutationCommands).toHaveLength(2);
      expect(mutationCommands[1]._cmd).toBe("update_money");

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });
      const worldRequest = {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0"
      };

      const payload = await postForm(config.httpPort, {
        ...worldRequest,
        sig: signPayload(worldRequest, token)
      });
      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const profile = world.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown> | undefined;

      expect(profile?.firstVisit).toBe("1");
    }
  });

  test("launcher keeps the normal gold HUD mode while exposing purchase success callbacks", () => {
    const html = renderLauncherHtml({
      appUrl: "https://127.0.0.1:31804",
      assetsBaseUrl: "https://127.0.0.1:31804/mcity/0.501/Datas/",
      serverBaseUrl: "https://127.0.0.1:31804",
      userId: "100000000000001",
      oauthToken: "local-oauth-token",
      gameToken: "bootstrap-token",
      facebookAppId: "315455798286",
      lang: "en_US",
      debugMode: false,
      climateMode: false,
      oldItemDesigns: false,
      localUserName: "Mayor",
      localCityName: "Chocolate Fields",
      localProfilePictureUrl: "/local/profile-picture?v=default"
    });

    expect(html).toContain("useFrictionlessFacebookCredits=false");
    expect(html).toContain("climateMode=0");
    expect(html).toContain("oldItemDesigns=0");
    expect(html).toContain("fbcreditsCurrentBalance:0:0");
    expect(html).toContain("messageResponseFacebookCredits:1");
    expect(html).toContain("var thumbnailSize = 50;");
    expect(html).toContain("localProfileUpdate");
    expect(html).toContain("INITIAL_LOCAL_PROFILE");
    expect(html).toContain("local_city_name");
    expect(html).toContain("Saved. Game profile updated.");
    expect(html).toContain("localStatsUpdate");
    expect(html).toContain("companyValue");
    expect(html).toContain("Saved. Game totals updated.");
    expect(html).toContain("mcity.localProfileSettingsVisible");
    expect(html).toContain("setLocalProfileSettingsVisible");
  });

  test("client local resource updates resynchronize the security baseline", () => {
    const patchSource = fs.readFileSync(
      path.join(
        getServerConfig().workspaceRoot,
        "client-patch-sources",
        "scripts",
        "com",
        "dchoc",
        "dollars",
        "server",
        "Server.as"
      ),
      "utf8"
    );

    expect(patchSource.replace(/\r\n/g, "\n")).toContain(
      "_loc2_.update();\n         UserDataFacade.securityInit();"
    );
  });

  test("saves local profile name and picture settings", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-local-profile-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const initial = await fetch(`http://127.0.0.1:${config.httpPort}/local/profile`);
    expect(initial.status).toBe(200);
    expect(await initial.json()).toMatchObject({
      ok: true,
      userName: "Mayor",
      cityName: "Chocolate Fields",
      hasProfilePicture: false
    });

    const invalidSave = await fetch(`http://127.0.0.1:${config.httpPort}/local/profile`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        userName: "Partially Saved Mayor",
        cityName: "Partially Saved City",
        profilePictureDataUrl: "not-an-image"
      })
    });
    expect(invalidSave.status).toBe(400);
    const profileAfterInvalidSave = await fetch(`http://127.0.0.1:${config.httpPort}/local/profile`);
    expect(await profileAfterInvalidSave.json()).toMatchObject({
      userName: "Mayor",
      cityName: "Chocolate Fields",
      hasProfilePicture: false
    });

    const pictureDataUrl = "data:image/gif;base64,R0lGODlhAQABAIABAP///wAAACwAAAAAAQABAAACAkQBADs=";
    const save = await fetch(`http://127.0.0.1:${config.httpPort}/local/profile`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        userName: "Test Mayor",
        cityName: "Test Town",
        profilePictureDataUrl: pictureDataUrl
      })
    });
    expect(save.status).toBe(200);
    expect(await save.json()).toMatchObject({
      ok: true,
      userName: "Test Mayor",
      cityName: "Test Town",
      hasProfilePicture: true
    });

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const profile = (universe.universe as Array<Record<string, unknown>>).find((entry) =>
      Array.isArray(entry.Profile)
    ) as Record<string, unknown> | undefined;
    expect(profile?.userName).toBe("Test Mayor");
    expect(profile?.cityname).toBe("Test Town");
    expect(profile?.cityNameCodes).toBe("84,101,115,116,32,84,111,119,110");
    expect(serverApp.repository.ensureDefaultUser().name).toBe("Test Mayor");

    const picture = await fetch(`http://127.0.0.1:${config.httpPort}/local/profile-picture`);
    expect(picture.status).toBe(200);
    expect(picture.headers.get("content-type")).toContain("image/gif");
    expect((await picture.arrayBuffer()).byteLength).toBeGreaterThan(0);

    await serverApp.stop();
    activeApps.pop();
    const restartedConfig = {
      ...config
    };
    const restartedServerApp = createServerApp(restartedConfig);
    activeApps.push(restartedServerApp);
    await restartedServerApp.start();

    const restartedProfile = await fetch(`http://127.0.0.1:${restartedConfig.httpPort}/local/profile`);
    expect(restartedProfile.status).toBe(200);
    expect(await restartedProfile.json()).toMatchObject({
      ok: true,
      userName: "Test Mayor",
      cityName: "Test Town",
      hasProfilePicture: true
    });

    const restartedPicture = await fetch(`http://127.0.0.1:${restartedConfig.httpPort}/local/profile-picture`);
    expect(restartedPicture.status).toBe(200);
    expect(restartedPicture.headers.get("content-type")).toContain("image/gif");
    expect((await restartedPicture.arrayBuffer()).byteLength).toBeGreaterThan(0);

    const clear = await fetch(`http://127.0.0.1:${restartedConfig.httpPort}/local/profile`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        userName: "Test Mayor",
        cityName: "Test Town",
        clearProfilePicture: true
      })
    });
    expect(clear.status).toBe(200);
    expect(await clear.json()).toMatchObject({
      ok: true,
      userName: "Test Mayor",
      cityName: "Test Town",
      hasProfilePicture: false
    });
  });

  test("adjusts local money, gold, and xp settings", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-local-resources-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();
    const cashToCoins = loadCashToCoins(path.join(config.assetRoot, "Datas", "rules", "settings.xml"));

    const initial = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources`);
    expect(initial.status).toBe(200);
    expect(await initial.json()).toMatchObject({
      ok: true,
      money: 380000,
      gold: 0,
      xp: 0,
      minXp: 0,
      maxXp: 470,
      companyValue: 720000
    });

    const addMoney = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources/adjust`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ resource: "money", delta: 250 })
    });
    expect(addMoney.status).toBe(200);
    expect(await addMoney.json()).toMatchObject({
      money: 380250,
      companyValue: 720250
    });

    const removeMoney = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources/adjust`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ resource: "money", delta: -1000 })
    });
    expect(removeMoney.status).toBe(200);
    expect(await removeMoney.json()).toMatchObject({
      money: 379250,
      companyValue: 719250
    });

    const addGold = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources/adjust`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ resource: "gold", delta: 75 })
    });
    expect(addGold.status).toBe(200);
    expect(await addGold.json()).toMatchObject({
      gold: 75,
      paidGold: 75,
      companyValue: 719250 + 75 * cashToCoins
    });

    const removeGold = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources/adjust`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ resource: "gold", delta: -100 })
    });
    expect(removeGold.status).toBe(200);
    expect(await removeGold.json()).toMatchObject({
      gold: 0,
      paidGold: 0,
      companyValue: 719250
    });

    const addXp = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources/adjust`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ resource: "xp", delta: 1000 })
    });
    expect(addXp.status).toBe(200);
    const xpResponse = await addXp.json() as Record<string, unknown>;
    expect(xpResponse.xp).toBe(1000);
    expect(Number(xpResponse.level)).toBeGreaterThanOrEqual(1);
    expect(Number(xpResponse.maxXp)).toBeGreaterThan(Number(xpResponse.minXp));

    const removeXp = await fetch(`http://127.0.0.1:${config.httpPort}/local/resources/adjust`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ resource: "xp", delta: -2000 })
    });
    expect(removeXp.status).toBe(200);
    expect(await removeXp.json()).toMatchObject({
      xp: 0,
      level: 1
    });

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const profile = (universe.universe as Array<Record<string, unknown>>).find((entry) =>
      Array.isArray(entry.Profile)
    ) as Record<string, unknown> | undefined;
    expect(profile?.DCCoins).toBe("379250");
    expect(profile?.DCCash).toBe("0");
    expect(profile?.DCCashPaid).toBe("0");
    expect(profile?.companyValue).toBe("719250");
    expect(profile?.exp).toBe("0");
    expect(profile?.level).toBe("1");
  });

  archivedAssetTest("awards a pending house collectible when an eligible level-6 house becomes rent-ready", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-house-collectible-award-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const root = universe.universe as Array<Record<string, unknown>>;
    const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
    const mineCompany = worldContainer.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>>; sid?: string };
    const savedAt = findCollectibleSavedAt("9020", "houses_001_001", "1", true);

    profile.tutorialEnd = "1";
    profile.level = "6";
    mineCompany.Company.push({
      Item: [{ State: [], id: "4" }],
      sid: "9900",
      csid: String(mineCompany.sid ?? "1"),
      sku: "HeadQuarter",
      x: "1",
      y: "1",
      isSuspended: "0"
    });
    mineCompany.Company.push({
      Item: [
        {
          State: [],
          id: "1",
          mode: "4",
          time: "1800000",
          contractSku: "1",
          savedAt
        }
      ],
      sid: "9020",
      csid: String(mineCompany.sid ?? "1"),
      sku: "houses_001_001",
      x: "12",
      y: "8",
      isSuspended: "0"
    });
    serverApp.repository.setDocument(1, "universe", universe);

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);
    const universeAfterLogin = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const worldAfterLogin = (universeAfterLogin.universe as Array<Record<string, unknown>>).find((entry) =>
      Array.isArray(entry.World)
    ) as { World: Array<Record<string, unknown>> };
    const mineAfterLogin = worldAfterLogin.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>> };
    const houseAfterLogin = mineAfterLogin.Company.find((entry: { sid?: string }) => entry.sid === "9020") as
      | { Item?: Array<Record<string, unknown>> }
      | undefined;
    const stateAfterLogin = houseAfterLogin?.Item?.find((entry) => Array.isArray(entry.State)) as
      | Record<string, unknown>
      | undefined;
    if (stateAfterLogin) {
      stateAfterLogin.savedAt = savedAt;
    }
    serverApp.repository.setDocument(1, "universe", universeAfterLogin);

    const mutationData = JSON.stringify({
      _cmdList: [
        {
          _cmd: "update_item",
          _dat: {
            action: "new_mode",
            sid: "9020",
            mode: 5,
            time: 0,
            contractSku: 1
          },
          _cnt: 1
        }
      ],
      _msgCount: 0,
      _sync: 1
    });

    const payload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: mutationData,
      flash_version: "WIN 32,0,0,0",
      sig: signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      )
    });

    const commands = extractCommands(payload);
    expect(commands).toHaveLength(2);
    expect(commands[0]._cmd).toBe("update_item");
    expect(commands[1]._cmd).toBe("update_item");
    expect(commands[1]._dat.action).toBe("give_collectible");
    expect(commands[1]._dat.sid).toBe("9020");
    expect(String(commands[1]._dat.sku)).toMatch(/^gift_/);

    const collectiblesData = JSON.stringify({
      _cmdList: [{ _cmd: "get_collectibles_list", _dat: {}, _cnt: 1 }],
      _msgCount: 0,
      _sync: 1
    });

    const collectiblesPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: collectiblesData,
      flash_version: "WIN 32,0,0,0",
      sig: signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: collectiblesData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      )
    });

    const collectiblesList = extractCommands(collectiblesPayload)[0]._dat;
    const pendingEntry = (collectiblesList.collectiblesList as Array<Record<string, unknown>>).find((entry) =>
      Array.isArray(entry.Pending)
    ) as { tupla?: string } | undefined;

    expect(pendingEntry?.tupla).toContain(`9020:${commands[1]._dat.sku}`);
  });

  test("does not award a house collectible before the level-6 unlock", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-house-collectible-level-gate-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const root = universe.universe as Array<Record<string, unknown>>;
    const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
    const mineCompany = worldContainer.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>>; sid?: string };
    const savedAt = findCollectibleSavedAt("9023", "houses_001_001", "1", true);

    profile.tutorialEnd = "1";
    profile.level = "5";
    mineCompany.Company.push({
      Item: [{ State: [], id: "4" }],
      sid: "9901",
      csid: String(mineCompany.sid ?? "1"),
      sku: "HeadQuarter",
      x: "1",
      y: "1",
      isSuspended: "0"
    });
    mineCompany.Company.push({
      Item: [
        {
          State: [],
          id: "1",
          mode: "4",
          time: "1800000",
          contractSku: "1",
          savedAt
        }
      ],
      sid: "9023",
      csid: String(mineCompany.sid ?? "1"),
      sku: "houses_001_001",
      x: "14",
      y: "8",
      isSuspended: "0"
    });
    serverApp.repository.setDocument(1, "universe", universe);

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const mutationData = JSON.stringify({
      _cmdList: [
        {
          _cmd: "update_item",
          _dat: {
            action: "new_mode",
            sid: "9023",
            mode: 5,
            time: 0,
            contractSku: 1
          },
          _cnt: 1
        }
      ],
      _msgCount: 0,
      _sync: 1
    });

    const payload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: mutationData,
      flash_version: "WIN 32,0,0,0",
      sig: signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      )
    });

    const commands = extractCommands(payload);
    expect(commands).toHaveLength(1);
    expect(commands[0]._cmd).toBe("update_item");
    expect(commands[0]._dat.action).toBe("new_mode");

    const collectiblesList = serverApp.repository.getDocument<Record<string, unknown>>(1, "collectiblesList")
      .collectiblesList as Array<Record<string, unknown>>;
    const pendingEntry = collectiblesList.find((entry) => Array.isArray(entry.Pending)) as { tupla?: string } | undefined;
    expect(pendingEntry?.tupla ?? "").not.toContain("9023:");
  });

  test("does not award a collectible on every completed house contract", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-house-collectible-rarity-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const root = universe.universe as Array<Record<string, unknown>>;
    const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
    const mineCompany = worldContainer.World.find(
      (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
        Array.isArray(entry.Company) && entry.whose === "0"
    ) as { Company: Array<Record<string, unknown>>; sid?: string };
    const savedAt = findCollectibleSavedAt("9024", "houses_001_001", "1", false);

    profile.tutorialEnd = "1";
    profile.level = "6";
    mineCompany.Company.push({
      Item: [{ State: [], id: "4" }],
      sid: "9902",
      csid: String(mineCompany.sid ?? "1"),
      sku: "HeadQuarter",
      x: "1",
      y: "1",
      isSuspended: "0"
    });
    mineCompany.Company.push({
      Item: [
        {
          State: [],
          id: "1",
          mode: "4",
          time: "1800000",
          contractSku: "1",
          savedAt
        }
      ],
      sid: "9024",
      csid: String(mineCompany.sid ?? "1"),
      sku: "houses_001_001",
      x: "15",
      y: "8",
      isSuspended: "0"
    });
    serverApp.repository.setDocument(1, "universe", universe);

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const mutationData = JSON.stringify({
      _cmdList: [
        {
          _cmd: "update_item",
          _dat: {
            action: "new_mode",
            sid: "9024",
            mode: 5,
            time: 0,
            contractSku: 1
          },
          _cnt: 1
        }
      ],
      _msgCount: 0,
      _sync: 1
    });

    const payload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: mutationData,
      flash_version: "WIN 32,0,0,0",
      sig: signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: mutationData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      )
    });

    const commands = extractCommands(payload);
    expect(commands).toHaveLength(1);
    expect(commands[0]._cmd).toBe("update_item");
    expect(commands[0]._dat.action).toBe("new_mode");

    const collectiblesList = serverApp.repository.getDocument<Record<string, unknown>>(1, "collectiblesList")
      .collectiblesList as Array<Record<string, unknown>>;
    const pendingEntry = collectiblesList.find((entry) => Array.isArray(entry.Pending)) as { tupla?: string } | undefined;
    expect(pendingEntry?.tupla ?? "").not.toContain("9024:");
  });

  test("keeps a collected house collectible and clears it from the pending list", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-house-collectible-keep-"));
    const dbPath = path.join(tempDir, "save.sqlite");
    const config = {
      ...getServerConfig(),
      dbPath,
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const collectiblesDocument = createEmptyCollectiblesDocument();
    (collectiblesDocument.collectiblesList as Array<Record<string, unknown>>).find((entry) => Array.isArray(entry.Pending))!.tupla =
      "3021:gift_025";
    serverApp.repository.setDocument(1, "collectiblesList", collectiblesDocument);

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const keepData = JSON.stringify({
      _cmdList: [
        {
          _cmd: "update_collectible",
          _dat: {
            action: "KEEP",
            sid: "3021",
            sku: "gift_025"
          },
          _cnt: 1
        }
      ],
      _msgCount: 0,
      _sync: 1
    });

    await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: keepData,
      flash_version: "WIN 32,0,0,0",
      sig: signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: keepData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      )
    });

    const collectiblesList = serverApp.repository.getDocument<Record<string, unknown>>(1, "collectiblesList")
      .collectiblesList as Array<Record<string, unknown>>;
    const objectsEntry = collectiblesList.find((entry) => Array.isArray(entry.Objects)) as { skus?: string } | undefined;
    const pendingEntry = collectiblesList.find((entry) => Array.isArray(entry.Pending)) as { tupla?: string } | undefined;

    expect(objectsEntry?.skus).toContain("gift_025");
    expect(pendingEntry?.tupla ?? "").not.toContain("3021:gift_025");

    await serverApp.stop();
    activeApps.pop();

    const restartedServerApp = createServerApp({
      ...config
    });
    activeApps.push(restartedServerApp);
    await restartedServerApp.start();

    const restartedCollectiblesList = restartedServerApp.repository.getDocument<Record<string, unknown>>(
      1,
      "collectiblesList"
    ).collectiblesList as Array<Record<string, unknown>>;
    const restartedObjectsEntry = restartedCollectiblesList.find((entry) => Array.isArray(entry.Objects)) as
      | { skus?: string }
      | undefined;
    const restartedPendingEntry = restartedCollectiblesList.find((entry) => Array.isArray(entry.Pending)) as
      | { tupla?: string }
      | undefined;

    expect(restartedObjectsEntry?.skus).toContain("gift_025");
    expect(restartedPendingEntry?.tupla ?? "").not.toContain("3021:gift_025");
  });

  test("persists bought collectible pieces across restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-collectible-buy-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      profile.tutorialEnd = "1";
      profile.DCCash = "100";
      serverApp.repository.setDocument(1, "universe", universe);

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const buyData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_collectible",
            _dat: {
              action: "BUY",
              sid: "-1",
              sku: "gift_057",
              security: {
                cashGain: -3,
                cashNow: 97
              }
            },
            _cnt: 1
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: buyData,
        flash_version: "WIN 32,0,0,0",
        sig: signPayload(
          {
            uid: config.launcherUserId,
            cmd: "cmdList",
            version: "0.501",
            data: buyData,
            flash_version: "WIN 32,0,0,0"
          },
          token
        )
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const collectiblesList = serverApp.repository.getDocument<Record<string, unknown>>(1, "collectiblesList")
        .collectiblesList as Array<Record<string, unknown>>;
      const objectsEntry = collectiblesList.find((entry) => Array.isArray(entry.Objects)) as
        | { skus?: string }
        | undefined;
      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;

      expect(objectsEntry?.skus).toContain("gift_057");
      expect(profile.DCCash).toBe("97");
    }
  });

  archivedAssetTest("persists collectible plane rewards to the profile plane", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-collectible-plane-reward-"));
    const config = {
      ...getServerConfig(),
      dbPath: path.join(tempDir, "save.sqlite"),
      useHttpsFacebookShim: false
    };

    const serverApp = createServerApp(config);
    activeApps.push(serverApp);
    await serverApp.start();

    const loginPayload = await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: "0.501",
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    const token = String(extractCommands(loginPayload)[0]._dat.token);

    const rewardData = JSON.stringify({
      _cmdList: [
        {
          _cmd: "update_collectible",
          _dat: {
            action: "GET_REWARD",
            sku: "2"
          },
          _cnt: 1
        }
      ],
      _msgCount: 0,
      _sync: 1
    });

    await postForm(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "cmdList",
      version: "0.501",
      data: rewardData,
      flash_version: "WIN 32,0,0,0",
      sig: signPayload(
        {
          uid: config.launcherUserId,
          cmd: "cmdList",
          version: "0.501",
          data: rewardData,
          flash_version: "WIN 32,0,0,0"
        },
        token
      )
    });

    const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
    const root = universe.universe as Array<Record<string, unknown>>;
    const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
    const collectiblesList = serverApp.repository.getDocument<Record<string, unknown>>(1, "collectiblesList")
      .collectiblesList as Array<Record<string, unknown>>;
    const rewardsEntry = collectiblesList.find((entry) => Array.isArray(entry.Rewards)) as { skus?: string } | undefined;

    expect(profile.planeSku).toBe("plane_02");
    expect(rewardsEntry?.skus).toContain("2");
  });

  archivedAssetTest("persists collectible HQ skin rewards to the saved headquarters", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-collectible-hq-reward-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      mineCompany.Company.push({
        Item: [
          { State: [], id: "4" },
          {
            Decorations: [
              {
                Decoration: [
                  { sku: [], id: "HeadQuarter_01" },
                  { sku: [], id: "HeadQuarter_02" },
                  { sku: [], id: "HeadQuarter_03" },
                  { sku: [], id: "HeadQuarter_04" }
                ],
                type: "0",
                currentSku: "HeadQuarter_01",
                shadowRows: "0"
              }
            ]
          }
        ],
        sid: "9904",
        csid: String(mineCompany.sid ?? "1"),
        sku: "HeadQuarter",
        x: "1",
        y: "1",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const rewardData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_collectible",
            _dat: {
              action: "GET_REWARD",
              sku: "1"
            },
            _cnt: 1
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: rewardData,
        flash_version: "WIN 32,0,0,0",
        sig: signPayload(
          {
            uid: config.launcherUserId,
            cmd: "cmdList",
            version: "0.501",
            data: rewardData,
            flash_version: "WIN 32,0,0,0"
          },
          token
        )
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const worldContainer = (universe.universe as Array<Record<string, unknown>>).find((entry) =>
        Array.isArray(entry.World)
      ) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>> };
      const hq = mineCompany.Company.find((entry) => entry.sid === "9904") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const decorations = hq?.Item?.find((entry) => Array.isArray(entry.Decorations)) as
        | { Decorations?: Array<Record<string, unknown>> }
        | undefined;
      const skin = decorations?.Decorations?.find((entry) => Array.isArray(entry.Decoration)) as
        | { currentSku?: string; shadowRows?: string }
        | undefined;
      const collectiblesList = serverApp.repository.getDocument<Record<string, unknown>>(1, "collectiblesList")
        .collectiblesList as Array<Record<string, unknown>>;
      const rewardsEntry = collectiblesList.find((entry) => Array.isArray(entry.Rewards)) as
        | { skus?: string }
        | undefined;

      expect(skin?.currentSku).toBe("HeadQuarter_02");
      expect(skin?.shadowRows).toBe("1");
      expect(rewardsEntry?.skus).toContain("1");
    }
  });

  archivedAssetTest("persists item collectible reward claims from reward placement", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-collectible-item-reward-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const profile = (universe.universe as Array<Record<string, unknown>>).find((entry) =>
        Array.isArray(entry.Profile)
      ) as Record<string, unknown>;
      profile.tutorialEnd = "1";
      serverApp.repository.setDocument(1, "universe", universe);

      const collectiblesDocument = createEmptyCollectiblesDocument();
      (collectiblesDocument.collectiblesList as Array<Record<string, unknown>>).find((entry) =>
        Array.isArray(entry.Objects)
      )!.skus = "gift_057,gift_058,gift_059,gift_060";
      serverApp.repository.setDocument(1, "collectiblesList", collectiblesDocument);

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const rewardItemData = JSON.stringify({
        _cmdList: [
          {
            _cmd: "update_item",
            _dat: {
              action: "new_item",
              sid: "8801",
              collectible: "15",
              item: {
                Item: [{ State: [], id: "5" }],
                sid: "8801",
                csid: "1",
                sku: "houses_037_001",
                x: "4",
                y: "5",
                isSuspended: "0"
              },
              dec: "0"
            },
            _cnt: 1
          }
        ],
        _msgCount: 0,
        _sync: 1
      });

      await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: rewardItemData,
        flash_version: "WIN 32,0,0,0",
        sig: signPayload(
          {
            uid: config.launcherUserId,
            cmd: "cmdList",
            version: "0.501",
            data: rewardItemData,
            flash_version: "WIN 32,0,0,0"
          },
          token
        )
      });

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const collectiblesList = serverApp.repository.getDocument<Record<string, unknown>>(1, "collectiblesList")
        .collectiblesList as Array<Record<string, unknown>>;
      const rewardsEntry = collectiblesList.find((entry) => Array.isArray(entry.Rewards)) as
        | { skus?: string }
        | undefined;
      const objectsEntry = collectiblesList.find((entry) => Array.isArray(entry.Objects)) as
        | { skus?: string }
        | undefined;
      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const worldContainer = (universe.universe as Array<Record<string, unknown>>).find((entry) =>
        Array.isArray(entry.World)
      ) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>> };

      expect(rewardsEntry?.skus).toContain("15");
      expect(objectsEntry?.skus).toContain("gift_057");
      expect(mineCompany.Company.some((entry) => entry.sid === "8801" && entry.sku === "houses_037_001")).toBe(true);
    }
  });

  test("projects pending house collectibles back into the world on restart", async () => {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-house-collectible-restart-"));
    const dbPath = path.join(tempDir, "save.sqlite");

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const universe = serverApp.repository.getDocument<Record<string, unknown>>(1, "universe");
      const root = universe.universe as Array<Record<string, unknown>>;
      const profile = root.find((entry) => Array.isArray(entry.Profile)) as Record<string, unknown>;
      const worldContainer = root.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>>; sid?: string };

      profile.tutorialEnd = "1";
      profile.level = "6";
      mineCompany.Company.push({
        Item: [{ State: [], id: "4" }],
        sid: "9903",
        csid: String(mineCompany.sid ?? "1"),
        sku: "HeadQuarter",
        x: "1",
        y: "1",
        isSuspended: "0"
      });
      mineCompany.Company.push({
        Item: [
          {
            State: [],
            id: "1",
            mode: "1",
            time: "0"
          }
        ],
        sid: "9022",
        csid: String(mineCompany.sid ?? "1"),
        sku: "houses_001_001",
        x: "13",
        y: "8",
        isSuspended: "0"
      });
      serverApp.repository.setDocument(1, "universe", universe);

      const collectiblesDocument = createEmptyCollectiblesDocument();
      (collectiblesDocument.collectiblesList as Array<Record<string, unknown>>).find((entry) => Array.isArray(entry.Pending))!.tupla =
        "9022:gift_025";
      serverApp.repository.setDocument(1, "collectiblesList", collectiblesDocument);

      await serverApp.stop();
      activeApps.pop();
    }

    {
      const config = {
        ...getServerConfig(),
        dbPath,
        useHttpsFacebookShim: false
      };

      const serverApp = createServerApp(config);
      activeApps.push(serverApp);
      await serverApp.start();

      const loginPayload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "login",
        version: "0.501",
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      });
      const token = String(extractCommands(loginPayload)[0]._dat.token);

      const worldData = JSON.stringify({
        _cmdList: [{ _cmd: "get_world", _dat: { targetUserId: 1 }, _cnt: 1 }],
        _msgCount: 0,
        _sync: 1
      });

      const payload = await postForm(config.httpPort, {
        uid: config.launcherUserId,
        cmd: "cmdList",
        version: "0.501",
        data: worldData,
        flash_version: "WIN 32,0,0,0",
        sig: signPayload(
          {
            uid: config.launcherUserId,
            cmd: "cmdList",
            version: "0.501",
            data: worldData,
            flash_version: "WIN 32,0,0,0"
          },
          token
        )
      });

      const world = extractCommands(payload)[0]._dat.universe as Array<Record<string, unknown>>;
      const worldContainer = world.find((entry) => Array.isArray(entry.World)) as { World: Array<Record<string, unknown>> };
      const mineCompany = worldContainer.World.find(
        (entry: { Company?: Array<Record<string, unknown>>; whose?: string }) =>
          Array.isArray(entry.Company) && entry.whose === "0"
      ) as { Company: Array<Record<string, unknown>> };
      const house = mineCompany.Company.find((item: { sid?: string }) => item.sid === "9022") as
        | { Item?: Array<Record<string, unknown>> }
        | undefined;
      const state = house?.Item?.find((entry) => Array.isArray(entry.State)) as Record<string, unknown> | undefined;

      expect(state?.id).toBe("1");
      expect(state?.mode).toBe("14");
      expect(state?.time).toBe("0");
    }
  });
});

async function postForm(port: number, form: Record<string, string>): Promise<string> {
  const response = await fetch(`http://127.0.0.1:${port}/Game`, {
    method: "POST",
    headers: {
      "content-type": "application/x-www-form-urlencoded"
    },
    body: new URLSearchParams(form)
  });

  return await response.text();
}

function extractCommands(xml: string): PacketCommand<JsonObject>[] {
  const match =
    xml.match(/<commands><!\[CDATA\[(.*)\]\]><\/commands>/s) ??
    xml.match(/<commands>(.*)<\/commands>/s);

  if (!match) {
    throw new Error(`Could not extract command payload from response: ${xml}`);
  }

  const payload = JSON.parse(match[1]);
  return payload.list as PacketCommand<JsonObject>[];
}

function extractDefinitionTag(xml: string, sku: string): string {
  const match = findDefinitionTag(xml, sku);
  if (!match) {
    throw new Error(`Could not find definition for ${sku}`);
  }
  return match;
}

function findDefinitionTag(xml: string, sku: string): string | undefined {
  const escapedSku = sku.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const match = xml.match(new RegExp(`<Definition\\b(?=[^>]*\\bsku="${escapedSku}")[^>]*/>`));
  return match?.[0];
}

function signPayload(payload: Record<string, string>, token: string): string {
  const serialized = Object.entries(payload)
    .sort(([a], [b]) => a.localeCompare(b, undefined, { sensitivity: "base" }))
    .map(([key, value]) => `${key}=${value}`)
    .join("&");

  return crypto.createHash("md5").update(`${serialized}${token}Host4h`).digest("hex");
}

function extractRoadTiles(worldEntry: { World: Array<Record<string, unknown>> }): Set<string> {
  const mapEntry = worldEntry.World.find((entry) => Array.isArray(entry.Map)) as
    | { Map: Array<Record<string, unknown>> }
    | undefined;
  const roadEntry = mapEntry?.Map.find((entry) => Array.isArray(entry.Road)) as
    | { chunk?: string }
    | undefined;

  return new Set((roadEntry?.chunk ?? "").split(",").filter(Boolean));
}

function getItemsOverlappingRoads(items: Array<Record<string, unknown>>, roadTiles: Set<string>): string[] {
  const overlaps: string[] = [];

  for (const item of items) {
    const sku = String(item.sku ?? "");
    const footprint = getFootprintForSku(sku);
    if (!footprint) {
      continue;
    }

    const startX = Number(item.x ?? 0);
    const startY = Number(item.y ?? 0);
    let isOverlapping = false;

    for (let y = startY; y < startY + footprint.height && !isOverlapping; y += 1) {
      for (let x = startX; x < startX + footprint.width; x += 1) {
        if (roadTiles.has(`${x}:${y}`)) {
          overlaps.push(`${sku}@${startX}:${startY}`);
          isOverlapping = true;
          break;
        }
      }
    }
  }

  return overlaps;
}

function getFootprintForSku(sku: string): { width: number; height: number } | undefined {
  switch (sku) {
    case "HeadQuarter":
      return { width: 4, height: 3 };
    case "commerce_pizza":
    case "houses_002_001":
    case "houses_002_002":
      return { width: 3, height: 3 };
    case "houses_001_002":
    case "decorations_font_02":
      return { width: 2, height: 2 };
    case "decorations_tree_05":
      return { width: 2, height: 1 };
    default:
      return undefined;
  }
}
