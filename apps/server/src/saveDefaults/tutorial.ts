import fs from "fs";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { loadLevelXpThresholds, parseXmlAttributes } from "../rules.js";
import {
  createElement,
  findElementChild,
  getElementChildren,
  getOrCreateElementChild,
  leafElement,
  parseChunkSet,
  upsertChunkElement
} from "../saveTree.js";
import {
  COMPLETED_MISSION_POLL_RULES,
  DEFAULT_CITY_NAME,
  STALE_TUTORIAL_POLL_MISSION_SKUS,
  STARTER_COMPANY_MINE_SID,
  TUTORIAL_COMPLETED_HOUSE_TILE,
  TUTORIAL_COMPLETED_HQ_TILE,
  TUTORIAL_COMPLETED_INITIAL_MISSIONS,
  TUTORIAL_COMPLETED_ROAD_TILES,
  TUTORIAL_COMPLETED_TERRAIN_TILES,
  TUTORIAL_COMPLETED_TREE_TILE,
  UNLOCKED_MISSION_RULES
} from "./constants.js";
import {
  MISSION_DEFINITIONS_PATH,
  XP_TABLE_PATH
} from "./paths.js";
import {
  createBuiltItem,
  createHeadQuarterDecorations,
  createHeadQuarterItem,
  createWaitingContractHouseItem,
  getNextItemSid,
  isHouseSku,
  isItemElement
} from "./items.js";
import { normalizeConstructionState, normalizeHouseRentState } from "./timers.js";

type PollMissionRule = {
  sku: string;
  unlockSku: string;
  unlockLevel: number;
  eventSku: string;
  eventAmount: number;
  conditionIndex: number;
  showInAbTest: boolean;
};

const POLL_MISSION_RULES = loadPollMissionRules(MISSION_DEFINITIONS_PATH);
const LEVEL_XP_THRESHOLDS = loadLevelXpThresholds(XP_TABLE_PATH);

export function normalizeCompletedTutorialUniverse(document: JsonObject, nowMs = Date.now()): boolean {
  const profile = getProfileElement(document);
  const mineCompany = getCompanyElement(document, "0");
  const rivalCompany = getCompanyElement(document, "1");
  const mapElement = getMapElement(document);

  if (!profile || !mineCompany || !mapElement || String(profile.tutorialEnd ?? "0") !== "1") {
    return false;
  }

  const mineItems = getElementChildren(mineCompany, "Company");
  const rivalItems = rivalCompany ? getElementChildren(rivalCompany, "Company") : [];
  const terrainTiles = parseChunkSet(findElementChild(getElementChildren(mapElement, "Map"), "Terrain"));
  const roadTiles = parseChunkSet(findElementChild(getElementChildren(mapElement, "Map"), "Road"));
  const hasHeadQuarter = mineItems.some((entry) => isItemElement(entry) && String(entry.sku ?? "") === "HeadQuarter");
  const needsStarterCashRepair = String(profile.DCCash ?? "") === "50" && Number(profile.companyValue ?? "0") < 1_000_000;
  const needsTutorialRepair = !hasHeadQuarter;

  let changed = false;
  changed = ensureCompletedTutorialMissionState(profile) || changed;
  changed = normalizeReachedPollMissionState(profile) || changed;
  changed = settleStaleTutorialPollMissions(profile) || changed;
  changed = migrateBoughtRivalItemsToMine(rivalItems, mineItems, String(mineCompany.sid ?? STARTER_COMPANY_MINE_SID)) || changed;
  changed = repairLegacyTutorialBungalowDuplicate(mineItems, nowMs) || changed;
  changed = normalizeTimedItemStates(mineItems, nowMs) || changed;

  if (needsStarterCashRepair) {
    profile.DCCash = "0";
    changed = true;
  }

  if (!needsTutorialRepair) {
    return changed;
  }

  changed =
    ensureTutorialItem(
      mineItems,
      String(mineCompany.sid ?? STARTER_COMPANY_MINE_SID),
      "HeadQuarter",
      TUTORIAL_COMPLETED_HQ_TILE.x,
      TUTORIAL_COMPLETED_HQ_TILE.y
    ) || changed;
  changed =
    ensureTutorialItem(
      mineItems,
      String(mineCompany.sid ?? STARTER_COMPANY_MINE_SID),
      "houses_001_001",
      TUTORIAL_COMPLETED_HOUSE_TILE.x,
      TUTORIAL_COMPLETED_HOUSE_TILE.y
    ) || changed;
  changed =
    ensureTutorialItem(
      mineItems,
      String(mineCompany.sid ?? STARTER_COMPANY_MINE_SID),
      "decorations_tree_01",
      TUTORIAL_COMPLETED_TREE_TILE.x,
      TUTORIAL_COMPLETED_TREE_TILE.y
    ) || changed;

  for (const tile of TUTORIAL_COMPLETED_TERRAIN_TILES) {
    if (!terrainTiles.has(tile)) {
      terrainTiles.add(tile);
      changed = true;
    }
  }

  for (const tile of TUTORIAL_COMPLETED_ROAD_TILES) {
    if (!roadTiles.has(tile)) {
      roadTiles.add(tile);
      changed = true;
    }
  }

  const mapChildren = getElementChildren(mapElement, "Map");
  upsertChunkElement(mapChildren, "Terrain", terrainTiles);
  upsertChunkElement(mapChildren, "Road", roadTiles);
  return changed;
}

