package com.dchoc.dollars.model.userdata
{
   import com.adobe.utils.ArrayUtil;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.*;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.utils.System;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class UserDataFacade
   {
      
      private static var smLastCompValueGain:Number;
      
      private static var mInstance:UserDataFacade;
      
      public static var smCompValue:Number;
      
      public static var smDcCoins:Number;
      
      public static var smFBCredits:int;
      
      public static var smDcCash:int;
      
      public static var smExp:int;
      
      private static var mAllowInstantiation:Boolean;
      
      public static var smFriendListLoadedSuccessful:Boolean = false;
      
      public static var smNeighborListLoadedSuccessful:Boolean = false;
      
      public static var TASK_ASK_FOR_HELP:String = "taskAskForHelp";
      
      public static var TASK_HELP_INVITE_FRIEND:String = "helpInviteFriend";
      
      public static var TASK_HELP_SEND_FREE_GIFT:String = "helpSendFreeGift";
      
      public static var TASK_POST_TO_FEED:String = "postToFeed";
      
      public static var TASK_CASH_SHOP:String = "cashShop";
      
      public static var TASK_CASH_SHOP_STANDALONE:String = "cashShopStandalone";
      
      public static var TASK_INVEST:String = "taskInvest";
      
      public static var TASK_BECAME_FAN:String = "becameFan";
      
      public static var TASK_IS_FAN:String = "isFan";
      
      public static var TASK_BROWSER_REFRESH:String = "browserRefresh";
      
      public static var TASK_FACEBOOK_CREDITS:String = "facebookCredits";
      
      public static var TASK_FACEBOOK_CREDITS_FRICTIONLESS:String = "facebookCreditsFrictionless";
      
      public static var TASK_FACEBOOK_CREDITS_GET_BALANCE:String = "getFBCreditsBalance";
      
      public static var TASK_LOAD_SUCCESS:String = "loadSuccess";
      
      public static var TASK_NEIGHBOR_REQUEST:String = "neighborRequest";
      
      public static var TASK_NEIGHBOR_LIST_RELOAD:String = "neighborListReload";
      
      public static var TASK_PARTNER_REQUEST:String = "partnerRequest";
      
      public static var TASK_INVESTMENT_REQUEST:String = "investmentRequest";
      
      public static var TASK_BOOKMARK:String = "bookmark";
      
      public static var TASK_OPEN_DCHOC_MMA:String = "openDchocMMA";
      
      public static var TASK_OPEN_URL:String = "openUrl";
      
      public static var TASK_SEND_COLLECTIBLE:String = "taskSendCollectible";
      
      public static var TASK_FED_PAYMENT:String = "fedPayment";
      
      public static var TASK_ASK_FOR_CASH:String = "askForCash";
      
      public static var TASK_VIDEO_AD:String = "videoAd";
      
      public static var TASK_CREW_REQUEST:String = "crewRequest";
      
      public static var TASK_PUBLISH_SCORE:String = "publishScore";
      
      public static var TASK_MESSAGE_CENTER_ASK_FOR_OPEN:String = "ready";
      
      public static var TASK_SEND_LEVEL:String = "sendLevel";
      
      public static var TAG_UNIVERSE:String = "universe";
      
      public static var TAG_FRIEND_LIST:String = "friendList";
      
      public static var TAG_NEIGHBOR_LIST:String = "neighborList";
      
      public static var TAG_UPGRADES_LIST:String = "upgradesList";
      
      public static var TAG_UPGRADES_ADD_ITEM:String = "upgradesAddItem";
      
      public static var TAG_UPGRADES_REMOVE_ITEM:String = "upgradesRemoveItem";
      
      public static var TAG_UPGRADES_PARTNER_LIST:String = "upgradesPartnerList";
      
      public static var TAG_HELP_BUILDING_LIST:String = "helpList";
      
      public static var TAG_WELCOME_PROGRESS:String = "welcome";
      
      public static var TAG_GIFTS_LIST:String = "giftsList";
      
      public static var TAG_FAN_LIST:String = "fanList";
      
      public static var TAG_INVESTMENTS_LIST:String = "investmentsList";
      
      public static var TAG_VIPS_LIST:String = "vipsList";
      
      public static var TAG_GAME_CONFIG:String = "gameConfig";
      
      public static var TAG_CROSS_APPLICATIONS_PLAYED:String = "crossApplicationsPlayed";
      
      public static var TAG_CHECK_MAIL:String = "checkMail";
      
      public static var TAG_UNLOCKED_LIST:String = "unlockedList";
      
      public static var TAG_AUCTIONS_LIST:String = "auctionsList";
      
      public static var TAG_LIM_ED_LIST:String = "limEdList";
      
      public static var TAG_STORAGE_LIST:String = "storageList";
      
      public static var TAG_CRM_CUSTOMIZER:String = "crmpopups";
      
      public static var TAG_COLLECTIBLE_LIST:String = "collectiblesList";
      
      public static var TAG_COLLECTIBLE_PENDING_LIST:String = "collectiblePendingList";
      
      public static var TAG_DAILY_BONUS_INFO:String = "dailyBonusInfo";
      
      public static var POST_DEFAULT:String = "vir_fb_default";
      
      public static var POST_LEVEL_UP:String = "vir_fb_levelup";
      
      public static var POST_HELP_WONDER:String = "vir_fb_helpwonder";
      
      public static var POST_JOURNAL:String = "vir_fb_journal";
      
      public static var POST_ONE_MILLION:String = "vir_fb_onemillion";
      
      public static var POST_GET_REWARD:String = "vir_fb_getreward";
      
      public static var POST_INVEST_ON_FRIEND:String = "vir_fb_investonfriend";
      
      public static var POST_INVEST_ON_FRIEND_REMINDER:String = "vir_fb_investonfriendreminder";
      
      public static var POST_INVEST_SPEED:String = "vir_fb_investwakeup";
      
      public static var POST_INVEST_THANKS:String = "vir_fb_investsaythanks";
      
      public static var POST_INVEST_COMPLETE:String = "vir_fb_investcomplete";
      
      public static var POST_END_TUTORIAL:String = "vir_fb_endtutorial";
      
      public static var POST_COLLECTIBLE_RECEIVED:String = "vir_fb_collectible_received";
      
      public static var POST_ASK_FOR_CASH:String = "vir_fb_ask_for_cash";
      
      public static var POST_ASK_FOR_CASH_THANKS:String = "vir_fb_ask_for_cash_thanks";
      
      public static var POST_ASK_FOR_CASH_DONE:String = "vir_fb_ask_for_cash_done";
      
      public static var POST_OPEN_BOX_STORAGE:String = "vir_fb_open_box_storage";
      
      public static var POST_ALL_UPGRADES_DONE:String = "vir_fb_allupgradesdone";
      
      public static var POST_NOTIFY_HELP_WONDER:String = "vir_fb_notifyhelpwonder";
      
      public static var POST_THANK_HELPERS_WONDER:String = "vir_fb_thankhelperswonder";
      
      public static var POST_PARTNER_ADD:String = "vir_fb_partneradd";
      
      public static var POST_PARTNER_ACCEPTED:String = "vir_fb_partneraccepted";
      
      public static var POST_NEW_EXPANSION:String = "vir_fb_newexpansion";
      
      public static var POST_CONTRATOR_MOVE:String = "vir_fb_move";
      
      public static var POST_CONTRATOR_COLLECT:String = "vir_fb_collect";
      
      public static var POST_CONTRATOR_CONTRACT:String = "vir_fb_contract";
      
      public static var POST_UPGRADE_ME:String = "vir_fb_upgrademe";
      
      public static var POST_ASK_COLLECTIBLE:String = "vir_fb_askcollectible";
      
      public static var POST_COLLECTIBLE_COLLECTION_COMPLETE:String = "vir_fb_collectiblecollectioncomplete";
      
      public static var POST_THANKS_COLLECTIBLE:String = "vir_fb_thankscollectible";
      
      public static var POST_THANKS_COLLECTIBLE_ALL:String = "vir_fb_thankscollectibleall";
      
      public static var POST_GOLD_BOUGHT:String = "vir_fb_goldbought";
      
      public static var CLIENT_SHOW_INFO:String = "clientShowInfo";
      
      public static var INVEST_TYPE_ON_FRIEND:int = 0;
      
      public static var INVEST_TYPE_ON_FRIEND_REMINDER:int = 1;
      
      public static var INVEST_TYPE_GET_INVERSION:int = 2;
      
      public static var INVEST_TYPE_SPEED:int = 3;
      
      public static var INVEST_TYPE_CANCEL:int = 4;
      
      public static var INVEST_TYPE_RESULTS:int = 5;
      
      public static var INVEST_TYPE_THANKS:int = 6;
      
      public static var INVEST_TYPE_COMPLETE:int = 7;
      
      public static var EXTRA_INCOME_HOUSES:String = "Houses";
      
      public static var EXTRA_INCOME_COMMERCES:String = "Commerces";
      
      public static var chk:Boolean = false;
      
      public static var taskLoadSuccessDone:Boolean = false;
      
      private static var smSecurityCoinsToAdd:int = 0;
      
      private static var smSecurityCashToAdd:int = 0;
      
      public static var smSecurityIgnore:Boolean = false;
      
      public static const QUEUE_REQUEST_DEL_TERRAIN:String = "queueRequestDelTerrain";
      
      public static const QUEUE_REQUEST_SET_ITEM_CONNECTION:String = "queueRequestSetItemConnection";
      
      public static const QUEUE_REQUEST_UPDATE_ITEM:String = "queueRequestUpdateItem";
      
      public static const QUEUE_REQUEST_DESTROY_ITEM_IN_NOT_EMPTY_PLOT:String = "queueRequestDestroyItemInNotEmptyPlot";
      
      public static const QUEUE_REQUEST_UPDATE_RANKING:String = "queueRequestUpdateRanking";
      
      public static const TIMER_LOGIN_ID:int = 0;
      
      public static const TIMER_GET_UNIVERSE_ID:int = 1;
      
      public static const TIMER_COUNT:int = 2;
      
      public var mUserName:String = "You";
      
      public var mToken:String = null;
      
      protected var mTimeOffset:int = 0;
      
      private var mQueueRequests:Array;
      
      public var mUserId:int = -1;
      
      private var mTimerTimesAt:Array;
      
      private var mUserIsVIP:Boolean;
      
      public var mUserExtId:String = "none";
      
      private var mTimerTimesSince:Array;
      
      protected var mServerTimeAtLogin:Number = 0;
      
      public var mSocial:Social;
      
      public var mUserLocale:String = "EN";
      
      public var mUserPhotoUrl:String = "";
      
      private var mFileCacheTag:Object = new Object();
      
      protected var mDoubleRent:Object = new Object();
      
      private var mFileCache:Object = new Object();
      
      public var mNPCSArray:Array = null;
      
      private var mQueueEnabled:Boolean;
      
      public function UserDataFacade(param1:Boolean = false)
      {
         super();
         if(!param1 && !mAllowInstantiation)
         {
            throw new Error("ERROR: UserDataFacade Error: Instantiation failed: Use UserDataFacade.getInstance() instead of new.");
         }
         this.mDoubleRent["Houses"] = false;
         this.mDoubleRent["Commerces"] = false;
         this.timerInit();
         Dollars.smStage.addEventListener(Event.MOUSE_LEAVE,this.applicationExit);
      }
      
      public static function getInstance() : UserDataFacade
      {
         if(mInstance == null)
         {
            mAllowInstantiation = true;
            mAllowInstantiation = false;
            if(Config.OFFLINE_GAMEPLAY_MODE)
            {
               mInstance = new UserDataFacadeOffline();
            }
            else
            {
               mInstance = new UserDataFacadeOnline();
            }
         }
         return mInstance;
      }
      
      public static function securityLogicUpdate() : void
      {
         var _loc1_:Profile = null;
         var _loc2_:Company = null;
         if(smSecurityCoinsToAdd != 0 || smSecurityCashToAdd != 0)
         {
            _loc1_ = DollarsGame.getProfile();
            if(_loc1_ != null)
            {
               if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
               {
                  _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
                  _loc2_.DCCoins += smSecurityCoinsToAdd;
                  _loc2_.DCCash += smSecurityCashToAdd;
               }
               else
               {
                  _loc1_.DCCoins += smSecurityCoinsToAdd;
                  _loc1_.DCCash += smSecurityCashToAdd;
               }
               smDcCoins += smSecurityCoinsToAdd;
               smDcCash += smSecurityCashToAdd;
            }
            if(smSecurityCashToAdd > 0)
            {
               DollarsGame.externalRequest(DollarsGame.REQ_POST_GOLD_BOUGHT);
            }
            smSecurityCoinsToAdd = 0;
            smSecurityCashToAdd = 0;
         }
      }
      
      public static function securityUpdate() : Object
      {
         var _loc1_:Object = new Object();
         var _loc2_:int = DollarsGame.getProfile().exp;
         var _loc3_:Number = DollarsGame.getProfile().DCCoins;
         var _loc4_:int = int(DollarsGame.getProfile().DCCash);
         var _loc5_:Number = DollarsGame.getProfile().companyValue;
         var _loc6_:int = DollarsGame.getProfile().facebookCredits;
         var _loc7_:int = _loc2_ - smExp;
         var _loc8_:int = _loc3_ - smDcCoins;
         var _loc9_:int = _loc4_ - smDcCash;
         var _loc10_:Number = _loc5_ - smCompValue;
         smLastCompValueGain = _loc10_;
         smExp = _loc2_;
         smDcCoins = _loc3_;
         smDcCash = _loc4_;
         smCompValue = _loc5_;
         _loc1_.expGain = _loc7_;
         _loc1_.coinsGain = _loc8_;
         _loc1_.cashGain = _loc9_;
         _loc1_.compValueGain = _loc10_;
         _loc1_.expNow = smExp;
         _loc1_.coinsNow = smDcCoins;
         _loc1_.cashNow = smDcCash;
         _loc1_.compValueNow = smCompValue;
         return _loc1_;
      }
      
      public static function securityInit() : void
      {
         smExp = DollarsGame.getProfile().exp;
         smDcCash = DollarsGame.getProfile().DCCash;
         smDcCoins = DollarsGame.getProfile().DCCoins;
         smCompValue = DollarsGame.getProfile().companyValue;
         smFBCredits = DollarsGame.getProfile().facebookCredits;
      }
      
      public static function securityCoinsToAdd(param1:int) : void
      {
         smSecurityCoinsToAdd += param1;
      }
      
      public static function setInstanceOffline() : void
      {
         mInstance = new UserDataFacadeOffline();
      }
      
      public static function securityCreateObj(param1:int, param2:int, param3:int) : Object
      {
         var _loc4_:Object = new Object();
         _loc4_.expGain = param1;
         _loc4_.coinsGain = param2;
         _loc4_.cashGain = param3;
         _loc4_.compValueGain = smLastCompValueGain;
         _loc4_.expNow = smExp;
         _loc4_.coinsNow = smDcCoins;
         _loc4_.cashNow = smDcCash;
         _loc4_.compValueNow = smCompValue;
         return _loc4_;
      }
      
      public static function securityCashToAdd(param1:int) : void
      {
         smSecurityCashToAdd += param1;
      }
      
      public function destroy() : void
      {
         this.queueRequestDestroy();
      }
      
      public function updateCollectible(param1:String, param2:String, param3:String, param4:String, param5:Object, param6:Object = null) : void
      {
      }
      
      private function timerInit() : void
      {
         this.mTimerTimesAt = new Array(TIMER_COUNT);
         this.mTimerTimesSince = new Array(TIMER_COUNT);
         var _loc1_:int = 0;
         while(_loc1_ < TIMER_COUNT)
         {
            this.mTimerTimesAt[_loc1_] = -1;
            this.mTimerTimesSince[_loc1_] = 0;
            _loc1_++;
         }
      }
      
      protected function setFile(param1:String, param2:Object) : void
      {
         this.mFileCache[param1] = param2;
         this.mFileCacheTag[param1] = null;
      }
      
      public function freeFile(param1:String) : void
      {
         delete this.mFileCache[param1];
         delete this.mFileCacheTag[param1];
      }
      
      public function logout() : void
      {
      }
      
      public function queueGetEnabled() : Boolean
      {
         return this.mQueueEnabled;
      }
      
      public function applicationExit(param1:Event) : void
      {
      }
      
      public function isEditorEnabled() : Boolean
      {
         var _loc2_:XML = null;
         var _loc1_:Boolean = Config.EDIT_MODE;
         if(_loc1_)
         {
            _loc2_ = this.getFileXML(TAG_UNIVERSE);
            _loc1_ = _loc2_.@role == "1";
         }
         return _loc1_;
      }
      
      public function queueSetEnabled(param1:Boolean) : void
      {
         this.mQueueEnabled = param1;
      }
      
      public function getServerTimeEmulated() : Number
      {
         return this.mServerTimeAtLogin + this.timerGetTimeSinceLogin();
      }
      
      public function updateRewards(param1:String, param2:Object, param3:Object = null) : void
      {
      }
      
      public function timerGetTimeSince(param1:int) : Number
      {
         return this.mTimerTimesSince[param1];
      }
      
      public function allFilesLoaded() : Boolean
      {
         var _loc1_:String = null;
         for(_loc1_ in this.mFileCacheTag)
         {
            if(this.mFileCacheTag[_loc1_] != null)
            {
               Debug.trace("************* File " + _loc1_ + " requested to the server not found");
               return false;
            }
         }
         return true;
      }
      
      public function getFile(param1:String) : Object
      {
         var _loc2_:String = null;
         for(_loc2_ in this.mFileCache)
         {
            if(_loc2_ == param1 && this.isFileLoaded(param1))
            {
               return this.mFileCache[_loc2_];
            }
         }
         return null;
      }
      
      public function updateProfile(param1:String, param2:Object, param3:XML = null) : void
      {
      }
      
      public function cmdCreateNewItemFromStorage() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.key = "storage";
         _loc1_.value = "true";
         return _loc1_;
      }
      
      public function allFilesLoadedExclude(param1:Array) : Boolean
      {
         var _loc2_:String = null;
         for(_loc2_ in this.mFileCacheTag)
         {
            if(!ArrayUtil.arrayContainsValue(param1,_loc2_))
            {
               if(this.mFileCacheTag[_loc2_] != null)
               {
                  Debug.trace("************* File " + _loc2_ + " requested to the server not found");
                  return false;
               }
            }
         }
         return true;
      }
      
      public function getServerTimeAtLogin() : Number
      {
         return this.mServerTimeAtLogin;
      }
      
      public function isBossNPC(param1:int) : Boolean
      {
         if(this.mNPCSArray != null)
         {
            if(param1 == this.mNPCSArray[this.mNPCSArray.length - 1])
            {
               return true;
            }
         }
         return false;
      }
      
      public function queueRequestFlush() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:ItemObject = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc10_:XML = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc16_:Object = null;
         var _loc17_:XML = null;
         if(this.mQueueRequests != null && DollarsGame.getCurrentUniverse().roleID == DollarsGame.ROLE_OWNER)
         {
            _loc1_ = this.mQueueRequests.pop();
            while(_loc1_ != null)
            {
               _loc2_ = _loc1_.cmd as String;
               _loc3_ = "";
               switch(_loc2_)
               {
                  case QUEUE_REQUEST_DEL_TERRAIN:
                     _loc4_ = _loc1_.sid as String;
                     _loc6_ = _loc1_.x as String;
                     _loc7_ = _loc1_.y as String;
                     _loc8_ = parseInt(_loc1_.tileIndex);
                     DollarsGame.getCurrentWorld().map.destroyTileApplyEconomy(_loc8_,false);
                     this.updateMap(_loc4_,"del",{
                        "type":"Terrain",
                        "x":_loc6_,
                        "y":_loc7_
                     },DollarsGame.getCurrentWorld().map.securityCreateObj("del","Terrain"));
                     _loc3_ += "xx = " + _loc6_ + " yy = " + _loc7_ + " tileIndex = " + _loc8_;
                     break;
                  case QUEUE_REQUEST_SET_ITEM_CONNECTION:
                     _loc5_ = _loc1_.item as ItemObject;
                     _loc4_ = _loc5_.mSid;
                     _loc9_ = _loc5_.getPersistence(true);
                     _loc10_ = XMLUtil.XMLListToXML(_loc9_.State);
                     _loc11_ = int(_loc10_.@time);
                     _loc5_.setIsSuspended(true);
                     _loc5_.resume();
                     break;
                  case QUEUE_REQUEST_DESTROY_ITEM_IN_NOT_EMPTY_PLOT:
                     _loc5_ = _loc1_.item as ItemObject;
                     _loc4_ = _loc5_.mSid;
                     _loc12_ = _loc5_.itemDefinition.getConstructionCoins(false);
                     if(_loc12_ > 0)
                     {
                        DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins + _loc5_.itemDefinition.getConstructionCoins(false);
                        _loc3_ += "DCCoins = " + _loc12_;
                     }
                     _loc13_ = _loc5_.itemDefinition.getConstructionCash();
                     if(_loc13_ > 0)
                     {
                        DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins + _loc5_.itemDefinition.getConstructionCash() * RulesFacade.getDCCashToDCCoins();
                        _loc3_ += "DCCash - DCCoins = " + _loc5_.itemDefinition.getConstructionCash() * RulesFacade.getDCCashToDCCoins();
                     }
                     this.updateItem(_loc4_,"destroyFix",{});
                     break;
                  case QUEUE_REQUEST_UPDATE_RANKING:
                     _loc14_ = _loc1_.rankingPos as int;
                     DollarsGame.getProfile().saveRankingPos(_loc14_);
                     break;
                  case QUEUE_REQUEST_UPDATE_ITEM:
                     _loc4_ = _loc1_.sid;
                     _loc15_ = _loc1_.action;
                     _loc16_ = _loc1_.params;
                     _loc17_ = _loc1_.xml;
                     this.updateItem(_loc4_,_loc15_,_loc16_,_loc17_);
               }
               Debug.trace("@@@@@@@@ queueRequestFlush " + _loc2_ + " " + " sid = " + _loc4_ + " " + _loc3_);
               _loc1_ = this.mQueueRequests.pop();
            }
         }
      }
      
      public function timerGetTimeSinceLogin() : Number
      {
         return this.timerGetTimeSince(TIMER_LOGIN_ID);
      }
      
      public function queueRequestAdd(param1:Object) : void
      {
         if(DollarsGame.getCurrentUniverse().roleID == DollarsGame.ROLE_OWNER)
         {
            if(this.mQueueRequests == null)
            {
               this.queueRequestLoad();
            }
            this.mQueueRequests.push(param1);
         }
      }
      
      public function requestFile(param1:String, param2:String) : void
      {
         var tag:String = param1;
         var url:String = param2;
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.onLoadFile_COMPLETE);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadFile_ERROR);
         this.mFileCacheTag[tag] = loader;
         this.mFileCache[tag] = null;
         try
         {
            loader.load(new URLRequest(url));
         }
         catch(error:Error)
         {
            trace("loadFile-Engine: Unable to load " + url);
         }
      }
      
      public function requestTask(param1:String, param2:Object = null) : void
      {
      }
      
      public function updateNextRent(param1:String, param2:Object) : void
      {
      }
      
      public function getTimeOffset() : int
      {
         return this.mTimeOffset;
      }
      
      private function onLoadFile_COMPLETE(param1:Event) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in this.mFileCacheTag)
         {
            if(this.mFileCacheTag[_loc2_] == param1.target)
            {
               this.mFileCache[_loc2_] = param1.target.data;
               this.mFileCacheTag[_loc2_] = null;
               param1.target.removeEventListener(Event.COMPLETE,this.onLoadFile_COMPLETE);
               if(_loc2_ == TAG_STORAGE_LIST)
               {
                  DollarsGame.externalRequest(DollarsGame.REQ_LOAD_STORAGE);
               }
               break;
            }
         }
      }
      
      public function timerGetTimeSinceGetUniverse() : Number
      {
         return this.timerGetTimeSince(TIMER_GET_UNIVERSE_ID);
      }
      
      private function userVIPBuild() : void
      {
         var _loc1_:XML = this.getFileXML(UserDataFacade.TAG_WELCOME_PROGRESS);
         if("@vip" in _loc1_)
         {
            this.mUserIsVIP = _loc1_.@vip == 1;
         }
         else
         {
            this.mUserIsVIP = false;
         }
      }
      
      public function timerSetTimeAt(param1:int, param2:Boolean = false) : void
      {
         if(this.mTimerTimesAt[param1] == -1 || param2)
         {
            this.mTimerTimesAt[param1] = System.currentTimeMillis();
            this.mTimerTimesSince[param1] = 0;
         }
      }
      
      private function queueRequestLoad() : void
      {
         this.mQueueRequests = new Array();
      }
      
      public function getFileXML(param1:String) : XML
      {
         var _loc2_:Object = this.getFile(param1);
         if(_loc2_ != null)
         {
            return new XML(_loc2_);
         }
         return null;
      }
      
      public function cmdCreateNewItemFromCollectibleReward(param1:String) : Object
      {
         var _loc2_:Object = new Object();
         _loc2_.key = "collectible";
         _loc2_.value = param1;
         return _loc2_;
      }
      
      public function logicUpdate(param1:int) : void
      {
         this.timerLogicUpdate(param1);
      }
      
      public function isLogged() : Boolean
      {
         return true;
      }
      
      public function isLoaded() : Boolean
      {
         return false;
      }
      
      public function updateMissions(param1:String, param2:Object, param3:XML = null, param4:Object = null) : void
      {
      }
      
      private function timerLogicUpdate(param1:int) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < TIMER_COUNT)
         {
            if(this.mTimerTimesAt[_loc2_] > -1)
            {
               this.mTimerTimesSince[_loc2_] += param1;
            }
            _loc2_++;
         }
      }
      
      public function updateMap(param1:String, param2:String, param3:Object, param4:Object = null) : void
      {
      }
      
      public function getNPCIdFromUserId(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = -1;
         if(this.mNPCSArray != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.mNPCSArray.length && _loc2_ == -1)
            {
               if(param1 == this.mNPCSArray[_loc3_])
               {
                  _loc2_ = _loc3_;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function isNPC(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         if(this.mNPCSArray != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.mNPCSArray.length)
            {
               if(param1 == this.mNPCSArray[_loc2_])
               {
                  return true;
               }
               _loc2_++;
            }
         }
         return false;
      }
      
      protected function reserveFile(param1:String) : void
      {
         this.mFileCacheTag[param1] = new Object();
         this.mFileCache[param1] = null;
      }
      
      protected function timerSetTimeAtLogin(param1:Boolean = false) : void
      {
         this.timerSetTimeAt(TIMER_LOGIN_ID);
      }
      
      private function queueRequestDestroy() : void
      {
         if(this.mQueueRequests != null)
         {
            this.mQueueRequests.splice(0,this.mQueueRequests.length);
            this.mQueueRequests = null;
         }
      }
      
      public function timerSetTimeAtGetUniverse() : void
      {
         this.timerSetTimeAt(TIMER_GET_UNIVERSE_ID);
      }
      
      public function notifyWCRM(param1:String, param2:String, param3:String, param4:Object = null) : void
      {
      }
      
      public function isUserVIP() : Boolean
      {
         return this.mUserIsVIP;
      }
      
      public function saveUniverse(param1:XML) : void
      {
         return mInstance.saveUniverse(param1);
      }
      
      private function onLoadFile_ERROR(param1:IOErrorEvent) : void
      {
         param1.target.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadFile_ERROR);
      }
      
      public function setServerTimeAtLogin(param1:Number) : void
      {
         this.mServerTimeAtLogin = param1;
      }
      
      public function updatePollManager(param1:String, param2:Object, param3:XML = null) : void
      {
      }
      
      public function load() : void
      {
      }
      
      public function isTutorialRequired() : Boolean
      {
         var _loc1_:Boolean = true;
         var _loc2_:XML = this.getFileXML(TAG_UNIVERSE);
         if(Config.EDIT_MODE && _loc2_.@role == "1")
         {
            _loc1_ = false;
         }
         else if("@tutorialEnd" in _loc2_.Profile)
         {
            _loc1_ = _loc2_.Profile.@tutorialEnd == "0";
         }
         return _loc1_;
      }
      
      public function login() : void
      {
      }
      
      public function isFileLoaded(param1:String) : Boolean
      {
         return this.mFileCacheTag[param1] == null;
      }
      
      public function serverIsBusy() : int
      {
         return 0;
      }
      
      public function flushUniverse() : void
      {
         return mInstance.flushUniverse();
      }
      
      public function getProfile(param1:String) : Profile
      {
         return new Profile();
      }
      
      public function isDoubleRent(param1:String) : Boolean
      {
         return false;
      }
      
      protected function build() : void
      {
         this.userVIPBuild();
         if(!Config.DEBUG_CONSOLE && !Debug.DEBUG)
         {
            Debug.DEBUG = Config.cheatsAreEnabled(Config.CHEAT_DEBUG_ID);
            Debug.visible = Debug.DEBUG;
            Debug.startConsole(Dollars.smStage);
         }
      }
      
      public function updatePlots(param1:String, param2:Object, param3:XML = null) : void
      {
      }
      
      public function updateItem(param1:String, param2:String, param3:Object, param4:XML = null, param5:Object = null) : void
      {
      }
      
      public function updateMoney(param1:String, param2:Object) : void
      {
      }
      
      public function clientTask(param1:String, param2:Object = null) : void
      {
         var _loc3_:String = null;
         switch(param1)
         {
            case CLIENT_SHOW_INFO:
               _loc3_ = param2.message;
               DollarsGame.smInstance.mPopupMsgSmall.showPopupParams(_loc3_);
         }
      }
   }
}

