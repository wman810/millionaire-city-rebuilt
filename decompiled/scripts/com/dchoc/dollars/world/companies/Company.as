package com.dchoc.dollars.world.companies
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.astar.INode;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.world.World;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinition;
   import flash.utils.Dictionary;
   
   public class Company
   {
      
      public static const WHOSE_MINE:uint = 0;
      
      public static const WHOSE_RIVAL:uint = 1;
      
      public static const WHOSE_COUNT:uint = 2;
      
      public static const MAX_CLIPPING_UPDATES_PER_TICK:int = 0;
      
      public static const MAX_BUILDING_RESOURCES_PER_TICK:int = 2;
      
      private static const REGISTER_ITEMS_ROUNDS_COUNT:int = 10;
      
      private static const REGISTER_ITEMS_STEP_START:int = 4;
      
      private static const REGISTER_ITEMS_STEP_END:int = REGISTER_ITEMS_STEP_START + REGISTER_ITEMS_ROUNDS_COUNT - 1;
      
      public static const BUILD_STEPS_COUNT:int = REGISTER_ITEMS_STEP_END + 1;
      
      private static const DELAYED_PAYMENT_MONEY_ID:int = 0;
      
      private static const DELAYED_PAYMENT_GOLD_ID:int = 1;
      
      private static const DELAYED_PAYMENT_EXP_ID:int = 2;
      
      private static const DELAYED_PAYMENT_COUNT:int = 3;
      
      public static const PROGRESS_EVENT_CONSTRUCTION_FINISHED:String = "constructionFinished";
      
      public static const PROGRESS_EVENT_CONSTRUCTION_FINISHED_WITH_HELP:String = "constructionFinishedWithHelp";
      
      public static const PROGRESS_WHAT_ALL:String = "All";
      
      private static const INVALID_VALUE:int = int.MIN_VALUE;
      
      private static const ATTRIBUTES_TARGET_ALL:String = "all";
      
      public static const ATTRIBUTES_KEY_INFLUENCE:String = "influence";
      
      public static const ATTRIBUTES_KEY_NPC_INCOME:String = "npcIncome";
      
      private static const LAYER_CURRENT:int = 0;
      
      private static const LAYER_OLD:int = 1;
      
      private static const LAYER_COUNT:int = 2;
      
      public static const REGISTER_OCCURRENCES_ITEM_ON_GET_RENT:String = "itemOnRent";
      
      private var mMaxPermits:uint;
      
      protected var mCompanyValuePerBuildingsRefresh:Boolean;
      
      private var mNextRentNeedsToIterate:Boolean;
      
      public var mSid:String = "";
      
      private var mNextRentCurrentItem:ItemObject;
      
      protected var mWhose:uint;
      
      private var mWorld:World;
      
      private var mDCGold:uint;
      
      protected var mItemObjectToBuild:Array;
      
      private var mDelayedPaymentMetricsProduct:Array;
      
      private var mAttributesChangeToNotify:Boolean;
      
      protected var mPersistenceShortFormat:XML;
      
      protected var mCompanyValuePerBuildings:Number;
      
      private var mDelayedPaymentMetricsEvent:Array;
      
      private var mDelayedPaymentCurrency:Array;
      
      private var mNextRentNeedsToBeCalculated:Boolean;
      
      private var mAttributesDictionary:Array;
      
      private var mAttributesChangeBeingNotified:Boolean;
      
      private var mExp:Number;
      
      private var mNextRentCurrentValue:Number;
      
      private var mDCMoney:Number;
      
      protected var mItemObjectsByArea:Array;
      
      private var mDelayedPaymentParticleX:Array;
      
      private var mDelayedPaymentParticleY:Array;
      
      protected var mPersistenceAttributesChanged:Boolean;
      
      private var mPermits:uint;
      
      protected var mItemsAllowedToBreakCount:int;
      
      protected var mDisplayFilters:Array;
      
      private var mRegisterOccurrencesDictionary:Dictionary;
      
      private var mCurrentItemIdBeingBuilt:int;
      
      private var mDelayedPaymentSpawnParticle:Array;
      
      private var mNumberOfItemsToProcessByRound:int;
      
      private var mDelayedPaymentMetricsText:Array;
      
      private var mNeedsToRegisterRoad:Boolean;
      
      protected var mItemObjects:Array;
      
      protected var mItemObjectsByTypeCount:Array;
      
      protected var mPersistence:XML;
      
      private var mItemObjectsBeingBuilt:Array;
      
      private var mNextRentPreviousValue:Number;
      
      private var mProgressDictionary:Dictionary;
      
      public function Company(param1:World, param2:uint)
      {
         super();
         this.mWorld = param1;
         this.mWhose = param2;
         this.mItemObjects = new Array();
         this.mItemObjectsByArea = new Array();
         this.mItemObjectToBuild = new Array();
         var _loc3_:* = MapDefinition.getInstance().getMapAreaCount();
         while(_loc3_ > 0)
         {
            this.mItemObjectsByArea.push(new Array());
            _loc3_--;
         }
         this.mItemObjectsByTypeCount = new Array();
         _loc3_ = 0;
         while(_loc3_ < ItemDefinition.TYPE_COUNT)
         {
            this.mItemObjectsByTypeCount.push(0);
            _loc3_++;
         }
         this.displayLoadFilters();
         this.mPersistenceAttributesChanged = false;
      }
      
      public static function getCompany(param1:World, param2:uint) : Company
      {
         var _loc3_:Company = null;
         if(param2 == WHOSE_MINE)
         {
            _loc3_ = new CompanyMine(param1,param2);
         }
         else
         {
            _loc3_ = new CompanyRival(param1,param2);
         }
         return _loc3_;
      }
      
      protected function displayDestroyFilters() : void
      {
         this.mDisplayFilters = null;
      }
      
      public function getItems() : Array
      {
         return this.mItemObjects;
      }
      
      public function isAgeEnabled() : Boolean
      {
         return this.isMine();
      }
      
      private function progressDestroy() : void
      {
         this.mProgressDictionary = null;
      }
      
      public function getCompanyValuePerDCCoins() : Number
      {
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
         {
            return DollarsGame.getProfileUniverse().DCCoins;
         }
         return this.mDCMoney;
      }
      
      private function nextRentCalculate() : void
      {
         var _loc1_:ItemObject = null;
         if(this.registerOccurrenceGetAmount(REGISTER_OCCURRENCES_ITEM_ON_GET_RENT) > 0)
         {
            this.mNextRentCurrentValue = 0;
         }
         else if(this.mNextRentNeedsToIterate)
         {
            this.mNextRentCurrentItem = null;
            this.mNextRentCurrentValue = Number.MAX_VALUE;
            for each(_loc1_ in this.mItemObjects)
            {
               if(_loc1_.needsToBeTrackedForRent())
               {
                  if(_loc1_.getIncomeTimeLeft() < this.mNextRentCurrentValue)
                  {
                     this.mNextRentCurrentValue = _loc1_.getIncomeTimeLeft();
                     this.mNextRentCurrentItem = _loc1_;
                  }
               }
            }
            if(this.mNextRentCurrentItem == null)
            {
               this.mNextRentCurrentValue = -1;
            }
            this.mNextRentNeedsToIterate = false;
         }
         if(this.mNextRentCurrentValue != this.mNextRentPreviousValue)
         {
            this.mNextRentPreviousValue = this.mNextRentCurrentValue;
            DollarsGame.getProfile().nextRentUpdate(this.mNextRentCurrentValue,this.mNextRentCurrentItem);
         }
         this.mNextRentNeedsToBeCalculated = false;
      }
      
      public function get itemsAllowedToBreakCount() : int
      {
         return this.mItemsAllowedToBreakCount;
      }
      
      protected function displayLoadFilters() : void
      {
      }
      
      public function nextRentDismiss(param1:ItemObject) : void
      {
         if(param1 == this.mNextRentCurrentItem)
         {
            this.mNextRentNeedsToBeCalculated = true;
            this.mNextRentNeedsToIterate = true;
         }
      }
      
      public function get exp() : Number
      {
         return DollarsGame.getProfile().exp;
      }
      
      public function set itemsAllowedToBreakCount(param1:int) : void
      {
         this.mItemsAllowedToBreakCount = param1;
      }
      
      public function showsNotificationIncome() : Boolean
      {
         return false;
      }
      
      private function delayedPaymentSetCommon(param1:int, param2:int, param3:String = null, param4:String = null, param5:String = null, param6:Boolean = false, param7:int = -1, param8:int = -1) : void
      {
         this.mDelayedPaymentCurrency[param1] = param2;
         this.mDelayedPaymentMetricsEvent[param1] = param3;
         this.mDelayedPaymentMetricsText[param1] = param4;
         this.mDelayedPaymentMetricsText[param1] = param5;
         this.mDelayedPaymentSpawnParticle[param1] = param6;
         this.mDelayedPaymentParticleX[param1] = param7;
         this.mDelayedPaymentParticleY[param1] = param8;
      }
      
      public function getCompanyValuePerBuildings() : Number
      {
         var _loc1_:ItemObject = null;
         var _loc2_:int = 0;
         if(this.mCompanyValuePerBuildingsRefresh)
         {
            this.mCompanyValuePerBuildings = 0;
            for each(_loc1_ in this.mItemObjects)
            {
               if(_loc1_.canBeSold())
               {
                  _loc2_ = _loc1_.getCompanyValue();
                  this.mCompanyValuePerBuildings += _loc2_;
               }
            }
         }
         return this.mCompanyValuePerBuildings;
      }
      
      private function delayedPaymentDestroy() : void
      {
         this.mDelayedPaymentCurrency = null;
         this.mDelayedPaymentSpawnParticle = null;
         this.mDelayedPaymentParticleX = null;
         this.mDelayedPaymentParticleY = null;
         this.mDelayedPaymentMetricsEvent = null;
         this.mDelayedPaymentMetricsProduct = null;
         this.mDelayedPaymentMetricsText = null;
      }
      
      public function changeQuality(param1:Boolean) : void
      {
         var _loc2_:ItemObject = null;
         for each(_loc2_ in this.mItemObjects)
         {
            _loc2_.changeAnimationQuality(param1);
         }
      }
      
      public function registerOccurrencesRemoveItem(param1:ItemObject) : void
      {
         var _loc2_:String = param1.itemDefinition.sku;
         this.registerOccurrencesRemoveEvent(_loc2_);
      }
      
      protected function sortOnDistance(param1:ItemObject, param2:ItemObject) : int
      {
         var _loc3_:Map = this.mWorld.map;
         var _loc4_:Number = param1.worldX - _loc3_.width / 2;
         var _loc5_:Number = param1.worldY - _loc3_.height / 2;
         var _loc6_:Number = param2.worldX - _loc3_.width / 2;
         var _loc7_:Number = param2.worldY - _loc3_.height / 2;
         var _loc8_:Number = Math.abs(_loc4_) + Math.abs(_loc5_);
         var _loc9_:Number = Math.abs(_loc6_) + Math.abs(_loc7_);
         if(_loc8_ > _loc9_)
         {
            return 1;
         }
         if(_loc8_ < _loc9_)
         {
            return -1;
         }
         return 0;
      }
      
      public function showsIncomeBar() : Boolean
      {
         return false;
      }
      
      public function delayedPaymentSetCoins(param1:int, param2:String = null, param3:String = null, param4:String = null, param5:Boolean = false, param6:int = -1, param7:int = -1) : void
      {
         this.delayedPaymentSetCommon(DELAYED_PAYMENT_MONEY_ID,param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function getItemsCount() : int
      {
         return this.mItemObjects.length;
      }
      
      public function getLastItem() : ItemObject
      {
         return this.mItemObjects[this.mItemObjects.length - 1] as ItemObject;
      }
      
      public function registerOccurrencesAddItem(param1:ItemObject) : void
      {
         var _loc2_:String = param1.itemDefinition.sku;
         this.registerOccurrencesAddEvent(_loc2_);
      }
      
      public function set exp(param1:Number) : void
      {
         if(this.isCompanyProgressAppliedToProfileEnabled())
         {
            if(this.isCompanyProgressEnabled())
            {
               this.mExp = param1;
            }
            DollarsGame.getProfile().exp = this.mExp;
         }
      }
      
      private function delayedPaymentLoad() : void
      {
         this.mDelayedPaymentCurrency = new Array(DELAYED_PAYMENT_COUNT);
         var _loc1_:int = 0;
         while(_loc1_ < DELAYED_PAYMENT_COUNT)
         {
            this.mDelayedPaymentCurrency[_loc1_] = 0;
            _loc1_++;
         }
         this.mDelayedPaymentSpawnParticle = new Array(DELAYED_PAYMENT_COUNT);
         this.mDelayedPaymentParticleX = new Array(DELAYED_PAYMENT_COUNT);
         this.mDelayedPaymentParticleY = new Array(DELAYED_PAYMENT_COUNT);
         this.mDelayedPaymentMetricsEvent = new Array(DELAYED_PAYMENT_COUNT);
         this.mDelayedPaymentMetricsProduct = new Array(DELAYED_PAYMENT_COUNT);
         this.mDelayedPaymentMetricsText = new Array(DELAYED_PAYMENT_COUNT);
      }
      
      public function delayedPaymentGetExp() : int
      {
         return this.delayedPaymentGetCommon(DELAYED_PAYMENT_EXP_ID);
      }
      
      public function progressBuildingItems() : int
      {
         if(this.mItemObjectToBuild == null)
         {
            return 0;
         }
         if(this.mItemObjects == null)
         {
            return 100;
         }
         return 100 - this.mItemObjectToBuild.length * 100 / this.mItemObjects.length;
      }
      
      public function registerItemInArea(param1:ItemObject) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = this.mWorld.map.getWorldToTileIndex(param1.worldX,param1.worldY,param1.worldZ);
         if(this.mWorld.map.isValidTileIndex(_loc2_))
         {
            _loc3_ = this.world.map.getAreaIndexFromTileIndex(_loc2_);
            this.mItemObjectsByArea[_loc3_].push(param1);
            if(Config.SMART_RESOURCE_LOADING && !param1.hasResourcesLoaded())
            {
               this.mItemObjectToBuild.push(param1);
            }
            if(!DollarsGame.getProfileUniverse().isExpansionAreaMine(_loc3_))
            {
               param1.viewSetColorAreaNotMine();
            }
         }
      }
      
      public function get DCCash() : uint
      {
         return DollarsGame.getProfile().DCCash;
      }
      
      public function connectionToHQRegisterItems(param1:int, param2:int) : void
      {
         var _loc3_:ItemObject = null;
         for each(_loc3_ in this.mItemObjects)
         {
            if(_loc3_ != null && this.connectionToHQNeedsToBeProcessed(_loc3_,param1,param2))
            {
               this.world.connectioToHQAddItem(_loc3_);
            }
         }
      }
      
      public function addItem(param1:ItemObject, param2:Boolean = true) : void
      {
         this.attachCompanyToItem(param1);
         var _loc3_:Map = this.world.map;
         if(param2)
         {
            this.registerItemInArea(param1);
         }
         this.mItemObjects.push(param1);
         var _loc4_:int = ItemDefinitionManager.getInstance().getTypeBySku(param1.sku);
         var _loc5_:* = this.mItemObjectsByTypeCount[_loc4_] as int;
         _loc5_ = _loc5_ + 1;
         this.mItemObjectsByTypeCount[_loc4_] = _loc5_;
         this.mCompanyValuePerBuildingsRefresh = true;
         if(param2)
         {
            if(this.mWorld.role != null)
            {
               this.mWorld.role.buildItem(param1);
            }
            if(_loc3_ != null && this.mWorld.role != null)
            {
               _loc3_.placeItem(param1,this.isMine());
            }
         }
      }
      
      public function initItemAfterBuying(param1:ItemObject, param2:Boolean = true) : void
      {
      }
      
      protected function displayAppFilter(param1:ItemObject) : void
      {
         if(param1 != null)
         {
            param1.displayObjectL0.filters = this.mDisplayFilters;
         }
      }
      
      public function attachRole(param1:Role) : void
      {
         var _loc2_:ItemObject = null;
         for each(_loc2_ in this.mItemObjects)
         {
            _loc2_.attachRole(param1);
         }
      }
      
      public function progressGetEventCount(param1:String, param2:String = "All") : int
      {
         var _loc3_:int = 0;
         var _loc4_:String = param1 + param2;
         if(this.mProgressDictionary[_loc4_] != null)
         {
            _loc3_ = int(this.mProgressDictionary[_loc4_]);
         }
         return _loc3_;
      }
      
      public function attributesGetValue(param1:String, param2:ItemDefinition, param3:int = 0) : int
      {
         var _loc5_:Dictionary = null;
         var _loc6_:String = null;
         var _loc4_:int = 0;
         if(this.mAttributesDictionary != null)
         {
            _loc5_ = this.mAttributesDictionary[param3] as Dictionary;
            if(_loc5_[param1] != null)
            {
               if(_loc5_[param1][ATTRIBUTES_TARGET_ALL] != null)
               {
                  _loc4_ += _loc5_[param1][ATTRIBUTES_TARGET_ALL];
               }
               if(_loc5_[param1][param2.sku] != null)
               {
                  _loc4_ += _loc5_[param1][param2.sku];
               }
               _loc6_ = ItemDefinition.NAME_TYPES[param2.type];
               if(_loc5_[param1][_loc6_] != null)
               {
                  _loc4_ += _loc5_[param1][_loc6_];
               }
            }
         }
         return _loc4_;
      }
      
      public function getCompanyValuePerTerrain() : Number
      {
         var _loc1_:Profile = DollarsGame.getProfileUniverse();
         var _loc2_:Number = DollarsGame.getCurrentWorld().map.terrainTilesCount * _loc1_.getTerrainPrice();
         var _loc3_:Number = _loc1_.getCompanyValuePerExpansions();
         return _loc2_ + _loc3_;
      }
      
      public function attributesHaveChanged(param1:String, param2:ItemDefinition) : Boolean
      {
         var _loc4_:Dictionary = null;
         var _loc3_:Boolean = this.mAttributesChangeBeingNotified;
         if(_loc3_)
         {
            _loc4_ = this.mAttributesDictionary[LAYER_OLD] as Dictionary;
            _loc3_ = _loc4_[param1] != null;
            if(_loc3_)
            {
               _loc3_ = _loc4_[param1][ATTRIBUTES_TARGET_ALL] != null || _loc4_[param1][param2.sku] != null;
            }
         }
         return _loc3_;
      }
      
      public function getCompanyValuePerDCCash() : Number
      {
         var _loc1_:Number = NaN;
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
         {
            _loc1_ = DollarsGame.getProfileUniverse().DCCash;
         }
         else
         {
            _loc1_ = this.mDCGold;
         }
         return _loc1_ * RulesFacade.getDCCashToDCCoins();
      }
      
      public function getPersistence(param1:Boolean = false) : XML
      {
         var _loc4_:Array = null;
         var _loc5_:ItemObject = null;
         if(this.mSid == "")
         {
            this.mSid = "" + DollarsGame.smCompanySid;
            ++DollarsGame.smCompanySid;
         }
         var _loc2_:String = this.mWorld.mSid;
         var _loc3_:XML = <Company sid={this.mSid} wsid={_loc2_} whose={this.mWhose}> 					            		
        		</Company>;
         if(!param1)
         {
            for each(_loc4_ in this.mItemObjectsByArea)
            {
               for each(_loc5_ in _loc4_)
               {
                  if(Config.OPT_USE_BUILD_SHORT_FORMAT && _loc5_.itemDefinition.getBuildFormatId() == ItemDefinition.BUILD_FORMAT_SHORT_ID)
                  {
                     this.mWorld.buildShortFormatAddItem(_loc5_.getPersistenceShortFormat());
                  }
                  else
                  {
                     _loc3_.appendChild(_loc5_.getPersistence());
                  }
               }
            }
         }
         this.mPersistence = _loc3_;
         return this.mPersistence;
      }
      
      public function getCompanyValue() : Number
      {
         return this.getCompanyValuePerDCCoins() + this.getCompanyValuePerDCCash() + this.getCompanyValuePerPatrimony();
      }
      
      public function build(param1:int) : void
      {
         var _loc2_:Map = null;
         var _loc3_:ItemObject = null;
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc15_:Object = null;
         if(param1 == 0)
         {
            this.progressLoad();
            this.attributesLoad();
            this.registerOccurrencesLoad();
            this.delayedPaymentLoad();
            this.nextRentLoad();
            _loc2_ = this.mWorld.map;
            this.mItemObjectsBeingBuilt = new Array();
         }
         else if(param1 == 1)
         {
            for each(_loc4_ in this.mPersistence.Item)
            {
               _loc3_ = new ItemObject();
               this.buildItem(_loc4_,ItemDefinition.BUILD_FORMAT_LONG_ID);
            }
         }
         else if(param1 == 2 && this.mPersistenceShortFormat != null)
         {
            for each(_loc5_ in this.mPersistenceShortFormat.Items)
            {
               _loc6_ = String(_loc5_.@chunk);
               _loc7_ = _loc6_.split(",");
               for each(_loc8_ in _loc7_)
               {
                  if(_loc8_ != "")
                  {
                     this.buildItem(_loc8_,ItemDefinition.BUILD_FORMAT_SHORT_ID);
                  }
               }
            }
         }
         else if(param1 == 3)
         {
            this.mItemObjectsBeingBuilt.sort(this.sortItems);
         }
         else if(param1 >= REGISTER_ITEMS_STEP_START && param1 <= REGISTER_ITEMS_STEP_END)
         {
            _loc9_ = int(this.mItemObjectsBeingBuilt.length);
            if(param1 == REGISTER_ITEMS_STEP_START)
            {
               this.mCurrentItemIdBeingBuilt = 0;
               this.mNumberOfItemsToProcessByRound = _loc9_ / REGISTER_ITEMS_ROUNDS_COUNT;
               if(_loc9_ % REGISTER_ITEMS_ROUNDS_COUNT != 0)
               {
                  ++this.mNumberOfItemsToProcessByRound;
               }
            }
            _loc2_ = this.mWorld.map;
            _loc10_ = this.mCurrentItemIdBeingBuilt;
            while(this.mCurrentItemIdBeingBuilt < _loc9_ && this.mCurrentItemIdBeingBuilt - _loc10_ < this.mNumberOfItemsToProcessByRound)
            {
               _loc3_ = this.mItemObjectsBeingBuilt[this.mCurrentItemIdBeingBuilt] as ItemObject;
               _loc11_ = _loc2_.getTileRelativeXToTile(_loc3_.tileRelativeX);
               _loc12_ = _loc2_.getTileRelativeYToTile(_loc3_.tileRelativeY);
               _loc13_ = _loc2_.getTileXYToTileIndex(_loc11_,_loc12_);
               _loc14_ = _loc3_.itemDefinition.isHeadQuarters() || _loc2_.isBuildable(_loc13_,_loc3_.itemDefinition,false);
               _loc14_ = true;
               if(_loc14_)
               {
                  this.addItem(_loc3_,false);
                  _loc3_.build();
                  _loc2_.placeItem(_loc3_,false);
                  this.registerItemInArea(_loc3_);
               }
               else
               {
                  _loc15_ = new Object();
                  _loc15_.cmd = UserDataFacade.QUEUE_REQUEST_DESTROY_ITEM_IN_NOT_EMPTY_PLOT;
                  _loc15_.item = _loc3_;
                  UserDataFacade.getInstance().queueRequestAdd(_loc15_);
                  Debug.trace("@@@@@@@@ queueRequestAdd " + _loc15_.cmd + " sid = " + _loc3_.mSid + ": ERROR in Company.build(): Item is trying to be placed in an invalid place");
               }
               ++this.mCurrentItemIdBeingBuilt;
            }
            if(param1 == REGISTER_ITEMS_STEP_END)
            {
               this.mItemObjectsBeingBuilt.splice(0,_loc9_);
               this.mItemObjectsBeingBuilt = null;
            }
         }
      }
      
      private function nextRentLogicUpdate(param1:int) : void
      {
         if(this.mNextRentNeedsToBeCalculated)
         {
            this.nextRentCalculate();
         }
      }
      
      public function needsToRegisterRoad() : Boolean
      {
         return Tutorial.smTutorialEnd || Tutorial.smTutorialStep >= Tutorial.TUTORIAL_STEP_BUILD_ROAD;
      }
      
      public function isRival() : Boolean
      {
         return this.mWhose == WHOSE_RIVAL;
      }
      
      public function showsCoinsParticles() : Boolean
      {
         return this.isMine();
      }
      
      public function progressRegisterEvent(param1:String, param2:String = "All") : void
      {
         var _loc3_:String = param1 + param2;
         if(this.mProgressDictionary[_loc3_] == null)
         {
            this.mProgressDictionary[_loc3_] = 0;
         }
         ++this.mProgressDictionary[_loc3_];
      }
      
      public function showsConstructionBar() : Boolean
      {
         return false;
      }
      
      public function set DCCoins(param1:Number) : void
      {
         if(this.isCompanyProgressAppliedToProfileEnabled())
         {
            if(this.isCompanyProgressEnabled())
            {
               this.mDCMoney = param1;
            }
            if(this.mDCMoney < 0)
            {
               this.mDCMoney = 0;
            }
            DollarsGame.getProfile().DCCoins = this.mDCMoney;
         }
      }
      
      public function sortItemsToBuild() : void
      {
         this.mItemObjectToBuild.sortOn("mDistanceFromMapCenter",Array.NUMERIC);
      }
      
      private function connectionToHQNeedsToBeProcessed(param1:ItemObject, param2:int, param3:int) : Boolean
      {
         var _loc5_:INode = null;
         var _loc4_:Boolean = param1.itemDefinition.needsHQConnection();
         if(_loc4_)
         {
            switch(param2)
            {
               case World.CONNECTION_TO_HQ_TYPE_REGISTER_ROAD:
                  _loc4_ = !param1.isHQConnected();
                  break;
               case World.CONNECTION_TO_HQ_TYPE_UNREGISTER_ROAD:
                  _loc5_ = this.world.map.getTileDataFromIndex(param3);
                  _loc4_ = param1.isHQConnected() && param1.searchHQContainsNode(_loc5_);
            }
         }
         return _loc4_;
      }
      
      public function get whose() : uint
      {
         return this.mWhose;
      }
      
      public function synchronizeDataWithProfile() : void
      {
         var _loc1_:Profile = DollarsGame.getProfile();
         this.mExp = _loc1_.exp;
         this.mDCGold = _loc1_.DCCash;
         this.mDCMoney = _loc1_.DCCoins;
      }
      
      public function get world() : World
      {
         return this.mWorld;
      }
      
      public function isInfluencePercentageEnabled() : Boolean
      {
         return this.isMine();
      }
      
      public function isMine() : Boolean
      {
         return this.mWhose == WHOSE_MINE;
      }
      
      private function isItemValid(param1:ItemObject) : Boolean
      {
         var _loc2_:Boolean = true;
         var _loc3_:Map = this.mWorld.map;
         var _loc4_:uint = _loc3_.getTileRelativeXToTile(param1.tileRelativeX);
         var _loc5_:uint = _loc3_.getTileRelativeYToTile(param1.tileRelativeY);
         var _loc6_:int = _loc3_.getTileXYToTileIndex(_loc4_,_loc5_);
         _loc2_ = _loc3_.getTileXYToTileIndex(_loc4_,_loc5_) != -1;
         if(_loc2_)
         {
            _loc2_ = _loc3_.getTileXYToTileIndex(_loc4_ + param1.itemDefinition.baseCols - 1,_loc5_ + param1.itemDefinition.baseRows - 1) != -1;
         }
         return _loc2_;
      }
      
      private function buildItem(param1:Object, param2:int) : void
      {
         var _loc5_:ItemDefinition = null;
         var _loc3_:ItemObject = new ItemObject();
         var _loc4_:Boolean = _loc3_.setPersistenceFromFormat(param1,param2);
         if(_loc4_)
         {
            _loc5_ = ItemDefinitionManager.getInstance().getDefinitionBySku(_loc3_.sku) as ItemDefinition;
            if(_loc5_ != null && _loc5_.isBuildableFromFormat(param2))
            {
               _loc3_.itemDefinition = _loc5_;
               _loc4_ = this.isItemValid(_loc3_);
               if(_loc4_)
               {
                  this.mItemObjectsBeingBuilt.push(_loc3_);
               }
               else if(Config.DEBUG_ASSERTS)
               {
                  Debug.trace("############# ERROR in Company.build(): Item <" + _loc3_.mSid + "> wasn\'t built because it\'s not within map area");
               }
            }
         }
      }
      
      public function set DCCash(param1:uint) : void
      {
         if(this.isCompanyProgressAppliedToProfileEnabled())
         {
            if(this.isCompanyProgressEnabled())
            {
               this.mDCGold = param1;
            }
            if(this.mDCGold < 0)
            {
               this.mDCGold = 0;
            }
            DollarsGame.getProfile().DCCash = this.mDCGold;
         }
      }
      
      private function registerOccurrencesLoad() : void
      {
         this.mRegisterOccurrencesDictionary = new Dictionary(true);
      }
      
      public function attributesDestroy() : void
      {
         var _loc1_:int = 0;
         if(this.mAttributesDictionary != null)
         {
            _loc1_ = 0;
            while(_loc1_ < LAYER_COUNT)
            {
               this.mAttributesDictionary[_loc1_] = null;
               _loc1_++;
            }
            this.mAttributesDictionary = null;
         }
      }
      
      public function getItem(param1:int, param2:int = -1) : ItemObject
      {
         var _loc3_:ItemObject = null;
         if(this.mItemObjectsByArea != null)
         {
            if(param2 == -1)
            {
               param2 = MapDefinition.getInstance().getAreaCentral();
            }
            _loc3_ = this.mItemObjectsByArea[param2][param1] as ItemObject;
         }
         return _loc3_;
      }
      
      private function attributesSetChangeNotification(param1:Boolean) : void
      {
         this.mAttributesChangeToNotify = param1;
         if(this.mAttributesChangeToNotify)
         {
            if(this.mAttributesDictionary[LAYER_OLD] == null)
            {
               this.mAttributesDictionary[LAYER_OLD] = new Dictionary(true);
            }
         }
         else
         {
            this.mAttributesDictionary[LAYER_OLD] = null;
         }
      }
      
      public function delayedPaymentGetCoins() : int
      {
         return this.delayedPaymentGetCommon(DELAYED_PAYMENT_MONEY_ID);
      }
      
      private function progressLoad() : void
      {
         this.mProgressDictionary = new Dictionary(true);
      }
      
      public function unattachRole(param1:Role) : void
      {
         var _loc2_:ItemObject = null;
         for each(_loc2_ in this.mItemObjects)
         {
            param1.unbuildItem(_loc2_);
         }
      }
      
      public function getItemsCountByType(param1:int) : int
      {
         return this.mItemObjectsByTypeCount[param1];
      }
      
      public function removeItem(param1:ItemObject, param2:Boolean = true) : void
      {
         var _loc7_:WonderTypeDefinition = null;
         this.nextRentDismiss(param1);
         if(param2 && param1.itemDefinition.type == ItemDefinition.TYPE_WONDERS_ID && param1.isHQConnected())
         {
            _loc7_ = param1.itemDefinition.getWonderType();
            _loc7_.undoEffect(param1);
         }
         var _loc3_:Map = this.mWorld.map;
         if(param2)
         {
            if(this.mWorld.role != null)
            {
               this.mWorld.role.unbuildItem(param1);
            }
            if(_loc3_ != null)
            {
               _loc3_.unplaceItem(param1);
            }
         }
         this.unregisterItemInArea(param1);
         var _loc4_:int = this.mItemObjects.indexOf(param1);
         this.mItemObjects.splice(_loc4_,1);
         var _loc5_:int = ItemDefinitionManager.getInstance().getTypeBySku(param1.sku);
         var _loc6_:* = this.mItemObjectsByTypeCount[_loc5_] as int;
         _loc6_ = _loc6_ - 1;
         this.mItemObjectsByTypeCount[_loc5_] = _loc6_;
         if(param1.itemDefinition.needsToRegisterNumberOfConstructions())
         {
            this.registerOccurrencesRemoveItem(param1);
         }
         if(param2)
         {
            param1.destroy(true);
         }
         this.mCompanyValuePerBuildingsRefresh = true;
      }
      
      public function registerOccurrencesAddEvent(param1:String) : void
      {
         if(this.mRegisterOccurrencesDictionary[param1] == null)
         {
            this.mRegisterOccurrencesDictionary[param1] = 0;
         }
         ++this.mRegisterOccurrencesDictionary[param1];
         if(param1 == REGISTER_OCCURRENCES_ITEM_ON_GET_RENT)
         {
            this.mNextRentNeedsToBeCalculated = true;
         }
      }
      
      private function unregisterItemInArea(param1:ItemObject) : void
      {
         var _loc2_:int = this.mWorld.map.getWorldToTileIndex(param1.worldX,param1.worldY,param1.worldZ);
         var _loc3_:int = this.mWorld.map.getAreaIndexFromTileIndex(_loc2_);
         var _loc4_:int = int(this.mItemObjectsByArea[_loc3_].indexOf(param1));
         if(_loc4_ > -1)
         {
            this.mItemObjectsByArea[_loc3_].splice(_loc4_,1);
         }
         if(Config.SMART_RESOURCE_LOADING)
         {
            _loc4_ = this.mItemObjectToBuild.indexOf(param1);
            if(_loc4_ > -1)
            {
               this.mItemObjectToBuild.splice(_loc4_,1);
            }
         }
      }
      
      public function isUpdateCompanyValueNeeded() : Boolean
      {
         return this.isMine();
      }
      
      public function nextRentCheck(param1:ItemObject) : void
      {
         if(param1 != this.mNextRentCurrentItem)
         {
            if(this.mNextRentCurrentValue == -1 || param1.getIncomeTimeLeft() < this.mNextRentCurrentValue)
            {
               this.mNextRentCurrentItem = param1;
               this.mNextRentCurrentValue = param1.getIncomeTimeLeft();
               this.mNextRentNeedsToBeCalculated = true;
               this.mNextRentNeedsToIterate = false;
            }
         }
      }
      
      public function setNeedsToRegisterRoad(param1:Boolean) : void
      {
         this.mNeedsToRegisterRoad = param1;
      }
      
      private function sortItems(param1:ItemObject, param2:ItemObject) : Number
      {
         var _loc3_:Number = 0;
         if(parseInt(param1.mSid) < parseInt(param2.mSid))
         {
            _loc3_ = 1;
         }
         else
         {
            _loc3_ = -1;
         }
         return _loc3_;
      }
      
      public function get DCCoins() : Number
      {
         return DollarsGame.getProfile().DCCoins;
      }
      
      public function delayedPaymentPay() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.mDelayedPaymentCurrency != null)
         {
            _loc1_ = 0;
            while(_loc1_ < DELAYED_PAYMENT_COUNT)
            {
               if(this.mDelayedPaymentCurrency[_loc1_] != 0)
               {
                  _loc2_ = int(PointsAnimation.TYPE_COINS);
                  if(_loc1_ == DELAYED_PAYMENT_MONEY_ID)
                  {
                     this.DCCoins -= this.mDelayedPaymentCurrency[_loc1_];
                     if(this.mDelayedPaymentMetricsEvent[_loc1_] != null)
                     {
                        if(this.mDelayedPaymentCurrency[_loc1_] >= 0)
                        {
                           MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,this.mDelayedPaymentMetricsEvent[_loc1_],this.mDelayedPaymentMetricsProduct[_loc1_],this.mDelayedPaymentMetricsText[_loc1_],null,this.mDelayedPaymentCurrency[_loc1_],0);
                        }
                        else
                        {
                           MyMetrics.sendMetricNG(MetricConstants.EVENT_EARN_MONEY,this.mDelayedPaymentMetricsEvent[_loc1_],this.mDelayedPaymentMetricsProduct[_loc1_],this.mDelayedPaymentMetricsText[_loc1_],null,-this.mDelayedPaymentCurrency[_loc1_],0);
                        }
                     }
                  }
                  else if(_loc1_ == DELAYED_PAYMENT_GOLD_ID)
                  {
                     this.DCCash -= this.mDelayedPaymentCurrency[_loc1_];
                     if(this.mDelayedPaymentMetricsEvent[_loc1_] != null)
                     {
                        if(this.mDelayedPaymentCurrency[_loc1_] >= 0)
                        {
                           MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,this.mDelayedPaymentMetricsEvent[_loc1_],this.mDelayedPaymentMetricsProduct[_loc1_],this.mDelayedPaymentMetricsText[_loc1_],null,0,this.mDelayedPaymentCurrency[_loc1_]);
                        }
                        else
                        {
                           MyMetrics.sendMetricNG(MetricConstants.EVENT_EARN_GOLD,this.mDelayedPaymentMetricsEvent[_loc1_],this.mDelayedPaymentMetricsProduct[_loc1_],this.mDelayedPaymentMetricsText[_loc1_],null,0,-this.mDelayedPaymentCurrency[_loc1_]);
                        }
                     }
                     _loc2_ = int(PointsAnimation.TYPE_GOLD);
                  }
                  else if(_loc1_ == DELAYED_PAYMENT_EXP_ID)
                  {
                     this.exp -= this.mDelayedPaymentCurrency[_loc1_];
                  }
                  if(Boolean(this.mDelayedPaymentSpawnParticle[_loc1_]) && this.showsCoinsParticles())
                  {
                     ParticlesManager.addParticle(new PointsAnimation(-this.mDelayedPaymentCurrency[_loc1_],_loc2_,this.mDelayedPaymentParticleX[_loc1_],this.mDelayedPaymentParticleY[_loc1_]));
                  }
                  this.mDelayedPaymentCurrency[_loc1_] = 0;
                  this.mDelayedPaymentMetricsEvent[_loc1_] = null;
                  this.mDelayedPaymentSpawnParticle[_loc1_] = false;
               }
               _loc1_++;
            }
         }
      }
      
      public function delayedPaymentGetCash() : int
      {
         return this.delayedPaymentGetCommon(DELAYED_PAYMENT_GOLD_ID);
      }
      
      public function delayedPaymentSetExp(param1:int, param2:String = null, param3:String = null, param4:String = null, param5:Boolean = false, param6:int = -1, param7:int = -1) : void
      {
         this.delayedPaymentSetCommon(DELAYED_PAYMENT_EXP_ID,param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc15_:ItemObject = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc2_:Profile = DollarsGame.getProfileUniverse();
         if(this.mAttributesChangeToNotify)
         {
            this.mAttributesChangeBeingNotified = true;
         }
         var _loc3_:int = int(this.mItemObjectsByArea.length);
         var _loc4_:Map = this.mWorld.map;
         var _loc5_:int = Dollars.smStage.stageWidth;
         var _loc6_:int = Dollars.smStage.stageHeight;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:UpgradesManager = UpgradesManager.getInstance();
         var _loc11_:String = _loc10_.sidsToUpgradeGetNextSid();
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         while(_loc14_ < _loc3_)
         {
            if(_loc2_.isExpansionAreaMine(_loc14_))
            {
               for each(_loc15_ in this.mItemObjectsByArea[_loc14_])
               {
                  if(Config.DEBUG_MODE)
                  {
                     _loc8_++;
                  }
                  if(_loc12_ < Company.MAX_CLIPPING_UPDATES_PER_TICK)
                  {
                     if(_loc15_.displayObjectL0 != null)
                     {
                        _loc16_ = _loc4_.getWorldXToScreen(_loc15_.worldX);
                        _loc17_ = _loc4_.getWorldYToScreen(_loc15_.worldY) + _loc15_.worldSizeY;
                        if(_loc16_ + _loc15_.worldSizeX > 0 && _loc16_ < _loc5_ && _loc17_ > 0 && _loc17_ - _loc15_.displayObjectL0.getHeight() < _loc6_)
                        {
                           if(!_loc15_.isVisible())
                           {
                              _loc15_.setVisible(true);
                              _loc4_.addIntoDisplay(_loc15_);
                              _loc7_ = true;
                              _loc12_++;
                           }
                           if(_loc13_ < MAX_BUILDING_RESOURCES_PER_TICK && _loc15_.buildUpdate(param1))
                           {
                              _loc13_++;
                           }
                        }
                        else if(_loc15_.isVisible())
                        {
                           _loc15_.setVisible(false);
                           _loc4_.removeFromDisplay(_loc15_);
                           _loc12_++;
                        }
                     }
                  }
                  if(_loc11_ != null && _loc15_.mSid == _loc11_)
                  {
                     _loc15_.applyUpgrade();
                     _loc10_.sidsToUpgradeShiftSid();
                     _loc11_ = _loc10_.sidsToUpgradeGetNextSid();
                  }
                  _loc15_.logicUpdate(param1);
                  if(Config.DEBUG_MODE && _loc15_.isVisible())
                  {
                     _loc9_++;
                  }
               }
            }
            _loc14_++;
         }
         if(_loc7_)
         {
            _loc4_.sortDisplayList();
         }
         if(this.mAttributesChangeBeingNotified)
         {
            this.attributesSetChangeNotification(false);
            this.mAttributesChangeBeingNotified = false;
         }
         if(this.mPersistenceAttributesChanged)
         {
            this.mPersistenceAttributesChanged = false;
         }
         this.nextRentLogicUpdate(param1);
      }
      
      public function areaBuy(param1:int) : void
      {
         var _loc2_:ItemObject = null;
         for each(_loc2_ in this.mItemObjectsByArea[param1])
         {
            _loc2_.viewSetColorAreaMine();
         }
      }
      
      public function isCommerceEventsEnabled() : Boolean
      {
         return this.isMine();
      }
      
      protected function attachCompanyToItem(param1:ItemObject) : void
      {
         param1.company = this;
         this.displayAppFilter(param1);
      }
      
      public function move(param1:ItemObject, param2:int, param3:int) : void
      {
         this.unregisterItemInArea(param1);
         param1.setWorldPosition(param2,param3,0);
         this.registerItemInArea(param1);
      }
      
      private function nextRentLoad() : void
      {
         this.mNextRentNeedsToBeCalculated = this.isMine();
         this.mNextRentNeedsToIterate = true;
         this.mNextRentPreviousValue = -2;
      }
      
      public function attributesAddValue(param1:String, param2:int, param3:String) : void
      {
         var _loc5_:Dictionary = null;
         var _loc6_:ItemObject = null;
         var _loc4_:Profile = DollarsGame.getProfile();
         if(param3 == ItemDefinition.NAME_TYPES[ItemDefinition.TYPE_DECORATIONS_ID])
         {
            for each(_loc6_ in this.mItemObjects)
            {
               if(_loc6_.hasInfluenceArea())
               {
                  _loc6_.unattachInfluence();
               }
            }
         }
         this.attributesSetChangeNotification(true);
         for each(_loc5_ in this.mAttributesDictionary)
         {
            if(_loc5_[param1] == null)
            {
               _loc5_[param1] = new Dictionary(true);
               _loc5_[param1][ATTRIBUTES_TARGET_ALL] = 0;
            }
            if(_loc5_[param1][param3] == null)
            {
               _loc5_[param1][param3] = 0;
            }
            _loc5_[param1][param3] += param2;
         }
         if(param3 == ItemDefinition.NAME_TYPES[ItemDefinition.TYPE_DECORATIONS_ID])
         {
            for each(_loc6_ in this.mItemObjects)
            {
               if(_loc6_.hasInfluenceArea())
               {
                  _loc6_.attachInfluence();
               }
            }
         }
      }
      
      public function buildUpdate(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ItemObject = null;
         if(Config.SMART_RESOURCE_LOADING)
         {
            _loc2_ = 0;
            for each(_loc3_ in this.mItemObjectToBuild)
            {
               if(_loc3_.isVisible())
               {
                  if(_loc3_.buildUpdate(param1))
                  {
                     _loc2_++;
                     this.mItemObjectToBuild.splice(this.mItemObjectToBuild.indexOf(_loc3_),1);
                  }
                  if(_loc2_ >= MAX_BUILDING_RESOURCES_PER_TICK)
                  {
                     return;
                  }
               }
            }
         }
      }
      
      public function initItemAfterConstruction(param1:ItemObject, param2:Boolean = true) : void
      {
         this.initItemAfterBuying(param1,param2);
      }
      
      public function registerOccurrenceGetAmount(param1:String) : int
      {
         var _loc2_:int = 0;
         if(this.mRegisterOccurrencesDictionary != null && this.mRegisterOccurrencesDictionary[param1] != null)
         {
            _loc2_ = int(this.mRegisterOccurrencesDictionary[param1]);
         }
         return _loc2_;
      }
      
      public function setPersistence(param1:XML, param2:XML = null) : void
      {
         this.mPersistence = param1;
         if(this.isMine() && Config.OPT_USE_BUILD_SHORT_FORMAT)
         {
            this.mPersistenceShortFormat = param2;
         }
         this.mSid = param1.@sid;
         var _loc3_:int = int(param1.@sid);
         if(DollarsGame.smCompanySid <= _loc3_)
         {
            DollarsGame.smCompanySid = _loc3_ + 1;
         }
      }
      
      public function registerOccurrencesRemoveEvent(param1:String) : void
      {
         if(this.mRegisterOccurrencesDictionary[param1] == null)
         {
            this.mRegisterOccurrencesDictionary[param1] = 0;
         }
         --this.mRegisterOccurrencesDictionary[param1];
         if(param1 == REGISTER_OCCURRENCES_ITEM_ON_GET_RENT)
         {
            this.mNextRentNeedsToBeCalculated = true;
         }
      }
      
      public function isCompanyProgressEnabled() : Boolean
      {
         return this.isMine();
      }
      
      private function registerOccurrencesDestroy() : void
      {
         this.mRegisterOccurrencesDictionary = null;
      }
      
      public function showsNotificationConstructionEnd() : Boolean
      {
         return false;
      }
      
      public function attributesLoad() : void
      {
         this.mAttributesDictionary = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < LAYER_COUNT)
         {
            this.mAttributesDictionary.push(new Dictionary(true));
            _loc1_++;
         }
      }
      
      public function getItemBySid(param1:String) : ItemObject
      {
         var _loc4_:* = 0;
         var _loc5_:ItemObject = null;
         var _loc2_:ItemObject = null;
         var _loc3_:* = int(MapDefinition.getInstance().getMapAreaCount() - 1);
         while(_loc3_ > -1 && _loc2_ == null)
         {
            _loc4_ = int(this.mItemObjectsByArea[_loc3_].length - 1);
            while(_loc4_ > -1 && _loc2_ == null)
            {
               _loc5_ = this.mItemObjectsByArea[_loc3_][_loc4_] as ItemObject;
               if(_loc5_.mSid == param1)
               {
                  _loc2_ = _loc5_;
               }
               _loc4_--;
            }
            _loc3_--;
         }
         return _loc2_;
      }
      
      public function getCompanyValuePerPatrimony() : Number
      {
         return this.getCompanyValuePerBuildings() + this.getCompanyValuePerTerrain();
      }
      
      public function isCompanyProgressAppliedToProfileEnabled() : Boolean
      {
         return this.isMine() && this.mWorld.role != null && this.mWorld.role.needsToUpdateProfile();
      }
      
      public function destroy() : void
      {
         var _loc1_:ItemObject = null;
         if(this.mItemObjects != null)
         {
            for each(_loc1_ in this.mItemObjects)
            {
               _loc1_.destroy(false);
            }
         }
         this.mItemObjects = null;
         this.mItemObjectsByArea = null;
         this.mItemObjectsByTypeCount = null;
         this.displayDestroyFilters();
         this.attributesDestroy();
         this.registerOccurrencesDestroy();
         this.progressDestroy();
         this.delayedPaymentDestroy();
      }
      
      public function isAffectedByHQConnection() : Boolean
      {
         return this.world.map.getHQItemObject() != null;
      }
      
      private function delayedPaymentGetCommon(param1:int) : int
      {
         return this.mDelayedPaymentCurrency[param1];
      }
      
      public function delayedPaymentSetGold(param1:int, param2:String = null, param3:String = null, param4:String = null, param5:Boolean = false, param6:int = -1, param7:int = -1) : void
      {
         this.delayedPaymentSetCommon(DELAYED_PAYMENT_GOLD_ID,param1,param2,param3,param4,param5,param6,param7);
      }
   }
}