function getProfileElement(document: JsonObject): JsonObject | undefined {
  const universe = document.universe;
  if (!Array.isArray(universe)) {
    return undefined;
  }

  return universe.find(
    (entry): entry is JsonObject =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Profile?: unknown }).Profile))
  );
}

function getCompanyElement(document: JsonObject, whose: string): JsonObject | undefined {
  const worldChildren = getWorldChildren(document);
  if (!worldChildren) {
    return undefined;
  }

  return worldChildren.find(
    (entry): entry is JsonObject =>
      Boolean(
        entry &&
          typeof entry === "object" &&
          Array.isArray((entry as { Company?: unknown }).Company) &&
          String((entry as { whose?: unknown }).whose ?? "") === whose
      )
  );
}

function getMapElement(document: JsonObject): JsonObject | undefined {
  const worldChildren = getWorldChildren(document);
  if (!worldChildren) {
    return undefined;
  }

  return worldChildren.find(
    (entry): entry is JsonObject =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Map?: unknown }).Map))
  );
}

function getWorldChildren(document: JsonObject): JsonObject[] | undefined {
  const universe = document.universe;
  if (!Array.isArray(universe)) {
    return undefined;
  }

  const worldElement = universe.find(
    (entry): entry is JsonObject =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { World?: unknown }).World))
  );
  if (!worldElement) {
    return undefined;
  }

  return getElementChildren(worldElement, "World");
}

function parseCountChunkMap(entry: JsonObject | undefined): Map<string, number> {
  const counts = new Map<string, number>();
  if (!entry || typeof entry.chunk !== "string" || entry.chunk.length === 0) {
    return counts;
  }

  for (const part of entry.chunk.split(",")) {
    if (part.length === 0) {
      continue;
    }

    const separator = part.lastIndexOf("/");
    if (separator === -1) {
      continue;
    }

    const key = part.slice(0, separator);
    const value = Number(part.slice(separator + 1));
    if (key.length > 0 && Number.isFinite(value)) {
      counts.set(key, value);
    }
  }

  return counts;
}

function markMissionAsGiven(sku: string, up: Set<string>, reached: Set<string>, given: Set<string>): boolean {
  const alreadyGiven = given.has(sku);
  const removedFromUp = up.delete(sku);
  const removedFromReached = reached.delete(sku);
  if (!alreadyGiven) {
    given.add(sku);
  }
  return !alreadyGiven || removedFromUp || removedFromReached;
}

