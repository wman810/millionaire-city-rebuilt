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
  normalizeHouseRentState,
  normalizeCompletedTutorialUniverse
} from "./saveDefaults.js";
import {
  createElement,
  findElementChild,
  getElementChildren,
  getOrCreateElementChild,
  parseChunkSet,
  serializeChunkSet,
  upsertChunkElement,
  upsertElementChild
} from "./saveTree.js";
import {
  collapsePendingCollectibleState,
  isCollectibleAwardMutation,
  isCollectibleFeatureUnlocked,
  normalizeCollectiblePendingDocument,
  normalizeCollectiblesDocument,
  pickCollectibleSkuForHouse,
  projectPendingCollectiblesOnUniverse,
  readCollectiblesState,
  removePendingFriendCollectible,
  resolvePlaneRewardSkuForCollectibleClaim,
  shouldAwardCollectibleDrop,
  writeCollectiblesState
} from "./commandHandlers/collectibles.js";
import { decodeAsciiCodes, encodeAsciiCodes, sanitizeForClientXml, sanitizeStoredString, sanitizeUniverseForClient } from "./commandHandlers/encoding.js";
import {
  applyMoneySecuritySnapshot,
  hasMoneySecuritySnapshot,
  hasNegativeSecurityDelta,
  reconcilePremiumCurrencyPurchase
} from "./commandHandlers/money.js";
import { getPlotStates, unlockNextPlots } from "./commandHandlers/plots.js";
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
  type MutableNode
} from "./commandHandlers/universe.js";
import { getLocalDayKey, getStoredUpgradeRecords, setStoredUpgradeRecords, VISITOR_UPGRADES_PER_DAY } from "./commandHandlers/upgrades.js";

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
        const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
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
        return isCollectibleFeatureUnlocked(getUniverseProfile(playerUniverse))
          ? projectPendingCollectiblesOnUniverse(playerUniverse, collectiblesDocument)
          : playerUniverse;
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
      case "get_storage_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.storage);
      case "get_collectibles_list":
        return this.getNormalizedCollectiblesDocument(userId);
      case "get_friends_collectible_sents_list":
        return this.getNormalizedCollectiblePendingDocument(userId);
      case "get_daily_rewards_info":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.dailyBonus);
      case "get_partners_list":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.partners);
      case "get_welcome_progress":
        return this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.welcome);
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
        this.repository.setDocument(userId, SAVE_TAGS.dailyBonus, {
          dailyBonusInfo: [],
          dailyRewardsCount: String(Number(payload.dailyRewardsCount ?? 1)),
          dailyRewardsLastGiven: String(payload.dailyRewardsLastGiven ?? ""),
          dailyRewardsLastGivenDate: String(payload.dailyRewardsLastGivenDate ?? Date.now()),
          dailyRewardsNextRewardId: String(payload.dailyRewardsNextRewardId ?? "")
        });
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

    if (command._cmd === "ask_for_help" || command._cmd === "ask_for_cash") {
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

    if (command._cmd === "update_collectible") {
      switch (action) {
        case "KEEP":
          this.applyCollectibleKeepMutation(userId, payload);
          break;
        case "SELL":
          this.applyCollectibleSellMutation(userId, payload);
          break;
        case "GET_REWARD":
          this.applyCollectibleRewardMutation(userId, payload);
          break;
        case "SEND":
          this.applyCollectibleSendMutation(userId, payload);
          break;
        default:
          break;
      }
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
    const todayKey = getLocalDayKey();
    const activeRecords = allRecords.filter(
      (record) =>
        record.ownerId === String(ownerId) &&
        record.dayKey === todayKey &&
        targetUniverse &&
        isUpgradeEligibleItem(targetUniverse, record.sid)
    );
    const visitorCount = activeRecords.filter((record) => record.visitorExtId === visitorExtId).length;

    return createElement(
      "upgradesList",
      {
        upgradesUniverseAvailable: String(Math.max(0, VISITOR_UPGRADES_PER_DAY - visitorCount))
      },
      activeRecords.map((record) =>
        createElement("upgrade", {
          sid: record.sid,
          extId: record.visitorExtId
        })
      )
    );
  }

  private applyUpgradeCommand(userId: number, payload: Record<string, unknown>): void {
    const sid = String(payload.sid ?? "");
    const ownerId = resolveUpgradeOwnerId(payload, sid);
    if (sid.length === 0) {
      return;
    }

    const playerUniverse = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const visitorExtId = String(getUniverseProfile(playerUniverse)?.extId ?? "");
    const bossGenre = Number(getUniverseProfile(playerUniverse)?.bossGenre ?? 0);
    const targetUniverse =
      ownerId === DEFAULT_USER_ID ? playerUniverse : createNeighborUniverse(ownerId, bossGenre);

    if (!targetUniverse || !isUpgradeEligibleItem(targetUniverse, sid)) {
      return;
    }

    const upgradesDocument = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.upgrades);
    const records = getStoredUpgradeRecords(upgradesDocument).filter((record) => record.dayKey >= getLocalDayKey(-7));
    const todayKey = getLocalDayKey();
    const existingRecord = records.some(
      (record) =>
        record.ownerId === String(ownerId) &&
        record.sid === sid &&
        record.visitorExtId === visitorExtId &&
        record.dayKey === todayKey
    );
    if (existingRecord) {
      return;
    }

    const visitorCount = records.filter(
      (record) =>
        record.ownerId === String(ownerId) &&
        record.visitorExtId === visitorExtId &&
        record.dayKey === todayKey
    ).length;
    if (visitorCount >= VISITOR_UPGRADES_PER_DAY) {
      return;
    }

    records.push({
      ownerId: String(ownerId),
      sid,
      visitorExtId,
      type: String(payload.type ?? "0"),
      dayKey: todayKey
    });

    setStoredUpgradeRecords(upgradesDocument, records);
    this.repository.setDocument(userId, SAVE_TAGS.upgrades, upgradesDocument);
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
        normalizeCompletedTutorialUniverse(universe);
        break;
      }
      case "city_name": {
        const cityName = sanitizeStoredString(String(value ?? profile.cityname ?? DEFAULT_CITY_NAME));
        profile.cityname = cityName;
        profile.cityNameCodes = encodeAsciiCodes(cityName);
        normalizeCompletedTutorialUniverse(universe);
        break;
      }
      case "boss_genre":
        profile.bossGenre = String(value ?? "0");
        break;
      case "gameConfig":
        this.applyGameConfigProfileMutation(userId, payload);
        break;
      case "tutorial_completed":
        profile.tutorialEnd = "1";
        normalizeCompletedTutorialUniverse(universe);
        break;
      case "firstMission":
        profile.firstMission = String(value ?? "0");
        normalizeCompletedTutorialUniverse(universe);
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
      case "checkmail":
        profile.checkmail = String(value ?? "0");
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

    switch (action) {
      case "first_visit":
        profile.firstVisit = String(payload.value ?? "1");
        break;
      case "firstPartner":
        profile.firstPartner = String(payload.value ?? "1");
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

  private applyCollectibleKeepMutation(userId: number, payload: Record<string, unknown>): void {
    const sid = String(payload.sid ?? "");
    const sku = String(payload.sku ?? "");
    if (sid.length === 0 || sku.length === 0) {
      return;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    let changed = false;

    if (sid.startsWith("f")) {
      const pendingDocument = this.getNormalizedCollectiblePendingDocument(userId);
      changed = removePendingFriendCollectible(pendingDocument, sid.slice(1), sku) || changed;
      if (changed) {
        this.repository.setDocument(userId, SAVE_TAGS.collectiblePending, pendingDocument);
      }
    } else if (collectibleState.pendingBySid.delete(sid)) {
      changed = true;
    }

    collectibleState.objectCounts.set(sku, (collectibleState.objectCounts.get(sku) ?? 0) + 1);
    changed = true;

    if (changed) {
      writeCollectiblesState(collectiblesDocument, collectibleState);
      this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);
    }
  }

  private applyCollectibleSellMutation(userId: number, payload: Record<string, unknown>): void {
    const sku = String(payload.sku ?? "");
    if (sku.length === 0) {
      return;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    const currentCount = collectibleState.objectCounts.get(sku) ?? 0;
    if (currentCount <= 0) {
      return;
    }

    if (currentCount === 1) {
      collectibleState.objectCounts.delete(sku);
    } else {
      collectibleState.objectCounts.set(sku, currentCount - 1);
    }
    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);
  }

  private applyCollectibleSendMutation(userId: number, payload: Record<string, unknown>): void {
    this.applyCollectibleSellMutation(userId, payload);
  }

  private applyCollectibleRewardMutation(userId: number, payload: Record<string, unknown>): void {
    const sku = String(payload.sku ?? "");
    if (sku.length === 0) {
      return;
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    collectibleState.rewards.add(sku);
    writeCollectiblesState(collectiblesDocument, collectibleState);
    this.repository.setDocument(userId, SAVE_TAGS.collectibles, collectiblesDocument);

    const planeSku = resolvePlaneRewardSkuForCollectibleClaim(sku);
    if (!planeSku) {
      return;
    }

    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile || String(profile.planeSku ?? "") === planeSku) {
      return;
    }

    profile.planeSku = planeSku;
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyCollectibleProjectionForItemMutation(
    userId: number,
    itemEntry: MutableNode,
    payload: Record<string, unknown>
  ): PacketCommand[] {
    const state = findElementChild(getElementChildren(itemEntry, "Item"), "State");
    if (!state || !isHouseSku(String(itemEntry.sku ?? ""))) {
      return [];
    }

    const mode = String(state.mode ?? "");
    if (mode === "14" || mode === "15") {
      collapsePendingCollectibleState(state);
      return [];
    }

    if (!isCollectibleAwardMutation(payload, state)) {
      return [];
    }

    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!isCollectibleFeatureUnlocked(profile)) {
      return [];
    }

    const collectiblesDocument = this.getNormalizedCollectiblesDocument(userId);
    const collectibleState = readCollectiblesState(collectiblesDocument);
    const sid = String(itemEntry.sid ?? "");
    if (sid.length === 0 || collectibleState.pendingBySid.has(sid)) {
      return [];
    }

    if (!shouldAwardCollectibleDrop(itemEntry, state)) {
      return [];
    }

    const collectibleSku = pickCollectibleSkuForHouse(String(itemEntry.sku ?? ""), sid, collectibleState);
    if (!collectibleSku) {
      return [];
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

  private applyItemMutation(userId: number, payload: Record<string, unknown>): PacketCommand[] {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const action = String(payload.action ?? "").toLowerCase();
    const sid = String(payload.sid ?? "");
    const incomingItem = extractIncomingItemEntry(payload.item);

    if (sid.length === 0) {
      return [];
    }

    const existing = findItemEntry(universe, sid);

    if (action.includes("destroy") || action.includes("sell") || action.includes("remove")) {
      if (existing) {
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

    const itemEntry = incomingItem ?? existing?.itemEntry ?? createItemEntry(payload, companyEntry);
    const itemChildren = getElementChildren(itemEntry, "Item");
    const shouldMoveCompanies =
      Boolean(existing) && String(existing?.companyEntry.sid ?? "") !== String(companyEntry.sid ?? "");

    const payloadSku = nonEmptyString(payload.sku);
    const incomingSku = nonEmptyString(incomingItem?.sku);
    const existingSku = nonEmptyString(existing?.itemEntry.sku);
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
    const collectibleSideEffects = this.applyCollectibleProjectionForItemMutation(userId, itemEntry, payload);
    if (isHouseSku(String(itemEntry.sku ?? "")) && itemState && String(itemState.id ?? "") !== "0") {
      const mode = String(itemState.mode ?? "");
      if (mode !== "14" && mode !== "15") {
        normalizeHouseRentState(itemState, itemChildren, Date.now());
      }
    }
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
    return collectibleSideEffects;
  }

  private applyMapMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const mapEntry = getMapEntry(universe);
    if (!mapEntry) {
      return;
    }

    const tileType = String(payload.type ?? "").toLowerCase();
    const tileKey =
      payload.x != null && payload.y != null ? `${String(payload.x)}:${String(payload.y)}` : "";
    if (tileKey.length === 0 || (tileType !== "terrain" && tileType !== "road")) {
      return;
    }

    const action = String(payload.action ?? "").toLowerCase();
    const mapChildren = getElementChildren(mapEntry, "Map");
    const terrainTiles = parseChunkSet(findElementChild(mapChildren, "Terrain"));
    const roadTiles = parseChunkSet(findElementChild(mapChildren, "Road"));
    const targetSet = tileType === "terrain" ? terrainTiles : roadTiles;

    if (action.includes("del") || action.includes("remove")) {
      targetSet.delete(tileKey);
    } else {
      targetSet.add(tileKey);
    }

    const nextChildren: JsonObject[] = [];
    if (terrainTiles.size > 0) {
      nextChildren.push(createElement("Terrain", { chunk: serializeChunkSet(terrainTiles) }));
    }
    if (roadTiles.size > 0) {
      nextChildren.push(createElement("Road", { chunk: serializeChunkSet(roadTiles) }));
    }
    mapEntry.Map = nextChildren;

    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyPlotsMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const plotsEntry = getPlotsEntry(universe);
    if (!plotsEntry) {
      return;
    }

    const states = getPlotStates(String(plotsEntry.type ?? ""));
    const index = Number(payload.index ?? -1);
    if (!Number.isInteger(index) || index < 0 || index >= states.length) {
      return;
    }

    const action = String(payload.action ?? "").toLowerCase();
    if (action === "bought") {
      states[index] = 2;
      unlockNextPlots(states, index);
    }

    plotsEntry.type = states.join(",");
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }

  private applyMissionsMutation(userId: number, payload: Record<string, unknown>): void {
    const universe = this.repository.getDocument<JsonObject>(userId, SAVE_TAGS.universe);
    const profile = getUniverseProfile(universe);
    if (!profile) {
      return;
    }

    const profileChildren = getElementChildren(profile, "Profile");
    const incomingMissions = extractIncomingElement(payload.xml, "Missions");
    if (incomingMissions) {
      upsertElementChild(profileChildren, "Missions", incomingMissions);
      this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
      return;
    }

    const sku = String(payload.sku ?? "");
    if (sku.length === 0) {
      return;
    }

    const security = toRecord(payload.security);
    const missionsEntry = getOrCreateElementChild(profileChildren, "Missions");
    const missionChildren = getElementChildren(missionsEntry, "Missions");
    const up = parseChunkSet(findElementChild(missionChildren, "Up"));
    const reached = parseChunkSet(findElementChild(missionChildren, "Reached"));
    const given = parseChunkSet(findElementChild(missionChildren, "Given"));

    up.delete(sku);
    if (given.has(sku)) {
      reached.delete(sku);
    } else if (reached.has(sku) || hasNegativeSecurityDelta(security)) {
      reached.delete(sku);
      given.add(sku);
    } else {
      reached.add(sku);
    }

    upsertChunkElement(missionChildren, "Up", up);
    upsertChunkElement(missionChildren, "Reached", reached);
    upsertChunkElement(missionChildren, "Given", given);

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
      normalizeCompletedTutorialUniverse(universe);
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
    normalizeCompletedTutorialUniverse(universe);
    this.repository.setDocument(userId, SAVE_TAGS.universe, universe);
  }
}

function nonEmptyString(value: unknown): string | undefined {
  return typeof value === "string" && value.length > 0 ? value : undefined;
}
