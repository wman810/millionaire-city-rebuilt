import path from "path";
import { loadDefinitionAttributes } from "../rules.js";
import { RULES_ROOT } from "../saveDefaults/paths.js";

type ItemFootprint = {
  width: number;
  height: number;
};

const ITEM_FOOTPRINTS = loadItemFootprints([
  "itemDefinitions.xml",
  "commerceDefinitions.xml",
  "decorationDefinitions.xml",
  "wonderDefinitions.xml"
]);

export function applyMapTileMutation(
  terrainTiles: Set<string>,
  roadTiles: Set<string>,
  tileType: string,
  action: string,
  tileKey: string
): boolean {
  const normalizedType = tileType.toLowerCase();
  const targetTiles = normalizedType === "terrain"
    ? terrainTiles
    : normalizedType === "road"
      ? roadTiles
      : undefined;
  if (!targetTiles || tileKey.length === 0) {
    return false;
  }

  if (action === "add") {
    const oppositeTiles = normalizedType === "terrain" ? roadTiles : terrainTiles;
    if (targetTiles.has(tileKey) || oppositeTiles.has(tileKey)) {
      return false;
    }
    targetTiles.add(tileKey);
    return true;
  }

  if (action === "del") {
    if (!targetTiles.has(tileKey)) {
      return false;
    }
    targetTiles.delete(tileKey);
    return true;
  }

  return false;
}

export function addTerrainFootprint(
  terrainTiles: Set<string>,
  roadTiles: Set<string>,
  sku: string,
  xValue: unknown,
  yValue: unknown
): boolean {
  const footprint = ITEM_FOOTPRINTS.get(sku);
  const startX = Number(xValue);
  const startY = Number(yValue);
  if (!footprint || !Number.isInteger(startX) || !Number.isInteger(startY)) {
    return false;
  }

  let changed = false;
  for (let y = startY; y < startY + footprint.height; y += 1) {
    for (let x = startX; x < startX + footprint.width; x += 1) {
      changed = applyMapTileMutation(terrainTiles, roadTiles, "terrain", "add", `${x}:${y}`) || changed;
    }
  }
  return changed;
}

function loadItemFootprints(fileNames: string[]): Map<string, ItemFootprint> {
  const footprints = new Map<string, ItemFootprint>();
  for (const fileName of fileNames) {
    for (const definition of loadDefinitionAttributes(path.join(RULES_ROOT, fileName))) {
      const sku = String(definition.sku ?? "").trim();
      const width = Number(definition.baseCols ?? "0");
      const height = Number(definition.baseRows ?? "0");
      if (!sku || !Number.isInteger(width) || width <= 0 || !Number.isInteger(height) || height <= 0) {
        continue;
      }
      footprints.set(sku, { width, height });
    }
  }
  return footprints;
}