function ensureCompletedTutorialMissionState(profile: JsonObject): boolean {
  const profileChildren = getElementChildren(profile, "Profile");
  const missionsEntry = getOrCreateElementChild(profileChildren, "Missions");
  const missionChildren = getElementChildren(missionsEntry, "Missions");
  const up = parseChunkSet(findElementChild(missionChildren, "Up"));
  const reached = parseChunkSet(findElementChild(missionChildren, "Reached"));
  const given = parseChunkSet(findElementChild(missionChildren, "Given"));
  let changed = false;

  if (up.size === 0 && reached.size === 0 && given.size === 0) {
    for (const sku of TUTORIAL_COMPLETED_INITIAL_MISSIONS) {
      up.add(sku);
    }
    upsertChunkElement(missionChildren, "Up", up);
    upsertChunkElement(missionChildren, "Reached", reached);
    upsertChunkElement(missionChildren, "Given", given);
    changed = true;
  }

  const pollManagerEntry = getOrCreateElementChild(profileChildren, "PollManager");
  const pollChildren = getElementChildren(pollManagerEntry, "PollManager");
  let countEntry = findElementChild(pollChildren, "Count");
  if (!countEntry) {
    countEntry = createElement("Count", { chunk: "" });
    pollChildren.push(countEntry);
    changed = true;
  }

  const counts = parseCountChunkMap(countEntry);
  if (
    typeof profile.cityname === "string" &&
    profile.cityname.trim().length > 0 &&
    profile.cityname !== DEFAULT_CITY_NAME
  ) {
    changed = markMissionAsGiven("1", up, reached, given) || changed;
  }

  for (const rule of COMPLETED_MISSION_POLL_RULES) {
    if ((counts.get(rule.countKey) ?? 0) >= rule.minCount) {
      changed = markMissionAsGiven(rule.sku, up, reached, given) || changed;
    }
  }

  if (given.has("1") && String(profile.firstMission ?? "0") !== "0") {
    profile.firstMission = "0";
    changed = true;
  }

  if (given.size === 0 && String(profile.firstMission ?? "0") !== "1") {
    profile.firstMission = "1";
    changed = true;
  }

  for (const rule of UNLOCKED_MISSION_RULES) {
    if (given.has(rule.requiredSku) && !given.has(rule.sku) && !reached.has(rule.sku) && !up.has(rule.sku)) {
      up.add(rule.sku);
      changed = true;
    }
  }

  upsertChunkElement(missionChildren, "Up", up);
  upsertChunkElement(missionChildren, "Reached", reached);
  upsertChunkElement(missionChildren, "Given", given);
  return changed;
}

function normalizeReachedPollMissionState(profile: JsonObject): boolean {
  const profileChildren = getElementChildren(profile, "Profile");
  const missionsEntry = getOrCreateElementChild(profileChildren, "Missions");
  const missionChildren = getElementChildren(missionsEntry, "Missions");
  const up = parseChunkSet(findElementChild(missionChildren, "Up"));
  const reached = parseChunkSet(findElementChild(missionChildren, "Reached"));
  const given = parseChunkSet(findElementChild(missionChildren, "Given"));
  const pollManagerEntry = getOrCreateElementChild(profileChildren, "PollManager");
  const pollChildren = getElementChildren(pollManagerEntry, "PollManager");
  const counts = parseCountChunkMap(findElementChild(pollChildren, "Count"));
  const level = getProfileLevel(profile);

  let changed = false;
  for (const rule of POLL_MISSION_RULES) {
    if (rule.showInAbTest || given.has(rule.sku)) {
      continue;
    }

    const unlockSatisfied = isMissionUnlockSatisfied(rule, reached, given, level);
    if (!unlockSatisfied && up.delete(rule.sku)) {
      changed = true;
    }

    if (!reached.has(rule.sku)) {
      continue;
    }

    reached.delete(rule.sku);
    changed = true;

    if (unlockSatisfied && isPollMissionSatisfied(rule, counts)) {
      if (!up.has(rule.sku)) {
        up.add(rule.sku);
      }
    }
  }

  if (changed) {
    upsertChunkElement(missionChildren, "Up", up);
    upsertChunkElement(missionChildren, "Reached", reached);
    upsertChunkElement(missionChildren, "Given", given);
  }

  return changed;
}

