package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.missions.MissionDefinitionManager;
   import com.dchoc.dollars.model.ActionGetCrewMechanicsDefinitions;
   import com.dchoc.dollars.model.ModelAction;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.utils.Utils;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.world.contracts.ContractDefinitionManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinition;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinitionManager;
   import flash.events.Event;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class RulesFacade
   {
      
      private static var smLevelDCCashLevelUp:Array;
      
      private static var smLevelBreakIncomeTimeMin:Array;
      
      private static var mTimePrice:Number;
      
      private static var smLevelTimePriceTable:Array;
      
      private static var mRenovatePriceOffPercentage:int;
      
      private static var mInstance:RulesFacade;
      
      private static var smDCCashToDCCoins:int;
      
      private static var smFBCreditsToDCCoins:int;
      
      private static var smNewToolRev:int;
      
      private static var smLevelFBCreditToCoins:Array;
      
      private static var smLevelBreakMaxItemsPercentage:Array;
      
      private static var smLevelXPTable:Array;
      
      private static var smMaxLevels:int;
      
      private static var smLevelRepairTimeDice:Array;
      
      private static var smShopNewItemTimer:int;
      
      private static var smLevelBreakIncomeTimePercentage:Array;
      
      private static var smNewItemsRev:int;
      
      private static var mShowHelpPopupTimer:int;
      
      private static var smLevelRepairPricePercentage:Array;
      
      private static var mAllowInstantiation:Boolean;
      
      private static var mDailyBonus:int;
      
      private static var smPopupHelpTimerThreshold:int;
      
      private static var smLevelTerrainPriceTable:Array;
      
      private static var mDailyBonusTimeInit:int;
      
      public static const UNLOCK_SEGMENTS_MODE_LIMITED:int = 0;
      
      public static const UNLOCK_SEGMENTS_MODE_UNLIMITED:int = 1;
      
      public static const UNLOCK_SEGMENTS_MODE_UNALLOWED:int = 2;
      
      public static const UNLOCK_SEGMENTS_MODE_DEFAULT:int = UNLOCK_SEGMENTS_MODE_LIMITED;
      
      private static const SIG_KEYS_ORDER:Array = [Config.getRoot() + ModelConfig.ITEM_DEFINITIONS_XML_FILE,Config.getRoot() + ModelConfig.COMMERCE_DEFINITIONS_XML_FILE,Config.getRoot() + ModelConfig.DECORATION_DEFINITIONS_XML_FILE,Config.getRoot() + ModelConfig.WONDER_DEFINITIONS_XML_FILE,Config.getRoot() + ModelConfig.CONTRACT_DEFINITIONS_XML_FILE,Config.getRoot() + ModelConfig.CONTRACTS_TYPE_DEFINITIONS_XML_FILE,Config.getRoot() + ModelConfig.MISSION_DEFINITIONS_XML_FILE,Config.getRoot() + ModelConfig.FREE_GIFTS_DEFINITIONS_XML_FILE];
      
      private var mSocialUpgradesVisitorDCCoinsPerUpgrade:Array;
      
      private var mGetInfoFromXMLActions:Array;
      
      private var ACTION_GET_WONDERS_DEFINITIONS:int = 3;
      
      private var mUnlockSegmentsMode:int;
      
      private var mSettingsIncomeMultiplier:int;
      
      private var mSettingsSideTabsUnlockLevel:int;
      
      private var mUniverseMapPersistence:XML;
      
      private var mUnlockSegmentsBasePriceGold:Array;
      
      private var mExpansionsPlotHeight:Array;
      
      private var mUnlockSegmentsVisibilityLevelsCount:Array;
      
      private var mSettingsTimeToPutItemOnSaleMax:int;
      
      private var mNpcsXps:Array;
      
      private var mExpansionsPlotX:Array;
      
      private var mExpansionsPlotY:Array;
      
      private var mSocialUpgradesVisitorExpPerUpgrade:Array;
      
      private var mSettingsTimeItemOnSaleMin:int;
      
      private var mUnlockSegmentsLoaded:Boolean;
      
      private var mSocialUpgradesAvailablePerVisitor:int;
      
      private var mSettingsInvestmentsUnlockLevel:int;
      
      private var mSocialSuperUpgradesTimeToAllowReminding:Number;
      
      private var ACTION_GET_REWARD_TYPE_DEFINITIONS:int = 24;
      
      private var mUnlockSegmentsVisibilityLevelStart:Array;
      
      private var mSettingsDestroyItemProfitPercentage:int;
      
      private var mSigPerFile:Dictionary;
      
      private var mNpcsCompanyValues:Array;
      
      private var mExpansionsPlotWidth:Array;
      
      private var ACTION_GET_ITEM_DEFINITIONS:int = 0;
      
      private var mSettingsCollectibleMaxUnitsPerItem:int;
      
      private var mNpcsLoaded:Boolean;
      
      private var mSettingsCrmPopupTimer:int;
      
      private var mExpansionsPlotUnlockOrder:Dictionary;
      
      private var mUnlockSegmentsVisibilityLevelEnd:Array;
      
      private var ACTION_GET_CONTRACTS_TYPE_DEFINITIONS:int = 21;
      
      private var ACTION_GET_COMMERCE_TYPE_DEFINITIONS:int = 6;
      
      private var mExpansionsPlotIndicesByUnlockOrder:Dictionary;
      
      private var mSettingsUpgradesVisitorExpPerUpgrade:int;
      
      private var mSigTotal:int;
      
      private var mUnlockSegmentsVisibilityLoaded:Boolean;
      
      private var mArrayExpansions:Array;
      
      private var mSettingsInitialDCCash:int;
      
      private var mUnlockSegmentsLevelEnd:Array;
      
      private var mExpansionsUnlockOrderCount:int;
      
      private var mSettingsInitialDCCoins:int;
      
      private var mSettingsContractSignatorAreaX:int;
      
      private var mSettingsContractSignatorAreaY:int;
      
      private var mSettingsCollectiblesUnlockLevel:int;
      
      private var ACTION_GET_ACCELERATOR_DEFINITIONS:int = 13;
      
      private var mSocialLoaded:Boolean;
      
      private var mSettingsUnlockMaxPriceFBCredits:int;
      
      private var ACTION_GET_COLLECTIBLE_GROUPS:int = 26;
      
      private var mUnlockSegmentsBasePriceFBCredits:Array;
      
      private var mUnlockSegmentsLevelStart:Array;
      
      private var ACTION_GET_CONTRACT_DEFINITIONS:int = 19;
      
      private var ACTION_GET_MAP_DEFINITION:int = 12;
      
      private var ACTION_GET_TRAFFIC_AGENT_DEFINITIONS:int = 15;
      
      private var mSettingsUpgradesAvailablePerVisitor:int;
      
      private var ACTION_GET_NEWS_FEED_DEFINITIONS:int = 23;
      
      private var mSettingsTimeToPutItemOnSaleMin:int;
      
      private var ACTION_GET_DECORATION_DEFINITIONS:int = 2;
      
      private var ACTION_GET_SERVICE_DEFINITIONS:int = 22;
      
      private var mUnlockSegmentsCheckVisibility:Boolean;
      
      private var mSocialInvestAskForSpeedTime:int;
      
      private var mExpansionsPlotConsecutiveSameUnlockOrder:Array;
      
      private var mHireCrewPriceFBC:int;
      
      private var mSettingsSellPricePercentage:int;
      
      private var ACTION_GET_GUI_SHOP_TAB_DEFINITIONS:int = 14;
      
      private var mExpansionsLoaded:Boolean;
      
      private var mExpansionsFriendsNeeded:Array;
      
      private var mNpcsUrls:Array;
      
      private var mSettingsAbandonTimePercentage:int;
      
      private var ACTION_GET_WONDER_TYPE_DEFINITIONS:int = 7;
      
      private var ACTION_GET_COMMERCE_DEFINITIONS:int = 1;
      
      private var ACTION_GET_TRAFFIC_AGENT_MANAGER_DEFINITION:int = 16;
      
      private var mNpcsSkus:Array;
      
      private var ACTION_GET_HQ_DECORATION_FLAG_DEFINITIONS:int = 4;
      
      private var mSettingsHelpConstructionMinTime:int;
      
      private var mSettingsTimeItemOnSaleMax:int;
      
      private var mExpansionsDCCash:Array;
      
      private var mExpansionsPricesLoaded:Boolean;
      
      private var mSettingsUnlockMaxPrice:int;
      
      private var mSettingsUpgradesVisitorDCCoinsPerUpgrade:int;
      
      private var mExpansionsFBCredits:Array;
      
      private var ACTION_GET_MISSION_DEFINITIONS:int = 11;
      
      private var mSocialUpgradesOwnerExtraPercentage:Array;
      
      private var mSettingsCompanyValueBreakPercentage:int;
      
      private var mSettingsCancelContractProfitPercentage:int;
      
      private var mSocialInvestRemindTime:int;
      
      private var mSettingsManagersPricePercentage:int;
      
      private var mExpansionsPlotMinis:Array;
      
      private var mExpansionsDCCoins:Array;
      
      private var mSettingsDestroyTerrainProfitPercentage:int;
      
      private var mSettingsLoaded:Boolean;
      
      private var ACTION_GET_CONSTRACT_NAME_DEFINITION:int = 20;
      
      private var mSettingsAbandonMinTime:int;
      
      private var mNpcsCompanyXps:Array;
      
      private const NPCS_ADVISOR_USER_ID:int = 0;
      
      private var mSettingsUpgradesOwnerExtraPercentage:int;
      
      private var ACTION_GET_INVEST_DEFINITIONS:int = 18;
      
      private var ACTION_GET_HQ_DECORATION_SKIN_DEFINITIONS:int = 5;
      
      private var mSettingsLimEdSoldOutShowTime:Number;
      
      private var mSettingsMoneyCollectorAreaX:int;
      
      private var mExpansionsMiniToPlot:Dictionary;
      
      private var mSettingsMoneyCollectorAreaY:int;
      
      private var mLevelLoaded:Boolean;
      
      private var mAskForHelpAccelerateItemPercent:int;
      
      public function RulesFacade()
      {
         super();
         if(!mAllowInstantiation)
         {
            throw new Error("ERROR: RulesFacade Error: Instantiation failed: Use ModelFacade.getInstance() instead of new.");
         }
      }
      
      public static function get maxLevel() : int
      {
         return smMaxLevels;
      }
      
      public static function getLevelTerrainPrice(param1:int) : int
      {
         return smLevelTerrainPriceTable[param1];
      }
      
      public static function getInstance() : RulesFacade
      {
         if(mInstance == null)
         {
            mAllowInstantiation = true;
            mInstance = new RulesFacade();
            mAllowInstantiation = false;
         }
         return mInstance;
      }
      
      public static function getInstantBuildPrice(param1:Number, param2:Number) : int
      {
         return DollarsGame.getProfile().getTimePrice(param1) * param2;
      }
      
      public static function get helpPopupTimerThresHold() : int
      {
         return smPopupHelpTimerThreshold;
      }
      
      public static function getLevelFBCreditConversion(param1:int) : int
      {
         return smLevelFBCreditToCoins[param1];
      }
      
      public static function get helpPopupTimer() : int
      {
         return mShowHelpPopupTimer;
      }
      
      public static function getDCCashToDCCoins() : int
      {
         return smDCCashToDCCoins;
      }
      
      public static function getLevelBreakMaxItemsPercentage(param1:int) : int
      {
         return smLevelBreakMaxItemsPercentage[param1];
      }
      
      public static function getLevelBreakIncomeTimeMin(param1:int) : int
      {
         return smLevelBreakIncomeTimeMin[param1];
      }
      
      public static function getLevelRepairTimeDice(param1:int) : int
      {
         return smLevelRepairTimeDice[param1];
      }
      
      public static function getLevelBreakMaxItems(param1:int, param2:int) : int
      {
         return param2 * smLevelBreakMaxItemsPercentage[param1] / 100;
      }
      
      public static function getTimePrice() : Number
      {
         return mTimePrice;
      }
      
      public static function getLevelXP(param1:int) : Number
      {
         return smLevelXPTable[param1];
      }
      
      public static function getLevelTimePrice(param1:int) : Number
      {
         return smLevelTimePriceTable[param1];
      }
      
      public static function getLevelRepairPricePercentage(param1:int) : int
      {
         return smLevelRepairPricePercentage[param1];
      }
      
      public static function getRenovatePrice(param1:ItemObject) : int
      {
         var _loc2_:int = int(param1.value);
         return _loc2_ - _loc2_ * mRenovatePriceOffPercentage / 100;
      }
      
      public static function getFBCreditsToDCCoins() : int
      {
         return smFBCreditsToDCCoins;
      }
      
      public static function getLevelBreakIncomeTimePercentage(param1:int) : int
      {
         return smLevelBreakIncomeTimePercentage[param1];
      }
      
      public static function getLevelDCCashLevelUp(param1:int) : int
      {
         return smLevelDCCashLevelUp[param1];
      }
      
      private function sigDestroy() : void
      {
         this.mSigPerFile = null;
      }
      
      private function universeDestroy() : void
      {
         this.mUniverseMapPersistence = null;
      }
      
      public function expansionsGetPlotUnlockOrderCount() : int
      {
         return this.mExpansionsUnlockOrderCount;
      }
      
      private function unlockSegmentsCashLoadOnComplete(param1:Event) : void
      {
         var _loc4_:XML = null;
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.unlockSegmentsCashLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.UNLOCK_SEGMENTS_CASH_XML_FILE,_loc2_.data as String);
         for each(_loc4_ in _loc3_.Definition)
         {
            this.mUnlockSegmentsLevelStart.push(int(_loc4_.@levelStart));
            this.mUnlockSegmentsLevelEnd.push(int(_loc4_.@levelEnd));
            this.mUnlockSegmentsBasePriceFBCredits.push(int(_loc4_.@baseFBC));
            this.mUnlockSegmentsBasePriceGold.push(int(_loc4_.@baseCash));
         }
         this.mUnlockSegmentsLoaded = true;
      }
      
      public function settingsGetInitialDCCoins() : int
      {
         return this.mSettingsInitialDCCoins;
      }
      
      private function unlockSegmentsCashDestroy() : void
      {
         if(this.mUnlockSegmentsLevelStart != null)
         {
            this.mUnlockSegmentsLevelStart.splice(0,this.mUnlockSegmentsLevelStart.length);
            this.mUnlockSegmentsLevelStart = null;
         }
         if(this.mUnlockSegmentsLevelEnd != null)
         {
            this.mUnlockSegmentsLevelEnd.splice(0,this.mUnlockSegmentsLevelEnd.length);
            this.mUnlockSegmentsLevelEnd = null;
         }
         if(this.mUnlockSegmentsBasePriceGold != null)
         {
            this.mUnlockSegmentsBasePriceGold.splice(0,this.mUnlockSegmentsBasePriceGold.length);
            this.mUnlockSegmentsBasePriceGold = null;
         }
         if(this.mUnlockSegmentsBasePriceFBCredits != null)
         {
            this.mUnlockSegmentsBasePriceFBCredits.splice(0,this.mUnlockSegmentsBasePriceFBCredits.length);
            this.mUnlockSegmentsBasePriceFBCredits = null;
         }
      }
      
      private function npcsLoadOnComplete(param1:Event) : void
      {
         var _loc5_:XML = null;
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.npcsLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.NPCS_XML_FILE,_loc2_.data as String);
         var _loc4_:int = 0;
         for each(_loc5_ in _loc3_.Definition)
         {
            this.mNpcsSkus.push(String(_loc5_.@name));
            this.mNpcsCompanyValues.push(Number(_loc5_.@companyValue));
            this.mNpcsUrls.push(_loc5_.@url);
            this.mNpcsXps.push(int(_loc5_.@xp));
         }
         this.mNpcsLoaded = true;
      }
      
      public function settingsGetTimeItemOnSaleMin() : int
      {
         return this.mSettingsTimeItemOnSaleMin;
      }
      
      public function getHireCrewPrice() : int
      {
         return this.mHireCrewPriceFBC;
      }
      
      private function unlockSegmentsGetSegmentId(param1:int) : int
      {
         var _loc2_:int = int(this.mUnlockSegmentsLevelStart.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ && this.mUnlockSegmentsLevelStart[_loc3_] <= param1)
         {
            _loc3_++;
         }
         return _loc3_ - 1;
      }
      
      public function expansionsGetPlotHeight(param1:int) : int
      {
         return this.mExpansionsPlotHeight[param1];
      }
      
      public function settingsGetSellPrice(param1:int) : int
      {
         return param1 * this.mSettingsSellPricePercentage / 100;
      }
      
      public function socialGetUpgradesVisitorExpPerUpgrade(param1:int) : int
      {
         return this.mSocialUpgradesVisitorExpPerUpgrade[param1];
      }
      
      public function getItemDefinitions() : void
      {
         var _loc1_:* = int(this.mGetInfoFromXMLActions.length - 1);
         while(_loc1_ > -1)
         {
            this.mGetInfoFromXMLActions[_loc1_].doAction();
            _loc1_--;
         }
      }
      
      public function npcsGetSku(param1:int) : String
      {
         return this.mNpcsSkus[param1];
      }
      
      public function settingsGetContractSignatorAreaX() : int
      {
         return this.mSettingsContractSignatorAreaX;
      }
      
      public function settingsGetContractSignatorAreaY() : int
      {
         return this.mSettingsContractSignatorAreaY;
      }
      
      public function newToolRev() : int
      {
         return smNewToolRev;
      }
      
      public function shopNewItemTimer() : int
      {
         return smShopNewItemTimer;
      }
      
      public function askForHelpAccelerateItemPercent() : int
      {
         return this.mAskForHelpAccelerateItemPercent;
      }
      
      public function npcsGetXp(param1:int) : int
      {
         return this.mNpcsXps[param1];
      }
      
      private function levelLoadOnComplete(param1:Event) : void
      {
         var _loc4_:XML = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.levelLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.XPTABLE_XML_FILE,_loc2_.data as String);
         for each(_loc4_ in _loc3_.level)
         {
            smLevelXPTable.push(Number(_loc4_.@xpneed));
            smLevelFBCreditToCoins.push(int(_loc4_.@exchangeFBC));
            smLevelTerrainPriceTable.push(int(_loc4_.@terrainPrice));
            _loc5_ = Number(_loc4_.@timePrice);
            mTimePrice = _loc5_;
            smLevelTimePriceTable.push(_loc5_);
            smLevelRepairPricePercentage.push(int(_loc4_.@repairPricePercentage));
            smLevelBreakIncomeTimePercentage.push(int(_loc4_.@breakIncomeTimePercentage));
            _loc6_ = Number(_loc4_.@breakIncomeTimeMin);
            smLevelBreakIncomeTimeMin.push(TimerUtil.hourToMs(_loc6_));
            smLevelBreakMaxItemsPercentage.push(int(_loc4_.@breakMaxItemsPercentage));
            _loc7_ = int(_loc4_.@repairTimeDice);
            smLevelRepairTimeDice.push(TimerUtil.secondToMs(_loc7_));
            smLevelDCCashLevelUp.push(_loc4_.@DCCashLevelUp);
         }
         smMaxLevels = smLevelXPTable.length;
         this.mLevelLoaded = true;
      }
      
      private function expansionsPricesLoadOnComplete(param1:Event) : void
      {
         var _loc8_:XML = null;
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.expansionsPricesLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.EXPANSIONS_PRICES_XML_FILE,_loc2_.data as String);
         var _loc4_:int = 0;
         var _loc5_:Number = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         for each(_loc8_ in _loc3_.Definition)
         {
            _loc4_ = int(_loc8_.@DCCash);
            _loc5_ = Number(_loc8_.@DCCoins);
            _loc7_ = int(_loc8_.@InversorsSuccessful);
            if("@FBC" in _loc8_)
            {
               _loc6_ = int(_loc8_.@FBC);
            }
            this.mExpansionsDCCash.push(_loc4_);
            this.mExpansionsDCCoins.push(_loc5_);
            this.mExpansionsFriendsNeeded.push(_loc7_);
            this.mExpansionsFBCredits.push(_loc6_);
         }
         this.mExpansionsPricesLoaded = true;
      }
      
      public function expansionsGetPlotWidth(param1:int) : int
      {
         return this.mExpansionsPlotWidth[param1];
      }
      
      private function expansionsLoadOnComplete(param1:Event) : void
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         this.mArrayExpansions = new Array();
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.expansionsLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.EXPANSIONS_XML_FILE,_loc2_.data as String);
         this.mExpansionsUnlockOrderCount = 0;
         var _loc4_:int = 0;
         for each(_loc5_ in _loc3_.Definition)
         {
            _loc6_ = _loc5_.@unlockedOrder;
            _loc7_ = parseInt(_loc6_);
            if(this.mExpansionsPlotIndicesByUnlockOrder[_loc7_] == null)
            {
               this.mExpansionsPlotIndicesByUnlockOrder[_loc7_] = new Array();
               ++this.mExpansionsUnlockOrderCount;
            }
            this.mExpansionsPlotIndicesByUnlockOrder[_loc6_].push(_loc4_);
            this.mExpansionsPlotUnlockOrder[_loc4_] = _loc6_;
            _loc8_ = String(_loc5_.@Composition);
            _loc9_ = _loc8_.split(",");
            _loc10_ = new Array();
            this.mArrayExpansions.push(_loc9_.length);
            for each(_loc11_ in _loc9_)
            {
               _loc11_ = TextManager.trim(_loc11_);
               _loc12_ = parseInt(_loc11_);
               this.mExpansionsMiniToPlot[_loc12_] = _loc4_;
               _loc10_.push(_loc12_);
            }
            this.mExpansionsPlotMinis.push(_loc10_);
            _loc4_++;
         }
         this.mExpansionsLoaded = true;
      }
      
      public function socialGetUpgradesVisitorDCCoinsPerUpgrade(param1:int) : int
      {
         return this.mSocialUpgradesVisitorDCCoinsPerUpgrade[param1];
      }
      
      private function universeMapLoadOnComplete(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.universeMapLoadOnComplete);
         this.mUniverseMapPersistence = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.RULES_UNIVERSE_MAP_XML_FILE,_loc2_.data as String);
      }
      
      public function get crmPopupTimer() : int
      {
         return this.mSettingsCrmPopupTimer;
      }
      
      public function socialGetUpgradesAvailablePerVisitor() : int
      {
         return this.mSocialUpgradesAvailablePerVisitor;
      }
      
      public function settingsGetTimeToPutItemOnSaleMax() : int
      {
         return this.mSettingsTimeToPutItemOnSaleMax;
      }
      
      public function npcsGetId(param1:String) : int
      {
         return this.mNpcsSkus.indexOf(param1);
      }
      
      public function newItemsRev() : int
      {
         return smNewItemsRev;
      }
      
      private function levelLoad() : void
      {
         var request:URLRequest;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.levelLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.XPTABLE_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.XPTABLE_XML_FILE + " document.");
         }
      }
      
      public function npcsGetUrl(param1:int) : String
      {
         return Config.getRoot() + ModelConfig.DIR_NPCS + this.mNpcsUrls[param1];
      }
      
      public function settingsGetMoneyCollectorAreaY() : int
      {
         return this.mSettingsMoneyCollectorAreaY;
      }
      
      private function unlockSegmentsVisibilityLoadOnComplete(param1:Event) : void
      {
         var _loc4_:XML = null;
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.unlockSegmentsVisibilityLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.UNLOCK_SEGMENTS_VISIBILITY_XML_FILE,_loc2_.data as String);
         for each(_loc4_ in _loc3_.Definition)
         {
            this.mUnlockSegmentsVisibilityLevelStart.push(int(_loc4_.@levelStart));
            this.mUnlockSegmentsVisibilityLevelEnd.push(int(_loc4_.@levelEnd));
            this.mUnlockSegmentsVisibilityLevelsCount.push(int(_loc4_.@levelsVisible));
         }
         this.mUnlockSegmentsVisibilityLoaded = true;
      }
      
      public function getArrayExpansions() : Array
      {
         return this.mArrayExpansions;
      }
      
      public function sigRegister(param1:String, param2:String) : void
      {
         this.mSigPerFile[param1] = param2;
      }
      
      public function settingsGetIncomeMultiplier() : int
      {
         return this.mSettingsIncomeMultiplier;
      }
      
      private function expansionsLoad() : void
      {
         var loaderExpansionsPrices:URLLoader;
         var loaderExpansions:URLLoader;
         var loaderContext:LoaderContext;
         var request:URLRequest;
         this.mExpansionsDCCash = new Array();
         this.mExpansionsDCCoins = new Array();
         this.mExpansionsFriendsNeeded = new Array();
         this.mExpansionsFBCredits = new Array();
         this.mExpansionsPlotMinis = new Array();
         this.mExpansionsMiniToPlot = new Dictionary(true);
         this.mExpansionsPlotX = new Array();
         this.mExpansionsPlotY = new Array();
         this.mExpansionsPlotWidth = new Array();
         this.mExpansionsPlotHeight = new Array();
         this.mExpansionsPlotIndicesByUnlockOrder = new Dictionary(true);
         this.mExpansionsPlotUnlockOrder = new Dictionary(true);
         this.mExpansionsPlotConsecutiveSameUnlockOrder = new Array();
         loaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         loaderExpansions = new URLLoader();
         loaderExpansions.addEventListener(Event.COMPLETE,this.expansionsLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.EXPANSIONS_XML_FILE);
         try
         {
            request = new URLRequest(Config.getRoot() + ModelConfig.EXPANSIONS_XML_FILE);
            loaderExpansions.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.EXPANSIONS_XML_FILE + " document.");
         }
         loaderExpansionsPrices = new URLLoader();
         loaderExpansionsPrices.addEventListener(Event.COMPLETE,this.expansionsPricesLoadOnComplete);
         try
         {
            request = new URLRequest(Config.getRoot() + ModelConfig.EXPANSIONS_PRICES_XML_FILE);
            loaderExpansionsPrices.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.EXPANSIONS_PRICES_XML_FILE + " document.");
         }
      }
      
      public function settingsGetInvestmentsUnlockLevel() : int
      {
         return this.mSettingsInvestmentsUnlockLevel;
      }
      
      public function settingsGetAbandonTime(param1:int) : int
      {
         var _loc2_:int = param1 * this.mSettingsAbandonTimePercentage / 100;
         return Math.max(_loc2_,this.mSettingsAbandonMinTime);
      }
      
      public function expansionsGetConsecutivePlotsWithSameUnlockOrder() : Array
      {
         return this.mExpansionsPlotConsecutiveSameUnlockOrder;
      }
      
      public function sigCalculateTotal() : void
      {
         var _loc2_:String = null;
         var _loc1_:String = "";
         for each(_loc2_ in SIG_KEYS_ORDER)
         {
            _loc1_ += this.mSigPerFile[_loc2_];
         }
         this.mSigTotal = Utils.getChk(_loc1_);
      }
      
      public function settingsGetSettingsSideTabsUnlockLevel() : int
      {
         return this.mSettingsSideTabsUnlockLevel;
      }
      
      public function settingsGetMoneyCollectorAreaX() : int
      {
         return this.mSettingsMoneyCollectorAreaX;
      }
      
      public function expansionsGetConsecutivePlotsWithSameUnlockOrderCount() : int
      {
         return this.mExpansionsPlotConsecutiveSameUnlockOrder.length;
      }
      
      public function settingsGetUnlockMaxPrice(param1:Boolean = true) : int
      {
         if(param1)
         {
            return this.mSettingsUnlockMaxPriceFBCredits;
         }
         return this.mSettingsUnlockMaxPrice;
      }
      
      public function unlockSegmentsGetPrice(param1:int, param2:int, param3:Boolean = true, param4:Boolean = false) : int
      {
         var _loc8_:int = 0;
         if(this.mUnlockSegmentsMode == UNLOCK_SEGMENTS_MODE_UNALLOWED)
         {
            return 0;
         }
         var _loc5_:int = this.unlockSegmentsGetSegmentId(param1);
         var _loc6_:int = int(this.mUnlockSegmentsBasePriceGold[_loc5_]);
         if(param3)
         {
            _loc6_ = int(this.mUnlockSegmentsBasePriceFBCredits[_loc5_]);
         }
         var _loc7_:int = param4 ? _loc6_ : 0;
         if(param2 > param1 && (!this.mUnlockSegmentsCheckVisibility || param2 - param1 <= this.mUnlockSegmentsVisibilityLevelsCount[this.unlockSegmentsVisibilityGetSegmentId(param1)]))
         {
            _loc8_ = this.unlockSegmentsGetSegmentId(param2);
            if(param3)
            {
               _loc6_ = int(this.mUnlockSegmentsBasePriceFBCredits[_loc8_]);
            }
            else
            {
               _loc6_ = int(this.mUnlockSegmentsBasePriceGold[_loc8_]);
            }
            _loc7_ = _loc6_ + this.unlockSegmentsGetPrice(param1,param2 - 1,param3,true);
         }
         return _loc7_;
      }
      
      private function settingsLoadOnComplete(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.settingsLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.SETTINGS_XML_FILE,_loc2_.data as String);
         if(Config.DEBUG_MODE)
         {
            trace(_loc2_.data as String);
         }
         smDCCashToDCCoins = int(_loc3_.Definition.@cashToCoins);
         smFBCreditsToDCCoins = int(_loc3_.Definition.@FBCToCoins);
         this.mSettingsDestroyItemProfitPercentage = int(_loc3_.Definition.@destroyItemProfitPercentage);
         this.mSettingsDestroyTerrainProfitPercentage = int(_loc3_.Definition.@destroyTerrainProfitPercentage);
         mShowHelpPopupTimer = int(_loc3_.Definition.@popupHelpTimer);
         smPopupHelpTimerThreshold = int(_loc3_.Definition.@popupHelpTimerThreshold);
         mRenovatePriceOffPercentage = int(_loc3_.Definition.@renovatePriceOffPercentage);
         this.mSettingsCompanyValueBreakPercentage = int(_loc3_.Definition.@companyValueBreakPercentage);
         this.mSettingsInitialDCCoins = int(_loc3_.Definition.@initialDCCoins);
         this.mSettingsInitialDCCash = int(_loc3_.Definition.@initialDCCash);
         this.mSettingsIncomeMultiplier = int(_loc3_.Definition.@incomeMultiplier);
         var _loc4_:Number = Number(_loc3_.Definition.@helpConstructionMinTime);
         this.mSettingsHelpConstructionMinTime = TimerUtil.minToMs(_loc4_);
         this.mSettingsManagersPricePercentage = int(_loc3_.Definition.@managersPricePercentage);
         this.mSettingsTimeToPutItemOnSaleMin = int(_loc3_.Definition.@timeToPutItemOnSaleMin);
         this.mSettingsTimeToPutItemOnSaleMax = int(_loc3_.Definition.@timeToPutItemOnSaleMax);
         this.mSettingsTimeItemOnSaleMin = int(_loc3_.Definition.@timeItemOnSaleMin);
         this.mSettingsTimeItemOnSaleMax = int(_loc3_.Definition.@timeItemOnSaleMax);
         this.mSettingsSellPricePercentage = int(_loc3_.Definition.@sellPricePercentage);
         this.mSettingsAbandonMinTime = int(TimerUtil.minToMs(_loc3_.Definition.@abandonMinTime));
         this.mSettingsAbandonTimePercentage = int(_loc3_.Definition.@abandonTimePercentage);
         this.mSettingsCancelContractProfitPercentage = int(_loc3_.Definition.@cancelContractProfitPercentage);
         mDailyBonus = int(_loc3_.Definition.@dailyBonus);
         mDailyBonusTimeInit = TimerUtil.hourToMs(int(_loc3_.Definition.@dailyBonusMinTime));
         smNewItemsRev = int(_loc3_.Definition.@newItemsRev);
         smNewToolRev = int(_loc3_.Definition.@newToolRev);
         smShopNewItemTimer = int(_loc3_.Definition.@shopNewItemsTimer);
         this.mSettingsMoneyCollectorAreaX = int(_loc3_.Definition.@moneyCollectorAreaX);
         this.mSettingsMoneyCollectorAreaY = int(_loc3_.Definition.@moneyCollectorAreaY);
         this.mSettingsContractSignatorAreaX = int(_loc3_.Definition.@contractSignatorAreaX);
         this.mSettingsContractSignatorAreaY = int(_loc3_.Definition.@contractSignatorAreaY);
         this.mSettingsCrmPopupTimer = int(_loc3_.Definition.@crmPopupTimer);
         this.mSettingsLimEdSoldOutShowTime = TimerUtil.hourToMs(int(_loc3_.Definition.@limEdSoldOutShowTime));
         this.mSettingsCollectibleMaxUnitsPerItem = int(_loc3_.Definition.@collectibleMaxUnitsPerItem);
         this.mSettingsCollectiblesUnlockLevel = int(_loc3_.Definition.@collectibleUnlockLevel);
         this.mSettingsInvestmentsUnlockLevel = int(_loc3_.Definition.@investmentsUnlockLevel);
         this.mSettingsSideTabsUnlockLevel = int(_loc3_.Definition.@sideTabsUnlockLevel);
         this.settingsSetUnlockMaxPrice(int(_loc3_.Definition.@unlockMaxPrice),false);
         this.settingsSetUnlockMaxPrice(int(_loc3_.Definition.@unlockMaxPriceFBC),true);
         this.mHireCrewPriceFBC = int(_loc3_.Definition.@hireCrewPriceFBC);
         this.mSettingsLoaded = true;
      }
      
      private function socialLoadOnComplete(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.socialLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         this.sigRegister(Config.getRoot() + ModelConfig.SOCIAL_XML_FILE,_loc2_.data as String);
         this.mSocialUpgradesAvailablePerVisitor = int(_loc3_.Definition.@upgradesAvailablePerVisitor);
         this.mSocialUpgradesVisitorExpPerUpgrade[UpgradesManager.UPGRADE_TYPE_NORMAL] = int(_loc3_.Definition.@upgradesVisitorExpPerUpgrade);
         this.mSocialUpgradesVisitorDCCoinsPerUpgrade[UpgradesManager.UPGRADE_TYPE_NORMAL] = int(_loc3_.Definition.@upgradesVisitorDCCoinsPerUpgrade);
         this.mSocialUpgradesVisitorExpPerUpgrade[UpgradesManager.UPGRADE_TYPE_SUPER] = int(_loc3_.Definition.@superUpgradesVisitorExpPerUpgrade);
         this.mSocialUpgradesVisitorDCCoinsPerUpgrade[UpgradesManager.UPGRADE_TYPE_SUPER] = int(_loc3_.Definition.@superUpgradesVisitorDCCoinsPerUpgrade);
         this.mSocialUpgradesOwnerExtraPercentage[UpgradesManager.UPGRADE_TYPE_NORMAL] = int(_loc3_.Definition.@upgradesOwnerExtraPercentage);
         this.mSocialUpgradesOwnerExtraPercentage[UpgradesManager.UPGRADE_TYPE_SUPER] = int(_loc3_.Definition.@superUpgradesOwnerExtraPercentage);
         this.mSocialSuperUpgradesTimeToAllowReminding = TimerUtil.hourToMs(Number(_loc3_.Definition.@superUpgradesTimeToAllowReminding));
         this.mSocialInvestAskForSpeedTime = TimerUtil.hourToMs(int(_loc3_.Definition.@invest_askForSpeedPost_time));
         this.mSocialInvestRemindTime = TimerUtil.hourToMs(int(_loc3_.Definition.@invest_remindPost_time));
         this.mAskForHelpAccelerateItemPercent = int(_loc3_.Definition.@askForHelp_accelerateItem_percent);
         this.mSocialLoaded = true;
      }
      
      public function settingsSetUnlockMaxPrice(param1:int, param2:Boolean = true) : void
      {
         if(param2)
         {
            this.mSettingsUnlockMaxPriceFBCredits = param1;
         }
         else
         {
            this.mSettingsUnlockMaxPrice = param1;
         }
      }
      
      private function universeLoad() : void
      {
         var request:URLRequest;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.universeMapLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.RULES_UNIVERSE_MAP_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.RULES_UNIVERSE_MAP_XML_FILE + " document.");
         }
      }
      
      public function settingsGetDestroyTerrainProfit(param1:int) : int
      {
         return param1 * this.mSettingsDestroyTerrainProfitPercentage / 100;
      }
      
      public function socialInvestRemindTime() : int
      {
         return this.mSocialInvestRemindTime;
      }
      
      public function settingsLimEdSoldOutShowTime() : Number
      {
         return this.mSettingsLimEdSoldOutShowTime;
      }
      
      public function universeGetMapPersistence() : XML
      {
         return this.mUniverseMapPersistence;
      }
      
      public function settingsGetCancelContractProfitPercentage() : int
      {
         return this.mSettingsCancelContractProfitPercentage;
      }
      
      public function settingsGetDestroyItemProfit(param1:ItemObject) : int
      {
         var _loc2_:int = int(param1.value);
         return int(_loc2_ * this.mSettingsDestroyItemProfitPercentage / 100);
      }
      
      public function load() : void
      {
         this.mGetInfoFromXMLActions = new Array();
         this.mGetInfoFromXMLActions.push(new ActionGetCrewMechanicsDefinitions());
         this.mGetInfoFromXMLActions.push(new ActionGetFreeGiftDefinition(Config.getRoot() + ModelConfig.FREE_GIFTS_DEFINITIONS_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetFreeGiftSequenceDefinition());
         this.mGetInfoFromXMLActions.push(new ActionGetBoxPrizeDefinition());
         this.mGetInfoFromXMLActions.push(new ActionGetOfferDefinition(Config.getRoot() + ModelConfig.OFFERS_DEFINITIONS_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetItemDefinitions(Config.getRoot() + ModelConfig.ITEM_DEFINITIONS_XML_FILE,TextIDs.TID_BUILDING_HQ,ItemDefinition.TYPE_HOUSES_ID));
         this.mGetInfoFromXMLActions.push(new ActionGetItemDefinitions(Config.getRoot() + ModelConfig.COMMERCE_DEFINITIONS_XML_FILE,TextIDs.TID_BUILDING_COMMERCE_01,ItemDefinition.TYPE_COMMERCES_ID));
         this.mGetInfoFromXMLActions.push(new ActionGetItemDefinitions(Config.getRoot() + ModelConfig.DECORATION_DEFINITIONS_XML_FILE,TextIDs.TID_BUILDING_DECORATION_01,ItemDefinition.TYPE_DECORATIONS_ID));
         this.mGetInfoFromXMLActions.push(new ActionGetItemDefinitions(Config.getRoot() + ModelConfig.WONDER_DEFINITIONS_XML_FILE,TextIDs.TID_BUILDING_WONDER_01,ItemDefinition.TYPE_WONDERS_ID));
         this.mGetInfoFromXMLActions.push(new ActionGetItemDefinitions(Config.getRoot() + ModelConfig.CLUB_DEFINITIONS_XML_FILE,TextIDs.TID_BUILDING_WONDER_01,ItemDefinition.TYPE_CLUBS_ID));
         this.mGetInfoFromXMLActions.push(new ActionGetItemDecorationDefinitions(Config.getRoot() + ModelConfig.HQ_DECORATION_FLAG_DEFINITIONS_XML_FILE,-1,ItemDecorationDefinition.TYPE_FLAGS_ID));
         this.mGetInfoFromXMLActions.push(new ActionGetItemDecorationDefinitions(Config.getRoot() + ModelConfig.HQ_DECORATION_SKIN_DEFINITIONS_XML_FILE,-1,ItemDecorationDefinition.TYPE_SKINS_ID));
         this.mGetInfoFromXMLActions.push(new ActionGetCommerceTypeDefinitions(Config.getRoot() + ModelConfig.COMMERCE_TYPE_DEFINITIONS_XML_FILE,TextIDs.TID_COMMERCE_TYPE_BANK_INFO_INCOME,0));
         this.mGetInfoFromXMLActions.push(new ActionGetWonderTypeDefinitions(Config.getRoot() + ModelConfig.WONDER_TYPE_DEFINITIONS_XML_FILE,TextIDs.TID_WONDER_TYPE_NPC_INCOME_INFO,0));
         this.mGetInfoFromXMLActions.push(new ActionGetMissionDefinitions(Config.getRoot() + ModelConfig.MISSION_DEFINITIONS_XML_FILE,TextIDs.TID_MISSION_001_TITLE));
         this.mGetInfoFromXMLActions.push(new ActionGetMapDefinition());
         this.mGetInfoFromXMLActions.push(new ActionGetAcceleratorDefinitions(Config.getRoot() + ModelConfig.ACCELERATOR_DEFINITIONS_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetGUIShopTabDefinitions(Config.getRoot() + ModelConfig.GUI_SHOP_TAB_DEFINITIONS_XML_FILE,TextIDs.TID_BUTTON_HOUSES));
         this.mGetInfoFromXMLActions.push(new ActionGetTrafficAgentDefinitions(Config.getRoot() + ModelConfig.TRAFFIC_AGENT_DEFINITIONS_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetTrafficAgentManagerDefinition(Config.getRoot() + ModelConfig.TRAFFIC_AGENT_MANAGER_DEFINITION_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetInvestDefinitions(Config.getRoot() + ModelConfig.INVEST_DEFINITIONS_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetContractDefinitions(Config.getRoot() + ModelConfig.CONTRACT_DEFINITIONS_XML_FILE,TextIDs.TID_CONTRACT1));
         this.mGetInfoFromXMLActions.push(new ActionGetContractNameDefinitions(Config.getRoot() + ModelConfig.CONTRACT_NAME_DEFINITIONS_XML_FILE,TextIDs.TID_CONTRACT1));
         this.mGetInfoFromXMLActions.push(new ActionGetContractsTypesDefinitions(Config.getRoot() + ModelConfig.CONTRACTS_TYPE_DEFINITIONS_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetServiceDefinitions(Config.getRoot() + ModelConfig.SERVICE_DEFINITIONS_XML_FILE));
         this.mGetInfoFromXMLActions.push(new ActionGetNewsFeedDefinitions(Config.getRoot() + ModelConfig.NEWS_FEED_DEFINITIONS_XML_FILE,TextIDs.TID_NEWSFEED_REWARD_PRE_POPUP_LEVEL_UP));
         this.mGetInfoFromXMLActions.push(new ActionGetRewardTypeDefinitions(Config.getRoot() + ModelConfig.REWARD_TYPE_DEFINITIONS_XML_FILE,TextIDs.TID_NEWSFEED_REWARD_EXP));
         if(Config.COLLECTIBLE_FEATURE_ENABLED)
         {
            this.mGetInfoFromXMLActions.push(new ActionGetCollectibleDefinition(Config.getRoot() + ModelConfig.COLLECTIBLE_DEFINITIONS_XML_FILE,TextIDs.TID_COLLECTIBLES_GIFT_001));
            this.mGetInfoFromXMLActions.push(new ActionGetCollectibleGroupDefinition(Config.getRoot() + ModelConfig.COLLECTIBLE_GROUPS_XML_FILE,TextIDs.TID_COLLECTIBLES_COLLECTION_NAME_001));
            this.mGetInfoFromXMLActions.push(new ActionGetCollectibleRewardDefinitions(Config.getRoot() + ModelConfig.COLLECTIBLE_REWARDS_DEFINITIONS_XML_FILE,TextIDs.TID_COLLECTIBLES_REWARD_001));
         }
         if(Config.DAILY_BONUS_FEATURE_ENABLED)
         {
            this.mGetInfoFromXMLActions.push(new ActionGetDailyBonusDefinitions(Config.getRoot() + ModelConfig.DAILY_BONUS_XML_FILE));
         }
         this.mGetInfoFromXMLActions.push(new ActionGetCrosspromotionDefinitions(Config.getRoot() + ModelConfig.CROSSPROMOTION_DEFINITIONS_XML_FILE,TextIDs.TID_UNLOCK_GYM_TITLE));
         smLevelXPTable = new Array();
         smLevelFBCreditToCoins = new Array();
         smLevelTerrainPriceTable = new Array();
         smLevelTimePriceTable = new Array();
         smLevelRepairPricePercentage = new Array();
         smLevelBreakIncomeTimePercentage = new Array();
         smLevelBreakIncomeTimeMin = new Array();
         smLevelBreakMaxItemsPercentage = new Array();
         smLevelRepairTimeDice = new Array();
         smLevelDCCashLevelUp = new Array();
         this.levelLoad();
         this.settingsLoad();
         this.expansionsLoad();
         this.socialLoad();
         this.npcsLoad();
         this.universeLoad();
         this.unlockSegmentsVisibilityLoad();
         this.unlockSegmentsCashLoad();
         this.sigLoad();
      }
      
      public function expansionsGetPlotIndicesByUnlockOrder(param1:int) : Array
      {
         return this.mExpansionsPlotIndicesByUnlockOrder[param1] as Array;
      }
      
      private function unlockSegmentsIsLoaded() : Boolean
      {
         return this.mUnlockSegmentsLoaded;
      }
      
      public function settingsGetCollectiblesUnlockLevel() : int
      {
         return this.mSettingsCollectiblesUnlockLevel;
      }
      
      public function settingsGetInvestCompanyValue() : int
      {
         return this.settingsGetInitialDCCoins() + this.settingsGetInitialDCCash() * getDCCashToDCCoins();
      }
      
      private function unlockSegmentsVisibilityIsLoaded() : Boolean
      {
         return this.mUnlockSegmentsVisibilityLoaded;
      }
      
      public function npcsGetCount() : int
      {
         return this.mNpcsCompanyValues.length;
      }
      
      public function expansionsAreConsecutivePlotsWithSameUnlockOrder(param1:int, param2:int) : Boolean
      {
         var _loc3_:String = this.expansionsGetKeyFromConsecutivePlots(param1,param2);
         var _loc4_:int = this.mExpansionsPlotConsecutiveSameUnlockOrder.indexOf(_loc3_);
         return _loc4_ > -1;
      }
      
      public function dailyBonusTimeInit() : int
      {
         return mDailyBonusTimeInit;
      }
      
      public function settingsGetTimeItemOnSaleMax() : int
      {
         return this.mSettingsTimeItemOnSaleMax;
      }
      
      public function settingsGetInitialDCCash() : int
      {
         return this.mSettingsInitialDCCash;
      }
      
      private function unlockSegmentsVisibilityLoad() : void
      {
         var request:URLRequest;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.unlockSegmentsVisibilityLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.UNLOCK_SEGMENTS_VISIBILITY_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.UNLOCK_SEGMENTS_VISIBILITY_XML_FILE + " document.");
         }
         this.mUnlockSegmentsVisibilityLevelStart = new Array();
         this.mUnlockSegmentsVisibilityLevelEnd = new Array();
         this.mUnlockSegmentsVisibilityLevelsCount = new Array();
      }
      
      public function expansionsGetPlotsCount() : int
      {
         return this.mExpansionsPlotX.length;
      }
      
      public function npcsGetShortName(param1:int) : String
      {
         return TextManager.getText(TextIDs.TID_RONALD_NAME_SHORT + param1);
      }
      
      public function settingsGetCompanyValueBreakPercentage() : int
      {
         return this.mSettingsCompanyValueBreakPercentage;
      }
      
      public function socialGetUpgradesOwnerExtraPercentage(param1:int) : int
      {
         return this.mSocialUpgradesOwnerExtraPercentage[param1];
      }
      
      public function settingsGetCollectibleMaxUnitsPerItem() : int
      {
         return this.mSettingsCollectibleMaxUnitsPerItem;
      }
      
      private function sigLoad() : void
      {
         this.mSigPerFile = new Dictionary(true);
      }
      
      public function npcsIsMyAdvisor(param1:int, param2:int) : Boolean
      {
         return this.npcsIsAdvisor(param1) && param2 == param1 - this.NPCS_ADVISOR_USER_ID;
      }
      
      public function settingsGetTimeToPutItemOnSaleMin() : int
      {
         return this.mSettingsTimeToPutItemOnSaleMin;
      }
      
      public function npcsGetCompanyValue(param1:int) : Number
      {
         return this.mNpcsCompanyValues[param1];
      }
      
      public function expansionsGetDCCoins(param1:int) : Number
      {
         return this.mExpansionsDCCoins[param1];
      }
      
      public function expansionsGetPlotUnlockOrder(param1:int) : int
      {
         return this.mExpansionsPlotUnlockOrder[param1];
      }
      
      public function expansionsGetFBCredits(param1:int) : Number
      {
         return this.mExpansionsFBCredits[param1];
      }
      
      private function universeIsLoaded() : Boolean
      {
         return this.mUniverseMapPersistence != null;
      }
      
      public function expansionsGetKeyFromConsecutivePlots(param1:int, param2:int) : String
      {
         return param1 + "_" + param2;
      }
      
      public function settingsGetHelpConstructionMinTime() : int
      {
         return this.mSettingsHelpConstructionMinTime;
      }
      
      public function sigGetTotal() : int
      {
         return this.mSigTotal;
      }
      
      public function settingsGetTimeItemOnSale() : int
      {
         return this.mSettingsTimeToPutItemOnSaleMin + Math.random() * (this.mSettingsTimeToPutItemOnSaleMax - this.mSettingsTimeToPutItemOnSaleMin);
      }
      
      public function unlockSegmentsSetMode(param1:int) : void
      {
         this.mUnlockSegmentsMode = param1;
         switch(this.mUnlockSegmentsMode)
         {
            case UNLOCK_SEGMENTS_MODE_LIMITED:
               this.mUnlockSegmentsCheckVisibility = true;
               break;
            case UNLOCK_SEGMENTS_MODE_UNLIMITED:
               this.mUnlockSegmentsCheckVisibility = false;
         }
      }
      
      private function expansionsIsLoaded() : Boolean
      {
         return this.mExpansionsLoaded && this.mExpansionsPricesLoaded;
      }
      
      public function areRivalCompanySalesTemporal() : Boolean
      {
         return false;
      }
      
      public function npcsGetLongName(param1:int) : String
      {
         return TextManager.getText(TextIDs.TID_RONALD_NAME + param1);
      }
      
      private function expansionsBuild() : void
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc1_:MapDefinition = MapDefinition.getInstance();
         var _loc2_:int = _loc1_.getMapAreaCols();
         var _loc3_:int = _loc1_.getAreaWidth();
         var _loc4_:int = _loc1_.getAreaHeight();
         for each(_loc5_ in this.mExpansionsPlotMinis)
         {
            _loc13_ = int.MAX_VALUE;
            _loc14_ = int.MAX_VALUE;
            _loc15_ = int.MIN_VALUE;
            _loc16_ = int.MIN_VALUE;
            for each(_loc17_ in _loc5_)
            {
               _loc18_ = _loc17_ % _loc2_;
               _loc19_ = _loc17_ / _loc2_;
               if(_loc18_ < _loc13_)
               {
                  _loc13_ = _loc18_;
               }
               if(_loc18_ > _loc15_)
               {
                  _loc15_ = _loc18_;
               }
               if(_loc19_ < _loc14_)
               {
                  _loc14_ = _loc19_;
               }
               if(_loc19_ > _loc16_)
               {
                  _loc16_ = _loc19_;
               }
            }
            this.mExpansionsPlotX.push(_loc13_ * _loc3_);
            this.mExpansionsPlotWidth.push((_loc15_ - _loc13_ + 1) * _loc3_);
            this.mExpansionsPlotY.push(_loc14_ * _loc4_);
            this.mExpansionsPlotHeight.push((_loc16_ - _loc14_ + 1) * _loc4_);
         }
         _loc6_ = _loc1_.getExpansionsSide();
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            _loc9_ = _loc7_ * _loc6_;
            _loc8_ = 0;
            while(_loc8_ < _loc6_ - 1)
            {
               _loc10_ = _loc9_ + _loc8_;
               _loc11_ = _loc10_ + 1;
               if(this.mExpansionsPlotUnlockOrder[_loc10_] == this.mExpansionsPlotUnlockOrder[_loc11_])
               {
                  _loc12_ = this.expansionsGetKeyFromConsecutivePlots(_loc10_,_loc11_);
                  this.mExpansionsPlotConsecutiveSameUnlockOrder.push(_loc12_);
               }
               _loc8_++;
            }
            _loc7_++;
         }
         _loc8_ = 0;
         while(_loc8_ < _loc6_)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc6_ - 1)
            {
               _loc9_ = _loc7_ * _loc6_;
               _loc10_ = _loc9_ + _loc8_;
               _loc11_ = (_loc7_ + 1) * _loc6_ + _loc8_;
               if(this.mExpansionsPlotUnlockOrder[_loc10_] == this.mExpansionsPlotUnlockOrder[_loc11_])
               {
                  _loc12_ = this.expansionsGetKeyFromConsecutivePlots(_loc10_,_loc11_);
                  this.mExpansionsPlotConsecutiveSameUnlockOrder.push(_loc12_);
               }
               _loc7_++;
            }
            _loc8_++;
         }
      }
      
      private function unlockSegmentsVisibilityGetSegmentId(param1:int) : int
      {
         var _loc2_:int = int(this.mUnlockSegmentsVisibilityLevelStart.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ && this.mUnlockSegmentsVisibilityLevelStart[_loc3_] <= param1)
         {
            _loc3_++;
         }
         return _loc3_ - 1;
      }
      
      public function expansionsGetPlotY(param1:int) : int
      {
         return this.mExpansionsPlotY[param1];
      }
      
      public function expansionsGetPlotX(param1:int) : int
      {
         return this.mExpansionsPlotX[param1];
      }
      
      public function dailyBonusValue() : int
      {
         return mDailyBonus;
      }
      
      public function npcsIsAdvisor(param1:int) : Boolean
      {
         return param1 - this.NPCS_ADVISOR_USER_ID < Profile.BOSS_COUNT;
      }
      
      public function socialGetSuperUpgradesTimeToAllowReminding() : Number
      {
         return this.mSocialSuperUpgradesTimeToAllowReminding;
      }
      
      public function expansionsGetFriendsNeeded(param1:int) : int
      {
         return this.mExpansionsFriendsNeeded[param1];
      }
      
      private function settingsLoad() : void
      {
         var request:URLRequest;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.settingsLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.SETTINGS_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.SETTINGS_XML_FILE + " document.");
         }
      }
      
      private function npcsLoad() : void
      {
         var loader:URLLoader;
         var loaderContext:LoaderContext;
         var request:URLRequest;
         this.mNpcsSkus = new Array();
         this.mNpcsCompanyValues = new Array();
         this.mNpcsUrls = new Array();
         this.mNpcsXps = new Array();
         loaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         loader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.npcsLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.NPCS_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.NPCS_XML_FILE + " document.");
         }
      }
      
      public function settingsGetTimeToPutItemOnSale() : int
      {
         return this.mSettingsTimeToPutItemOnSaleMin + Math.random() * (this.mSettingsTimeToPutItemOnSaleMax - this.mSettingsTimeToPutItemOnSaleMin);
      }
      
      private function expansionsDestroy() : void
      {
         this.mExpansionsDCCash = null;
         this.mExpansionsDCCoins = null;
         this.mExpansionsFriendsNeeded = null;
         this.mExpansionsFBCredits = null;
         this.mExpansionsPlotMinis = null;
         this.mExpansionsMiniToPlot = null;
         this.mExpansionsPlotX = null;
         this.mExpansionsPlotY = null;
         this.mExpansionsPlotWidth = null;
         this.mExpansionsPlotHeight = null;
         this.mExpansionsPlotIndicesByUnlockOrder = null;
         this.mExpansionsPlotUnlockOrder = null;
         this.mExpansionsPlotConsecutiveSameUnlockOrder = null;
      }
      
      public function expansionsGetDCCoinsWithFriends(param1:int) : Number
      {
         return this.mExpansionsDCCash[param1] * smDCCashToDCCoins;
      }
      
      public function isLoaded() : Boolean
      {
         var _loc1_:* = int(this.mGetInfoFromXMLActions.length - 1);
         while(_loc1_ > -1 && Boolean(this.mGetInfoFromXMLActions[_loc1_].isFinished))
         {
            _loc1_--;
         }
         var _loc2_:Boolean = _loc1_ == -1 && this.mSettingsLoaded && this.mLevelLoaded && this.expansionsIsLoaded() && this.mSocialLoaded && this.mNpcsLoaded && this.universeIsLoaded() && this.unlockSegmentsVisibilityIsLoaded() && this.unlockSegmentsIsLoaded();
         if(Config.COLLECTIBLE_FEATURE_ENABLED)
         {
            if(Config.DEBUG_MODE)
            {
               Debug.trace("." + _loc2_);
            }
         }
         if(_loc2_)
         {
            this.sigCalculateTotal();
            ItemDefinitionManager.getInstance().build();
            if(Config.DEBUG_MODE)
            {
               Debug.trace("build ItemDefinition done");
            }
            ItemDecorationDefinitionManager.getInstance().build();
            if(Config.DEBUG_MODE)
            {
               Debug.trace("build ItemDecorationDefinitionManager done");
            }
            ContractDefinitionManager.getInstance().build();
            if(Config.DEBUG_MODE)
            {
               Debug.trace("build ContractDefinitionManager done");
            }
            MissionDefinitionManager.getInstance().build();
            if(Config.DEBUG_MODE)
            {
               Debug.trace("build MissionDefinitionManager done");
            }
            this.expansionsBuild();
            if(Config.DEBUG_MODE)
            {
               Debug.trace("build expansions done");
            }
         }
         if(Config.DEBUG_MODE)
         {
            Debug.trace("build done");
         }
         return _loc2_;
      }
      
      private function socialDestroy() : void
      {
         this.mSocialUpgradesVisitorExpPerUpgrade = null;
         this.mSocialUpgradesVisitorDCCoinsPerUpgrade = null;
         this.mSocialUpgradesOwnerExtraPercentage = null;
      }
      
      public function expansionsSetFBCredits(param1:int, param2:int) : void
      {
         if(param1 >= 0 && param1 < this.mExpansionsFBCredits.length)
         {
            this.mExpansionsFBCredits[param1] = param2;
         }
      }
      
      public function settingsGetSellPricePercentage() : int
      {
         return this.mSettingsSellPricePercentage;
      }
      
      public function settingsGetManagersPricePercentage() : int
      {
         return this.mSettingsManagersPricePercentage;
      }
      
      public function universeSavePersistence() : void
      {
         var _loc1_:XML = DollarsGame.getCurrentWorld().map.getRulesPersistence();
         var _loc2_:String = _loc1_.toXMLString();
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(_loc2_);
         var _loc4_:FileReference = new FileReference();
         var _loc5_:String = "map.xml";
         _loc4_.save(_loc3_,_loc5_);
      }
      
      private function unlockSegmentsVisibilityDestroy() : void
      {
         if(this.mUnlockSegmentsVisibilityLevelStart != null)
         {
            this.mUnlockSegmentsVisibilityLevelStart.splice(0,this.mUnlockSegmentsVisibilityLevelStart.length);
            this.mUnlockSegmentsVisibilityLevelStart = null;
         }
         if(this.mUnlockSegmentsVisibilityLevelEnd != null)
         {
            this.mUnlockSegmentsVisibilityLevelEnd.splice(0,this.mUnlockSegmentsVisibilityLevelEnd.length);
            this.mUnlockSegmentsVisibilityLevelEnd = null;
         }
         if(this.mUnlockSegmentsVisibilityLevelsCount != null)
         {
            this.mUnlockSegmentsVisibilityLevelsCount.splice(0,this.mUnlockSegmentsVisibilityLevelsCount.length);
            this.mUnlockSegmentsVisibilityLevelsCount = null;
         }
      }
      
      private function npcsDestroy() : void
      {
         this.mNpcsSkus = null;
         this.mNpcsCompanyValues = null;
         this.mNpcsUrls = null;
         this.mNpcsXps = null;
      }
      
      public function overrideUnlockFBCBasePrice(param1:int, param2:int) : void
      {
         if(param1 >= 0 && param1 < this.mUnlockSegmentsBasePriceFBCredits.length)
         {
            this.mUnlockSegmentsBasePriceFBCredits[param1] = param2;
         }
      }
      
      public function socialInvestAskForSpeedTime() : int
      {
         return this.mSocialInvestAskForSpeedTime;
      }
      
      private function socialLoad() : void
      {
         var loader:URLLoader;
         var loaderContext:LoaderContext;
         var request:URLRequest;
         this.mSocialUpgradesVisitorExpPerUpgrade = new Array(UpgradesManager.UPGRADE_TYPE_COUNT);
         this.mSocialUpgradesVisitorDCCoinsPerUpgrade = new Array(UpgradesManager.UPGRADE_TYPE_COUNT);
         this.mSocialUpgradesOwnerExtraPercentage = new Array(UpgradesManager.UPGRADE_TYPE_COUNT);
         loaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         loader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.socialLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.SOCIAL_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.SOCIAL_XML_FILE + " document.");
         }
      }
      
      public function expansionsGetMiniToPlot(param1:int) : int
      {
         return this.mExpansionsMiniToPlot[param1];
      }
      
      public function destroy() : void
      {
         var _loc1_:* = 0;
         var _loc2_:ModelAction = null;
         if(this.mGetInfoFromXMLActions != null)
         {
            _loc1_ = int(this.mGetInfoFromXMLActions.length - 1);
            while(_loc1_ > -1)
            {
               _loc2_ = this.mGetInfoFromXMLActions[_loc1_] as ModelAction;
               _loc2_.destroy();
               this.mGetInfoFromXMLActions[_loc1_] = null;
               _loc1_--;
            }
            this.mGetInfoFromXMLActions = null;
         }
         smLevelXPTable = null;
         smLevelFBCreditToCoins = null;
         smLevelTerrainPriceTable = null;
         smLevelTimePriceTable = null;
         smLevelRepairPricePercentage = null;
         smLevelBreakIncomeTimePercentage = null;
         smLevelBreakIncomeTimeMin = null;
         smLevelBreakMaxItemsPercentage = null;
         smLevelRepairTimeDice = null;
         smLevelDCCashLevelUp = null;
         this.expansionsDestroy();
         this.socialDestroy();
         this.npcsDestroy();
         this.universeDestroy();
         this.unlockSegmentsCashDestroy();
         if(Config.COLLECTIBLE_FEATURE_ENABLED)
         {
         }
         this.sigDestroy();
      }
      
      public function expansionsGetDCCash(param1:int) : int
      {
         return this.mExpansionsDCCash[param1];
      }
      
      private function unlockSegmentsCashLoad() : void
      {
         var request:URLRequest;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.unlockSegmentsCashLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.UNLOCK_SEGMENTS_CASH_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.UNLOCK_SEGMENTS_CASH_XML_FILE + " document.");
         }
         this.mUnlockSegmentsLevelStart = new Array();
         this.mUnlockSegmentsLevelEnd = new Array();
         this.mUnlockSegmentsBasePriceGold = new Array();
         this.mUnlockSegmentsBasePriceFBCredits = new Array();
         this.unlockSegmentsSetMode(UNLOCK_SEGMENTS_MODE_DEFAULT);
      }
   }
}

