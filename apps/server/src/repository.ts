import crypto from "crypto";
import {
  DEFAULT_ADVISOR_IDS,
  DEFAULT_SYNC,
  DEFAULT_USER_EXT_ID,
  DEFAULT_USER_ID,
  SAVE_TAGS
} from "@mcity/shared";
import type { JsonObject, LoginResponseData } from "@mcity/shared/dist/types.js";
import type { SaveBundle } from "./saveDefaults.js";
import { createFreshSaveBundle, normalizeCompletedTutorialUniverse } from "./saveDefaults.js";
import type { MCityDatabase, SessionRow, UserRow } from "./database.js";

const SAVE_SCHEMA_VERSION = "8";
const GAME_CONFIG_DEFAULTS_META_KEY = "game_config_defaults_version";
const GAME_CONFIG_DEFAULTS_VERSION = "1";
const CASH_TO_COINS = 60000;

export class SaveRepository {
  constructor(private readonly database: MCityDatabase) {}

  ensureDefaultUser(): UserRow {
    const now = new Date().toISOString();
    const existing = this.database.db
      .prepare("SELECT id, ext_id, name, created_at FROM users WHERE id = ?")
      .get(DEFAULT_USER_ID) as UserRow | undefined;

    if (existing) {
      this.ensureCompatibleSave(existing.id, existing.ext_id);
      return existing;
    }

    this.database.db
      .prepare("INSERT INTO users (id, ext_id, name, created_at) VALUES (?, ?, ?, ?)")
      .run(DEFAULT_USER_ID, DEFAULT_USER_EXT_ID, "Mayor", now);

    const user = this.database.db
      .prepare("SELECT id, ext_id, name, created_at FROM users WHERE id = ?")
      .get(DEFAULT_USER_ID) as UserRow;

    this.seedFreshSave(user.id, user.ext_id);
    this.setSession(user.id, crypto.randomBytes(16).toString("hex"), DEFAULT_SYNC);
    return user;
  }

  updateDefaultUserName(name: string): UserRow {
    const user = this.ensureDefaultUser();
    this.database.db
      .prepare("UPDATE users SET name = ? WHERE id = ?")
      .run(name, user.id);

    return {
      ...user,
      name
    };
  }

  getMeta(key: string): string | undefined {
    const row = this.database.db
      .prepare("SELECT value FROM meta WHERE key = ?")
      .get(key) as { value: string } | undefined;
    return row?.value;
  }

  setMeta(key: string, value: string): void {
    this.database.db
      .prepare("INSERT OR REPLACE INTO meta (key, value, updated_at) VALUES (?, ?, ?)")
      .run(key, value, new Date().toISOString());
  }

  deleteMeta(key: string): void {
    this.database.db
      .prepare("DELETE FROM meta WHERE key = ?")
      .run(key);
  }

  seedFreshSave(userId: number, userExtId: string): void {
    const bundle = createFreshSaveBundle(userExtId);
    const stmt = this.database.db.prepare(
      "INSERT OR REPLACE INTO save_documents (user_id, tag, json, updated_at) VALUES (?, ?, ?, ?)"
    );
    const now = new Date().toISOString();
    const tx = this.database.db.transaction((saveBundle: SaveBundle) => {
      for (const [tag, document] of Object.entries(saveBundle)) {
        stmt.run(userId, tag, JSON.stringify(document), now);
      }
      this.database.db
        .prepare(
          "INSERT OR REPLACE INTO meta (key, value, updated_at) VALUES (?, ?, ?)"
        )
        .run("save_schema_version", SAVE_SCHEMA_VERSION, now);
      this.database.db
        .prepare(
          "INSERT OR REPLACE INTO meta (key, value, updated_at) VALUES (?, ?, ?)"
        )
        .run(GAME_CONFIG_DEFAULTS_META_KEY, GAME_CONFIG_DEFAULTS_VERSION, now);
    });
    tx(bundle);
  }

  getSession(userId: number): SessionRow | undefined {
    return this.database.db
      .prepare("SELECT user_id, token, sync, created_at, updated_at FROM sessions WHERE user_id = ?")
      .get(userId) as SessionRow | undefined;
  }

  setSession(userId: number, token: string, sync: number): void {
    const now = new Date().toISOString();
    this.database.db
      .prepare(
        `
          INSERT INTO sessions (user_id, token, sync, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?)
          ON CONFLICT(user_id) DO UPDATE SET
            token = excluded.token,
            sync = excluded.sync,
            updated_at = excluded.updated_at
        `
      )
      .run(userId, token, sync, now, now);
  }

