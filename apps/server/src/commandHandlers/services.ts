import path from "path";
import { loadCashToCoins, loadDefinitionAttributes } from "../rules.js";
import { RULES_ROOT } from "../saveDefaults/paths.js";
import type { MutableNode } from "./universe.js";

type ServiceDefinition = {
  sku: string;
  contractId: number;
  durationMs: number;
  waitingMs: number;
  waitingMaxUses: number;
  priceCoins: number;
  priceCash: number;
  offerPriceCoins: number;
  offerPriceCash: number;
};

const SERVICE_DEFINITIONS = loadServiceDefinitions(path.join(RULES_ROOT, "servicesDefinitions.xml"));
const SETTINGS = loadDefinitionAttributes(path.join(RULES_ROOT, "settings.xml"))[0] ?? {};
const CASH_TO_COINS = loadCashToCoins(path.join(RULES_ROOT, "settings.xml"));
export const NEW_ITEMS_REVISION = String(SETTINGS.newItemsRev ?? "1");

export function isKnownServiceSku(sku: string): boolean {
  return SERVICE_DEFINITIONS.some((definition) => definition.sku === sku);
}

export function getTimedServicePurchaseCost(payload: Record<string, unknown>): {
  coins: number;
  cash: number;
  companyValue: number;
} | undefined {
  const sku = String(payload.value ?? "").trim();
  const contractId = Number(payload.id ?? 0);
  const definition = SERVICE_DEFINITIONS.find(
    (entry) => entry.sku === sku && entry.contractId === contractId
  );
  if (!definition) {
    return undefined;
  }
  const offer = String(payload.offer ?? "0") === "1";
  const coins = offer ? definition.offerPriceCoins : definition.priceCoins;
  const cash = offer ? definition.offerPriceCash : definition.priceCash;
  return { coins, cash, companyValue: coins + cash * CASH_TO_COINS };
}

export function applyTimedServicePurchase(
  profile: MutableNode,
  payload: Record<string, unknown>,
  nowMs: number
): boolean {
  const sku = String(payload.value ?? "").trim();
  const contractId = Number(payload.id ?? 0);
  if (sku.length === 0 || !Number.isInteger(contractId) || contractId < 0) {
    return false;
  }

  const definition = SERVICE_DEFINITIONS.find(
    (entry) => entry.sku === sku && entry.contractId === contractId
  );
  if (!definition) {
    return false;
  }

  if (definition.waitingMs > 0) {
    const waitingKey = `${sku}_3TimeOver`;
    const currentWaitingEnd = Number(profile[waitingKey] ?? 0);
    if (Number.isFinite(currentWaitingEnd) && currentWaitingEnd > nowMs) {
      return false;
    }

    const usesKey = `${sku}_3UsesCount`;
    const currentUses = readNonNegativeInteger(profile[usesKey]);
    const nextUses = Math.min(definition.waitingMaxUses, currentUses + 1);
    profile[waitingKey] = String(nowMs + definition.waitingMs);
    profile[usesKey] = String(nextUses);
  }
  profile[`${sku}TimeOver`] = String(nowMs + definition.durationMs);
  return true;
}

export function projectTimedServiceState(profile: MutableNode | undefined, nowMs: number): void {
  if (!profile) {
    return;
  }

  for (const [key, rawValue] of Object.entries(profile)) {
    if (!key.endsWith("TimeOver")) {
      continue;
    }
    const timeOver = Number(rawValue);
    if (!Number.isFinite(timeOver)) {
      continue;
    }
    const sku = key.slice(0, -"TimeOver".length);
    profile[`${sku}TimeLeft`] = String(Math.max(0, timeOver - nowMs));
  }
}

function loadServiceDefinitions(filePath: string): ServiceDefinition[] {
  const contractIds = new Map<string, number>();
  const definitions: ServiceDefinition[] = [];
  for (const definition of loadDefinitionAttributes(filePath)) {
    const sku = definition.sku?.trim() ?? "";
    const durationHours = Number(definition.timeDuration ?? "");
    if (sku.length === 0 || !Number.isFinite(durationHours) || durationHours < 0) {
      continue;
    }

    const contractId = contractIds.get(sku) ?? 0;
    contractIds.set(sku, contractId + 1);
    const waitingHours = readNonNegativeNumber(definition.timeExpired);
    definitions.push({
      sku,
      contractId,
      durationMs: durationHours * 60 * 60 * 1000,
      waitingMs: waitingHours * 60 * 60 * 1000,
      waitingMaxUses: readNonNegativeInteger(definition.timeExpiredMax),
      priceCoins: readNonNegativeInteger(definition.priceCoins),
      priceCash: readNonNegativeInteger(definition.priceCash),
      offerPriceCoins: readNonNegativeInteger(definition.priceCoins),
      offerPriceCash: readNonNegativeInteger(definition.offerPriceCash)
    });
  }
  return definitions;
}

function readNonNegativeNumber(value: unknown): number {
  const number = Number(value ?? 0);
  return Number.isFinite(number) && number >= 0 ? number : 0;
}

function readNonNegativeInteger(value: unknown): number {
  return Math.trunc(readNonNegativeNumber(value));
}
