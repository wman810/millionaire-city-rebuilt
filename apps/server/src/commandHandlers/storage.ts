import path from "path";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { loadDefinitionAttributes } from "../rules.js";
import { RULES_ROOT } from "../saveDefaults/paths.js";
import { createElement, getElementChildren } from "../saveTree.js";

type StorageEntry = JsonObject & {
  sku?: string;
  amount?: string;
};

export type BundleItem = {
  sku: string;
  amount: number;
};

export type BoxPrizeDefinition = {
  sku: string;
  sourceSku: string;
  type: string;
  value: string;
};

const BOX_PRIZES = loadBoxPrizes(path.join(RULES_ROOT, "boxPrizeDefinition.xml"));
const BOX_SEQUENCES = loadBoxSequences(path.join(RULES_ROOT, "giftSequenceDefinition.xml"), BOX_PRIZES);
const GIFT_STORAGE_RULES = loadGiftStorageRules(path.join(RULES_ROOT, "giftDefinitions.xml"));
const STORAGE_MAXIMUMS = GIFT_STORAGE_RULES.maximums;

export function getBoxPrizeDefinition(sku: string): BoxPrizeDefinition | undefined {
  return BOX_PRIZES.get(sku);
}

export function getBoxPrizeSequence(sourceSku: string): readonly BoxPrizeDefinition[] {
  return BOX_SEQUENCES.get(sourceSku) ?? [];
}

export function getStorageMaximumForSku(sku: string): number {
  return STORAGE_MAXIMUMS.get(sku) ?? Number.POSITIVE_INFINITY;
}

export function resolveGiftStorageSku(definitionSku: string): string | undefined {
  return GIFT_STORAGE_RULES.storageSkuByDefinition.get(definitionSku);
}

export function normalizeStorageDocument(document: JsonObject): boolean {
  if (Array.isArray(document.storageList) || Array.isArray(document.storage)) {
    return false;
  }

  document.storageList = [];
  return true;
}

export function getStorageItemAmount(document: JsonObject, sku: string): number {
  const entry = findStorageEntry(document, sku);
  return entry ? readAmount(entry.amount) : 0;
}

export function addStorageItem(
  document: JsonObject,
  sku: string,
  amount = 1,
  maximum = Number.POSITIVE_INFINITY
): boolean {
  const normalizedSku = sku.trim();
  const normalizedAmount = Math.trunc(amount);
  if (normalizedSku.length === 0 || !Number.isFinite(normalizedAmount) || normalizedAmount <= 0) {
    return false;
  }

  const children = getStorageChildren(document);
  const existing = findStorageEntry(document, normalizedSku);
  const currentAmount = existing ? readAmount(existing.amount) : 0;
  const cappedMaximum = Number.isFinite(maximum) ? Math.max(0, Math.trunc(maximum)) : Number.POSITIVE_INFINITY;
  const nextAmount = Math.min(cappedMaximum, currentAmount + normalizedAmount);
  if (nextAmount <= currentAmount) {
    return false;
  }

  if (existing) {
    existing.amount = String(nextAmount);
  } else {
    children.push(createElement("item", { sku: normalizedSku, amount: String(nextAmount) }));
  }
  return true;
}

export function removeStorageItem(document: JsonObject, sku: string, amount = 1): boolean {
  const normalizedSku = sku.trim();
  const normalizedAmount = Math.trunc(amount);
  if (normalizedSku.length === 0 || !Number.isFinite(normalizedAmount) || normalizedAmount <= 0) {
    return false;
  }

  const children = getStorageChildren(document);
  const index = children.findIndex((entry) => isStorageEntry(entry) && String(entry.sku ?? "") === normalizedSku);
  if (index < 0) {
    return false;
  }

  const entry = children[index] as StorageEntry;
  const currentAmount = readAmount(entry.amount);
  if (currentAmount < normalizedAmount) {
    return false;
  }

  const nextAmount = currentAmount - normalizedAmount;
  if (nextAmount === 0) {
    children.splice(index, 1);
  } else {
    entry.amount = String(nextAmount);
  }
  return true;
}

export function findBundleItems(document: JsonObject, bundleSku: string): BundleItem[] {
  const normalizedSku = bundleSku.trim();
  if (normalizedSku.length === 0) {
    return [];
  }

  const candidate = findObjectRecursive(document, (entry) => {
    return String(entry.sku ?? "") === normalizedSku && typeof entry.items === "string";
  });
  return candidate ? parseBundleItems(String(candidate.items ?? "")) : [];
}

