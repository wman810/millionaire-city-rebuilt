import {
  DEFAULT_USER_ID,
  DEFAULT_SYNC,
  MUTATION_COMMANDS,
  NOOP_COMMANDS,
  SAVE_TAGS,
  STARTUP_COMMANDS
} from "@mcity/shared";
import type { PacketCommand } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import type { SaveRepository } from "./repository.js";
import {
  createNeighborUniverse,
  normalizeConstructionState,
  normalizeHouseRentState
} from "./saveDefaults.js";
import {
  normalizeDailyBonusDefaults,
  normalizeWelcomeDefaults
} from "./saveDefaults/starter.js";
import {
  createElement,
  findElementChild,
  getElementChildren,
  getOrCreateElementChild,
  parseChunkSet,
  upsertChunkElement,
  upsertElementChild
} from "./saveTree.js";
import {
  getCollectibleDefinitionForMutation,
  getCollectibleGroupForClaim,
  getCollectibleMaximumUnits,
  getCollectibleAwardSource,
  getProfileLevel,
  isCollectibleFeatureUnlocked,
  normalizeCollectiblePendingDocument,
  normalizeCollectiblesDocument,
  pickCollectibleSkuForCommerce,
  pickCollectibleSkuForHouse,
  readCollectiblesState,
  removePendingFriendCollectible,
  reserveHouseCollectibleDropSlot,
  resolveHeadQuarterRewardSkuForCollectibleClaim,
  resolveItemRewardCollectibleGroupFromMutation,
  resolvePlaneRewardSkuForCollectibleClaim,
  shouldAwardCommerceCollectibleDrop,
  shouldAwardHouseCollectibleDrop,
  writeCollectiblesState
} from "./commandHandlers/collectibles.js";
import {
  claimDailyReward,
  getDailyBonusCoins,
  getDailyRewardIntervalMs,
  prepareDailyRewards,
  type DailyRewardDefinition
} from "./commandHandlers/dailyRewards.js";
import { addBoughtCrewPositions, getBoughtCrewPurchaseCost } from "./commandHandlers/crew.js";
import { decodeAsciiCodes, encodeAsciiCodes, sanitizeForClientXml, sanitizeStoredString, sanitizeUniverseForClient } from "./commandHandlers/encoding.js";
import {
  applyMoneySecuritySnapshot,
  applyMoneySecuritySnapshotWithPositiveDeltaFallback,
  applyPositiveMoneySecurityDeltas,
  hasMoneySecuritySnapshot,
  reconcilePremiumCurrencyPurchase
} from "./commandHandlers/money.js";
import { addTerrainFootprint, applyMapTileMutation } from "./commandHandlers/mapIntegrity.js";
import { getPlotStates, unlockNextPlots } from "./commandHandlers/plots.js";
import {
  applyTimedServicePurchase,
  getTimedServicePurchaseCost,
  isKnownServiceSku,
  NEW_ITEMS_REVISION,
  projectTimedServiceState
} from "./commandHandlers/services.js";
import {
  extractIncomingElement,
  extractIncomingItemEntry,
  extractStateAttributes,
  hasStateMutation,
  parseCountChunkSet,
  toRecord,
  upsertCountChunkElement
} from "./commandHandlers/state.js";
import {
  addStorageItem,
  findBundleItems,
  getBoxPrizeDefinition,
  getBoxPrizeSequence,
  getStorageItemAmount,
  getStorageMaximumForSku,
  normalizeStorageDocument,
  removeStorageItem,
  resolveGiftStorageSku
} from "./commandHandlers/storage.js";
import {
  DEFAULT_CITY_NAME,
  createItemEntry,
  ensureHeadQuarterDecorations,
  ensureStateElement,
  findItemEntry,
  getCompanyEntryBySid,
  getCompanyEntryByWhose,
  getMapEntry,
  getPlotsEntry,
  getUniverseProfile,
  isHouseSku,
  isUpgradeEligibleItem,
  resolveTargetOwnerId,
  resolveUpgradeOwnerId,
  setPlayerHeadQuarterSkin,
  type MutableNode
} from "./commandHandlers/universe.js";
import {
  getUpgradeVisitorReward,
  getStoredUpgradeRecords,
  isUpgradeRecordActive,
  setStoredUpgradeRecords,
  UPGRADE_REPEAT_WINDOW_MS,
  VISITOR_UPGRADES_PER_WINDOW
} from "./commandHandlers/upgrades.js";

export class CommandService {
  constructor(private readonly repository: SaveRepository) {}

  handleCommand(userId: number, command: PacketCommand): PacketCommand[] {
    if (command._cmd === "ping" || command._cmd === "empty") {
      return [
        {
          _cmd: command._cmd,
          _dat: {},
          _sync: this.repository.getSession(userId)?.sync ?? DEFAULT_SYNC
        }
      ];
    }

    if ((STARTUP_COMMANDS as readonly string[]).includes(command._cmd)) {
      return [this.handleStartupCommand(userId, command._cmd, command._dat as Record<string, unknown> | undefined)];
    }

    if ((MUTATION_COMMANDS as readonly string[]).includes(command._cmd)) {
      return this.handleMutationCommand(userId, command);
    }

    if (command._cmd === "add_upgrade_item") {
      return [this.handleUpgradeCommand(userId, command)];
    }

    if (command._cmd === "ask_collectible" || command._cmd === "update_collectible") {
      return [this.handleCollectibleCommand(userId, command)];
    }

    if ((NOOP_COMMANDS as readonly string[]).includes(command._cmd)) {
      return [this.handleNoopCommand(userId, command)];
    }

    return [
      {
        _cmd: command._cmd,
        _dat: {
          success: "true",
          ignored: "1"
        },
        _sync: this.repository.getSession(userId)?.sync ?? DEFAULT_SYNC
      }
    ];
  }

  private handleStartupCommand(userId: number, commandName: string, payload: Record<string, unknown> = {}): PacketCommand {
    const rawData = this.getStartupDocument(userId, commandName, payload);
    const data = commandName === "get_world" ? sanitizeUniverseForClient(rawData) : sanitizeForClientXml(rawData);
    return {
      _cmd: commandName,
      _dat: data,
      _sync: this.repository.getSession(userId)?.sync ?? DEFAULT_SYNC
    };
  }

