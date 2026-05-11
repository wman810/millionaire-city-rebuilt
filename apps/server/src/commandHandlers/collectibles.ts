import path from "path";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createEmptyCollectiblePendingDocument, createEmptyCollectiblesDocument } from "../saveDefaults.js";
import { loadCollectibleUnlockLevel, loadDefinitionAttributes, loadLevelXpThresholds } from "../rules.js";
import { createElement, findElementChild, getElementChildren } from "../saveTree.js";
import { getCompanyEntryByWhose, isHouseSku, isItemElement, type MutableNode } from "./universe.js";

type CollectibleDefinition = {
  sku: string;
  collection: string;
  contractGroups: string[];
};

type CollectiblesState = {
  objectCounts: Map<string, number>;
  rewards: Set<string>;
  pendingBySid: Map<string, string>;
};

const RULES_ROOT = path.resolve(__dirname, "../../../../Millionaire City/dchoc1-a.akamaihd.net/0.501/mcity/Datas/rules");
const SETTINGS_PATH = path.join(RULES_ROOT, "settings.xml");
const XP_TABLE_PATH = path.join(RULES_ROOT, "XPTable.xml");
const ITEM_CONTRACT_GROUP_BY_SKU = loadItemContractGroupMap(path.join(RULES_ROOT, "itemDefinitions.xml"));
const COLLECTIBLE_DEFINITIONS = loadCollectibleDefinitions(path.join(RULES_ROOT, "collectiblesDefinitions.xml"));
const COLLECTIBLE_PLANE_REWARD_BY_GROUP = loadCollectiblePlaneRewardMap(
  path.join(RULES_ROOT, "collectiblesGroupsDefinitions.xml"),
  path.join(RULES_ROOT, "collectiblesRewardDefinitions.xml")
);
const COLLECTIBLES_BY_CONTRACT_GROUP = groupCollectiblesByContractGroup(COLLECTIBLE_DEFINITIONS);
const COLLECTIBLE_UNLOCK_LEVEL = loadCollectibleUnlockLevel(SETTINGS_PATH);
const LEVEL_XP_THRESHOLDS = loadLevelXpThresholds(XP_TABLE_PATH);
const HOUSE_COLLECTIBLE_DROP_DIVISOR = 8;

export function normalizeCollectiblesDocument(document: JsonObject): boolean {
  const normalized = createEmptyCollectiblesDocument();
  let changed = false;

  if (!Array.isArray(document.collectiblesList)) {
    document.collectiblesList = normalized.collectiblesList;
    changed = true;
  }

  const children = getElementChildren(document, "collectiblesList");
  const objects = findElementChild(children, "Objects");
  if (!objects) {
    children.push(createElement("Objects", { skus: "" }));
    changed = true;
  } else if (typeof objects.skus !== "string") {
    objects.skus = "";
    changed = true;
  }

  const rewards = findElementChild(children, "Rewards");
  if (!rewards) {
    children.push(createElement("Rewards", { skus: "" }));
    changed = true;
  } else if (typeof rewards.skus !== "string") {
    rewards.skus = "";
    changed = true;
  }

  const pending = findElementChild(children, "Pending");
  if (!pending) {
    children.push(createElement("Pending", { tupla: "" }));
    changed = true;
  } else if (typeof pending.tupla !== "string") {
    pending.tupla = "";
    changed = true;
  }

  return changed;
}

export function normalizeCollectiblePendingDocument(document: JsonObject): boolean {
  if (Array.isArray(document.collectiblePendingList)) {
    return false;
  }

  document.collectiblePendingList = createEmptyCollectiblePendingDocument().collectiblePendingList;
  return true;
}

export function readCollectiblesState(document: JsonObject): CollectiblesState {
  normalizeCollectiblesDocument(document);
  const children = getElementChildren(document, "collectiblesList");
  const objects = findElementChild(children, "Objects");
  const rewards = findElementChild(children, "Rewards");
  const pending = findElementChild(children, "Pending");

  return {
    objectCounts: parseSkuCountMap(String(objects?.skus ?? "")),
    rewards: parseSkuSet(String(rewards?.skus ?? "")),
    pendingBySid: parsePendingCollectibleMap(String(pending?.tupla ?? ""))
  };
}

export function writeCollectiblesState(document: JsonObject, state: CollectiblesState): void {
  normalizeCollectiblesDocument(document);
  const children = getElementChildren(document, "collectiblesList");
  upsertSimpleAttributeElement(children, "Objects", "skus", serializeSkuCountMap(state.objectCounts));
  upsertSimpleAttributeElement(children, "Rewards", "skus", serializeSkuSet(state.rewards));
  upsertSimpleAttributeElement(children, "Pending", "tupla", serializePendingCollectibleMap(state.pendingBySid));
}

