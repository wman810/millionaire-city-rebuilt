import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, test } from "vitest";
import { DEFAULT_USER_ID, SAVE_TAGS, type PacketCommand } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { CommandService } from "../src/commandHandlers.js";
import { MCityDatabase } from "../src/database.js";
import { SaveRepository } from "../src/repository.js";
import { findElementChild, getElementChildren, parseChunkSet } from "../src/saveTree.js";

type Fixture = {
  database: MCityDatabase;
  directory: string;
  repository: SaveRepository;
  service: CommandService;
};

const fixtures: Fixture[] = [];

afterEach(() => {
  while (fixtures.length > 0) {
    const fixture = fixtures.pop();
    fixture?.database.close();
    if (fixture) {
      fs.rmSync(fixture.directory, { force: true, recursive: true });
    }
  }
});

describe("original mission and map integrity", () => {
  test("advances missions only through update-driven absent, up, reached, and given states", () => {
    const fixture = createFixture();

    mutate(fixture, "update_profile", { action: "city_name", value: "Exact State City" });
    mutate(fixture, "update_pollmanager", { action: "add", type: "build", parameter: "houses_001_001" });
    mutate(fixture, "update_profile", { action: "tutorial_completed" });
    mutate(fixture, "update_missions", {
      action: "replace",
      sku: "39",
      xml: { Missions: [{ Given: [], chunk: "39" }] }
    });
    expect(readMissionSets(fixture)).toEqual({ up: [], reached: [], given: [] });

    const rewardSecurity = {
      expGain: 10,
      expNow: 10,
      coinsGain: 25,
      coinsNow: 380025,
      cashGain: 0,
      compValueGain: 0
    };
    mutate(fixture, "update_missions", { action: "update", sku: "39", security: rewardSecurity });
    expect(readMissionSets(fixture)).toEqual({ up: ["39"], reached: [], given: [] });
    expect(readProfile(fixture).exp).toBe("0");
    expect(readProfile(fixture).DCCoins).toBe("380000");

    mutate(fixture, "update_missions", { action: "update", sku: "39", security: rewardSecurity });
    expect(readMissionSets(fixture)).toEqual({ up: [], reached: ["39"], given: [] });
    expect(readProfile(fixture).exp).toBe("0");

    mutate(fixture, "update_missions", { action: "update", sku: "39", security: rewardSecurity });
    expect(readMissionSets(fixture)).toEqual({ up: [], reached: [], given: ["39"] });
    expect(readProfile(fixture).exp).toBe("10");
    expect(readProfile(fixture).DCCoins).toBe("380025");

    mutate(fixture, "update_missions", { action: "update", sku: "39", security: rewardSecurity });
    expect(readProfile(fixture).exp).toBe("10");
    expect(readProfile(fixture).DCCoins).toBe("380025");

    mutate(fixture, "update_missions", {
      action: "update",
      sku: "40",
      security: { expGain: -1000, coinsGain: -1000 }
    });
    expect(readMissionSets(fixture)).toEqual({ up: ["40"], reached: [], given: ["39"] });
    expect(readProfile(fixture).exp).toBe("10");
    expect(readProfile(fixture).DCCoins).toBe("380025");

    fixture.repository.ensureDefaultUser();
    expect(readMissionSets(fixture)).toEqual({ up: ["40"], reached: [], given: ["39"] });
    expect(findItemBySku(fixture, "HeadQuarter")).toBeUndefined();
  });

  test("rejects cross-layer duplicates, duplicate adds, nonexistent deletes, and locked plot purchases", () => {
    const fixture = createFixture();
    const initialCoins = String(readProfile(fixture).DCCoins);

    mutate(fixture, "update_map", { action: "add", type: "Road", x: 40, y: 40 });
    expect(readMapSets(fixture).road.has("40:40")).toBe(true);

    const invalidSecurity = { coinsGain: 500, coinsNow: Number(initialCoins) + 500 };
    mutate(fixture, "update_map", {
      action: "add",
      type: "Road",
      x: 40,
      y: 40,
      security: invalidSecurity
    });
    mutate(fixture, "update_map", {
      action: "add",
      type: "Terrain",
      x: 40,
      y: 40,
      security: invalidSecurity
    });
    mutate(fixture, "update_map", {
      action: "del",
      type: "Road",
      x: 41,
      y: 41,
      security: invalidSecurity
    });
    mutate(fixture, "update_map", {
      action: "add",
      type: "Terrain",
      x: "not-an-integer",
      y: 41,
      security: invalidSecurity
    });
    expect(readProfile(fixture).DCCoins).toBe(initialCoins);
    expect(readMapSets(fixture).road.has("40:40")).toBe(true);
    expect(readMapSets(fixture).terrain.has("40:40")).toBe(false);

    mutate(fixture, "update_map", { action: "del", type: "Road", x: 40, y: 40 });
    expect(readMapSets(fixture).road.has("40:40")).toBe(false);

    const beforePlots = String(readPlots(fixture).type ?? "");
    mutate(fixture, "update_plots", { action: "bought", index: 12, security: invalidSecurity });
    expect(readPlots(fixture).type).toBe(beforePlots);
    expect(readProfile(fixture).DCCoins).toBe(initialCoins);

    mutate(fixture, "update_plots", { action: "bought", index: 7 });
    const states = String(readPlots(fixture).type).split(",").map(Number);
    expect(states[7]).toBe(2);
    expect(states[12]).toBe(2);
  });

  test("creates missing items only for new_item and restores automatic and rival-sale footprints", () => {
    const fixture = createFixture();

    mutate(fixture, "update_item", {
      action: "build",
      sid: "9900",
      sku: "houses_001_001",
      x: 40,
      y: 40,
      state: 5
    });
    expect(findItemBySid(fixture, "9900")).toBeUndefined();

    mutate(fixture, "update_item", {
      action: "new_item",
      sid: "9901",
      sku: "houses_001_001",
      autoPlots: "1",
      item: {
        Item: [{ State: [], id: "5" }],
        sid: "9901",
        csid: "1",
        sku: "houses_001_001",
        x: "40",
        y: "40",
        isSuspended: "0"
      }
    });
    const automaticFootprint = readMapSets(fixture).terrain;
    expect(["40:40", "41:40", "40:41", "41:41"].every((tile) => automaticFootprint.has(tile))).toBe(true);

    mutate(fixture, "update_map", { action: "add", type: "Road", x: 51, y: 50 });
    mutate(fixture, "update_item", {
      action: "new_item",
      sid: "9902",
      sku: "houses_001_001",
      autoPlots: "1",
      item: {
        Item: [{ State: [], id: "5" }],
        sid: "9902",
        csid: "1",
        sku: "houses_001_001",
        x: "50",
        y: "50",
        isSuspended: "0"
      }
    });
    const partiallyBlockedFootprint = readMapSets(fixture);
    expect(partiallyBlockedFootprint.road.has("51:50")).toBe(true);
    expect(partiallyBlockedFootprint.terrain.has("51:50")).toBe(false);
    expect(["50:50", "50:51", "51:51"].every((tile) => partiallyBlockedFootprint.terrain.has(tile))).toBe(true);

    const rivalPizza = findCompany(fixture, "1").Company.find((item) => item.sku === "commerce_pizza");
    expect(rivalPizza).toBeTruthy();
    const rivalSid = String(rivalPizza?.sid ?? "");
    mutate(fixture, "update_item", { action: "new_mode", sid: rivalSid, mode: 3, time: 0 });
    mutate(fixture, "update_item", { action: "new_mode", sid: rivalSid, csid: "1", mode: 4, time: 0 });

    const rivalFootprint = readMapSets(fixture).terrain;
    for (let y = -3; y <= -1; y += 1) {
      for (let x = -7; x <= -5; x += 1) {
        expect(rivalFootprint.has(`${x}:${y}`)).toBe(true);
      }
    }
    expect(findCompany(fixture, "1").Company.some((item) => item.sid === rivalSid)).toBe(false);
    expect(findCompany(fixture, "0").Company.some((item) => item.sid === rivalSid)).toBe(true);
  });
});

