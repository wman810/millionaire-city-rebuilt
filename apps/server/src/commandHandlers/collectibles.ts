import fs from "fs";
import path from "path";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createEmptyCollectiblePendingDocument, createEmptyCollectiblesDocument } from "../saveDefaults.js";
import { ITEM_ASSETS_ROOT, RULES_ROOT } from "../saveDefaults/paths.js";
import { loadCollectibleUnlockLevel, loadDefinitionAttributes, loadLevelXpThresholds } from "../rules.js";
import { createElement, findElementChild, getElementChildren } from "../saveTree.js";
import { isHouseSku, type MutableNode } from "./universe.js";

export type CollectibleDefinition = {
  sku: string;
  collection: string;
  contractGroups: string[];
  commerceSkus: string[];
  rarity: number;
  minRarity: number;
  dependency: number;
  buyPriceCash: number;
  sellPriceCoins: number;
};

export type CollectibleGroupDefinition = {
  sku: string;
  rewardSku: string;
  rewardType: string;
  requirement: string;
  tradeable: boolean;
  collectibleSkus: string[];
  rewardValue?: {
    cash: number;
    coins: number;
    exp: number;
  };
};

export type CollectiblesState = {
  objectCounts: Map<string, number>;
  rewards: Set<string>;
  pendingBySid: Map<string, string>;
};

export type RandomSource = () => number;

const SETTINGS_PATH = path.join(RULES_ROOT, "settings.xml");
const XP_TABLE_PATH = path.join(RULES_ROOT, "XPTable.xml");
const CONTRACTS_PATH = path.join(RULES_ROOT, "contracts.xml");
const COLLECTIBLE_CHANCES_PATH = path.join(RULES_ROOT, "collectiblesChances.xml");
const ADVISOR_VARIANT_ITEM_SKUS = loadAdvisorVariantItemSkus(path.join(RULES_ROOT, "itemDefinitions.xml"));
const AVAILABLE_COLLECTIBLE_GROUPS = loadAvailableCollectibleGroupSkus(
  path.join(RULES_ROOT, "collectiblesGroupsDefinitions.xml"),
  ITEM_ASSETS_ROOT,
  ADVISOR_VARIANT_ITEM_SKUS
);
const ITEM_CONTRACT_GROUP_BY_SKU = loadItemContractGroupMap(path.join(RULES_ROOT, "itemDefinitions.xml"));
const COLLECTIBLE_DEFINITIONS = loadCollectibleDefinitions(
  path.join(RULES_ROOT, "collectiblesDefinitions.xml"),
  AVAILABLE_COLLECTIBLE_GROUPS
);
const COLLECTIBLE_GROUP_DEFINITIONS_BY_SKU = loadCollectibleGroupDefinitionMap(
  path.join(RULES_ROOT, "collectiblesGroupsDefinitions.xml"),
  path.join(RULES_ROOT, "collectiblesRewardDefinitions.xml"),
  COLLECTIBLE_DEFINITIONS,
  AVAILABLE_COLLECTIBLE_GROUPS
);
const COLLECTIBLE_PLANE_REWARD_BY_GROUP = loadCollectiblePlaneRewardMap(
  path.join(RULES_ROOT, "collectiblesGroupsDefinitions.xml"),
  path.join(RULES_ROOT, "collectiblesRewardDefinitions.xml"),
  AVAILABLE_COLLECTIBLE_GROUPS
);
const COLLECTIBLE_HQ_REWARD_BY_GROUP = loadCollectibleRewardMapByType(
  path.join(RULES_ROOT, "collectiblesGroupsDefinitions.xml"),
  path.join(RULES_ROOT, "collectiblesRewardDefinitions.xml"),
  AVAILABLE_COLLECTIBLE_GROUPS,
  "hq"
);
const COLLECTIBLES_BY_CONTRACT_GROUP = groupCollectiblesByContractGroup(COLLECTIBLE_DEFINITIONS);
const COLLECTIBLES_BY_COMMERCE_SKU = groupCollectiblesByCommerceSku(COLLECTIBLE_DEFINITIONS);
const CONTRACT_INCOME_HOURS_BY_SKU = loadContractIncomeHoursBySku(CONTRACTS_PATH);
const COLLECTIBLE_DROP_CHANCE_BY_HOURS = loadCollectibleDropChanceByHours(COLLECTIBLE_CHANCES_PATH);
const COLLECTIBLE_UNLOCK_LEVEL = loadCollectibleUnlockLevel(SETTINGS_PATH);
const LEVEL_XP_THRESHOLDS = loadLevelXpThresholds(XP_TABLE_PATH);
const COLLECTIBLE_SETTINGS = loadDefinitionAttributes(SETTINGS_PATH)[0] ?? {};
const COLLECTIBLE_MAX_UNITS_PER_ITEM = readNonNegativeInteger(
  COLLECTIBLE_SETTINGS.collectibleMaxUnitsPerItem,
  99
);
const COMMERCE_COLLECTIBLE_DROP_CHANCE =
  readNonNegativeInteger(COLLECTIBLE_SETTINGS.collectRewardInCommerceChances, 1) / 100;
