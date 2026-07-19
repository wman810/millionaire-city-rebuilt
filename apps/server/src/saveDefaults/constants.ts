export const DEFAULT_CITY_NAME = "Chocolate Fields";
export const DEFAULT_CITY_NAME_CODES = "67,104,111,99,111,108,97,116,101,32,70,105,101,108,100,115";
export const DEFAULT_ABANDON_MINUTES = 60;
export const DEFAULT_ABANDON_TIME_PERCENTAGE = 100;
export const STARTER_WORLD_SID = "1";
export const STARTER_COMPANY_MINE_SID = "1";
export const STARTER_COMPANY_RIVAL_SID = "2";
export const STARTER_COIN_BALANCE = 380000;
export const STARTER_COMPANY_VALUE = 720000;
export const NPC_PRIMARY_USER_ID = 100;
export const NPC_SHEIK_USER_ID = 101;
export const TUTORIAL_COMPLETED_HQ_TILE = { x: "-1", y: "-3" };
export const TUTORIAL_COMPLETED_HOUSE_TILE = { x: "4", y: "2" };
export const TUTORIAL_COMPLETED_TREE_TILE = { x: "4", y: "1" };
export const TUTORIAL_COMPLETED_TERRAIN_TILES = ["5:2", "5:3"];
export const TUTORIAL_COMPLETED_ROAD_TILES = ["3:4", "4:4"];
export const TUTORIAL_COMPLETED_INITIAL_MISSIONS = ["1", "2", "5", "10"];
export const COMPLETED_MISSION_POLL_RULES = [
  { sku: "2", countKey: "buycommerce_pizza", minCount: 1 },
  { sku: "5", countKey: "instantBuild", minCount: 1 },
  { sku: "18", countKey: "checkInfluencecommerce_pizza", minCount: 1 },
  { sku: "31", countKey: "collectcommerce_pizza", minCount: 1 }
];
export const STALE_TUTORIAL_POLL_MISSION_SKUS = new Set(["10", "25", "26"]);
export const UNLOCKED_MISSION_RULES = [
  { sku: "18", requiredSku: "2" },
  { sku: "31", requiredSku: "18" }
];
