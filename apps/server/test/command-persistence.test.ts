import { describe, expect, test } from "vitest";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createElement, findElementChild, getElementChildren } from "../src/saveTree.js";
import { addBoughtCrewPositions, getBoughtCrewPurchaseCost } from "../src/commandHandlers/crew.js";
import {
  claimDailyReward,
  getDailyRewardIntervalMs,
  prepareDailyRewards
} from "../src/commandHandlers/dailyRewards.js";
import {
  applyTimedServicePurchase,
  getTimedServicePurchaseCost,
  projectTimedServiceState
} from "../src/commandHandlers/services.js";
import {
  addStorageItem,
  getStorageItemAmount,
  parseBundleItems,
  removeStorageItem
} from "../src/commandHandlers/storage.js";

describe("original command persistence rules", () => {
  test("persists a daily reward roll and only accepts that selected reward", () => {
    const now = Date.UTC(2026, 6, 22, 12);
    const source: JsonObject = createElement("dailyBonusInfo", {
      dailyRewardsCount: "0",
      dailyRewardsLastGiven: "",
      dailyRewardsLastGivenDate: "0",
      dailyRewardsNextRewardId: ""
    });

    const first = prepareDailyRewards(source, now, () => 0);
    const second = prepareDailyRewards(first.stored, now, () => 0.999999);
    expect(first.eligible).toBe(true);
    expect(first.response.dailyRewardsCount).toBe("1");
    expect(second.response.dailyRewardsNextRewardId).toBe(first.response.dailyRewardsNextRewardId);

    const selectedSku = String(first.response.dailyRewardsNextRewardId);
    const otherGroupOneSku = selectedSku === "reward_02" ? "reward_03" : "reward_02";
    expect(claimDailyReward(first.stored, otherGroupOneSku, now)).toBeUndefined();

    const claim = claimDailyReward(first.stored, selectedSku, now);
    expect(claim?.document.dailyRewardsCount).toBe("1");
    expect(claim?.document.dailyRewardsLastGiven).toBe(selectedSku);
    const storedClaimDate = new Date(Number(claim?.document.dailyRewardsLastGivenDate));
    expect([storedClaimDate.getHours(), storedClaimDate.getMinutes()]).toEqual([0, 10]);
    expect([storedClaimDate.getSeconds(), storedClaimDate.getMilliseconds()]).toEqual([0, 0]);
    expect(claimDailyReward(claim?.document ?? first.stored, selectedSku, now)).toBeUndefined();
  });

  test("resets an expired daily reward streak before rolling day one", () => {
    const interval = getDailyRewardIntervalMs();
    const now = Date.UTC(2026, 6, 22, 12);
    const source: JsonObject = createElement("dailyBonusInfo", {
      dailyRewardsCount: "4",
      dailyRewardsLastGiven: "reward_01,reward_04,reward_07,reward_10",
      dailyRewardsLastGivenDate: String(now - interval * 3),
      dailyRewardsNextRewardId: "reward_10"
    });

    const prepared = prepareDailyRewards(source, now, () => 0);
    expect(prepared.response.dailyRewardsCount).toBe("1");
    expect(prepared.response.dailyRewardsLastGiven).toBe("");
    expect(prepared.response.dailyRewardsNextRewardId).toBe("reward_01");
  });

  test("persists unique crew purchases within the rule-defined slot count", () => {
    const item = createElement("Item", { sid: "club", sku: "club_001" });
    expect(getBoughtCrewPurchaseCost(item, "0,2")).toEqual({ cash: 4, companyValue: 240_000 });
    expect(addBoughtCrewPositions(item, "0,2")).toBe(true);
    expect(getBoughtCrewPurchaseCost(item, "2")).toBeUndefined();
    expect(addBoughtCrewPositions(item, "2")).toBe(false);
    expect(addBoughtCrewPositions(item, "3")).toBe(false);

    const crew = findElementChild(getElementChildren(item, "Item"), "Crew");
    expect(crew).toMatchObject({ ids: "", bought: "0,2" });
  });

  test("applies service durations and the free-contract cooldown", () => {
    const now = 1_720_000_000_000;
    const profile: JsonObject = {};
    expect(getTimedServicePurchaseCost({ value: "move", id: "0" })).toEqual({
      coins: 0,
      cash: 10,
      companyValue: 600_000
    });
    expect(getTimedServicePurchaseCost({ value: "moneyCollector", id: "0", offer: "1" })).toEqual({
      coins: 0,
      cash: 28,
      companyValue: 1_680_000
    });
    expect(getTimedServicePurchaseCost({ value: "moneyCollector", id: "4" })).toEqual({
      coins: 0,
      cash: 0,
      companyValue: 0
    });
    expect(applyTimedServicePurchase(profile, { value: "move", id: "0" }, now)).toBe(true);
    expect(profile.moveTimeOver).toBe(String(now + 24 * 60 * 60 * 1000));

    expect(applyTimedServicePurchase(profile, { value: "moneyCollector", id: "4" }, now)).toBe(true);
    expect(profile.moneyCollectorTimeOver).toBe(String(now + 0.1 * 60 * 60 * 1000));
    expect(profile.moneyCollector_3TimeOver).toBe(String(now + 48 * 60 * 60 * 1000));
    expect(applyTimedServicePurchase(profile, { value: "moneyCollector", id: "4" }, now + 1)).toBe(false);

    projectTimedServiceState(profile, now + 60 * 60 * 1000);
    expect(profile.moveTimeLeft).toBe(String(23 * 60 * 60 * 1000));
    expect(profile.moneyCollectorTimeLeft).toBe("0");
  });

  test("mutates storage counts atomically and parses bundle quantities", () => {
    const storage = createElement("storageList", {});
    expect(addStorageItem(storage, "move", 2, 20)).toBe(true);
    expect(removeStorageItem(storage, "move")).toBe(true);
    expect(getStorageItemAmount(storage, "move")).toBe(1);
    expect(removeStorageItem(storage, "move", 2)).toBe(false);
    expect(getStorageItemAmount(storage, "move")).toBe(1);
    expect(parseBundleItems("houses_001_001:2;move:3;houses_001_001:1")).toEqual([
      { sku: "houses_001_001", amount: 3 },
      { sku: "move", amount: 3 }
    ]);
  });
});