function createFixture(): Fixture {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-mission-map-integrity-"));
  const database = new MCityDatabase(path.join(directory, "save.sqlite"));
  const repository = new SaveRepository(database);
  repository.ensureDefaultUser();
  const fixture = {
    database,
    directory,
    repository,
    service: new CommandService(repository)
  };
  fixtures.push(fixture);
  return fixture;
}

function mutate(fixture: Fixture, command: string, data: JsonObject): void {
  fixture.service.handleCommand(DEFAULT_USER_ID, {
    _cmd: command,
    _dat: data,
    _sync: 1
  } as PacketCommand);
}

function readUniverse(fixture: Fixture): JsonObject {
  return fixture.repository.getDocument<JsonObject>(DEFAULT_USER_ID, SAVE_TAGS.universe);
}

function readProfile(fixture: Fixture): JsonObject {
  const profile = getRoot(readUniverse(fixture)).find((entry) => Array.isArray(entry.Profile));
  if (!profile) {
    throw new Error("Profile missing from test universe.");
  }
  return profile;
}

function readMissionSets(fixture: Fixture): { up: string[]; reached: string[]; given: string[] } {
  const profile = readProfile(fixture);
  const missions = getElementChildren(profile, "Profile").find((entry) => Array.isArray(entry.Missions));
  const children = missions ? getElementChildren(missions, "Missions") : [];
  return {
    up: [...parseChunkSet(findElementChild(children, "Up"))],
    reached: [...parseChunkSet(findElementChild(children, "Reached"))],
    given: [...parseChunkSet(findElementChild(children, "Given"))]
  };
}