function settleStaleTutorialPollMissions(profile: JsonObject): boolean {
  const profileChildren = getElementChildren(profile, "Profile");
  const missionsEntry = getOrCreateElementChild(profileChildren, "Missions");
  const missionChildren = getElementChildren(missionsEntry, "Missions");
  const up = parseChunkSet(findElementChild(missionChildren, "Up"));
  const reached = parseChunkSet(findElementChild(missionChildren, "Reached"));
  const given = parseChunkSet(findElementChild(missionChildren, "Given"));
  const pollManagerEntry = getOrCreateElementChild(profileChildren, "PollManager");
  const pollChildren = getElementChildren(pollManagerEntry, "PollManager");
  const counts = parseCountChunkMap(findElementChild(pollChildren, "Count"));
  const level = getProfileLevel(profile);

  let changed = false;
  let madeProgress = true;
  while (madeProgress) {
    madeProgress = false;
    for (const rule of POLL_MISSION_RULES) {
      if (!STALE_TUTORIAL_POLL_MISSION_SKUS.has(rule.sku) || rule.showInAbTest || given.has(rule.sku)) {
        continue;
      }
      if (!isMissionUnlockSatisfied(rule, reached, given, level)) {
        continue;
      }
      if (!isPollMissionSatisfied(rule, counts)) {
        continue;
      }
      if (markMissionAsGiven(rule.sku, up, reached, given)) {
        changed = true;
        madeProgress = true;
      }
    }
  }

  if (changed) {
    upsertChunkElement(missionChildren, "Up", up);
    upsertChunkElement(missionChildren, "Reached", reached);
    upsertChunkElement(missionChildren, "Given", given);
  }

  return changed;
}

function isMissionUnlockSatisfied(rule: PollMissionRule, reached: Set<string>, given: Set<string>, level: number): boolean {
  if (rule.unlockSku.length > 0 && !reached.has(rule.unlockSku) && !given.has(rule.unlockSku)) {
    return false;
  }
  if (rule.unlockLevel > 0 && Number.isFinite(level) && level > 0 && level < rule.unlockLevel) {
    return false;
  }
  return true;
}

function getProfileLevel(profile: JsonObject): number {
  const explicitLevel = Number(profile.level ?? "");
  if (Number.isFinite(explicitLevel) && explicitLevel >= 1) {
    return Math.floor(explicitLevel);
  }

  const exp = Number(profile.exp ?? "0");
  if (!Number.isFinite(exp) || exp < 0 || LEVEL_XP_THRESHOLDS.length === 0) {
    return 1;
  }

  let level = 0;
  while (level < LEVEL_XP_THRESHOLDS.length) {
    if (exp < LEVEL_XP_THRESHOLDS[level]) {
      return Math.max(1, level);
    }
    level += 1;
  }

  return Math.max(1, LEVEL_XP_THRESHOLDS.length);
}

function isPollMissionSatisfied(rule: PollMissionRule, counts: Map<string, number>): boolean {
  const progress = counts.get(rule.eventSku) ?? 0;
  if (!Number.isFinite(progress) || progress <= 0) {
    return false;
  }
  if (rule.conditionIndex >= 0) {
    return progress > rule.conditionIndex;
  }
  return progress >= rule.eventAmount;
}

