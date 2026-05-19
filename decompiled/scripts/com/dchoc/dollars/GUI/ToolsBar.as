package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.GUI.Collectibles.NewCollectibleBar;
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.tools.Tool;
   import com.dchoc.dollars.map.tools.ToolBuild;
   import com.dchoc.dollars.map.tools.ToolDecorator;
   import com.dchoc.dollars.missions.MissionDefinitionManager;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.offers.OfferManager;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.math.Vector2D;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.utils.AssetManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.GTweenTimeline;
   import com.gskinner.motion.easing.Bounce;
   import com.gskinner.motion.easing.Linear;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class ToolsBar
   {
      
      public static const SHOW_BUY_BOX_EVENT:String = "ShowBuyBox";
      
      public static const SHOW_BUY_SPECIAL_BOX_EVENT:String = "ShowBuySpecialBox";
      
      public static const SHOW_COLLECTIBLE_BAR_EVENT:String = "ShowCollectibleBar";
      
      public static const EVENT_ENABLE_COLLECTIBLES:String = "EventEnableCollectibles";
      
      public static const EVENT_ENABLE_INVESTMENTS:String = "EventEnableInvestments";
      
      public static const TOOL_SELECT_ID:uint = 0;
      
      public static const TOOL_TERRAIN_ID:uint = 1;
      
      public static const TOOL_BUILD_ID:uint = 2;
      
      public static const TOOL_DESTROY_ID:uint = 3;
      
      public static const TOOL_MOVE_ID:uint = 4;
      
      public static const TOOL_MONEY_COLLECTOR_ID:uint = 5;
      
      public static const TOOL_CONTRACT_SIGNATOR_ID:uint = 6;
      
      public static const TOOL_ROAD_ID:uint = 7;
      
      public static const TOOL_RENT_ACCELERATOR:uint = 8;
      
      public static const TOOL_SOLID_ID:uint = 9;
      
      public static const TOOL_DEFAULT_ID:uint = TOOL_SELECT_ID;
      
      public static const SELECT_BUTTON:int = 0;
      
      public static const BUILD_BUTTON:int = 1;
      
      public static const DEMOLITION_BUTTON:int = 2;
      
      public static const ROAD_BUTTON:int = 3;
      
      public static const BUY_TERRAIN_BUTTON:int = 4;
      
      public static const VAULT_BUTTON:int = 5;
      
      public static const BOSS_BUTTON:int = 6;
      
      public static const HOME_BUTTON:int = 7;
      
      public static const INVEST_BUTTON:int = 8;
      
      public static const MULTI_FUNCTION_BUTTON:int = 9;
      
      public static const PARTNER_BUTTON:int = 10;
      
      public static const TOTAL_BUTTONS:int = 11;
      
      public static const SELECT_VIDEO_BUTTON:int = 12;
      
      public static const ZOOM_MIN:Number = 0.25;
      
      private static const TWEEN_JUMP_LENGTH:Number = 0.5;
      
      public static const BOSS_ALERT_NONE:int = -1;
      
      public static const BOSS_ALERT_NEW_MISSION:int = 0;
      
      public static const BOSS_ALERT_MISSION_REACHED:int = 1;
      
      public static const BOSS_ALERT_NEW_MISSION_CLICK:int = 2;
      
      public static const BOSS_ALERT_MISSION_REACHED_CLICK:int = 3;
      
      public static const BOSS_ALERT_COUNT:int = 4;
      
      private var mFXStateBeforeVideo:Boolean = false;
      
      private var mBossAlertDO:Array;
      
      private var mVaultBar:VaultBar;
      
      public var mPopupInvest:PopupInvest;
      
      private var mGiftAlert:MovieClip;
      
      private var mCollectibleBarBuffer:Array;
      
      private var mBossGenre:int;
      
      private var mCollectibleCounter:int;
      
      private var mCurrentToolIndex:int;
      
      private var mGift:MovieClip;
      
      private var mHomeButton:DynamicButton;
      
      public var mToolBar:Sprite;
      
      private var mOldButton:DynamicButton;
      
      public var mInvestmentButtonReady:Boolean;
      
      private var mBossButton:DynamicButton;
      
      private var mVaultButton:DynamicButton;
      
      private var mJumpTweenTimeline:GTweenTimeline;
      
      private var mSelectButton:DynamicButton;
      
      private var mSuperupgradeArrow:MovieClip;
      
      private var mAlertOffers:MovieClip;
      
      private const BLINK_INTERVAL:int = 500;
      
      private var mBlinkId:int;
      
      private var mBuyButton:DynamicButton;
      
      private var mTools:Array;
      
      private var mInvestmentButton:DynamicButton;
      
      private var mBossSprites:Array;
      
      private var mRole:Role;
      
      private var mTerrainTutorial:Boolean;
      
      private var mPopupPartner:PopupPartner;
      
      private var videoButton:DynamicButton;
      
      private var mBuildButton:DynamicButton;
      
      private var mVaultAlert:MovieClip;
      
      private var mDemolitionButton:DynamicButton;
      
      private var mCurrentButton:DynamicButton;
      
      private var mRoadTutorial:Boolean;
      
      private var mPartnerButton:DynamicButton;
      
      private var mMap:Map;
      
      private var mUpgradesButton:Array;
      
      private var mNextTool:int;
      
      private var mRoadButton:DynamicButton;
      
      private var mNewText:TextField;
      
      private var mMusicStateBeforeVideo:Boolean = false;
      
      private var mCollectibleBar:NewCollectibleBar;
      
      private var mInvestmentArrow:MovieClip;
      
      private var mCollectibleSku:String;
      
      private var mMultifunctionBar:MultifunctionBar;
      
      private var mJumpingButton:DynamicButton;
      
      private var mMissionArrow:MovieClip;
      
      public var mMissions:MissionsBox;
      
      private var mMultifunctionButton:DynamicButton;
      
      public function ToolsBar(param1:Role)
      {
         var _loc6_:String = null;
         var _loc7_:MovieClip = null;
         super();
         this.mToolBar = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"tool_panel"))();
         this.mSelectButton = new DynamicButton(this.mToolBar.getChildByName("SelectButton") as MovieClip);
         this.mSelectButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mSelectButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_SELECTOR));
         this.videoButton = new DynamicButton(this.mToolBar.getChildByName("selectvideo") as MovieClip);
         this.videoButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.videoButton.setTip(TextManager.getText(TextIDs.TID_INCENTIVICED_VIDEO_ADS));
         var _loc2_:MovieClip = this.mToolBar.getChildByName("BuildButton") as MovieClip;
         this.mBuildButton = new DynamicButton(_loc2_);
         this.mBuildButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_HOUSES));
         this.mAlertOffers = _loc2_.getChildByName("alert_ok") as MovieClip;
         if(this.mAlertOffers != null)
         {
            this.mAlertOffers.visible = false;
            this.mAlertOffers.stop();
         }
         this.mDemolitionButton = new DynamicButton(this.mToolBar.getChildByName("DemolitionButton") as MovieClip);
         this.mDemolitionButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_DEMOLISH));
         this.mRoadButton = new DynamicButton(this.mToolBar.getChildByName("RoadButton") as MovieClip);
         this.mRoadButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_ROAD));
         this.mRoadButton.setLabel(TextManager.getText(TextIDs.TID_GEN_FREE));
         this.mBuyButton = new DynamicButton(this.mToolBar.getChildByName("BuyButton") as MovieClip);
         this.mBuyButton.setTip(TextManager.replaceParameters(TextIDs.TID_HINT_MENU_BUTTON_TERRAIN,new Array("" + RulesFacade.getLevelTerrainPrice(DollarsGame.getProfile().level))));
         this.mVaultButton = new DynamicButton(this.mToolBar.getChildByName("VaultButton") as MovieClip);
         this.mVaultButton.setTip(TextManager.getText(TextIDs.TID_COLLECTIBLES_SHOP_BUTTON02));
         this.mVaultAlert = this.mVaultButton.getButtonMc()["alert"];
         this.setVaultAlert(false);
         this.mBossGenre = -1;
         this.mBossSprites = new Array();
         this.mHomeButton = new DynamicButton(this.mToolBar.getChildByName("GohomeButton") as MovieClip);
         this.mHomeButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_HOME));
         this.mInvestmentButton = new DynamicButton(this.mToolBar.getChildByName("InvestButton") as MovieClip);
         this.mMultifunctionButton = new DynamicButton(this.mToolBar.getChildByName("SpecialButton") as MovieClip);
         this.mMultifunctionButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTION_MULTIFUNCTION));
         this.mMultifunctionButton.setLabel(TextManager.getText(TextIDs.TID_GEN_NEW));
         this.mSuperupgradeArrow = new AssetManager.SuperupgradeArrow();
         this.mPartnerButton = new DynamicButton(this.mToolBar.getChildByName("PartnerButton") as MovieClip);
         this.mUpgradesButton = new Array();
         var _loc3_:DynamicButton = new DynamicButton(this.mToolBar.getChildByName("UpgradeButton") as MovieClip);
         _loc3_.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_UPGRADES));
         _loc3_.getButtonMc().buttonMode = false;
         _loc3_.visible = false;
         this.mUpgradesButton.push(_loc3_);
         _loc3_ = new DynamicButton(this.mToolBar.getChildByName("SuperupgradeButton") as MovieClip);
         _loc3_.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_UPGRADES));
         _loc3_.getButtonMc().buttonMode = false;
         _loc3_.visible = false;
         this.mUpgradesButton.push(_loc3_);
         this.mRole = param1;
         this.mTools = param1.getTools();
         this.mPopupInvest = new PopupInvest();
         this.mMultifunctionBar = new MultifunctionBar();
         this.mToolBar.addChild(this.mMultifunctionBar);
         this.mVaultBar = new VaultBar();
         this.mVaultBar.setAlert(false);
         this.mToolBar.addChild(this.mVaultBar);
         if(Config.COLLECTIBLE_AUTO_STORAGE_FEATURE)
         {
            this.mToolBar.addEventListener(SHOW_COLLECTIBLE_BAR_EVENT,this.onShowCollectibleBar);
         }
         var _loc4_:int = 0;
         while(_loc4_ < Profile.BOSS_COUNT)
         {
            _loc6_ = "BossButton_0" + (_loc4_ + 1);
            _loc7_ = this.mToolBar.getChildByName(_loc6_) as MovieClip;
            _loc7_.stop();
            this.mBossSprites[_loc4_] = _loc7_;
            this.mToolBar.removeChild(_loc7_);
            _loc4_++;
         }
         this.setBossButton();
         this.bossAlertLoad();
         var _loc5_:int = 0;
         while(_loc5_ < BOSS_ALERT_COUNT)
         {
            this.mToolBar.removeChild(this.mBossAlertDO[_loc5_]);
            _loc5_++;
         }
         this.mToolBar.setChildIndex(this.mSelectButton.getButtonMc(),SELECT_BUTTON);
         this.mToolBar.setChildIndex(this.mBuildButton.getButtonMc(),BUILD_BUTTON);
         this.mToolBar.setChildIndex(this.mDemolitionButton.getButtonMc(),DEMOLITION_BUTTON);
         this.mToolBar.setChildIndex(this.mRoadButton.getButtonMc(),ROAD_BUTTON);
         this.mToolBar.setChildIndex(this.mBuyButton.getButtonMc(),BUY_TERRAIN_BUTTON);
         this.mToolBar.setChildIndex(this.mVaultButton.getButtonMc(),VAULT_BUTTON);
         this.mToolBar.setChildIndex(this.mBossButton.getButtonMc(),BOSS_BUTTON);
         this.mToolBar.setChildIndex(this.mHomeButton.getButtonMc(),HOME_BUTTON);
         this.mToolBar.setChildIndex(this.mInvestmentButton.getButtonMc(),INVEST_BUTTON);
         this.mToolBar.setChildIndex(this.mMultifunctionButton.getButtonMc(),MULTI_FUNCTION_BUTTON);
         this.mToolBar.setChildIndex(this.mPartnerButton.getButtonMc(),PARTNER_BUTTON);
         this.mToolBar.setChildIndex(this.videoButton.getButtonMc(),SELECT_VIDEO_BUTTON);
         this.mBossButton.visible = false;
         if(Tutorial.smTutorialEnd)
         {
            this.addMissionArrow();
         }
      }
      
      public function disable() : void
      {
         this.mToolBar.mouseEnabled = false;
         this.mToolBar.mouseChildren = false;
      }
      
      public function setBossButton(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         if(this.mBossGenre != DollarsGame.getProfile().bossGenre)
         {
            _loc2_ = -1;
            if(this.mBossButton != null)
            {
               _loc2_ = this.mToolBar.getChildIndex(this.mBossButton.getButtonMc());
               this.mBossButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
               this.mToolBar.removeChild(this.mBossButton.getButtonMc());
               this.mBossButton.destroy();
               this.mBossButton = null;
            }
            this.mBossGenre = DollarsGame.getProfile().bossGenre;
            _loc3_ = this.mBossSprites[this.mBossGenre];
            this.mBossButton = new DynamicButton(_loc3_);
            if(param1)
            {
               this.mBossButton.start();
               this.mBossButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
            }
            this.mBossButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_MISSIONS));
            this.mBossButton.visible = false;
            if(_loc2_ > -1)
            {
               this.mToolBar.addChildAt(this.mBossButton.getButtonMc(),_loc2_);
            }
            else
            {
               this.mToolBar.addChild(this.mBossButton.getButtonMc());
            }
         }
      }
      
      private function startJumpButton(param1:DynamicButton) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:GTweenTimeline = null;
         var _loc4_:GTween = null;
         if(param1 != null)
         {
            this.stopJumpButton();
            this.mJumpingButton = param1;
            _loc2_ = param1.getButtonMc().y;
            this.mJumpTweenTimeline = new GTweenTimeline(null,0,null,{"repeatCount":0});
            _loc3_ = new GTweenTimeline(null,0,null,{"repeatCount":3});
            _loc4_ = new GTween(param1.getButtonMc(),0.15,{
               "scaleX":0.8,
               "scaleY":0.8
            },{"ease":Linear.easeNone});
            _loc3_.addTween(0,_loc4_);
            _loc4_ = new GTween(param1.getButtonMc(),0.25,{
               "scaleX":1.2,
               "scaleY":1.2
            },{
               "autoPlay":false,
               "ease":Linear.easeNone
            });
            _loc3_.addTween(0.2,_loc4_);
            _loc4_ = new GTween(param1.getButtonMc(),0.75,{
               "scaleX":1,
               "scaleY":1
            },{
               "autoPlay":false,
               "ease":Bounce.easeOut
            });
            _loc3_.addTween(0.45,_loc4_);
            _loc3_.calculateDuration();
            _loc3_.duration += 1;
            this.mJumpTweenTimeline.addTween(0,_loc3_);
            this.mJumpTweenTimeline.calculateDuration();
            this.mJumpTweenTimeline.duration += 10;
         }
      }
      
      public function getRoadButtonPoint() : Point
      {
         return new Point(this.mRoadButton.getButtonMc().x,this.mRoadButton.getButtonMc().y);
      }
      
      public function setToolMove(param1:String = null) : void
      {
         this.setMultiTool(TOOL_MOVE_ID,param1);
      }
      
      public function bossAlertSetMissionReachedEnabled(param1:Boolean) : void
      {
         var _loc2_:int = 2;
         if(param1)
         {
            this.addMissionArrow();
         }
         else if(!DollarsGame.getProfile().firstMission)
         {
            if(MissionObjectManager.getInstance().getMissionsGivenCount() > 0)
            {
               if(this.mMissionArrow != null)
               {
                  this.mToolBar.removeChild(this.mMissionArrow);
                  this.mMissionArrow = null;
               }
            }
         }
      }
      
      private function setInvestmentsButton() : void
      {
         if(InvestManager.getInstance().areInvestmentsEnabled() && Tutorial.smTutorialEnd)
         {
            this.mInvestmentButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
            this.mInvestmentButton.setTip(TextManager.getText(TextIDs.TID_INVESTMENTS_TOOLTIP));
            this.mInvestmentButton.enable();
         }
         else
         {
            this.mInvestmentButton.disable(true);
            this.mInvestmentButton.setTip(TextManager.replaceParameters(TextIDs.TID_UNLOCK_LEVEL_INVESTMENTS,new Array("" + RulesFacade.getInstance().settingsGetInvestmentsUnlockLevel())));
         }
         this.mInvestmentButtonReady = true;
      }
      
      public function addInvestmentArrow() : void
      {
         var _loc1_:MissionObject = null;
         if(this.mInvestmentArrow == null && !DollarsGame.getProfile().investmentGetToolbarHelpShown())
         {
            _loc1_ = MissionObjectManager.getInstance().getMissionBySku("1");
            this.mInvestmentArrow = new AssetManager.TutorialArrow();
            this.mToolBar.addChild(this.mInvestmentArrow);
            this.mInvestmentArrow.x = this.mInvestmentButton.getButtonMc().x + 25;
            this.mInvestmentArrow.y = this.mInvestmentButton.getButtonMc().y - 25;
            this.mInvestmentArrow.visible = this.mInvestmentButton.visible;
         }
      }
      
      public function setToolContractSignator() : void
      {
         this.setMultiTool(TOOL_CONTRACT_SIGNATOR_ID);
      }
      
      public function addMissionArrow() : void
      {
         var _loc1_:MissionObject = null;
         if(DollarsGame.getProfile().firstMission)
         {
            _loc1_ = MissionObjectManager.getInstance().getMissionByType("nameCity");
            if(_loc1_.state == MissionObject.STATE_GIVEN || _loc1_.state == MissionObject.STATE_REACHED)
            {
               DollarsGame.getProfile().firstMission = false;
               DollarsGame.getProfile().firstMissionDone();
            }
         }
         if(this.mMissionArrow == null && (this.mRole.needsToShowMissionArrow() && DollarsGame.getProfile().firstMission || MissionObjectManager.getInstance().getMissionsGivenCount() == 0 && MissionObjectManager.getInstance().getMissionsReachedCount() > 0))
         {
            this.mMissionArrow = new AssetManager.TutorialArrow();
            this.mToolBar.addChild(this.mMissionArrow);
            this.mMissionArrow.x = this.mBossButton.getButtonMc().x + 5;
            this.mMissionArrow.y = this.mBossButton.getButtonMc().y - 30;
            this.mMissionArrow.visible = this.mBossButton.visible;
         }
      }
      
      public function startBlink() : void
      {
         if(DollarsGame.getProfile().isNewTool() && this.mBlinkId == -1)
         {
            this.mBlinkId = setInterval(this.newBlink,this.BLINK_INTERVAL);
         }
      }
      
      private function bossAlertDestroy() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < BOSS_ALERT_COUNT)
         {
            this.mToolBar.removeChild(this.mBossAlertDO[_loc1_]);
            _loc1_++;
         }
         this.mBossAlertDO[BOSS_ALERT_NEW_MISSION_CLICK].removeEventListener(MouseEvent.CLICK,this.setToolMissions);
         this.mBossAlertDO[BOSS_ALERT_MISSION_REACHED_CLICK].removeEventListener(MouseEvent.CLICK,this.setToolMissions);
         this.mBossAlertDO = null;
         MissionObjectManager.getInstance().removeEventListener(Event.CHANGE,this.bossAlertOnChange);
      }
      
      public function decreaseCollectibleCounter() : void
      {
         --this.mCollectibleCounter;
      }
      
      private function setMultiTool(param1:int, param2:String = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Tool = this.mTools[param1] as Tool;
         switch(param1)
         {
            case TOOL_MONEY_COLLECTOR_ID:
               _loc4_ = RulesFacade.getInstance().settingsGetMoneyCollectorAreaX();
               _loc5_ = RulesFacade.getInstance().settingsGetMoneyCollectorAreaY();
               break;
            case TOOL_CONTRACT_SIGNATOR_ID:
               _loc4_ = RulesFacade.getInstance().settingsGetContractSignatorAreaX();
               _loc5_ = RulesFacade.getInstance().settingsGetContractSignatorAreaY();
         }
         _loc3_.areaSetSize(_loc4_,_loc5_);
         this.mMap.changeTool(_loc3_,param2);
         Dollars.getCurrentCursor().changeCursor(_loc3_.getDefaultCursorID());
      }
      
      private function onClosePartner(param1:Event) : void
      {
         if(param1 != null)
         {
            this.mPopupPartner.removeEventListener(Popup.EVENT_CLOSE,this.onClosePartner);
         }
         if(this.mToolBar.contains(this.mSuperupgradeArrow))
         {
            this.mToolBar.removeChild(this.mSuperupgradeArrow);
         }
         DollarsGame.getProfile().firstPartnerDone();
         UpgradesManager.getInstance().getNeighborObject().resetSuperUpgradeTimeToAllowRemaining();
      }
      
      public function disableButton(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:DynamicButton = this.getButtonDO(param1);
         if(_loc3_ != null)
         {
            if(param2)
            {
               _loc3_.getButtonMc().filters = FiltersManager.getSaturationFilter(0);
            }
            _loc3_.getButtonMc().mouseEnabled = false;
         }
      }
      
      public function toolBarSetTool(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:NeighborObject = null;
         var _loc4_:Tool = null;
         var _loc5_:int = 0;
         this.mSelectButton.setUnselected();
         this.mBuyButton.setUnselected();
         this.mDemolitionButton.setUnselected();
         this.mRoadButton.setUnselected();
         this.mBuildButton.setUnselected();
         this.mMultifunctionButton.setUnselected();
         this.mVaultButton.setUnselected();
         this.videoButton.setUnselected();
         this.mRoadButton.setLabel(TextManager.getText(TextIDs.TID_GEN_FREE));
         if(param1 != MULTI_FUNCTION_BUTTON && this.mMultifunctionBar.visible)
         {
            this.hideMultifunctionBar();
         }
         if(param1 != VAULT_BUTTON && this.mVaultBar.visible)
         {
            this.hideVaultBar();
         }
         if(param2)
         {
            if(this.mMap.currentTool == this.mTools[param1])
            {
               return;
            }
         }
         this.mCurrentToolIndex = param1;
         this.mMap.unattachTerrainShape();
         DollarsGame.getCurrentWorld().map.removeBuildGrid();
         switch(param1)
         {
            case SELECT_BUTTON:
               this.mMap.changeTool(this.mTools[TOOL_SELECT_ID]);
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
               this.mSelectButton.setSelected();
               break;
            case ROAD_BUTTON:
               if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == 4 && !this.mRoadTutorial)
               {
                  Tutorial.removeToolbarArrow(this.mToolBar);
                  Tutorial.addRoads();
                  this.mMap.mouseEnabled = true;
                  this.mRoadTutorial = true;
               }
               this.mMap.changeTool(this.mTools[TOOL_ROAD_ID]);
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_ROAD);
               this.mRoadButton.setSelected();
               this.mRoadButton.setLabel(TextManager.getText(TextIDs.TID_GEN_FREE));
               break;
            case BUILD_BUTTON:
               this.mMap.changeTool(this.mTools[TOOL_SELECT_ID]);
               DollarsGame.smInstance.showBuyBox();
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
               this.mBuildButton.setSelected();
               if(DollarsGame.getProfile().isNewItem())
               {
                  ++DollarsGame.getProfile().newItemRev;
                  DollarsGame.getProfile().newItemsRevDone();
               }
               break;
            case DEMOLITION_BUTTON:
               this.mMap.changeTool(this.mTools[TOOL_DESTROY_ID]);
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_DEMOLITION);
               this.mDemolitionButton.setSelected();
               break;
            case BUY_TERRAIN_BUTTON:
               if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == 2 && !this.mTerrainTutorial)
               {
                  Tutorial.removeToolbarArrow(this.mToolBar);
                  Tutorial.addTerrains();
                  this.mMap.mouseEnabled = true;
                  this.mTerrainTutorial = true;
               }
               this.mMap.changeTool(this.mTools[TOOL_TERRAIN_ID]);
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_TERRAIN);
               this.mMap.attachTerrainShape();
               this.mBuyButton.setSelected();
               break;
            case VAULT_BUTTON:
               if(!this.mVaultBar.visible)
               {
                  this.toolBarSetTool(SELECT_BUTTON);
                  this.showVaultBar();
               }
               else
               {
                  this.hideVaultBar();
                  this.mSelectButton.setSelected();
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
               }
               this.mCurrentToolIndex = SELECT_BUTTON;
               break;
            case BOSS_BUTTON:
               if(this.mRole.isLogicTilesEditionAllowed())
               {
                  _loc4_ = this.mTools[TOOL_SOLID_ID];
                  this.mMap.changeTool(_loc4_);
                  Dollars.getCurrentCursor().changeCursor(_loc4_.getDefaultCursorID());
                  break;
               }
               _loc5_ = 0;
               while(_loc5_ < BOSS_ALERT_COUNT)
               {
                  this.mBossAlertDO[_loc5_].visible = false;
                  _loc5_++;
               }
               if(this.mMissions == null)
               {
                  MissionDefinitionManager.getInstance().build();
                  this.mMissions = new MissionsBox();
               }
               else
               {
                  this.mMissions.showPopup();
               }
               this.selectOldButton();
               this.mCurrentToolIndex = SELECT_BUTTON;
               break;
            case HOME_BUTTON:
               DollarsGame.visitUniverse(DollarsGame.getProfile().owner);
               this.mHomeButton.rollout(null);
               this.mSelectButton.setSelected();
               break;
            case INVEST_BUTTON:
               this.showInvestMenu();
               if(this.mJumpingButton == this.mInvestmentButton)
               {
                  this.stopJumpButton();
               }
               break;
            case MULTI_FUNCTION_BUTTON:
               if(!this.mMultifunctionBar.visible)
               {
                  this.toolBarSetTool(SELECT_BUTTON);
                  this.showMultifunctionBar();
               }
               else
               {
                  this.hideMultifunctionBar();
                  this.mSelectButton.setSelected();
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
               }
               this.mCurrentToolIndex = SELECT_BUTTON;
               break;
            case PARTNER_BUTTON:
               _loc3_ = UpgradesManager.getInstance().getNeighborObject();
               if(this.mPopupPartner == null)
               {
                  this.mPopupPartner = new PopupPartner(PopupPartner.TYPE_PARTNER);
               }
               this.mPopupPartner.showPopupParams(_loc3_);
               this.mPopupPartner.addEventListener(Popup.EVENT_ACCEPT,this.onClosePartner);
               break;
            case SELECT_VIDEO_BUTTON:
               this.onShowVideoAd();
         }
      }
      
      public function setUpgrades(param1:int) : void
      {
         var _loc2_:int = UpgradesManager.getInstance().getType();
         this.mUpgradesButton[_loc2_].setLabel("" + param1);
         if(param1 == 0)
         {
            this.mUpgradesButton[_loc2_].visible = false;
         }
         else
         {
            this.mUpgradesButton[_loc2_].visible = true;
         }
      }
      
      public function showMultifunctionBar(param1:int = -1) : void
      {
         this.mMultifunctionButton.setSelected();
         this.mMultifunctionBar.start(param1);
         this.mSelectButton.setUnselected();
      }
      
      public function unattachItem(param1:ItemObject) : void
      {
         var _loc2_:Tool = null;
         for each(_loc2_ in this.mTools)
         {
            _loc2_.unattachItem(param1);
         }
      }
      
      public function setVaultAlert(param1:Boolean) : void
      {
         this.mVaultAlert.visible = param1;
         if(param1)
         {
            this.mVaultAlert.play();
            if(this.mVaultBar != null)
            {
               this.mVaultBar.setAlert(true);
            }
         }
         else
         {
            this.mVaultAlert.stop();
            if(this.mVaultBar != null)
            {
               this.mVaultBar.setAlert(false);
            }
         }
      }
      
      private function onEnableInvestments() : void
      {
         this.mToolBar.removeEventListener(EVENT_ENABLE_INVESTMENTS,this.onEnableInvestments);
         this.setInvestmentsButton();
         this.addInvestmentArrow();
      }
      
      public function setToolMoneyCollector() : void
      {
         this.setMultiTool(TOOL_MONEY_COLLECTOR_ID);
      }
      
      public function start(param1:Map) : void
      {
         var _loc2_:Tool = null;
         this.mMap = param1;
         for each(_loc2_ in this.mTools)
         {
            _loc2_.setMap(this.mMap);
         }
         this.mMultifunctionBar.map = this.mMap;
         this.mMultifunctionBar.tools = this.mTools;
         this.mVaultBar.setToolsBar(this);
         this.mToolBar.visible = true;
         this.mMap.changeTool(this.mTools[TOOL_DEFAULT_ID]);
         this.mSelectButton.start();
         this.mSelectButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mRoadButton.start();
         this.mRoadButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mBuildButton.start();
         this.mBuildButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mBuildButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_HOUSES));
         this.mDemolitionButton.start();
         this.mDemolitionButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mBuyButton.start();
         this.mBuyButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mVaultButton.start();
         this.mVaultButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mBossButton.start();
         this.mBossButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mHomeButton.start();
         this.mHomeButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.videoButton.start();
         this.videoButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
         {
            this.mPartnerButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_ADD_PARTNER));
            this.mToolBar.addChild(this.mSuperupgradeArrow);
            this.mSuperupgradeArrow.x = this.mPartnerButton.getButtonMc().width;
            this.mSuperupgradeArrow.y = -300;
         }
         else
         {
            this.mBlinkId = -1;
         }
         this.mPartnerButton.start();
         this.mPartnerButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         var _loc3_:int = 0;
         while(_loc3_ < this.mUpgradesButton.length)
         {
            this.mUpgradesButton[_loc3_].start();
            this.mUpgradesButton[_loc3_].addEventListener(MouseEvent.CLICK,this.toolBarAction);
            _loc3_++;
         }
         this.mInvestmentButton.start();
         if(!InvestManager.getInstance().areInvestmentsLoaded())
         {
            this.mInvestmentButton.disable(false);
            this.mInvestmentButtonReady = false;
         }
         else
         {
            this.setInvestmentsButton();
         }
         this.mMultifunctionButton.start();
         this.mMultifunctionButton.addEventListener(MouseEvent.CLICK,this.toolBarAction);
         if(this.mMissionArrow != null && !this.mToolBar.contains(this.mMissionArrow))
         {
            this.mToolBar.addChild(this.mMissionArrow);
         }
         if(this.mInvestmentArrow != null && !this.mToolBar.contains(this.mInvestmentArrow))
         {
            this.mToolBar.addChild(this.mInvestmentArrow);
         }
      }
      
      private function toolBarAction(param1:MouseEvent) : void
      {
         var _loc2_:DynamicButton = param1.target as DynamicButton;
         if(_loc2_ != null)
         {
            this.mOldButton = this.mCurrentButton;
            this.mCurrentButton = _loc2_;
         }
         this.mCurrentToolIndex = this.mToolBar.getChildIndex(param1.target as DisplayObject);
         this.toolBarSetTool(this.mCurrentToolIndex);
      }
      
      public function setToolbarConfig(param1:Boolean) : void
      {
         var _loc4_:int = 0;
         this.mSelectButton.visible = !param1;
         this.mRoadButton.visible = !param1;
         this.mBuildButton.visible = !param1;
         this.mDemolitionButton.visible = !param1;
         this.mBuyButton.visible = !param1;
         if(this.mMissionArrow != null)
         {
            this.mMissionArrow.visible = this.mBossButton.visible;
         }
         if(this.mInvestmentArrow != null)
         {
            this.mInvestmentArrow.visible = this.mInvestmentButton.visible;
         }
         this.mMultifunctionButton.visible = !param1;
         this.mMultifunctionBar.visible = !param1;
         this.mVaultButton.visible = !param1;
         this.mVaultBar.visible = !param1;
         this.videoButton.visible = !param1;
         if(Config.COLLECTIBLE_FEATURE_ENABLED && Config.COLLECTIBLE_AUTO_STORAGE_FEATURE)
         {
            if(this.mCollectibleBar)
            {
               this.mCollectibleBar.visible = !param1;
            }
         }
         this.mHomeButton.visible = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.mUpgradesButton.length)
         {
            this.mUpgradesButton[_loc2_].visible = false;
            this.mUpgradesButton[_loc2_].visible = false;
            _loc2_++;
         }
         if(param1)
         {
            _loc4_ = UpgradesManager.getInstance().getType();
            this.mPartnerButton.visible = Config.USE_SUPERUPGRADES && FriendsManager.getNeighborsNoAdvisors().length > 0;
            this.mSuperupgradeArrow.visible = this.mPartnerButton.visible && !DollarsGame.getProfile().firstPartner;
            if(UpgradesManager.getInstance().isAnyUpgradeAllowed())
            {
               this.mUpgradesButton[_loc4_].visible = true;
            }
         }
         else
         {
            this.mPartnerButton.visible = false;
         }
         this.mInvestmentButton.visible = !param1;
         this.mBossButton.visible = false;
         var _loc3_:int = 0;
         while(_loc3_ < BOSS_ALERT_COUNT)
         {
            if(param1 && this.mToolBar.contains(this.mBossAlertDO[_loc3_]))
            {
               this.mToolBar.removeChild(this.mBossAlertDO[_loc3_]);
            }
            else if(!param1 && !this.mToolBar.contains(this.mBossAlertDO[_loc3_]))
            {
               this.mToolBar.addChild(this.mBossAlertDO[_loc3_]);
            }
            _loc3_++;
         }
      }
      
      private function bossAlertLoad() : void
      {
         this.mBossAlertDO = new Array(BOSS_ALERT_COUNT);
         this.mBossAlertDO[BOSS_ALERT_NEW_MISSION] = this.mToolBar.getChildByName("alert") as MovieClip;
         this.mToolBar.addChild(this.mBossAlertDO[BOSS_ALERT_NEW_MISSION]);
         this.mBossAlertDO[BOSS_ALERT_MISSION_REACHED] = this.mToolBar.getChildByName("alert_ok") as MovieClip;
         this.mToolBar.addChild(this.mBossAlertDO[BOSS_ALERT_MISSION_REACHED]);
         this.mBossAlertDO[BOSS_ALERT_NEW_MISSION_CLICK] = this.mToolBar.getChildByName("click_alert") as MovieClip;
         this.mToolBar.addChild(this.mBossAlertDO[BOSS_ALERT_NEW_MISSION_CLICK]);
         this.mBossAlertDO[BOSS_ALERT_MISSION_REACHED_CLICK] = this.mToolBar.getChildByName("click_alert_ok") as MovieClip;
         this.mToolBar.addChild(this.mBossAlertDO[BOSS_ALERT_MISSION_REACHED_CLICK]);
         this.mBossAlertDO[BOSS_ALERT_NEW_MISSION_CLICK].addEventListener(MouseEvent.CLICK,this.setToolMissions);
         this.mBossAlertDO[BOSS_ALERT_MISSION_REACHED_CLICK].addEventListener(MouseEvent.CLICK,this.setToolMissions);
         var _loc1_:int = 0;
         while(_loc1_ < BOSS_ALERT_COUNT)
         {
            this.mBossAlertDO[_loc1_].visible = false;
            _loc1_++;
         }
         MissionObjectManager.getInstance().addEventListener(Event.CHANGE,this.bossAlertOnChange);
      }
      
      public function unselectButton() : void
      {
         this.mSelectButton.setUnselected();
      }
      
      public function getShopButtonPoint() : Point
      {
         return new Point(this.mBuildButton.getButtonMc().x,this.mBuildButton.getButtonMc().y);
      }
      
      public function stopBlink() : void
      {
         if(this.mBlinkId > -1)
         {
            clearInterval(this.mBlinkId);
            this.mNewText.visible = false;
         }
      }
      
      public function getGiftButtonCoordinates() : Vector2D
      {
         var _loc1_:Point = new Point(this.mVaultButton.getButtonMc().x,this.mVaultButton.getButtonMc().y);
         _loc1_ = this.mToolBar.localToGlobal(_loc1_);
         return new Vector2D(_loc1_.x,_loc1_.y);
      }
      
      public function removeMissionArrow() : void
      {
         if(this.mMissionArrow != null)
         {
            this.mToolBar.removeChild(this.mMissionArrow);
            this.mMissionArrow = null;
         }
         DollarsGame.getProfile().firstMission = false;
         DollarsGame.getProfile().firstMissionDone();
      }
      
      public function enableButtons() : void
      {
         var _loc1_:int = 0;
         if(Tutorial.smTutorialEnd)
         {
            _loc1_ = 0;
            while(_loc1_ <= TOTAL_BUTTONS)
            {
               this.enableButton(_loc1_);
               _loc1_++;
            }
         }
      }
      
      public function enable() : void
      {
         this.mToolBar.mouseEnabled = true;
         this.mToolBar.mouseChildren = true;
      }
      
      public function setToolBuild(param1:ItemDefinition, param2:Boolean = false, param3:Object = null, param4:Boolean = false, param5:String = null) : void
      {
         var _loc6_:ToolDecorator = this.mTools[TOOL_BUILD_ID] as ToolDecorator;
         var _loc7_:ToolBuild = ToolBuild(_loc6_.mTool);
         _loc7_.setItemDefinition(param1,param2,param3,false);
         this.mMap.changeTool(this.mTools[TOOL_BUILD_ID],param5);
      }
      
      public function disableButtons(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ <= TOTAL_BUTTONS)
         {
            this.disableButton(_loc2_,param1);
            _loc2_++;
         }
      }
      
      public function bossAlertOnChange(param1:Event) : void
      {
      }
      
      private function newBlink() : void
      {
         this.mNewText.visible = !this.mNewText.visible;
      }
      
      private function selectOldButton() : void
      {
         if(this.mOldButton == this.mRoadButton || this.mOldButton == this.mBuyButton || this.mOldButton == this.mDemolitionButton)
         {
            this.mOldButton.setSelected();
         }
         else
         {
            this.mSelectButton.setSelected();
         }
      }
      
      public function setToolToSelect() : void
      {
         var _loc1_:Tool = DollarsGame.getCurrentRole().toolsBar.getToolByID(ToolsBar.TOOL_SELECT_ID);
         if(_loc1_ != null)
         {
            DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.TOOL_SELECT_ID);
            DollarsGame.getCurrentWorld().map.changeTool(_loc1_);
         }
      }
      
      public function get currentToolIndex() : uint
      {
         return this.mCurrentToolIndex;
      }
      
      public function enableButton(param1:int) : void
      {
         var _loc2_:DynamicButton = this.getButtonDO(param1);
         if(_loc2_ != null)
         {
            _loc2_.getButtonMc().filters = null;
            _loc2_.getButtonMc().mouseEnabled = true;
         }
      }
      
      public function setToolMissions(param1:MouseEvent) : void
      {
         this.mOldButton = this.mCurrentButton;
         this.mCurrentButton = this.mBossButton;
         this.mCurrentToolIndex = this.mToolBar.getChildIndex(this.mBossButton.getButtonMc());
         this.toolBarSetTool(this.mCurrentToolIndex);
      }
      
      private function disableNew() : void
      {
         if(DollarsGame.getProfile().isNewTool())
         {
            ++DollarsGame.getProfile().newToolRev;
            DollarsGame.getProfile().newToolRevDone();
            this.stopBlink();
         }
      }
      
      private function stopJumpButton() : void
      {
         if(this.mJumpTweenTimeline != null)
         {
            this.mJumpTweenTimeline.paused = true;
            this.mJumpTweenTimeline.end();
            this.mJumpTweenTimeline = null;
         }
         this.mJumpingButton = null;
      }
      
      private function getButtonDO(param1:int) : DynamicButton
      {
         var _loc2_:DynamicButton = null;
         switch(param1)
         {
            case SELECT_BUTTON:
               _loc2_ = this.mSelectButton;
               break;
            case ROAD_BUTTON:
               _loc2_ = this.mRoadButton;
               break;
            case BUILD_BUTTON:
               _loc2_ = this.mBuildButton;
               break;
            case DEMOLITION_BUTTON:
               _loc2_ = this.mDemolitionButton;
               break;
            case BUY_TERRAIN_BUTTON:
               _loc2_ = this.mBuyButton;
               break;
            case BOSS_BUTTON:
               _loc2_ = this.mBossButton;
               break;
            case VAULT_BUTTON:
               _loc2_ = this.mVaultButton;
               break;
            case BOSS_BUTTON:
               _loc2_ = this.mBossButton;
               break;
            case INVEST_BUTTON:
               _loc2_ = this.mInvestmentButton;
               break;
            case MULTI_FUNCTION_BUTTON:
               _loc2_ = this.mMultifunctionButton;
               break;
            case SELECT_VIDEO_BUTTON:
               _loc2_ = this.videoButton;
         }
         return _loc2_;
      }
      
      public function resize() : void
      {
         this.mToolBar.x = (Dollars.smStage.stageWidth - this.mToolBar.width) / 2;
         this.mToolBar.y = Dollars.smStage.stageHeight;
      }
      
      private function onShowCollectibleBar(param1:Event) : void
      {
         var _loc2_:NewCollectibleBar = null;
         var _loc3_:int = 0;
         var _loc4_:NewCollectibleBar = null;
         if(this.mCollectibleSku)
         {
            if(!this.mCollectibleCounter)
            {
               this.mCollectibleCounter = 0;
            }
            if(!this.mCollectibleBarBuffer)
            {
               this.mCollectibleBarBuffer = new Array();
            }
            _loc2_ = new NewCollectibleBar(this.mCollectibleSku);
            _loc2_.x += 65;
            if(this.mCollectibleBarBuffer.length > 0)
            {
               _loc3_ = 1;
               for each(_loc4_ in this.mCollectibleBarBuffer)
               {
                  _loc4_.y -= (_loc2_.height - 30) * _loc3_;
               }
            }
            this.mToolBar.addChild(_loc2_);
            this.mCollectibleBarBuffer.push(_loc2_);
            ++this.mCollectibleCounter;
            _loc2_.showCollectibleBar();
         }
      }
      
      public function hideMultifunctionBar() : void
      {
         this.mMap.changeTool(this.mTools[TOOL_DEFAULT_ID]);
         this.mMultifunctionButton.setUnselected();
         this.mMultifunctionBar.end();
      }
      
      public function getMultifunctionBar() : MultifunctionBar
      {
         return this.mMultifunctionBar;
      }
      
      public function showVaultBar(param1:int = -1) : void
      {
         this.mVaultButton.setSelected();
         this.mVaultBar.start(param1);
         this.mSelectButton.setUnselected();
      }
      
      public function startJumpInvestmentButton() : void
      {
         this.startJumpButton(this.mInvestmentButton);
      }
      
      public function showInvestMenu() : void
      {
         this.selectOldButton();
         this.mPopupInvest.showPopup();
         this.mCurrentToolIndex = SELECT_BUTTON;
      }
      
      public function removeInvestmentArrow() : void
      {
         if(this.mInvestmentArrow != null)
         {
            this.mToolBar.removeChild(this.mInvestmentArrow);
            this.mInvestmentArrow = null;
         }
         DollarsGame.getProfile().investmentSetToolbarHelpShown(true);
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Boolean = false;
         if(DollarsGame.getProfile().mCollectiblesUnlocked && !DollarsGame.getProfile().collectiblesGetFirstShown())
         {
            DollarsGame.getProfile().collectiblesShopSetEnhancedShown(true);
         }
         if(Config.OFFLINE_GAMEPLAY_MODE)
         {
            this.videoButton.visible = false;
         }
         else
         {
            if(this.videoButton.visible == false && CustomizerManager.getInstance().isVideoAdEnabled())
            {
               this.videoButton.visible = true;
            }
            if(this.videoButton.visible == true && !CustomizerManager.getInstance().isVideoAdEnabled())
            {
               this.videoButton.visible = false;
            }
         }
         if(InvestManager.getInstance().areInvestmentsLoaded())
         {
            if(DollarsGame.getProfile().mInvestmentUnlocked && !DollarsGame.getProfile().investmentGetToolbarHelpShown() && this.mInvestmentArrow == null)
            {
               this.onEnableInvestments();
            }
            else if(!this.mInvestmentButtonReady)
            {
               this.setInvestmentsButton();
            }
         }
         if(this.mAlertOffers != null)
         {
            _loc2_ = OfferManager.getInstance().mFlagNewFreeItems;
            if(this.mAlertOffers.visible && !_loc2_)
            {
               this.mAlertOffers.visible = false;
               this.mAlertOffers.stop();
            }
            else if(_loc2_)
            {
               this.mAlertOffers.visible = true;
               this.mAlertOffers.play();
            }
         }
         if(this.mVaultBar != null)
         {
            this.mVaultBar.logicUpdate(param1);
         }
      }
      
      public function getToolByID(param1:int) : Tool
      {
         return this.mTools[param1];
      }
      
      private function onShowVideoAd() : void
      {
         if(Config.USE_SOUNDS)
         {
            this.mMusicStateBeforeVideo = SoundManager.getInstance().isMusicOn();
            this.mFXStateBeforeVideo = SoundManager.getInstance().isSfxOn();
            SoundManager.getInstance().stopAll();
         }
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_VIDEO_AD,{"func":CustomizerManager.getInstance().getVideoFunctionName()});
      }
      
      public function hideVaultBar() : void
      {
         this.mMap.changeTool(this.mTools[TOOL_DEFAULT_ID]);
         this.mVaultButton.setUnselected();
         this.mVaultBar.end();
      }
      
      public function getDisplayObject() : DisplayObjectContainer
      {
         return this.mToolBar;
      }
      
      public function end() : void
      {
         this.mToolBar.visible = false;
         this.mSelectButton.end();
         this.mSelectButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mRoadButton.end();
         this.mRoadButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mBuildButton.end();
         this.mBuildButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mDemolitionButton.end();
         this.mDemolitionButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mBuyButton.end();
         this.mBuyButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mVaultButton.end();
         this.mVaultButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mHomeButton.end();
         this.mHomeButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         if(this.mMissionArrow != null && this.mToolBar.contains(this.mMissionArrow))
         {
            this.mToolBar.removeChild(this.mMissionArrow);
         }
         if(this.mInvestmentArrow != null && this.mToolBar.contains(this.mInvestmentArrow))
         {
            this.mToolBar.removeChild(this.mInvestmentArrow);
         }
         this.mPartnerButton.end();
         this.mPartnerButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         if(this.mSuperupgradeArrow != null && this.mToolBar.contains(this.mSuperupgradeArrow))
         {
            this.mToolBar.removeChild(this.mSuperupgradeArrow);
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.mUpgradesButton.length)
         {
            this.mUpgradesButton[_loc1_].end();
            this.mUpgradesButton[_loc1_].removeEventListener(MouseEvent.CLICK,this.toolBarAction);
            _loc1_++;
         }
         this.mInvestmentButton.end();
         this.mInvestmentButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mMultifunctionButton.end();
         this.mMultifunctionButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         this.mMultifunctionBar.end();
         this.mVaultBar.end();
         this.mBossButton.end();
         this.mBossButton.removeEventListener(MouseEvent.CLICK,this.toolBarAction);
         _loc1_ = 0;
         while(_loc1_ < BOSS_ALERT_COUNT)
         {
            if(this.mToolBar.contains(this.mBossAlertDO[_loc1_]))
            {
               this.mToolBar.removeChild(this.mBossAlertDO[_loc1_]);
            }
            _loc1_++;
         }
      }
      
      public function getVaultBar() : VaultBar
      {
         return this.mVaultBar;
      }
      
      public function setToolRentAccelerator(param1:String = null) : void
      {
         this.mCurrentToolIndex = -1;
         var _loc2_:Tool = this.mTools[TOOL_RENT_ACCELERATOR] as Tool;
         this.mMap.changeTool(_loc2_,param1);
      }
      
      public function destroy() : void
      {
         var _loc2_:uint = 0;
         this.end();
         if(this.mMissionArrow != null && this.mToolBar.contains(this.mMissionArrow))
         {
            this.mToolBar.removeChild(this.mMissionArrow);
         }
         if(this.mInvestmentArrow != null && this.mToolBar.contains(this.mInvestmentArrow))
         {
            this.mToolBar.removeChild(this.mInvestmentArrow);
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.mUpgradesButton.length)
         {
            this.mToolBar.removeChild(this.mUpgradesButton[_loc1_]);
            _loc1_++;
         }
         this.bossAlertDestroy();
         this.mToolBar = null;
         if(this.mTools != null)
         {
            _loc2_ = this.mTools.length - 1;
            while(_loc2_ >= 0)
            {
               this.mTools[_loc2_].destroy();
               this.mTools[_loc2_] = null;
               _loc2_--;
            }
            this.mTools = null;
         }
         this.mBossSprites.splice(0,this.mBossSprites.length);
         this.mBossSprites = null;
      }
      
      public function setCollectibleForBar(param1:String) : void
      {
         this.mCollectibleSku = param1;
      }
      
      public function getTerrainButtonPoint() : Point
      {
         return new Point(this.mBuyButton.getButtonMc().x,this.mBuyButton.getButtonMc().y);
      }
   }
}

