import {
  DEFAULT_ADVISOR_IDS,
  DEFAULT_GAME_VARIANT,
  DEFAULT_LANG,
  DEFAULT_USER_EXT_ID,
  DEFAULT_USER_ID,
  SAVE_TAGS,
  type GameVariant
} from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createElement, leafElement } from "../saveTree.js";
import {
  DEFAULT_CITY_NAME,
  DEFAULT_CITY_NAME_CODES,
  STARTER_COMPANY_MINE_SID,
  STARTER_COMPANY_RIVAL_SID,
  STARTER_WORLD_SID,
  getStarterEconomy
} from "./constants.js";
import { createEmptyCollectiblePendingDocument, createEmptyCollectiblesDocument } from "./collectibles.js";
import { createHorizontalChunk, createVerticalChunk } from "./geometry.js";
import { createCompanyElement, createRivalSaleItem } from "./items.js";
import { createStarterDecorationItems } from "./starterDecorations.js";

const STARTER_ROAD_TILES = [
  ...createHorizontalChunk(-7, 11, 0),
  ...createVerticalChunk(-1, 1, 3),
  ...createVerticalChunk(2, 1, 4),
  ...createHorizontalChunk(-1, 1, 4)
];
const ORIGINAL_STARTER_PLOTS_TYPE = "0,0,0,0,0,0,0,1,0,0,0,1,2,1,0,0,0,1,0,0,0,0,0,0,0";
const RECOVERED_STARTER_TERRAIN_TILES = [
  "-1:-3", "0:-3", "1:-3", "2:-3", "4:2", "4:3", "-1:-1",
  "-1:-2", "0:-2", "1:-2", "2:-2", "2:-1", "1:-1", "0:-1"
];
const ORIGINAL_STARTER_ROAD_TILES = [
  "2:1", "-1:1", "-1:4", "0:4", "1:4", "2:4", "2:3", "2:2", "-1:2", "-1:3",
  "-1:0", "-2:0", "-3:0", "-4:0", "-5:0", "-6:0", "-7:0", "0:0", "1:0", "2:0",
  "4:0", "3:0", "5:0", "6:0", "7:0", "8:0", "9:0", "10:0", "11:0"
];

const DAILY_BONUS_DEFAULT_ATTRIBUTES = {
  dailyRewardsCount: "0",
  dailyRewardsLastGiven: "",
  dailyRewardsLastGivenDate: "0",
  dailyRewardsNextRewardId: ""
} as const;
const WELCOME_DEFAULT_ATTRIBUTES = {
  allItemsUnlockables: "1",
  vip: "0",
  help: "0",
  invest: "0",
  newItems: "0",
  npcSheikTimeLeft: "100000",
  npcCindyTimeLeft: "100000",
  npcRonaldTimeLeft: "100000"
} as const;

export interface SaveBundle {
  [SAVE_TAGS.universe]: JsonObject;
  [SAVE_TAGS.customizer]: JsonObject;
  [SAVE_TAGS.friends]: JsonObject;
  [SAVE_TAGS.neighbors]: JsonObject;
  [SAVE_TAGS.help]: JsonObject;
  [SAVE_TAGS.upgrades]: JsonObject;
  [SAVE_TAGS.unlocked]: JsonObject;
  [SAVE_TAGS.limitedEdition]: JsonObject;
  [SAVE_TAGS.storage]: JsonObject;
  [SAVE_TAGS.collectibles]: JsonObject;
  [SAVE_TAGS.collectiblePending]: JsonObject;
  [SAVE_TAGS.dailyBonus]: JsonObject;
  [SAVE_TAGS.partners]: JsonObject;
  [SAVE_TAGS.welcome]: JsonObject;
  [SAVE_TAGS.investments]: JsonObject;
  [SAVE_TAGS.gameConfig]: JsonObject;
  [SAVE_TAGS.fan]: JsonObject;
}

