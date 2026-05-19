import path from "path";
import { loadCashToCoins, loadGoldPackageRewards } from "../rules.js";
import type { MutableNode } from "./universe.js";

const RULES_ROOT = path.resolve(__dirname, "../../../../assets/dchoc1-a.akamaihd.net/0.501/mcity/Datas/rules");
const SETTINGS_PATH = path.join(RULES_ROOT, "settings.xml");
const GOLD_PACKAGE_REWARDS = loadGoldPackageRewards(path.join(RULES_ROOT, "fbcredits.xml"));
const CASH_TO_COINS = loadCashToCoins(SETTINGS_PATH);

export function hasMoneySecuritySnapshot(security: Record<string, unknown> | undefined): boolean {
  if (!security) {
    return false;
  }

  return ["expNow", "coinsNow", "cashNow", "compValueNow", "expGain", "coinsGain", "cashGain", "compValueGain"].some(
    (key) => Number.isFinite(Number(security[key] ?? Number.NaN))
  );
}

export function applyMoneySecuritySnapshot(profile: MutableNode, security: Record<string, unknown> | undefined): void {
  if (!security) {
    return;
  }

  applyMoneySecurityField(profile, security, "exp", "expNow", "expGain");
  applyMoneySecurityField(profile, security, "DCCoins", "coinsNow", "coinsGain");
  applyMoneySecurityField(profile, security, "DCCash", "cashNow", "cashGain");
  applyMoneySecurityField(profile, security, "companyValue", "compValueNow", "compValueGain");
}

export function reconcilePremiumCurrencyPurchase(
  profile: MutableNode,
  payload: Record<string, unknown>,
  state: {
    previousCash: number;
    previousPaidCash: number;
    hadSecuritySnapshot: boolean;
  }
): void {
  if (String(payload.action ?? "") !== "buyGold") {
    return;
  }

  const reward = GOLD_PACKAGE_REWARDS.get(String(payload.sku ?? "").trim());
  if (!reward) {
    return;
  }

  const currentCash = Number(profile.DCCash ?? "0");
  const currentPaidCash = Number(profile.DCCashPaid ?? "0");
  const currentCompanyValue = Number(profile.companyValue ?? "0");
  const awardedCash = reward.gold + reward.freeGold;

  if (!Number.isFinite(currentCash) || !Number.isFinite(currentPaidCash) || !Number.isFinite(currentCompanyValue)) {
    return;
  }

  if (currentCash > state.previousCash) {
    if (currentPaidCash <= state.previousPaidCash) {
      profile.DCCashPaid = String(state.previousPaidCash + reward.gold);
    }
    return;
  }

  if (state.hadSecuritySnapshot || currentPaidCash > state.previousPaidCash) {
    return;
  }

  profile.DCCash = String(state.previousCash + awardedCash);
  profile.DCCashPaid = String(state.previousPaidCash + reward.gold);
  profile.companyValue = String(currentCompanyValue + awardedCash * CASH_TO_COINS);
}

export function hasNegativeSecurityDelta(value: Record<string, unknown> | undefined): boolean {
  if (!value) {
    return false;
  }

  return ["expGain", "coinsGain", "cashGain", "compValueGain"].some((key) => {
    const delta = Number(value[key] ?? 0);
    return Number.isFinite(delta) && delta < 0;
  });
}

function applyMoneySecurityField(
  profile: MutableNode,
  security: Record<string, unknown>,
  targetKey: string,
  absoluteKey: string,
  deltaKey: string
): void {
  const absoluteValue = Number(security[absoluteKey] ?? Number.NaN);
  if (Number.isFinite(absoluteValue)) {
    profile[targetKey] = String(absoluteValue);
    return;
  }

  const deltaValue = Number(security[deltaKey] ?? Number.NaN);
  if (!Number.isFinite(deltaValue) || deltaValue === 0) {
    return;
  }

  const currentValue = Number(profile[targetKey] ?? "0");
  if (!Number.isFinite(currentValue)) {
    return;
  }

  profile[targetKey] = String(currentValue + deltaValue);
}