  private getStartupDocument(userId: number, commandName: string, payload: Record<string, unknown> = {}): JsonObject {
    switch (commandName) {
      case "get_world": {
        const playerUniverse = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
        const targetUserId = Number(payload.targetUserId ?? DEFAULT_USER_ID);
        if (Number.isFinite(targetUserId) && targetUserId !== DEFAULT_USER_ID) {
          const playerProfile = getUniverseProfile(playerUniverse);
          const bossGenre = Number(playerProfile?.bossGenre ?? 0);
          const neighborUniverse = createNeighborUniverse(targetUserId, bossGenre);
          if (neighborUniverse) {
            return neighborUniverse;
          }

          const savedNeighborUniverse = this.repository.getOptionalDocument<JsonObject>(targetUserId, SAVE_TAGS.universe);
          if (savedNeighborUniverse) {
            return savedNeighborUniverse;
          }
        }
        projectTimedServiceState(getUniverseProfile(playerUniverse), Date.now());
        return playerUniverse;
      }
      case "get_customizer_info":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.customizer);
      case "get_friends_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.friends);
      case "get_neighbor_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.neighbors);
      case "get_neighbor_info":
        return {
          neighborList: []
        };
      case "get_help_building_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.help);
      case "get_upgrades_list":
        return this.buildUpgradesListDocument(userId, payload);
      case "get_unlocked_items_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.unlocked);
      case "get_limited_edition_items_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.limitedEdition);
      case "get_storage_list": {
        const storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
        if (normalizeStorageDocument(storage)) {
          this.repository.setDocument(userId, SAVE_TAGS.storage, storage);
        }
        return storage;
      }
      case "get_collectibles_list":
        return this.getNormalizedCollectiblesDocument(userId);
      case "get_friends_collectible_sents_list":
        return this.getNormalizedCollectiblePendingDocument(userId);
      case "get_daily_rewards_info": {
        const dailyRewards = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.dailyBonus);
        const normalized = normalizeDailyBonusDefaults(dailyRewards);
        const prepared = prepareDailyRewards(dailyRewards, Date.now());
        if (normalized || prepared.changed) {
          this.repository.setDocument(userId, SAVE_TAGS.dailyBonus, prepared.stored);
        }
        return prepared.response;
      }
      case "get_partners_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.partners);
      case "get_welcome_progress": {
        const welcome = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.welcome);
        if (normalizeWelcomeDefaults(welcome)) {
          this.repository.setDocument(userId, SAVE_TAGS.welcome, welcome);
        }
        return welcome;
      }
      case "get_investments_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.investments);
      case "get_game_config":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.gameConfig);
      case "load_success":
        return {
          success: "true"
        };
      default:
        return {};
    }
  }

  private handleMutationCommand(userId: number, command: PacketCommand): PacketCommand[] {
    const payload = command._dat as JsonObject;
    let sideEffects: PacketCommand[] = [];
    switch (command._cmd) {
      case "update_profile":
        this.applyProfileMutation(userId, payload);
        break;
      case "update_money":
        this.applyMoneyMutation(userId, payload);
        break;
      case "update_item":
        sideEffects = this.applyItemMutation(userId, payload);
        break;
      case "update_map":
        this.applyMapMutation(userId, payload);
        break;
      case "update_plots":
        this.applyPlotsMutation(userId, payload);
        break;
      case "update_missions":
        this.applyMissionsMutation(userId, payload);
        break;
      case "update_pollmanager":
        this.applyPollManagerMutation(userId, payload);
        break;
      case "update_daily_reward":
        this.applyDailyRewardMutation(userId, payload);
        break;
      default:
        break;
    }

    this.repository.incrementSessionSync(userId);
    const sync = this.repository.getSession(userId)?.sync ?? DEFAULT_SYNC;
    return [
      {
        _cmd: command._cmd,
        _dat: payload,
        _sync: sync
      },
      ...sideEffects.map((entry) => ({
        ...entry,
        _sync: sync
      }))
    ];
  }

  private handleNoopCommand(userId: number, command: PacketCommand): PacketCommand {
    let response: JsonObject = {
      success: "true",
      unavailableOffline: "1"
    };

    if (
      command._cmd === "ask_for_help" ||
      command._cmd === "ask_for_cash" ||
      command._cmd === "help_accelerate"
    ) {
      response = {
        help_id: "null",
        time_passed: "0",
        time_total: "0",
        unavailableOffline: "1"
      };
    } else if (command._cmd.startsWith("invest_")) {
      response = {
        success: "false",
        unavailableOffline: "1"
      };
    }

    return {
      _cmd: command._cmd,
      _dat: response,
      _sync: this.repository.getSession(userId)?.sync ?? DEFAULT_SYNC
    };
  }

  private handleUpgradeCommand(userId: number, command: PacketCommand): PacketCommand {
    this.applyUpgradeCommand(userId, command._dat as Record<string, unknown>);
    this.repository.incrementSessionSync(userId);
    return {
      _cmd: command._cmd,
      _dat: command._dat as JsonObject,
      _sync: this.repository.getSession(userId)?.sync ?? DEFAULT_SYNC
    };
  }

  private handleCollectibleCommand(userId: number, command: PacketCommand): PacketCommand {
    const payload = command._dat as Record<string, unknown>;
    const action = String(payload.action ?? "").toUpperCase();
    let accepted = command._cmd === "ask_collectible";

    if (command._cmd === "update_collectible") {
      switch (action) {
        case "KEEP":
          accepted = this.applyCollectibleKeepMutation(userId, payload);
          break;
        case "BUY":
          accepted = this.applyCollectibleBuyMutation(userId, payload);
          break;
        case "SELL":
          accepted = this.applyCollectibleSellMutation(userId, payload);
          break;
        case "GET_REWARD":
          accepted = this.applyCollectibleRewardMutation(userId, payload);
          break;
        case "SEND":
          accepted = this.applyCollectibleSendMutation(userId, payload);
          break;
        default:
          break;
      }
    }

    if (accepted && command._cmd === "update_collectible") {
      this.applyCollectibleMoneySecurity(userId, payload);
    }
    this.repository.incrementSessionSync(userId);
    return {
      _cmd: command._cmd,
      _dat: {
        ...payload,
        success: "true"
      },
      _sync: this.repository.getSession(userId)?.sync ?? DEFAULT_SYNC
    };
  }

  private buildUpgradesListDocument(userId: number, payload: Record<string, unknown>): JsonObject {
    const ownerId = resolveTargetOwnerId(payload);
    const playerUniverse = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const visitorExtId = String(getUniverseProfile(playerUniverse)?.extId ?? "");
    const bossGenre = Number(getUniverseProfile(playerUniverse)?.bossGenre ?? 0);
    const targetUniverse =
      ownerId === DEFAULT_USER_ID ? playerUniverse : createNeighborUniverse(ownerId, bossGenre);

    const allRecords = getStoredUpgradeRecords(this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.upgrades));
    const nowMs = Date.now();
    const activeRecords = allRecords.filter(
      (record) =>
        record.ownerId === String(ownerId) &&
        isUpgradeRecordActive(record, nowMs) &&
        targetUniverse &&
        isUpgradeEligibleItem(targetUniverse, record.sid)
    );
    const visitorCount = activeRecords.filter((record) => record.visitorExtId === visitorExtId).length;

    return createElement(
      "upgradesList",
      {
        upgradesUniverseAvailable: String(Math.max(0, VISITOR_UPGRADES_PER_WINDOW - visitorCount))
      },
      activeRecords.map((record) =>
        createElement("upgrade", {
          sid: record.sid,
          extId: record.visitorExtId
        })
      )
    );
  }

  private applyUpgradeCommand(userId: number, payload: Record<string, unknown>): boolean {
    const sid = String(payload.sid ?? "");
    const ownerId = resolveUpgradeOwnerId(payload, sid);
    if (sid.length === 0) {
      return false;
    }

    const playerUniverse = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const visitorExtId = String(getUniverseProfile(playerUniverse)?.extId ?? "");
    const bossGenre = Number(getUniverseProfile(playerUniverse)?.bossGenre ?? 0);
    const targetUniverse =
      ownerId === DEFAULT_USER_ID ? playerUniverse : createNeighborUniverse(ownerId, bossGenre);

    if (!targetUniverse || !isUpgradeEligibleItem(targetUniverse, sid)) {
      return false;
    }

    const upgradesDocument = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.upgrades);
    const nowMs = Date.now();
    const records = getStoredUpgradeRecords(upgradesDocument).filter((record) => {
      const age = nowMs - record.createdAtMs;
      return age >= 0 && age < UPGRADE_REPEAT_WINDOW_MS;
    });
    const existingRecord = records.some(
      (record) =>
        record.ownerId === String(ownerId) &&
        record.sid === sid &&
        record.visitorExtId === visitorExtId &&
        isUpgradeRecordActive(record, nowMs)
    );
    if (existingRecord) {
      return false;
    }

    const visitorCount = records.filter(
      (record) =>
        record.ownerId === String(ownerId) &&
        record.visitorExtId === visitorExtId &&
        isUpgradeRecordActive(record, nowMs)
    ).length;
    if (visitorCount >= VISITOR_UPGRADES_PER_WINDOW) {
      return false;
    }

    const profile = getUniverseProfile(playerUniverse);
    const reward = getUpgradeVisitorReward(payload.type);
    const rewardDeltas: MoneyDeltas = {
      exp: reward.exp,
      DCCoins: reward.coins
    };
    if (!profile || !validateExactMoneySecurity(profile, toRecord(payload.security), rewardDeltas, true)) {
      return false;
    }

    records.push({
      ownerId: String(ownerId),
      sid,
      visitorExtId,
      type: String(payload.type ?? "0"),
      createdAtMs: nowMs
    });

    setStoredUpgradeRecords(upgradesDocument, records);
    this.repository.setDocument(userId, SAVE_TAGS.upgrades, upgradesDocument);
    applyExactMoneyDeltas(profile, rewardDeltas);
    this.repository.setDocument(userId, SAVE_TAGS.universe, playerUniverse);
    return true;
  }

  private applyProfileMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return;
    }

    const action = String(payload.action ?? "");
    const value = payload.value;

    switch (action) {
      case "city_name_codes": {
        const cityNameCodes = String(value ?? profile.cityNameCodes ?? "");
        const cityName = sanitizeStoredString(decodeAsciiCodes(cityNameCodes));
        if (cityName.length > 0) {
          profile.cityname = cityName;
        }
        profile.cityNameCodes = encodeAsciiCodes(cityName);
        break;
      }
      case "city_name": {
        const cityName = sanitizeStoredString(String(value ?? profile.cityname ?? DEFAULT_CITY_NAME));
        profile.cityname = cityName;
        profile.cityNameCodes = encodeAsciiCodes(cityName);
        break;
      }
      case "boss_genre":
        profile.bossGenre = normalizeBossGenreValue(value);
        break;
      case "gameConfig":
        this.applyGameConfigProfileMutation(userId, payload);
        break;
      case "tutorial_completed":
        profile.tutorialEnd = "1";
        break;
      case "firstMission":
        profile.firstMission = String(value ?? "0");
        break;
      case "first_invest":
        profile.firstInvest = String(value ?? "0");
        break;
      case "firstPartner":
        profile.firstPartner = String(value ?? "0");
        break;
      case "firstVisit":
        profile.firstVisit = String(value ?? "0");
        break;
      case "newToolRev":
        profile.newToolRev = String(value ?? "0");
        break;
      case "newItemsRev":
      case "newItemsRevDone":
        profile.newItemsRev = NEW_ITEMS_REVISION;
        profile.newItemsRevDone = NEW_ITEMS_REVISION;
        break;
      case "service": {
        const sku = String(value ?? "").trim();
        if (isKnownServiceSku(sku)) {
          profile[`${sku}PresentationShown`] = "1";
        }
        break;
      }
      case "flag": {
        const name = String(payload.name ?? "").trim();
        if (name.length > 0) {
          profile.flags = updateProfileFlag(String(profile.flags ?? ""), name, String(value ?? ""));
        }
        break;
      }
      case "checkmail":
        profile.checkmail = normalizeCheckmailState(profile.checkmail, value);
        break;
      case "ranking":
        profile.ranking = String(value ?? profile.ranking ?? "-1");
        break;
      case "planeSku":
        profile.planeSku = String(value ?? profile.planeSku ?? "plain");
        break;
      case "fourMillions":
        profile.fourMillions = String(value ?? "0");
        break;
      case "million_news_feed":
        profile.millionNewsFeed = String(value ?? "1");
        break;
      default:
        break;
    }

    if (typeof payload.userName === "string") {
      profile.userName = sanitizeStoredString(payload.userName);
    }

    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyGameConfigProfileMutation(userId: number, payload: Record<string, unknown>): void {
    const gameConfig = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.gameConfig);

    if (typeof payload.music === "string") {
      gameConfig.music = payload.music;
    }
    if (typeof payload.sound === "string") {
      gameConfig.sound = payload.sound;
    }
    if (typeof payload.quality === "string") {
      gameConfig.quality = payload.quality;
    }

    this.repository.setDocument(userId, SAVE_TAGS.gameConfig, gameConfig);
  }

  private applyMoneyMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return;
    }

    const previousCash = Number(profile.DCCash ?? "0");
    const previousPaidCash = Number(profile.DCCashPaid ?? "0");
    const security = toRecord(payload.security);
    const action = String(payload.action ?? "");
    const normalizedAction = action.toLowerCase();
    const boxPrize = getBoxPrizeDefinition(String(payload.prize ?? ""));

    if (boxPrize && (normalizedAction === "openbox" || normalizedAction === boxPrize.sourceSku.toLowerCase())) {
      if (!this.applyBoxPrizeMutation(userId, profile, payload, boxPrize.sourceSku, normalizedAction === "openbox")) {
        return;
      }
      this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
      return;
    } else if (normalizedAction === "openbox" || normalizedAction === "briefcase") {
      return;
    }

    switch (action) {
      case "first_visit":
        profile.firstVisit = String(payload.value ?? "1");
        break;
      case "firstPartner":
        profile.firstPartner = String(payload.value ?? "1");
        break;
      case "dailyBonusDone": {
        const cooldownKey = `daily_bonus_at:${userId}`;
        const nowMs = Date.now();
        const nextAllowedAt = Number(this.repository.getMeta(cooldownKey) ?? 0);
        if (Number.isFinite(nextAllowedAt) && nextAllowedAt > nowMs) {
          return;
        }
        const reward: MoneyDeltas = { DCCoins: getDailyBonusCoins() };
        if (!validateExactMoneySecurity(profile, security, reward, true)) {
          return;
        }
        this.repository.setMeta(cooldownKey, String(nowMs + getDailyRewardIntervalMs()));
        applyExactMoneyDeltas(profile, reward);
        this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
        return;
      }
      case "service": {
        const cost = getTimedServicePurchaseCost(payload);
        if (!cost) {
          return;
        }
        const deltas: MoneyDeltas = {
          DCCoins: -cost.coins,
          DCCash: -cost.cash,
          companyValue: -cost.companyValue
        };
        if (
          Number(profile.DCCoins ?? 0) < cost.coins ||
          Number(profile.DCCash ?? 0) < cost.cash ||
          !validateExactMoneySecurity(profile, security, deltas, false) ||
          !applyTimedServicePurchase(profile, payload, Date.now())
        ) {
          return;
        }
        applyExactMoneyDeltas(profile, deltas);
        this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
        return;
      }
      case "unlockItem":
        if (!this.applyUnlockedItemMutation(userId, String(payload.value ?? ""))) {
          return;
        }
        break;
      case "buy_bundle":
        this.applyBundlePurchaseMutation(userId, String(payload.sku ?? ""));
        break;
      case "rentAccelerator":
        if (!this.applyRentAcceleratorStorageMutation(userId, String(payload.sku ?? ""))) {
          return;
        }
        break;
      default:
        break;
    }

    for (const [key, value] of Object.entries(payload)) {
      if (value == null) {
        continue;
      }

      if (["money", "coins", "DCCoins"].includes(key)) {
        profile.DCCoins = String(value);
      } else if (["gold", "cash", "DCCash"].includes(key)) {
        profile.DCCash = String(value);
      } else if (["paidCash", "DCCashPaid"].includes(key)) {
        profile.DCCashPaid = String(value);
      } else if (key === "exp") {
        profile.exp = String(value);
      } else if (key === "companyValue") {
        profile.companyValue = String(value);
      }
    }

    applyMoneySecuritySnapshot(profile, security);
    reconcilePremiumCurrencyPurchase(profile, payload, {
      previousCash,
      previousPaidCash,
      hadSecuritySnapshot: hasMoneySecuritySnapshot(security)
    });

    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private getNormalizedCollectiblesDocument(userId: number): JsonObject {
    const document = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.collectibles);
    if (normalizeCollectiblesDocument(document)) {
      this.repository.setDocument(userId, SAVE_TAGS.collectibles, document);
    }
    return document;
  }

  private getNormalizedCollectiblePendingDocument(userId: number): JsonObject {
    const document = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.collectiblePending);
    if (normalizeCollectiblePendingDocument(document)) {
      this.repository.setDocument(userId, SAVE_TAGS.collectiblePending, document);
    }
    return document;
  }

  private applyCollectibleKeepMutation(userId: number, payload: Record<string, unknown>): boolean {
    const sid = String(payload.sid ?? "");
    const sku = String(payload.sku ?? "");
    if (
      sid.length === 0 ||
      !getCollectibleDefinitionForMutation(sku) ||
      !this.validateCollectibleSecurityDeltas(userId, payload, {})
    ) {
      return false;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    const currentCount = collectibleState.objectCounts.get(sku) ?? 0;
    if (currentCount >= getCollectibleMaximumUnits()) {
      return false;
    }

    if (sid.startsWith("f")) {
      const pendingDocument = this.getNormalizedCollectiblePendingDocument(userId);
      if (!removePendingFriendCollectible(pendingDocument, sid.slice(1), sku)) {
        return false;
      }
      this.repository.setDocument(userId, SAVE_TAGS.collectiblePending, pendingDocument);
    } else {
      if (collectibleState.pendingBySid.get(sid) !== sku) {
        return false;
      }
      collectibleState.pendingBySid.delete(sid);
    }

    collectibleState.objectCounts.set(sku, currentCount + 1);
    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);
    return true;
  }

  private applyCollectibleBuyMutation(userId: number, payload: Record<string, unknown>): boolean {
    const sku = String(payload.sku ?? "");
    const definition = getCollectibleDefinitionForMutation(sku);
    if (!definition || !this.validateCollectibleSecurityDeltas(userId, payload, { DCCash: -definition.buyPriceCash })) {
      return false;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    const currentCount = collectibleState.objectCounts.get(sku) ?? 0;
    if (currentCount >= getCollectibleMaximumUnits()) {
      return false;
    }

    collectibleState.objectCounts.set(sku, currentCount + 1);
    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);
    return true;
  }

  private applyCollectibleSellMutation(userId: number, payload: Record<string, unknown>): boolean {
    const sid = String(payload.sid ?? "");
    const sku = String(payload.sku ?? "");
    const definition = getCollectibleDefinitionForMutation(sku);
    if (
      sid.length === 0 ||
      !definition ||
      !this.validateCollectibleSecurityDeltas(userId, payload, { DCCoins: definition.sellPriceCoins })
    ) {
      return false;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    if (sid.startsWith("f")) {
      const pendingDocument = this.getNormalizedCollectiblePendingDocument(userId);
      if (!removePendingFriendCollectible(pendingDocument, sid.slice(1), sku)) {
        return false;
      }
      this.repository.setDocument(userId, SAVE_TAGS.collectiblePending, pendingDocument);
      return true;
    }
    if (sid.startsWith("v") || collectibleState.pendingBySid.get(sid) !== sku) {
      return false;
    }

    collectibleState.pendingBySid.delete(sid);
    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);
    return true;
  }

  private applyCollectibleSendMutation(userId: number, payload: Record<string, unknown>): boolean {
    const sid = String(payload.sid ?? "");
    const sku = String(payload.sku ?? "");
    if (
      sid.length === 0 ||
      !getCollectibleDefinitionForMutation(sku) ||
      sid.startsWith("f") ||
      !this.validateCollectibleSecurityDeltas(userId, payload, {})
    ) {
      return false;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    const currentCount = collectibleState.objectCounts.get(sku) ?? 0;
    if (sid.startsWith("v")) {
      return currentCount >= 2;
    }
    if (
      collectibleState.pendingBySid.get(sid) !== sku ||
      currentCount >= getCollectibleMaximumUnits()
    ) {
      return false;
    }

    collectibleState.pendingBySid.delete(sid);
    collectibleState.objectCounts.set(sku, currentCount + 1);
    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);
    return true;
  }

  private applyCollectibleRewardMutation(
    userId: number,
    payload: Record<string, unknown>,
    claimedItemSku?: string
  ): boolean {
    const sku = String(payload.sku ?? "");
    const group = getCollectibleGroupForClaim(sku);
    if (!group || group.collectibleSkus.length === 0) {
      return false;
    }

    if (!group.tradeable && !this.validateCollectibleSecurityDeltas(userId, payload, {})) {
      return false;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    if (
      group.collectibleSkus.some((collectibleSku) => (collectibleState.objectCounts.get(collectibleSku) ?? 0) <= 0) ||
      (group.requirement.length > 0 && !collectibleState.rewards.has(group.requirement)) ||
      (!group.tradeable && collectibleState.rewards.has(sku)) ||
      (group.rewardType === "item" && claimedItemSku !== group.rewardSku) ||
      (group.rewardType !== "item" && claimedItemSku != null)
    ) {
      return false;
    }

    if (group.tradeable) {
      const reward = group.rewardValue;
      if (
        !reward ||
        !this.validateCollectibleSecurityDeltas(userId, payload, {
          DCCash: reward.cash,
          DCCoins: reward.coins,
          exp: reward.exp
        })
      ) {
        return false;
      }
      for (const collectibleSku of group.collectibleSkus) {
        const currentCount = collectibleState.objectCounts.get(collectibleSku) ?? 0;
        if (currentCount === 1) {
          collectibleState.objectCounts.delete(collectibleSku);
        } else {
          collectibleState.objectCounts.set(collectibleSku, currentCount - 1);
        }
      }
    } else {
      collectibleState.rewards.add(sku);
    }

    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);

    if (group.tradeable || group.rewardType === "item") {
      return true;
    }

    const planeSku = resolvePlaneRewardSkuForCollectibleClaim(sku);
    const hqSkinSku = resolveHeadQuarterRewardSkuForCollectibleClaim(sku);
    if (!planeSku && !hqSkinSku) {
      return true;
    }

    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    let changed = false;

    if (planeSku && profile && String(profile.planeSku ?? "") !== planeSku) {
      profile.planeSku = planeSku;
      changed = true;
    }

    if (hqSkinSku) {
      changed = setPlayerHeadQuarterSkin(universe, hqSkinSku) || changed;
    }

    if (changed) {
      this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
    }
    return true;
  }

  private applyCollectibleRewardItemMutation(userId: number, payload: Record<string, unknown>, itemEntry: MutableNode): boolean {
    const groupSku = resolveItemRewardCollectibleGroupFromMutation(payload, itemEntry);
    if (!groupSku) {
      return false;
    }

    return this.applyCollectibleRewardMutation(
      userId,
      { ...payload, sku: groupSku },
      String(itemEntry.sku ?? "")
    );
  }

  private canClaimCollectibleItemReward(userId: number, groupSku: string, itemSku: string): boolean {
    const group = getCollectibleGroupForClaim(groupSku);
    if (!group || group.rewardType !== "item" || group.rewardSku !== itemSku || group.tradeable) {
      return false;
    }
    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const state = readCollectiblesState(collectiblesDocument);
    return (
      !state.rewards.has(groupSku) &&
      (group.requirement.length === 0 || state.rewards.has(group.requirement)) &&
      group.collectibleSkus.length > 0 &&
      group.collectibleSkus.every((sku) => (state.objectCounts.get(sku) ?? 0) > 0)
    );
  }

  private validateCollectibleSecurityDeltas(
    userId: number,
    payload: Record<string, unknown>,
    expected: Partial<Record<"exp" | "DCCoins" | "DCCash", number>>
  ): boolean {
    const security = toRecord(payload.security);
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return false;
    }
    return validateExactMoneySecurity(profile, security, expected, false);
  }

  private applyCollectibleMoneySecurity(userId: number, payload: Record<string, unknown>): void {
    const security = toRecord(payload.security);
    if (!hasMoneySecuritySnapshot(security)) {
      return;
    }

    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return;
    }

    applyMoneySecuritySnapshotWithPositiveDeltaFallback(profile, security);
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyCollectibleProjectionForItemMutation(
    userId: number,
    itemEntry: MutableNode,
    payload: Record<string, unknown>,
    profile: MutableNode | undefined,
    previousMode: string
  ): PacketCommand[] {
    const state = findElementChild(getElementChildren(itemEntry, "Item"), "State");
    if (!state) {
      return [];
    }

    const itemSku = String(itemEntry.sku ?? "");
    const source = getCollectibleAwardSource(payload, itemSku, previousMode, state);
    if (!source) {
      return [];
    }

    if (source === "house" && !isCollectibleFeatureUnlocked(profile)) {
      return [];
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    const sid = String(itemEntry.sid ?? "");
    if (sid.length === 0 || collectibleState.pendingBySid.has(sid)) {
      return [];
    }

    const forceFirstHouseCollectible = source === "house" && String(profile?.firstGift ?? "0") === "0";
    if (source === "house") {
      if (!forceFirstHouseCollectible && !shouldAwardHouseCollectibleDrop(state)) {
        return [];
      }
      if (!forceFirstHouseCollectible && !this.reserveHouseCollectibleSlot(userId, Date.now())) {
        return [];
      }
    } else if (!shouldAwardCommerceCollectibleDrop()) {
      return [];
    }

    const collectibleSku =
      source === "house"
        ? pickCollectibleSkuForHouse(itemSku, String(state.contractGroupSku ?? ""), collectibleState)
        : pickCollectibleSkuForCommerce(itemSku, collectibleState);
    if (!collectibleSku) {
      return [];
    }

    if (forceFirstHouseCollectible && profile) {
      profile.firstGift = "1";
    }

    collectibleState.pendingBySid.set(sid, collectibleSku);
    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);
    return [
      {
        _cmd: "update_item",
        _dat: {
          action: "give_collectible",
          sid,
          sku: collectibleSku
        }
      }
    ];
  }

  private reserveHouseCollectibleSlot(userId: number, nowMs: number): boolean {
    const metaKey = `collectible_slots:${userId}`;
    const serialized = this.repository.getMeta(metaKey);
    let currentExpirations: number[] = [];
    if (serialized) {
      try {
        const parsed = JSON.parse(serialized) as unknown;
        if (Array.isArray(parsed)) {
          currentExpirations = parsed.map(Number);
        }
      } catch {
        currentExpirations = [];
      }
    }

    const nextExpirations = reserveHouseCollectibleDropSlot(currentExpirations, nowMs);
    if (!nextExpirations) {
      return false;
    }

    this.repository.setMeta(metaKey, JSON.stringify(nextExpirations));
    return true;
  }

  private applyItemMutation(userId: number, payload: Record<string, unknown>): PacketCommand[] {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    const action = String(payload.action ?? "").toLowerCase();
    const sid = String(payload.sid ?? "");
    const incomingItem = extractIncomingItemEntry(payload.item);
    const security = toRecord(payload.security);

    if (sid.length === 0) {
      return [];
    }

    const existing = findItemEntry(universe, sid);
    if (action === "buy_crew") {
      const cost = existing ? getBoughtCrewPurchaseCost(existing.itemEntry, payload.position) : undefined;
      const deltas: MoneyDeltas | undefined = cost
        ? { DCCash: -cost.cash, companyValue: -cost.companyValue }
        : undefined;
      if (
        !existing ||
        !profile ||
        !cost ||
        !deltas ||
        Number(profile.DCCash ?? 0) < cost.cash ||
        !validateExactMoneySecurity(profile, security, deltas, false) ||
        !addBoughtCrewPositions(existing.itemEntry, payload.position)
      ) {
        return [];
      }
      applyExactMoneyDeltas(profile, deltas);
      this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
      return [];
    }

    const beforeSignature = existing ? getItemMutationSignature(existing.itemEntry) : "";
    const previousState = existing
      ? findElementChild(getElementChildren(existing.itemEntry, "Item"), "State")
      : undefined;
    const previousStateId = String(previousState?.id ?? "");
    const previousMode = String(previousState?.mode ?? "");

    if (action.includes("destroy") || action.includes("sell") || action.includes("remove")) {
      if (existing) {
        if (profile && hasMoneySecuritySnapshot(security)) {
          applyMoneySecuritySnapshotWithPositiveDeltaFallback(profile, security);
        }
        existing.companyChildren.splice(existing.index, 1);
        this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
      }
      return [];
    }

    const requestedCompanyEntry =
      getCompanyEntryBySid(universe, String(incomingItem?.csid ?? payload.csid ?? "")) ??
      (payload.whose != null ? getCompanyEntryByWhose(universe, String(payload.whose)) : undefined) ??
      (!existing ? getCompanyEntryByWhose(universe, "0") : undefined);
    const companyEntry = requestedCompanyEntry ?? existing?.companyEntry;

    if (!companyEntry) {
      return [];
    }

    const payloadSku = nonEmptyString(payload.sku);
    const incomingSku = nonEmptyString(incomingItem?.sku);
    const existingSku = nonEmptyString(existing?.itemEntry.sku);
    const resolvedItemSku = payloadSku ?? incomingSku ?? existingSku ?? "";
    if (resolvedItemSku.length === 0) {
      return [];
    }

    if (!existing && action !== "new_item") {
      return [];
    }

    let storage: JsonObject | undefined;
    let consumeStorageSku: string | undefined;
    let addStorageSku: string | undefined;
    if (action === "new_item" && String(payload.storage ?? "").trim().length > 0) {
      storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
      if (getStorageItemAmount(storage, resolvedItemSku) <= 0) {
        return [];
      }
      consumeStorageSku = resolvedItemSku;
    } else if (action === "new_item" && ["2for1", "2per1"].includes(String(payload.offer ?? "").trim().toLowerCase())) {
      storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
      if (getStorageItemAmount(storage, resolvedItemSku) > 0) {
        consumeStorageSku = resolvedItemSku;
      } else {
        addStorageSku = resolvedItemSku;
      }
    } else if (action === "move" && String(payload.freeMove ?? "").trim().length > 0) {
      storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
      if (getStorageItemAmount(storage, "move") <= 0) {
        return [];
      }
      consumeStorageSku = "move";
    }

    const collectibleGroupSku = String(payload.collectible ?? "").trim();
    if (
      collectibleGroupSku.length > 0 &&
      !this.canClaimCollectibleItemReward(userId, collectibleGroupSku, resolvedItemSku)
    ) {
      return [];
    }

    const itemEntry = incomingItem ?? existing?.itemEntry ?? createItemEntry(payload, companyEntry);
    const itemChildren = getElementChildren(itemEntry, "Item");
    const shouldMoveCompanies =
      Boolean(existing) && String(existing?.companyEntry.sid ?? "") !== String(companyEntry.sid ?? "");

    if (payloadSku) {
      itemEntry.sku = payloadSku;
    } else if (incomingSku) {
      itemEntry.sku = incomingSku;
    } else if (existingSku) {
      itemEntry.sku = existingSku;
    }
    if (payload.x != null) {
      itemEntry.x = String(payload.x);
    } else if (incomingItem?.x != null) {
      itemEntry.x = String(incomingItem.x);
    } else if (typeof itemEntry.x !== "string") {
      itemEntry.x = "0";
    }
    if (payload.y != null) {
      itemEntry.y = String(payload.y);
    } else if (incomingItem?.y != null) {
      itemEntry.y = String(incomingItem.y);
    } else if (typeof itemEntry.y !== "string") {
      itemEntry.y = "0";
    }
    if (payload.isSuspended != null) {
      itemEntry.isSuspended = String(payload.isSuspended);
    } else if (incomingItem?.isSuspended != null) {
      itemEntry.isSuspended = String(incomingItem.isSuspended);
    } else if (typeof itemEntry.isSuspended !== "string") {
      itemEntry.isSuspended = "0";
    }

    itemEntry.sid = sid;
    itemEntry.csid = String(companyEntry.sid ?? payload.csid ?? "1");

    const existingState = findElementChild(itemChildren, "State");

    if (typeof itemEntry.sku === "string" && itemEntry.sku === "HeadQuarter") {
      ensureStateElement(itemChildren, { id: "4" });
      ensureHeadQuarterDecorations(itemChildren, String(companyEntry.whose ?? "0"));
    } else if (hasStateMutation(payload)) {
      const stateAttributes = extractStateAttributes(payload);
      if (stateAttributes.id == null && !existingState) {
        stateAttributes.id = "5";
      }
      ensureStateElement(itemChildren, stateAttributes);
    } else if (!existingState) {
      ensureStateElement(itemChildren, { id: "5" });
    }

    if (incomingItem && existing && !shouldMoveCompanies) {
      existing.companyChildren[existing.index] = itemEntry;
    }

    if (shouldMoveCompanies && existing) {
      existing.companyChildren.splice(existing.index, 1);
      getElementChildren(companyEntry, "Company").push(itemEntry);
    } else if (!existing) {
      getElementChildren(companyEntry, "Company").push(itemEntry);
    }

    const itemState = findElementChild(itemChildren, "State");
    if (itemState && String(itemState.id ?? "") === "0") {
      normalizeConstructionState(String(itemEntry.sku ?? ""), itemState, Date.now());
    }
    if (isHouseSku(String(itemEntry.sku ?? "")) && itemState && String(itemState.id ?? "") !== "0") {
      const mode = String(itemState.mode ?? "");
      if (mode !== "14" && mode !== "15") {
        normalizeHouseRentState(itemState, itemChildren, Date.now());
      }
    }

    const didChange = !existing || beforeSignature !== getItemMutationSignature(itemEntry);
    if (!didChange) {
      return [];
    }

    if (storage) {
      if (consumeStorageSku && !removeStorageItem(storage, consumeStorageSku)) {
        return [];
      }
      if (addStorageSku) {
        addStorageItem(storage, addStorageSku, 1, getStorageMaximumForSku(addStorageSku));
      }
      this.repository.setDocument(userId, SAVE_TAGS.storage, storage);
    }

    const shouldAddAutomaticFootprint =
      action === "new_item" && Object.prototype.hasOwnProperty.call(payload, "autoPlots");
    const shouldAddBoughtRivalFootprint =
      action === "new_mode" &&
      previousStateId === "3" &&
      previousMode === "3" &&
      Number(payload.mode) === 4;
    if (shouldAddAutomaticFootprint || shouldAddBoughtRivalFootprint) {
      applyItemTerrainFootprint(universe, itemEntry);
    }

    const collectibleSideEffects = this.applyCollectibleProjectionForItemMutation(
      userId,
      itemEntry,
      payload,
      profile,
      previousMode
    );
    if (collectibleGroupSku.length > 0) {
      this.applyCollectibleRewardItemMutation(userId, payload, itemEntry);
    }
    if (profile && hasMoneySecuritySnapshot(security)) {
      applyMoneySecuritySnapshotWithPositiveDeltaFallback(profile, security);
    }
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
    return collectibleSideEffects;
  }

  private applyMapMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    const mapEntry = getMapEntry(universe);
    if (!mapEntry) {
      return;
    }

    const tileType = String(payload.type ?? "");
    const tileX = Number(payload.x);
    const tileY = Number(payload.y);
    if (payload.x == null || payload.y == null || !Number.isInteger(tileX) || !Number.isInteger(tileY)) {
      return;
    }
    const tileKey = `${tileX}:${tileY}`;

    const action = String(payload.action ?? "").toLowerCase();
    const mapChildren = getElementChildren(mapEntry, "Map");
    const terrainTiles = parseChunkSet(findElementChild(mapChildren, "Terrain"));
    const roadTiles = parseChunkSet(findElementChild(mapChildren, "Road"));
    if (!applyMapTileMutation(terrainTiles, roadTiles, tileType, action, tileKey)) {
      return;
    }

    upsertChunkElement(mapChildren, "Terrain", terrainTiles);
    upsertChunkElement(mapChildren, "Road", roadTiles);

    const security = toRecord(payload.security);
    if (profile && hasMoneySecuritySnapshot(security)) {
      applyMoneySecuritySnapshotWithPositiveDeltaFallback(profile, security);
    }
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyPlotsMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    const plotsEntry = getPlotsEntry(universe);
    if (!plotsEntry) {
      return;
    }

    const states = getPlotStates(String(plotsEntry.type ?? ""));
    const beforeType = states.join(",");
    const index = Number(payload.index ?? -1);
    if (!Number.isInteger(index) || index < 0 || index >= states.length) {
      return;
    }

    const action = String(payload.action ?? "").toLowerCase();
    if (action !== "bought" || states[index] !== 1) {
      return;
    }

    states[index] = 2;
    unlockNextPlots(states, index);

    plotsEntry.type = states.join(",");
    const security = toRecord(payload.security);
    if (profile && hasMoneySecuritySnapshot(security) && beforeType !== plotsEntry.type) {
      applyMoneySecuritySnapshotWithPositiveDeltaFallback(profile, security);
    }
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyMissionsMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return;
    }

    if (String(payload.action ?? "") !== "update") {
      return;
    }

    const sku = String(payload.sku ?? "");
    if (sku.length === 0) {
      return;
    }

    const security = toRecord(payload.security);
    const profileChildren = getElementChildren(profile, "Profile");
    const missionsEntry = getOrCreateElementChild(profileChildren, "Missions");
    const missionChildren = getElementChildren(missionsEntry, "Missions");
    const up = parseChunkSet(findElementChild(missionChildren, "Up"));
    const reached = parseChunkSet(findElementChild(missionChildren, "Reached"));
    const given = parseChunkSet(findElementChild(missionChildren, "Given"));
    if (given.has(sku)) {
      return;
    }

    let shouldClaimReward = false;
    if (reached.delete(sku)) {
      given.add(sku);
      shouldClaimReward = true;
    } else if (up.delete(sku)) {
      reached.add(sku);
    } else {
      up.add(sku);
    }

    upsertChunkElement(missionChildren, "Up", up);
    upsertChunkElement(missionChildren, "Reached", reached);
    upsertChunkElement(missionChildren, "Given", given);

    if (shouldClaimReward) {
      applyPositiveMoneySecurityDeltas(profile, security);
    }

    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyUnlockedItemMutation(userId: number, skuValue: string): boolean {
    const sku = skuValue.trim();
    if (sku.length === 0) {
      return false;
    }

    const unlocked = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.unlocked);
    const children = getElementChildren(unlocked, "unlockedList");
    const alreadyUnlocked = children.some(
      (entry) => Array.isArray(entry.item) && String(entry.sku ?? "") === sku
    );
    if (!alreadyUnlocked) {
      children.push(createElement("item", { sku }));
      this.repository.setDocument(userId, SAVE_TAGS.unlocked, unlocked);
    }
    return true;
  }

  private applyBundlePurchaseMutation(userId: number, bundleSku: string): void {
    const customizer = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.customizer);
    const items = findBundleItems(customizer, bundleSku);
    if (items.length === 0) {
      return;
    }

    const storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
    let changed = false;
    for (const item of items) {
      changed =
        addStorageItem(storage, item.sku, item.amount, getStorageMaximumForSku(item.sku)) || changed;
    }
    if (changed) {
      this.repository.setDocument(userId, SAVE_TAGS.storage, storage);
    }
  }

  private applyRentAcceleratorStorageMutation(userId: number, giftDefinitionSku: string): boolean {
    const storageSku = resolveGiftStorageSku(giftDefinitionSku);
    if (!storageSku) {
      return false;
    }
    const storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
    if (!removeStorageItem(storage, storageSku)) {
      return false;
    }
    this.repository.setDocument(userId, SAVE_TAGS.storage, storage);
    return true;
  }

  private applyBoxPrizeMutation(
    userId: number,
    profile: MutableNode,
    payload: Record<string, unknown>,
    sourceSku: string,
    usesCounterMap: boolean
  ): boolean {
    const prize = getBoxPrizeDefinition(String(payload.prize ?? ""));
    const sequence = getBoxPrizeSequence(sourceSku);
    if (!prize || prize.sourceSku !== sourceSku || sequence.length === 0) {
      return false;
    }
    if (payload.type != null && String(payload.type).toLowerCase() !== prize.type) {
      return false;
    }
    if (payload.value != null && String(payload.value) !== prize.value) {
      return false;
    }

    const counters = parseBoxSequenceCounters(profile.bfcCnt);
    const currentPosition = usesCounterMap
      ? counters.get(sourceSku) ?? 0
      : readNonNegativeInteger(profile.bfcCnt, 0);
    const normalizedPosition = currentPosition % sequence.length;
    if (sequence[normalizedPosition]?.sku !== prize.sku) {
      return false;
    }

    const prizeAmount = readNonNegativeInteger(prize.value, 0);
    const reward: MoneyDeltas = {};
    if (prize.type === "cash") {
      reward.DCCoins = prizeAmount * getProfileLevel(profile);
    } else if (prize.type === "gold") {
      reward.DCCash = prizeAmount;
    } else if (prize.type === "exp") {
      reward.exp = prizeAmount;
    }
    if (!validateExactMoneySecurity(profile, toRecord(payload.security), reward, true)) {
      return false;
    }

    const storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
    if (!removeStorageItem(storage, sourceSku)) {
      return false;
    }
    if (prize.type === "move") {
      const amount = readNonNegativeInteger(prize.value, 0);
      addStorageItem(storage, "move", amount, getStorageMaximumForSku("move"));
    } else if (prize.type === "item") {
      addStorageItem(storage, prize.value, 1, getStorageMaximumForSku(prize.value));
    }
    this.repository.setDocument(userId, SAVE_TAGS.storage, storage);

    const nextPosition = (normalizedPosition + 1) % sequence.length;
    if (usesCounterMap) {
      counters.set(sourceSku, nextPosition);
      profile.bfcCnt = serializeBoxSequenceCounters(counters);
    } else {
      profile.bfcCnt = String(nextPosition);
    }
    applyExactMoneyDeltas(profile, reward);
    return true;
  }

  private applyDailyRewardMutation(userId: number, payload: Record<string, unknown>): void {
    const sku = String(payload.sku ?? "").trim();
    if (sku.length === 0) {
      return;
    }

    const dailyRewards = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.dailyBonus);
    const claim = claimDailyReward(dailyRewards, sku, Date.now());
    if (!claim) {
      return;
    }

    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return;
    }

    const security = toRecord(payload.security);
    if (claim.reward.bonusType === "item") {
      const securityItem = String(security?.item ?? "").trim();
      if (
        (securityItem.length > 0 && securityItem !== claim.reward.bonusValue) ||
        !validateExactMoneySecurity(profile, security, {}, true)
      ) {
        return;
      }
      const storage = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
      addStorageItem(
        storage,
        claim.reward.bonusValue,
        1,
        getStorageMaximumForSku(claim.reward.bonusValue)
      );
      this.repository.setDocument(userId, SAVE_TAGS.storage, storage);
    } else if (!applyDailyRewardValue(profile, claim.reward, security)) {
      return;
    }

    this.repository.setDocument(userId, SAVE_TAGS.dailyBonus, claim.document);
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyPollManagerMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return;
    }

    const profileChildren = getElementChildren(profile, "Profile");
    const incomingPollManager = extractIncomingElement(payload.xml, "PollManager");
    if (incomingPollManager) {
      upsertElementChild(profileChildren, "PollManager", incomingPollManager);
      this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
      return;
    }

    const type = String(payload.type ?? "");
    if (type.length === 0) {
      return;
    }

    const sku = `${type}${String(payload.parameter ?? "")}`;
    const pollManagerEntry = getOrCreateElementChild(profileChildren, "PollManager");
    const pollChildren = getElementChildren(pollManagerEntry, "PollManager");
    const counts = parseCountChunkSet(findElementChild(pollChildren, "Count"));
    const action = String(payload.action ?? "").toLowerCase();

    if (action === "add") {
      counts.set(sku, (counts.get(sku) ?? 0) + 1);
    } else {
      const value = Number(payload.value ?? 0);
      if (!Number.isFinite(value)) {
        return;
      }
      counts.set(sku, value);
    }

    upsertCountChunkElement(pollChildren, "Count", counts);
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }
}

