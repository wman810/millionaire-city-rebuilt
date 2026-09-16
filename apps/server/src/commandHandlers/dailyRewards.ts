import path from "path";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { loadDefinitionAttributes } from "../rules.js";
import { RULES_ROOT } from "../saveDefaults/paths.js";

export type DailyRewardDefinition = {
  sku: string;
  bonusType: string;
  bonusValue: string;
  group: number;
  chances: number;
};

export type PreparedDailyRewards = {
  response: JsonObject;
  stored: JsonObject;
  eligible: boolean;
  changed: boolean;
};

const SETTINGS = loadDefinitionAttributes(path.join(RULES_ROOT, "settings.xml"))[0] ?? {};
const DAILY_REWARD_INTERVAL_MS = readPositiveNumber(SETTINGS.dailyBonusMinTime, 24) * 60 * 60 * 1000;
const DAILY_BONUS_COINS = readPositiveNumber(SETTINGS.dailyBonus, 5000);
const DAILY_REWARDS = loadDailyRewards(path.join(RULES_ROOT, "dailyRewardsDefinitions.xml"));
const DAILY_REWARD_GROUPS = loadDailyRewardGroups(path.join(RULES_ROOT, "dailyRewardsGroupDefinitions.xml"));

export function prepareDailyRewards(
  source: JsonObject,
  nowMs: number,
  random: () => number = Math.random
): PreparedDailyRewards {
  const stored = cloneJsonObject(source);
  let changed = normalizeDailyRewardsDocument(stored);
  let count = readNonNegativeInteger(stored.dailyRewardsCount, 0);
  let lastGiven = parseRewardHistory(stored.dailyRewardsLastGiven);
  const lastGivenDate = readNonNegativeNumber(stored.dailyRewardsLastGivenDate, 0);
  const elapsed = nowMs - lastGivenDate;
  const eligible = elapsed >= DAILY_REWARD_INTERVAL_MS;

  if (!eligible) {
    return {
      response: cloneJsonObject(stored),
      stored,
      eligible: false,
      changed
    };
  }

  const streakExpired = elapsed > DAILY_REWARD_INTERVAL_MS * 2;
  if (streakExpired) {
    count = 0;
    lastGiven = [];
    stored.dailyRewardsCount = "0";
    stored.dailyRewardsLastGiven = "";
    changed = true;
  }

  const nextClaimCount = count + 1;
  const expectedGroup = getDailyRewardGroup(nextClaimCount);
  const storedReward = DAILY_REWARDS.get(String(stored.dailyRewardsNextRewardId ?? ""));
  const reward = storedReward?.group === expectedGroup
    ? storedReward
    : pickDailyReward(nextClaimCount, random);
  const nextRewardSku = reward?.sku ?? "";
  if (String(stored.dailyRewardsNextRewardId ?? "") !== nextRewardSku) {
    stored.dailyRewardsNextRewardId = nextRewardSku;
    changed = true;
  }

  const response = cloneJsonObject(stored);
  response.dailyRewardsCount = String(nextClaimCount);
  response.dailyRewardsLastGiven = lastGiven.join(",");
  response.dailyRewardsNextRewardId = nextRewardSku;
  return { response, stored, eligible: true, changed };
}

export function claimDailyReward(
  source: JsonObject,
  sku: string,
  nowMs: number
): { document: JsonObject; reward: DailyRewardDefinition } | undefined {
  const document = cloneJsonObject(source);
  normalizeDailyRewardsDocument(document);
  const reward = DAILY_REWARDS.get(sku);
  if (!reward) {
    return undefined;
  }

  const lastGivenDate = readNonNegativeNumber(document.dailyRewardsLastGivenDate, 0);
  const elapsed = nowMs - lastGivenDate;
  if (elapsed < DAILY_REWARD_INTERVAL_MS) {
    return undefined;
  }

  let count = readNonNegativeInteger(document.dailyRewardsCount, 0);
  let history = parseRewardHistory(document.dailyRewardsLastGiven);
  if (elapsed > DAILY_REWARD_INTERVAL_MS * 2) {
    count = 0;
    history = [];
  }

  const nextCount = count + 1;
  if (
    reward.group !== getDailyRewardGroup(nextCount) ||
    String(document.dailyRewardsNextRewardId ?? "") !== sku
  ) {
    return undefined;
  }

  history.push(sku);
  if (history.length > 6) {
    history = history.slice(-6);
  }

  const claimDate = new Date(nowMs);
  claimDate.setHours(0, 10, 0, 0);
  document.dailyRewardsCount = String(nextCount);
  document.dailyRewardsLastGiven = history.join(",");
  document.dailyRewardsLastGivenDate = String(claimDate.getTime());
  document.dailyRewardsNextRewardId = sku;
  return { document, reward };
}