export const HOUSE_COLLECTIBLE_SLOT_COUNT = 3;
export const HOUSE_COLLECTIBLE_SLOT_EXPIRE_MS =
  readPositiveNumber(COLLECTIBLE_SETTINGS.collectibleSlotExpire, 8) * 60 * 60 * 1000;

export function getCollectibleMaximumUnits(): number {
  return COLLECTIBLE_MAX_UNITS_PER_ITEM;
}

export function getCollectibleDefinitionForMutation(sku: string): CollectibleDefinition | undefined {
  return COLLECTIBLE_DEFINITIONS.find((definition) => definition.sku === sku);
}

export function getCollectibleGroupForClaim(sku: string): CollectibleGroupDefinition | undefined {
  return COLLECTIBLE_GROUP_DEFINITIONS_BY_SKU.get(sku);
}

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

export type CollectibleAwardSource = "house" | "commerce";

export function getCollectibleAwardSource(
  payload: Record<string, unknown>,
  itemSku: string,
  previousMode: string,
  state: MutableNode
): CollectibleAwardSource | undefined {
  const action = String(payload.action ?? "").toLowerCase();
  if ((action !== "new_mode" && action !== "new_state") || String(state.mode ?? "") !== "4") {
    return undefined;
  }

  if (isHouseSku(itemSku) && previousMode === "1") {
    return "house";
  }

  if (COLLECTIBLES_BY_COMMERCE_SKU.has(itemSku) && (previousMode === "6" || previousMode === "14")) {
    return "commerce";
  }

  return undefined;
}

export function isCollectibleFeatureUnlocked(profile: MutableNode | undefined): boolean {
  return getProfileLevel(profile) >= COLLECTIBLE_UNLOCK_LEVEL;
}

export function shouldAwardHouseCollectibleDrop(
  state: MutableNode,
  random: RandomSource = Math.random
): boolean {
  const contractSku = String(state.contractSku ?? "").trim();
  const incomeHours = CONTRACT_INCOME_HOURS_BY_SKU.get(contractSku);
  if (incomeHours == null) {
    return false;
  }

  const chance = COLLECTIBLE_DROP_CHANCE_BY_HOURS.get(incomeHours);
  return chance != null && normalizeRandomRoll(random()) <= chance;
}

export function shouldAwardCommerceCollectibleDrop(random: RandomSource = Math.random): boolean {
  return normalizeRandomRoll(random()) <= COMMERCE_COLLECTIBLE_DROP_CHANCE;
}

export function reserveHouseCollectibleDropSlot(
  currentExpirations: readonly number[],
  nowMs: number
): number[] | undefined {
  const expirations = currentExpirations
    .filter((value) => Number.isFinite(value) && value >= 0)
    .slice(0, HOUSE_COLLECTIBLE_SLOT_COUNT);
  const nextExpiration = nowMs + HOUSE_COLLECTIBLE_SLOT_EXPIRE_MS;

  if (expirations.length < HOUSE_COLLECTIBLE_SLOT_COUNT) {
    expirations.push(nextExpiration);
    return expirations;
  }

  const reusableIndex = expirations.findIndex((expiration) => expiration < nowMs);
  if (reusableIndex === -1) {
    return undefined;
  }

  expirations[reusableIndex] = nextExpiration;
  return expirations;
}

export function pickCollectibleSkuForHouse(
  itemSku: string,
  contractGroupSku: string,
  state: CollectiblesState,
  random: RandomSource = Math.random
): string | undefined {
  const contractGroup = contractGroupSku.trim() || ITEM_CONTRACT_GROUP_BY_SKU.get(itemSku);
  if (!contractGroup) {
    return undefined;
  }

  const candidates = COLLECTIBLES_BY_CONTRACT_GROUP.get(contractGroup) ?? [];
  return pickCollectibleSkuFromPossibleList(candidates, state, random);
}

