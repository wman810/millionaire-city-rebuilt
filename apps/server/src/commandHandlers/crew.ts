import path from "path";
import { loadCashToCoins, loadDefinitionAttributes } from "../rules.js";
import { createElement, findElementChild, getElementChildren } from "../saveTree.js";
import { RULES_ROOT } from "../saveDefaults/paths.js";
import type { MutableNode } from "./universe.js";

const CREW_JOB_COUNTS = loadCrewJobCounts(path.join(RULES_ROOT, "crewMechanicsDefinition.xml"));
const CREW_GOLD_PRICES = loadCrewGoldPrices(path.join(RULES_ROOT, "crewMechanicsDefinition.xml"));
const ITEM_CREWS = loadItemCrews(path.join(RULES_ROOT, "clubDefinitions.xml"));
const CASH_TO_COINS = loadCashToCoins(path.join(RULES_ROOT, "settings.xml"));

export function getBoughtCrewPurchaseCost(
  itemEntry: MutableNode,
  value: unknown
): { cash: number; companyValue: number } | undefined {
  const crewSku = ITEM_CREWS.get(String(itemEntry.sku ?? ""));
  const jobCount = crewSku ? CREW_JOB_COUNTS.get(crewSku) ?? 0 : 0;
  const price = crewSku ? CREW_GOLD_PRICES.get(crewSku) ?? 0 : 0;
  const positions = parsePositions(value);
  if (
    jobCount <= 0 ||
    price < 0 ||
    positions.length === 0 ||
    new Set(positions).size !== positions.length ||
    positions.some((position) => position < 0 || position >= jobCount)
  ) {
    return undefined;
  }

  const crew = findElementChild(getElementChildren(itemEntry, "Item"), "Crew");
  const bought = new Set(parsePositions(crew?.bought));
  if (positions.some((position) => bought.has(position))) {
    return undefined;
  }
  const cash = price * positions.length;
  return { cash, companyValue: cash * CASH_TO_COINS };
}

export function addBoughtCrewPositions(itemEntry: MutableNode, value: unknown): boolean {
  const crewSku = ITEM_CREWS.get(String(itemEntry.sku ?? ""));
  const jobCount = crewSku ? CREW_JOB_COUNTS.get(crewSku) ?? 0 : 0;
  if (jobCount <= 0) {
    return false;
  }

  const positions = parsePositions(value);
  if (
    positions.length === 0 ||
    new Set(positions).size !== positions.length ||
    positions.some((position) => position < 0 || position >= jobCount)
  ) {
    return false;
  }

  const itemChildren = getElementChildren(itemEntry, "Item");
  const crew = findElementChild(itemChildren, "Crew");
  const bought = parsePositions(crew?.bought);
  const boughtSet = new Set(bought);
  if (positions.some((position) => boughtSet.has(position))) {
    return false;
  }

  for (const position of positions) {
    boughtSet.add(position);
  }
  const boughtValue = Array.from(boughtSet).sort((left, right) => left - right).join(",");
  if (crew) {
    crew.bought = boughtValue;
    if (crew.ids == null) {
      crew.ids = "";
    }
  } else {
    itemChildren.push(createElement("Crew", { ids: "", bought: boughtValue }));
  }
  return true;
}

function parsePositions(value: unknown): number[] {
  const raw = String(value ?? "").trim();
  if (raw.length === 0) {
    return [];
  }

  const positions: number[] = [];
  for (const entry of raw.split(",")) {
    const normalized = entry.trim();
    if (!/^\d+$/.test(normalized)) {
      return [];
    }
    positions.push(Number(normalized));
  }
  return positions;
}

function loadCrewJobCounts(filePath: string): Map<string, number> {
  const result = new Map<string, number>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim() ?? "";
    const jobs = (definition.jobs ?? "")
      .split(",")
      .map((entry) => entry.trim())
      .filter((entry) => entry.length > 0);
    if (sku.length > 0 && jobs.length > 0) {
      result.set(sku, jobs.length);
    }
  }
  return result;
}

function loadCrewGoldPrices(filePath: string): Map<string, number> {
  const result = new Map<string, number>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim() ?? "";
    const price = Number(definition.goldPrice ?? "");
    if (sku.length > 0 && Number.isFinite(price) && price >= 0) {
      result.set(sku, Math.trunc(price));
    }
  }
  return result;
}

function loadItemCrews(filePath: string): Map<string, string> {
  const result = new Map<string, string>();
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim() ?? "";
    const crewSku = definition.constructionCrew?.trim() ?? "";
    if (sku.length > 0 && crewSku.length > 0) {
      result.set(sku, crewSku);
    }
  }
  return result;
}
