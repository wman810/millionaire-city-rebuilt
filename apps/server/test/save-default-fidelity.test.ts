import { describe, expect, test } from "vitest";
import { SAVE_TAGS } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { findElementChild, getElementChildren } from "../src/saveTree.js";
import { createNeighborUniverse } from "../src/saveDefaults/neighbors.js";
import {
  createFreshSaveBundle,
  normalizeDailyBonusDefaults,
  normalizeWelcomeDefaults
} from "../src/saveDefaults/starter.js";
import {
  normalizeConstructionState,
  normalizeHouseRentState,
  normalizeOfflineTimerState
} from "../src/saveDefaults/timers.js";

describe("recovered save-default fidelity", () => {
  test("uses the exact recovered 0.338 starter geometry without changing 0.501 targets", () => {
    const original = createFreshSaveBundle("test-user", "original");
    const current = createFreshSaveBundle("test-user", "current");
    const originalRoot = getRoot(original[SAVE_TAGS.universe]);
    const currentRoot = getRoot(current[SAVE_TAGS.universe]);
    const originalProfile = getProfile(originalRoot);
    const currentProfile = getProfile(currentRoot);
    const originalWorld = getWorld(originalRoot);
    const currentWorld = getWorld(currentRoot);
    const originalMine = getCompany(originalWorld, "0");
    const currentMine = getCompany(currentWorld, "0");
    const originalRival = getCompany(originalWorld, "1");
    const originalMap = getMap(originalWorld);
    const currentMap = getMap(currentWorld);

    expect(originalProfile).toMatchObject({ exp: "0", DCCoins: "200000", DCCash: "2", companyValue: "660000" });
    expect(currentProfile).toMatchObject({ exp: "0", DCCoins: "380000", DCCash: "0", companyValue: "720000" });
    expect(getPlots(originalProfile)?.type).toBe(
      "0,0,0,0,0,0,0,1,0,0,0,1,2,1,0,0,0,1,0,0,0,0,0,0,0"
    );
    expect(getPlots(currentProfile)?.type).toBe("");
    expect(originalMine.Company).toHaveLength(67);
    expect(currentMine.Company).toHaveLength(67);
    expect(originalMine.Company).toEqual(expect.arrayContaining([
      expect.objectContaining({ sid: "264", sku: "decorations_tree_03", x: "29", y: "-27" }),
      expect.objectContaining({ sid: "258", sku: "decorations_tree_03", x: "33", y: "-14" }),
      expect.objectContaining({ sid: "267", sku: "decorations_tree_03", x: "28", y: "13" }),
      expect.objectContaining({ sid: "272", sku: "decorations_tree_03", x: "28", y: "18" }),
      expect.objectContaining({ sid: "265", sku: "decorations_tree_03", x: "32", y: "11" }),
      expect.objectContaining({ sid: "303", sku: "decorations_tree_01", x: "-2", y: "21" })
    ]));
    expect(currentMine.Company).toEqual(expect.arrayContaining([
      expect.objectContaining({ sid: "264", sku: "decorations_tree_03", x: "29", y: "-27" }),
      expect.objectContaining({ sid: "258", sku: "decorations_tree_03", x: "33", y: "-14" }),
      expect.objectContaining({ sid: "267", sku: "decorations_tree_03", x: "28", y: "13" }),
      expect.objectContaining({ sid: "272", sku: "decorations_tree_03", x: "28", y: "18" }),
      expect.objectContaining({ sid: "265", sku: "decorations_tree_03", x: "32", y: "11" }),
      expect.objectContaining({ sid: "303", sku: "decorations_tree_01", x: "-2", y: "21" })
    ]));
    expect(originalRival.Company.map((item) => [item.sid, item.sku, item.x, item.y])).toEqual([
      ["245", "houses_002_001", "-4", "1"],
      ["246", "houses_001_002", "-13", "1"],
      ["247", "commerce_pizza", "-7", "-3"],
      ["248", "houses_002_002", "9", "-3"]
    ]);
    expect(getChunk(originalMap, "Terrain")).toHaveLength(14);
    expect(getChunk(originalMap, "Road")).toHaveLength(29);
    expect(getChunk(currentMap, "Terrain")).toHaveLength(14);
    expect(getChunk(currentMap, "Road")).toHaveLength(29);
  });

  test("backfills ancillary defaults without overwriting existing progress", () => {
    const bundle = createFreshSaveBundle();
    expect(bundle[SAVE_TAGS.dailyBonus]).toMatchObject({
      dailyRewardsCount: "0",
      dailyRewardsLastGiven: "",
      dailyRewardsLastGivenDate: "0",
      dailyRewardsNextRewardId: ""
    });
    expect(bundle[SAVE_TAGS.welcome]).toMatchObject({
      allItemsUnlockables: "1",
      npcSheikTimeLeft: "100000",
      npcCindyTimeLeft: "100000",
      npcRonaldTimeLeft: "100000"
    });

    const oldDaily: JsonObject = { dailyBonusInfo: [], dailyRewardsCount: "4" };
    const oldWelcome: JsonObject = { welcome: [], vip: "1", npcRonaldTimeLeft: "25" };
    expect(normalizeDailyBonusDefaults(oldDaily)).toBe(true);
    expect(normalizeWelcomeDefaults(oldWelcome)).toBe(true);
    expect(oldDaily.dailyRewardsCount).toBe("4");
    expect(oldWelcome.vip).toBe("1");
    expect(oldWelcome.npcRonaldTimeLeft).toBe("25");
    expect(normalizeDailyBonusDefaults(oldDaily)).toBe(false);
    expect(normalizeWelcomeDefaults(oldWelcome)).toBe(false);
  });

  test("reconciles every recovered timer state, clamps at zero, and skips suspended items", () => {
    for (let id = 0; id <= 6; id += 1) {
      const state: JsonObject = { State: [], id: String(id), time: "1000", savedAt: "1000" };
      expect(normalizeOfflineTimerState(state, 1600)).toBe(true);
      expect(state).toMatchObject({ id: String(id), time: "400", savedAt: "1600" });
    }

    const unsupported: JsonObject = { State: [], id: "7", time: "1000", savedAt: "1000" };
    const suspended: JsonObject = { State: [], id: "2", time: "1000", savedAt: "1000" };
    const negative: JsonObject = { State: [], id: "3", time: "-50", savedAt: "1000" };
    const legacy: JsonObject = { State: [], id: "4", time: "1000" };
    expect(normalizeOfflineTimerState(unsupported, 1600)).toBe(false);
    expect(normalizeOfflineTimerState(suspended, 1600, true)).toBe(false);
    expect(normalizeOfflineTimerState(negative, 1600)).toBe(true);
    expect(normalizeOfflineTimerState(legacy, 1600)).toBe(true);
    expect(unsupported.time).toBe("1000");
    expect(suspended).toMatchObject({ time: "1000", savedAt: "1000" });
    expect(negative.time).toBe("0");
    expect(legacy).toMatchObject({ time: "1000", savedAt: "1600" });

    const construction: JsonObject = { State: [], id: "0", time: "500", savedAt: "1000" };
    expect(normalizeConstructionState("houses_001_001", construction, 1600)).toBe(true);
    expect(construction.time).toBe("0");

    const houseChildren: JsonObject[] = [];
    const house: JsonObject = {
      State: [], id: "1", mode: "4", time: "1000", savedAt: "1000", contractSku: "1"
    };
    houseChildren.push(house);
    expect(normalizeHouseRentState(house, houseChildren, 1600)).toBe(true);
    expect(house).toMatchObject({ id: "1", mode: "4", time: "400", savedAt: "1600", contractSku: "1" });
  });

  test("preserves recovered NPC profile metadata while applying local identities", () => {
    const cindy = createNeighborUniverse(100, 1);
    const ronald = createNeighborUniverse(100, 0);
    const sheik = createNeighborUniverse(101, 0);
    expect(cindy).toBeDefined();
    expect(ronald).toBeDefined();
    expect(sheik).toBeDefined();

    const cindyRoot = getRoot(cindy as JsonObject);
    const ronaldRoot = getRoot(ronald as JsonObject);
    const sheikRoot = getRoot(sheik as JsonObject);
    const cindyProfile = getProfile(cindyRoot);
    const sheikProfile = getProfile(sheikRoot);
    expect(cindyProfile).toMatchObject({
      exp: "1219814249",
      DCCoins: "52769",
      DCCash: "7887056",
      companyValue: "474611291791",
      ranking: "10",
      planeSku: "plane_03",
      flags: "stopFirstSessionPopups:1,",
      userName: "Cindy",
      profileId: "100",
      extId: "npc-cindy"
    });
    expect(getPlots(cindyProfile)?.type).toBe("2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2");
    expect(sheikProfile).toMatchObject({
      exp: "2394230",
      DCCoins: "33599",
      DCCash: "137",
      cityname: "Sheik`s City",
      companyValue: "660944599",
      ranking: "9",
      userName: "Sheik",
      profileId: "101",
      extId: "npc-sheik"
    });

    expect(getItems(getWorld(cindyRoot)).some((item) => item.sku === "wonder_npc_Cindy")).toBe(true);
    expect(getItems(getWorld(cindyRoot)).some((item) => item.sku === "wonder_npc_Ronald")).toBe(false);
    expect(getItems(getWorld(ronaldRoot)).some((item) => item.sku === "wonder_npc_Ronald")).toBe(true);
  });
});

