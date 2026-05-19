package com.dchoc.dollars.model.profile
{
   import com.dchoc.dollars.GUI.NewsPaper;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupJournal;
   import com.dchoc.dollars.GUI.PopupLevel;
   import com.dchoc.dollars.GUI.hud.Hud;
   import com.dchoc.dollars.GUI.hud.Plot;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.map.tools.Tool;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.services.ServiceDefinition;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.metrics.BAMetrics;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.poll.*;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class Profile extends EventDispatcher
   {
      
      public static var smCashPaidUsed:Boolean;
      
      private static const COMPANY_VALUE_KEY:String = "companyValue";
      
      private static const DCCOINS_KEY:String = "DCCoins";
      
      private static const DCCASH_KEY:String = "DCCash";
      
      private static const DCCASHPAID_KEY:String = "DCCashPaid";
      
      private static const EXP_KEY:String = "exp";
      
      private static const ATTRIBUTES_KEYS:Array = [COMPANY_VALUE_KEY,DCCOINS_KEY,DCCASH_KEY];
      
      public static const BOSS_MALE:int = 0;
      
      public static const BOSS_FEMALE:int = 1;
      
      public static const BOSS_COUNT:int = 2;
      
      public static const MANAGERS_LEVEL:int = 3;
      
      public static const COLLECTIBLES_LEVEL:int = 2;
      
      public static const INVESTMENTS_LEVEL:int = 3;
      
      private static const BONUS_KEYS:Vector.<String> = Vector.<String>([EXP_KEY,DCCOINS_KEY]);
      
      private static const BONUS_KEYS_COUNT:int = BONUS_KEYS.length;
      
      public static const SERVICES_MOVE_SKU:String = "move";
      
      public static const SERVICES_MONEY_COLLECTOR_SKU:String = "moneyCollector";
      
      public static const SERVICES_CONTRACT_SIGNATOR_SKU:String = "contractSignator";
      
      private static const SERVICES_STR_PRESENTATION_SHOWN:String = "PresentationShown";
      
      private static const SERVICES_STR_TIME_LEFT:String = "TimeLeft";
      
      private static const SERVICES_TIME_WARNING_ABOUT_TO_EXPIRE:int = 5000;
      
      private static const SERVICES_TIME_WARNING_HAS_EXPIRED:int = 2000;
      
      private static const SERVICES_STATE_NONE:int = 0;
      
      private static const SERVICES_STATE_NOT_AVAILABLE:int = 1;
      
      private static const SERVICES_STATE_AVAILABLE:int = 2;
      
      private static const SERVICES_STATE_ABOUT_TO_EXPIRE:int = 3;
      
      private static const SERVICES_STATE_HAS_EXPIRED_OFFLINE:int = 4;
      
      public static const REGISTER_EVENT_NPC_INCOME:String = "npcIncome";
      
      private static const FLAGS_USE_COLLECTIBLES_HELP_SHOWN:String = "collectiblesHelpShown2";
      
      private static const FLAGS_USE_COLLECTIBLES_HELP_SHOWN_VERSION_TARGET:int = 1;
      
      private static const FLAGS_USE_INVESTMENT_EXPIRED_REMINDER:String = "investmentExpiredReminder";
      
      private static const FLAGS_USE_INVESTMENT_EXPIRED_VERSION_TARGET:int = 1;
      
      private static const FLAGS_USE_INVESTMENT_ACHIEVED_REMINDER:String = "investmentAchievedReminder";
      
      private static const FLAGS_USE_INVESTMENT_ACHIEVED_VERSION_TARGET:int = 1;
      
      private static const FLAGS_USE_INVESTMENT_HELP_SHOWN:String = "investmentHelpShown";
      
      private static const FLAGS_USE_INVESTMENT_HELP_SHOWN_VERSION_TARGET:int = 1;
      
      private static const FLAGS_USE_INVESTMENT_TOOLBAR_HELP_SHOWN:String = "investmentToolbarHelpShown";
      
      private static const FLAGS_USE_INVESTMENT_TOOLBAR_HELP_SHOWN_VESION_TARGET:int = 1;
      
      private static const FLAGS_USE_DAILY_BONUS_HELP_SHOWN:String = "dailyBonusHelpShown";
      
      private static const FLAGS_USE_DAILY_BONUS_HELP_SHOWN_VESION_TARGET:int = 1;
      
      private static const FLAGS_USE_DAILY_BONUS_CONFIRM_HELP_SHOWN:String = "dailyBonusConfirmHelpShown";
      
      private static const FLAGS_USE_DAILY_BONUS_CONFIRM_HELP_SHOWN_VESION_TARGET:int = 1;
      
      private static const FLAGS_STOP_FIRST_SESSION_POPUPS:String = "stopFirstSessionPopups";
      
      private static const FLAGS_STOP_FIRST_SESSION_POPUPS_VERSION_TARGET:int = 1;
      
      private static const FLAGS_COLLECTIBLES_FIRST_SHOWN:String = "collectiblesFirstShown";
      
      private static const FLAGS_COLLECTIBLES_FIRST_SHOWN_VERSION_TARGET:int = 1;
      
      private static const FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN:String = "collectiblesShopEnhancedShown";
      
      private static const FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN_VERSION_TARGET:int = 1;
      
      private static const FLAGS_COLLECTIBLES_COMMERCE_TAB_FIRST_SHOWN:String = "collectiblesCommerceTabFirstShown";
      
      private static const FLAGS_COLLECTIBLES_COMMERCE_TAB_FIRST_SHOWN_VERSION_TARGET:int = 1;
      
      private static const FLAGS_GRAPHICS:String = "background";
      
      private static const FLAGS_GRAPHICS_NEW:int = 1;
      
      private static const FLAGS_MISSIONS_LAYOUT:String = "missionsLayout";
      
      private static const FLAGS_MISSIONS_LAYOUT_NEW:int = 1;
      
      private static const FLAGS_MISSION_ALT_REWARD:String = "missionAltReward";
      
      private static const FLAGS_MISSION_ALT_REWARD_DEFAULT:int = 0;
      
      private static const FLAGS_ALT_MISSIONS:String = "altMissions";
      
      private static const FLAGS_ALT_MISSIONS_ENABLED:int = 1;
      
      private static const FLAGS_BUY_GOLD_CURRENCY:String = "buyGoldCurrency";
      
      private static const FLAGS_BUY_GOLD_CURRENCY_ENABLED:int = 1;
      
      public var mInvestmentUnlocked:Boolean;
      
      private var mLevelUpShow:Boolean;
      
      private var mIsBuild:Boolean;
      
      private var mFlags:Dictionary;
      
      private var mUpdateCompanyValueEnabled:Boolean;
      
      private var mOwner:int;
      
      private var mServicesServiceDefinitionContracted:Dictionary;
      
      private var mBriefcaseCount:int;
      
      private var mIsMe:Boolean;
      
      private var mOldCursor:int;
      
      private var mNextRentCurrentValue:Number;
      
      private var mServicesNeedsToShowPresentation:Array;
      
      private var mNewToolRev:int;
      
      private var mNewCompanyValue:Number = -1;
      
      private var mOldCompanyValue:Number;
      
      private var mUpdateEnabled:Boolean = true;
      
      private var mServicesOfferEnabled:Array;
      
      private var mManagersActive:Boolean;
      
      private var mRegisterEventsDictionary:Dictionary;
      
      private var mNews:NewsPaper;
      
      private var mIsEnhanced:Boolean = false;
      
      private var mLevelHasChanged:Boolean = false;
      
      private var mPlots:Array;
      
      public var mMillionNewsFeed:Boolean;
      
      private var mServicesTimeLeft:Array;
      
      public var mCollectiblesUnlocked:Boolean;
      
      private var mExpansionsMineCount:int;
      
      private var mServicesTimeLeftNotifications:Array;
      
      private var mServicesLock:Array;
      
      private var mData:Dictionary;
      
      private var mNextRentCurrentItemSid:String;
      
      private var mServicesStates:Array;
      
      private var mNewItemsRev:int;
      
      private const LEVELUP_TIMER:int = 0;
      
      private var mServicesInitialized:Array;
      
      private var mPersistence:XML;
      
      public function Profile(param1:int = -1, param2:Boolean = false)
      {
         super();
         this.mOwner = param1;
         this.mIsMe = param2;
         this.mIsBuild = false;
         this.load();
      }
      
      public static function bonusKeyIsAllowed(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < BONUS_KEYS_COUNT && !_loc2_)
         {
            _loc2_ = BONUS_KEYS[_loc3_] == param1;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function collectiblesGetFirstShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_COLLECTIBLES_FIRST_SHOWN) >= FLAGS_COLLECTIBLES_FIRST_SHOWN_VERSION_TARGET;
      }
      
      public function servicesGetServiceDefinitionContracted(param1:String) : ServiceDefinition
      {
         return this.mServicesServiceDefinitionContracted[param1];
      }
      
      public function get HQLevel() : uint
      {
         return this.mData["HQLevel"];
      }
      
      public function altMissionsGet() : Boolean
      {
         return this.flagsGetValue(FLAGS_ALT_MISSIONS) == FLAGS_ALT_MISSIONS_ENABLED;
      }
      
      public function investmentAchivievedGetReminderShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_USE_INVESTMENT_ACHIEVED_REMINDER) >= FLAGS_USE_INVESTMENT_ACHIEVED_VERSION_TARGET;
      }
      
      public function collectiblesSetFirstShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_COLLECTIBLES_FIRST_SHOWN,FLAGS_COLLECTIBLES_FIRST_SHOWN_VERSION_TARGET);
      }
      
      private function flagsLoad() : void
      {
         this.mFlags = new Dictionary(true);
      }
      
      private function flagsToString() : String
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc1_:String = "";
         for(_loc2_ in this.mFlags)
         {
            _loc3_ = int(this.mFlags[_loc2_]);
            if(_loc3_ > 0)
            {
               _loc1_ += _loc2_ + ":" + _loc3_ + ",";
            }
         }
         return _loc1_;
      }
      
      public function bonusArrayApply(param1:Array) : void
      {
         var _loc2_:Array = null;
         for each(_loc2_ in param1)
         {
            this.bonusApply(_loc2_[0],_loc2_[1],false);
         }
         this.update();
      }
      
      public function get bossGenre() : int
      {
         return this.mData["bossGenre"];
      }
      
      public function newGraphicsSet(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_GRAPHICS,int(param1));
      }
      
      public function get maxExp() : Number
      {
         return this.mData["maxExp"];
      }
      
      public function registerEventsGet(param1:String) : int
      {
         var _loc2_:int = 0;
         if(this.mRegisterEventsDictionary != null)
         {
            if(this.mRegisterEventsDictionary[param1] == null)
            {
               if(Config.DEBUG_ASSERTS)
               {
                  Debug.trace("############# ERROR in Profile.registerEventsGet: Not value found for sku = " + param1);
               }
            }
            else
            {
               _loc2_ = int(this.mRegisterEventsDictionary[param1]);
            }
         }
         return _loc2_;
      }
      
      public function investmentGetHelpShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_USE_INVESTMENT_HELP_SHOWN) >= FLAGS_USE_INVESTMENT_HELP_SHOWN_VERSION_TARGET;
      }
      
      public function get exp() : Number
      {
         return this.mData["exp"];
      }
      
      public function setDCCashPaid(param1:uint) : void
      {
         this.mData[DCCASHPAID_KEY] = param1;
      }
      
      public function setDCCoins(param1:Number) : void
      {
         this.mData[DCCOINS_KEY] = param1;
         if(this.mIsMe)
         {
            this.eventCheck(DCCOINS_KEY);
         }
      }
      
      private function checkNextLevel(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupLevel.removeEventListener(Popup.EVENT_CLOSE,this.checkNextLevel);
         DollarsGame.smInstance.mPopupLevel.destroy();
         DollarsGame.smInstance.mPopupLevel = null;
         if(this.exp >= this.maxExp)
         {
            this.levelUp();
            this.update();
         }
         else
         {
            this.mLevelUpShow = false;
            Dollars.getCurrentCursor().changeCursor(this.mOldCursor);
         }
      }
      
      public function get newToolRev() : int
      {
         return this.mNewToolRev;
      }
      
      public function set bossGenre(param1:int) : void
      {
         this.mData["bossGenre"] = param1;
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("boss_genre",{"value":this.mData["bossGenre"]});
         }
      }
      
      public function missionsLayoutSet(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_MISSIONS_LAYOUT,int(param1));
      }
      
      public function set maxExp(param1:Number) : void
      {
         this.mData["maxExp"] = param1;
      }
      
      public function setFacebookCredits(param1:int, param2:int = 0) : void
      {
         this.mData["facebookCredits"] = param1;
         this.mData["facebookCreditsNotSpent"] = param2;
         this.mData["facebookCreditsUpdated"] = true;
         this.update();
      }
      
      public function set exp(param1:Number) : void
      {
         var _loc2_:Number = this.exp;
         this.setExp(param1);
         var _loc3_:Number = RulesFacade.getLevelXP(6) + (RulesFacade.getLevelXP(7) - RulesFacade.getLevelXP(6)) / 2;
         if(this.exp >= _loc3_ && _loc2_ < _loc3_ && this.mNews == null)
         {
            this.mNews = new NewsPaper(PopupJournal.TYPE_NEWS);
            Dollars.smStage.addEventListener(DollarsGame.EVENT_FULLSCREEN,this.onResize);
            this.mNews.start();
            this.mNews.addEventListener(Popup.EVENT_CLOSE,this.onCloseNewspaper);
         }
         if(this.exp >= this.maxExp && !this.mLevelUpShow)
         {
            this.mOldCursor = Dollars.getCurrentCursor().mCurrentCursorID;
            this.update();
            this.mLevelUpShow = true;
         }
         this.update();
      }
      
      public function getBreakIncomeTimePercentage() : int
      {
         return RulesFacade.getLevelBreakIncomeTimePercentage(this.level);
      }
      
      public function set planeSku(param1:String) : void
      {
         this.mData["planeSku"] = param1;
      }
      
      public function exchangeDone(param1:int) : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateMoney("exchange",{"value":param1});
         }
      }
      
      public function servicesGetIdFromSku(param1:String) : int
      {
         return ServiceDefinitionManager.getInstance().getIdFromTypeSku(param1);
      }
      
      public function isNewItem() : Boolean
      {
         return this.mNewItemsRev < RulesFacade.getInstance().newItemsRev();
      }
      
      public function newToolRevDone() : void
      {
         UserDataFacade.getInstance().updateProfile("newToolRev",{"value":this.newToolRev});
      }
      
      public function dailyBonusGetHelpShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_USE_DAILY_BONUS_HELP_SHOWN) >= FLAGS_USE_DAILY_BONUS_HELP_SHOWN_VESION_TARGET;
      }
      
      public function get bookmarked() : Boolean
      {
         return this.mData["bookmark"];
      }
      
      public function set newToolRev(param1:int) : void
      {
         this.mNewToolRev = param1;
      }
      
      public function get DCCash() : uint
      {
         return this.mData[DCCASH_KEY];
      }
      
      public function setExp(param1:Number) : void
      {
         this.mData["exp"] = param1;
      }
      
      public function isExpansionAreaMine(param1:int) : Boolean
      {
         return this.isExpansionAreaType(param1,Plot.TYPE_FULL);
      }
      
      public function get updateCompanyValue() : Boolean
      {
         return this.mNewCompanyValue != -1;
      }
      
      public function firstMissionDone() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("firstMission",{"value":0});
         }
      }
      
      public function hasGivenEmail() : Boolean
      {
         return this.checkmail != "0";
      }
      
      private function servicesLoad() : void
      {
         var _loc1_:int = ServiceDefinitionManager.getInstance().getDefinitionsCount();
         this.mServicesServiceDefinitionContracted = new Dictionary(true);
         this.mServicesTimeLeft = new Array(_loc1_);
         this.mServicesStates = new Array(_loc1_);
         this.mServicesLock = new Array(_loc1_);
         this.mServicesTimeLeftNotifications = new Array(_loc1_);
         this.mServicesInitialized = new Array(_loc1_);
         this.mServicesNeedsToShowPresentation = new Array(_loc1_);
         this.mServicesOfferEnabled = new Array(_loc1_);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this.mServicesOfferEnabled[_loc2_] = false;
            _loc2_++;
         }
      }
      
      public function get isMe() : Boolean
      {
         return this.mIsMe;
      }
      
      public function get minExp() : Number
      {
         return this.mData["minExp"];
      }
      
      public function setStopPopupFirstSessionPopups(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_STOP_FIRST_SESSION_POPUPS,FLAGS_STOP_FIRST_SESSION_POPUPS_VERSION_TARGET);
      }
      
      public function build(param1:Boolean = true) : void
      {
         if(param1)
         {
            this.level = 0;
            while(this.level < RulesFacade.maxLevel)
            {
               if(this.exp < RulesFacade.getLevelXP(this.level))
               {
                  this.minExp = RulesFacade.getLevelXP(this.level - 1);
                  this.maxExp = RulesFacade.getLevelXP(this.level);
                  break;
               }
               ++this.level;
            }
            MissionObjectManager.getInstance().build();
            PollManager.getInstance().build();
            this.update();
         }
         else
         {
            this.eventsBuild();
         }
         this.mIsBuild = true;
      }
      
      public function get cityname() : String
      {
         return this.mData["cityname"];
      }
      
      public function get rankingPos() : int
      {
         return this.mData["ranking"];
      }
      
      public function get firstVisit() : Boolean
      {
         return this.mData["firstVisit"];
      }
      
      public function set rankingPos(param1:int) : void
      {
         this.mData["ranking"] = param1;
      }
      
      public function servicesSetLock(param1:String, param2:Boolean) : void
      {
         var _loc3_:int = this.servicesGetIdFromSku(param1);
         if(_loc3_ != -1)
         {
            this.mServicesLock[_loc3_] = param2;
         }
      }
      
      public function servicesCancel(param1:String) : void
      {
         var _loc2_:int = int((this.mServicesServiceDefinitionContracted[param1] as ServiceDefinition).type);
         this.servicesChangeState(param1,_loc2_,SERVICES_STATE_NOT_AVAILABLE);
         this.mServicesServiceDefinitionContracted[param1] = null;
         Debug.trace("############# SERVICE: cancel CONTRACT server call in Profile.servicesCancel() method sku = " + param1 + " cash = " + this.DCCash + " coins = " + this.DCCoins);
      }
      
      public function investmentSetHelpShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_USE_INVESTMENT_HELP_SHOWN,FLAGS_USE_INVESTMENT_HELP_SHOWN_VERSION_TARGET);
      }
      
      public function get briefcaseCount() : int
      {
         return this.mBriefcaseCount;
      }
      
      public function getExpansionCount() : int
      {
         return this.mExpansionsMineCount;
      }
      
      private function servicesLogicUpdate(param1:int) : void
      {
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:ServiceDefinition = null;
         var _loc9_:Number = NaN;
         var _loc2_:ServiceDefinitionManager = ServiceDefinitionManager.getInstance();
         var _loc3_:Array = _loc2_.getTypeSkus();
         var _loc4_:int = int(_loc3_.length);
         var _loc5_:int = 0;
         for(; _loc5_ < _loc4_; _loc5_++)
         {
            if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
            {
               if(this.mServicesInitialized[_loc5_])
               {
                  this.mServicesInitialized[_loc5_] = false;
               }
               continue;
            }
            _loc6_ = _loc3_[_loc5_];
            if(!_loc2_.hasTimeAvailable(_loc6_))
            {
               continue;
            }
            if(this.mServicesStates[_loc5_] == SERVICES_STATE_NOT_AVAILABLE)
            {
               continue;
            }
            _loc7_ = this.servicesGetTimeLeft(_loc6_,_loc5_,false);
            if(!this.mServicesInitialized[_loc5_])
            {
               this.mServicesInitialized[_loc5_] = true;
               if(_loc7_ <= 0 && this.servicesIsAvailable(_loc6_,_loc5_))
               {
                  this.servicesChangeState(_loc6_,_loc5_,SERVICES_STATE_HAS_EXPIRED_OFFLINE);
               }
            }
            _loc8_ = ServiceDefinitionManager.getInstance().getServiceDefinition(_loc6_) as ServiceDefinition;
            _loc9_ = _loc8_.getTimeExtra();
            if(this.mServicesStates[_loc5_] == SERVICES_STATE_ABOUT_TO_EXPIRE && _loc9_ > 0 && _loc7_ < -_loc9_)
            {
               this.servicesChangeState(_loc6_,_loc5_,SERVICES_STATE_NOT_AVAILABLE);
               break;
            }
            if(this.servicesIsDone(_loc6_,_loc5_))
            {
               this.mServicesTimeLeftNotifications[_loc5_] -= param1;
               if(this.mServicesTimeLeftNotifications[_loc5_] <= 0)
               {
                  if(this.mServicesLock[_loc5_])
                  {
                     this.mServicesTimeLeftNotifications[_loc5_] = 1;
                  }
                  else
                  {
                     this.mServicesTimeLeftNotifications[_loc5_] = 0;
                     this.servicesChangeState(_loc6_,_loc5_,SERVICES_STATE_NOT_AVAILABLE);
                  }
               }
               continue;
            }
            switch(this.mServicesStates[_loc5_])
            {
               case SERVICES_STATE_AVAILABLE:
                  if(_loc7_ < SERVICES_TIME_WARNING_ABOUT_TO_EXPIRE)
                  {
                     this.mServicesTimeLeftNotifications[_loc5_] = SERVICES_TIME_WARNING_ABOUT_TO_EXPIRE;
                     this.servicesChangeState(_loc6_,_loc5_,SERVICES_STATE_ABOUT_TO_EXPIRE);
                  }
            }
         }
      }
      
      public function tutorialCompleted() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("tutorial_completed",{});
         }
      }
      
      public function bonusApply(param1:String, param2:Number, param3:Boolean = true) : void
      {
         this.mData[param1] += param2;
         if(param3)
         {
            this.update();
         }
      }
      
      public function servicesNeedsToShowPresentation(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = this.servicesGetIdFromSku(param1);
         if(Config.DEBUG_ASSERTS && _loc3_ == -1)
         {
            Debug.trace("############# ERROR in Profile.servicesNeedsToShowPresentation(): Index not found for sku = " + param1);
         }
         else
         {
            _loc2_ = Boolean(this.mServicesNeedsToShowPresentation[_loc3_]);
         }
         return _loc2_;
      }
      
      public function getOldCompanyValue() : Number
      {
         return this.mOldCompanyValue;
      }
      
      private function eventCheck(param1:String) : void
      {
         var _loc2_:PollEvent = PollManager.getInstance().getEvent(MissionsEventIDs.MISSION_EVENT_EARN + param1);
         if(_loc2_ != null && _loc2_.needsToBeChecked())
         {
            _loc2_.checkCondition(this.mData[param1]);
         }
         if(param1 == COMPANY_VALUE_KEY)
         {
            _loc2_ = PollManager.getInstance().getEvent(MissionsEventIDs.MISSION_EVENT_BEAT);
            if(_loc2_ != null && _loc2_.needsToBeChecked())
            {
               _loc2_.checkCondition(this.mData[param1]);
            }
         }
      }
      
      public function setServicesIsOfferEnabled(param1:String, param2:Boolean) : void
      {
         var _loc3_:int = this.servicesGetIdFromSku(param1);
         if(_loc3_ != -1)
         {
            this.mServicesOfferEnabled[_loc3_] = param2;
         }
      }
      
      public function setCompanyValue(param1:Number) : void
      {
         if(this.mUpdateCompanyValueEnabled)
         {
            this.mOldCompanyValue = this.companyValue;
            this.mNewCompanyValue = param1;
            if(param1 > 4000000 && !this.fourMillions)
            {
               this.fourMillions = true;
               this.fourMillionsDone();
               MyMetrics.sendMetric(MetricConstants.EVENT_INVESTMENTS,MetricConstants.LABEL_INVEST_4MM);
            }
         }
      }
      
      public function firstVisitDone() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateMoney("first_visit",{"value":1});
         }
      }
      
      private function registerEventsLoad() : void
      {
         if(this.registerEventsIsAllowed())
         {
            this.mRegisterEventsDictionary = new Dictionary(true);
         }
      }
      
      public function investmentAchivievedSetReminderShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_USE_INVESTMENT_ACHIEVED_REMINDER,FLAGS_USE_INVESTMENT_ACHIEVED_VERSION_TARGET);
      }
      
      public function newItemsRevDone() : void
      {
         UserDataFacade.getInstance().updateProfile("newItemsRevDone",{});
      }
      
      public function set bookmarked(param1:Boolean) : void
      {
         this.mData["bookmark"] = param1;
      }
      
      public function set DCCash(param1:uint) : void
      {
         var _loc2_:int = param1 - this.DCCash;
         this.setCompanyValue(this.companyValue + _loc2_ * RulesFacade.getDCCashToDCCoins());
         this.setDCCash(param1);
         this.update();
         smCashPaidUsed = _loc2_ < 0 && this.mData[DCCASHPAID_KEY] > 0;
         if(smCashPaidUsed)
         {
            this.mData[DCCASHPAID_KEY] = Math.max(0,this.mData[DCCASHPAID_KEY] + _loc2_);
         }
      }
      
      public function servicesGetTimeLeft(param1:String, param2:int = -1, param3:Boolean = true) : Number
      {
         if(param2 == -1)
         {
            param2 = this.servicesGetIdFromSku(param1);
         }
         var _loc4_:Number = 0;
         if(param2 != -1)
         {
            _loc4_ = this.mServicesTimeLeft[param2] - UserDataFacade.getInstance().timerGetTimeSinceLogin();
            if(param3 && _loc4_ < 0)
            {
               _loc4_ = 0;
            }
         }
         return _loc4_;
      }
      
      public function servicesBuild() : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:XMLList = null;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:ServiceDefinition = null;
         var _loc10_:String = null;
         var _loc1_:Array = ServiceDefinitionManager.getInstance().getTypeSkus();
         var _loc2_:int = 0;
         for each(_loc3_ in _loc1_)
         {
            _loc4_ = _loc3_ + SERVICES_STR_TIME_LEFT;
            _loc5_ = this.mPersistence.attribute(_loc4_);
            _loc6_ = SERVICES_STATE_NOT_AVAILABLE;
            _loc7_ = 0;
            if(_loc5_.length() > 0)
            {
               _loc7_ = Number(_loc5_[0]);
               if(_loc7_ == 0)
               {
                  _loc6_ = SERVICES_STATE_HAS_EXPIRED_OFFLINE;
                  this.mServicesOfferEnabled[_loc2_] = true;
               }
               else if(_loc7_ > SERVICES_TIME_WARNING_ABOUT_TO_EXPIRE)
               {
                  if(_loc7_ > SERVICES_TIME_WARNING_ABOUT_TO_EXPIRE)
                  {
                     _loc7_ += UserDataFacade.getInstance().timerGetTimeSinceLogin();
                  }
                  _loc6_ = SERVICES_STATE_AVAILABLE;
               }
               else if(_loc7_ > 0)
               {
                  _loc6_ = SERVICES_STATE_AVAILABLE;
               }
            }
            this.mServicesTimeLeft[_loc2_] = _loc7_;
            this.servicesChangeState(_loc3_,_loc2_,_loc6_);
            this.mServicesLock[_loc2_] = false;
            this.mServicesInitialized[_loc2_] = false;
            _loc4_ = _loc3_ + SERVICES_STR_PRESENTATION_SHOWN;
            _loc5_ = this.mPersistence.attribute(_loc4_);
            _loc8_ = 0;
            if(_loc5_.length() > 0)
            {
               _loc8_ = int(_loc5_[0]);
            }
            this.mServicesNeedsToShowPresentation[_loc2_] = _loc8_ == 0;
            _loc9_ = ServiceDefinitionManager.getInstance().getServiceLockable(this.servicesGetIdFromSku(_loc3_));
            if(_loc9_ != null)
            {
               _loc10_ = _loc3_ + "_3";
               _loc4_ = _loc10_ + "TimeLeft";
               _loc5_ = this.mPersistence.attribute(_loc4_);
               if(_loc5_.length() > 0)
               {
                  _loc9_.setWaitingTimeLeft(Number(_loc5_[0]));
               }
               _loc4_ = _loc10_ + "UsesCount";
               _loc5_ = this.mPersistence.attribute(_loc4_);
               if(_loc5_.length() > 0)
               {
                  _loc9_.setUsesCount(int(_loc5_[0]));
               }
            }
            _loc2_++;
         }
      }
      
      public function collectiblesGetHelpShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_USE_COLLECTIBLES_HELP_SHOWN) >= FLAGS_USE_COLLECTIBLES_HELP_SHOWN_VERSION_TARGET;
      }
      
      public function collectiblesShopGetEnhancedShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN) >= FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN_VERSION_TARGET && this.mIsEnhanced;
      }
      
      public function get owner() : int
      {
         return this.mOwner;
      }
      
      public function checkLevelUpShow() : void
      {
         if(this.mLevelUpShow)
         {
            this.mLevelUpShow = false;
            this.levelUp();
         }
      }
      
      public function nextRentUpdate(param1:Number, param2:ItemObject) : void
      {
         var _loc3_:Boolean = false;
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
         {
            _loc3_ = false;
            if(this.mNextRentCurrentValue > 0)
            {
               _loc3_ = this.mNextRentCurrentItemSid == null || param2 == null || param2.mSid != this.mNextRentCurrentItemSid;
            }
            else
            {
               _loc3_ = this.mNextRentCurrentValue != param1;
            }
            this.mNextRentCurrentValue = param1;
            if(param2 == null)
            {
               this.mNextRentCurrentItemSid = null;
            }
            else
            {
               this.mNextRentCurrentItemSid = param2.mSid;
            }
            if(_loc3_)
            {
               param1 = this.mNextRentCurrentValue;
               if(param1 > 0)
               {
                  param1 /= 1000;
               }
               UserDataFacade.getInstance().updateNextRent("update_next_rent",{"next_rent":int(param1)});
            }
         }
      }
      
      public function missionAltRewardSet(param1:int) : void
      {
         this.flagsSetValue(FLAGS_MISSION_ALT_REWARD,param1);
      }
      
      public function investmentGetToolbarHelpShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_USE_INVESTMENT_TOOLBAR_HELP_SHOWN) >= FLAGS_USE_INVESTMENT_TOOLBAR_HELP_SHOWN_VESION_TARGET;
      }
      
      public function buyGoldCurrencySet(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_BUY_GOLD_CURRENCY,int(param1));
      }
      
      public function dailyBonusSetHelpShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_USE_DAILY_BONUS_HELP_SHOWN,FLAGS_USE_DAILY_BONUS_HELP_SHOWN_VESION_TARGET);
      }
      
      public function get firstMission() : Boolean
      {
         return this.mData["firstMission"];
      }
      
      private function flagsRead(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc2_:Array = param1.split(",");
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_ != "")
            {
               _loc4_ = _loc3_.split(":");
               if(_loc4_.length == 1)
               {
                  this.mFlags[_loc3_] = 1;
               }
               else
               {
                  this.mFlags[_loc4_[0]] = int(_loc4_[1]);
               }
            }
         }
         if(this.buyGoldCurrencyGet())
         {
            Config.FACEBOOK_CREDITS_AS_CURRENCY = false;
         }
      }
      
      private function registerEventsDestroy() : void
      {
         this.mRegisterEventsDictionary = null;
      }
      
      public function get checkmail() : String
      {
         return this.mData["checkmail"];
      }
      
      public function get DCCoins() : Number
      {
         return this.mData[DCCOINS_KEY];
      }
      
      public function get firstInvest() : Boolean
      {
         return this.mData["firstInvest"];
      }
      
      public function update() : void
      {
         if(this.mUpdateEnabled)
         {
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function get fourMillions() : Boolean
      {
         return this.mData["fourMillions"];
      }
      
      public function isNewTool() : Boolean
      {
         return DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER && this.mNewToolRev < RulesFacade.getInstance().newToolRev();
      }
      
      public function get newItemRev() : int
      {
         return this.mNewItemsRev;
      }
      
      private function eventsBuild() : void
      {
         var _loc1_:String = null;
         if(this.mIsMe)
         {
            for each(_loc1_ in ATTRIBUTES_KEYS)
            {
               this.eventCheck(_loc1_);
            }
         }
      }
      
      public function set minExp(param1:Number) : void
      {
         this.mData["minExp"] = param1;
      }
      
      public function setPersistence(param1:XML, param2:Boolean = true) : void
      {
         var _loc3_:RulesFacade = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         this.mPersistence = param1;
         if(param2)
         {
            if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
            {
               if("@tutorialEnd" in param1)
               {
                  Tutorial.smTutorialEnd = param1.@tutorialEnd == 1;
               }
            }
            else
            {
               Tutorial.smTutorialEnd = true;
               Tutorial.smRoadMsgShown = true;
               Tutorial.smManagersMsgShown = true;
            }
         }
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_EDITOR)
         {
            this.setExp(Number.MAX_VALUE);
            this.setDCCash(int.MAX_VALUE);
            this.setDCCoins(Number.MAX_VALUE);
            this.setCompanyValue(Number.MAX_VALUE);
         }
         else
         {
            this.setExp(param1.@exp);
            if(Tutorial.smTutorialEnd)
            {
               this.setDCCoins(param1.@DCCoins);
               this.setDCCash(param1.@DCCash);
               this.setDCCashPaid(param1.@DCCashPaid);
            }
            else
            {
               _loc3_ = RulesFacade.getInstance();
               this.setDCCoins(_loc3_.settingsGetInitialDCCoins());
               this.setDCCash(_loc3_.settingsGetInitialDCCash());
               this.setDCCashPaid(0);
            }
            if("@investmentInMeTimeLeft" in param1)
            {
               this.investmentInMeTimeLeft = Number(param1.@investmentInMeTimeLeft);
            }
            if("@investmentInMeUserId" in param1)
            {
               this.investmentInMeUserId = int(param1.@investmentInMeUserId);
            }
            if("@investmentInMeExtId" in param1)
            {
               this.investmentInMeExtId = String(param1.@investmentInMeExtId);
            }
            if("@flags" in param1)
            {
               this.flagsRead(param1.@flags);
            }
            if("@firstInvest" in param1)
            {
               this.firstInvest = Boolean(int(param1.@firstInvest));
            }
            else
            {
               this.firstInvest = false;
            }
            if("@firstVisit" in param1)
            {
               this.firstVisit = Boolean(int(param1.@firstVisit));
            }
            else
            {
               this.firstVisit = false;
            }
            if("@newItemsRevDone" in param1)
            {
               this.mNewItemsRev = int(param1.@newItemsRevDone);
            }
            else
            {
               this.mNewItemsRev = 0;
            }
            if("@newToolRev" in param1)
            {
               this.mNewToolRev = int(param1.@newToolRev);
            }
            else
            {
               this.mNewToolRev = 0;
            }
            if(!Tutorial.smTutorialEnd)
            {
               this.mNewToolRev = RulesFacade.getInstance().newToolRev();
               this.newToolRevDone();
            }
            if("@cityNameCodes" in param1)
            {
               _loc4_ = param1.@cityNameCodes;
               _loc5_ = _loc4_.split(",");
               _loc6_ = "";
               for each(_loc7_ in _loc5_)
               {
                  _loc6_ += String.fromCharCode(int(_loc7_));
               }
               this.cityname = _loc6_;
            }
            else if("@cityname" in param1)
            {
               this.cityname = param1.@cityname;
            }
            else
            {
               this.cityname = TextManager.getText(TextIDs.TID_INITIAL_CITY_NAME);
            }
            if("@checkmail" in param1)
            {
               this.checkmail = param1.@checkmail;
            }
            else
            {
               this.checkmail = "0";
            }
            this.mOldCompanyValue = Number(param1.@companyValue);
            this.mMillionNewsFeed = false;
            if(int(param1.@millionNewsFeed) == 1)
            {
               this.mMillionNewsFeed = true;
            }
            this.rankingPos = int(param1.@ranking);
            if("@bossGenre" in param1 && Tutorial.smTutorialEnd)
            {
               this.bossGenre = int(param1.@bossGenre);
            }
            if("@firstPartner" in param1)
            {
               this.firstPartner = Boolean(int(param1.@firstPartner));
            }
            if("@fourMillions" in param1)
            {
               this.fourMillions = Boolean(int(param1.@fourMillions));
            }
            if("@firstMission" in param1)
            {
               this.firstMission = Boolean(int(param1.@firstMission));
            }
            else
            {
               this.firstMission = true;
            }
            if("@planeSku" in param1)
            {
               this.planeSku = param1.@planeSku;
            }
            else
            {
               this.planeSku = "plain";
            }
            this.mBriefcaseCount = 0;
            if("@bfcCnt" in param1)
            {
               _loc8_ = param1.@bfcCnt;
               _loc9_ = _loc8_.split(",");
               for each(_loc10_ in _loc9_)
               {
                  _loc11_ = _loc10_.split(":");
                  FreeGiftDefinitionManager.getInstance().setSequencePosition(_loc11_[0],int(_loc11_[1]));
               }
            }
         }
         if(!Tutorial.smTutorialEnd)
         {
            this.companyValue = this.DCCoins + this.DCCash * RulesFacade.getDCCashToDCCoins();
            this.rankingPos = -1;
         }
         if(param2)
         {
            MissionObjectManager.getInstance().setPersistence(XMLUtil.XMLListToXML(param1.Missions));
            PollManager.getInstance().setPersistence(XMLUtil.XMLListToXML(param1.PollManager));
         }
         this.plotsSetPersistence(XMLUtil.XMLListToXML(param1.Plots));
      }
      
      public function getStopPopupFirstSessionPopups() : Boolean
      {
         return this.flagsGetValue(FLAGS_STOP_FIRST_SESSION_POPUPS) >= FLAGS_STOP_FIRST_SESSION_POPUPS_VERSION_TARGET;
      }
      
      private function registerEventsIsAllowed() : Boolean
      {
         return this.mIsMe;
      }
      
      public function set facebookCreditsNotSpent(param1:int) : void
      {
         this.mData["facebookCreditsNotSpent"] = param1;
         this.mData["facebookCreditsUpdated"] = true;
         this.update();
      }
      
      private function load() : void
      {
         this.mData = new Dictionary();
         this.level = 1;
         this.minExp = 0;
         this.maxExp = RulesFacade.getLevelXP(this.level - 1);
         this.servicesLoad();
         this.registerEventsLoad();
         this.nextRentLoad();
         this.flagsLoad();
      }
      
      public function set cityname(param1:String) : void
      {
         this.mData["cityname"] = param1;
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("city_name",{"value":this.mData["cityname"]});
         }
      }
      
      public function set investmentInMeUserId(param1:int) : void
      {
         this.mData["investmentInMeUserId"] = param1;
      }
      
      public function get companyValue() : Number
      {
         var _loc1_:Number = this.mNewCompanyValue;
         if(_loc1_ == -1)
         {
            _loc1_ = Number(this.mData[COMPANY_VALUE_KEY]);
         }
         return _loc1_;
      }
      
      public function setUpdateEnabled(param1:Boolean) : void
      {
         this.mUpdateEnabled = param1;
      }
      
      public function get facebookCredits() : int
      {
         return this.mData["facebookCredits"];
      }
      
      public function set firstVisit(param1:Boolean) : void
      {
         this.mData["firstVisit"] = param1;
      }
      
      public function investmentExpiredGetReminderShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_USE_INVESTMENT_EXPIRED_REMINDER) >= FLAGS_USE_INVESTMENT_EXPIRED_VERSION_TARGET;
      }
      
      public function set level(param1:uint) : void
      {
         this.mData["level"] = param1;
         this.update();
         this.mManagersActive = param1 >= MANAGERS_LEVEL;
         this.mLevelHasChanged = true;
      }
      
      public function set briefcaseCount(param1:int) : void
      {
         this.mBriefcaseCount = param1;
      }
      
      public function newGraphicsGet() : Boolean
      {
         return this.flagsGetValue(FLAGS_GRAPHICS) == FLAGS_GRAPHICS_NEW;
      }
      
      public function set isFan(param1:Boolean) : void
      {
         this.mData["fan"] = param1;
      }
      
      public function dailyBonusConfirmGetHelpShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_USE_DAILY_BONUS_CONFIRM_HELP_SHOWN) >= FLAGS_USE_DAILY_BONUS_CONFIRM_HELP_SHOWN_VESION_TARGET;
      }
      
      public function altMissionsSet(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_ALT_MISSIONS,int(param1));
      }
      
      public function get planeSku() : String
      {
         return this.mData["planeSku"];
      }
      
      public function getBreakMaxItems(param1:int) : int
      {
         return RulesFacade.getLevelBreakMaxItems(this.level,param1);
      }
      
      public function collectiblesShopSetEnhancedShown(param1:Boolean) : void
      {
         this.mIsEnhanced = param1;
         if(!this.flagsGetValue(FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN) >= FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN_VERSION_TARGET)
         {
            this.flagsSetValue(FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN,FLAGS_COLLECTIBLES_SHOP_ENHANCED_GET_BUTTON_SHOWN_VERSION_TARGET);
         }
      }
      
      public function get facebookCreditsUpdated() : Boolean
      {
         return this.mData["facebookCreditsUpdated"];
      }
      
      public function collectiblesSetHelpShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_USE_COLLECTIBLES_HELP_SHOWN,FLAGS_USE_COLLECTIBLES_HELP_SHOWN_VERSION_TARGET);
      }
      
      private function plotsSetPersistence(param1:XML) : void
      {
         var _loc4_:RulesFacade = null;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc2_:String = param1.@type;
         var _loc3_:Array = new Array();
         if(_loc2_ == "")
         {
            _loc4_ = RulesFacade.getInstance();
            _loc5_ = int(_loc4_.expansionsGetPlotsCount() - 1);
            while(_loc5_ > -1)
            {
               _loc3_.push(Plot.TYPE_LOCKED);
               _loc5_--;
            }
            _loc6_ = 0;
            _loc7_ = _loc4_.expansionsGetPlotIndicesByUnlockOrder(_loc6_);
            for each(_loc8_ in _loc7_)
            {
               _loc3_[_loc8_] = Plot.TYPE_FULL;
            }
            _loc6_++;
            _loc7_ = _loc4_.expansionsGetPlotIndicesByUnlockOrder(_loc6_);
            for each(_loc8_ in _loc7_)
            {
               _loc3_[_loc8_] = Plot.TYPE_NORMAL;
            }
         }
         else
         {
            _loc9_ = _loc2_.split(",");
            for each(_loc10_ in _loc9_)
            {
               _loc3_.push(int(_loc10_));
            }
         }
         this.plots = _loc3_;
      }
      
      public function setDCCash(param1:uint) : void
      {
         this.mData[DCCASH_KEY] = param1;
         if(this.mIsMe)
         {
            this.eventCheck(DCCASH_KEY);
         }
      }
      
      public function collectiblesCommmerceTabGetFirstShown() : Boolean
      {
         return this.flagsGetValue(FLAGS_COLLECTIBLES_COMMERCE_TAB_FIRST_SHOWN) >= FLAGS_COLLECTIBLES_COMMERCE_TAB_FIRST_SHOWN_VERSION_TARGET;
      }
      
      public function isExpansionAreaType(param1:int, param2:int) : Boolean
      {
         return this.mPlots[param1] == param2;
      }
      
      public function missionsLayoutGet() : Boolean
      {
         return this.flagsGetValue(FLAGS_MISSIONS_LAYOUT) == FLAGS_MISSIONS_LAYOUT_NEW;
      }
      
      public function levelUp() : void
      {
         var _loc1_:int = RulesFacade.getLevelDCCashLevelUp(this.level);
         DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash + RulesFacade.getLevelDCCashLevelUp(this.level - 1);
         ++this.level;
         if(this.level == 2)
         {
            MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_LEVEL_2);
            if(Config.BA_ENABLED)
            {
               BAMetrics.getInstance().registerEvent("newUsers","Level2Reached");
            }
         }
         if(this.level == RulesFacade.getInstance().settingsGetCollectiblesUnlockLevel())
         {
            this.mCollectiblesUnlocked = true;
         }
         if(this.level == RulesFacade.getInstance().settingsGetInvestmentsUnlockLevel())
         {
            this.mInvestmentUnlocked = true;
         }
         this.minExp = this.maxExp;
         this.maxExp = RulesFacade.getLevelXP(this.level);
         this.update();
         ItemDefinitionManager.getInstance().requestLoadResourcesWithConditions(true,this.level + 1,this.level + 1);
         DollarsGame.smInstance.mPopupLevel = new PopupLevel();
         DollarsGame.smInstance.mPopupLevel.showPopup();
         DollarsGame.smInstance.mPopupLevel.addEventListener(Popup.EVENT_CLOSE,this.checkNextLevel);
      }
      
      private function onCloseNewspaper(param1:Event) : void
      {
         this.mNews.removeEventListener(Popup.EVENT_CLOSE,this.onCloseNewspaper);
         Dollars.smStage.removeEventListener(DollarsGame.EVENT_FULLSCREEN,this.onResize);
         this.mNews.destroy();
         this.mNews = null;
         PriorityLoader.getInstance().unload(NewsPaper.SKU);
      }
      
      public function firstMissionToDo() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("firstMission",{"value":1});
         }
      }
      
      public function getCompanyValuePerExpansions() : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.mExpansionsMineCount)
         {
            _loc3_ = RulesFacade.getInstance().expansionsGetDCCoinsWithFriends(_loc2_);
            _loc4_ = RulesFacade.getInstance().expansionsGetDCCash(_loc2_) * RulesFacade.getDCCashToDCCoins();
            _loc1_ += Math.min(_loc3_,_loc4_);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function set investmentInMeTimeLeft(param1:Number) : void
      {
         this.mData["investmentInMeTimeLeft"] = param1;
      }
      
      public function collectiblesCommmerceTabSetFirstShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_COLLECTIBLES_COMMERCE_TAB_FIRST_SHOWN,FLAGS_COLLECTIBLES_COMMERCE_TAB_FIRST_SHOWN_VERSION_TARGET);
      }
      
      public function registerEventsRemove(param1:String) : void
      {
         if(this.mRegisterEventsDictionary != null)
         {
            if(this.mRegisterEventsDictionary[param1] == null)
            {
               if(Config.DEBUG_ASSERTS)
               {
                  Debug.trace("############# ERROR in Profile.registerEventsRemove: Index not found for sku = " + param1);
               }
            }
            else if(this.mRegisterEventsDictionary[param1] > 0)
            {
               --this.mRegisterEventsDictionary[param1];
            }
            else if(Config.DEBUG_ASSERTS)
            {
               Debug.trace("############# ERROR in Profile.registerEventsRemove: Negative value for sku = " + param1);
            }
         }
      }
      
      public function expansionsGetFBCredits(param1:int) : Number
      {
         return RulesFacade.getInstance().expansionsGetFBCredits(this.mExpansionsMineCount);
      }
      
      public function expansionsGetDCCoins(param1:int) : Number
      {
         return RulesFacade.getInstance().expansionsGetDCCoins(this.mExpansionsMineCount);
      }
      
      private function flagsGetValue(param1:String) : int
      {
         var _loc2_:int = 0;
         if(this.mFlags[param1] != null)
         {
            _loc2_ = int(this.mFlags[param1]);
         }
         return _loc2_;
      }
      
      public function servicesGetLock(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = this.servicesGetIdFromSku(param1);
         if(_loc3_ != -1)
         {
            _loc2_ = Boolean(this.mServicesLock[_loc3_]);
         }
         return _loc2_;
      }
      
      public function isBuild() : Boolean
      {
         return this.mIsBuild;
      }
      
      public function registerEventsAdd(param1:String) : void
      {
         if(this.mRegisterEventsDictionary != null)
         {
            if(this.mRegisterEventsDictionary[param1] == null)
            {
               this.mRegisterEventsDictionary[param1] = 0;
            }
            ++this.mRegisterEventsDictionary[param1];
         }
      }
      
      public function set maxPermits(param1:uint) : void
      {
         this.mData["maxPermits"] = param1;
         this.update();
      }
      
      public function getPersistence(param1:Boolean = false, param2:Boolean = false) : XML
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc19_:Number = NaN;
         var _loc20_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Boolean = DollarsGame.getCurrentRole().isProgressEnabled();
         if(param1)
         {
            _loc7_ = true;
            param2 = false;
         }
         if(_loc7_)
         {
            _loc3_ = Tutorial.smTutorialEnd ? 1 : 0;
            _loc6_ = this.mMillionNewsFeed ? 1 : 0;
            _loc11_ = this.firstInvest ? 1 : 0;
            _loc12_ = this.firstVisit ? 1 : 0;
            _loc13_ = this.firstPartner ? 1 : 0;
            _loc14_ = this.firstMission ? 1 : 0;
            _loc15_ = int(this.checkmail);
            _loc16_ = this.fourMillions ? 1 : 0;
            _loc17_ = "" + (this.investmentInMeUserId ? this.investmentInMeUserId : -1);
            _loc18_ = "" + (this.investmentInMeExtId ? this.investmentInMeExtId : -1);
            _loc19_ = this.investmentInMeTimeLeft ? this.investmentInMeTimeLeft : -1;
            _loc20_ = <Profile investmentInMeTimeLeft={_loc19_} investmentInMeUserId={_loc17_} investmentInMeExtId={_loc18_} exp={this.exp} DCCoins={this.DCCoins} DCCash={this.DCCash} cityname={this.cityname} cityNameCodes={this.getCityNameCodes()} tutorialEnd={_loc3_} companyValue={this.companyValue} millionNewsFeed={_loc6_} ranking={this.rankingPos} bossGenre={this.bossGenre} firstInvest={_loc11_} firstVisit={_loc12_} firstPartner={_loc13_} firstMission={_loc14_} newToolRev={this.newToolRev} checkmail={_loc15_} fourMillions={_loc16_} planeSku={this.planeSku} flags={this.flagsToString()}/>;
            if(!param2 && _loc7_)
            {
               _loc20_.appendChild(MissionObjectManager.getInstance().getPersistence());
               _loc20_.appendChild(PollManager.getInstance().getPersistence());
               _loc20_.appendChild(this.plotsGetPersistence());
            }
            return _loc20_;
         }
         return this.mPersistence;
      }
      
      public function set plots(param1:Array) : void
      {
         var _loc2_:int = 0;
         this.mPlots = param1;
         this.mExpansionsMineCount = -1;
         for each(_loc2_ in this.mPlots)
         {
            if(_loc2_ == Plot.TYPE_FULL)
            {
               ++this.mExpansionsMineCount;
            }
         }
      }
      
      public function get facebookCreditsNotSpent() : int
      {
         return this.mData["facebookCreditsNotSpent"];
      }
      
      private function onResize(param1:Event) : void
      {
         this.mNews.resize();
      }
      
      public function getUpdateCompanyValueEnabled() : Boolean
      {
         return this.mUpdateCompanyValueEnabled;
      }
      
      public function get investmentInMeUserId() : int
      {
         return this.mData["investmentInMeUserId"];
      }
      
      public function set firstMission(param1:Boolean) : void
      {
         this.mData["firstMission"] = param1;
      }
      
      public function getCityNameCodes() : String
      {
         var _loc1_:String = this.cityname;
         var _loc2_:String = "";
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            _loc2_ += _loc1_.charCodeAt(_loc3_) + ",";
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function isExpansionAreaForSale(param1:int) : Boolean
      {
         return !this.isExpansionAreaType(param1,Plot.TYPE_FULL);
      }
      
      public function set checkmail(param1:String) : void
      {
         this.mData["checkmail"] = param1;
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("checkmail",{"value":this.mData["checkmail"]});
         }
      }
      
      public function calculateCompanyValue() : void
      {
         var _loc1_:Number = DollarsGame.getCurrentWorld().getCompanyMine().getCompanyValue();
         this.companyValue = _loc1_;
      }
      
      public function servicesCheatTime(param1:Number) : void
      {
         var _loc2_:* = int(this.mServicesTimeLeft.length);
         while(_loc2_ > -1)
         {
            this.mServicesTimeLeft[_loc2_] -= param1;
            _loc2_--;
         }
      }
      
      private function servicesChangeState(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:Hud = null;
         var _loc5_:Tool = null;
         if(this.mServicesStates[param2] != param3)
         {
            _loc4_ = DollarsGame.getCurrentRole().hud;
            switch(this.mServicesStates[param2])
            {
               case SERVICES_STATE_HAS_EXPIRED_OFFLINE:
               case SERVICES_STATE_ABOUT_TO_EXPIRE:
                  this.mServicesTimeLeftNotifications[param2] = 0;
                  if(ServiceDefinitionManager.getInstance().hasTimeAvailable(param1))
                  {
                     _loc4_.stopIconBlink(param1);
                     _loc4_.setIconVisible(param1,false);
                  }
            }
            this.mServicesStates[param2] = param3;
            switch(param3)
            {
               case SERVICES_STATE_HAS_EXPIRED_OFFLINE:
                  this.mServicesTimeLeftNotifications[param2] = SERVICES_TIME_WARNING_HAS_EXPIRED;
               case SERVICES_STATE_ABOUT_TO_EXPIRE:
                  if(ServiceDefinitionManager.getInstance().hasTimeAvailable(param1))
                  {
                     _loc4_.startIconBlink(param1);
                  }
                  break;
               case SERVICES_STATE_AVAILABLE:
                  if(ServiceDefinitionManager.getInstance().hasTimeAvailable(param1))
                  {
                     _loc4_.setIconVisible(param1,true);
                  }
                  break;
               case SERVICES_STATE_NOT_AVAILABLE:
                  this.mServicesServiceDefinitionContracted[param1] = null;
                  if(ServiceDefinitionManager.getInstance().hasTimeAvailable(param1))
                  {
                     _loc4_.stopIconBlink(param1);
                     _loc4_.setIconVisible(param1,false);
                  }
                  _loc5_ = DollarsGame.getCurrentWorld().map.currentTool;
                  if(_loc5_ != null)
                  {
                     _loc5_.serviceEnd();
                  }
            }
         }
      }
      
      public function get level() : uint
      {
         return this.mData["level"];
      }
      
      public function set DCCoins(param1:Number) : void
      {
         var _loc2_:Number = param1 - this.DCCoins;
         this.setCompanyValue(this.companyValue + _loc2_);
         this.setDCCoins(param1);
         this.update();
      }
      
      public function servicesIsAvailable(param1:String, param2:int = -1) : Boolean
      {
         if(param2 == -1)
         {
            param2 = this.servicesGetIdFromSku(param1);
         }
         return this.mServicesStates[param2] != SERVICES_STATE_NOT_AVAILABLE && this.mServicesStates[param2] != SERVICES_STATE_HAS_EXPIRED_OFFLINE;
      }
      
      public function get isFan() : Boolean
      {
         return this.mData["fan"];
      }
      
      public function set firstInvest(param1:Boolean) : void
      {
         this.mData["firstInvest"] = param1;
      }
      
      private function flagsDestroy() : void
      {
         this.mFlags = null;
      }
      
      public function servicesIsOfferEnabled(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = param1 != Profile.SERVICES_MOVE_SKU;
         if(_loc2_)
         {
            _loc3_ = this.servicesGetIdFromSku(param1);
            if(_loc3_ != -1)
            {
               _loc2_ = Boolean(this.mServicesOfferEnabled[_loc3_]);
            }
         }
         return _loc2_;
      }
      
      public function dailyBonusConfirmSetHelpShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_USE_DAILY_BONUS_CONFIRM_HELP_SHOWN,FLAGS_USE_DAILY_BONUS_CONFIRM_HELP_SHOWN_VESION_TARGET);
      }
      
      public function servicesContract(param1:String, param2:int = 0) : void
      {
         var _loc3_:ServiceDefinition = ServiceDefinitionManager.getInstance().getServiceDefinition(param1,param2) as ServiceDefinition;
         var _loc4_:int = int(_loc3_.type);
         _loc3_.contract();
         this.mServicesServiceDefinitionContracted[param1] = _loc3_;
         this.mServicesTimeLeft[_loc4_] = UserDataFacade.getInstance().timerGetTimeSinceLogin() + _loc3_.getTimeAvailable();
         this.mServicesTimeLeftNotifications[_loc4_] = 0;
         this.servicesChangeState(param1,_loc4_,SERVICES_STATE_AVAILABLE);
         DollarsGame.getCurrentWorld().getCompanyMine().delayedPaymentPay();
         var _loc5_:String = "0";
         if(this.mServicesOfferEnabled[_loc4_])
         {
            _loc5_ = "1";
            this.mServicesOfferEnabled[_loc4_] = false;
         }
         Debug.trace("############# SERVICE: add CONTRACT server call in Profile.servicesContract() method sku = " + param1 + " contractId = " + param2 + " cash = " + this.DCCash + " coins = " + this.DCCoins + " offer = " + _loc5_);
         UserDataFacade.getInstance().updateMoney("service",{
            "value":param1,
            "id":param2,
            "offer":_loc5_
         });
      }
      
      public function getTerrainPrice() : int
      {
         return RulesFacade.getLevelTerrainPrice(this.level - 1);
      }
      
      public function getBreakIncomeTimeMin() : int
      {
         return RulesFacade.getLevelBreakIncomeTimeMin(this.level);
      }
      
      public function get bossName() : String
      {
         if(this.mData["bossGenre"] == 0)
         {
            return "Ronald";
         }
         return "Cindy";
      }
      
      public function firstPartnerDone() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateMoney("firstPartner",{"value":1});
         }
      }
      
      public function saveRankingPos(param1:int = -1) : void
      {
         if(param1 == -1)
         {
            param1 = this.rankingPos;
         }
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("ranking",{"value":param1});
         }
      }
      
      public function investmentExpiredSetReminderShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_USE_INVESTMENT_EXPIRED_REMINDER,FLAGS_USE_INVESTMENT_EXPIRED_VERSION_TARGET);
      }
      
      public function buyGoldCurrencyGet() : Boolean
      {
         return this.flagsGetValue(FLAGS_BUY_GOLD_CURRENCY) == FLAGS_BUY_GOLD_CURRENCY_ENABLED;
      }
      
      public function set newItemRev(param1:int) : void
      {
         this.mNewItemsRev = param1;
      }
      
      public function set fourMillions(param1:Boolean) : void
      {
         this.mData["fourMillions"] = param1;
      }
      
      public function get investmentInMeTimeLeft() : Number
      {
         return this.mData["investmentInMeTimeLeft"];
      }
      
      public function expansionsGetFriendsNeeded(param1:int) : int
      {
         return RulesFacade.getInstance().expansionsGetFriendsNeeded(this.mExpansionsMineCount);
      }
      
      public function missionAltRewardGet() : int
      {
         return this.flagsGetValue(FLAGS_MISSION_ALT_REWARD);
      }
      
      public function get plots() : Array
      {
         return this.mPlots;
      }
      
      public function plotsGetPersistence(param1:Boolean = false) : XML
      {
         var _loc2_:String = this.mPlots[0];
         var _loc3_:int = 1;
         while(_loc3_ < this.mPlots.length)
         {
            _loc2_ += "," + this.mPlots[_loc3_];
            _loc3_++;
         }
         return <Plots type={_loc2_}/>;
      }
      
      private function servicesDestroy() : void
      {
         this.mServicesServiceDefinitionContracted = null;
         if(this.mServicesTimeLeft != null)
         {
            this.mServicesTimeLeft.splice(0,this.mServicesTimeLeft.length);
            this.mServicesTimeLeft = null;
         }
         if(this.mServicesStates != null)
         {
            this.mServicesStates.splice(0,this.mServicesStates.length);
            this.mServicesStates = null;
         }
         if(this.mServicesLock != null)
         {
            this.mServicesStates.splice(0,this.mServicesLock.length);
            this.mServicesLock = null;
         }
         if(this.mServicesTimeLeftNotifications != null)
         {
            this.mServicesTimeLeftNotifications.splice(0,this.mServicesTimeLeftNotifications.length);
            this.mServicesTimeLeftNotifications = null;
         }
         if(this.mServicesInitialized != null)
         {
            this.mServicesInitialized.splice(0,this.mServicesInitialized.length);
            this.mServicesInitialized = null;
         }
         if(this.mServicesNeedsToShowPresentation != null)
         {
            this.mServicesNeedsToShowPresentation.splice(0,this.mServicesNeedsToShowPresentation.length);
            this.mServicesNeedsToShowPresentation = null;
         }
         if(this.mServicesOfferEnabled != null)
         {
            this.mServicesOfferEnabled.splice(0,this.mServicesOfferEnabled.length);
            this.mServicesOfferEnabled = null;
         }
      }
      
      public function savePlaneSku() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("planeSku",{"value":this.planeSku});
         }
      }
      
      public function investmentSetToolbarHelpShown(param1:Boolean) : void
      {
         this.flagsSetValue(FLAGS_USE_INVESTMENT_TOOLBAR_HELP_SHOWN,FLAGS_USE_INVESTMENT_TOOLBAR_HELP_SHOWN_VESION_TARGET);
      }
      
      public function getTimePrice(param1:Number = -1) : int
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = RulesFacade.getLevelTimePrice(this.level - 1);
         if(param1 > -1)
         {
            _loc3_ = TimerUtil.msToMin(param1);
            _loc2_ *= _loc3_;
         }
         return _loc2_;
      }
      
      public function getRepairPricePercentage() : int
      {
         return RulesFacade.getLevelRepairPricePercentage(this.level);
      }
      
      public function expansionsGetDCCoinsWithFriends(param1:int) : Number
      {
         return RulesFacade.getInstance().expansionsGetDCCoinsWithFriends(this.mExpansionsMineCount);
      }
      
      public function getRepairTimeDice() : int
      {
         return RulesFacade.getLevelRepairTimeDice(this.level);
      }
      
      public function servicesIsDone(param1:String, param2:int = -1) : Boolean
      {
         if(param2 == -1)
         {
            param2 = this.servicesGetIdFromSku(param1);
         }
         return this.mServicesTimeLeftNotifications[param2] > 0 && DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD;
      }
      
      public function set investmentInMeExtId(param1:String) : void
      {
         this.mData["investmentInMeExtId"] = param1;
      }
      
      private function nextRentLoad() : void
      {
         this.mNextRentCurrentValue = -2;
      }
      
      private function flagsSetValue(param1:String, param2:int) : void
      {
         this.mFlags[param1] = param2;
         Debug.trace("Update flag: " + param1 + " value: " + param2);
         UserDataFacade.getInstance().updateProfile("flag",{
            "name":param1,
            "value":param2
         });
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Vector.<NeighborObject> = null;
         var _loc3_:NeighborObject = null;
         var _loc4_:int = 0;
         if(this.mNewCompanyValue != -1)
         {
            this.mData[COMPANY_VALUE_KEY] = this.mNewCompanyValue;
            if(this.mIsMe)
            {
               if(DollarsGame.smInstance.mState == DollarsGame.STATE_RUN_WORLD)
               {
                  if(this.companyValue >= 1000000 && !this.mMillionNewsFeed && !DollarsGame.smInstance.mShowPopup)
                  {
                     this.mMillionNewsFeed = true;
                     DollarsGame.smInstance.magazineShow();
                     UserDataFacade.getInstance().updateProfile("million_news_feed",{});
                  }
               }
               this.eventCheck(COMPANY_VALUE_KEY);
               FriendsManager.mNeighborMyself.companyValue = this.mNewCompanyValue;
            }
            _loc2_ = FriendsManager.getSortedNeightbors();
            _loc3_ = FriendsManager.mNeighborMyself;
            _loc4_ = _loc2_.indexOf(_loc3_);
            if(_loc3_ != null)
            {
               if(this.mLevelHasChanged)
               {
                  _loc3_.exp = this.exp;
               }
               DollarsGame.getFriendsBar().refreshMySelf();
               this.mNewCompanyValue = -1;
            }
         }
         this.servicesLogicUpdate(param1);
         if(DollarsGame.smInstance.mPopupLevel != null)
         {
            DollarsGame.smInstance.mPopupLevel.logicUpdate(param1);
         }
      }
      
      public function setUpdateCompanyValueEnabled(param1:Boolean) : void
      {
         this.mUpdateCompanyValueEnabled = param1;
      }
      
      public function firstInvestDone() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("first_invest",{"value":1});
         }
      }
      
      public function set companyValue(param1:Number) : void
      {
         this.setCompanyValue(param1);
         this.update();
      }
      
      public function get investmentInMeExtId() : String
      {
         return this.mData["investmentInMeExtId"];
      }
      
      public function fourMillionsDone() : void
      {
         if(this.mIsMe)
         {
            UserDataFacade.getInstance().updateProfile("fourMillions",{"value":1});
         }
      }
      
      public function set firstPartner(param1:Boolean) : void
      {
         this.mData["firstPartner"] = param1;
      }
      
      public function expansionsGetDCCash(param1:int) : int
      {
         return RulesFacade.getInstance().expansionsGetDCCash(this.mExpansionsMineCount);
      }
      
      public function set HQLevel(param1:uint) : void
      {
         this.mData["HQLevel"] = param1;
      }
      
      public function get firstPartner() : Boolean
      {
         return this.mData["firstPartner"];
      }
      
      public function destroy() : void
      {
         this.mData = null;
         this.servicesDestroy();
         this.registerEventsDestroy();
         this.flagsDestroy();
      }
      
      public function servicesSetShowPresentation(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = this.servicesGetIdFromSku(param1);
         if(Config.DEBUG_ASSERTS && _loc2_ == -1)
         {
            Debug.trace("############# ERROR in Profile.servicesSetShowPresentation(): Index not found for sku = " + param1);
         }
         else
         {
            this.mServicesNeedsToShowPresentation[_loc2_] = false;
            _loc3_ = param1 + SERVICES_STR_PRESENTATION_SHOWN;
            Debug.trace("############# SERVICE: add PRESENTAION SHOWN server call in Profile.servicesSetShowPresentation() method key = " + _loc3_);
            UserDataFacade.getInstance().updateProfile("service",{"value":param1});
         }
      }
   }
}

