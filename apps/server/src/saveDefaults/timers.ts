import fs from "fs";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { loadConstructionTimeBySku } from "../rules.js";
import { leafElement } from "../saveTree.js";
import {
  DEFAULT_ABANDON_MINUTES,
  DEFAULT_ABANDON_TIME_PERCENTAGE
} from "./constants.js";
import {
  CONTRACTS_PATH,
  ITEM_DEFINITIONS_PATH,
  SETTINGS_PATH
} from "./paths.js";

const CONTRACT_INCOME_TIME_BY_SKU = loadContractIncomeTimeBySku(CONTRACTS_PATH);
const CONSTRUCTION_TIME_BY_SKU = loadConstructionTimeBySku(ITEM_DEFINITIONS_PATH);
const { minTimeMs: ABANDON_MIN_TIME_MS, percentage: ABANDON_TIME_PERCENTAGE } = loadAbandonTimingSettings(SETTINGS_PATH);

export function normalizeHouseRentState(state: JsonObject | undefined, itemChildren: JsonObject[], nowMs: number): boolean {
  if (!state) {
    itemChildren.unshift(leafElement("State", { id: "1", mode: "1", time: "0" }));
    return true;
  }

  let changed = false;
  if (String(state.id ?? "") !== "1") {
    state.id = "1";
    changed = true;
  }

  if (String(state.mode ?? "") === "1") {
    if (String(state.time ?? "") !== "0") {
      state.time = "0";
      changed = true;
    }
    for (const staleKey of ["contractSku", "contractGroupSku", "savedAt", "accelerated", "doubleRent"]) {
      if (staleKey in state) {
        delete state[staleKey];
        changed = true;
      }
    }
    return changed;
  }

  const contractSku = String(state.contractSku ?? "").trim();
  if (contractSku.length > 0) {
    let normalizedMode = String(state.mode ?? "");
    if (normalizedMode === "14" || normalizedMode === "15") {
      state.mode = "1";
      state.time = "0";
      for (const staleKey of ["contractSku", "contractGroupSku", "savedAt", "accelerated", "doubleRent"]) {
        if (staleKey in state) {
          delete state[staleKey];
        }
      }
      return true;
    }
    const abandonDurationMs = getAbandonTimeMs(contractSku, Number(state.time ?? "0"));
    if (
      normalizedMode !== "4" &&
      normalizedMode !== "5" &&
      normalizedMode !== "6" &&
      normalizedMode !== "14" &&
      normalizedMode !== "15" &&
      normalizedMode !== "7"
    ) {
      state.mode = "4";
      normalizedMode = "4";
      changed = true;
    }
    if (state.time == null || String(state.time).length === 0) {
      state.time = "0";
      changed = true;
    }
    const currentTime = Number(state.time ?? "0");
    const savedAt = Number(state.savedAt ?? "0");
    if (normalizedMode === "4" && Number.isFinite(currentTime) && currentTime > 0) {
      if (Number.isFinite(savedAt) && savedAt > 0) {
        const elapsed = Math.max(0, nowMs - savedAt);
        if (elapsed >= currentTime) {
          const overdueElapsed = elapsed - currentTime;
          if (overdueElapsed >= abandonDurationMs) {
            if (String(state.mode ?? "") !== "7") {
              state.mode = "7";
              changed = true;
            }
            if (String(state.time ?? "") !== "0") {
              state.time = "0";
              changed = true;
            }
          } else {
            const remainingAbandonTime = Math.max(0, abandonDurationMs - overdueElapsed);
            if (String(state.mode ?? "") !== "5") {
              state.mode = "5";
              changed = true;
            }
            if (String(state.time ?? "") !== String(remainingAbandonTime)) {
              state.time = String(remainingAbandonTime);
              changed = true;
            }
            if (String(state.savedAt ?? "") !== String(nowMs)) {
              state.savedAt = String(nowMs);
              changed = true;
            }
          }
        } else {
          const nextTime = currentTime - elapsed;
          if (String(state.time ?? "") !== String(nextTime)) {
            state.time = String(nextTime);
            changed = true;
          }
          if (String(state.savedAt ?? "") !== String(nowMs)) {
            state.savedAt = String(nowMs);
            changed = true;
          }
        }
      } else {
        state.savedAt = String(nowMs);
        changed = true;
      }
    } else if (normalizedMode === "5" || normalizedMode === "6") {
      if (Number.isFinite(currentTime) && currentTime > 0) {
        if (Number.isFinite(savedAt) && savedAt > 0) {
          const elapsed = Math.max(0, nowMs - savedAt);
          const nextTime = Math.max(0, currentTime - elapsed);
          if (nextTime === 0) {
            if (String(state.mode ?? "") !== "7") {
              state.mode = "7";
              changed = true;
            }
            if (String(state.time ?? "") !== "0") {
              state.time = "0";
              changed = true;
            }
          } else {
            if (normalizedMode === "6" && String(state.mode ?? "") !== "5") {
              state.mode = "5";
              changed = true;
            }
            if (String(state.time ?? "") !== String(nextTime)) {
              state.time = String(nextTime);
              changed = true;
            }
            if (String(state.savedAt ?? "") !== String(nowMs)) {
              state.savedAt = String(nowMs);
              changed = true;
            }
          }
        } else {
          state.savedAt = String(nowMs);
          changed = true;
        }
      } else {
        if (String(state.mode ?? "") !== "5") {
          state.mode = "5";
          changed = true;
        }
        if (String(state.time ?? "") !== String(abandonDurationMs)) {
          state.time = String(abandonDurationMs);
          changed = true;
        }
        if (String(state.savedAt ?? "") !== String(nowMs)) {
          state.savedAt = String(nowMs);
          changed = true;
        }
      }
    } else if (normalizedMode === "7") {
      if (String(state.time ?? "") !== "0") {
        state.time = "0";
        changed = true;
      }
    }
    return changed;
  }

  if (String(state.mode ?? "") !== "1") {
    state.mode = "1";
    changed = true;
  }
  if (String(state.time ?? "") !== "0") {
    state.time = "0";
    changed = true;
  }
  if ("accelerated" in state) {
    delete state.accelerated;
    changed = true;
  }
  return changed;
}

