import type { JsonObject } from "@mcity/shared/dist/types.js";
import { addStorageItem, getStorageItemAmount } from "./commandHandlers/storage.js";
import { loadDefinitionAttributes } from "./rules.js";

export interface FreeGiftDefinition {
  sku: string;
  storageSku: string;
  amount: number;
  maximum: number;
  unlockLevel: number;
}

export type FreeGiftGrantResult =
  | {
      ok: true;
      definitionSku: string;
      storageSku: string;
      added: number;
      amount: number;
      maximum: number;
    }
  | {
      ok: false;
      reason: "unknown" | "locked" | "full";
      unlockLevel?: number;
    };

export function loadFreeGiftDefinitions(filePath: string): Map<string, FreeGiftDefinition> {
  const definitions = new Map<string, FreeGiftDefinition>();

  for (const attributes of loadDefinitionAttributes(filePath)) {
    const sku = attributes.sku?.trim() ?? "";
    const giftType = attributes.giftType?.trim() ?? "";
    const value = attributes.value?.trim() ?? "";
    const maximum = readNonNegativeInteger(attributes.maxAmount, -1);
    const unlockLevel = readNonNegativeInteger(attributes.unlockValue, 0);
    if (
      sku.length === 0 ||
      giftType.length === 0 ||
      maximum < 0 ||
      attributes.disabled?.trim() === "1"
    ) {
      continue;
    }

    const storageSku = giftType === "item" ? value : giftType;
    if (storageSku.length === 0) {
      continue;
    }

    const amount = giftType === "move" ? Math.max(1, readNonNegativeInteger(value, 1)) : 1;
    definitions.set(sku, {
      sku,
      storageSku,
      amount,
      maximum,
      unlockLevel
    });
  }

  return definitions;
}

export function grantFreeGiftToStorage(
  storage: JsonObject,
  definitions: ReadonlyMap<string, FreeGiftDefinition>,
  definitionSku: string,
  playerLevel: number
): FreeGiftGrantResult {
  const definition = definitions.get(definitionSku.trim());
  if (!definition) {
    return { ok: false, reason: "unknown" };
  }
  if (!Number.isFinite(playerLevel) || Math.floor(playerLevel) < definition.unlockLevel) {
    return { ok: false, reason: "locked", unlockLevel: definition.unlockLevel };
  }

  const previousAmount = getStorageItemAmount(storage, definition.storageSku);
  if (!addStorageItem(storage, definition.storageSku, definition.amount, definition.maximum)) {
    return { ok: false, reason: "full" };
  }

  const amount = getStorageItemAmount(storage, definition.storageSku);
  return {
    ok: true,
    definitionSku: definition.sku,
    storageSku: definition.storageSku,
    added: amount - previousAmount,
    amount,
    maximum: definition.maximum
  };
}

function readNonNegativeInteger(value: unknown, fallback: number): number {
  const parsed = Number(value ?? fallback);
  return Number.isFinite(parsed) && parsed >= 0 ? Math.floor(parsed) : fallback;
}