  incrementSessionSync(userId: number): number {
    const session = this.getSession(userId);
    const sync = (session?.sync ?? DEFAULT_SYNC) + 1;
    this.setSession(userId, session?.token ?? crypto.randomBytes(16).toString("hex"), sync);
    return sync;
  }

  getDocument<T extends JsonObject>(userId: number, tag: string): T {
    const row = this.database.db
      .prepare("SELECT json FROM save_documents WHERE user_id = ? AND tag = ?")
      .get(userId, tag) as { json: string } | undefined;

    if (!row) {
      const user = this.ensureDefaultUser();
      this.seedFreshSave(user.id, user.ext_id);
      return this.getDocument<T>(userId, tag);
    }

    return JSON.parse(row.json) as T;
  }

  getOptionalDocument<T extends JsonObject>(userId: number, tag: string): T | undefined {
    const row = this.database.db
      .prepare("SELECT json FROM save_documents WHERE user_id = ? AND tag = ?")
      .get(userId, tag) as { json: string } | undefined;

    return row ? JSON.parse(row.json) as T : undefined;
  }

  setDocument(userId: number, tag: string, document: JsonObject): void {
    this.database.db
      .prepare(
        `
          INSERT OR REPLACE INTO save_documents (user_id, tag, json, updated_at)
          VALUES (?, ?, ?, ?)
        `
      )
      .run(userId, tag, JSON.stringify(document), new Date().toISOString());
  }

  ensureCompatibleSave(userId: number, userExtId: string): void {
    const schemaVersion = this.database.db
      .prepare("SELECT value FROM meta WHERE key = ?")
      .get("save_schema_version") as { value: string } | undefined;
    const gameConfigDefaultsVersion = this.database.db
      .prepare("SELECT value FROM meta WHERE key = ?")
      .get(GAME_CONFIG_DEFAULTS_META_KEY) as { value: string } | undefined;
    const universe = this.database.db
      .prepare("SELECT json FROM save_documents WHERE user_id = ? AND tag = ?")
      .get(userId, SAVE_TAGS.universe) as { json: string } | undefined;
    const gameConfig = this.database.db
      .prepare("SELECT json FROM save_documents WHERE user_id = ? AND tag = ?")
      .get(userId, SAVE_TAGS.gameConfig) as { json: string } | undefined;

    if (!universe || !gameConfig || schemaVersion?.value !== SAVE_SCHEMA_VERSION) {
      this.seedFreshSave(userId, userExtId);
      return;
    }

    const universeDoc = JSON.parse(universe.json) as JsonObject;
    const configDoc = JSON.parse(gameConfig.json) as JsonObject;

    if (isLegacyBrokenUniverse(universeDoc) || isLegacyBrokenGameConfig(configDoc)) {
      console.warn("[mcity] Resetting incompatible save schema to the current starter format.");
      this.seedFreshSave(userId, userExtId);
      return;
    }

    if (normalizeCompletedTutorialUniverse(universeDoc)) {
      this.setDocument(userId, SAVE_TAGS.universe, universeDoc);
    }

    if (
      gameConfigDefaultsVersion?.value !== GAME_CONFIG_DEFAULTS_VERSION &&
      usesLegacyMutedGameConfig(configDoc)
    ) {
      configDoc.music = "1";
      configDoc.sound = "1";
      this.setDocument(userId, SAVE_TAGS.gameConfig, configDoc);
      this.database.db
        .prepare("INSERT OR REPLACE INTO meta (key, value, updated_at) VALUES (?, ?, ?)")
        .run(GAME_CONFIG_DEFAULTS_META_KEY, GAME_CONFIG_DEFAULTS_VERSION, new Date().toISOString());
    }

    if (isTutorialIncomplete(universeDoc) && shouldResetIncompleteTutorialSave(universeDoc)) {
      const premiumCurrency = extractPremiumCurrencyState(universeDoc);
      this.seedFreshSave(userId, userExtId);
      if (premiumCurrency.cash > 0 || premiumCurrency.paidCash > 0) {
        this.applyPremiumCurrencyCarryover(userId, premiumCurrency.cash, premiumCurrency.paidCash);
      }
    }
  }

  getLoginResponse(userId: number): LoginResponseData {
    const session = this.getSession(userId);
    const user = this.ensureDefaultUser();

    return {
      userId,
      userExtId: user.ext_id,
      advisorId: DEFAULT_ADVISOR_IDS,
      token: session?.token ?? "",
      currentServerTime: Date.now()
    };
  }

