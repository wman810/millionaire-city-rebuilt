package com.dchoc.dollars.flow
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectables;
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.GUI.Collectibles.PopupPendingCollectiblesList;
   import com.dchoc.dollars.GUI.NewsPaper;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirm;
   import com.dchoc.dollars.GUI.PopupConfirmExpansion;
   import com.dchoc.dollars.GUI.PopupConnection;
   import com.dchoc.dollars.GUI.PopupCrm;
   import com.dchoc.dollars.GUI.PopupDailyIncome;
   import com.dchoc.dollars.GUI.PopupGold;
   import com.dchoc.dollars.GUI.PopupHelpFriend;
   import com.dchoc.dollars.GUI.PopupInstantBuild;
   import com.dchoc.dollars.GUI.PopupInvest;
   import com.dchoc.dollars.GUI.PopupJournal;
   import com.dchoc.dollars.GUI.PopupLevel;
   import com.dchoc.dollars.GUI.PopupMessage;
   import com.dchoc.dollars.GUI.PopupMessageSmall;
   import com.dchoc.dollars.GUI.PopupMultiContract;
   import com.dchoc.dollars.GUI.PopupOutOfSync;
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.GUI.PopupRentMoneyCollector;
   import com.dchoc.dollars.GUI.PopupServicePresentation;
   import com.dchoc.dollars.GUI.PopupTradeBox;
   import com.dchoc.dollars.GUI.PopupTutorial;
   import com.dchoc.dollars.GUI.PopupVisit;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.dailyReward.PopupDailyReward;
   import com.dchoc.dollars.GUI.events.DollarsEventManager;
   import com.dchoc.dollars.GUI.hireCrew.PopupHireCrew;
   import com.dchoc.dollars.GUI.hud.Hud;
   import com.dchoc.dollars.GUI.hud.OptionsPanel;
   import com.dchoc.dollars.GUI.instantBuild.PopupInstantBuildSecondStep;
   import com.dchoc.dollars.GUI.payment.PopupPaymentFail;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectiblePendingManager;
   import com.dchoc.dollars.containers.BuyBox;
   import com.dchoc.dollars.containers.ContractBox;
   import com.dchoc.dollars.containers.ContractBoxMultiple;
   import com.dchoc.dollars.containers.ContractBoxSingle;
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.dailyBonus.DailyBonusManager;
   import com.dchoc.dollars.freeGift.FreeGiftDefinition;
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsBar;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.map.Background;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.missions.MissionDefinitionManager;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.missions.iconLayer.MissionsIconLayerManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.ShowPopup;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.UnlockedListManager;
   import com.dchoc.dollars.model.WelcomeProgress;
   import com.dchoc.dollars.model.limEd.LimEdManager;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.roles.RoleEditor;
   import com.dchoc.dollars.model.roles.RoleOwner;
   import com.dchoc.dollars.model.roles.RoleVisitor;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.offers.OfferManager;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.GUI.messages.MessageManager;
   import com.dchoc.dollars.utils.Mouse.MouseWheelEnabler;
   import com.dchoc.dollars.utils.actions.ActionsLibrary;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.metrics.BAMetrics;
   import com.dchoc.dollars.utils.metrics.CRMCustomizerDefinition;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.metrics.PaymentManager;
   import com.dchoc.dollars.utils.particles.NoteRain;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.Plane;
   import com.dchoc.dollars.utils.particles.climate.ClimateManager;
   import com.dchoc.dollars.utils.poll.PollManager;
   import com.dchoc.dollars.utils.stats.FPSCounter;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.utils.traffic.TrafficAgentManager;
   import com.dchoc.dollars.utils.traffic.TrafficAgentManagerDefinition;
   import com.dchoc.dollars.world.Universe;
   import com.dchoc.dollars.world.World;
   import com.dchoc.dollars.world.companies.*;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.states.FSMState;
   import com.dchoc.framework.states.LoadingState;
   import com.dchoc.framework.states.StateMachine;
   import com.dchoc.framework.utils.XMLTuner;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.Capabilities;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class DollarsGame extends FSMState
   {
      
      public static var smInstance:DollarsGame;
      
      private static var mPopupGold:PopupGold;
      
      private static var smTimeOffset:Number;
      
      public static var smFPSCounter:FPSCounter;
      
      private static var smItemOutlinePending:ItemObject;
      
      private static var mNumExtraOptions:int;
      
      private static const ROLE_NONE:int = -1;
      
      public static const ROLE_OWNER:int = 0;
      
      public static const ROLE_EDITOR:int = 1;
      
      public static const ROLE_VISITOR:int = 2;
      
      private static const ROLE_COUNT:int = 2;
      
      public static const HUD_SKU:String = "HudSku";
      
      public static var smWorldSid:int = 1;
      
      public static var smCompanySid:int = 1;
      
      public static var smItemSid:int = 1;
      
      public static var smMapSid:int = 1;
      
      public static var smCRMhash:String = "";
      
      public static const STATE_PROGRAM_RESOURCES_TO_LOAD:int = 0;
      
      public static const STATE_LOAD_RESOURCES:int = 1;
      
      public static const STATE_VISIT_WORLD:int = 2;
      
      public static const STATE_REQUEST_WORLD:int = 3;
      
      public static const STATE_BUILD_WORLD:int = 4;
      
      public static const STATE_RUN_WORLD:int = 5;
      
      private static var smItemOutlineEnabled:Boolean = true;
      
      private static var mScaleX:Number = 1;
      
      private static var mScaleY:Number = 1;
      
      private static var mLoadingTime:Number = 0;
      
      public static var smFakeCredtisInfoShowed:int = 0;
      
      public static const EVENT_FULLSCREEN:String = "EventFullScreen";
      
      private static const VIEW_UNATTACH_WORLD_STEP_START:int = 0;
      
      private static const VIEW_UNATTACH_WORLD_STEP_END:int = VIEW_UNATTACH_WORLD_STEP_START;
      
      private static const DESTROY_WORLD_STEP_START:int = VIEW_UNATTACH_WORLD_STEP_END + 1;
      
      private static const DESTROY_WORLD_STEP_END:int = DESTROY_WORLD_STEP_START;
      
      private static const SET_PERSISTENCE_WORLD_STEP_START:int = DESTROY_WORLD_STEP_END + 1;
      
      private static const SET_PERSISTENCE_WORLD_STEP_END:int = SET_PERSISTENCE_WORLD_STEP_START;
      
      private static const BUILD_WORLD_STEP_START:int = SET_PERSISTENCE_WORLD_STEP_END + 1;
      
      private static const BUILD_WORLD_STEP_END:int = BUILD_WORLD_STEP_START + World.BUILD_STEPS_COUNT - 1;
      
      private static const ATTACH_ROLE_STEP_START:int = BUILD_WORLD_STEP_END + 1;
      
      private static const ATTACH_ROLE_STEP_END:int = ATTACH_ROLE_STEP_START;
      
      private static const VIEW_ATTACH_WORLD_START:int = ATTACH_ROLE_STEP_END + 1;
      
      private static const VIEW_ATTACH_WORLD_END:int = VIEW_ATTACH_WORLD_START;
      
      private static const VISIT_WORLD_STEPS_COUNT:int = VIEW_ATTACH_WORLD_END + 1;
      
      private static const LOAD_WORLD_RESOURCES_STEP_START:int = 2;
      
      private static const LOAD_WORLD_RESOURCES_STEP_END:int = LOAD_WORLD_RESOURCES_STEP_START + 100;
      
      private static const REQUEST_DEFINITION_MANAGER_RESOURCES_STEP:int = LOAD_WORLD_RESOURCES_STEP_END + 1;
      
      private static const VISIT_WORLD_STEP_START:int = REQUEST_DEFINITION_MANAGER_RESOURCES_STEP + 1;
      
      private static const VISIT_WORLD_STEP_END:int = VISIT_WORLD_STEP_START + VISIT_WORLD_STEPS_COUNT - 1;
      
      private static const REPORT_HACKING_STEP_START:int = VISIT_WORLD_STEP_END + 1;
      
      private static const REPORT_HACKING_STEP_END:int = REPORT_HACKING_STEP_START + 1;
      
      private static const LOADING_BUILD_TOTAL_STEPS:int = REPORT_HACKING_STEP_END + 1;
      
      public static const FILTER_GREY:String = "FILTER_GREY";
      
      private static const MAX_TIMER_MINUTES:int = 1;
      
      private static const MAX_TIMER_MS:int = TimerUtil.minToMs(MAX_TIMER_MINUTES);
      
      private static const LOADING_PERCENT_TO_LOAD_RESOURCES:int = 50;
      
      public static var REQ_SHOW_POPUP_INFO:int = 0;
      
      public static var REQ_GAME_PLAY_PAUSE:int = 1;
      
      public static var REQ_GAME_PLAY_RESUME:int = 2;
      
      public static var REQ_GAME_PLAY_LOGOUT:int = 3;
      
      public static var REQ_INVEST_GET_INVERSION:int = 5;
      
      public static var REQ_LIM_ED_RESPONSE:int = 6;
      
      public static var REQ_GIVE_COLLECTIBLE:int = 7;
      
      public static var REQ_POST_INVERSION:int = 8;
      
      public static var REQ_POST_GOLD_BOUGHT:int = 9;
      
      public static var REQ_LEVEL:int = 10;
      
      public static var REQ_PAYMENT_FAIL:int = 11;
      
      public static var REQ_FAKE_CREDITS_INFO:int = 12;
      
      public static var REQ_LOAD_STORAGE:int = 13;
      
      public static var REQ_RESUME_SOUND:int = 14;
      
      public static const MESSAGES_BECOME_PARTNER:String = "messageBecomePartner";
      
      public static const MESSAGES_ACCEPT_COLLECTIBLE:String = "messageAcceptCollectible";
      
      public static const MESSAGES_GIVE_BONUS:String = "messageGiveBonus";
      
      public static const MESSAGES_FREE_GIFT:String = "messageFreeGift";
      
      public static const MESSAGES_ADD_NEIGHBOR:String = "messageAddNeighbor";
      
      public static const MESSAGES_REMOVE_NEIGHBOR:String = "messageRemoveNeighbor";
      
      public static const MESSAGES_FAN_POPUP_CLOSED:String = "messageFanPopupClosed";
      
      private static const MESSAGES_KEYS:Vector.<String> = Vector.<String>([MESSAGES_BECOME_PARTNER,MESSAGES_ACCEPT_COLLECTIBLE,MESSAGES_GIVE_BONUS,MESSAGES_FREE_GIFT,MESSAGES_ADD_NEIGHBOR,MESSAGES_REMOVE_NEIGHBOR,MESSAGES_FAN_POPUP_CLOSED]);
      
      private static const MESSAGES_COUNT:int = MESSAGES_KEYS.length;
      
      private var mConfigLoaded:Boolean = false;
      
      private var mPopupHelpTimer:int;
      
      private var mMessages:Vector.<Object>;
      
      public var mOptionsPanel:OptionsPanel;
      
      private var mEnabled:Boolean = true;
      
      private var mTutoTimerID:int;
      
      private var mGamePaused:Boolean = false;
      
      public var mPopupContractSignator:PopupMultiContract;
      
      private var mWorld:World;
      
      private var mPopupHelpTimerRandom:int;
      
      public var mState:int;
      
      private var mMagazine:NewsPaper;
      
      public var mBuyBox:BuyBox;
      
      public var mPopupConection:PopupConnection;
      
      private var mLoadingPercent:int;
      
      private var mScrollEnabled:Boolean;
      
      private var mPopupVisit:PopupVisit;
      
      public var mRoles:Array;
      
      private var mLoadingBuildTotalSteps:int;
      
      public var mPopupCollectibleShop:PopupCollectables;
      
      public var mPopupRentCollector:PopupRentMoneyCollector;
      
      private var mLoadingScreen:LoadingState;
      
      private var zoomValue:Number;
      
      private var mPopupDailyIncome:PopupDailyIncome;
      
      public var mPopupMsgSmall:PopupMessageSmall;
      
      public var mPopupInstantBuildSecondStep:PopupInstantBuildSecondStep;
      
      private var mOldCursor:int;
      
      public var mPopupContract:ContractBoxSingle;
      
      public var mShopIsOpen:Boolean;
      
      private var mPopupHelpType:int;
      
      private var mProfile:Profile;
      
      public var mWelcomProgress:WelcomeProgress;
      
      public var mPopupConfirm:PopupConfirm;
      
      public var mPopupLevel:PopupLevel;
      
      public var mPopupOutOfSync:PopupOutOfSync;
      
      public var mFriendsBar:FriendsBar;
      
      public var mPopupPaymentFail:PopupPaymentFail;
      
      private var mLoadingOldPercent:int;
      
      public var mPopupGamePlayConection:PopupConnection;
      
      private var mShopSearch:String;
      
      private var chkReported:Boolean = false;
      
      public var mPopupContractMultiple:ContractBoxMultiple;
      
      public var mPopupServicePresentation:PopupServicePresentation;
      
      public var mRain2:NoteRain;
      
      public var mRain:NoteRain;
      
      public var mPopupTutorial:PopupTutorial;
      
      public var mPopupMsg:PopupMessage;
      
      private var mViewWorldAttached:Boolean;
      
      private var time:int = 0;
      
      public var mPopupHelpShown:Boolean;
      
      public var mPopupHireCrew:PopupHireCrew;
      
      private var mLoadingBuildCurrentStep:int;
      
      private var mPreviousDCCash:Number = 0;
      
      public var mPopupWonders:PopupInstantBuild;
      
      public var mShowpIsOpen:Boolean;
      
      private var mUserDataFacade:UserDataFacade;
      
      private var mProfileUniverse:Profile;
      
      private var mCurrentRole:int;
      
      private var mUniverse:Universe;
      
      public var mPopupInstantBuild:PopupTradeBox;
      
      public var mPopupPendingCollectibles:PopupPendingCollectiblesList;
      
      public var mPopupDailyReward:PopupDailyReward;
      
      private var mIsWorldStopped:Boolean = false;
      
      public var mPlane:Plane;
      
      public var mShowPopup:Boolean;
      
      public function DollarsGame(param1:StateMachine)
      {
         super(param1,true,false);
         this.loadingLoad();
         smInstance = this;
      }
      
      public static function getCurrentWorld() : World
      {
         if(smInstance != null)
         {
            return smInstance.mWorld;
         }
         return null;
      }
      
      public static function getScreenHeight() : int
      {
         var _loc1_:int = Dollars.smStage.stageHeight;
         var _loc2_:FriendsBar = getFriendsBar();
         if(_loc2_ != null)
         {
            _loc1_ -= FriendsBar.getHeight();
         }
         return _loc1_;
      }
      
      public static function getCurrentRoleID() : int
      {
         if(smInstance != null)
         {
            return smInstance.mCurrentRole;
         }
         return ROLE_NONE;
      }
      
      public static function getFriendsBar() : FriendsBar
      {
         if(smInstance != null)
         {
            return smInstance.mFriendsBar;
         }
         return null;
      }
      
      public static function externalRequest(param1:int, param2:Object = null) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:FriendObject = null;
         var _loc10_:PopupPartner = null;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:String = null;
         if(param2 == null)
         {
            param2 = new Object();
         }
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("--=> DollarsGame.extertalRequest(" + param1 + ")");
            Debug.traceObject(param2);
         }
         switch(param1)
         {
            case REQ_SHOW_POPUP_INFO:
               ShowPopup.show(ShowPopup.POPUP_MSG_SMALL,param2.text);
               break;
            case REQ_GAME_PLAY_PAUSE:
               ShowPopup.show(ShowPopup.POPUP_CONECTION,TextManager.getText(TextIDs.TID_CONNECTIVITY_NETWORK_BUSY));
               break;
            case REQ_GAME_PLAY_RESUME:
               ShowPopup.close();
               break;
            case REQ_GAME_PLAY_LOGOUT:
               _loc4_ = ShowPopup.POPUP_OUT_OF_SYNC;
               _loc5_ = TextIDs.TID_GENERIC_ERROR;
               if(param2.hasOwnProperty("type"))
               {
                  if(param2["type"] == "world")
                  {
                     _loc5_ = TextIDs.TID_LOAD_CITY_ERROR;
                  }
                  else if(param2["type"] == "update_version")
                  {
                     _loc5_ = TextIDs.TID_CONNECTIVITY_SERVER_JUST_UPDATED;
                  }
                  else if(param2["type"] == "syncNotMatch")
                  {
                     _loc5_ = TextIDs.TID_CONNECTIVITY_SERVER_MULTIPLE_SESSIONS;
                  }
                  else if(param2["type"] == "security")
                  {
                     _loc5_ = TextIDs.TID_CONNECTIVITY_ERROR;
                  }
                  else
                  {
                     _loc5_ = TextIDs.TID_GENERIC_ERROR;
                  }
               }
               _loc3_ = TextManager.getText(_loc5_);
               if(param2.hasOwnProperty("text") && param2.text != null)
               {
                  _loc3_ = param2.text;
               }
               ShowPopup.show(_loc4_,_loc3_);
               smInstance.mEnabled = false;
               break;
            case REQ_INVEST_GET_INVERSION:
               Tutorial.showPopupInvest();
               break;
            case REQ_SHOW_POPUP_INFO:
               ShowPopup.show(ShowPopup.POPUP_MSG_SMALL,param2.text);
               break;
            case REQ_LIM_ED_RESPONSE:
               _loc6_ = param2.sku;
               if(_loc6_ != null)
               {
                  _loc11_ = int(param2.itemsLeft);
                  _loc12_ = Number(param2.lastLegalBuyTime);
                  LimEdManager.getInstance().updateItem(_loc6_,_loc11_,_loc12_);
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("itemsLeft - " + _loc11_ + " / sku - " + _loc6_);
                  }
               }
               break;
            case REQ_GIVE_COLLECTIBLE:
               _loc6_ = param2.sku;
               _loc7_ = param2.sid;
               if(_loc6_ != null)
               {
                  CollectibleManager.getInstance().addCollectibleToPendingList(_loc7_,_loc6_);
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("House " + _loc7_ + " will have collectible " + _loc6_);
                  }
               }
               break;
            case REQ_POST_INVERSION:
               _loc8_ = (param2.extIds as String).split(",");
               for each(_loc13_ in _loc8_)
               {
                  _loc9_ = FriendsManager.getFriendByID(_loc13_);
                  InvestManager.getInstance().investInFriend(_loc9_);
               }
               break;
            case REQ_POST_GOLD_BOUGHT:
               _loc10_ = new PopupPartner(PopupPartner.TYPE_SHARE_GOLD_BOUGHT);
               _loc10_.showPopupParams(null);
               break;
            case REQ_LEVEL:
               param2.level = getProfile().level;
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_SEND_LEVEL,param2);
               break;
            case REQ_PAYMENT_FAIL:
               _loc3_ = TextManager.getText(TextIDs.TID_PAYMENT_FAIL_FBC_BODY);
               ShowPopup.show(ShowPopup.POPUP_PAYMENT_FAIL,_loc3_);
               break;
            case REQ_FAKE_CREDITS_INFO:
               _loc3_ = TextManager.getText(TextIDs.TID_FAKE_CREDITS_FBC);
               ShowPopup.show(ShowPopup.POPUP_FAKE_CREDITS,_loc3_);
               DollarsGame.smFakeCredtisInfoShowed = 2;
               break;
            case REQ_LOAD_STORAGE:
               StorageManager.getInstance().build();
               break;
            case REQ_RESUME_SOUND:
               getCurrentRole().hud.resumeSounds();
         }
      }
      
      public static function getCurrentRole() : Role
      {
         if(smInstance != null && smInstance.mRoles != null)
         {
            return smInstance.mRoles[smInstance.mCurrentRole];
         }
         return null;
      }
      
      public static function getProfile() : Profile
      {
         if(smInstance != null)
         {
            return smInstance.mProfile;
         }
         return null;
      }
      
      public static function getItemOutlineEnabled() : Boolean
      {
         return smItemOutlineEnabled;
      }
      
      public static function setItemOutlineEnabled(param1:Boolean) : void
      {
         smItemOutlineEnabled = param1;
         if(param1 && smItemOutlinePending != null)
         {
            smItemOutlinePending.setDisplayObjectOutlineVisible(false,0);
            smItemOutlinePending = null;
         }
      }
      
      public static function getCurrentUniverse() : Universe
      {
         if(smInstance != null)
         {
            return smInstance.mUniverse;
         }
         return null;
      }
      
      public static function addGold() : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc1_:Boolean = false;
         if(Config.FACEBOOK_CREDITS_OR_OFFERPAL && (PaymentManager.smAreFb || CustomizerManager.getInstance().crmOfferState == CustomizerManager.CRM_OFFER_ENABLED))
         {
            _loc2_ = Dollars.smStage.root.loaderInfo.parameters;
            _loc3_ = _loc2_.platform;
            if(_loc3_ == "standalone")
            {
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_CASH_SHOP_STANDALONE);
            }
            else
            {
               _loc1_ = true;
            }
         }
         else
         {
            _loc1_ = true;
         }
         if(_loc1_ && !mPopupGold.mPopupOpen)
         {
            if(mNumExtraOptions != PaymentManager.getInstance().paymentCount)
            {
               mPopupGold = null;
               mPopupGold = new PopupGold();
               mNumExtraOptions = PaymentManager.getInstance().paymentCount;
            }
            mPopupGold.showPopup();
         }
         else if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            Dollars.smStage.displayState = StageDisplayState.NORMAL;
         }
      }
      
      public static function visitUniverse(param1:int) : void
      {
         var _loc2_:Map = null;
         if(getCurrentUniverse().owner != param1)
         {
            ParticlesManager.killPartilce();
            getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
            smInstance.visitUniverse(param1);
            getCurrentRole().toolsBar.disable();
            smInstance.mFriendsBar.disable();
            _loc2_ = getCurrentWorld().map;
            mScaleX = _loc2_.scaleX;
            mScaleY = _loc2_.scaleY;
         }
      }
      
      public static function setTimeOffset(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         smTimeOffset = param1;
         if(Config.CHEATS_ENABLED)
         {
            _loc2_ = TimerUtil.minToMs(param1);
            ServiceDefinitionManager.getInstance().cheatTime(_loc2_);
            DollarsGame.getProfile().servicesCheatTime(_loc2_);
         }
      }
      
      public static function getProfileUniverse() : Profile
      {
         if(smInstance != null)
         {
            return smInstance.mProfileUniverse;
         }
         return null;
      }
      
      public static function setItemOutlinePending(param1:ItemObject) : void
      {
         smItemOutlinePending = param1;
      }
      
      private function loadCRMCustomizer() : void
      {
         if(Config.USE_CRM_POPUPS)
         {
            try
            {
               CustomizerManager.getInstance().loadCrmPopups();
            }
            catch(e:Error)
            {
               Debug.trace("" + e.toString());
            }
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.end();
         this.loadingDestroy();
         if(Config.DEBUG_MODE)
         {
            Map.debugDestroy();
         }
         if(this.mUserDataFacade != null)
         {
            this.mUserDataFacade.destroy();
            this.mUserDataFacade = null;
         }
         if(this.mProfile != null)
         {
            this.mProfile.destroy();
            this.mProfile = null;
         }
         if(this.mProfileUniverse != null)
         {
            this.mProfileUniverse.destroy();
            this.mProfileUniverse = null;
         }
         if(this.mWorld != null)
         {
            this.mWorld.destroy();
            this.mWorld = null;
         }
         var _loc1_:int = 0;
         while(_loc1_ < ROLE_COUNT)
         {
            this.mRoles[_loc1_].destroy();
            this.mRoles[_loc1_] = null;
            _loc1_++;
         }
         this.mRoles = null;
         this.mFriendsBar.destroy();
         this.mFriendsBar = null;
         this.mOptionsPanel.destroy();
         this.mOptionsPanel = null;
         if(this.mBuyBox != null)
         {
            this.mBuyBox.destroy();
            this.mBuyBox = null;
         }
         this.messagesDestroy();
      }
      
      public function visitWorld(param1:int, param2:int) : void
      {
         var _loc3_:Company = null;
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("------ STEP Start " + param2);
         }
         if(param2 >= VIEW_UNATTACH_WORLD_STEP_START && param2 <= VIEW_UNATTACH_WORLD_STEP_END)
         {
            this.mUniverse.currentWorldID = param1;
            this.mProfile.setUpdateCompanyValueEnabled(false);
            this.viewUnattachWorld(this.mWorld);
         }
         else if(param2 >= DESTROY_WORLD_STEP_START && param2 <= DESTROY_WORLD_STEP_END)
         {
            this.mWorld.destroy();
            this.mWorld = null;
            this.mWorld = new World();
         }
         else if(param2 >= SET_PERSISTENCE_WORLD_STEP_START && param2 <= SET_PERSISTENCE_WORLD_STEP_END)
         {
            this.mWorld.setPersistence(this.mUniverse.getWorldPersistence(param1));
            UpgradesManager.getInstance().load();
         }
         else if(param2 >= BUILD_WORLD_STEP_START && param2 <= BUILD_WORLD_STEP_END)
         {
            this.mWorld.build(param2 - BUILD_WORLD_STEP_START);
         }
         else if(param2 >= ATTACH_ROLE_STEP_START && param2 <= ATTACH_ROLE_STEP_END)
         {
            setTimeOffset(UserDataFacade.getInstance().getTimeOffset());
            _loc3_ = this.mWorld.getCompanyMine();
            _loc3_.synchronizeDataWithProfile();
            if(this.mCurrentRole == ROLE_VISITOR)
            {
               UpgradesManager.getInstance().setNeighborId(this.mUniverse.owner);
            }
            this.mWorld.attachRole(this.mRoles[this.mCurrentRole]);
         }
         else if(param2 >= VIEW_ATTACH_WORLD_START && param2 <= VIEW_ATTACH_WORLD_END)
         {
            this.viewAttachWorld(this.mWorld);
            this.mProfile.setUpdateCompanyValueEnabled(true);
            if(this.mCurrentRole == ROLE_OWNER)
            {
               this.mProfile.calculateCompanyValue();
               FriendsManager.mNeighborMyself.companyValue = this.mProfile.companyValue;
            }
            else if(this.mCurrentRole == ROLE_VISITOR)
            {
               if(!getProfile().firstVisit)
               {
                  this.mPopupVisit = new PopupVisit();
                  this.mPopupVisit.addEventListener(Popup.EVENT_CLOSE,this.onCloseVisit);
               }
               if(getProfile().firstVisit)
               {
                  this.visitCheckGiveReward();
               }
            }
            TrafficAgentManagerDefinition.getInstance().setBuildParameters();
            if(Config.USE_SOUNDS)
            {
               SoundManager.getInstance().stopSound(ModelConfig.SOUND_RONALD);
               SoundManager.getInstance().stopSound(ModelConfig.SOUND_TUTORIAL);
               SoundManager.getInstance().stopSound(ModelConfig.SOUND_MAIN);
               if(SoundManager.getInstance().isMusicOn())
               {
                  SoundManager.getInstance().playSound(this.getCurrentMusic(),1,0,-1);
               }
            }
         }
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("------ STEP End " + param2);
         }
      }
      
      private function visitGetRewardCoins(param1:Boolean, param2:String) : int
      {
         var _loc6_:Array = null;
         var _loc7_:ItemDefinition = null;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc3_ += RulesFacade.getInstance().dailyBonusValue();
         }
         var _loc4_:Boolean = param1 && this.mProfile.registerEventsGet(Profile.REGISTER_EVENT_NPC_INCOME + "Advisor") > 0;
         var _loc5_:Boolean = param2 != null && this.mProfile.registerEventsGet(Profile.REGISTER_EVENT_NPC_INCOME + param2) > 0;
         if(_loc4_ || _loc5_)
         {
            _loc6_ = ItemDefinitionManager.getInstance().getDefinitions(ItemDefinition.TYPE_WONDERS_ID);
            for each(_loc7_ in _loc6_)
            {
               if(_loc7_.isSubtypeOf(Profile.REGISTER_EVENT_NPC_INCOME))
               {
                  if(_loc5_ && _loc7_.target == param2 || _loc4_ && _loc7_.target == "Advisor")
                  {
                     _loc3_ += _loc7_.getIncomeValue();
                  }
               }
            }
         }
         return _loc3_;
      }
      
      public function startTutorial() : void
      {
         this.mTutoTimerID = setTimeout(this.launchTutorial,3000);
         Tutorial.disableButtons();
         var _loc1_:Role = this.mRoles[ROLE_OWNER];
         _loc1_.toolsBar.setBossButton(true);
         _loc1_.toolsBar.disableButton(ToolsBar.BOSS_BUTTON,true);
         FriendsManager.changeBoss();
      }
      
      private function messagesDestroy() : void
      {
         this.mMessages = null;
      }
      
      private function pauseGame() : void
      {
         this.mGamePaused = true;
         mGameClip.mouseChildren = false;
         mGameClip.mouseEnabled = false;
         Dollars.smStage.mouseChildren = false;
      }
      
      public function init() : void
      {
         this.load();
         Dollars.smStage.addEventListener(Event.RESIZE,this.onResize);
         MouseWheelEnabler.init(Dollars.smStage,true);
         if(!this.mScrollEnabled)
         {
            this.mScrollEnabled = true;
            Dollars.smStage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onScrollMouse);
         }
      }
      
      private function onCloseDailyIncome(param1:Event) : void
      {
         this.mPopupDailyIncome.removeEventListener(Popup.EVENT_CLOSE,this.onCloseDailyIncome);
         this.mPopupDailyIncome = null;
         var _loc2_:String = this.visitGetNpcSku();
         WelcomeProgress.setDailyBonusTime(_loc2_,RulesFacade.getInstance().dailyBonusTimeInit());
         getCurrentWorld().getCompanyMine().DCCoins = getCurrentWorld().getCompanyMine().DCCoins + this.visitGetRewardCoins(this.visitIsBoss(),_loc2_);
         UserDataFacade.getInstance().updateMoney("dailyBonusDone",{});
      }
      
      private function destroyWelcome(param1:Event) : void
      {
         this.mWelcomProgress.removeEventListener(WelcomeProgress.EVENT_WELCOME_END,this.destroyWelcome);
         this.mWelcomProgress = null;
      }
      
      private function visitGetNpcIdFromUserId(param1:int) : int
      {
         var _loc2_:int = UserDataFacade.getInstance().getNPCIdFromUserId(param1);
         if(RulesFacade.getInstance().npcsIsAdvisor(_loc2_))
         {
            _loc2_ += this.mProfile.bossGenre;
         }
         return _loc2_;
      }
      
      private function loadingInitSoundManager() : void
      {
         if(Config.USE_SOUNDS)
         {
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "main.mp3",ModelConfig.SOUND_MAIN,SoundManager.TYPE_MUSIC);
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "tycoon.mp3",ModelConfig.SOUND_RONALD,SoundManager.TYPE_MUSIC);
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "money.mp3",ModelConfig.SOUND_INCOME,SoundManager.TYPE_SFX);
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "contract.mp3",ModelConfig.SOUND_CONTRACT,SoundManager.TYPE_SFX);
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "build.mp3",ModelConfig.SOUND_BUILD,SoundManager.TYPE_SFX);
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "bulldoze.mp3",ModelConfig.SOUND_DESTROY,SoundManager.TYPE_SFX);
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "levelup.mp3",ModelConfig.SOUND_LEVEL,SoundManager.TYPE_SFX);
            SoundManager.getInstance().addExternalSound(Config.getRoot() + ModelConfig.DIR_SOUNDS + "tutorial2.mp3",ModelConfig.SOUND_TUTORIAL,SoundManager.TYPE_MUSIC);
         }
      }
      
      private function magazineOnClose(param1:Event) : void
      {
         this.mMagazine.removeEventListener(Popup.EVENT_CLOSE,this.magazineOnClose);
         this.mMagazine = null;
         PriorityLoader.getInstance().unload(NewsPaper.MAGAZINE_SKU);
      }
      
      override public function exit() : void
      {
         super.exit();
         this.mPopupConection.destroy();
         this.mPopupConection = null;
         this.mPopupGamePlayConection.destroy();
         this.mPopupGamePlayConection = null;
         this.mPopupOutOfSync.destroy();
         this.mPopupOutOfSync = null;
         if(this.mPopupPaymentFail != null)
         {
            this.mPopupPaymentFail.destroy();
            this.mPopupPaymentFail = null;
         }
         var _loc1_:Cursor = this.getCurrentCursor();
         if(_loc1_ != null)
         {
            _loc1_.end();
         }
      }
      
      public function launchTutorial() : void
      {
         clearTimeout(this.mTutoTimerID);
         this.mPopupTutorial = new PopupTutorial(mGameClip);
         Tutorial.welcomeTutorial();
      }
      
      public function reduceHelpTime() : void
      {
         this.mPopupHelpTimer = 1;
      }
      
      private function onShowBuyBox(param1:Event) : void
      {
         var _loc2_:Role = this.mRoles[this.mCurrentRole];
         this.mBuyBox.addEventListener(Popup.EVENT_CLOSE,this.closeBox);
         mGameClip.mouseChildren = false;
         mGameClip.mouseEnabled = false;
         this.mBuyBox.start(false);
         mPopupClip.addChild(this.mBuyBox.getForm());
         _loc2_.toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
         this.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         this.mShopIsOpen = true;
         if(this.mShopSearch != null)
         {
            this.mBuyBox.searchItem(this.mShopSearch);
         }
      }
      
      private function ronaldsCityStateIsRequired() : Boolean
      {
         return UserDataFacade.getInstance().isTutorialRequired() && !Tutorial.smTutorialEnd;
      }
      
      private function messagesLogicUpdate(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc5_:PopupCollectables = null;
         var _loc6_:FreeGiftDefinition = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         while(_loc4_ < this.mMessages.length)
         {
            _loc2_ = this.mMessages[_loc4_];
            if(this.messagesIsAllowedToBeProcessed(_loc2_.cmd))
            {
               switch(_loc2_.cmd)
               {
                  case MESSAGES_BECOME_PARTNER:
                     UpgradesManager.getInstance().partnersBecomePartner(_loc2_.extId);
                     DollarsGame.smInstance.mFriendsBar.refreshFriend(_loc2_.id);
                     break;
                  case MESSAGES_ACCEPT_COLLECTIBLE:
                     _loc5_ = PopupCollectibleManager.getInstance().smPopupCollectibleShop;
                     if(_loc5_ != null && CollectibleManager.getInstance().wouldThisCollectibleCompleteTheGroup(_loc2_.collectibleSku))
                     {
                        this.popupsClosePopupsFromIndex(this.popupsGetPopupIndex(_loc5_));
                     }
                     CollectibleManager.getInstance().keepCollectible(_loc2_.collectibleSku,true);
                     if(_loc5_ != null)
                     {
                        _loc5_.refreshGroups();
                     }
                     break;
                  case MESSAGES_GIVE_BONUS:
                     getProfile().bonusArrayApply(_loc2_.bonusArray);
                     break;
                  case MESSAGES_FREE_GIFT:
                     _loc6_ = FreeGiftDefinitionManager.getInstance().getDefinitionBySku(_loc2_.freeGiftSku) as FreeGiftDefinition;
                     if(_loc6_ != null)
                     {
                        _loc7_ = 1;
                        _loc8_ = _loc6_.giftType;
                        switch(_loc6_.giftType)
                        {
                           case "move":
                              _loc7_ = int(_loc6_.value);
                              break;
                           case "item":
                              _loc8_ = _loc6_.value;
                        }
                        StorageManager.getInstance().addItem(_loc8_,_loc7_);
                        StorageManager.getInstance().sortStorage();
                     }
                     break;
                  case MESSAGES_ADD_NEIGHBOR:
                     UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_NEIGHBOR_LIST_RELOAD);
                     break;
                  case MESSAGES_REMOVE_NEIGHBOR:
                     UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_NEIGHBOR_LIST_RELOAD);
                     break;
                  case MESSAGES_FAN_POPUP_CLOSED:
                     UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_IS_FAN);
               }
               this.mMessages.shift();
            }
            else
            {
               _loc4_++;
            }
         }
      }
      
      public function loadingDestroy() : void
      {
         this.mLoadingScreen.destroy();
         this.mLoadingScreen = null;
      }
      
      public function showBuyBox(param1:String = null) : void
      {
         this.mShopSearch = param1;
         this.onShowBuyBox(null);
      }
      
      private function messagesLoad() : void
      {
         this.mMessages = new Vector.<Object>();
      }
      
      private function loadGameConfig() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_GAME_CONFIG);
         if("@music" in _loc1_)
         {
            SoundManager.getInstance().setMusicOn(Boolean(int(_loc1_.@music)));
         }
         else
         {
            SoundManager.getInstance().setMusicOn(true);
         }
         if("@sound" in _loc1_)
         {
            SoundManager.getInstance().setSfxOn(Boolean(int(_loc1_.@sound)));
         }
         else
         {
            SoundManager.getInstance().setSfxOn(true);
         }
         if("@quality" in _loc1_)
         {
            _loc2_ = Boolean(int(_loc1_.@quality));
            if(_loc2_)
            {
               Dollars.changeQuality(StageQuality.HIGH);
            }
            else
            {
               Dollars.changeQuality(StageQuality.LOW);
            }
         }
         else
         {
            Dollars.changeQuality(StageQuality.LOW);
         }
         if(Config.USE_CLIMATE)
         {
            ClimateManager.getInstance().enable = Dollars.smStage.quality.toLocaleLowerCase() == StageQuality.HIGH.toLowerCase();
         }
         this.mConfigLoaded = true;
         Dollars.updateGameConfig();
      }
      
      private function visitGetNpcSku(param1:int = -1) : String
      {
         if(param1 == -1)
         {
            param1 = this.mUniverse.owner;
         }
         var _loc2_:int = this.visitGetNpcIdFromUserId(param1);
         return RulesFacade.getInstance().npcsGetSku(_loc2_);
      }
      
      public function viewAttachWorld(param1:World) : void
      {
         var oldHud:Hud;
         var hud:Hud;
         var toolsBar:ToolsBar;
         var cursor:Cursor;
         var world:World = param1;
         PollManager.getInstance().setEnabled(true);
         mGameClip.addChild(world.map);
         hud = this.mRoles[this.mCurrentRole].hud;
         oldHud = null;
         if(this.mCurrentRole == ROLE_VISITOR)
         {
            oldHud = this.mRoles[ROLE_OWNER].hud;
         }
         try
         {
            this.changeHelpType();
         }
         catch(e:Error)
         {
            Debug.trace(e.toString());
         }
         hud.start(oldHud);
         mGameClip.addChild(hud);
         ParticlesManager.init();
         this.mFriendsBar.start();
         mGameClip.addChild(this.mFriendsBar.getBackground());
         toolsBar = this.mRoles[this.mCurrentRole].toolsBar;
         toolsBar.start(world.map);
         toolsBar.setToolbarConfig(this.mCurrentRole == ROLE_VISITOR);
         mGameClip.addChild(toolsBar.getDisplayObject());
         this.mOptionsPanel.start();
         mGameClip.addChild(this.mOptionsPanel);
         cursor = this.mRoles[this.mCurrentRole].cursor;
         cursor.start();
         mCursorClip.addChild(cursor);
         this.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         this.mViewWorldAttached = true;
         mGameClip.visible = false;
      }
      
      public function start() : void
      {
      }
      
      private function resetPopupHelpTimer(param1:MouseEvent = null) : void
      {
         this.mPopupHelpTimer = RulesFacade.helpPopupTimer + this.mPopupHelpTimerRandom;
         this.mPopupHelpShown = false;
      }
      
      public function viewUnattachWorld(param1:World = null) : void
      {
         var _loc2_:Hud = null;
         var _loc3_:ToolsBar = null;
         var _loc4_:Cursor = null;
         if(this.mViewWorldAttached)
         {
            PollManager.getInstance().setEnabled(false);
            if(this.mPlane != null)
            {
               this.mPlane.removePlane();
            }
            ParticlesManager.reset();
            mGameClip.removeChild(param1.map);
            _loc2_ = this.mRoles[this.mCurrentRole].hud;
            _loc2_.end();
            mGameClip.removeChild(_loc2_);
            _loc3_ = this.mRoles[this.mCurrentRole].toolsBar;
            _loc3_.end();
            mGameClip.removeChild(_loc3_.getDisplayObject());
            this.mOptionsPanel.end();
            mGameClip.removeChild(this.mOptionsPanel);
            this.mFriendsBar.end();
            mGameClip.removeChild(this.mFriendsBar.getBackground());
            _loc4_ = this.mRoles[this.mCurrentRole].cursor;
            _loc4_.end();
            mCursorClip.removeChild(_loc4_);
            this.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
            MessageManager.getInstance().setVisible(false);
            DollarsEventManager.getInstance().destroy();
            this.mViewWorldAttached = false;
            InvestManager.getInstance().destroy();
         }
      }
      
      private function onCloseVisit(param1:Event) : void
      {
         this.mPopupVisit.removeEventListener(Popup.EVENT_CLOSE,this.onCloseVisit);
         this.mPopupVisit.destroy();
         this.mPopupVisit = null;
         getProfile().firstVisit = true;
         getProfile().firstVisitDone();
         this.visitCheckGiveReward();
      }
      
      private function onResize(param1:Event) : void
      {
         if(this.mRoles != null && this.mRoles[this.mCurrentRole] != null)
         {
            this.mRoles[this.mCurrentRole].hud.resize();
            this.mFriendsBar.resize();
            this.mRoles[this.mCurrentRole].toolsBar.resize();
            this.mOptionsPanel.resize();
            Dollars.backgroundResize();
            if(this.mMagazine != null)
            {
               this.mMagazine.resize();
            }
            Dollars.smStage.dispatchEvent(new Event(EVENT_FULLSCREEN));
         }
      }
      
      private function popupsGetPopupIndex(param1:Popup) : int
      {
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         var _loc5_:DisplayObject = null;
         var _loc2_:* = -1;
         if(param1 != null)
         {
            _loc3_ = mPopupClip.numChildren;
            _loc5_ = param1.getForm();
            _loc2_ = int(_loc3_ - 1);
            while(_loc2_ > -1)
            {
               _loc4_ = mPopupClip.getChildAt(_loc2_);
               if(_loc4_ == _loc5_)
               {
                  break;
               }
               _loc2_--;
            }
         }
         return _loc2_;
      }
      
      override public function getCurrentCursor() : Cursor
      {
         if(smInstance.mCurrentRole != ROLE_NONE && smInstance.mRoles != null)
         {
            return smInstance.mRoles[smInstance.mCurrentRole].cursor;
         }
         return null;
      }
      
      public function onScrollMouse(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Sprite = null;
         if(!this.mGamePaused)
         {
            _loc2_ = 0.1;
            _loc3_ = mMainClip;
            if(mMainClip != null && this.mFriendsBar != null)
            {
               if(param1.delta > 0)
               {
                  this.mOptionsPanel.onZoomIn(null);
               }
               else
               {
                  this.mOptionsPanel.onZoomOut(null);
               }
            }
         }
      }
      
      private function popupsClosePopupsFromIndex(param1:int) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = mPopupClip.numChildren;
         var _loc4_:* = int(_loc2_ - 1);
         while(_loc4_ > param1)
         {
            _loc3_ = mPopupClip.getChildAt(_loc4_);
            if(_loc3_ is Popup)
            {
               Popup(_loc3_).onClose();
            }
            _loc4_--;
         }
      }
      
      public function loadingLoad() : void
      {
         this.mLoadingScreen = new LoadingState(getStateMachine());
      }
      
      public function getVersion() : int
      {
         var _loc1_:Array = Capabilities.version.split(",");
         return _loc1_[0].substr(4);
      }
      
      public function closeBox(param1:Event) : void
      {
         this.mBuyBox.destroy();
         this.mBuyBox.removeEventListener(Popup.EVENT_CLOSE,this.closeBox);
         mGameClip.mouseChildren = true;
         mGameClip.mouseEnabled = true;
         mPopupClip.removeChild(this.mBuyBox.getForm());
         this.mShopIsOpen = false;
      }
      
      private function toogleWorldAnimations(param1:Boolean) : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:ItemObject = null;
         if(param1)
         {
            Dollars.playChilds(getCurrentWorld().map.mItemObjectsLayerTop);
         }
         else
         {
            Dollars.stopChild(getCurrentWorld().map.mItemObjectsLayerTop);
         }
         _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine().getItems();
         for each(_loc3_ in _loc2_)
         {
            _loc3_.toggleAnimation(!param1);
         }
         return !param1;
      }
      
      public function visitUniverse(param1:int = -1) : void
      {
         if(this.mUniverse.owner != param1)
         {
            this.mUniverse.owner = param1;
            this.mUniverse.currentWorldID = 0;
            this.changeState(STATE_VISIT_WORLD);
            if(Config.USE_SOUNDS)
            {
               SoundManager.getInstance().stopAll(true,false);
            }
            if(param1 == DollarsGame.getProfile().owner)
            {
               this.mFriendsBar.centerFriendsBar();
            }
         }
      }
      
      public function getCurrentMusic() : String
      {
         var _loc1_:String = ModelConfig.SOUND_MAIN;
         if(this.mCurrentRole == ROLE_OWNER)
         {
            if(!Tutorial.smTutorialEnd)
            {
               _loc1_ = ModelConfig.SOUND_TUTORIAL;
            }
         }
         else if(this.mCurrentRole == ROLE_VISITOR)
         {
            if(UserDataFacade.getInstance().isNPC(this.mUniverse.owner))
            {
               _loc1_ = ModelConfig.SOUND_RONALD;
            }
            else
            {
               _loc1_ = ModelConfig.SOUND_VISIT_FRIEND;
            }
         }
         return _loc1_;
      }
      
      private function messagesIsAllowedToBeProcessed(param1:String) : Boolean
      {
         var _loc2_:Boolean = !this.mShowPopup && this.mCurrentRole == ROLE_OWNER;
         switch(param1)
         {
            case MESSAGES_ACCEPT_COLLECTIBLE:
               if(this.mShowPopup)
               {
                  _loc2_ = this.popupsGetPopupIndex(PopupCollectibleManager.getInstance().smPopupCollectibleShop) > -1;
               }
               break;
            case MESSAGES_BECOME_PARTNER:
               _loc2_ = UpgradesManager.getInstance().partnersIsLoaded();
               break;
            case MESSAGES_GIVE_BONUS:
               _loc2_ = !this.mShowPopup;
               break;
            case MESSAGES_FREE_GIFT:
               _loc2_ = true;
               break;
            case MESSAGES_ADD_NEIGHBOR:
               _loc2_ = Dollars.isFocusGame();
               break;
            case MESSAGES_REMOVE_NEIGHBOR:
               _loc2_ = Dollars.isFocusGame();
               break;
            case MESSAGES_FAN_POPUP_CLOSED:
               _loc2_ = true;
         }
         return _loc2_;
      }
      
      private function resumeGame() : void
      {
         this.mGamePaused = false;
         mGameClip.mouseChildren = true;
         mGameClip.mouseEnabled = true;
         Dollars.smStage.mouseChildren = true;
      }
      
      public function magazineShow() : void
      {
         this.mMagazine = new NewsPaper(PopupJournal.TYPE_MAGAZINE);
         this.mMagazine.start();
         this.mMagazine.addEventListener(Popup.EVENT_CLOSE,this.magazineOnClose);
      }
      
      private function changeState(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Map = null;
         var _loc6_:StateMachine = null;
         var _loc7_:FSMState = null;
         var _loc8_:Profile = null;
         var _loc9_:String = null;
         var _loc10_:NeighborObject = null;
         switch(this.mState)
         {
            case STATE_LOAD_RESOURCES:
               UnlockedListManager.getInstance().build();
               if(Config.DEBUG_ASSERTS)
               {
                  Debug.trace("build UnlockedListManager done");
               }
               LimEdManager.getInstance().build();
               if(Config.DEBUG_ASSERTS)
               {
                  Debug.trace("build LimEdManager done");
               }
               if(Config.COLLECTIBLE_FEATURE_ENABLED)
               {
                  CollectibleManager.getInstance().populate();
                  CollectibleManager.getInstance().build();
                  if(Config.COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED)
                  {
                     CollectiblePendingManager.getInstance().build();
                  }
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("buid CollectibleManager done");
                  }
               }
               this.mProfile = new Profile(this.mUniverse.owner,true);
               OfferManager.getInstance().build();
               StorageManager.getInstance().build();
               MissionDefinitionManager.getInstance().build();
               FreeGiftDefinitionManager.getInstance().buildSequenceData();
               if(Config.DAILY_BONUS_FEATURE_ENABLED)
               {
                  DailyBonusManager.getInstance().build();
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("build dailyBonus done");
                  }
               }
               this.loadCRMCustomizer();
         }
         this.mState = param1;
         switch(this.mState)
         {
            case STATE_PROGRAM_RESOURCES_TO_LOAD:
               MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_RESOURCES_TO_LOAD,0);
               UserDataFacade.getInstance().load();
               RulesFacade.getInstance().load();
               this.mLoadingScreen.enter();
               break;
            case STATE_LOAD_RESOURCES:
               MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_LOAD_RESOURCES,0);
               XMLTuner.getInstance();
               this.loadingInitSoundManager();
               this.loadingInitResourceManager();
               break;
            case STATE_VISIT_WORLD:
               Dollars.backgroundSetColor(16777215);
               if(this.mViewWorldAttached)
               {
                  this.mWorld.disable();
               }
               this.mLoadingScreen.skinSetId(LoadingState.SKIN_SIMPLE_ID);
               this.mLoadingScreen.enter(false);
               UserDataFacade.getInstance().flushUniverse();
               break;
            case STATE_REQUEST_WORLD:
               MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_REQUEST_WORLD,0);
               _loc2_ = new Object();
               _loc2_.userId = this.mUniverse.owner;
               UserDataFacade.getInstance().requestTask(UserDataFacade.TAG_UNIVERSE,_loc2_);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TAG_UPGRADES_LIST,_loc2_);
               UpgradesManager.getInstance().destroy();
               break;
            case STATE_BUILD_WORLD:
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_FACEBOOK_CREDITS_GET_BALANCE);
               MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_BUILD_WORLD,0);
               this.mLoadingOldPercent = this.mLoadingPercent;
               this.mLoadingBuildCurrentStep = 0;
               this.mLoadingBuildTotalSteps = LOADING_BUILD_TOTAL_STEPS;
               FriendsManager.preLoad();
               break;
            case STATE_RUN_WORLD:
               MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_RUN_WORLD,0);
               if(Config.DEBUG_ASSERTS)
               {
                  Debug.trace("==================  STATE_RUN_WORLD  ================");
               }
               FriendsManager.init();
               this.mLoadingScreen.exit();
               getCurrentRole().toolsBar.enable();
               this.mFriendsBar.enable();
               if(!isNaN(mScaleX))
               {
                  _loc5_ = getCurrentWorld().map;
                  _loc5_.scaleX = mScaleX;
                  _loc5_.scaleY = mScaleY;
                  _loc5_.calculateScrollBottomY();
                  _loc5_.cameraStart();
               }
               UserDataFacade.securityInit();
               _loc3_ = this.mProfile.cityname;
               _loc4_ = this.mProfile.planeSku;
               getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.SELECT_BUTTON);
               if(this.ronaldsCityStateIsRequired())
               {
                  MyMetrics.sendMetric(MetricConstants.EVENT_PLAY_TUTORIAL,MetricConstants.LABEL_TUTORIAL_LOADING);
                  _loc6_ = getStateMachine();
                  _loc7_ = new RonaldsCity(_loc6_);
                  getStateMachine().setNextState(_loc7_);
                  _loc3_ = getProfile().cityname;
                  this.mFriendsBar.getBackground().mouseChildren = false;
                  Dollars.smWelcomeDone = true;
               }
               else if(Tutorial.smTutorialEnd && !Dollars.smWelcomeDone && getCurrentRoleID() == ROLE_OWNER)
               {
                  this.mWelcomProgress = new WelcomeProgress();
                  this.mWelcomProgress.addEventListener(WelcomeProgress.EVENT_WELCOME_END,this.destroyWelcome);
                  this.mWelcomProgress.start();
                  Dollars.smWelcomeDone = true;
               }
               if(Tutorial.smTutorialEnd)
               {
                  if(PriorityLoader.getInstance().isLoaded(RonaldsCity.SKU))
                  {
                     PriorityLoader.getInstance().unload(RonaldsCity.SKU);
                  }
               }
               if(getCurrentRoleID() == ROLE_VISITOR)
               {
                  _loc8_ = getProfileUniverse();
                  _loc3_ = _loc8_.cityname;
                  _loc4_ = _loc8_.planeSku;
                  _loc9_ = MissionsEventIDs.MISSION_EVENT_VISIT_FRIEND;
                  if(this.mUniverse.owner == UserDataFacade.getInstance().mNPCSArray[0])
                  {
                     _loc9_ = MissionsEventIDs.MISSION_EVENT_VISIT_RONALD;
                  }
                  PollManager.getInstance().registerEvent(_loc9_);
                  _loc10_ = FriendsManager.getNeighborByID(this.mUniverse.owner);
                  if(_loc10_.isPartner())
                  {
                     PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_VISIT_PARTNER);
                  }
                  PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_VISIT_CITY);
               }
               if(_loc3_ != null)
               {
                  this.mPlane = new Plane(_loc4_);
                  this.mPlane.start(_loc3_);
               }
               mGameClip.visible = true;
               Dollars.backgroundSetColor(Background.BACKGROUND_COLOR);
               UserDataFacade.getInstance().queueRequestFlush();
               if(UserDataFacade.getInstance().isUserVIP())
               {
                  Debug.DEBUG = true;
               }
               if(getCurrentRoleID() == ROLE_OWNER && !UserDataFacade.taskLoadSuccessDone)
               {
                  UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_LOAD_SUCCESS,{"sig":RulesFacade.getInstance().sigGetTotal()});
               }
               smFPSCounter = new FPSCounter(0,0,0,true,16777215);
               Dollars.smStage.addChild(smFPSCounter);
               smFPSCounter.setVisible(Debug.visible);
               MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_LOADING),MetricConstants.EVENT_LOADING,MetricConstants.LABEL_LOAD_END,0);
               if(Config.BA_ENABLED)
               {
                  BAMetrics.getInstance().registerEvent("session","LoadCompleted");
               }
               if(this.mProfile.mMillionNewsFeed)
               {
                  PriorityLoader.getInstance().unload(NewsPaper.MAGAZINE_SKU);
               }
               if(this.mProfile.level > 7)
               {
                  PriorityLoader.getInstance().unload(NewsPaper.SKU);
               }
               this.onResize(null);
         }
      }
      
      private function getRandomHelpFriendTime() : void
      {
         var _loc1_:int = Math.random() * 100 > 50 ? 1 : -1;
         this.mPopupHelpTimerRandom = Math.random() * RulesFacade.helpPopupTimerThresHold * _loc1_;
      }
      
      override public function logicUpdate(param1:int) : void
      {
         var newRole:int = 0;
         var persistence:XML = null;
         var world:XML = null;
         var itemDefMng:ItemDefinitionManager = null;
         var companyXML:XML = null;
         var itemXML:XML = null;
         var itemDef:ItemDefinition = null;
         var dt:* = undefined;
         var crmDef:CRMCustomizerDefinition = null;
         var popup:Popup = null;
         var deltaTime:int = param1;
         PriorityLoader.getInstance().update();
         if(FBCreditsPurchase.getInstance().waitingForPurchaseProcess())
         {
            if(!this.mGamePaused)
            {
               this.pauseGame();
            }
         }
         else if(!FBCreditsPurchase.getInstance().waitingForPurchaseProcess() && this.mGamePaused)
         {
            this.resumeGame();
         }
         if(this.mEnabled && !this.mGamePaused)
         {
            if(this.loadingIsLoading())
            {
               this.loadingSetPercent();
            }
            switch(this.mState)
            {
               case STATE_PROGRAM_RESOURCES_TO_LOAD:
                  if(RulesFacade.getInstance().isLoaded())
                  {
                     this.changeState(STATE_LOAD_RESOURCES);
                  }
                  break;
               case STATE_LOAD_RESOURCES:
                  if(this.mLoadingPercent == LOADING_PERCENT_TO_LOAD_RESOURCES)
                  {
                     FiltersManager.load();
                     FiltersManager.catalogAddFilter(FILTER_GREY,FiltersManager.getSaturationFilter(0));
                     this.changeState(STATE_BUILD_WORLD);
                     if(Config.USE_OFFERPAL_EXTRA_OPTIONS)
                     {
                        PaymentManager.getInstance().load();
                     }
                  }
                  break;
               case STATE_VISIT_WORLD:
                  if(PriorityLoader.getInstance().getTotalProgress() >= 100)
                  {
                     this.changeState(STATE_REQUEST_WORLD);
                  }
                  break;
               case STATE_REQUEST_WORLD:
                  if(UserDataFacade.getInstance().isFileLoaded(UserDataFacade.TAG_UNIVERSE) && UserDataFacade.getInstance().isFileLoaded(UserDataFacade.TAG_UPGRADES_LIST))
                  {
                     this.changeState(STATE_BUILD_WORLD);
                  }
                  break;
               case STATE_BUILD_WORLD:
                  if(this.mLoadingBuildCurrentStep == 0)
                  {
                     this.mUniverse.read();
                     this.mCurrentRole = this.mUniverse.roleID;
                     if(!this.mProfile.isBuild())
                     {
                        if(this.ronaldsCityStateIsRequired())
                        {
                           PriorityLoader.getInstance().queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_DATA + "splash.swf",RonaldsCity.SKU,"swf");
                        }
                        if(Config.DEBUG_MODE)
                        {
                           Map.debugLoad();
                        }
                        this.mProfile.setPersistence(this.mUniverse.getProfilePersistence());
                        this.mProfile.build();
                        UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_MESSAGE_CENTER_ASK_FOR_OPEN);
                        WelcomeProgress.load();
                        this.mProfileUniverse = new Profile(this.mUniverse.owner,false);
                        this.mProfileUniverse.setPersistence(this.mUniverse.getProfilePersistence(),false);
                        this.mWorld = new World();
                        FriendsManager.loadSimple();
                        this.mRain = new NoteRain(NoteRain.BACKGROUND,50);
                        this.mRain2 = new NoteRain(NoteRain.FOREGROUND,10);
                        this.mFriendsBar = new FriendsBar();
                        this.mOptionsPanel = new OptionsPanel();
                        this.mRoles = new Array();
                        this.mRoles.push(new RoleOwner());
                        this.mRoles.push(new RoleEditor());
                        this.mRoles.push(new RoleVisitor());
                        if(this.mProfile.rankingPos == -1)
                        {
                           this.mProfile.rankingPos = FriendsManager.getSortedNeightbors().indexOf(FriendsManager.getNeighborByID(UserDataFacade.getInstance().mUserId));
                        }
                        this.mPopupConfirm = new PopupConfirm();
                        this.mPopupInstantBuild = new PopupTradeBox(PopupTradeBox.TYPE_INSTANT_BUILD);
                        this.mPopupInstantBuildSecondStep = new PopupInstantBuildSecondStep();
                        this.mPopupMsg = new PopupMessage();
                        this.mPopupMsgSmall = new PopupMessageSmall();
                        this.mPopupWonders = new PopupInstantBuild();
                        mPopupGold = new PopupGold();
                        mNumExtraOptions = PaymentManager.getInstance().paymentCount;
                        this.mPopupRentCollector = new PopupRentMoneyCollector();
                        if(Config.USE_TOOL_CONTRACT_SIGNATOR)
                        {
                           this.mPopupContractSignator = new PopupMultiContract();
                        }
                        this.mPopupServicePresentation = new PopupServicePresentation();
                        this.getRandomHelpFriendTime();
                        this.resetPopupHelpTimer();
                        Dollars.smStage.addEventListener(MouseEvent.MOUSE_MOVE,this.resetPopupHelpTimer);
                        this.mPopupContract = new ContractBoxSingle();
                        this.mPopupContractMultiple = new ContractBoxMultiple();
                        this.mBuyBox = new BuyBox(this.mRoles[this.mCurrentRole]);
                        this.mPlane = new Plane(this.mProfileUniverse.planeSku);
                        this.mProfile.servicesBuild();
                     }
                  }
                  else if(this.mLoadingBuildCurrentStep == 1)
                  {
                     newRole = ROLE_OWNER;
                     if(UserDataFacade.getInstance().isEditorEnabled())
                     {
                        newRole = ROLE_EDITOR;
                     }
                     else if(this.mUniverse.owner != this.mProfile.owner)
                     {
                        newRole = ROLE_VISITOR;
                     }
                     if(this.mCurrentRole != newRole || !this.mViewWorldAttached)
                     {
                        this.setRole(newRole);
                     }
                     if(newRole == ROLE_VISITOR)
                     {
                        persistence = this.mUniverse.getProfilePersistence();
                     }
                     else
                     {
                        persistence = this.mProfile.getPersistence(true);
                     }
                     this.mProfileUniverse.setPersistence(persistence,false);
                     this.mProfile.build(false);
                     MissionDefinitionManager.getInstance().reload();
                  }
                  else if(this.mLoadingBuildCurrentStep == LOAD_WORLD_RESOURCES_STEP_START)
                  {
                     if(Config.SMART_RESOURCE_LOADING)
                     {
                        world = this.mUniverse.getWorldPersistence(this.mUniverse.currentWorldID);
                        itemDefMng = ItemDefinitionManager.getInstance();
                        for each(companyXML in world.Company)
                        {
                           for each(itemXML in companyXML.Item)
                           {
                              itemDef = itemDefMng.getDefinitionBySku(itemXML.@sku) as ItemDefinition;
                              if(itemDef != null)
                              {
                                 itemDefMng.requestLoadResourcesByDefinition(itemDef,PriorityLoader.QUEUE_LOADING);
                              }
                           }
                        }
                     }
                     else
                     {
                        this.mLoadingBuildCurrentStep = LOAD_WORLD_RESOURCES_STEP_END;
                     }
                  }
                  else if(this.mLoadingBuildCurrentStep > LOAD_WORLD_RESOURCES_STEP_START && this.mLoadingBuildCurrentStep <= LOAD_WORLD_RESOURCES_STEP_END)
                  {
                     this.mLoadingBuildCurrentStep = LOAD_WORLD_RESOURCES_STEP_START + PriorityLoader.getInstance().queueProgress(PriorityLoader.QUEUE_LOADING);
                  }
                  else if(this.mLoadingBuildCurrentStep >= VISIT_WORLD_STEP_START && this.mLoadingBuildCurrentStep <= VISIT_WORLD_STEP_END)
                  {
                     this.visitWorld(this.mUniverse.currentWorldID,this.mLoadingBuildCurrentStep - VISIT_WORLD_STEP_START);
                  }
                  else if(this.mLoadingBuildCurrentStep == REPORT_HACKING_STEP_START)
                  {
                     if(getCurrentRoleID() == ROLE_OWNER && UserDataFacade.chk)
                     {
                        UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_LOAD_SUCCESS,{});
                     }
                  }
                  else if(this.mLoadingBuildCurrentStep == REPORT_HACKING_STEP_END)
                  {
                     if(getCurrentRoleID() == ROLE_OWNER && UserDataFacade.chk && !UserDataFacade.taskLoadSuccessDone || this.ronaldsCityStateIsRequired() && !DCResourceManager.getInstance().isResLoaded(RonaldsCity.SKU))
                     {
                        break;
                     }
                  }
                  else if(this.mLoadingBuildCurrentStep == REQUEST_DEFINITION_MANAGER_RESOURCES_STEP && Config.SMART_RESOURCE_LOADING)
                  {
                     ItemDefinitionManager.getInstance().requestLoadResourcesWithConditions(true,this.mProfile.level,this.mProfile.level + 3);
                  }
                  else if(this.mLoadingBuildCurrentStep == LOADING_BUILD_TOTAL_STEPS)
                  {
                     if(!this.mConfigLoaded)
                     {
                        this.loadGameConfig();
                     }
                     this.mOptionsPanel.load();
                     this.mWorld.getCompanyMine().sortItemsToBuild();
                     this.changeState(STATE_RUN_WORLD);
                  }
                  if(CustomizerManager.getInstance().getCRMStatus() != 0)
                  {
                     ++this.mLoadingBuildCurrentStep;
                  }
                  break;
               case STATE_RUN_WORLD:
                  FriendsManager.init();
                  do
                  {
                     if(smTimeOffset >= MAX_TIMER_MINUTES)
                     {
                        dt = MAX_TIMER_MS;
                        smTimeOffset -= MAX_TIMER_MINUTES;
                        this.resetPopupHelpTimer();
                     }
                     else
                     {
                        dt = deltaTime;
                        if(smTimeOffset > 0)
                        {
                           dt += TimerUtil.minToMs(smTimeOffset);
                           smTimeOffset = 0;
                        }
                     }
                     this.mWorld.buildUpdate(dt);
                     if(this.mShowPopup || this.mWelcomProgress != null)
                     {
                        if(!this.mIsWorldStopped)
                        {
                           this.mIsWorldStopped = this.toogleWorldAnimations(false);
                           this.mPlane.pause();
                           TrafficAgentManager.getInstance().pause();
                        }
                        if(this.mScrollEnabled)
                        {
                           this.mScrollEnabled = false;
                           Dollars.smStage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onScrollMouse);
                        }
                     }
                     else
                     {
                        if(this.mIsWorldStopped)
                        {
                           this.mIsWorldStopped = this.toogleWorldAnimations(true);
                           this.mPlane.resume();
                           TrafficAgentManager.getInstance().resume();
                        }
                        this.mWorld.logicUpdate(dt);
                        getCurrentRole().hud.logicUpdate(dt);
                        if(getCurrentRoleID() == ROLE_OWNER)
                        {
                           this.mProfile.checkLevelUpShow();
                        }
                        this.mPlane.logicUpdate(dt);
                        if(Config.cheatsAreEnabled(Config.CHEAT_TIME_ID))
                        {
                           this.time += deltaTime;
                        }
                        if(!this.mScrollEnabled)
                        {
                           this.mScrollEnabled = true;
                           Dollars.smStage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onScrollMouse);
                        }
                        if(Tutorial.smTutorialEnd)
                        {
                           MissionsIconLayerManager.getInstance().update(deltaTime);
                        }
                     }
                     if(CustomizerManager.getInstance().crmOfferState == CustomizerManager.CRM_OFFER_ENABLED)
                     {
                        CustomizerManager.getInstance().logicupdate(dt);
                     }
                     if(getCurrentRoleID() != ROLE_EDITOR)
                     {
                        this.mProfile.logicUpdate(dt);
                     }
                     if(this.mShopIsOpen)
                     {
                        this.mBuyBox.logicUpdate(dt);
                     }
                  }
                  while(smTimeOffset > 0);
                  try
                  {
                     if(this.mPopupHelpTimer > 0 && !this.mPopupHelpShown && Tutorial.smTutorialEnd && CustomizerManager.getInstance().crmEvent > -1)
                     {
                        this.mPopupHelpTimer -= deltaTime;
                        if(this.mPopupHelpTimer <= 0)
                        {
                           if(this.mShowPopup || this.mPopupHelpShown)
                           {
                              this.resetPopupHelpTimer(null);
                           }
                           else
                           {
                              crmDef = CustomizerManager.getInstance().getCrmPopupDefinition(CRMCustomizerDefinition.TYPE_IDLE,this.mPopupHelpType);
                              if(crmDef != null)
                              {
                                 if(crmDef.format == CRMCustomizerDefinition.FORMAT_IDLE)
                                 {
                                    popup = new PopupHelpFriend(crmDef);
                                 }
                                 else
                                 {
                                    popup = new PopupCrm(crmDef);
                                 }
                                 popup.showPopup();
                                 popup.addEventListener(Popup.EVENT_CLOSE,this.closeHelpPopup);
                                 Dollars.smStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.resetPopupHelpTimer);
                                 this.mPopupHelpShown = true;
                              }
                           }
                        }
                     }
                  }
                  catch(e:Error)
                  {
                     Debug.trace(e.toString());
                  }
                  if(Config.cheatsAreEnabled(Config.CHEAT_TIME_ID))
                  {
                     this.mFriendsBar.setTime(this.time);
                  }
                  this.mFriendsBar.logicUpdate(deltaTime);
                  if(getCurrentRoleID() == ROLE_OWNER)
                  {
                     InvestManager.getInstance().logicUpdate(deltaTime);
                     getCurrentRole().toolsBar.logicUpdate(deltaTime);
                  }
                  if(UserDataFacade.chk)
                  {
                     UserDataFacade.getInstance().logout();
                     if(!this.chkReported)
                     {
                        this.chkReported = true;
                        MyMetrics.send_GA_metric("OutOfSync","Client: chk error","" + UserDataFacade.getInstance().mUserExtId);
                     }
                  }
                  UserDataFacade.securityLogicUpdate();
                  WelcomeProgress.logicUpdate(deltaTime);
                  MessageManager.getInstance().logicUpdate(deltaTime);
                  ParticlesManager.update(deltaTime);
                  MissionObjectManager.getInstance().logicUpdate(deltaTime);
                  this.messagesLogicUpdate(deltaTime);
                  if(this.mPopupHireCrew != null && this.mPopupHireCrew.isOpen())
                  {
                     this.mPopupHireCrew.logicUpdate(dt);
                  }
            }
         }
      }
      
      public function finishRain(param1:Event) : void
      {
         var _loc2_:NoteRain = param1.target as NoteRain;
         _loc2_.removeEventListener(NoteRain.EVENT_RAIN_END,this.finishRain);
         _loc2_.end();
      }
      
      private function closeHelpPopup(param1:Event) : void
      {
         var e:Event = param1;
         var popup:Popup = e.target as Popup;
         popup.removeEventListener(Popup.EVENT_CLOSE,this.closeHelpPopup);
         Dollars.smStage.addEventListener(MouseEvent.MOUSE_MOVE,this.resetPopupHelpTimer);
         this.getRandomHelpFriendTime();
         this.resetPopupHelpTimer();
         try
         {
            CustomizerManager.getInstance().removePopupDefinition(this.mPopupHelpType);
            this.changeHelpType();
         }
         catch(e:Error)
         {
            Debug.trace(e.toString());
         }
         popup.destroy();
      }
      
      public function end() : void
      {
         this.setRole(ROLE_NONE);
      }
      
      public function loadingIsLoading() : Boolean
      {
         return this.mState != STATE_RUN_WORLD;
      }
      
      private function load() : void
      {
         Debug.trace("-----------------------------messagesLoad()");
         this.messagesLoad();
         this.mPopupConection = new PopupConnection(PopupConnection.TYPE_CONNECTION);
         this.mPopupGamePlayConection = new PopupConnection(PopupConnection.TYPE_GAME_PLAY_CONNECTION);
         this.mPopupOutOfSync = new PopupOutOfSync();
         this.changeState(STATE_PROGRAM_RESOURCES_TO_LOAD);
         this.mUserDataFacade = UserDataFacade.getInstance();
         this.mUniverse = new Universe();
         this.mUniverse.owner = this.mUserDataFacade.mUserId;
         this.mUniverse.currentWorldID = 0;
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         super.enter(param1);
         var _loc2_:Cursor = this.getCurrentCursor();
         if(_loc2_ != null)
         {
            _loc2_.start();
         }
      }
      
      private function changeHelpType() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:CRMCustomizerDefinition = null;
         var _loc1_:int = CustomizerManager.getInstance().getCountIdle();
         if(CustomizerManager.getInstance().crmEvent > -1 && _loc1_ > 0)
         {
            _loc2_ = int(Math.random() * (CustomizerManager.getInstance().rank() - 1));
            _loc3_ = 0;
            _loc4_ = 0;
            while(_loc4_ < _loc1_)
            {
               _loc5_ = CustomizerManager.getInstance().getCrmPopupDefinition(CRMCustomizerDefinition.TYPE_IDLE,_loc4_);
               _loc3_ += _loc5_.weight;
               if(_loc2_ < _loc3_)
               {
                  this.mPopupHelpType = _loc4_;
                  break;
               }
               _loc4_++;
            }
            _loc5_ = CustomizerManager.getInstance().getCrmPopupDefinition(CRMCustomizerDefinition.TYPE_IDLE,this.mPopupHelpType);
            if(_loc5_.actionButtonAction == ActionsLibrary.UPGRADE_FRIENDS || _loc5_.actionButtonAction == ActionsLibrary.VISIT_FRIEND)
            {
               if(!PopupHelpFriend.loadFriend())
               {
                  this.changeHelpType();
               }
            }
         }
      }
      
      private function visitIsBoss(param1:int = -1) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         if(param1 == -1)
         {
            param1 = this.mUniverse.owner;
         }
         if(UserDataFacade.getInstance().isNPC(param1))
         {
            _loc3_ = this.visitGetNpcIdFromUserId(param1);
            _loc2_ = RulesFacade.getInstance().npcsIsAdvisor(_loc3_);
         }
         return _loc2_;
      }
      
      private function getLoadingTime() : Number
      {
         var _loc1_:Date = new Date();
         var _loc2_:Number = _loc1_.getTime();
         var _loc3_:Number = _loc2_ - mLoadingTime;
         if(mLoadingTime != 0)
         {
            _loc3_ /= 1000;
         }
         mLoadingTime = _loc2_;
         return _loc3_;
      }
      
      public function messagesAddMessage(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Array = null;
         var _loc11_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < MESSAGES_COUNT && param1.search(MESSAGES_KEYS[_loc3_]) == -1)
         {
            _loc3_++;
         }
         var _loc4_:Boolean = _loc3_ < MESSAGES_COUNT;
         if(_loc4_)
         {
            _loc5_ = new Object();
            _loc7_ = param1.split(":");
            _loc8_ = int(_loc7_.length);
            _loc5_.cmd = _loc7_[0];
            _loc9_ = true;
            switch(_loc5_.cmd)
            {
               case MESSAGES_BECOME_PARTNER:
                  if(_loc8_ == 2)
                  {
                     _loc5_.extId = _loc7_[1];
                     break;
                  }
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " is malformed: the extId of the friend to become partner is missing");
                  }
                  _loc9_ = false;
                  break;
               case MESSAGES_ACCEPT_COLLECTIBLE:
                  if(_loc8_ == 2)
                  {
                     _loc5_.collectibleSku = _loc7_[1];
                     break;
                  }
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " is malformed: the collectible sku");
                  }
                  _loc9_ = false;
                  break;
               case MESSAGES_GIVE_BONUS:
                  if(_loc8_ > 1)
                  {
                     _loc10_ = new Array();
                     _loc3_ = 1;
                     while(_loc3_ < _loc8_ && _loc9_)
                     {
                        _loc11_ = _loc7_[_loc3_].split("_");
                        if(_loc11_.length != 2)
                        {
                           if(Config.DEBUG_ASSERTS)
                           {
                              Debug.trace("############# ERROR in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " bonus " + _loc7_[_loc3_] + " is malformed");
                           }
                           _loc9_ = false;
                        }
                        _loc10_.push(_loc11_);
                        _loc3_++;
                     }
                     if(_loc9_)
                     {
                        _loc5_.bonusArray = _loc10_;
                     }
                     break;
                  }
                  _loc9_ = false;
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " bonus information is missing");
                  }
                  break;
               case MESSAGES_FREE_GIFT:
                  if(_loc8_ == 2)
                  {
                     _loc5_.freeGiftSku = _loc7_[1];
                     break;
                  }
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " is malformed: the free gift sku");
                  }
                  _loc9_ = false;
                  break;
               case MESSAGES_ADD_NEIGHBOR:
                  if(_loc8_ == 1)
                  {
                     for each(_loc6_ in this.mMessages)
                     {
                        if(_loc6_.cmd == _loc5_.cmd)
                        {
                           Debug.trace("############# DEBUG in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " already added");
                           _loc9_ = false;
                        }
                     }
                     break;
                  }
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " is malformed");
                  }
                  _loc9_ = false;
                  break;
               case MESSAGES_REMOVE_NEIGHBOR:
                  if(_loc8_ == 2)
                  {
                     _loc5_.extId = _loc7_[1];
                     for each(_loc6_ in this.mMessages)
                     {
                        if(_loc6_.cmd == _loc5_.cmd)
                        {
                           Debug.trace("############# DEBUG in DollarsGame.messagesRemoveMessage(): message with key " + _loc5_.cmd + " already added");
                           _loc9_ = false;
                        }
                     }
                     break;
                  }
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in DollarsGame.messagesRemoveMessage(): message with key " + _loc5_.cmd + " is malformed");
                  }
                  _loc9_ = false;
                  break;
               case MESSAGES_FAN_POPUP_CLOSED:
                  if(_loc8_ != 1)
                  {
                     if(Config.DEBUG_ASSERTS)
                     {
                        Debug.trace("############# ERROR in DollarsGame.messagesAddMessage(): message with key " + _loc5_.cmd + " is malformed");
                     }
                     _loc9_ = false;
                  }
            }
            if(_loc9_)
            {
               this.mMessages.push(_loc5_);
            }
         }
         return _loc4_;
      }
      
      private function loadingSetPercent() : void
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         switch(this.mState)
         {
            case STATE_PROGRAM_RESOURCES_TO_LOAD:
               this.mLoadingPercent = 0;
               break;
            case STATE_LOAD_RESOURCES:
               this.mLoadingPercent = PriorityLoader.getInstance().queueProgress(PriorityLoader.QUEUE_LOADING);
               this.mLoadingPercent = this.mLoadingPercent * LOADING_PERCENT_TO_LOAD_RESOURCES / 100;
               if(!XMLTuner.getInstance().isLoaded() || !UserDataFacade.getInstance().isLoaded() || !UserDataFacade.getInstance().isLogged())
               {
                  this.mLoadingPercent = Math.max(0,this.mLoadingPercent - 1);
               }
               if(Config.DEBUG_ASSERTS)
               {
                  _loc1_ = DCResourceManager.getInstance().showFilesDueToLoad();
                  for each(_loc2_ in _loc1_)
                  {
                     trace("Waiting for: " + _loc2_);
                  }
               }
               break;
            case STATE_VISIT_WORLD:
               this.mLoadingPercent = PriorityLoader.getInstance().getTotalProgress();
               this.mLoadingPercent = this.mLoadingPercent * LOADING_PERCENT_TO_LOAD_RESOURCES / 100;
               break;
            case STATE_REQUEST_WORLD:
               this.mLoadingPercent = LOADING_PERCENT_TO_LOAD_RESOURCES;
               break;
            case STATE_BUILD_WORLD:
               this.mLoadingPercent = this.mLoadingOldPercent + (100 - this.mLoadingOldPercent) * this.mLoadingBuildCurrentStep / this.mLoadingBuildTotalSteps;
         }
         this.mLoadingScreen.setPercent(this.mLoadingPercent);
      }
      
      private function loadingInitResourceManager() : void
      {
         var _loc1_:PriorityLoader = PriorityLoader.getInstance();
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.CONTRACT_PNG,ModelConfig.CONTRACT_PNG_SKU,"BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.RENT_PNG,ModelConfig.RENT_PNG_SKU,"BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.HOUSES_RENT_SWF,Config.getRoot() + ModelConfig.HOUSES_RENT_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_GUI + "expansions.swf",PopupConfirmExpansion.SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_GUI + "Missions.swf",MissionsBox.SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_DATA + "plain.swf",Plane.PLAIN_SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_DATA + "newspaper.swf",NewsPaper.SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_DATA + "magazine_cover.swf",NewsPaper.MAGAZINE_SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_PICS + "hud/hud.swf",DollarsGame.HUD_SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_MISSIONS + "missions_layout.swf","missions_layout",".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_TERRAIN + "terrain.swf",Background.TERRAIN_SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_TILESET + "tileset.png","tileset","BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_PICS + "terrain/fence.swf",Background.FENCE_SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_GUI + "investment.swf",PopupInvest.SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_GUI + "contracts.swf",ContractBox.SKU,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.VISITOR_UPGRADES_SWF,Config.getRoot() + ModelConfig.VISITOR_UPGRADES_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.VISITOR_SUPER_UPGRADES_SWF,Config.getRoot() + ModelConfig.VISITOR_SUPER_UPGRADES_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.HOUSE_UPGRADED_SWF,Config.getRoot() + ModelConfig.HOUSE_UPGRADED_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.HOUSE_SUPER_UPGRADED_SWF,Config.getRoot() + ModelConfig.HOUSE_SUPER_UPGRADED_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.CONTRACT_SWF,Config.getRoot() + ModelConfig.CONTRACT_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.COLLECTABLES_SWF,Config.getRoot() + ModelConfig.COLLECTABLES_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.COLLECTIBLES_EVENT_SWF,Config.getRoot() + ModelConfig.COLLECTIBLES_EVENT_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.BUILDING_STATE_SWF,Config.getRoot() + ModelConfig.BUILDING_STATE_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.STORAGE_SWF,Config.getRoot() + ModelConfig.STORAGE_SWF,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.BUTTON_LIBRARY,Config.getRoot() + ModelConfig.BUTTON_LIBRARY,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.EXCHANGE_FBCREDITS_TO_CASH,Config.getRoot() + ModelConfig.EXCHANGE_FBCREDITS_TO_CASH,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_CONFIRM,Config.getRoot() + ModelConfig.POPUP_CONFIRM,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_INSTANT_BUILD,Config.getRoot() + ModelConfig.POPUP_INSTANT_BUILD,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_CONFIRM_BUILD,Config.getRoot() + ModelConfig.POPUP_CONFIRM_BUILD,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_CREW_MECHANICS,Config.getRoot() + ModelConfig.POPUP_CREW_MECHANICS,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_SHOP,Config.getRoot() + ModelConfig.POPUP_SHOP,".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_POPUPS + "popup_standard.swf","popup_standard.swf","swf");
         if(Config.USE_BITMAP_DATA_ANIMATIONS)
         {
            _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_ITEMS_COMMERCE_TYPES + "icons.swf","icons",".swf");
         }
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_ITEMS + "decorations_christmas_07.swf","decorations_christmas_07",".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_ITEMS + "decorations_christmas_10.swf","decorations_christmas_10",".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_ITEMS + "decorations_pond_03.swf","decorations_pond_03",".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_ITEMS + "houses_037_001_Ronald.swf","houses_037_001_Ronald",".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_ITEMS + "houses_037_001_Cindy.swf","houses_037_001_Cindy",".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_PLANES + "plane_show.swf","plane_show",".swf");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_COMMON + "blue_stars.png","blue_stars","BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_COMMON + "popup_reward_coins.png","popup_reward_coins","BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_COMMON + "popup_reward_exp.png","popup_reward_exp","BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.POPUP_COMMON + "popup_stars.png","popup_stars","BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.BUTTON_COMMON + "cash.png","cash","BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.BUTTON_COMMON + "fbc.png","fbc","BitmapData");
         _loc1_.queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.BUTTON_COMMON + "gold.png","gold","BitmapData");
      }
      
      private function visitCheckGiveReward() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         if(UserDataFacade.getInstance().isNPC(this.mUniverse.owner))
         {
            _loc1_ = this.visitGetNpcIdFromUserId(this.mUniverse.owner);
            _loc2_ = RulesFacade.getInstance().npcsIsAdvisor(_loc1_);
            _loc3_ = RulesFacade.getInstance().npcsGetSku(_loc1_);
            if(WelcomeProgress.isDailyBonusAllowed(_loc3_))
            {
               if(_loc2_ || this.mProfile.registerEventsGet(Profile.REGISTER_EVENT_NPC_INCOME + _loc3_) > 0)
               {
                  this.mPopupDailyIncome = new PopupDailyIncome();
                  this.mPopupDailyIncome.showPopupParams(this.visitGetRewardCoins(_loc2_,_loc3_));
                  this.mPopupDailyIncome.addEventListener(Popup.EVENT_CLOSE,this.onCloseDailyIncome);
               }
            }
         }
      }
      
      public function setRole(param1:int) : void
      {
         this.viewUnattachWorld(this.mWorld);
         this.mCurrentRole = param1;
         this.mUniverse.roleID = this.mCurrentRole;
         var _loc2_:Role = this.mRoles[this.mCurrentRole];
         _loc2_.start();
         if(_loc2_.usesMaxExp())
         {
            this.mProfile.level = RulesFacade.maxLevel;
         }
      }
   }
}

