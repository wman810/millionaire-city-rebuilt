import { DEFAULT_USER_ID } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";

type UpgradeRecord = {
  ownerId: string;
  sid: string;
  visitorExtId: string;
  type: string;
  dayKey: string;
};

export const VISITOR_UPGRADES_PER_DAY = 5;
const NPC_UPGRADES_STATE_KEY = "__npcUpgradeRecords";

export function getStoredUpgradeRecords(document: JsonObject): UpgradeRecord[] {
  const entries = document[NPC_UPGRADES_STATE_KEY];
  if (!Array.isArray(entries)) {
    return [];
  }

  return entries
    .filter((entry): entry is UpgradeRecord => Boolean(entry && typeof entry === "object"))
    .map((entry) => ({
      ownerId: String(entry.ownerId ?? DEFAULT_USER_ID),
      sid: String(entry.sid ?? ""),
      visitorExtId: String(entry.visitorExtId ?? ""),
      type: String(entry.type ?? "0"),
      dayKey: String(entry.dayKey ?? "")
    }))
    .filter((entry) => entry.sid.length > 0 && entry.visitorExtId.length > 0 && entry.dayKey.length > 0);
}

export function setStoredUpgradeRecords(document: JsonObject, records: UpgradeRecord[]): void {
  document[NPC_UPGRADES_STATE_KEY] = records;
}

export function getLocalDayKey(dayOffset = 0): string {
  const now = new Date();
  if (dayOffset !== 0) {
    now.setDate(now.getDate() + dayOffset);
  }

  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}
