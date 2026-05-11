import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createElement, leafElement } from "../saveTree.js";
import { STARTER_COMPANY_RIVAL_SID } from "./constants.js";

export function createCompanyElement(attributes: Record<string, string>, children: JsonObject[] = []): JsonObject {
  return createElement("Company", attributes, children);
}

export function createRivalSaleItem(sid: string, sku: string, x: string, y: string): JsonObject {
  return createElement(
    "Item",
    {
      sid,
      csid: STARTER_COMPANY_RIVAL_SID,
      sku,
      x,
      y,
      isSuspended: "0"
    },
    [leafElement("State", { id: "3", mode: "2", time: "0" })]
  );
}

export function createBuiltItem(sid: string, csid: string, sku: string, x: string, y: string): JsonObject {
  return createElement(
    "Item",
    {
      sid,
      csid,
      sku,
      x,
      y,
      isSuspended: "0"
    },
    [leafElement("State", { id: "5" })]
  );
}

export function createWaitingContractHouseItem(sid: string, csid: string, sku: string, x: string, y: string): JsonObject {
  return createElement(
    "Item",
    {
      sid,
      csid,
      sku,
      x,
      y,
      isSuspended: "0"
    },
    [leafElement("State", { id: "1", mode: "1", time: "0" })]
  );
}

export function createRentingIncomeItem(
  sid: string,
  csid: string,
  sku: string,
  x: string,
  y: string,
  contractSku = "1",
  time = "1800000"
): JsonObject {
  return createElement(
    "Item",
    {
      sid,
      csid,
      sku,
      x,
      y,
      isSuspended: "0"
    },
    [leafElement("State", { id: "1", mode: "4", time, contractSku })]
  );
}

export function createHeadQuarterItem(sid: string, csid: string, x: string, y: string, currentSku = "HeadQuarter_01"): JsonObject {
  return createElement(
    "Item",
    {
      sid,
      csid,
      sku: "HeadQuarter",
      x,
      y,
      isSuspended: "0"
    },
    [
      leafElement("State", { id: "4" }),
      createHeadQuarterDecorations(currentSku)
    ]
  );
}

export function createHeadQuarterDecorations(currentSku = "HeadQuarter_01"): JsonObject {
  return createElement("Decorations", {}, [
    createElement("Decoration", { type: "0", currentSku, shadowRows: currentSku === "HeadQuarter_01" ? "0" : "1" }, [
      leafElement("sku", { id: "HeadQuarter_01" }),
      leafElement("sku", { id: "HeadQuarter_02" }),
      leafElement("sku", { id: "HeadQuarter_03" }),
      leafElement("sku", { id: "HeadQuarter_04" })
    ])
  ]);
}

export function isItemElement(entry: JsonObject): boolean {
  return Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Item?: unknown }).Item));
}

export function isHouseSku(sku: string): boolean {
  return sku.startsWith("houses_");
}

export function getNextItemSid(items: JsonObject[]): number {
  let maxSid = 0;
  for (const item of items) {
    const sid = Number(String(item.sid ?? "0"));
    if (Number.isFinite(sid) && sid > maxSid) {
      maxSid = sid;
    }
  }
  return maxSid + 1;
}
