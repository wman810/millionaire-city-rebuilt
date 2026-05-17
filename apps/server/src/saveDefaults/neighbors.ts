import {
  DEFAULT_ADVISOR_IDS,
  DEFAULT_LANG
} from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createElement, leafElement } from "../saveTree.js";
import {
  NPC_PRIMARY_USER_ID,
  NPC_SHEIK_USER_ID,
  STARTER_COMPANY_MINE_SID,
  STARTER_COMPANY_RIVAL_SID,
  STARTER_WORLD_SID
} from "./constants.js";
import {
  createCompanyElement,
  createHeadQuarterItem
} from "./items.js";
import {
  RONALD_LAYOUT_ITEMS,
  RONALD_PLOTS_TYPE,
  RONALD_ROAD_RANGES,
  RONALD_TERRAIN_RANGES,
  type RonaldLayoutItem,
  type RonaldLayoutItemState
} from "./ronaldLayout.js";
import {
  SHEIK_LAYOUT_ITEMS,
  SHEIK_PLOTS_TYPE,
  SHEIK_ROAD_RANGES,
  SHEIK_TERRAIN_RANGES,
  type SheikLayoutItem,
  type SheikLayoutItemState,
  type TileRange
} from "./sheikLayout.js";

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

  return createNpcUniverseDocument({
    userId: NPC_PRIMARY_USER_ID,
    extId: isCindy ? "npc-cindy" : "npc-ronald",
    userName: isCindy ? "Cindy" : "Ronald",
    cityName: "Chocolate Fields",
    companyValue: isCindy ? "115000000" : "100000000",
    hqSkin: isCindy ? "HeadQuarter_03" : "HeadQuarter_02",
    planeSku: "plane_03",
    plotsType: RONALD_PLOTS_TYPE,
    terrainTiles: expandTileRanges(RONALD_TERRAIN_RANGES),
    roadTiles: expandTileRanges(RONALD_ROAD_RANGES),
    items: RONALD_LAYOUT_ITEMS.map((layoutItem) =>
      createCapturedLayoutItem(layoutItem, isCindy ? "HeadQuarter_03" : "HeadQuarter_02")
    )
  });
}

function createSheikNeighborUniverse(): JsonObject {
  return createNpcUniverseDocument({
    userId: NPC_SHEIK_USER_ID,
    extId: "npc-sheik",
    userName: "Sheik",
    cityName: "Sheik's City",
    companyValue: "900000000",
    hqSkin: "HeadQuarter_04",
    planeSku: "plane_04",
    plotsType: SHEIK_PLOTS_TYPE,
    terrainTiles: expandTileRanges(SHEIK_TERRAIN_RANGES),
    roadTiles: expandTileRanges(SHEIK_ROAD_RANGES),
    items: SHEIK_LAYOUT_ITEMS.map((layoutItem) => createCapturedLayoutItem(layoutItem, "HeadQuarter_04"))
  });
}

function createCapturedLayoutItem(layoutItem: SheikLayoutItem | RonaldLayoutItem, hqSkin: string): JsonObject {
  const [sid, sku, x, y, type, state, savedAt] = layoutItem;
  if (state === "hq") {
    return createHeadQuarterItem(sid, STARTER_COMPANY_MINE_SID, x, y, hqSkin);
  }

  const attributes: Record<string, string> = {
    sid,
    csid: STARTER_COMPANY_MINE_SID,
    sku,
    x,
    y,
    isSuspended: "0"
  };
  if (type) {
    attributes.type = type;
  }

  return createElement("Item", attributes, [leafElement("State", createCapturedLayoutState(state, savedAt))]);
}

function createCapturedLayoutState(
  state: SheikLayoutItemState | RonaldLayoutItemState,
  savedAt?: string
): Record<string, string> {
  if (state === "built") {
    return { id: "5" };
  }

  if (state === "waiting") {
    return { id: "1", mode: "1", time: "0" };
  }

  const rentingState: Record<string, string> = { id: "1", mode: "4", time: "180000" };
  if (savedAt) {
    rentingState.savedAt = savedAt;
  }
  return rentingState;
}

function expandTileRanges(ranges: readonly TileRange[]): string[] {
  const tiles: string[] = [];
  for (const [y, startX, endX] of ranges) {
    for (let x = startX; x <= endX; x += 1) {
      tiles.push(`${x}:${y}`);
    }
  }
  return tiles;
}

function createNpcUniverseDocument(options: {
  userId: number;
  extId: string;
  userName: string;
  cityName: string;
  companyValue: string;
  hqSkin: string;
  planeSku?: string;
  plotsType?: string;
  terrainTiles: string[];
  roadTiles: string[];
  items: JsonObject[];
}): JsonObject {
  return {
    universe: [
      {
        Profile: [
          { Missions: [] },
          { PollManager: [] },
          leafElement("Plots", { type: options.plotsType ?? "" })
        ],
        exp: "135629",
        DCCoins: options.companyValue,
        DCCash: "0",
        DCCashPaid: "0",
        cityname: options.cityName,
        cityNameCodes: toAsciiCodes(options.cityName),
        tutorialEnd: "1",
        companyValue: options.companyValue,
        ranking: "1",
        firstInvest: "0",
        firstVisit: "0",
        firstPartner: "0",
        firstMission: "0",
        newToolRev: "0",
        checkmail: "0",
        fourMillions: "1",
        planeSku: options.planeSku ?? "plain",
        flags: "",
        investmentInMeTimeLeft: "-1",
        investmentInMeUserId: "-1",
        investmentInMeExtId: "-1",
        userName: options.userName,
        profileId: String(options.userId),
        extId: options.extId,
        advisorId: DEFAULT_ADVISOR_IDS,
        lang: DEFAULT_LANG
      },
      {
        World: [
          createCompanyElement(
            {
              sid: STARTER_COMPANY_MINE_SID,
              wsid: STARTER_WORLD_SID,
              whose: "0",
              HQLevel: "3",
              exp: "0",
              DCCoins: options.companyValue,
              workers: "12"
            },
            options.items
          ),
          createCompanyElement(
            {
              sid: STARTER_COMPANY_RIVAL_SID,
              wsid: STARTER_WORLD_SID,
              whose: "1",
              HQLevel: "0",
              exp: "0",
              DCCoins: "0",
              workers: "0"
            },
            []
          ),
          {
            Map: [
              createElement("Terrain", { chunk: Array.from(new Set(options.terrainTiles)).join(",") }),
              createElement("Road", { chunk: Array.from(new Set(options.roadTiles)).join(",") })
            ],
            sid: STARTER_WORLD_SID,
            wsid: STARTER_WORLD_SID
          }
        ],
        sid: STARTER_WORLD_SID
      }
    ]
  };
}

function toAsciiCodes(value: string): string {
  return Array.from(value).map((character) => character.charCodeAt(0)).join(",");
}