export function normalizeConstructionState(_itemSku: string, state: JsonObject, nowMs: number): boolean {
  const currentTime = Number(state.time ?? "0");
  const mode = String(state.mode ?? "");
  const savedAt = Number(state.savedAt ?? "0");
  const hasValidSavedAt = Number.isFinite(savedAt) && savedAt > 0;
  if (!Number.isFinite(currentTime) || currentTime <= 0) {
    if (String(state.time ?? "") !== "0") {
      state.time = "0";
      return true;
    }
    return false;
  }

  if (!hasValidSavedAt) {
    state.savedAt = String(nowMs);
    return true;
  }

  const elapsed = Math.max(0, nowMs - savedAt);
  const nextTime = Math.max(0, currentTime - elapsed);
  let changed = false;
  if (nextTime !== currentTime) {
    state.time = String(nextTime);
    changed = true;
  }
  if (String(state.savedAt ?? "") !== String(nowMs)) {
    state.savedAt = String(nowMs);
    changed = true;
  }
  return changed;
}

function getAbandonTimeMs(contractSku: string, fallbackTimeMs = 0): number {
  const contractIncomeTimeMs = CONTRACT_INCOME_TIME_BY_SKU.get(contractSku) ?? 0;
  const baseTimeMs = contractIncomeTimeMs > 0 ? contractIncomeTimeMs : Math.max(0, fallbackTimeMs);
  const calculatedMs = Math.round((baseTimeMs * ABANDON_TIME_PERCENTAGE) / 100);
  return Math.max(calculatedMs, ABANDON_MIN_TIME_MS);
}

function loadAbandonTimingSettings(filePath: string): { minTimeMs: number; percentage: number } {
  if (!fs.existsSync(filePath)) {
    return {
      minTimeMs: DEFAULT_ABANDON_MINUTES * 60 * 1000,
      percentage: DEFAULT_ABANDON_TIME_PERCENTAGE
    };
  }

  const xml = fs.readFileSync(filePath, "utf8");
  const minTimeMatch = xml.match(/abandonMinTime="([^"]+)"/);
  const percentageMatch = xml.match(/abandonTimePercentage="([^"]+)"/);
  const minTimeMinutes = Number(minTimeMatch?.[1] ?? DEFAULT_ABANDON_MINUTES);
  const percentage = Number(percentageMatch?.[1] ?? DEFAULT_ABANDON_TIME_PERCENTAGE);
  return {
    minTimeMs:
      Number.isFinite(minTimeMinutes) && minTimeMinutes > 0
        ? Math.round(minTimeMinutes * 60 * 1000)
        : DEFAULT_ABANDON_MINUTES * 60 * 1000,
    percentage:
      Number.isFinite(percentage) && percentage >= 0 ? percentage : DEFAULT_ABANDON_TIME_PERCENTAGE
  };
}

function loadContractIncomeTimeBySku(filePath: string): Map<string, number> {
  const durations = new Map<string, number>();
  if (!fs.existsSync(filePath)) {
    return durations;
  }

  const xml = fs.readFileSync(filePath, "utf8");
  const matches = xml.matchAll(/<Definition\s+sku="([^"]+)"[^>]*incomeTime="([^"]+)"/g);
  for (const match of matches) {
    const sku = String(match[1] ?? "").trim();
    const hours = Number(match[2] ?? "0");
    if (sku.length === 0 || !Number.isFinite(hours) || hours <= 0) {
      continue;
    }
    durations.set(sku, Math.round(hours * 60 * 60 * 1000));
  }
  return durations;
}
