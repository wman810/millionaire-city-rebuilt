import fs from "fs";

export type GoldPackageReward = {
  gold: number;
  freeGold: number;
};

export function parseXmlAttributes(attributeBlob: string): Record<string, string> {
  const attributes: Record<string, string> = {};
  for (const match of attributeBlob.matchAll(/([A-Za-z0-9_]+)="([^"]*)"/g)) {
    attributes[match[1]] = match[2];
  }
  return attributes;
}

export function loadDefinitionAttributes(filePath: string): Array<Record<string, string>> {
  if (!fs.existsSync(filePath)) {
    return [];
  }

  const xml = fs.readFileSync(filePath, "utf8");
  const definitions: Array<Record<string, string>> = [];
  for (const match of xml.matchAll(/<Definition\b([^>]*)\/>/g)) {
    definitions.push(parseXmlAttributes(match[1] ?? ""));
  }
  return definitions;
}

export function loadCashToCoins(filePath: string): number {
  const settings = loadDefinitionAttributes(filePath)[0];
  const cashToCoins = Number(settings?.cashToCoins ?? "60000");
  return Number.isFinite(cashToCoins) && cashToCoins > 0 ? Math.floor(cashToCoins) : 60000;
}

export function loadCollectibleUnlockLevel(filePath: string): number {
  const settings = loadDefinitionAttributes(filePath)[0];
  const level = Number(settings?.collectibleUnlockLevel ?? "6");
  return Number.isFinite(level) && level >= 1 ? Math.floor(level) : 6;
}

export function loadConstructionTimeBySku(filePath: string): Map<string, number> {
  const definitions = loadDefinitionAttributes(filePath);
  const durations = new Map<string, number>();
  for (const definition of definitions) {
    const sku = definition.sku?.trim();
    const constructionTimeMinutes = Number(definition.constructionTime ?? "0");
    if (!sku || !Number.isFinite(constructionTimeMinutes) || constructionTimeMinutes <= 0) {
      continue;
    }
    durations.set(sku, Math.round(constructionTimeMinutes * 60 * 1000));
  }
  return durations;
}

export function loadGoldPackageRewards(filePath: string): Map<string, GoldPackageReward> {
  const definitions = loadDefinitionAttributes(filePath);
  const rewards = new Map<string, GoldPackageReward>();
  for (const definition of definitions) {
    const itemId = definition.item_id?.trim();
    const gold = Number(definition.gold ?? "0");
    const freeGold = Number(definition.freeGold ?? "0");
    if (!itemId || !Number.isFinite(gold) || !Number.isFinite(freeGold)) {
      continue;
    }
    rewards.set(itemId, {
      gold: Math.max(0, Math.floor(gold)),
      freeGold: Math.max(0, Math.floor(freeGold))
    });
  }
  return rewards;
}

export function loadLevelXpThresholds(filePath: string): number[] {
  if (!fs.existsSync(filePath)) {
    return [0];
  }

  const xml = fs.readFileSync(filePath, "utf8");
  const thresholds: number[] = [];
  for (const match of xml.matchAll(/<level\b([^>]*)\/>/g)) {
    const attributes = parseXmlAttributes(match[1] ?? "");
    const xpNeed = Number(attributes.xpneed ?? "");
    if (Number.isFinite(xpNeed)) {
      thresholds.push(xpNeed);
    }
  }

  return thresholds.length > 0 ? thresholds : [0];
}
