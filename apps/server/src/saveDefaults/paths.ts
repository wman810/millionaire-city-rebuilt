import path from "path";
import { getActiveDataRoot } from "../config.js";

export const DATA_ROOT = getActiveDataRoot();
export const RULES_ROOT = path.join(DATA_ROOT, "rules");
export const ITEM_ASSETS_ROOT = path.join(DATA_ROOT, "Assets", "items");
export const SETTINGS_PATH = path.join(RULES_ROOT, "settings.xml");
export const CONTRACTS_PATH = path.join(RULES_ROOT, "contracts.xml");
export const ITEM_DEFINITIONS_PATH = path.join(RULES_ROOT, "itemDefinitions.xml");
export const MISSION_DEFINITIONS_PATH = path.join(RULES_ROOT, "missionDefinitions.xml");
export const XP_TABLE_PATH = path.join(RULES_ROOT, "XPTable.xml");