export function removePendingFriendCollectible(document: JsonObject, extId: string, sku: string): boolean {
  normalizeCollectiblePendingDocument(document);
  const children = getElementChildren(document, "collectiblePendingList");
  const index = children.findIndex(
    (entry) =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as Record<string, unknown>).item)) &&
      String((entry as MutableNode).extId ?? "") === extId &&
      String((entry as MutableNode).sku ?? "") === sku
  );
  if (index === -1) {
    return false;
  }

  children.splice(index, 1);
  return true;
}

export function projectPendingCollectiblesOnUniverse(universe: JsonObject, collectiblesDocument: JsonObject): JsonObject {
  const pendingBySid = readCollectiblesState(collectiblesDocument).pendingBySid;
  if (pendingBySid.size === 0) {
    return universe;
  }

  const company = getCompanyEntryByWhose(universe, "0");
  if (!company) {
    return universe;
  }

  for (const item of getElementChildren(company, "Company")) {
    if (!isItemElement(item)) {
      continue;
    }

    const sid = String(item.sid ?? "");
    if (!pendingBySid.has(sid) || !isHouseSku(String(item.sku ?? ""))) {
      continue;
    }

    const state = ensureProjectedHouseState(item);
    const currentMode = String(state.mode ?? "1");
    if (currentMode === "5" || currentMode === "6") {
      continue;
    }

    state.id = "1";
    state.mode = "14";
    state.time = "0";
    for (const staleKey of ["contractSku", "contractGroupSku", "savedAt", "accelerated", "doubleRent"]) {
      if (staleKey in state) {
        delete state[staleKey];
      }
    }
  }

  return universe;
}

export function collapsePendingCollectibleState(state: MutableNode): void {
  state.id = "1";
  state.mode = "1";
  state.time = "0";
  for (const staleKey of ["contractSku", "contractGroupSku", "savedAt", "accelerated", "doubleRent"]) {
    if (staleKey in state) {
      delete state[staleKey];
    }
  }
}

export function isCollectibleAwardMutation(payload: Record<string, unknown>, state: MutableNode): boolean {
  const action = String(payload.action ?? "").toLowerCase();
  return (
    (action === "new_mode" || action === "new_state") &&
    String(state.id ?? "") === "1" &&
    String(state.mode ?? "") === "5"
  );
}

export function isCollectibleFeatureUnlocked(profile: MutableNode | undefined): boolean {
  return getProfileLevel(profile) >= COLLECTIBLE_UNLOCK_LEVEL;
}

export function shouldAwardCollectibleDrop(itemEntry: MutableNode, state: MutableNode): boolean {
  const sid = String(itemEntry.sid ?? "").trim();
  const itemSku = String(itemEntry.sku ?? "").trim();
  const contractSku = String(state.contractSku ?? "").trim();
  const savedAt = String(state.savedAt ?? "").trim();
  if (sid.length === 0 || itemSku.length === 0 || contractSku.length === 0 || savedAt.length === 0) {
    return false;
  }

  const cycleKey = `${sid}:${itemSku}:${contractSku}:${savedAt}`;
  const roll = Math.abs(stableStringHash(cycleKey));
  return roll % HOUSE_COLLECTIBLE_DROP_DIVISOR === 0;
}

export function pickCollectibleSkuForHouse(itemSku: string, sid: string, state: CollectiblesState): string | undefined {
  const contractGroup = ITEM_CONTRACT_GROUP_BY_SKU.get(itemSku);
  if (!contractGroup) {
    return undefined;
  }

  const candidates = COLLECTIBLES_BY_CONTRACT_GROUP.get(contractGroup) ?? [];
  if (candidates.length === 0) {
    return undefined;
  }

  const pendingCounts = new Map<string, number>();
  for (const sku of state.pendingBySid.values()) {
    pendingCounts.set(sku, (pendingCounts.get(sku) ?? 0) + 1);
  }

  return candidates
    .slice()
    .sort((left, right) => {
      const leftCount = (state.objectCounts.get(left) ?? 0) + (pendingCounts.get(left) ?? 0);
      const rightCount = (state.objectCounts.get(right) ?? 0) + (pendingCounts.get(right) ?? 0);
      if (leftCount !== rightCount) {
        return leftCount - rightCount;
      }

      const leftHash = stableStringHash(`${sid}:${left}`);
      const rightHash = stableStringHash(`${sid}:${right}`);
      if (leftHash !== rightHash) {
        return leftHash - rightHash;
      }

      return left.localeCompare(right);
    })[0];
}

export function resolvePlaneRewardSkuForCollectibleClaim(groupSku: string): string | undefined {
  return COLLECTIBLE_PLANE_REWARD_BY_GROUP.get(groupSku);
}

function upsertSimpleAttributeElement(
  children: JsonObject[],
  tagName: string,
  attributeName: string,
  attributeValue: string
): void {
  const existing = findElementChild(children, tagName);
  if (existing) {
    existing[attributeName] = attributeValue;
    return;
  }

  children.push(createElement(tagName, { [attributeName]: attributeValue }));
}