function getRoot(document: JsonObject): JsonObject[] {
  expect(Array.isArray(document.universe)).toBe(true);
  return document.universe as JsonObject[];
}

function getProfile(root: JsonObject[]): JsonObject {
  const profile = root.find((entry) => Array.isArray(entry.Profile));
  expect(profile).toBeDefined();
  return profile as JsonObject;
}

function getPlots(profile: JsonObject): JsonObject | undefined {
  return findElementChild(getElementChildren(profile, "Profile"), "Plots");
}

function getWorld(root: JsonObject[]): JsonObject {
  const world = root.find((entry) => Array.isArray(entry.World));
  expect(world).toBeDefined();
  return world as JsonObject;
}

function getCompany(world: JsonObject, whose: string): JsonObject & { Company: JsonObject[] } {
  const company = getElementChildren(world, "World").find(
    (entry) => Array.isArray(entry.Company) && String(entry.whose ?? "") === whose
  );
  expect(company).toBeDefined();
  return company as JsonObject & { Company: JsonObject[] };
}

function getMap(world: JsonObject): JsonObject {
  const map = findElementChild(getElementChildren(world, "World"), "Map");
  expect(map).toBeDefined();
  return map as JsonObject;
}

function getChunk(map: JsonObject, tagName: string): string[] {
  const entry = findElementChild(getElementChildren(map, "Map"), tagName);
  return String(entry?.chunk ?? "").split(",").filter(Boolean);
}

function getItems(world: JsonObject): JsonObject[] {
  return getElementChildren(world, "World")
    .filter((entry) => Array.isArray(entry.Company))
    .flatMap((entry) => entry.Company as JsonObject[]);
}