function applyItemTerrainFootprint(universe: JsonObject, itemEntry: JsonObject): boolean {
  const mapEntry = getMapEntry(universe);
  if (!mapEntry) {
    return false;
  }

  const mapChildren = getElementChildren(mapEntry, "Map");
  const terrainTiles = parseChunkSet(findElementChild(mapChildren, "Terrain"));
  const roadTiles = parseChunkSet(findElementChild(mapChildren, "Road"));
  if (
    !addTerrainFootprint(
      terrainTiles,
      roadTiles,
      String(itemEntry.sku ?? ""),
      itemEntry.x,
      itemEntry.y
    )
  ) {
    return false;
  }

  upsertChunkElement(mapChildren, "Terrain", terrainTiles);
  upsertChunkElement(mapChildren, "Road", roadTiles);
  return true;
}

function nonEmptyString(value: unknown): string | undefined {
  return typeof value === "string" && value.length > 0 ? value : undefined;
}

function normalizeBossGenreValue(value: unknown): string {
  return String(value ?? "0").trim() === "1" ? "1" : "0";
}

function getItemMutationSignature(itemEntry: MutableNode): string {
  const state = findElementChild(getElementChildren(itemEntry, "Item"), "State");
  return JSON.stringify({
    sid: itemEntry.sid ?? "",
    csid: itemEntry.csid ?? "",
    sku: itemEntry.sku ?? "",
    x: itemEntry.x ?? "",
    y: itemEntry.y ?? "",
    isSuspended: itemEntry.isSuspended ?? "",
    state: state ? getStableScalarRecord(state) : {}
  });
}

