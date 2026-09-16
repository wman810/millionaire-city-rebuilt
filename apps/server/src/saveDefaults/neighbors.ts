import {
  DEFAULT_ADVISOR_IDS,
  DEFAULT_LANG
} from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { cloneJsonValue } from "../saveTree.js";
import {
  NPC_PRIMARY_USER_ID,
  NPC_SHEIK_USER_ID
} from "./constants.js";
import { loadNpcWorldLayout } from "./npcLayoutXml.js";

export function createNeighborUniverse(targetUserId: number, bossGenre = 0): JsonObject | undefined {
  if (targetUserId === NPC_PRIMARY_USER_ID) {
    return createAdvisorNeighborUniverse(bossGenre);
  }

  if (targetUserId === NPC_SHEIK_USER_ID) {
    return createSheikNeighborUniverse();
  }

  return undefined;
}

function createAdvisorNeighborUniverse(bossGenre: number): JsonObject {
  const isCindy = bossGenre === 1;
  const layout = loadNpcWorldLayout("advisor");
  const profile = cloneJsonValue(layout.profile);
  const world = cloneJsonValue(layout.world);
  if (isCindy) {
    applyCindyWorldVariant(world);
  }

  return createNpcUniverseDocument({
    userId: NPC_PRIMARY_USER_ID,
    extId: isCindy ? "npc-cindy" : "npc-ronald",
    userName: isCindy ? "Cindy" : "Ronald",
    profile,
    world
  });
}

function createSheikNeighborUniverse(): JsonObject {
  const layout = loadNpcWorldLayout("sheik");

  return createNpcUniverseDocument({
    userId: NPC_SHEIK_USER_ID,
    extId: "npc-sheik",
    userName: "Sheik",
    profile: cloneJsonValue(layout.profile),
    world: cloneJsonValue(layout.world)
  });
}

function createNpcUniverseDocument(options: {
  userId: number;
  extId: string;
  userName: string;
  profile: JsonObject;
  world: JsonObject;
}): JsonObject {
  const profile = options.profile;
  const cityName = String(profile.cityname ?? "");
  profile.DCCashPaid ??= "0";
  profile.cityNameCodes ??= toAsciiCodes(cityName);
  profile.userName = options.userName;
  profile.profileId = String(options.userId);
  profile.extId = options.extId;
  profile.advisorId = DEFAULT_ADVISOR_IDS;
  profile.lang = DEFAULT_LANG;

  return {
    universe: [
      profile,
      options.world
    ]
  };
}

function applyCindyWorldVariant(world: JsonObject): void {
  const worldChildren = world.World;
  if (!Array.isArray(worldChildren)) {
    return;
  }

  for (const company of worldChildren) {
    if (!company || typeof company !== "object" || !Array.isArray((company as JsonObject).Company)) {
      continue;
    }

    for (const item of (company as JsonObject).Company as JsonObject[]) {
      if (String(item.sku ?? "") === "wonder_npc_Ronald") {
        item.sku = "wonder_npc_Cindy";
      }

      if (String(item.sku ?? "") !== "HeadQuarter" || !Array.isArray(item.Item)) {
        continue;
      }

      const decorations = (item.Item as JsonObject[]).find((entry) => Array.isArray(entry.Decorations));
      const decoration = decorations && Array.isArray(decorations.Decorations)
        ? (decorations.Decorations as JsonObject[]).find((entry) => Array.isArray(entry.Decoration))
        : undefined;
      if (decoration) {
        decoration.currentSku = "HeadQuarter_03";
      }
    }
  }
}

function toAsciiCodes(value: string): string {
  return Array.from(value).map((character) => character.charCodeAt(0)).join(",");
}