export function parseBundleItems(value: string): BundleItem[] {
  const items = new Map<string, number>();
  for (const rawEntry of value.split(";")) {
    const [rawSku, rawAmount] = rawEntry.split(":");
    const sku = rawSku?.trim() ?? "";
    const amount = Number(rawAmount ?? "1");
    if (sku.length === 0 || !Number.isFinite(amount) || amount <= 0) {
      continue;
    }
    items.set(sku, (items.get(sku) ?? 0) + Math.trunc(amount));
  }

  return Array.from(items, ([sku, amount]) => ({ sku, amount }));
}

function getStorageChildren(document: JsonObject): JsonObject[] {
  normalizeStorageDocument(document);
  return Array.isArray(document.storageList)
    ? getElementChildren(document, "storageList")
    : getElementChildren(document, "storage");
}

function findStorageEntry(document: JsonObject, sku: string): StorageEntry | undefined {
  return getStorageChildren(document).find(
    (entry): entry is StorageEntry => isStorageEntry(entry) && String(entry.sku ?? "") === sku
  );
}

function isStorageEntry(value: JsonObject): value is StorageEntry {
  return Array.isArray(value.item);
}

function readAmount(value: unknown): number {
  const amount = Number(value ?? 0);
  return Number.isFinite(amount) && amount > 0 ? Math.trunc(amount) : 0;
}

function findObjectRecursive(
  value: JsonObject,
  predicate: (entry: JsonObject) => boolean
): JsonObject | undefined {
  if (predicate(value)) {
    return value;
  }

  for (const child of Object.values(value)) {
    if (Array.isArray(child)) {
      for (const entry of child) {
        if (!entry || typeof entry !== "object" || Array.isArray(entry)) {
          continue;
        }
        const found = findObjectRecursive(entry as JsonObject, predicate);
        if (found) {
          return found;
        }
      }
    } else if (child && typeof child === "object") {
      const found = findObjectRecursive(child as JsonObject, predicate);
      if (found) {
        return found;
      }
    }
  }

  return undefined;
}

function loadBoxPrizes(filePath: string): Map<string, BoxPrizeDefinition> {
  const prizes = new Map<string, BoxPrizeDefinition>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim() ?? "";
    const sourceSku = definition.item?.trim() ?? "";
    const type = definition.giftType?.trim().toLowerCase() ?? "";
    if (sku.length === 0 || sourceSku.length === 0 || type.length === 0) {
      continue;
    }
    prizes.set(sku, {
      sku,
      sourceSku,
      type,
      value: definition.value?.trim() ?? ""
    });
  }
  return prizes;
}

function loadBoxSequences(
  filePath: string,
  prizes: Map<string, BoxPrizeDefinition>
): Map<string, BoxPrizeDefinition[]> {
  const sequences = new Map<string, BoxPrizeDefinition[]>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const prize = prizes.get(definition.sku?.trim() ?? "");
    if (!prize) {
      continue;
    }
    const sequence = sequences.get(prize.sourceSku) ?? [];
    sequence.push(prize);
    sequences.set(prize.sourceSku, sequence);
  }
  return sequences;
}

function loadGiftStorageRules(filePath: string): {
  maximums: Map<string, number>;
  storageSkuByDefinition: Map<string, string>;
} {
  const maximums = new Map<string, number>();
  const storageSkuByDefinition = new Map<string, string>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const definitionSku = definition.sku?.trim() ?? "";
    const giftType = definition.giftType?.trim() ?? "";
    const value = definition.value?.trim() ?? "";
    const maximum = Number(definition.maxAmount ?? "");
    if (giftType.length === 0 || !Number.isFinite(maximum) || maximum < 0) {
      continue;
    }
    const storageSku = giftType === "item" && value.length > 0 ? value : giftType;
    if (definitionSku.length > 0) {
      storageSkuByDefinition.set(definitionSku, storageSku);
    }
    const previous = maximums.get(storageSku);
    maximums.set(storageSku, previous == null ? Math.trunc(maximum) : Math.max(previous, Math.trunc(maximum)));
  }
  return { maximums, storageSkuByDefinition };
}