export function createFreshSaveBundle(
  userExtId = DEFAULT_USER_EXT_ID,
  gameVariant: GameVariant = DEFAULT_GAME_VARIANT
): SaveBundle {
  return {
    [SAVE_TAGS.universe]: createStarterUniverse(userExtId, gameVariant),
    [SAVE_TAGS.customizer]: { crmpopups: [] },
    [SAVE_TAGS.friends]: { friendsList: [] },
    [SAVE_TAGS.neighbors]: { neighborList: [] },
    [SAVE_TAGS.help]: { helpList: [] },
    [SAVE_TAGS.upgrades]: { upgradesList: [] },
    [SAVE_TAGS.unlocked]: { unlockedList: [] },
    [SAVE_TAGS.limitedEdition]: { limEdList: [] },
    [SAVE_TAGS.storage]: { storageList: [] },
    [SAVE_TAGS.collectibles]: createEmptyCollectiblesDocument(),
    [SAVE_TAGS.collectiblePending]: createEmptyCollectiblePendingDocument(),
    [SAVE_TAGS.dailyBonus]: leafElement("dailyBonusInfo", DAILY_BONUS_DEFAULT_ATTRIBUTES),
    [SAVE_TAGS.partners]: { partnersList: [] },
    [SAVE_TAGS.welcome]: leafElement("welcome", WELCOME_DEFAULT_ATTRIBUTES),
    [SAVE_TAGS.investments]: { investmentsList: [] },
    [SAVE_TAGS.gameConfig]: leafElement("gameConfig", {
      music: "1",
      sound: "1",
      quality: "1"
    }),
    [SAVE_TAGS.fan]: leafElement("fan", {
      value: "2",
      bookmark: "0"
    })
  };
}

function createStarterUniverse(
  userExtId = DEFAULT_USER_EXT_ID,
  gameVariant: GameVariant = DEFAULT_GAME_VARIANT
): JsonObject {
  const economy = getStarterEconomy(gameVariant);
  const isOriginal = gameVariant === "original";
  const roadTiles = isOriginal ? ORIGINAL_STARTER_ROAD_TILES : Array.from(new Set(STARTER_ROAD_TILES));
  return {
    universe: [
      {
        Profile: [
          { Missions: [] },
          { PollManager: [] },
          leafElement("Plots", { type: isOriginal ? ORIGINAL_STARTER_PLOTS_TYPE : "" })
        ],
        exp: "0",
        DCCoins: String(economy.coins),
        DCCash: String(economy.cash),
        DCCashPaid: "0",
        cityname: DEFAULT_CITY_NAME,
        cityNameCodes: DEFAULT_CITY_NAME_CODES,
        tutorialEnd: "0",
        companyValue: String(economy.companyValue),
        ranking: "-1",
        bossGenre: "0",
        firstInvest: "0",
        firstVisit: "0",
        firstPartner: "0",
        firstMission: "0",
        firstGift: "0",
        newToolRev: "0",
        checkmail: "0",
        fourMillions: "0",
        planeSku: "plain",
        flags: "",
        investmentInMeTimeLeft: "-1",
        investmentInMeUserId: "-1",
        investmentInMeExtId: "-1",
        userName: "Mayor",
        profileId: String(DEFAULT_USER_ID),
        extId: userExtId,
        advisorId: DEFAULT_ADVISOR_IDS,
        lang: DEFAULT_LANG
      },
      {
        World: [
          createCompanyElement({
            sid: STARTER_COMPANY_MINE_SID,
            wsid: STARTER_WORLD_SID,
            whose: "0",
            HQLevel: "0",
            exp: "0",
            DCCoins: String(economy.coins),
            workers: "0"
          }, createStarterDecorationItems(STARTER_COMPANY_MINE_SID, gameVariant)),
          createCompanyElement({
            sid: STARTER_COMPANY_RIVAL_SID,
            wsid: STARTER_WORLD_SID,
            whose: "1",
            HQLevel: "0",
            exp: "0",
            DCCoins: "0",
            workers: "0"
          }, [
            ...(isOriginal
              ? [
                  createRivalSaleItem("245", "houses_002_001", "-4", "1"),
                  createRivalSaleItem("246", "houses_001_002", "-13", "1"),
                  createRivalSaleItem("247", "commerce_pizza", "-7", "-3"),
                  createRivalSaleItem("248", "houses_002_002", "9", "-3")
                ]
              : [
                  createRivalSaleItem("2001", "commerce_pizza", "-7", "-3"),
                  createRivalSaleItem("2002", "houses_002_001", "-4", "1"),
                  createRivalSaleItem("2003", "houses_002_002", "9", "-3"),
                  createRivalSaleItem("2004", "houses_001_002", "-13", "1")
                ])
          ]),
          {
            Map: [
              createElement("Terrain", { chunk: RECOVERED_STARTER_TERRAIN_TILES.join(",") }),
              createElement("Road", { chunk: roadTiles.join(",") })
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

export function normalizeDailyBonusDefaults(document: JsonObject): boolean {
  return applyMissingAttributes(document, DAILY_BONUS_DEFAULT_ATTRIBUTES);
}

export function normalizeWelcomeDefaults(document: JsonObject): boolean {
  return applyMissingAttributes(document, WELCOME_DEFAULT_ATTRIBUTES);
}

function applyMissingAttributes(document: JsonObject, defaults: Record<string, string>): boolean {
  let changed = false;
  for (const [key, value] of Object.entries(defaults)) {
    if (document[key] == null) {
      document[key] = value;
      changed = true;
    }
  }
  return changed;
}
