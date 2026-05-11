import { DEFAULT_USER_ID } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createNeighborUniverse } from "../saveDefaults.js";
import { createElement, findElementChild, getElementChildren } from "../saveTree.js";

export type MutableNode = JsonObject;

export const DEFAULT_CITY_NAME = "Chocolate Fields";
const HQ_SKINS = ["HeadQuarter_01", "HeadQuarter_02", "HeadQuarter_03", "HeadQuarter_04"];

export function getUniverseProfile(universe: JsonObject): MutableNode | undefined {
  const root = universe.universe;
  if (!Array.isArray(root)) {
    return undefined;
  }

  return root.find(
    (entry): entry is MutableNode =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Profile?: unknown }).Profile))
  );
}

export function getPlotsEntry(universe: JsonObject): MutableNode | undefined {
  const profile = getUniverseProfile(universe);
  if (!profile || !Array.isArray(profile.Profile)) {
    return undefined;
  }

  return profile.Profile.find(
    (entry): entry is MutableNode =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Plots?: unknown }).Plots))
  );
}

export function getWorldContainer(universe: JsonObject): MutableNode | undefined {
  const root = universe.universe;
  if (!Array.isArray(root)) {
    return undefined;
  }

  return root.find(
    (entry): entry is MutableNode =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { World?: unknown }).World))
  );
}

export function getCompanyEntryByWhose(universe: JsonObject, whose: string): MutableNode | undefined {
  const world = getWorldContainer(universe);
  if (!world || !Array.isArray(world.World)) {
    return undefined;
  }

  return world.World.find(
    (entry): entry is MutableNode =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Company?: unknown }).Company)) &&
      String((entry as { whose?: unknown }).whose ?? "") === whose
  );
}

export function getCompanyEntryBySid(universe: JsonObject, sid: string): MutableNode | undefined {
  if (sid.length === 0) {
    return undefined;
  }

  const world = getWorldContainer(universe);
  if (!world || !Array.isArray(world.World)) {
    return undefined;
  }

  return world.World.find(
    (entry): entry is MutableNode =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Company?: unknown }).Company)) &&
      String((entry as { sid?: unknown }).sid ?? "") === sid
  );
}

export function getMapEntry(universe: JsonObject): MutableNode | undefined {
  const world = getWorldContainer(universe);
  if (!world || !Array.isArray(world.World)) {
    return undefined;
  }

  return world.World.find(
    (entry): entry is MutableNode =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Map?: unknown }).Map))
  );
}

export function resolveTargetOwnerId(payload: Record<string, unknown>, preferredKey = "userId"): number {
  const rawValue = payload[preferredKey] ?? payload.targetUserId ?? payload.ownerId ?? DEFAULT_USER_ID;
  const ownerId = Number(rawValue);
  return Number.isFinite(ownerId) ? ownerId : DEFAULT_USER_ID;
}

export function resolveUpgradeOwnerId(payload: Record<string, unknown>, sid: string): number {
  const preferredOwnerId = resolveTargetOwnerId(payload, "ownerId");
  if (preferredOwnerId !== DEFAULT_USER_ID || sid.length === 0) {
    return preferredOwnerId;
  }

  const advisorUniverse = createNeighborUniverse(100, 0);
  if (advisorUniverse && findItemEntry(advisorUniverse, sid)) {
    return 100;
  }

  const sheikUniverse = createNeighborUniverse(101, 0);
  if (sheikUniverse && findItemEntry(sheikUniverse, sid)) {
    return 101;
  }

  return preferredOwnerId;
}

export function findItemEntry(
  universe: JsonObject,
  sid: string
): { companyEntry: MutableNode; companyChildren: JsonObject[]; itemEntry: MutableNode; index: number } | undefined {
  const world = getWorldContainer(universe);
  if (!world || !Array.isArray(world.World)) {
    return undefined;
  }

  for (const worldChild of world.World) {
    if (!worldChild || typeof worldChild !== "object" || !Array.isArray((worldChild as { Company?: unknown }).Company)) {
      continue;
    }

    const companyEntry = worldChild as MutableNode;
    const companyChildren = getElementChildren(companyEntry, "Company");
    const index = companyChildren.findIndex(
      (entry) =>
        Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Item?: unknown }).Item)) &&
        String((entry as { sid?: unknown }).sid ?? "") === sid
    );

    if (index !== -1) {
      return {
        companyEntry,
        companyChildren,
        itemEntry: companyChildren[index] as MutableNode,
        index
      };
    }
  }

  return undefined;
}

export function getItemStateEntry(itemEntry: MutableNode): MutableNode | undefined {
  return findElementChild(getElementChildren(itemEntry, "Item"), "State");
}

export function isUpgradeEligibleItem(universe: JsonObject, sid: string): boolean {
  const itemMatch = findItemEntry(universe, sid);
  if (!itemMatch) {
    return false;
  }

  const state = getItemStateEntry(itemMatch.itemEntry);
  const sku = String(itemMatch.itemEntry.sku ?? "");
  return sku !== "HeadQuarter" && String(state?.id ?? "") === "1" && String(state?.mode ?? "") === "4";
}

export function createItemEntry(payload: Record<string, unknown>, companyEntry: MutableNode): MutableNode {
  const itemChildren: JsonObject[] = [];
  const sku = String(payload.sku ?? "");
  const whose = String(companyEntry.whose ?? "0");

  if (sku === "HeadQuarter") {
    itemChildren.push(createElement("State", { id: "4" }));
    itemChildren.push(createHeadQuarterDecorations(whose === "1" ? "HeadQuarter_02" : "HeadQuarter_01"));
  } else {
    itemChildren.push(createElement("State", { id: String(payload.state ?? "5") }));
  }

  return createElement(
    "Item",
    {
      sid: String(payload.sid ?? ""),
      csid: String(companyEntry.sid ?? payload.csid ?? "1"),
      sku,
      x: String(payload.x ?? "0"),
      y: String(payload.y ?? "0"),
      isSuspended: String(payload.isSuspended ?? "0")
    },
    itemChildren
  );
}

export function ensureStateElement(children: JsonObject[], attributes: Record<string, string>): void {
  const stateEntry = findElementChild(children, "State");
  if (stateEntry) {
    Object.assign(stateEntry, attributes);
    return;
  }

  children.unshift(createElement("State", attributes));
}

export function ensureHeadQuarterDecorations(children: JsonObject[], whose: string): void {
  const existing = findElementChild(children, "Decorations");
  if (existing) {
    const decoration = findElementChild(getElementChildren(existing, "Decorations"), "Decoration");
    if (decoration) {
      decoration.currentSku = whose === "1" ? "HeadQuarter_02" : "HeadQuarter_01";
      return;
    }
  }

  children.push(createHeadQuarterDecorations(whose === "1" ? "HeadQuarter_02" : "HeadQuarter_01"));
}

export function createHeadQuarterDecorations(currentSku: string): JsonObject {
  return createElement("Decorations", {}, [
    createElement(
      "Decoration",
      {
        type: "0",
        currentSku,
        shadowRows: currentSku === "HeadQuarter_01" ? "0" : "1"
      },
      HQ_SKINS.map((sku) => createElement("sku", { id: sku }))
    )
  ]);
}

export function isItemElement(entry: MutableNode): boolean {
  return Array.isArray(entry.Item);
}

export function isHouseSku(sku: string): boolean {
  return sku.startsWith("houses_") || sku === "house_001";
}
