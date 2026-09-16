import path from "path";
import { DEFAULT_USER_ID } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { loadDefinitionAttributes } from "../rules.js";
import { RULES_ROOT } from "../saveDefaults/paths.js";

export type UpgradeRecord = {
  ownerId: string;
  sid: string;
  visitorExtId: string;
  type: string;
  createdAtMs: number;
};

const SOCIAL_RULES = loadDefinitionAttributes(path.join(RULES_ROOT, "social.xml"))[0] ?? {};
export const VISITOR_UPGRADES_PER_WINDOW = readPositiveInteger(SOCIAL_RULES.upgrade_maximunOf_items, 5);
export const UPGRADE_REPEAT_WINDOW_MS =
  readPositiveNumber(SOCIAL_RULES.upgrade_repeatUpgrades_time, 12) * 60 * 60 * 1000;
const UPGRADE_REWARD = {
  exp: readNonNegativeInteger(SOCIAL_RULES.upgradesVisitorExpPerUpgrade, 10),
  coins: readNonNegativeInteger(SOCIAL_RULES.upgradesVisitorDCCoinsPerUpgrade, 100)
};
const SUPER_UPGRADE_REWARD = {
  exp: readNonNegativeInteger(SOCIAL_RULES.superUpgradesVisitorExpPerUpgrade, 15),
  coins: readNonNegativeInteger(SOCIAL_RULES.superUpgradesVisitorDCCoinsPerUpgrade, 150)
};
const NPC_UPGRADES_STATE_KEY = "__npcUpgradeRecords";

export function getStoredUpgradeRecords(document: JsonObject): UpgradeRecord[] {
  const entries = document[NPC_UPGRADES_STATE_KEY];
  if (!Array.isArray(entries)) {
    return [];
  }

  return entries
    .filter((entry): entry is JsonObject => Boolean(entry && typeof entry === "object" && !Array.isArray(entry)))
    .map((entry) => {
      const createdAtMs = Number(entry.createdAtMs ?? parseLegacyDayKey(String(entry.dayKey ?? "")));
      return {
        ownerId: String(entry.ownerId ?? DEFAULT_USER_ID),
        sid: String(entry.sid ?? ""),
        visitorExtId: String(entry.visitorExtId ?? ""),
        type: String(entry.type ?? "0"),
        createdAtMs
      };
    })
    .filter(
      (entry) =>
        entry.sid.length > 0 &&
        entry.visitorExtId.length > 0 &&
        Number.isFinite(entry.createdAtMs) &&
        entry.createdAtMs >= 0
    );
}

export function setStoredUpgradeRecords(document: JsonObject, records: UpgradeRecord[]): void {
  document[NPC_UPGRADES_STATE_KEY] = records;
}

export function isUpgradeRecordActive(record: UpgradeRecord, nowMs: number): boolean {
  const age = nowMs - record.createdAtMs;
  return age >= 0 && age < UPGRADE_REPEAT_WINDOW_MS;
}

export function getUpgradeVisitorReward(type: unknown): { exp: number; coins: number } {
  return String(type ?? "0") === "1" ? SUPER_UPGRADE_REWARD : UPGRADE_REWARD;
}

function parseLegacyDayKey(value: string): number {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return Number.NaN;
  }
  const parsed = new Date(`${value}T00:00:00`).getTime();
  return Number.isFinite(parsed) ? parsed : Number.NaN;
}

function readPositiveInteger(value: unknown, fallback: number): number {
  const number = Number(value ?? fallback);
  return Number.isFinite(number) && number > 0 ? Math.trunc(number) : fallback;
}

function readPositiveNumber(value: unknown, fallback: number): number {
  const number = Number(value ?? fallback);
  return Number.isFinite(number) && number > 0 ? number : fallback;
}

function readNonNegativeInteger(value: unknown, fallback: number): number {
  const number = Number(value ?? fallback);
  return Number.isFinite(number) && number >= 0 ? Math.trunc(number) : fallback;
}