function parseSkuCountMap(value: string): Map<string, number> {
  const counts = new Map<string, number>();
  for (const part of value.split(",")) {
    const trimmed = part.trim();
    if (trimmed.length === 0) {
      continue;
    }

    const [sku, countValue] = trimmed.split(":");
    const count = countValue == null ? 1 : Number(countValue);
    if (sku && Number.isFinite(count) && count > 0) {
      counts.set(sku, count);
    }
  }
  return counts;
}

function serializeSkuCountMap(values: Map<string, number>): string {
  return Array.from(values.entries())
    .filter(([, count]) => Number.isFinite(count) && count > 0)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([sku, count]) => (count === 1 ? sku : `${sku}:${count}`))
    .join(",");
}

function parseSkuSet(value: string): Set<string> {
  return new Set(
    value
      .split(",")
      .map((entry) => entry.trim())
      .filter((entry) => entry.length > 0)
  );
}

function serializeSkuSet(values: Set<string>): string {
  return Array.from(values).sort().join(",");
}

function parsePendingCollectibleMap(value: string): Map<string, string> {
  const pending = new Map<string, string>();
  for (const part of value.split(",")) {
    const trimmed = part.trim();
    if (trimmed.length === 0) {
      continue;
    }

    const separator = trimmed.indexOf(":");
    if (separator === -1) {
      continue;
    }

    const sid = trimmed.slice(0, separator);
    const sku = trimmed.slice(separator + 1);
    if (sid.length > 0 && sku.length > 0) {
      pending.set(sid, sku);
    }
  }
  return pending;
}

function serializePendingCollectibleMap(values: Map<string, string>): string {
  return Array.from(values.entries())
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([sid, sku]) => `${sid}:${sku}`)
    .join(",");
}

function ensureProjectedHouseState(item: MutableNode): MutableNode {
  const itemChildren = getElementChildren(item, "Item");
  const existing = findElementChild(itemChildren, "State");
  if (existing) {
    return existing;
  }

  const state = createElement("State", { id: "1", mode: "1", time: "0" });
  itemChildren.unshift(state);
  return state;
}

function getProfileLevel(profile: MutableNode | undefined): number {
  const explicitLevel = Number(profile?.level ?? "");
  if (Number.isFinite(explicitLevel) && explicitLevel >= 1) {
    return Math.floor(explicitLevel);
  }

  const exp = Number(profile?.exp ?? "0");
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

function stableStringHash(value: string): number {
  let hash = 17;
  for (let index = 0; index < value.length; index += 1) {
    hash = (hash * 31 + value.charCodeAt(index)) | 0;
  }
  return hash;
}

function loadItemContractGroupMap(filePath: string): Map<string, string> {
  const definitions = loadDefinitionAttributes(filePath);
  const mapping = new Map<string, string>();
  for (const definition of definitions) {
    const sku = definition.sku?.trim();
    const contractGroup = definition.contractsTypeSku?.trim();
    if (sku && contractGroup) {
      mapping.set(sku, contractGroup);
    }
  }
  return mapping;
}

function loadCollectibleDefinitions(filePath: string): CollectibleDefinition[] {
  return loadDefinitionAttributes(filePath)
    .map((definition) => {
      const sku = definition.sku?.trim() ?? "";
      const collection = definition.collection?.trim() ?? "";
      const contractGroups = (definition.contracsGroupList ?? "")
        .split(",")
        .map((entry) => entry.trim())
        .filter((entry) => entry.length > 0);
      return { sku, collection, contractGroups };
    })
    .filter(
      (definition) =>
        definition.sku.length > 0 && definition.collection.length > 0 && definition.contractGroups.length > 0
    );
}

function loadCollectiblePlaneRewardMap(groupsPath: string, rewardsPath: string): Map<string, string> {
  const rewardTypesBySku = new Map<string, string>();
  for (const definition of loadDefinitionAttributes(rewardsPath)) {
    const sku = definition.sku?.trim();
    const rewardType = definition.rewardType?.trim();
    if (sku && rewardType) {
      rewardTypesBySku.set(sku, rewardType);
    }
  }

  const planeRewardsByGroup = new Map<string, string>();
  for (const definition of loadDefinitionAttributes(groupsPath)) {
    const groupSku = definition.sku?.trim();
    const rewardSku = definition.reward?.trim();
    if (groupSku && rewardSku && rewardTypesBySku.get(rewardSku) === "plane") {
      planeRewardsByGroup.set(groupSku, rewardSku);
    }
  }

  return planeRewardsByGroup;
}

function groupCollectiblesByContractGroup(definitions: CollectibleDefinition[]): Map<string, string[]> {
  const mapping = new Map<string, string[]>();
  for (const definition of definitions) {
    for (const group of definition.contractGroups) {
      const current = mapping.get(group) ?? [];
      current.push(definition.sku);
      mapping.set(group, current);
    }
  }
  return mapping;
}