function getStableScalarRecord(value: MutableNode): Record<string, string> {
  const record: Record<string, string> = {};
  for (const key of Object.keys(value).sort()) {
    const entry = value[key];
    if (Array.isArray(entry) || entry == null || typeof entry === "object") {
      continue;
    }
    record[key] = String(entry);
  }
  return record;
}

function normalizeCheckmailState(currentValue: unknown, nextValue: unknown): string {
  const current = parseCheckmailState(currentValue);
  const next = parseCheckmailState(nextValue);
  return String(Math.max(current, next));
}

function parseCheckmailState(value: unknown): number {
  const parsed = Number(value ?? 0);
  if (!Number.isFinite(parsed)) {
    return 0;
  }

  return Math.min(2, Math.max(0, Math.trunc(parsed)));
}

type MoneyDeltas = Partial<Record<"exp" | "DCCoins" | "DCCash" | "companyValue", number>>;

const MONEY_SECURITY_FIELDS = {
  exp: { delta: "expGain", absolute: "expNow" },
  DCCoins: { delta: "coinsGain", absolute: "coinsNow" },
  DCCash: { delta: "cashGain", absolute: "cashNow" },
  companyValue: { delta: "compValueGain", absolute: "compValueNow" }
} as const;

function validateExactMoneySecurity(
  profile: MutableNode,
  security: Record<string, unknown> | undefined,
  expected: MoneyDeltas,
  allowMissing: boolean
): boolean {
  const hasExpectedDelta = Object.values(expected).some((value) => Number(value ?? 0) !== 0);
  if (!security) {
    return allowMissing || !hasExpectedDelta;
  }

  for (const [profileKey, keys] of Object.entries(MONEY_SECURITY_FIELDS) as Array<
    [keyof typeof MONEY_SECURITY_FIELDS, { delta: string; absolute: string }]
  >) {
    const expectedDelta = Number(expected[profileKey] ?? 0);
    const current = Number(profile[profileKey] ?? 0);
    if (!Number.isFinite(expectedDelta) || !Number.isFinite(current)) {
      return false;
    }

    const hasDelta = Object.prototype.hasOwnProperty.call(security, keys.delta);
    const actualDelta = hasDelta ? Number(security[keys.delta]) : 0;
    if (!Number.isFinite(actualDelta) || actualDelta !== expectedDelta) {
      return false;
    }

    if (Object.prototype.hasOwnProperty.call(security, keys.absolute)) {
      const absolute = Number(security[keys.absolute]);
      if (!Number.isFinite(absolute) || absolute !== current + expectedDelta) {
        return false;
      }
    }
  }
  return true;
}