export function pickCollectibleSkuForCommerce(
  itemSku: string,
  state: CollectiblesState,
  random: RandomSource = Math.random
): string | undefined {
  const candidates = COLLECTIBLES_BY_COMMERCE_SKU.get(itemSku) ?? [];
  return pickCollectibleSkuFromPossibleList(candidates, state, random);
}

function pickCollectibleSkuFromPossibleList(
  candidates: readonly CollectibleDefinition[],
  state: CollectiblesState,
  random: RandomSource
): string | undefined {
  if (candidates.length === 0) {
    return undefined;
  }

  const candidatesByCollection = new Map<string, CollectibleDefinition[]>();
  for (const candidate of candidates) {
    const collection = candidatesByCollection.get(candidate.collection) ?? [];
    collection.push(candidate);
    candidatesByCollection.set(candidate.collection, collection);
  }

  const weightedCandidates: Array<{ sku: string; weight: number }> = [];
  for (const collection of candidatesByCollection.values()) {
    const isComplete = collection.every((candidate) => (state.objectCounts.get(candidate.sku) ?? 0) > 0);
    const dependencySum = collection.reduce(
      (sum, candidate) =>
        sum + ((state.objectCounts.get(candidate.sku) ?? 0) > 0 ? candidate.dependency : 0),
      0
    );

    for (const candidate of collection) {
      const count = state.objectCounts.get(candidate.sku) ?? 0;
      const baseWeight = Math.max(candidate.rarity, candidate.minRarity);
      let weight = baseWeight;
      if (!isComplete && count > 0) {
        weight =
          count >= COLLECTIBLE_MAX_UNITS_PER_ITEM
            ? 0
            : Math.max(baseWeight - dependencySum, candidate.minRarity);
      }

      weightedCandidates.push({ sku: candidate.sku, weight });
    }
  }

  const totalWeight = weightedCandidates.reduce((sum, candidate) => sum + candidate.weight, 0);
  if (totalWeight <= 0) {
    return undefined;
  }

  const roll = Math.floor(normalizeRandomRoll(random()) * totalWeight);
  let cumulativeWeight = 0;
  for (const candidate of weightedCandidates) {
    cumulativeWeight += candidate.weight;
    if (roll < cumulativeWeight) {
      return candidate.sku;
    }
  }

  for (let index = weightedCandidates.length - 1; index >= 0; index -= 1) {
    if (weightedCandidates[index].weight > 0) {
      return weightedCandidates[index].sku;
    }
  }

  return undefined;
}

export function resolvePlaneRewardSkuForCollectibleClaim(groupSku: string): string | undefined {
  return COLLECTIBLE_PLANE_REWARD_BY_GROUP.get(groupSku);
}

export function resolveHeadQuarterRewardSkuForCollectibleClaim(groupSku: string): string | undefined {
  return COLLECTIBLE_HQ_REWARD_BY_GROUP.get(groupSku);
}

