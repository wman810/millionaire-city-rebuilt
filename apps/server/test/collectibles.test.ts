import { describe, expect, test } from "vitest";
import {
  getCollectibleAwardSource,
  HOUSE_COLLECTIBLE_SLOT_EXPIRE_MS,
  pickCollectibleSkuForCommerce,
  reserveHouseCollectibleDropSlot,
  shouldAwardCommerceCollectibleDrop,
  shouldAwardHouseCollectibleDrop,
  type CollectiblesState
} from "../src/commandHandlers/collectibles.js";

function createCollectiblesState(objectCounts: Record<string, number> = {}): CollectiblesState {
  return {
    objectCounts: new Map(Object.entries(objectCounts)),
    rewards: new Set(),
    pendingBySid: new Map()
  };
}

describe("original collectible random rules", () => {
  test("uses the archived contract-duration chance table", () => {
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "1" }, () => 0.0125)).toBe(true);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "1" }, () => 0.012501)).toBe(false);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "4" }, () => 0.04)).toBe(false);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "5" }, () => 0.04)).toBe(true);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "7" }, () => 0.208333)).toBe(true);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "7" }, () => 0.208334)).toBe(false);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "8" }, () => 0.1375)).toBe(true);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "8" }, () => 0.137501)).toBe(false);
    expect(shouldAwardHouseCollectibleDrop({ contractSku: "missing" }, () => 0)).toBe(false);
  });

  test("uses the original one-percent commerce chance", () => {
    expect(shouldAwardCommerceCollectibleDrop(() => 0.01)).toBe(true);
    expect(shouldAwardCommerceCollectibleDrop(() => 0.010001)).toBe(false);
  });

  test("rolls when a house contract starts and when a commerce cycle resets", () => {
    expect(getCollectibleAwardSource({ action: "new_mode" }, "houses_001_001", "1", { mode: "4" })).toBe(
      "house"
    );
    expect(getCollectibleAwardSource({ action: "new_mode" }, "houses_001_001", "4", { mode: "5" })).toBeUndefined();
    expect(getCollectibleAwardSource({ action: "new_mode" }, "commerce_pizza", "6", { mode: "4" })).toBe(
      "commerce"
    );
    expect(getCollectibleAwardSource({ action: "new_mode" }, "commerce_pizza", "14", { mode: "4" })).toBe(
      "commerce"
    );
  });

  test("applies rarity, dependency, minimum weight, and the 99-piece cap", () => {
    expect(pickCollectibleSkuForCommerce("commerce_pizza", createCollectiblesState(), () => 0)).toBe("gift_037");
    expect(pickCollectibleSkuForCommerce("commerce_pizza", createCollectiblesState(), () => 0.25)).toBe(
      "gift_038"
    );

    const oneOwned = createCollectiblesState({ gift_037: 1 });
    expect(pickCollectibleSkuForCommerce("commerce_pizza", oneOwned, () => 20.999 / 96)).toBe("gift_037");
    expect(pickCollectibleSkuForCommerce("commerce_pizza", oneOwned, () => 21 / 96)).toBe("gift_038");

    const threeOwned = createCollectiblesState({ gift_037: 1, gift_038: 1, gift_039: 1 });
    expect(pickCollectibleSkuForCommerce("commerce_pizza", threeOwned, () => 39 / 64)).toBe("gift_040");

    const capped = createCollectiblesState({ gift_037: 99 });
    expect(pickCollectibleSkuForCommerce("commerce_pizza", capped, () => 0)).toBe("gift_038");

    const complete = createCollectiblesState({ gift_037: 99, gift_038: 1, gift_039: 1, gift_040: 1 });
    expect(pickCollectibleSkuForCommerce("commerce_pizza", complete, () => 0)).toBe("gift_037");
  });

  test("limits normal house drops to three rolling eight-hour slots", () => {
    const nowMs = 1_000;
    let expirations: number[] = [];
    for (let index = 0; index < 3; index += 1) {
      const reserved = reserveHouseCollectibleDropSlot(expirations, nowMs);
      expect(reserved).toBeDefined();
      expirations = reserved ?? expirations;
    }

    expect(reserveHouseCollectibleDropSlot(expirations, nowMs)).toBeUndefined();
    const firstExpiration = nowMs + HOUSE_COLLECTIBLE_SLOT_EXPIRE_MS;
    expect(reserveHouseCollectibleDropSlot(expirations, firstExpiration)).toBeUndefined();
    expect(reserveHouseCollectibleDropSlot(expirations, firstExpiration + 1)).toEqual([
      firstExpiration + 1 + HOUSE_COLLECTIBLE_SLOT_EXPIRE_MS,
      firstExpiration,
      firstExpiration
    ]);
  });
});
