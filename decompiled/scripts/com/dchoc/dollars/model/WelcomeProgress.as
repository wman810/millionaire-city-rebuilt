package com.dchoc.dollars.model
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleBuyAsk;
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.GUI.Collectibles.PopupPendingCollectiblesList;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupBecameFan;
   import com.dchoc.dollars.GUI.PopupCrm;
   import com.dchoc.dollars.GUI.PopupHelpFriend;
   import com.dchoc.dollars.GUI.PopupInvestAccept;
   import com.dchoc.dollars.GUI.PopupMessage;
   import com.dchoc.dollars.GUI.PopupMultiContract;
   import com.dchoc.dollars.GUI.PopupNewItem;
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.GUI.PopupProgerss;
   import com.dchoc.dollars.GUI.PopupRentMoneyCollector;
   import com.dchoc.dollars.GUI.Services.PopupServiceExpired;
   import com.dchoc.dollars.GUI.bundles.PopupConfirmBundle;
   import com.dchoc.dollars.GUI.dailyReward.PopupDailyReward;
   import com.dchoc.dollars.GUI.dailyReward.PopupDailyRewardSpecial;
   import com.dchoc.dollars.GUI.newsfeeds.NewsFeedRewardPresentation;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.collectibles.CollectiblePendingManager;
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinition;
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinitionManager;
   import com.dchoc.dollars.dailyBonus.DailyBonusManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.invests.InvestObject;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinition;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinitionManager;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.metrics.CRMCustomizerDefinition;
   import com.dchoc.dollars.utils.metrics.CheckCRMToolbar;
   import com.dchoc.dollars.utils.metrics.CheckConfirmEmail;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class WelcomeProgress extends EventDispatcher
   {
      
      public static var mLoginSourceItemSku:String;
      
      public static var mLoginSourceExtId:String;
      
      private static var mBecameFan:int;
      
      private static var smDailyBonusTime:Array;
      
      private static var mCRMEvent:int;
      
      public static var smRanking:int;
      
      public static const EVENT_WELCOME_END:String = "EventWelcomeEnd";
      
      public static const EVENT_SERVICE_SHOP_CLOSE:String = "EventServiceShopClose";
      
      public static const NO_FAN_NO_SHOW:int = 0;
      
      public static const NO_FAN_SHOW:int = 1;
      
      public static const FAN:int = 2;
      
      private const STEP_FAN:int = 3;
      
      private var STEP_CHECK_MAIL:int = 13;
      
      private const STEP_NEW_ITEM:int = 7;
      
      private const STEP_CRM_EVENT:int = 11;
      
      private const STEP_BUILDING_FINISH:int = 6;
      
      private var mNewItems:Boolean;
      
      private var mNewsFeedDefinition:NewsFeedDefinition;
      
      private var mPopupNewItem:PopupNewItem;
      
      private var mPopupProgress:PopupProgerss;
      
      private var mInvestmentReminderPopup:PopupInvestAccept;
      
      private const STEP_FAKE_CREDITS:int = 2;
      
      private const STEP_INVESTMENT_STATUS:int = 8;
      
      private var mServicesBuffer:Array;
      
      private var mServiceExpiredPopup:PopupServiceExpired;
      
      private var mBuildingsComplete:int;
      
      private var mIsPopupOpened:Boolean;
      
      private const STEP_PROGRESS:int = 4;
      
      private const STEP_INVESTMENT_REMIND:int = 9;
      
      private var mPopupGiftPresentation:NewsFeedRewardPresentation;
      
      private const STEP_DAILY_BONUS:int = 1;
      
      private var mHelp:int;
      
      private var STEP_END:int = 14;
      
      private const USE_PROGRESS_POPUP:Boolean = false;
      
      private var mInvestments:int;
      
      private var mPopupFan:PopupBecameFan;
      
      private var mCollectibleReceived:Boolean;
      
      private var STEP_PENDING_COLLECTIBLES:int = 12;
      
      private var mCrmPopupCount:int;
      
      private var mPopupShare:PopupPartner;
      
      private const STEP_LOGIN_SOURCE:int = 5;
      
      private const STEP_SERVICE_EXPIRED:int = 10;
      
      private var mPopupInformation:PopupMessage;
      
      private var mDailyRewardPopup:PopupDailyReward;
      
      private var mLoginSourceSku:String;
      
      private var mStep:int;
      
      public function WelcomeProgress()
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:XMLList = null;
         var _loc9_:Number = NaN;
         super();
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_WELCOME_PROGRESS);
         this.loginSourceBuild(_loc1_);
         this.mHelp = int(_loc1_.@help);
         this.mInvestments = int(_loc1_.@invest);
         this.mNewItems = int(_loc1_.@newItems) == 1;
         var _loc2_:RulesFacade = RulesFacade.getInstance();
         var _loc3_:int = _loc2_.npcsGetCount();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = _loc2_.npcsGetSku(_loc4_);
            _loc7_ = "npc" + _loc6_ + "TimeLeft";
            _loc8_ = _loc1_.attribute(_loc7_);
            _loc9_ = 0;
            if(_loc8_.length() > 0)
            {
               _loc9_ = Number(_loc8_[0]);
            }
            smDailyBonusTime[_loc4_] = _loc9_;
            _loc4_++;
         }
         var _loc5_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mBuildingsComplete = _loc5_.progressGetEventCount(Company.PROGRESS_EVENT_CONSTRUCTION_FINISHED);
      }
      
      public static function loginSourceGetItemDefinition() : ItemDefinition
      {
         return ItemDefinitionManager.getInstance().getDefinitionBySku(mLoginSourceItemSku) as ItemDefinition;
      }
      
      public static function isDailyBonusAllowed(param1:String) : Boolean
      {
         var _loc2_:Number = getDailyBonusTime(param1);
         return _loc2_ == 0;
      }
      
      public static function logicUpdate(param1:int) : void
      {
         var _loc2_:* = 0;
         if(smDailyBonusTime != null)
         {
            _loc2_ = int(smDailyBonusTime.length - 1);
            while(_loc2_ > -1)
            {
               if(smDailyBonusTime[_loc2_] > 0)
               {
                  smDailyBonusTime[_loc2_] -= param1;
                  if(smDailyBonusTime[_loc2_] < 0)
                  {
                     smDailyBonusTime[_loc2_] = 0;
                  }
               }
               _loc2_--;
            }
         }
      }
      
      public static function getDailyBonusTime(param1:String) : Number
      {
         var _loc2_:int = RulesFacade.getInstance().npcsGetId(param1);
         return smDailyBonusTime[_loc2_];
      }
      
      public static function setDailyBonusTime(param1:String, param2:Number) : void
      {
         var _loc3_:int = RulesFacade.getInstance().npcsGetId(param1);
         smDailyBonusTime[_loc3_] = param2;
      }
      
      public static function load() : void
      {
         var _loc5_:Boolean = false;
         var _loc1_:RulesFacade = RulesFacade.getInstance();
         var _loc2_:int = _loc1_.npcsGetCount();
         smDailyBonusTime = new Array(_loc2_);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            smDailyBonusTime[_loc3_] = 0;
            _loc3_++;
         }
         var _loc4_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_FAN_LIST);
         mBecameFan = int(_loc4_.@value);
         if("@bookmark" in _loc4_)
         {
            _loc5_ = Boolean(int(_loc4_.@bookmark));
            DollarsGame.getProfile().bookmarked = _loc5_;
         }
         else
         {
            DollarsGame.getProfile().bookmarked = false;
         }
         DollarsGame.getProfile().isFan = mBecameFan == FAN;
      }
      
      private function onCloseBuildEnd(param1:Event) : void
      {
         this.mPopupShare.removeEventListener(Popup.EVENT_CLOSE,this.onCloseBuildEnd);
         this.mPopupShare = null;
         this.nextStep();
      }
      
      private function onCloseDailyReward(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupDailyReward.removeEventListener(Popup.EVENT_CLOSE,this.onCloseDailyReward);
         DollarsGame.smInstance.mPopupDailyReward = null;
         this.firstSessionProgress();
      }
      
      private function firstSessionProgress() : void
      {
         Debug.trace("*-*-*-*-*-*-*-*- > WelcomeProgress: firstSessionProgress()");
         if(!DollarsGame.getProfile().getStopPopupFirstSessionPopups())
         {
            Debug.trace("*-*-*-*-*-*-*-*- > WelcomeProgress: firstSessionProgress() -> getStopPopupFirstSessionPopups() is false");
            DollarsGame.getProfile().setStopPopupFirstSessionPopups(true);
            dispatchEvent(new Event(EVENT_WELCOME_END));
         }
         else
         {
            this.nextStep();
         }
      }
      
      private function onCloseInvestmentReminder(param1:Event) : void
      {
         this.mInvestmentReminderPopup.removeEventListener(Popup.EVENT_CLOSE,this.onCloseInvestmentReminder);
         this.mInvestmentReminderPopup = null;
         this.nextStep();
      }
      
      private function nextServiceStep() : void
      {
         var _loc1_:String = null;
         if(this.mServicesBuffer != null && this.mServicesBuffer.length > 0)
         {
            if(!this.mServiceExpiredPopup)
            {
               this.mServiceExpiredPopup = new PopupServiceExpired();
            }
            if(!DollarsGame.smInstance.mPopupRentCollector.isOpen() && !DollarsGame.smInstance.mPopupContractSignator.isOpen())
            {
               _loc1_ = this.mServicesBuffer[this.mServicesBuffer.length - 1] as String;
               this.mServiceExpiredPopup.setSku(_loc1_);
               this.mServiceExpiredPopup.resetParameters();
               this.mServiceExpiredPopup.showPopup();
               this.mServiceExpiredPopup.addEventListener(Popup.EVENT_CLOSE,this.onCloseServiceExpired);
               this.mServiceExpiredPopup.addEventListener(Popup.EVENT_ACCEPT,this.onAcceptServiceExpired);
            }
         }
         else if(!this.mIsPopupOpened)
         {
            this.nextStep();
         }
      }
      
      private function showNewFeed() : void
      {
         var _loc2_:ItemDefinition = null;
         var _loc1_:FriendObject = null;
         if(this.mLoginSourceSku == UserDataFacade.POST_HELP_WONDER)
         {
            _loc1_ = FriendsManager.getFriendByID(mLoginSourceExtId);
            this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_HELP);
            if(_loc1_ != null)
            {
               this.mLoginSourceSku = "";
               _loc2_ = loginSourceGetItemDefinition();
               if(_loc2_ != null)
               {
                  this.mPopupShare.setItemDefinition(_loc2_);
               }
            }
         }
         else if(this.mLoginSourceSku == UserDataFacade.POST_ASK_FOR_CASH_DONE)
         {
            _loc1_ = FriendsManager.getFriendByID(mLoginSourceExtId);
            this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_ASK_FOR_CASH_DONE);
            this.mPopupShare.setFriendExtId(mLoginSourceExtId);
         }
         else if(this.mLoginSourceSku == UserDataFacade.POST_ASK_FOR_CASH_THANKS)
         {
            _loc1_ = FriendsManager.getFriendByID(mLoginSourceExtId);
            this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_ASK_FOR_CASH_THANKS);
            this.mPopupShare.setFriendExtId(mLoginSourceExtId);
         }
         else if(this.mLoginSourceSku == UserDataFacade.POST_PARTNER_ADD)
         {
            _loc1_ = FriendsManager.getFriendByID(mLoginSourceExtId);
            this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_NEW_PARTNERS);
         }
         if(_loc1_ != null && this.mPopupShare != null)
         {
            this.mPopupShare.showPopupParams(_loc1_);
            this.mPopupShare.addEventListener(Popup.EVENT_CLOSE,this.onCloseShare);
         }
         else
         {
            this.nextStep();
         }
      }
      
      private function onCloseProgress(param1:Event) : void
      {
         this.mPopupProgress.removeEventListener(Popup.EVENT_CLOSE,this.onCloseProgress);
         this.mPopupProgress = null;
         this.nextStep();
      }
      
      private function showCrmPopup(param1:int) : void
      {
         var crmDef:CRMCustomizerDefinition = null;
         var popupCrm:Popup = null;
         var index:int = param1;
         try
         {
            Debug.trace("*-*-*-*-*-*-*-*- > showCrmPopup : index = " + index);
            crmDef = CustomizerManager.getInstance().getCrmPopupDefinition(CRMCustomizerDefinition.TYPE_INIT,index);
            if(crmDef.popupType == CRMCustomizerDefinition.POPUP_TYPE_FREE_ITEM && DollarsGame.getCurrentWorld().getCompanyMine().registerOccurrenceGetAmount(crmDef.actionButtonParams[0]) > 0)
            {
               ++this.mCrmPopupCount;
               crmDef = CustomizerManager.getInstance().getCrmPopupDefinition(CRMCustomizerDefinition.TYPE_INIT,this.mCrmPopupCount);
            }
            if(crmDef == null)
            {
               this.nextStep();
            }
            else
            {
               if(crmDef.popupType == CRMCustomizerDefinition.POPUP_TYPE_BUNDLE)
               {
                  Debug.trace("*-*-*-*-*-*-*-*- > showCrmPopup : BUNDLE");
                  popupCrm = new PopupConfirmBundle(crmDef.getBundleDefinition());
               }
               else if(crmDef.format == CRMCustomizerDefinition.FORMAT_IDLE)
               {
                  Debug.trace("*-*-*-*-*-*-*-*- > showCrmPopup : IDLE");
                  popupCrm = new PopupHelpFriend(crmDef);
                  popupCrm.showPopup();
               }
               else
               {
                  Debug.trace("*-*-*-*-*-*-*-*- > showCrmPopup : INIT");
                  popupCrm = new PopupCrm(crmDef);
                  popupCrm.showPopup();
               }
               popupCrm.addEventListener(Popup.EVENT_CLOSE,this.onCloseCrmPopup);
               popupCrm.addEventListener(Popup.EVENT_ACCEPT,this.onAcceptPopupCrm);
            }
         }
         catch(error:Error)
         {
            Debug.trace("*-*-*-*-*-*-*-*- > showCrmPopup up Exception: " + error.message);
            nextStep();
         }
      }
      
      private function onCloseShare(param1:Event) : void
      {
         if(this.mPopupShare != null)
         {
            this.mPopupShare.removeEventListener(Popup.EVENT_CLOSE,this.onCloseShare);
            this.mPopupShare = null;
         }
         this.nextStep();
      }
      
      private function showProcess() : void
      {
         this.mPopupProgress = new PopupProgerss();
         this.mPopupProgress.showPopupParams(smRanking,this.mHelp,this.mBuildingsComplete,this.mInvestments);
         this.mPopupProgress.addEventListener(Popup.EVENT_CLOSE,this.onCloseProgress);
      }
      
      private function onCloseInformation(param1:Event) : void
      {
         this.mPopupInformation.removeEventListener(Popup.EVENT_CLOSE,this.onCloseInformation);
         this.mPopupInformation = null;
         this.nextStep();
      }
      
      private function closeCollectiblePopup(param1:Event) : void
      {
      }
      
      private function onCloseNewItem(param1:Event) : void
      {
         this.mPopupNewItem.removeEventListener(Popup.EVENT_CLOSE,this.onCloseNewItem);
         this.mPopupNewItem = null;
         this.nextStep();
      }
      
      private function nextStep() : void
      {
         var _loc1_:Definition = null;
         var _loc2_:DailyBonusDefinition = null;
         var _loc3_:CollectibleObject = null;
         var _loc4_:FriendObject = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Array = null;
         var _loc9_:InvestObject = null;
         var _loc10_:InvestObject = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:MissionObject = null;
         ++this.mStep;
         Debug.trace("*-*-*-*-*-*-*-*- > WelcomeProgress: step = " + this.mStep);
         if(this.mStep == this.STEP_DAILY_BONUS)
         {
            if(Config.DAILY_BONUS_FEATURE_ENABLED)
            {
               if(DailyBonusManager.getInstance().isBonusEnabled())
               {
                  _loc1_ = DailyBonusDefinitionManager.getInstance().getDefinitionBySku(DailyBonusManager.getInstance().getCurrentDailyBonusSku());
                  if(_loc1_ != null)
                  {
                     _loc2_ = DailyBonusDefinition(_loc1_);
                     if(_loc2_.getDate() != 0)
                     {
                        DollarsGame.smInstance.mPopupDailyReward = new PopupDailyRewardSpecial();
                     }
                     else
                     {
                        DollarsGame.smInstance.mPopupDailyReward = new PopupDailyReward();
                     }
                     DollarsGame.smInstance.mPopupDailyReward.showPopup();
                     DollarsGame.smInstance.mPopupDailyReward.addEventListener(Popup.EVENT_CLOSE,this.onCloseDailyReward);
                  }
                  else
                  {
                     this.firstSessionProgress();
                  }
               }
               else
               {
                  this.firstSessionProgress();
               }
            }
            else
            {
               this.firstSessionProgress();
            }
         }
         else if(this.mStep == this.STEP_FAKE_CREDITS)
         {
            if(DollarsGame.getProfile().facebookCreditsNotSpent > 0 && DollarsGame.smFakeCredtisInfoShowed == 0)
            {
               this.mPopupInformation = new PopupMessage();
               this.mPopupInformation.showPopupParams(TextManager.getText(TextIDs.TID_FAKE_CREDITS_FBC),PopupMessage.NO_ICON);
               this.mPopupInformation.addEventListener(Popup.EVENT_CLOSE,this.onCloseInformation);
               DollarsGame.smFakeCredtisInfoShowed = 2;
            }
            else
            {
               DollarsGame.smFakeCredtisInfoShowed = 1;
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_FAN)
         {
            if(mBecameFan == NO_FAN_SHOW)
            {
               this.mPopupFan = new PopupBecameFan();
               this.mPopupFan.showPopup();
               this.mPopupFan.addEventListener(Popup.EVENT_CLOSE,this.onCloseFan);
            }
            else
            {
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_PROGRESS)
         {
            if(this.USE_PROGRESS_POPUP && (smRanking > 0 || this.mHelp > 0 || this.mBuildingsComplete > 0))
            {
               this.showProcess();
            }
            else
            {
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_LOGIN_SOURCE)
         {
            if(this.mNewsFeedDefinition != null)
            {
               this.mPopupGiftPresentation = new NewsFeedRewardPresentation();
               this.mPopupGiftPresentation.showPopupParams(this.mNewsFeedDefinition);
               this.mPopupGiftPresentation.addEventListener(Popup.EVENT_CLOSE,this.onCloseGiftPresentation);
            }
            else
            {
               switch(this.mLoginSourceSku)
               {
                  case UserDataFacade.POST_ASK_COLLECTIBLE:
                     if(mLoginSourceExtId != UserDataFacade.getInstance().mUserExtId)
                     {
                        if(CollectibleManager.getInstance().canCollectibleBeGivenAway(mLoginSourceItemSku))
                        {
                           PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy = new PopupCollectibleBuyAsk(CollectibleManager.getInstance().getCollectibleBySku(mLoginSourceItemSku),PopupCollectibleBuyAsk.TYPE_WELCOME_SEND,mLoginSourceExtId);
                           PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy.showPopup();
                           PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy.addEventListener(Popup.EVENT_CLOSE,this.onCloseSendCollectibleAsked);
                           break;
                        }
                        _loc3_ = CollectibleManager.getInstance().getCollectibleBySku(mLoginSourceItemSku);
                        if(_loc3_ != null)
                        {
                           PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy = new PopupCollectibleBuyAsk(CollectibleManager.getInstance().getCollectibleBySku(mLoginSourceItemSku),PopupCollectibleBuyAsk.TYPE_WELCOME_NOT_SEND);
                           PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy.showPopup();
                           PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy.addEventListener(Popup.EVENT_CLOSE,this.onCloseSendCollectibleAsked);
                        }
                     }
                     break;
                  case UserDataFacade.POST_COLLECTIBLE_RECEIVED:
                     if(mLoginSourceExtId == "")
                     {
                        this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_THANKS_COLLECTIBLE_ALL);
                     }
                     else
                     {
                        this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_THANKS_COLLECTIBLE);
                        this.mPopupShare.setFriendExtId(mLoginSourceExtId);
                     }
                     this.mPopupShare.showPopupParams(null);
                     this.mPopupShare.addEventListener(Popup.EVENT_CLOSE,this.onCloseShare);
                     break;
                  case UserDataFacade.POST_HELP_WONDER:
                     this.showNewFeed();
                     break;
                  case UserDataFacade.POST_PARTNER_ADD:
                     this.showNewFeed();
                     break;
                  case UserDataFacade.POST_ASK_FOR_CASH_DONE:
                     this.showNewFeed();
                     break;
                  case UserDataFacade.POST_ASK_FOR_CASH_THANKS:
                     this.showNewFeed();
                     break;
                  default:
                     this.nextStep();
               }
            }
         }
         else if(this.mStep == this.STEP_BUILDING_FINISH)
         {
            if(DollarsGame.getCurrentWorld().getCompanyMine().progressGetEventCount(Company.PROGRESS_EVENT_CONSTRUCTION_FINISHED_WITH_HELP) > 0)
            {
               this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_FINISHED);
               this.mPopupShare.showPopupParams(null);
               this.mPopupShare.addEventListener(Popup.EVENT_CLOSE,this.onCloseBuildEnd);
            }
            else
            {
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_NEW_ITEM)
         {
            if(this.mNewItems)
            {
               this.mPopupNewItem = new PopupNewItem();
               this.mPopupNewItem.showPopup();
               this.mPopupNewItem.addEventListener(Popup.EVENT_CLOSE,this.onCloseNewItem);
            }
            else
            {
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_INVESTMENT_STATUS)
         {
            _loc4_ = FriendsManager.getFriendByID(DollarsGame.getProfile().investmentInMeExtId);
            if(_loc4_)
            {
               if(DollarsGame.getProfile().investmentInMeTimeLeft > 0)
               {
                  if(DollarsGame.getProfile().fourMillions && !DollarsGame.getProfile().investmentAchivievedGetReminderShown())
                  {
                     this.mInvestmentReminderPopup = new PopupInvestAccept(true);
                     this.mInvestmentReminderPopup.addEventListener(Popup.EVENT_CLOSE,this.onCloseInvestmentReminder);
                     this.mInvestmentReminderPopup.showPopupParams(_loc4_);
                     _loc5_ = TextManager.getText(TextIDs.TID_INVESTMENT_REMINDER_DONE_TITLE);
                     _loc6_ = TextManager.replaceParameters(TextIDs.TID_INVESTMENT_REMINDER_DONE_BODY,new Array(_loc4_.nameFriend));
                     DollarsGame.getProfile().investmentAchivievedSetReminderShown(true);
                     this.mInvestmentReminderPopup.setTitle(_loc5_);
                     this.mInvestmentReminderPopup.setTextInfo(_loc6_);
                  }
                  else if(!DollarsGame.getProfile().fourMillions)
                  {
                     this.mInvestmentReminderPopup = new PopupInvestAccept(false);
                     this.mInvestmentReminderPopup.addEventListener(Popup.EVENT_CLOSE,this.onCloseInvestmentReminder);
                     this.mInvestmentReminderPopup.showPopupParams(_loc4_);
                     _loc7_ = 4000000 - DollarsGame.getProfile().companyValue;
                     _loc5_ = TextManager.getText(TextIDs.TID_INVESTMENT_REMINDER_DOIT_TITLE);
                     _loc6_ = TextManager.replaceParameters(TextIDs.TID_INVESTMENT_REMINDER_DOIT_BODY,new Array(_loc4_.nameFriend,TextManager.convertTimeToString(DollarsGame.getProfile().investmentInMeTimeLeft,true,true),String(_loc7_)));
                     this.mInvestmentReminderPopup.setTitle(_loc5_);
                     this.mInvestmentReminderPopup.setTextInfo(_loc6_);
                  }
                  else
                  {
                     this.nextStep();
                  }
               }
               else if(!DollarsGame.getProfile().investmentExpiredGetReminderShown() && !DollarsGame.getProfile().investmentAchivievedGetReminderShown())
               {
                  this.mInvestmentReminderPopup = new PopupInvestAccept(false);
                  this.mInvestmentReminderPopup.addEventListener(Popup.EVENT_CLOSE,this.onCloseInvestmentReminder);
                  this.mInvestmentReminderPopup.showPopupParams(_loc4_);
                  this.mInvestmentReminderPopup.setTitle(TextManager.getText(TextIDs.TID_INVESTMENT_REMINDER_FAIL_TITLE));
                  this.mInvestmentReminderPopup.setTextInfo(TextManager.replaceParameters(TextIDs.TID_INVESTMENT_REMINDER_FAIL_BODY,new Array(_loc4_.nameFriend)));
                  DollarsGame.getProfile().investmentExpiredSetReminderShown(true);
               }
               else
               {
                  this.nextStep();
               }
            }
            else
            {
               if(Config.DEBUG_ASSERTS)
               {
                  Debug.trace("############# ERROR in WelcomeProgress.nextStep(): Friend with id: " + DollarsGame.getProfile().investmentInMeUserId + " does not exist");
               }
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_INVESTMENT_REMIND)
         {
            if(InvestManager.getInstance().getReminder())
            {
               _loc8_ = InvestManager.getInstance().getInvestmentsUI();
               _loc9_ = null;
               for each(_loc10_ in _loc8_)
               {
                  if(_loc10_.getState() == InvestObject.STATE_RUNNING && _loc10_.getRemindTimeLeft() == 0 && _loc10_.getTimeLeft() < 5 * 24 * 60 * 60 * 1000)
                  {
                     _loc9_ = _loc10_;
                     break;
                  }
               }
               if(_loc9_ != null)
               {
                  _loc4_ = FriendsManager.getFriendByID(_loc9_.getExtId());
                  if(_loc4_ != null)
                  {
                     this.mInvestmentReminderPopup = new PopupInvestAccept(false,true,_loc9_);
                     this.mInvestmentReminderPopup.addEventListener(Popup.EVENT_CLOSE,this.onCloseInvestmentReminder);
                     this.mInvestmentReminderPopup.showPopupParams(_loc4_);
                     _loc5_ = TextManager.getText(TextIDs.TID_INVESTMENT_REMINDER_DOIT_TITLE);
                     _loc6_ = TextManager.replaceParameters(TextIDs.TID_GEN_TIME_LEFT,new Array(TextManager.convertTimeToString(_loc9_.getTimeLeft(),true,true)));
                     this.mInvestmentReminderPopup.setTitle(_loc5_);
                     this.mInvestmentReminderPopup.setTextInfo(_loc6_);
                  }
                  else
                  {
                     this.nextStep();
                  }
               }
               else
               {
                  this.nextStep();
               }
            }
            else
            {
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_SERVICE_EXPIRED)
         {
            this.mServicesBuffer = new Array();
            _loc11_ = 0;
            while(_loc11_ < ServiceDefinitionManager.getInstance().getTypeSkus().length)
            {
               _loc12_ = ServiceDefinitionManager.getInstance().getTypeSkus()[_loc11_];
               if(DollarsGame.getProfile().servicesIsOfferEnabled(_loc12_))
               {
                  this.mServicesBuffer.push(_loc12_);
               }
               _loc11_++;
            }
            this.nextServiceStep();
         }
         else if(this.mStep >= this.STEP_CRM_EVENT && this.mStep < this.STEP_PENDING_COLLECTIBLES)
         {
            Debug.trace("*-*-*-*-*-*-*-*- > WelcomeProgress: step = " + this.mStep + " // popup count = " + this.mCrmPopupCount);
            if(CustomizerManager.getInstance().crmEvent > -1)
            {
               this.showCrmPopup(this.mCrmPopupCount);
               ++this.mCrmPopupCount;
            }
            else
            {
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_PENDING_COLLECTIBLES)
         {
            if(Config.COLLECTIBLE_FEATURE_ENABLED)
            {
               if(Config.COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED)
               {
                  if(CollectiblePendingManager.getInstance().getPendingCollectibles().length > 0)
                  {
                     PopupCollectibleManager.getInstance().smPopupCollectiblePendingList = new PopupPendingCollectiblesList();
                     PopupCollectibleManager.getInstance().smPopupCollectiblePendingList.showPopup();
                  }
               }
               this.nextStep();
            }
         }
         else if(this.mStep == this.STEP_CHECK_MAIL)
         {
            if(DollarsGame.getProfile().checkmail != CheckConfirmEmail.MAIL_CHECKED)
            {
               CheckConfirmEmail.getInstance().load();
            }
            _loc13_ = MissionObjectManager.getInstance().getMissionBySku("87");
            if(_loc13_ != null && _loc13_.state == MissionObject.STATE_UNLOCKED)
            {
               CheckCRMToolbar.getInstance().load();
            }
            if(CustomizerManager.getInstance().crmEvent > -1)
            {
               CustomizerManager.getInstance().destroyDefinitionsInit();
            }
            dispatchEvent(new Event(EVENT_WELCOME_END));
            this.nextStep();
         }
         else if(this.mStep == this.STEP_END)
         {
            if(this.mLoginSourceSku == UserDataFacade.POST_COLLECTIBLE_RECEIVED)
            {
               CollectibleManager.getInstance().keepCollectible(mLoginSourceItemSku,false);
            }
         }
      }
      
      private function onCloseGiftPresentation(param1:Event) : void
      {
         this.mPopupGiftPresentation.removeEventListener(Popup.EVENT_CLOSE,this.onCloseGiftPresentation);
         this.mPopupGiftPresentation = null;
         this.nextStep();
      }
      
      private function onAcceptServiceExpired(param1:Event) : void
      {
         this.mIsPopupOpened = true;
         var _loc2_:String = this.mServiceExpiredPopup.type;
         if(_loc2_ == PopupServiceExpired.TYPE_MONEY_COLLECTOR)
         {
            DollarsGame.smInstance.mPopupRentCollector = new PopupRentMoneyCollector();
            DollarsGame.smInstance.mPopupRentCollector.showPopup();
            addEventListener(EVENT_SERVICE_SHOP_CLOSE,this.onCloseServiceShop);
         }
         else
         {
            DollarsGame.smInstance.mPopupContractSignator = new PopupMultiContract();
            DollarsGame.smInstance.mPopupContractSignator.showPopup();
            addEventListener(EVENT_SERVICE_SHOP_CLOSE,this.onCloseServiceShop);
         }
      }
      
      private function onCloseCrmPopup(param1:Event) : void
      {
         var _loc2_:Popup = param1.target as Popup;
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.onCloseCrmPopup);
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.onAcceptPopupCrm);
         if(!(_loc2_ is PopupConfirmBundle))
         {
            _loc2_.destroy();
         }
         this.nextStep();
      }
      
      public function start() : void
      {
         this.STEP_PENDING_COLLECTIBLES = this.STEP_CRM_EVENT + CustomizerManager.getInstance().getCountInit();
         this.STEP_CHECK_MAIL = this.STEP_PENDING_COLLECTIBLES + 1;
         this.STEP_END = this.STEP_CHECK_MAIL + 1;
         this.mStep = 0;
         this.nextStep();
      }
      
      private function loginSourceBuild(param1:XML) : void
      {
         this.mLoginSourceSku = param1.loginSourceParam.@sku;
         mLoginSourceExtId = param1.loginSourceParam.@extId;
         mLoginSourceItemSku = param1.loginSourceParam.@itemSku;
         this.mNewsFeedDefinition = NewsFeedDefinitionManager.getInstance().getDefinitionBySku(this.mLoginSourceSku) as NewsFeedDefinition;
         if(mLoginSourceExtId == UserDataFacade.getInstance().mUserExtId || this.mNewsFeedDefinition != null && !this.mNewsFeedDefinition.hasReward())
         {
            this.mNewsFeedDefinition = null;
         }
      }
      
      private function onCloseServiceShop(param1:Event) : void
      {
         this.mIsPopupOpened = false;
         var _loc2_:Popup = param1.target as Popup;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.onCloseServiceShop);
         }
         removeEventListener(EVENT_SERVICE_SHOP_CLOSE,this.onCloseServiceShop);
         this.nextServiceStep();
      }
      
      private function onCloseSendCollectibleAsked(param1:Event) : void
      {
         PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy.removeEventListener(Popup.EVENT_CLOSE,this.onCloseSendCollectibleAsked);
         PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy = null;
         this.nextStep();
      }
      
      private function launchCRMPopup() : void
      {
      }
      
      private function onCloseServiceExpired(param1:Event) : void
      {
         this.mServiceExpiredPopup.removeEventListener(Popup.EVENT_CLOSE,this.onCloseServiceExpired);
         this.mServiceExpiredPopup.removeEventListener(Popup.EVENT_ACCEPT,this.onAcceptServiceExpired);
         this.mServicesBuffer.pop();
         this.nextServiceStep();
      }
      
      private function onCollectiblePendingList(param1:Event) : void
      {
         PopupCollectibleManager.getInstance().removeEventListener(PopupCollectibleManager.WELLCOME_EVENT,this.onCollectiblePendingList);
         if(Config.COLLECTIBLE_FEATURE_ENABLED)
         {
            if(Config.COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED)
            {
               if(CollectiblePendingManager.getInstance().getPendingCollectibles().length > 0)
               {
                  PopupCollectibleManager.getInstance().smPopupCollectiblePendingList = new PopupPendingCollectiblesList();
                  PopupCollectibleManager.getInstance().smPopupCollectiblePendingList.showPopup();
               }
            }
         }
      }
      
      private function onAcceptPopupCrm(param1:Event) : void
      {
         this.mStep = this.STEP_END - 1;
         this.onCloseCrmPopup(param1);
      }
      
      private function onCloseFan(param1:Event) : void
      {
         this.mPopupFan.removeEventListener(Popup.EVENT_CLOSE,this.onCloseFan);
         this.mPopupFan = null;
         this.nextStep();
      }
   }
}