function applyExactMoneyDeltas(profile: MutableNode, deltas: MoneyDeltas): void {
  for (const profileKey of Object.keys(MONEY_SECURITY_FIELDS) as Array<keyof typeof MONEY_SECURITY_FIELDS>) {
    const delta = Number(deltas[profileKey] ?? 0);
    if (!Number.isFinite(delta) || delta === 0) {
      continue;
    }
    const current = Number(profile[profileKey] ?? 0);
    if (Number.isFinite(current)) {
      profile[profileKey] = String(current + delta);
    }
  }
}

function applyDailyRewardValue(
  profile: MutableNode,
  reward: DailyRewardDefinition,
  security: Record<string, unknown> | undefined
): boolean {
  const amount = readNonNegativeInteger(reward.bonusValue, -1);
  if (amount < 0) {
    return false;
  }

  const deltas: MoneyDeltas = {};
  if (reward.bonusType === "exp") {
    deltas.exp = amount;
  } else if (reward.bonusType === "coins") {
    deltas.DCCoins = amount;
  } else if (reward.bonusType === "cash" || reward.bonusType === "gold") {
    deltas.DCCash = amount;
  } else {
    return false;
  }

  if (!validateExactMoneySecurity(profile, security, deltas, true)) {
    return false;
  }
  applyExactMoneyDeltas(profile, deltas);
  return true;
}