function normalizeDailyRewardsDocument(document: JsonObject): boolean {
  let changed = false;
  if (!Array.isArray(document.dailyBonusInfo)) {
    document.dailyBonusInfo = [];
    changed = true;
  }

  const defaults: Record<string, string> = {
    dailyRewardsCount: "0",
    dailyRewardsLastGiven: "",
    dailyRewardsLastGivenDate: "0",
    dailyRewardsNextRewardId: ""
  };
  for (const [key, fallback] of Object.entries(defaults)) {
    if (typeof document[key] !== "string") {
      document[key] = String(document[key] ?? fallback);
      changed = true;
    }
  }
  return changed;
}

export function getDailyRewardIntervalMs(): number {
  return DAILY_REWARD_INTERVAL_MS;
}

export function getDailyBonusCoins(): number {
  return Math.trunc(DAILY_BONUS_COINS);
}

function pickDailyReward(day: number, random: () => number): DailyRewardDefinition | undefined {
  const group = getDailyRewardGroup(day);
  const candidates = Array.from(DAILY_REWARDS.values()).filter((entry) => entry.group === group);
  const totalWeight = candidates.reduce((sum, entry) => sum + entry.chances, 0);
  if (totalWeight <= 0) {
    return undefined;
  }

  const roll = normalizeRandom(random()) * totalWeight;
  let cursor = 0;
  for (const candidate of candidates) {
    cursor += candidate.chances;
    if (roll < cursor) {
      return candidate;
    }
  }
  return candidates[candidates.length - 1];
}

function getDailyRewardGroup(day: number): number {
  const normalizedDay = Math.max(1, Math.trunc(day));
  const index = (normalizedDay - 1) % 5;
  return DAILY_REWARD_GROUPS[index] ?? index + 1;
}

function loadDailyRewards(filePath: string): Map<string, DailyRewardDefinition> {
  const rewards = new Map<string, DailyRewardDefinition>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim() ?? "";
    const group = Number(definition.group ?? "");
    const chances = Number(definition.chances ?? "");
    if (sku.length === 0 || !Number.isFinite(group) || group <= 0 || !Number.isFinite(chances) || chances <= 0) {
      continue;
    }
    rewards.set(sku, {
      sku,
      bonusType: definition.bonusType?.trim().toLowerCase() ?? "",
      bonusValue: definition.bonusValue?.trim() ?? "",
      group: Math.trunc(group),
      chances: Math.trunc(chances)
    });
  }
  return rewards;
}

function loadDailyRewardGroups(filePath: string): number[] {
  const groups: number[] = [];
  for (const definition of loadDefinitionAttributes(filePath)) {
    const day = Number(definition.sku ?? "");
    const group = Number(definition.groupSku ?? "");
    if (!Number.isInteger(day) || day <= 0 || !Number.isInteger(group) || group <= 0) {
      continue;
    }
    groups[day - 1] = group;
  }
  return groups;
}

function parseRewardHistory(value: unknown): string[] {
  return String(value ?? "")
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0);
}

function readNonNegativeInteger(value: unknown, fallback: number): number {
  const number = Number(value ?? fallback);
  return Number.isFinite(number) && number >= 0 ? Math.trunc(number) : fallback;
}

function readNonNegativeNumber(value: unknown, fallback: number): number {
  const number = Number(value ?? fallback);
  return Number.isFinite(number) && number >= 0 ? number : fallback;
}

function readPositiveNumber(value: unknown, fallback: number): number {
  const number = Number(value ?? fallback);
  return Number.isFinite(number) && number > 0 ? number : fallback;
}

function normalizeRandom(value: number): number {
  if (!Number.isFinite(value) || value <= 0) {
    return 0;
  }
  return value >= 1 ? 1 - Number.EPSILON : value;
}

function cloneJsonObject(value: JsonObject): JsonObject {
  return JSON.parse(JSON.stringify(value)) as JsonObject;
}