function readMapSets(fixture: Fixture): { terrain: Set<string>; road: Set<string> } {
  const world = getWorld(fixture);
  const map = world.find((entry) => Array.isArray(entry.Map));
  if (!map) {
    throw new Error("Map missing from test universe.");
  }
  const children = getElementChildren(map, "Map");
  return {
    terrain: parseChunkSet(findElementChild(children, "Terrain")),
    road: parseChunkSet(findElementChild(children, "Road"))
  };
}

function readPlots(fixture: Fixture): JsonObject {
  const plots = getElementChildren(readProfile(fixture), "Profile").find((entry) => Array.isArray(entry.Plots));
  if (!plots) {
    throw new Error("Plots missing from test universe.");
  }
  return plots;
}

function findCompany(fixture: Fixture, whose: string): JsonObject & { Company: JsonObject[] } {
  const company = getWorld(fixture).find(
    (entry) => Array.isArray(entry.Company) && String(entry.whose ?? "") === whose
  );
  if (!company) {
    throw new Error(`Company ${whose} missing from test universe.`);
  }
  return company as JsonObject & { Company: JsonObject[] };
}

function findItemBySid(fixture: Fixture, sid: string): JsonObject | undefined {
  return getWorld(fixture)
    .filter((entry) => Array.isArray(entry.Company))
    .flatMap((entry) => entry.Company as JsonObject[])
    .find((entry) => String(entry.sid ?? "") === sid);
}

function findItemBySku(fixture: Fixture, sku: string): JsonObject | undefined {
  return getWorld(fixture)
    .filter((entry) => Array.isArray(entry.Company))
    .flatMap((entry) => entry.Company as JsonObject[])
    .find((entry) => String(entry.sku ?? "") === sku);
}

function getWorld(fixture: Fixture): JsonObject[] {
  const world = getRoot(readUniverse(fixture)).find((entry) => Array.isArray(entry.World));
  if (!world) {
    throw new Error("World missing from test universe.");
  }
  return getElementChildren(world, "World");
}

function getRoot(universe: JsonObject): JsonObject[] {
  if (!Array.isArray(universe.universe)) {
    throw new Error("Universe root missing from test document.");
  }
  return universe.universe as JsonObject[];
}