export function resolveItemRewardCollectibleGroupFromMutation(
  payload: Record<string, unknown>,
  itemEntry: MutableNode
): string | undefined {
  const groupSku = String(payload.collectible ?? "").trim();
  if (groupSku.length === 0) {
    return undefined;
  }

  const group = COLLECTIBLE_GROUP_DEFINITIONS_BY_SKU.get(groupSku);
  if (!group || group.rewardType !== "item") {
    return undefined;
  }

  const itemSku = String(itemEntry.sku ?? "").trim();
  return itemSku.length === 0 || itemSku === group.rewardSku ? groupSku : undefined;
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
      counts.set(sku, Math.min(COLLECTIBLE_MAX_UNITS_PER_ITEM, Math.trunc(count)));
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

export function getProfileLevel(profile: MutableNode | undefined): number {
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

function normalizeRandomRoll(value: number): number {
  if (!Number.isFinite(value) || value <= 0) {
    return 0;
  }
  if (value >= 1) {
    return 1 - Number.EPSILON;
  }
  return value;
}

function readNonNegativeInteger(value: string | undefined, fallback: number): number {
  if (value == null || value.trim().length === 0) {
    return fallback;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed >= 0 ? Math.trunc(parsed) : fallback;
}

function readPositiveNumber(value: string | undefined, fallback: number): number {
  if (value == null || value.trim().length === 0) {
    return fallback;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
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

function loadCollectibleDefinitions(filePath: string, availableGroupSkus: Set<string>): CollectibleDefinition[] {
  return loadDefinitionAttributes(filePath)
    .map((definition) => {
      const sku = definition.sku?.trim() ?? "";
      const collection = definition.collection?.trim() ?? "";
      const contractGroups = (definition.contracsGroupList ?? "")
        .split(",")
        .map((entry) => entry.trim())
        .filter((entry) => entry.length > 0);
      const commerceSkus = (definition.commerce ?? "")
        .split(",")
        .map((entry) => entry.trim())
        .filter((entry) => entry.length > 0);
      const rarity = readNonNegativeInteger(definition.prioritySku, 0);
      const minRarity = readNonNegativeInteger(definition.minPriority, 0);
      const dependency = readNonNegativeInteger(definition.dependency, 0);
      const buyPriceCash = readNonNegativeInteger(definition.priceCash, 0);
      const sellPriceCoins = readNonNegativeInteger(definition.priceCoins, 0);
      return {
        sku,
        collection,
        contractGroups,
        commerceSkus,
        rarity,
        minRarity,
        dependency,
        buyPriceCash,
        sellPriceCoins
      };
    })
    .filter(
      (definition) =>
        definition.sku.length > 0 &&
        definition.collection.length > 0 &&
        availableGroupSkus.has(definition.collection) &&
        definition.rarity > 0 &&
        (definition.contractGroups.length > 0 || definition.commerceSkus.length > 0)
    );
}

function loadContractIncomeHoursBySku(filePath: string): Map<string, number> {
  const mapping = new Map<string, number>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim();
    const incomeHours = Number(definition.incomeTime ?? "");
    if (sku && Number.isFinite(incomeHours) && incomeHours > 0) {
      mapping.set(sku, incomeHours);
    }
  }
  return mapping;
}

function loadCollectibleDropChanceByHours(filePath: string): Map<number, number> {
  const mapping = new Map<number, number>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const incomeHours = Number(definition.hours ?? "");
    const percentage = Number(definition.finalResult ?? "");
    if (
      Number.isFinite(incomeHours) &&
      incomeHours > 0 &&
      Number.isFinite(percentage) &&
      percentage >= 0
    ) {
      mapping.set(incomeHours, Math.min(1, percentage / 100));
    }
  }
  return mapping;
}

function loadCollectibleGroupDefinitionMap(
  groupsPath: string,
  rewardsPath: string,
  collectibleDefinitions: CollectibleDefinition[],
  availableGroupSkus: Set<string>
): Map<string, CollectibleGroupDefinition> {
  const rewardValues = new Map<string, CollectibleGroupDefinition["rewardValue"]>();
  for (const definition of loadDefinitionAttributes(rewardsPath)) {
    const sku = definition.sku?.trim() ?? "";
    const parts = (definition.value ?? "").split(":").map(Number);
    if (sku.length === 0 || parts.length !== 3 || parts.some((value) => !Number.isFinite(value))) {
      continue;
    }
    rewardValues.set(sku, {
      cash: Math.trunc(parts[0]),
      coins: Math.trunc(parts[1]),
      exp: Math.trunc(parts[2])
    });
  }

  const collectibleSkusByGroup = new Map<string, string[]>();
  for (const definition of collectibleDefinitions) {
    const members = collectibleSkusByGroup.get(definition.collection) ?? [];
    members.push(definition.sku);
    collectibleSkusByGroup.set(definition.collection, members);
  }

  const groups = new Map<string, CollectibleGroupDefinition>();
  for (const definition of loadDefinitionAttributes(groupsPath)) {
    const sku = definition.sku?.trim() ?? "";
    const rewardSku = definition.reward?.trim() ?? "";
    const rewardType = definition.rewardType?.trim().toLowerCase() ?? "";
    if (sku.length === 0 || rewardSku.length === 0 || !availableGroupSkus.has(sku)) {
      continue;
    }

    groups.set(sku, {
      sku,
      rewardSku,
      rewardType,
      requirement: definition.requirements?.trim() ?? "",
      tradeable: definition.tradein === "1",
      collectibleSkus: collectibleSkusByGroup.get(sku) ?? [],
      rewardValue: rewardValues.get(rewardSku)
    });
  }

  return groups;
}

function loadCollectiblePlaneRewardMap(
  groupsPath: string,
  rewardsPath: string,
  availableGroupSkus: Set<string>
): Map<string, string> {
  return loadCollectibleRewardMapByType(groupsPath, rewardsPath, availableGroupSkus, "plane");
}

function loadCollectibleRewardMapByType(
  groupsPath: string,
  rewardsPath: string,
  availableGroupSkus: Set<string>,
  rewardTypeFilter: string
): Map<string, string> {
  const rewardTypesBySku = new Map<string, string>();
  for (const definition of loadDefinitionAttributes(rewardsPath)) {
    const sku = definition.sku?.trim();
    const rewardType = definition.rewardType?.trim().toLowerCase();
    if (sku && rewardType) {
      rewardTypesBySku.set(sku, rewardType);
    }
  }

  const rewardsByGroup = new Map<string, string>();
  for (const definition of loadDefinitionAttributes(groupsPath)) {
    const groupSku = definition.sku?.trim();
    const rewardSku = definition.reward?.trim();
    if (!groupSku || !rewardSku || !availableGroupSkus.has(groupSku)) {
      continue;
    }

    const groupRewardType = definition.rewardType?.trim().toLowerCase();
    const rewardType = rewardTypesBySku.get(rewardSku) ?? groupRewardType;
    if (rewardType === rewardTypeFilter) {
      rewardsByGroup.set(groupSku, rewardSku);
    }
  }

  return rewardsByGroup;
}

function loadAvailableCollectibleGroupSkus(
  groupsPath: string,
  itemAssetsRoot: string,
  advisorVariantItemSkus: Set<string>
): Set<string> {
  const archivedItemSwfs = createArchivedItemSwfSet(itemAssetsRoot);
  const groupSkus = new Set<string>();
  for (const definition of loadDefinitionAttributes(groupsPath)) {
    const groupSku = definition.sku?.trim();
    const rewardSku = definition.reward?.trim();
    const rewardType = definition.rewardType?.trim().toLowerCase();
    if (!groupSku || !rewardSku) {
      continue;
    }

    if (
      rewardType === "item" &&
      !isArchivedItemSkuAvailable(rewardSku, archivedItemSwfs, advisorVariantItemSkus.has(rewardSku))
    ) {
      continue;
    }

    groupSkus.add(groupSku);
  }

  return groupSkus;
}

function loadAdvisorVariantItemSkus(filePath: string): Set<string> {
  const advisorSkus = new Set<string>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim();
    if (sku && definition.useAdvisor != null) {
      advisorSkus.add(sku);
    }
  }

  return advisorSkus;
}

function isArchivedItemSkuAvailable(sku: string, archivedItemSwfs: Set<string>, usesAdvisor: boolean): boolean {
  if (archivedItemSwfs.has(`${sku}.swf`.toLowerCase())) {
    return true;
  }

  return (
    usesAdvisor &&
    archivedItemSwfs.has(`${sku}_Cindy.swf`.toLowerCase()) &&
    archivedItemSwfs.has(`${sku}_Ronald.swf`.toLowerCase())
  );
}

function createArchivedItemSwfSet(itemAssetsRoot: string): Set<string> {
  if (!fs.existsSync(itemAssetsRoot)) {
    return new Set();
  }

  return new Set(
    fs
      .readdirSync(itemAssetsRoot, { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".swf"))
      .map((entry) => entry.name.toLowerCase())
  );
}

function groupCollectiblesByContractGroup(definitions: CollectibleDefinition[]): Map<string, CollectibleDefinition[]> {
  const mapping = new Map<string, CollectibleDefinition[]>();
  for (const definition of definitions) {
    for (const group of definition.contractGroups) {
      const current = mapping.get(group) ?? [];
      current.push(definition);
      mapping.set(group, current);
    }
  }
  return mapping;
}

function groupCollectiblesByCommerceSku(definitions: CollectibleDefinition[]): Map<string, CollectibleDefinition[]> {
  const mapping = new Map<string, CollectibleDefinition[]>();
  for (const definition of definitions) {
    for (const commerceSku of definition.commerceSkus) {
      const current = mapping.get(commerceSku) ?? [];
      current.push(definition);
      mapping.set(commerceSku, current);
    }
  }
  return mapping;
}