function ensureTutorialItem(
  items: JsonObject[],
  companySid: string,
  sku: string,
  x: string,
  y: string
): boolean {
  const existing = items.find((entry) => isItemElement(entry) && String(entry.sku ?? "") === sku);
  if (!existing) {
    const nextSid = String(getNextItemSid(items));
    if (sku === "HeadQuarter") {
      items.push(createHeadQuarterItem(nextSid, companySid, x, y));
    } else if (isHouseSku(sku)) {
      items.push(createWaitingContractHouseItem(nextSid, companySid, sku, x, y));
    } else {
      items.push(createBuiltItem(nextSid, companySid, sku, x, y));
    }
    return true;
  }

  let changed = false;
  if (String(existing.x ?? "") !== x) {
    existing.x = x;
    changed = true;
  }
  if (String(existing.y ?? "") !== y) {
    existing.y = y;
    changed = true;
  }
  if (String(existing.csid ?? "") !== companySid) {
    existing.csid = companySid;
    changed = true;
  }
  if (String(existing.isSuspended ?? "") !== "0") {
    existing.isSuspended = "0";
    changed = true;
  }

  const itemChildren = getElementChildren(existing, "Item");
  const state = findElementChild(itemChildren, "State");
  if (sku === "HeadQuarter") {
    if (!state || String(state.id ?? "") !== "4") {
      if (state) {
        state.id = "4";
      } else {
        itemChildren.unshift(leafElement("State", { id: "4" }));
      }
      changed = true;
    }

    const decorations = findElementChild(itemChildren, "Decorations");
    if (!decorations) {
      itemChildren.push(createHeadQuarterDecorations());
      changed = true;
    }
  } else if (isHouseSku(sku)) {
    changed = normalizeHouseRentState(state, itemChildren, Date.now()) || changed;
  } else if (!state || String(state.id ?? "") !== "5") {
    if (state) {
      state.id = "5";
    } else {
      itemChildren.unshift(leafElement("State", { id: "5" }));
    }
    changed = true;
  }

  return changed;
}

function normalizeTimedItemStates(items: JsonObject[], nowMs: number): boolean {
  let changed = false;

  for (const item of items) {
    if (!isItemElement(item)) {
      continue;
    }

    const itemChildren = getElementChildren(item, "Item");
    const state = findElementChild(itemChildren, "State");
    if (!state) {
      continue;
    }

    if (isHouseSku(String(item.sku ?? "")) && String(state.id ?? "") !== "0") {
      changed = normalizeHouseRentState(state, itemChildren, nowMs) || changed;
    }
    if (String(state.id ?? "") === "0") {
      changed = normalizeConstructionState(String(item.sku ?? ""), state, nowMs) || changed;
    }
  }

  return changed;
}

function repairLegacyTutorialBungalowDuplicate(items: JsonObject[], nowMs: number): boolean {
  const tutorialHouse = items.find(
    (entry) =>
      isItemElement(entry) &&
      String(entry.sku ?? "") === "houses_001_001" &&
      String(entry.x ?? "") === TUTORIAL_COMPLETED_HOUSE_TILE.x &&
      String(entry.y ?? "") === TUTORIAL_COMPLETED_HOUSE_TILE.y
  );
  const legacyGhostIndex = items.findIndex(
    (entry) =>
      isItemElement(entry) &&
      String(entry.sku ?? "") === "houses_001_001" &&
      String(entry.x ?? "") === "0" &&
      String(entry.y ?? "") === "0"
  );

  if (!tutorialHouse || legacyGhostIndex === -1) {
    return false;
  }

  const legacyGhost = items[legacyGhostIndex];
  if (!isItemElement(legacyGhost) || legacyGhost === tutorialHouse) {
    return false;
  }

  let changed = false;
  const tutorialStateChildren = getElementChildren(tutorialHouse, "Item");
  const legacyStateChildren = getElementChildren(legacyGhost, "Item");
  const tutorialState = findElementChild(tutorialStateChildren, "State");
  const legacyState = findElementChild(legacyStateChildren, "State");
  if (legacyState && shouldPreferHouseState(legacyState, tutorialState)) {
    const clonedState = JSON.parse(JSON.stringify(legacyState)) as JsonObject;
    const existingIndex = tutorialStateChildren.findIndex(
      (entry) => Boolean(entry && typeof entry === "object" && Array.isArray((entry as Record<string, unknown>).State))
    );
    if (existingIndex === -1) {
      tutorialStateChildren.unshift(clonedState);
    } else {
      tutorialStateChildren[existingIndex] = clonedState;
    }
    changed = true;
  }

  items.splice(legacyGhostIndex, 1);
  changed = true;
  const repairedTutorialState = findElementChild(getElementChildren(tutorialHouse, "Item"), "State");
  changed = normalizeHouseRentState(repairedTutorialState, getElementChildren(tutorialHouse, "Item"), nowMs) || changed;
  return changed;
}