function updateProfileFlag(currentValue: string, name: string, value: string): string {
  const entries = new Map<string, string>();
  for (const rawEntry of currentValue.split(",")) {
    const separator = rawEntry.indexOf(":");
    if (separator <= 0) {
      continue;
    }
    entries.set(rawEntry.slice(0, separator), rawEntry.slice(separator + 1));
  }
  entries.set(name, value);
  return `${Array.from(entries, ([key, entryValue]) => `${key}:${entryValue}`).join(",")},`;
}

function readNonNegativeInteger(value: unknown, fallback: number): number {
  const parsed = Number(value ?? fallback);
  return Number.isFinite(parsed) && parsed >= 0 ? Math.trunc(parsed) : fallback;
}

function parseBoxSequenceCounters(value: unknown): Map<string, number> {
  const counters = new Map<string, number>();
  for (const rawEntry of String(value ?? "").split(",")) {
    const separator = rawEntry.lastIndexOf(":");
    if (separator <= 0) {
      continue;
    }
    const sku = rawEntry.slice(0, separator).trim();
    const position = readNonNegativeInteger(rawEntry.slice(separator + 1), -1);
    if (sku.length > 0 && position >= 0) {
      counters.set(sku, position);
    }
  }
  return counters;
}

function serializeBoxSequenceCounters(counters: Map<string, number>): string {
  return Array.from(counters, ([sku, position]) => `${sku}:${position}`).join(",");
}