  private applyPremiumCurrencyCarryover(userId: number, cash: number, paidCash: number): void {
    const universe = this.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getProfileContainer(universe);
    if (!profile) {
      return;
    }

    const safeCash = Number.isFinite(cash) ? Math.max(0, cash) : 0;
    const safePaidCash = Number.isFinite(paidCash) ? Math.max(0, paidCash) : 0;
    profile.DCCash = String(safeCash);
    profile.DCCashPaid = String(safePaidCash);
    profile.companyValue = String(550000 + safeCash * CASH_TO_COINS);
    this.setDocument(userId, SAVE_TAGS.universe, universe);
  }
}

function isLegacyBrokenUniverse(document: JsonObject): boolean {
  const root = document.universe;
  if (!Array.isArray(root)) {
    return true;
  }

  const profileContainer = getProfileContainer(document);
  const worldContainer = root.find(
    (entry): entry is JsonObject & { World: JsonObject[] } =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { World?: unknown }).World))
  );

  if (!profileContainer || !worldContainer) {
    return true;
  }

  const plotsContainer = profileContainer.Profile.find(
    (entry): entry is JsonObject & { type?: string } =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Plots?: unknown }).Plots))
  );
  const plotType = typeof plotsContainer?.type === "string" ? plotsContainer.type : null;
  const plotCount = plotType && plotType.length > 0 ? plotType.split(",").length : 0;

  const companies = worldContainer.World.filter(
    (entry): entry is JsonObject & { whose?: string } =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Company?: unknown }).Company))
  );
  const companyWhose = new Set(companies.map((entry) => entry.whose));
  const mapContainer = worldContainer.World.find(
    (entry): entry is JsonObject & { Map: JsonObject[] } =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Map?: unknown }).Map))
  );
  const hasTerrain = mapContainer?.Map.some(
    (entry) => Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Terrain?: unknown }).Terrain))
  );
  const hasRoad = mapContainer?.Map.some(
    (entry) => Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Road?: unknown }).Road))
  );

  const usesTutorialStarterPlots = plotType === "";
  const usesConcretePlotState = plotCount === 25 || plotCount === 36;

  return (
    (!usesTutorialStarterPlots && !usesConcretePlotState) ||
    companyWhose.size < 2 ||
    !companyWhose.has("0") ||
    !companyWhose.has("1") ||
    !mapContainer ||
    !hasTerrain ||
    !hasRoad
  );
}

function isLegacyBrokenGameConfig(document: JsonObject): boolean {
  return typeof document.music !== "string" || typeof document.sound !== "string" || typeof document.quality !== "string";
}

function usesLegacyMutedGameConfig(document: JsonObject): boolean {
  return document.music === "0" && document.sound === "0" && document.quality === "1";
}

function isTutorialIncomplete(document: JsonObject): boolean {
  const profileContainer = getProfileContainer(document);
  if (!profileContainer) {
    return true;
  }

  return String(profileContainer.tutorialEnd ?? "0") !== "1";
}

function shouldResetIncompleteTutorialSave(document: JsonObject): boolean {
  const company = getPlayerCompanyContainer(document);
  if (!company) {
    return true;
  }

  const items = company.Company.filter(
    (entry): entry is JsonObject =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Item?: unknown }).Item))
  );

  return items.some((item) => {
    const sku = String(item.sku ?? "");
    return sku === "HeadQuarter" || sku.startsWith("houses_") || sku.startsWith("commerce_");
  });
}

function getProfileContainer(document: JsonObject): (JsonObject & { Profile: JsonObject[] }) | undefined {
  const root = document.universe;
  if (!Array.isArray(root)) {
    return undefined;
  }

  return root.find(
    (entry): entry is JsonObject & { Profile: JsonObject[] } =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Profile?: unknown }).Profile))
  );
}

function getPlayerCompanyContainer(document: JsonObject): (JsonObject & { Company: JsonObject[] }) | undefined {
  const root = document.universe;
  if (!Array.isArray(root)) {
    return undefined;
  }

  const worldContainer = root.find(
    (entry): entry is JsonObject & { World: JsonObject[] } =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { World?: unknown }).World))
  );

  return worldContainer?.World.find(
    (entry): entry is JsonObject & { Company: JsonObject[] } =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as { Company?: unknown }).Company)) &&
      String(entry.whose ?? "") === "0"
  );
}

function extractPremiumCurrencyState(document: JsonObject): { cash: number; paidCash: number } {
  const profile = getProfileContainer(document);
  if (!profile) {
    return { cash: 0, paidCash: 0 };
  }

  const cash = Number(profile.DCCash ?? "0");
  const paidCash = Number(profile.DCCashPaid ?? "0");
  return {
    cash: Number.isFinite(cash) ? cash : 0,
    paidCash: Number.isFinite(paidCash) ? paidCash : 0
  };
}