function migrateBoughtRivalItemsToMine(rivalItems: JsonObject[], mineItems: JsonObject[], mineCompanySid: string): boolean {
  let changed = false;

  for (let index = rivalItems.length - 1; index >= 0; index -= 1) {
    const item = rivalItems[index];
    if (!isItemElement(item)) {
      continue;
    }

    const state = findElementChild(getElementChildren(item, "Item"), "State");
    if (!state || String(state.id ?? "") !== "1") {
      continue;
    }

    rivalItems.splice(index, 1);
    item.csid = mineCompanySid;
    mineItems.push(item);
    changed = true;
  }

  return changed;
}

function shouldPreferHouseState(candidate: JsonObject | undefined, current: JsonObject | undefined): boolean {
  return getHouseStatePriority(candidate) > getHouseStatePriority(current);
}

function getHouseStatePriority(state: JsonObject | undefined): number {
  if (!state) {
    return 0;
  }

  const contractSku = String(state.contractSku ?? "").trim();
  const mode = String(state.mode ?? "");
  const time = Number(state.time ?? "0");
  if (contractSku.length > 0 && mode === "4" && Number.isFinite(time) && time > 0) {
    return 5;
  }
  if (contractSku.length > 0 && (mode === "5" || mode === "6" || mode === "14" || mode === "15" || mode === "7")) {
    return 4;
  }
  if (String(state.id ?? "") === "1" && mode === "1") {
    return 2;
  }
  if (String(state.id ?? "") === "1") {
    return 1;
  }
  return 0;
}

function loadPollMissionRules(filePath: string): PollMissionRule[] {
  if (!fs.existsSync(filePath)) {
    return [];
  }

  const xml = fs.readFileSync(filePath, "utf8");
  const rules: PollMissionRule[] = [];
  const conditionIndexByEventSku = new Map<string, number>();
  const matches = xml.matchAll(/<Definition\b([^>]*)\/>/g);
  for (const match of matches) {
    const attributes = parseXmlAttributes(match[1] ?? "");
    const sku = String(attributes.sku ?? "").trim();
    const eventType = String(attributes.type ?? "").trim();
    const eventParameter = String(attributes.parameter ?? "").trim();
    const eventAmount = Number(attributes.amount ?? "0");
    if (sku.length === 0 || eventType.length === 0 || !Number.isFinite(eventAmount) || eventAmount <= 0) {
      continue;
    }
    const eventSku = `${eventType}${eventParameter}`;
    const hasCondition = attributes.condition != null && String(attributes.condition).trim().length > 0;
    let conditionIndex = -1;
    if (hasCondition) {
      conditionIndex = conditionIndexByEventSku.get(eventSku) ?? 0;
      conditionIndexByEventSku.set(eventSku, conditionIndex + 1);
    }
    rules.push({
      sku,
      unlockSku: String(attributes.unlockSku ?? "").trim(),
      unlockLevel: Number(attributes.unlockLevel ?? "0"),
      eventSku,
      eventAmount,
      conditionIndex,
      showInAbTest: attributes.showInABtest != null
    });
  }
  return rules;
}
