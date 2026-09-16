export const GAME_VERSION = "0.501";
export const ORIGINAL_GAME_VERSION = "0.338";
export const DEFAULT_GAME_VARIANT = "current" as const;
export const GAME_VARIANTS = {
  current: {
    gameVersion: GAME_VERSION,
    label: "Current revival version"
  },
  original: {
    gameVersion: ORIGINAL_GAME_VERSION,
    label: "Original archived version"
  }
} as const;
export type GameVariant = keyof typeof GAME_VARIANTS;

export function isGameVariant(value: unknown): value is GameVariant {
  return typeof value === "string" && Object.prototype.hasOwnProperty.call(GAME_VARIANTS, value);
}
export const DEFAULT_USER_ID = 1;
export const DEFAULT_USER_EXT_ID = "100000000000001";
export const DEFAULT_ADVISOR_IDS = "100,101";
export const DEFAULT_LANG = "en_US";

export const STARTUP_COMMANDS = [
  "get_world",
  "get_customizer_info",
  "get_friends_list",
  "get_neighbor_list",
  "get_neighbor_info",
  "get_help_building_list",
  "get_upgrades_list",
  "get_unlocked_items_list",
  "get_limited_edition_items_list",
  "get_storage_list",
  "get_collectibles_list",
  "get_friends_collectible_sents_list",
  "get_daily_rewards_info",
  "get_partners_list",
  "get_welcome_progress",
  "get_investments_list",
  "get_game_config",
  "load_success"
] as const;

export const MUTATION_COMMANDS = [
  "update_item",
  "update_map",
  "update_plots",
  "update_profile",
  "update_money",
  "update_next_rent",
  "update_daily_reward",
  "update_missions",
  "update_pollmanager"
] as const;

export const NOOP_COMMANDS = [
  "ask_for_help",
  "ask_for_cash",
  "help_accelerate",
  "postReward",
  "invest_cancel",
  "invest_get_inversion",
  "invest_on_friend",
  "invest_on_friend_reminder",
  "invest_results",
  "add_upgrade_item"
] as const;

export const SAVE_TAGS = {
  universe: "universe",
  customizer: "crmpopups",
  friends: "friendList",
  neighbors: "neighborList",
  help: "helpList",
  upgrades: "upgradesList",
  unlocked: "unlockedList",
  limitedEdition: "limEdList",
  storage: "storageList",
  collectibles: "collectiblesList",
  collectiblePending: "collectiblePendingList",
  dailyBonus: "dailyBonusInfo",
  partners: "partnersList",
  welcome: "welcome",
  investments: "investmentsList",
  gameConfig: "gameConfig",
  fan: "fan"
} as const;

export const DEFAULT_SYNC = 1;
