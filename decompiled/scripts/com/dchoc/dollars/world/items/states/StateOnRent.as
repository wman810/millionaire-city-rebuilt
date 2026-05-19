package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleFound;
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirmDestroy;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.events.DollarsEventManager;
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxAbandoned;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Layers.TopLayer;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.tools.Tool;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.animations.DCBitmapSprite;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.math.Vector2D;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.particles.ParticleAnimation;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.utils.poll.PollEvent;
   import com.dchoc.dollars.utils.poll.PollManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.GUI.DCFillBar;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.states.StateMachine;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.clearInterval;
   
   public class StateOnRent extends StateItemObject
   {
      
      private static var smTutorialAlreadyUsed:Boolean;
      
      public static const EVENT_MOVE_COLLECTIBLE_TO_VAULT:String = "eventmovecollectibletovault";
      
      public static var smItemsBrokenCount:int = 0;
      
      public static const ID:int = STATE_ON_RENT_ID;
      
      protected static const MODE_NONE:int = 0;
      
      protected static const MODE_WAITING_FOR_CONTRACT:int = 1;
      
      protected static const MODE_SIGNING_CONTRACT:int = 2;
      
      protected static const MODE_CANCELING_CONTRACT:int = 3;
      
      protected static const MODE_RENTING:int = 4;
      
      protected static const MODE_GET_RENT:int = 5;
      
      protected static const MODE_GIVING_RENT:int = 6;
      
      protected static const MODE_ABANDONED:int = 7;
      
      protected static const MODE_RESETING_ABANDONED:int = 8;
      
      protected static const MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT:int = 9;
      
      protected static const MODE_POSTPONING_SET_MODE:int = 10;
      
      protected static const MODE_COLLECTIBLE:int = 14;
      
      protected static const MODE_GIVING_COLLECTIBLE:int = 15;
      
      protected static const UI_MODES:Array = [MODE_NONE,MODE_CANCELING_CONTRACT,MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT,MODE_RESETING_ABANDONED,MODE_POSTPONING_SET_MODE];
      
      public static const CMD_SIGN_CONTRACT:String = "cmdSignContract";
      
      public static const CMD_COLLECTIBLE_GOTTEN:String = "cmdCollectibleGotten";
      
      public static const CMD_COMMERCE_COLLECTIBLE_GOTTEN:String = "cmdCommerceCollectibleGotten";
      
      private static var smRentsCollected:int = 0;
      
      private static const UNAPPLY_ANIM_SKUS:Array = ["Event_Contract_anim_ok","Event_Contract_anim_ok_superupgrade"];
      
      private static const CONTRACT_ICON_ID:int = 0;
      
      private static const CONTRACT_SIGN_ID:int = 1;
      
      private static const CONTRACT_SIGN_BAR_ID:int = 2;
      
      private static const CONTRACT_SIGN_END_ID:int = 3;
      
      private static const CONTRACT_ABANDONED_ID:int = 4;
      
      private static const CONTRACT_RESETING_ABANDONED_ID:int = 5;
      
      private static const CONTRACT_CANCEL_BAR_ID:int = 6;
      
      private static const CONTRACT_COUNT:int = 7;
      
      private var mContractAnimVisible:Boolean;
      
      private var mStars:MovieClip;
      
      private var mIntervalId:int;
      
      private var mInfoBox:InfoBox;
      
      private var mRentScaleFactor:Number = 0.02;
      
      private var mContractSignFillBar:DCFillBar;
      
      private var mContractScaleFactor:Number = 0.02;
      
      private const CONTRACT_SIGN_TIME:int = 3000;
      
      private var mContractAnimatingSprite:DCBitmapSprite;
      
      private var mRentInterval:uint;
      
      private var mMaxIncomeTime:int;
      
      private var mIsAccelerated:Boolean;
      
      private const MAX_COMPANY_VALUE:Number = 350000001;
      
      private var mNextModeId:int;
      
      private var mRentAnimationSprite:DCBitmapSprite;
      
      private var mCurrentVelocity:Vector2D;
      
      private var mContractDOs:Array;
      
      private var mFinalPosition:Vector2D;
      
      private var mLastModeSentToServer:int = 0;
      
      private var mInitialPosition:Vector2D;
      
      private var mIncomeTime:int;
      
      private var mVelocity:Vector2D;
      
      private var mNotifyDoubleRent:Boolean = false;
      
      private var mContractCancelFillBar:DCFillBar;
      
      private var mMovingCollectibleIcon:MovieClip;
      
      private var mContractInterval:uint;
      
      private var mAcceleration:Vector2D;
      
      private const MIN_COMPANY_VALUE:Number = 249999999;
      
      private var mStartMoving:Boolean;
      
      private var mMap:Map;
      
      protected var mMode:int = 0;
      
      private var mCollectibleInterval:uint;
      
      private var mDOGetCollectibleIcon:MovieClip;
      
      private var mDoubleRentDO:MovieClip;
      
      private const CONTRACT_CANCEL_TIME:int = 3000;
      
      private var mVaultReached:Boolean;
      
      private var mIncomeTimeTarget:int;
      
      private var mCollectibleScaleFactor:Number = 0.02;
      
      private var mRentAnimVisible:Boolean;
      
      private const TRACK_RENT_COUNT:Number = 5;
      
      public function StateOnRent(param1:StateMachine)
      {
         super(param1);
         this.viewStart();
      }
      
      public static function regla3(param1:int, param2:int, param3:int) : int
      {
         return param1 * param3 / param2;
      }
      
      override public function isOutlineInMouseOverEnabled() : Boolean
      {
         return this.isModeMouseOverEnabled();
      }
      
      private function contractRemoveView(param1:int) : void
      {
         var _loc2_:MovieClip = this.mContractDOs[param1] as MovieClip;
         switch(param1)
         {
            case CONTRACT_SIGN_ID:
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.contractSignAnimCheckEnd);
               break;
            case CONTRACT_RESETING_ABANDONED_ID:
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.contractResetingAbandonedCheckEnd);
               break;
            case CONTRACT_SIGN_END_ID:
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.contractSignEndCheckEnd);
         }
         var _loc3_:DisplayObjectContainer = this.contractGetParent();
         if(_loc3_.contains(_loc2_))
         {
            _loc3_.removeChild(_loc2_);
         }
      }
      
      public function canBeAccelerated() : Boolean
      {
         return this.mMode == MODE_RENTING && !this.mIsAccelerated;
      }
      
      protected function viewEnd() : void
      {
         this.mStars = null;
         this.mDoubleRentDO = null;
         if(this.mDOGetCollectibleIcon != null)
         {
            this.mDOGetCollectibleIcon.visible = false;
         }
         if(Config.COLLECTIBLE_AUTO_STORAGE_FEATURE)
         {
            if(this.mMovingCollectibleIcon != null)
            {
               this.mMovingCollectibleIcon.visible = false;
            }
         }
         this.contractDestroy();
      }
      
      protected function doEnter(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(param1)
         {
            _loc2_ = mItemObject.itemDefinition.isACommerce() ? MODE_RENTING : MODE_WAITING_FOR_CONTRACT;
            if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep <= Tutorial.TUTORIAL_STEP_SIGN_CONTRACT_ID)
            {
               _loc2_ = MODE_NONE;
            }
            this.setMode(_loc2_,param1);
         }
         else
         {
            _loc3_ = false;
            if(this.mMode == MODE_COLLECTIBLE)
            {
               if(Config.COLLECTIBLE_COMMERCES_FEATURE)
               {
                  if(mItemObject.itemDefinition.isACommerce())
                  {
                     this.mMode = MODE_RENTING;
                  }
                  else
                  {
                     this.mMode = MODE_WAITING_FOR_CONTRACT;
                  }
               }
               else
               {
                  this.mMode = MODE_WAITING_FOR_CONTRACT;
               }
               _loc3_ = true;
            }
            this.setMode(this.mMode,false,true,_loc3_);
         }
         if(mItemObject.itemDefinition.needsToRegisterNumberOfConstructionsFinished())
         {
            mItemObject.company.registerOccurrencesAddItem(mItemObject);
         }
      }
      
      override public function doUIEventWaitingFor() : void
      {
         switch(this.mMode)
         {
            case MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT:
               this.setMode(MODE_SIGNING_CONTRACT,true);
         }
      }
      
      private function contractLoad() : void
      {
         var _loc1_:DCResourceManager = null;
         var _loc2_:String = null;
         var _loc3_:Sprite = null;
         var _loc4_:Sprite = null;
         var _loc5_:DisplayObject = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(mItemObject.itemDefinition.type == ItemDefinition.TYPE_HOUSES_ID || mItemObject.itemDefinition.isAClub())
         {
            this.mContractDOs = new Array(CONTRACT_COUNT);
            _loc1_ = DCResourceManager.getInstance();
            _loc2_ = Config.getRoot() + ModelConfig.CONTRACT_SWF;
            this.mContractDOs[CONTRACT_ICON_ID] = new (_loc1_.getSWFClass(_loc2_,"Event"))();
            this.mContractDOs[CONTRACT_SIGN_ID] = new (_loc1_.getSWFClass(_loc2_,"Event_ok"))();
            _loc3_ = new (_loc1_.getSWFClass(DollarsGame.HUD_SKU,"Bar_contract"))();
            this.mContractDOs[CONTRACT_SIGN_BAR_ID] = _loc3_;
            this.mContractSignFillBar = new DCFillBar(_loc3_.getChildByName("FillBar") as MovieClip,0,this.CONTRACT_SIGN_TIME);
            _loc4_ = new (_loc1_.getSWFClass(DollarsGame.HUD_SKU,"Bar_contract_broken"))();
            this.mContractDOs[CONTRACT_CANCEL_BAR_ID] = _loc4_;
            this.mContractCancelFillBar = new DCFillBar(_loc4_.getChildByName("FillBar") as MovieClip,0,this.CONTRACT_CANCEL_TIME);
            this.mContractDOs[CONTRACT_RESETING_ABANDONED_ID] = new (_loc1_.getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Empty_House_Ok"))();
            this.mContractDOs[CONTRACT_ABANDONED_ID] = new (_loc1_.getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Empty_House"))();
            this.mContractDOs[CONTRACT_SIGN_END_ID] = new (_loc1_.getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Start_Income"))();
            for each(_loc5_ in this.mContractDOs)
            {
               _loc5_.x = mItemObject.itemDefinition.baseWidth >> 1;
               _loc5_.y = mItemObject.itemDefinition.baseHeight >> 1;
            }
            _loc6_ = _loc3_.width;
            _loc7_ = mItemObject.itemDefinition.baseWidth;
            if(_loc6_ > _loc7_)
            {
               _loc3_.scaleX = _loc7_ / _loc6_;
               _loc3_.scaleY = _loc3_.scaleX;
            }
            _loc3_.x = mItemObject.getBarX();
            _loc3_.y = mItemObject.getBarY();
            _loc4_.x = _loc3_.x;
            _loc4_.y = _loc3_.y;
            _loc4_.scaleX = _loc3_.scaleX;
            _loc4_.scaleY = _loc3_.scaleY;
         }
      }
      
      override public function removeAllSpritesInState() : void
      {
         this.hideIcons();
         this.mContractAnimVisible = false;
         this.mRentAnimVisible = false;
      }
      
      override public function eventsProcess(param1:Object) : void
      {
         var _loc2_:String = param1.cmd;
         switch(_loc2_)
         {
            case CMD_SIGN_CONTRACT:
               this.setMode(MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT,true);
               break;
            case CMD_COLLECTIBLE_GOTTEN:
               this.setMode(MODE_WAITING_FOR_CONTRACT);
               break;
            case CMD_COMMERCE_COLLECTIBLE_GOTTEN:
               this.setMode(MODE_RENTING);
         }
      }
      
      override public function exit() : void
      {
         super.exit();
         this.checkEnd();
      }
      
      protected function setMode(param1:int, param2:Boolean = true, param3:Boolean = true, param4:Boolean = false) : void
      {
         var _loc10_:TopLayer = null;
         var _loc12_:ContractDefinition = null;
         var _loc13_:Company = null;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc17_:Profile = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:String = null;
         var _loc21_:Boolean = false;
         var _loc22_:int = 0;
         var _loc23_:XML = null;
         var _loc24_:XML = null;
         var _loc25_:int = 0;
         var _loc26_:Object = null;
         var _loc27_:Boolean = false;
         var _loc28_:ContractDefinition = null;
         var _loc29_:Object = null;
         var _loc30_:Object = null;
         var _loc5_:Boolean = this.mMode != param1;
         var _loc6_:int = this.mMode;
         var _loc7_:int = int(mItemObject.getSellPrice(false));
         var _loc8_:int = -1;
         var _loc9_:Boolean = false;
         _loc10_ = this.mMap.getTopLayer();
         if(_loc5_)
         {
            switch(this.mMode)
            {
               case MODE_WAITING_FOR_CONTRACT:
                  this.mIsAccelerated = false;
                  if(Config.USE_OLD_ICON_SYSTEM)
                  {
                     mItemObject.destroyIcon(this.checkEnd);
                  }
                  else if(this.mContractAnimatingSprite != null)
                  {
                     this.mMap.getTopLayer().removeItemInLayer(this.mContractAnimatingSprite,mItemObject);
                     this.mContractAnimatingSprite = null;
                     this.mContractAnimVisible = false;
                  }
                  if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_SIGN_CONTRACT_ID)
                  {
                     Tutorial.removeHouseArrow(mItemObject);
                  }
                  break;
               case MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT:
                  mItemObject.setDisplayObjectWaitingForUI(false);
                  break;
               case MODE_SIGNING_CONTRACT:
                  DollarsEventManager.getInstance().waitersRemoveWaiter(mItemObject,DollarsEventManager.EVENT_SIGN_CONTRACT_ID);
                  this.contractRemoveView(CONTRACT_SIGN_BAR_ID);
                  if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_SIGN_CONTRACT_ID)
                  {
                     param1 = MODE_NONE;
                     this.contractAddView(CONTRACT_SIGN_END_ID);
                     Tutorial.activeOkButton();
                  }
                  if(param2 && Config.USE_SOUNDS)
                  {
                     SoundManager.getInstance().playSound(ModelConfig.SOUND_CONTRACT,1,0,0);
                  }
                  break;
               case MODE_CANCELING_CONTRACT:
                  this.contractRemoveView(CONTRACT_CANCEL_BAR_ID);
                  _loc12_ = mItemObject.getContract();
                  if(_loc12_.getCostCoins() > 0)
                  {
                     _loc13_ = mItemObject.company;
                     _loc14_ = _loc12_.getCostCoins() * RulesFacade.getInstance().settingsGetCancelContractProfitPercentage() / 100;
                     _loc13_.DCCoins += _loc14_;
                     gainedAccumDCCoins(_loc14_);
                     ParticlesManager.addParticle(new PointsAnimation(_loc14_,PointsAnimation.TYPE_COINS,mItemObject.displayObjectL0.x,mItemObject.displayObjectL0.y));
                  }
                  if(!mItemObject.itemDefinition.isACommerce())
                  {
                     mItemObject.company.nextRentDismiss(mItemObject);
                  }
                  break;
               case MODE_RENTING:
                  if(param1 != MODE_CANCELING_CONTRACT && !mItemObject.itemDefinition.isACommerce())
                  {
                     mItemObject.company.nextRentDismiss(mItemObject);
                  }
                  break;
               case MODE_GET_RENT:
                  mItemObject.endLoopGlow();
                  if(mItemObject.itemDefinition.hasCommerceBehaviour())
                  {
                     mItemObject.influenceResetItemsAffectedByCommerce();
                  }
                  else
                  {
                     itemObject.company.registerOccurrencesRemoveEvent(Company.REGISTER_OCCURRENCES_ITEM_ON_GET_RENT);
                  }
                  if(Config.USE_OLD_ICON_SYSTEM)
                  {
                     mItemObject.destroyIcon();
                     break;
                  }
                  if(this.mRentAnimationSprite != null)
                  {
                     this.mMap.getTopLayer().removeItemInLayer(this.mRentAnimationSprite,mItemObject);
                     this.mRentAnimationSprite = null;
                     this.mRentAnimVisible = false;
                  }
                  break;
               case MODE_COLLECTIBLE:
                  break;
               case MODE_GIVING_COLLECTIBLE:
                  this.mVaultReached = false;
                  this.mStartMoving = false;
                  break;
               case MODE_ABANDONED:
                  this.contractRemoveView(CONTRACT_ABANDONED_ID);
            }
         }
         var _loc11_:int = this.mMode;
         this.mMode = param1;
         switch(this.mMode)
         {
            case MODE_WAITING_FOR_CONTRACT:
               if(mItemObject.itemDefinition.isAClub())
               {
                  mItemObject.changeAnim(ItemObject.STATE_HQ_NORMAL);
               }
               else
               {
                  mItemObject.changeAnim(ItemObject.STATE_NORMAL);
               }
               mItemObject.changeAnimFrame(1);
               mItemObject.disableContract();
               if(Config.USE_OLD_ICON_SYSTEM)
               {
                  mItemObject.setIcon(ItemObject.ICON_CONTRACT);
                  mItemObject.gotoAndPlayIcon(1);
               }
               else if(this.mContractAnimatingSprite == null)
               {
                  this.setAnimationContract();
               }
               this.mMaxIncomeTime = 0;
               this.mIncomeTime = 0;
               this.mIncomeTimeTarget = 0;
               break;
            case MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT:
               if(param2)
               {
                  mItemObject.setDisplayObjectWaitingForUI(true);
                  DollarsEventManager.getInstance().waitersAddWaiter(mItemObject,DollarsEventManager.EVENT_SIGN_CONTRACT_ID);
                  break;
               }
               if(Config.OFFLINE_GAMEPLAY_MODE)
               {
                  this.setMode(MODE_WAITING_FOR_CONTRACT,true);
               }
               break;
            case MODE_SIGNING_CONTRACT:
               if(Config.USE_OLD_ICON_SYSTEM)
               {
                  mItemObject.setIcon(ItemObject.ICON_CONTRACT_COLLECT,this.checkEnd);
                  mItemObject.gotoAndPlayIcon(1);
               }
               else
               {
                  this.contractAddView(CONTRACT_SIGN_ID);
               }
               this.contractAddView(CONTRACT_SIGN_BAR_ID);
               if(param2)
               {
                  _loc12_ = mItemObject.getContract(true);
                  if(_loc12_.getCostCoins() > 0 && mItemObject.company.DCCoins >= _loc12_.getCostCoins())
                  {
                     _loc13_ = mItemObject.company;
                     _loc14_ = _loc12_.getCostCoins();
                     _loc13_.DCCoins -= _loc14_;
                     gainedAccumDCCoins(-_loc14_);
                     ParticlesManager.addParticle(new PointsAnimation(-_loc14_,PointsAnimation.TYPE_COINS,mItemObject.displayObjectL0.x,mItemObject.displayObjectL0.y));
                     _loc17_ = DollarsGame.getProfile();
                     _loc17_.companyValue += _loc12_.getCostCoins();
                  }
                  this.mIncomeTime = this.CONTRACT_SIGN_TIME;
                  this.mIncomeTimeTarget = this.mIncomeTime;
                  if(mUIIsMouseOver)
                  {
                     mItemObject.undoMouseOver(true);
                     this.mMap.setToolItemMouseOver(mItemObject);
                  }
                  break;
               }
               DollarsEventManager.getInstance().waitersAddWaiter(mItemObject,DollarsEventManager.EVENT_SIGN_CONTRACT_ID);
               break;
            case MODE_CANCELING_CONTRACT:
               this.contractAddView(CONTRACT_CANCEL_BAR_ID);
               if(param2)
               {
                  this.mIncomeTime = this.CONTRACT_CANCEL_TIME;
                  this.mIncomeTimeTarget = this.mIncomeTime;
                  if(mUIIsMouseOver)
                  {
                     mItemObject.undoMouseOver(true);
                     this.mMap.setToolItemMouseOver(mItemObject);
                  }
                  break;
               }
               mItemObject.enableContract();
               break;
            case MODE_RENTING:
               _loc15_ = !mItemObject.itemDefinition.isACommerce();
               mItemObject.changeAnimFrame(1);
               if(_loc15_)
               {
                  mItemObject.enableContract();
               }
               if(param2)
               {
                  if(_loc15_)
                  {
                     this.contractAddView(CONTRACT_SIGN_END_ID);
                  }
                  this.incomeInit();
               }
               this.mMaxIncomeTime = mItemObject.incomeTime;
               if(_loc15_)
               {
                  mItemObject.company.nextRentCheck(mItemObject);
               }
               break;
            case MODE_GET_RENT:
               _loc16_ = true;
               if(_loc16_)
               {
                  if(!param2 && !mItemObject.itemDefinition.isACommerce())
                  {
                     mItemObject.enableContract();
                  }
                  if(Dollars.getCurrentCursor().mCurrentCursorID == Cursor.CURSOR_SELECT)
                  {
                     _loc18_ = mItemObject.displayObjectL0.mouseX;
                     _loc19_ = mItemObject.displayObjectL0.mouseY;
                     if(_loc18_ >= mItemObject.worldX && _loc18_ <= mItemObject.worldX + mItemObject.worldSizeX && _loc19_ >= mItemObject.worldY && _loc19_ <= mItemObject.worldY + mItemObject.worldSizeY)
                     {
                        Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
                     }
                  }
                  mItemObject.changeAnimFrame(4,false);
                  if(Dollars.smStage.quality.toUpperCase() == StageQuality.HIGH.toUpperCase())
                  {
                     mItemObject.startLoopGlow(ItemObject.GLOW_LOOP_COLOR);
                  }
                  if(Config.USE_OLD_ICON_SYSTEM)
                  {
                     mItemObject.setIcon(ItemObject.ICON_RENT);
                     mItemObject.gotoAndPlayIcon(1);
                  }
                  else if(this.mRentAnimationSprite == null)
                  {
                     this.setAnimationRent();
                  }
                  if(!mItemObject.itemDefinition.isACommerce())
                  {
                     itemObject.company.registerOccurrencesAddEvent(Company.REGISTER_OCCURRENCES_ITEM_ON_GET_RENT);
                     if(param2)
                     {
                        this.mIncomeTime = RulesFacade.getInstance().settingsGetAbandonTime(mItemObject.incomeTime);
                        this.mIncomeTimeTarget = this.mIncomeTime;
                     }
                  }
               }
               break;
            case MODE_COLLECTIBLE:
               if(Config.COLLECTIBLE_FEATURE_ENABLED)
               {
                  if(!mItemObject.itemDefinition.isACommerce())
                  {
                     this.mDOGetCollectibleIcon = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTIBLES_EVENT_SWF,"Event"))();
                  }
                  else
                  {
                     this.mDOGetCollectibleIcon = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTIBLES_EVENT_SWF,"Event_commerce"))();
                  }
                  if(Dollars.getCurrentCursor().mCurrentCursorID == Cursor.CURSOR_SELECT)
                  {
                     _loc18_ = mItemObject.displayObjectL0.mouseX;
                     _loc19_ = mItemObject.displayObjectL0.mouseY;
                     if(_loc18_ >= mItemObject.worldX && _loc18_ <= mItemObject.worldX + mItemObject.worldSizeX && _loc19_ >= mItemObject.worldY && _loc19_ <= mItemObject.worldY + mItemObject.worldSizeY)
                     {
                        Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
                     }
                  }
               }
               break;
            case MODE_GIVING_RENT:
               if(param2)
               {
                  mItemObject.setIcon(ItemObject.ICON_RENT_COLLECT,this.checkEnd);
                  if(mUpgradeEnabled)
                  {
                     _loc9_ = true;
                     upgradeUnapply();
                  }
                  break;
               }
               this.setNextMode(false);
               break;
            case MODE_GIVING_COLLECTIBLE:
               if(Config.COLLECTIBLE_FEATURE_ENABLED)
               {
                  if(Config.COLLECTIBLE_AUTO_STORAGE_FEATURE)
                  {
                     _loc20_ = CollectibleManager.getInstance().getPendingCollectibleSku(mItemObject.mSid);
                     if(CollectibleManager.getInstance().canCollectibleBeKept(_loc20_) || mItemObject.itemDefinition.isACommerce())
                     {
                        this.mMovingCollectibleIcon = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"new_" + _loc20_))();
                        this.mMovingCollectibleIcon.x = mItemObject.itemDefinition.baseWidth >> 1;
                        this.mMovingCollectibleIcon.y = mItemObject.itemDefinition.baseHeight >> 1;
                        mItemObject.displayObjectL1.addChild(this.mMovingCollectibleIcon);
                        this.mMovingCollectibleIcon.gotoAndPlay(1);
                        this.mMovingCollectibleIcon.addEventListener(Event.ENTER_FRAME,this.checkCollEnd);
                        break;
                     }
                     PopupCollectibleManager.getInstance().smPopupCollectibleFound = new PopupCollectibleFound(PopupCollectibleFound.STATE_KEEP,_loc20_,false,mItemObject);
                     PopupCollectibleManager.getInstance().smPopupCollectibleFound.showPopup();
                     break;
                  }
                  this.mStars = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTIBLES_EVENT_SWF,"Event_ok"))();
                  this.mStars.x = mItemObject.itemDefinition.baseWidth >> 1;
                  this.mStars.y = mItemObject.itemDefinition.baseHeight >> 1;
                  mItemObject.displayObjectL1.addChild(this.mStars);
                  this.mStars.gotoAndPlay(1);
                  this.mStars.addEventListener(Event.ENTER_FRAME,this.checkCollEnd);
               }
               break;
            case MODE_ABANDONED:
               this.contractAddView(CONTRACT_ABANDONED_ID);
               mItemObject.disableContract();
               break;
            case MODE_RESETING_ABANDONED:
               if(param2)
               {
                  this.contractAddView(CONTRACT_RESETING_ABANDONED_ID);
                  break;
               }
               if(Config.OFFLINE_GAMEPLAY_MODE)
               {
                  this.setMode(MODE_WAITING_FOR_CONTRACT,true);
               }
         }
         if(mItemObject.itemDefinition.needsHQConnection() && !mItemObject.isHQConnected())
         {
            mItemObject.suspend();
         }
         if(param3 && this.mMap.mouseEnabled)
         {
            _loc21_ = mUIIsMouseOver && _loc6_ != this.mMode;
            if(_loc21_)
            {
               undoMouseOver();
            }
            if(_loc21_ && isMouseOverEnabled())
            {
               mItemObject.doMouseOver();
            }
            else if(param2)
            {
               if(this.mMap.getToolItemMouseOver() == mItemObject)
               {
                  this.mMap.reportMouseOver();
               }
            }
         }
         if(this.mLastModeSentToServer != this.mMode && UI_MODES.indexOf(this.mMode) == -1)
         {
            _loc22_ = this.mLastModeSentToServer;
            this.mLastModeSentToServer = this.mMode;
            _loc23_ = mItemObject.getPersistence(true);
            _loc24_ = XMLUtil.XMLListToXML(_loc23_.State);
            _loc25_ = int(_loc24_.@time);
            _loc26_ = {
               "mode":this.mMode,
               "time":_loc25_
            };
            if("@contractSku" in _loc24_)
            {
               _loc26_.contractSku = int(_loc24_.@contractSku);
            }
            if(_loc9_)
            {
               _loc26_.upgradeType = "" + UpgradesManager.getInstance().getUpgradeType(mItemObject.mSid);
            }
            if(this.mNotifyDoubleRent)
            {
               this.mNotifyDoubleRent = false;
               _loc26_.doubleRent = 1;
            }
            _loc27_ = true;
            if(Tutorial.smTutorialEnd)
            {
               if(_loc22_ == MODE_WAITING_FOR_CONTRACT && this.mMode == MODE_SIGNING_CONTRACT)
               {
                  _loc26_.mode = MODE_RENTING;
                  _loc28_ = mItemObject.getContract();
                  _loc26_.time = _loc28_.getIncomeTime();
                  _loc26_.contractGroupSku = mItemObject.itemDefinition.getContractsTypeSku();
               }
               else if(_loc11_ == MODE_SIGNING_CONTRACT && this.mMode == MODE_RENTING)
               {
                  _loc27_ = false;
               }
               else if(_loc22_ == MODE_GET_RENT && this.mMode == MODE_GIVING_RENT && !mItemObject.itemDefinition.isACommerce())
               {
                  _loc26_.mode = this.checkIfCollectible();
               }
               else if(_loc11_ == MODE_GIVING_RENT && (this.mMode == MODE_WAITING_FOR_CONTRACT || this.mMode == MODE_COLLECTIBLE))
               {
                  if(!mItemObject.itemDefinition.isACommerce())
                  {
                     _loc27_ = false;
                  }
               }
               else if(_loc11_ == MODE_COLLECTIBLE && this.mMode == MODE_GIVING_COLLECTIBLE)
               {
                  _loc27_ = false;
               }
            }
            if(_loc27_)
            {
               _loc29_ = UserDataFacade.securityCreateObj(mGainedExp,mGainedDCCoins,mGainedDCCash);
               UserDataFacade.getInstance().updateItem(mItemObject.mSid,"new_mode",_loc26_,_loc23_,_loc29_);
            }
            if(param4)
            {
               _loc30_ = new Object();
               _loc30_.cmd = UserDataFacade.QUEUE_REQUEST_UPDATE_ITEM;
               _loc30_.sid = mItemObject.mSid;
               _loc30_.action = "new_mode";
               _loc30_.params = _loc26_;
               _loc30_.xml = _loc23_;
               UserDataFacade.getInstance().queueRequestAdd(_loc30_);
               if(Config.DEBUG_MODE)
               {
                  Debug.trace("@@@@@@@@ queueRequestAdd " + _loc30_.cmd + " sid = " + mItemObject.mSid + ": ERROR in StateOnRent.setMode(): Item requires to notify an internal change of state");
               }
            }
         }
         gainedReset();
         if(_loc8_ >= 0)
         {
            this.setMode(_loc8_,true,true,true);
         }
      }
      
      private function checkCollEnd(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc4_:Sprite = null;
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_ != null)
         {
            if(_loc2_.currentFrame == _loc2_.totalFrames)
            {
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.checkCollEnd);
               if(Config.COLLECTIBLE_AUTO_STORAGE_FEATURE)
               {
                  _loc2_.stop();
               }
               else
               {
                  mItemObject.displayObjectL1.removeChild(_loc2_);
               }
               if(this.mMode == MODE_GIVING_COLLECTIBLE)
               {
                  _loc3_ = CollectibleManager.getInstance().getPendingCollectibleSku(mItemObject.mSid);
                  _loc4_ = DollarsGame.smInstance.mPopupClip;
                  _loc4_.addChild(_loc2_);
                  this.moveCollectible();
               }
            }
         }
      }
      
      private function checkPickCollectibleAnimEnd(param1:Event) : void
      {
         if(mItemObject.hasCurrentAnimFinished())
         {
            mItemObject.changeAnimFrame(4,true);
         }
      }
      
      private function giveIncome(param1:ItemObject = null, param2:Boolean = false) : void
      {
         var _loc3_:int = int(mItemObject.getIncomeValue(param2,param1));
         if(UserDataFacade.getInstance().isDoubleRent(mItemObject.itemDefinition.nameType))
         {
            this.mNotifyDoubleRent = true;
            this.giveDCCoins(_loc3_,param1,RulesFacade.getInstance().settingsGetIncomeMultiplier());
         }
         else
         {
            this.giveDCCoins(_loc3_,param1);
         }
         _loc3_ = int(mItemObject.incomeXP);
         this.giveExp(_loc3_,param1);
      }
      
      private function contractCancelOnAccept(param1:Event = null) : void
      {
         this.contractCancelOnClose(param1);
         this.setMode(MODE_CANCELING_CONTRACT);
      }
      
      override public function getIncomeTimeLeft() : int
      {
         return this.mIncomeTime;
      }
      
      override public function suspend() : void
      {
         super.suspend();
         this.onSuspend();
         var _loc1_:XML = mItemObject.getPersistence(true);
         var _loc2_:XML = XMLUtil.XMLListToXML(_loc1_.State);
         var _loc3_:int = int(_loc2_.@time);
         UserDataFacade.getInstance().updateItem(mItemObject.mSid,"upd_suspended",{
            "isSuspended":1,
            "time":_loc3_
         },mItemObject.getPersistence(true));
         if(Config.DEBUG_MODE)
         {
            Debug.trace("item (" + mItemObject.mSid + ") State_onRent: suspend");
         }
      }
      
      private function contractSignEndCheckEnd(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         if(!this.contractCheckEnd(CONTRACT_SIGN_END_ID,param1))
         {
            _loc2_ = this.mContractDOs[CONTRACT_SIGN_END_ID] as MovieClip;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numChildren)
            {
               if(_loc2_.getChildAt(_loc3_) is TextField)
               {
                  TextManager.reformatTextField(TextField(_loc2_.getChildAt(_loc3_)));
                  TextField(_loc2_.getChildAt(_loc3_)).text = TextManager.getText(TextIDs.TID_CONTRACT_SIGNED);
               }
               _loc3_++;
            }
         }
      }
      
      private function animateContract(param1:Boolean, param2:int) : void
      {
         if(param1)
         {
            if(this.mContractDOs[param2].scaleX > 1.25)
            {
               this.mContractScaleFactor = -0.02;
            }
            else if(this.mContractDOs[param2].scaleX < 0.75)
            {
               this.mContractScaleFactor = 0.02;
            }
            this.mContractDOs[param2].scaleX += this.mContractScaleFactor;
            this.mContractDOs[param2].scaleY += this.mContractScaleFactor;
         }
         else
         {
            clearInterval(this.mContractInterval);
            this.mContractDOs[param2].scaleX = 1;
            this.mContractDOs[param2].scaleY = 1;
         }
      }
      
      override public function isClickPriority() : Boolean
      {
         return this.mMode == MODE_GET_RENT;
      }
      
      override public function resume() : void
      {
         super.resume();
         this.onResume();
         var _loc1_:XML = mItemObject.getPersistence(true);
         var _loc2_:XML = XMLUtil.XMLListToXML(_loc1_.State);
         var _loc3_:int = int(_loc2_.@time);
         UserDataFacade.getInstance().updateItem(mItemObject.mSid,"upd_suspended",{
            "isSuspended":0,
            "time":_loc3_
         },mItemObject.getPersistence(true));
         if(Config.DEBUG_MODE)
         {
            Debug.trace("item (" + mItemObject.mSid + ") State_onRent: resume");
         }
      }
      
      override protected function doDoMouseOver(param1:Boolean = false) : void
      {
         if(this.isInfoBoxAllowed())
         {
            infoBoxStart();
         }
         this.doDoDoMouseOver(param1);
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         super.doLogicUpdate(param1);
         this.doDoLogicUpdate(param1);
      }
      
      protected function giveExp(param1:int, param2:ItemObject = null) : void
      {
         if(param2 == null)
         {
            param2 = mItemObject;
         }
         if(param1 > 0)
         {
            DollarsGame.getCurrentWorld().getCompanyMine().exp = DollarsGame.getCurrentWorld().getCompanyMine().exp + param1;
            gainedAccumExp(param1);
            ParticlesManager.addParticle(new PointsAnimation(param1,PointsAnimation.TYPE_XP,param2.displayObjectL0.x,param2.displayObjectL0.y));
         }
      }
      
      override protected function upgradeDoSetDOs() : void
      {
         mUpgradeDOs[UPGRADE_DO_UNAPPLY] = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,UNAPPLY_ANIM_SKUS[mUpgradeType]))();
      }
      
      override protected function doInfoBoxShow() : void
      {
         this.infoBoxRefresh();
      }
      
      override public function afterMoving() : void
      {
         super.afterMoving();
         if(this.mMode == MODE_RENTING)
         {
            this.mIncomeTime = this.mMaxIncomeTime;
            this.mIncomeTimeTarget = this.mIncomeTime;
         }
      }
      
      override public function setBehaviorTutorial(param1:int = -1) : void
      {
         if(param1 == Tutorial.TUTORIAL_STEP_SIGN_CONTRACT_ID)
         {
            this.setMode(MODE_WAITING_FOR_CONTRACT,true);
         }
         else if(param1 == Tutorial.TUTORIAL_STEP_COLLECT_RENT_ID)
         {
            mItemObject.enableContract();
            this.setMode(MODE_GET_RENT,true);
         }
      }
      
      override public function needsToBeTrackedForRent() : Boolean
      {
         return !mItemObject.itemDefinition.isACommerce() && this.mMode == MODE_RENTING;
      }
      
      override protected function doDoIsMouseOverEnabled() : Boolean
      {
         var _loc1_:Boolean = true;
         if(!Tutorial.smTutorialEnd)
         {
            _loc1_ = mItemObject.itemDefinition.type == ItemDefinition.TYPE_HOUSES_ID && (Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_SIGN_CONTRACT_ID || Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_COLLECT_RENT_ID);
         }
         return _loc1_;
      }
      
      override protected function onSuspend() : void
      {
         switch(this.mMode)
         {
            case MODE_WAITING_FOR_CONTRACT:
               this.hideIcons();
               this.mContractDOs[CONTRACT_ICON_ID].visible = false;
               break;
            case MODE_GET_RENT:
               this.hideIcons();
               break;
            case MODE_SIGNING_CONTRACT:
               this.mContractDOs[CONTRACT_SIGN_ID].visible = false;
               this.mContractDOs[CONTRACT_SIGN_BAR_ID].visible = false;
               break;
            case MODE_CANCELING_CONTRACT:
               this.mContractDOs[CONTRACT_CANCEL_BAR_ID].visible = false;
               break;
            case MODE_ABANDONED:
               this.mContractDOs[CONTRACT_ABANDONED_ID].visible = false;
         }
      }
      
      public function getVelocity(param1:Number, param2:Vector2D) : Vector2D
      {
         var _loc6_:Number = NaN;
         var _loc7_:Vector2D = null;
         var _loc8_:Vector2D = null;
         var _loc9_:Vector2D = null;
         var _loc3_:Vector2D = new Vector2D(this.mFinalPosition).minus(param2);
         var _loc4_:Vector2D = new Vector2D(this.mFinalPosition).minus(this.mInitialPosition);
         var _loc5_:Number = _loc3_.magnitude;
         if(_loc5_ > 0)
         {
            _loc6_ = 0.98 * _loc3_.magnitude / _loc4_.magnitude + 0.01;
            _loc7_ = _loc3_.times(0.5);
            _loc8_ = new Vector2D(_loc7_).normalize().times(60);
            if(_loc8_.magnitude < _loc7_.magnitude)
            {
               _loc7_ = _loc8_;
            }
            _loc9_ = new Vector2D(this.mCurrentVelocity).times(_loc6_).plus(_loc7_.times(1 - _loc6_));
            if(_loc9_.magnitude < 0.1)
            {
               return new Vector2D(0,0);
            }
            return _loc9_;
         }
         return new Vector2D(0,0);
      }
      
      override protected function doInfoBoxGetBox() : InfoBox
      {
         if(this.mInfoBox == null)
         {
            if(mItemObject.isSuspended)
            {
               this.mInfoBox = new InfoBoxAbandoned(DollarsGame.smInstance.mPopupClip,mItemObject.itemDefinition,TextIDs.TID_DISCONNECTED_HOUSE,TextIDs.TID_DISCONNECTED_SOLUTION);
            }
            else if(mItemObject.itemDefinition.type == ItemDefinition.TYPE_HOUSES_ID && this.mMode == MODE_WAITING_FOR_CONTRACT)
            {
               this.mInfoBox = new ItemDefinition.TYPE_INFO_BOX[ItemDefinition.TYPE_WONDERS_ID](DollarsGame.smInstance.mPopupClip,mItemObject.itemDefinition);
            }
            else
            {
               this.mInfoBox = new ItemDefinition.TYPE_INFO_BOX[mItemObject.itemDefinition.type](DollarsGame.smInstance.mPopupClip,mItemObject.itemDefinition);
            }
         }
         return this.mInfoBox;
      }
      
      override public function getPersistence() : XML
      {
         var _loc1_:XML = super.getPersistence();
         _loc1_.@mode = this.mMode;
         var _loc2_:String = mItemObject.getContractSku();
         if(_loc2_ != null && _loc2_ != "")
         {
            _loc1_.@contractSku = mItemObject.getContractSku();
         }
         if(this.mIsAccelerated)
         {
            _loc1_.@accelerated = "1";
         }
         if(this.mIncomeTime != this.mIncomeTimeTarget)
         {
            this.mIncomeTime = this.mIncomeTimeTarget;
         }
         _loc1_.@time = this.mIncomeTime;
         return _loc1_;
      }
      
      override protected function doIsSelectable() : Boolean
      {
         if(this.mMode == MODE_GET_RENT)
         {
            this.doDoSelection();
         }
         else if(mItemObject.company.isMine() && this.mMode == MODE_RENTING)
         {
            return true;
         }
         return false;
      }
      
      protected function doDoLogicUpdate(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:Vector2D = null;
         var _loc10_:Vector2D = null;
         var _loc11_:InfoBox = null;
         var _loc12_:PollEvent = null;
         if(mLogicUpdateEnabled)
         {
            _loc2_ = -1;
            if(!Tutorial.smTutorialEnd && (Tutorial.smTutorialStep != Tutorial.TUTORIAL_STEP_SIGN_CONTRACT_ID || Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_SIGN_CONTRACT_ID && !this.mMap.mouseEnabled || mItemObject.itemDefinition.isACommerce()))
            {
               return;
            }
            _loc3_ = false;
            this.mIncomeTimeTarget -= param1;
            this.mIncomeTime -= param1;
            if(this.mIncomeTime != this.mIncomeTimeTarget)
            {
               _loc4_ = this.mIncomeTimeTarget / 20;
               if(_loc4_ <= 0)
               {
                  _loc4_ = 0;
               }
               this.mIncomeTime -= _loc4_;
               if(this.mIncomeTime < this.mIncomeTimeTarget || _loc4_ == 0)
               {
                  this.mIncomeTime = this.mIncomeTimeTarget;
               }
            }
            if(this.mIncomeTime <= 0)
            {
               this.mIncomeTime = 0;
               this.mIncomeTimeTarget = 0;
               _loc3_ = true;
            }
            switch(this.mMode)
            {
               case MODE_POSTPONING_SET_MODE:
                  this.setMode(this.mNextModeId,true);
                  break;
               case MODE_SIGNING_CONTRACT:
                  this.mContractSignFillBar.setValueWithoutBarAnimation(this.CONTRACT_SIGN_TIME - this.mIncomeTime);
                  if(_loc3_)
                  {
                     this.setMode(MODE_RENTING,true);
                  }
                  break;
               case MODE_CANCELING_CONTRACT:
                  this.mContractCancelFillBar.setValueWithoutBarAnimation(this.CONTRACT_CANCEL_TIME - this.mIncomeTime);
                  if(_loc3_)
                  {
                     this.setMode(MODE_WAITING_FOR_CONTRACT,true);
                  }
                  break;
               case MODE_RENTING:
                  _loc5_ = 2 - regla3(this.mIncomeTime,this.mMaxIncomeTime,3);
                  if(mItemObject.getAnimFrame() != _loc5_)
                  {
                     mItemObject.changeAnimFrame(_loc5_ + 1);
                  }
                  if(_loc3_)
                  {
                     _loc7_ = true;
                     if(mItemObject.itemDefinition.isACommerce())
                     {
                        if(_loc2_ == -1)
                        {
                           _loc2_ = mItemObject.getPopulation();
                        }
                        if(_loc2_ == 0)
                        {
                           this.setMode(MODE_RENTING,true,false);
                           _loc7_ = false;
                        }
                     }
                     if(_loc7_)
                     {
                        this.mIncomeTime = 0;
                        this.mIncomeTimeTarget = 0;
                        this.setMode(MODE_GET_RENT);
                        if(!Tutorial.smTutorialEnd)
                        {
                           Tutorial.incomeHouseArrow();
                        }
                     }
                  }
                  break;
               case MODE_GET_RENT:
                  if(mItemObject.itemDefinition.hasCommerceBehaviour())
                  {
                     if(_loc2_ == -1)
                     {
                        _loc2_ = mItemObject.getPopulation();
                     }
                     if(_loc2_ == 0)
                     {
                        if(mItemObject.itemDefinition.isAClub())
                        {
                           this.setMode(MODE_ABANDONED);
                        }
                        else
                        {
                           this.setMode(MODE_RENTING);
                        }
                        _loc3_ = false;
                        mItemObject.endGlow();
                     }
                  }
                  if(_loc3_)
                  {
                     if(!mItemObject.itemDefinition.isACommerce())
                     {
                        this.setMode(MODE_ABANDONED);
                     }
                  }
                  break;
               case MODE_COLLECTIBLE:
                  _loc6_ = CollectibleManager.getInstance().getPendingCollectibleSku(mItemObject.mSid);
                  if(!_loc6_)
                  {
                     if(Config.COLLECTIBLE_COMMERCES_FEATURE)
                     {
                        _loc8_ = mItemObject.itemDefinition.isACommerce() ? MODE_RENTING : MODE_WAITING_FOR_CONTRACT;
                     }
                     else
                     {
                        _loc8_ = MODE_WAITING_FOR_CONTRACT;
                     }
                     this.setMode(_loc8_);
                     break;
                  }
                  this.setMode(MODE_GIVING_COLLECTIBLE);
                  break;
               case MODE_GIVING_COLLECTIBLE:
                  if(!this.mVaultReached && this.mStartMoving)
                  {
                     _loc9_ = this.getVelocity(param1,new Vector2D(this.mMovingCollectibleIcon.x,this.mMovingCollectibleIcon.y));
                     this.mCurrentVelocity = _loc9_;
                     _loc10_ = new Vector2D(this.mMovingCollectibleIcon.x,this.mMovingCollectibleIcon.y).plus(_loc9_);
                     this.mMovingCollectibleIcon.x = _loc10_.x;
                     this.mMovingCollectibleIcon.y = _loc10_.y;
                     this.disposeCollectible();
                  }
            }
            if(this.mInfoBox != null)
            {
               if(mUIIsMouseOver && isMouseOverEnabled() && this.isInfoBoxAllowed())
               {
                  _loc11_ = this.doInfoBoxGetBox();
                  _loc11_.setTimer(mItemObject,this.mIncomeTime);
                  if(mItemObject.itemDefinition.hasCommerceBehaviour())
                  {
                     _loc11_.setIncome(mItemObject.getIncomeValue(true));
                     _loc2_ = mItemObject.getPopulation();
                     _loc11_.setAttendance(_loc2_);
                  }
               }
               else
               {
                  this.doInfoBoxHide();
               }
            }
            if(mItemObject.company.isMine() && mItemObject.itemDefinition.isACommerce())
            {
               _loc12_ = PollManager.getInstance().getEvent(MissionsEventIDs.MISSION_EVENT_CHECK_INFLUENCE + mItemObject.itemDefinition.nameType);
               if(_loc12_ != null && _loc12_.needsToBeChecked())
               {
                  if(_loc2_ == -1)
                  {
                     _loc2_ = mItemObject.getPopulation();
                  }
                  _loc12_.checkCondition(_loc2_,mItemObject.sid);
               }
               _loc12_ = PollManager.getInstance().getEvent(MissionsEventIDs.MISSION_EVENT_CHECK_INFLUENCE + mItemObject.itemDefinition.sku);
               if(_loc12_ != null && _loc12_.needsToBeChecked())
               {
                  if(_loc2_ == -1)
                  {
                     _loc2_ = mItemObject.getPopulation();
                  }
                  _loc12_.checkCondition(_loc2_,mItemObject.sid);
               }
            }
         }
      }
      
      private function contractSignAnimCheckEnd(param1:Event) : void
      {
         this.contractCheckEnd(CONTRACT_SIGN_ID,param1);
      }
      
      private function setAnimationContract() : void
      {
         var _loc1_:TopLayer = this.mMap.getTopLayer();
         if(_loc1_)
         {
            this.mContractAnimatingSprite = new DCBitmapSprite(_loc1_.getResource(TopLayer.PNG_CONTRACT),_loc1_.getResource(TopLayer.PNG_CONTRACT + TopLayer.MASK),TopLayer.TILE_WIDTH,TopLayer.TILE_HEIGHT);
            this.setAnimationPosition(this.mContractAnimatingSprite);
            this.mMap.getTopLayer().addItemInLayer(this.mContractAnimatingSprite,mItemObject);
            this.mContractAnimVisible = true;
         }
      }
      
      override public function isInfoBoxAllowed() : Boolean
      {
         return this.mMode == MODE_RENTING || this.mMode == MODE_WAITING_FOR_CONTRACT;
      }
      
      public function incomeInit() : void
      {
         this.mIncomeTime = mItemObject.incomeTime;
         this.mIncomeTimeTarget = this.mIncomeTime;
         if(!Tutorial.smTutorialEnd && !smTutorialAlreadyUsed)
         {
            this.mIncomeTime = Tutorial.TUTORIAL_BUILD_HOUSE_TIME;
            smTutorialAlreadyUsed = true;
         }
         this.mMaxIncomeTime = this.mIncomeTime;
      }
      
      protected function doDoDoMouseOver(param1:Boolean = false) : void
      {
         var _loc2_:Role = mItemObject.company.world.role;
         if(_loc2_ != null)
         {
            if(mItemObject.company.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON)
            {
               if(this.mMode == MODE_GET_RENT)
               {
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_COLLECT);
               }
               else if(this.mMode == MODE_RENTING && Tutorial.smTutorialEnd)
               {
                  if(!mItemObject.itemDefinition.isACommerce())
                  {
                     Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_CANCEL_CONTRACT);
                  }
               }
               else if(this.mMode == MODE_WAITING_FOR_CONTRACT && Dollars.getCurrentCursor().mCurrentCursorID != Cursor.CURSOR_MOVE)
               {
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SIGN_CONTRACT);
               }
               else if(this.mMode == MODE_ABANDONED)
               {
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_ABANDONED);
               }
               else if(this.mMode == MODE_COLLECTIBLE)
               {
                  if(mItemObject.itemDefinition.isACommerce())
                  {
                     Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_COLLECTIBLE_COMMERCE);
                  }
                  else
                  {
                     Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_COLLECTIBLE);
                  }
               }
            }
         }
      }
      
      protected function onIncome(param1:MouseEvent = null) : void
      {
         var _loc2_:Array = null;
         var _loc3_:ItemObject = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:ContractDefinition = null;
         if(mItemObject.itemDefinition.isACommerce())
         {
            _loc2_ = mItemObject.influenceGetItemsAffectedByCommerce();
            for each(_loc3_ in _loc2_)
            {
               this.giveIncome(_loc3_);
               _loc4_ = mItemObject.itemDefinition.getCommerceType().getDOIconOnHouse();
               _loc5_ = _loc3_.worldX + (_loc3_.itemDefinition.baseWidth >> 1);
               _loc6_ = _loc3_.worldY + (_loc3_.itemDefinition.baseHeight >> 1);
               ParticlesManager.addParticle(new ParticleAnimation(_loc5_,_loc6_,_loc4_),false);
            }
         }
         else
         {
            this.giveIncome(null,mItemObject.itemDefinition.isAClub());
            _loc7_ = mItemObject.getContract();
            PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_COLLECT_INCOME,mItemObject.itemDefinition.nameType + "%" + _loc7_.getTimeSku());
            mItemObject.disableContract(false);
            if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == Tutorial.TUTORIAL_STEP_COLLECT_RENT_ID)
            {
               mItemObject.undoMouseOver(true);
               Tutorial.activeOkButton();
            }
            if(mItemObject.getCurrentState().upgradeGetEnabled())
            {
               PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_COLLECT_UPGRADED,mItemObject.itemDefinition.nameType);
            }
         }
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_COLLECT_INCOME,mItemObject.itemDefinition.nameType);
         PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_COLLECT_INCOME,mItemObject.itemDefinition.sku);
         if(Config.USE_SOUNDS)
         {
            SoundManager.getInstance().playSound(ModelConfig.SOUND_INCOME,1,0,0);
         }
      }
      
      private function contractAddView(param1:int) : void
      {
         var _loc2_:MovieClip = this.mContractDOs[param1] as MovieClip;
         if(_loc2_ != null)
         {
            switch(param1)
            {
               case CONTRACT_SIGN_ID:
                  _loc2_.gotoAndPlay(1);
                  _loc2_.addEventListener(Event.ENTER_FRAME,this.contractSignAnimCheckEnd);
                  _loc2_.mouseChildren = false;
                  break;
               case CONTRACT_RESETING_ABANDONED_ID:
                  _loc2_.gotoAndPlay(1);
                  _loc2_.addEventListener(Event.ENTER_FRAME,this.contractResetingAbandonedCheckEnd);
                  break;
               case CONTRACT_SIGN_END_ID:
                  _loc2_.gotoAndPlay(1);
                  _loc2_.addEventListener(Event.ENTER_FRAME,this.contractSignEndCheckEnd);
                  break;
               case CONTRACT_ICON_ID:
                  _loc2_.gotoAndPlay(1);
            }
            this.contractGetParent().addChild(_loc2_);
         }
      }
      
      private function contractDestroy() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.mContractDOs != null)
         {
            _loc1_ = int(this.mContractDOs.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               this.contractRemoveView(_loc2_);
               _loc2_++;
            }
            this.mContractDOs.splice(0,_loc1_);
            this.mContractDOs = null;
            this.mContractSignFillBar = null;
            this.mContractCancelFillBar = null;
         }
      }
      
      override public function isAffectedByType(param1:int) : Boolean
      {
         return this.mMode == MODE_GET_RENT || this.mMode == MODE_RENTING;
      }
      
      override public function resetMode() : void
      {
         switch(this.mMode)
         {
            case MODE_GET_RENT:
               this.setMode(MODE_RENTING);
         }
      }
      
      override protected function doInfoBoxHide() : void
      {
         if(this.mInfoBox != null)
         {
            this.mInfoBox.close();
            this.mInfoBox.destroy();
            this.mInfoBox = null;
         }
      }
      
      private function setAnimationRent() : void
      {
         var _loc2_:ItemDefinition = null;
         var _loc1_:TopLayer = this.mMap.getTopLayer();
         if(_loc1_)
         {
            _loc2_ = mItemObject.itemDefinition;
            if(mItemObject.itemDefinition.type == ItemDefinition.TYPE_COMMERCES_ID)
            {
               this.mRentAnimationSprite = new DCBitmapSprite(_loc1_.getResource(_loc2_.getCommerceIcon()),_loc1_.getResource(_loc2_.getCommerceIcon() + "_MASK"),TopLayer.TILE_WIDTH,TopLayer.TILE_HEIGHT);
            }
            else
            {
               this.mRentAnimationSprite = new DCBitmapSprite(_loc1_.getResource(TopLayer.PNG_RENT),_loc1_.getResource(TopLayer.PNG_RENT + TopLayer.MASK),TopLayer.TILE_WIDTH,TopLayer.TILE_HEIGHT);
            }
            this.setAnimationPosition(this.mRentAnimationSprite);
            this.mMap.getTopLayer().addItemInLayer(this.mRentAnimationSprite,mItemObject);
            this.mRentAnimVisible = true;
         }
      }
      
      private function contractCancelOnClose(param1:Event) : void
      {
         var _loc2_:PopupConfirmDestroy = param1.target as PopupConfirmDestroy;
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.contractCancelOnAccept);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.contractCancelOnClose);
         _loc2_.destroy();
         _loc2_ = null;
      }
      
      protected function giveDCCoins(param1:int, param2:ItemObject = null, param3:int = 1) : void
      {
         if(param2 == null)
         {
            param2 = mItemObject;
         }
         var _loc4_:int = param2.displayObjectL0.x;
         var _loc5_:int = param2.displayObjectL0.y;
         if(param1 > 0)
         {
            param1 *= param3;
            DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins + param1;
            gainedAccumDCCoins(param1);
            ParticlesManager.addParticle(new PointsAnimation(param1,PointsAnimation.TYPE_COINS,_loc4_,_loc5_));
            if(param3 > 1)
            {
               ParticlesManager.addParticle(new ParticleAnimation(_loc4_ + (param2.itemDefinition.baseWidth >> 1),_loc5_ + (param2.itemDefinition.baseHeight >> 1),this.mDoubleRentDO));
            }
         }
      }
      
      override public function changeAnimationQuality(param1:Boolean) : void
      {
         if(this.mMode == MODE_GET_RENT)
         {
            if(param1)
            {
               itemObject.startLoopGlow(ItemObject.GLOW_LOOP_COLOR);
            }
            else
            {
               itemObject.endLoopGlow();
            }
         }
      }
      
      private function setAnimationPosition(param1:DCBitmapSprite) : void
      {
         var _loc2_:Number = this.mMap.scaleX;
         param1.setPosition(mItemObject.worldX + (mItemObject.worldSizeX / _loc2_ - TopLayer.TILE_WIDTH) / 2,mItemObject.worldY + (mItemObject.worldSizeY / _loc2_ - TopLayer.TILE_HEIGHT) / 2);
         param1.visible = true;
      }
      
      override protected function doDoClick() : void
      {
         var _loc1_:PopupConfirmDestroy = null;
         switch(this.mMode)
         {
            case MODE_WAITING_FOR_CONTRACT:
               if(mItemObject.isHQConnected())
               {
                  DollarsGame.setItemOutlineEnabled(false);
                  DollarsGame.smInstance.mPopupContract.showPopupParam(mItemObject);
               }
               break;
            case MODE_RENTING:
               if(!mItemObject.itemDefinition.isACommerce() && mItemObject.isHQConnected())
               {
                  DollarsGame.setItemOutlineEnabled(false);
                  _loc1_ = new PopupConfirmDestroy();
                  _loc1_.addEventListener(Popup.EVENT_ACCEPT,this.contractCancelOnAccept);
                  _loc1_.addEventListener(Popup.EVENT_CLOSE,this.contractCancelOnClose);
                  _loc1_.showPopUp(Cursor.CURSOR_SELECT,TextManager.getText(TextIDs.TID_CANCEL_CONTRACT));
               }
               break;
            case MODE_GET_RENT:
               if(mItemObject.isHQConnected())
               {
                  this.onIncome();
                  this.setMode(MODE_GIVING_RENT);
                  if(!Tutorial.smTutorialEnd)
                  {
                     Tutorial.removeHouseArrow(mItemObject);
                  }
                  if(smRentsCollected <= this.TRACK_RENT_COUNT && DollarsGame.getProfile().companyValue > this.MIN_COMPANY_VALUE && DollarsGame.getProfile().companyValue < this.MAX_COMPANY_VALUE)
                  {
                     ++smRentsCollected;
                     if(smRentsCollected == this.TRACK_RENT_COUNT)
                     {
                        if(Dollars.smStage.quality.toUpperCase() == StageQuality.LOW.toUpperCase())
                        {
                           MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_FPS),MetricConstants.EVENT_FPS_COLLECTING_LO,DollarsGame.smFPSCounter.getTextValue());
                        }
                        else
                        {
                           MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_FPS),MetricConstants.EVENT_FPS_COLLECTING_HI,DollarsGame.smFPSCounter.getTextValue());
                        }
                        MyMetrics.send_GA_metric(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_FPS),MetricConstants.EVENT_FPS,MetricConstants.LABEL_COLLECTING_RENTS,DollarsGame.smFPSCounter.getValue());
                     }
                  }
               }
               break;
            case MODE_ABANDONED:
               if(mItemObject.isHQConnected())
               {
                  this.setMode(MODE_RESETING_ABANDONED,true);
               }
         }
      }
      
      override public function refreshPositionOfSprites() : void
      {
         mItemObject.setVisibilityIcon(true);
         if(this.mContractAnimatingSprite == null && this.mContractAnimVisible)
         {
            this.setAnimationContract();
         }
         if(this.mRentAnimationSprite == null && this.mRentAnimVisible)
         {
            this.setAnimationRent();
         }
      }
      
      private function contractGetParent() : DisplayObjectContainer
      {
         return mItemObject.displayObjectL1;
      }
      
      override protected function doDoSelection() : void
      {
         switch(this.mMode)
         {
            case MODE_GET_RENT:
               this.onIncome();
               this.setMode(MODE_RENTING);
         }
      }
      
      private function checkEnd(param1:Event = null) : void
      {
         var _loc2_:MovieClip = null;
         if(param1 != null)
         {
            _loc2_ = param1.target as MovieClip;
            if(_loc2_ != null && _loc2_.currentFrame == _loc2_.totalFrames)
            {
               mItemObject.destroyIcon(this.checkEnd);
               this.setNextMode();
            }
         }
      }
      
      protected function viewStart() : void
      {
         var _loc1_:DCResourceManager = DCResourceManager.getInstance();
         if(mItemObject.itemDefinition.type == ItemDefinition.TYPE_HOUSES_ID)
         {
            this.mDoubleRentDO = new (_loc1_.getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Duplicate"))();
         }
         this.contractLoad();
      }
      
      private function setNextMode(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         switch(this.mMode)
         {
            case MODE_GIVING_RENT:
               _loc2_ = this.checkIfCollectible();
               if(param1)
               {
                  this.setMode(_loc2_,true);
                  break;
               }
               this.mNextModeId = _loc2_;
               this.setMode(MODE_POSTPONING_SET_MODE);
         }
      }
      
      private function contractResetingAbandonedCheckEnd(param1:Event) : void
      {
         if(this.contractCheckEnd(CONTRACT_RESETING_ABANDONED_ID,param1))
         {
            this.setMode(MODE_WAITING_FOR_CONTRACT,true);
         }
      }
      
      private function eventInit() : void
      {
         this.mIncomeTime = mItemObject.eventOnTime;
         this.mIncomeTimeTarget = this.mIncomeTime;
         this.mMaxIncomeTime = this.mIncomeTime;
      }
      
      private function checkIfCollectibleUI() : int
      {
         var _loc1_:int = mItemObject.itemDefinition.isACommerce() ? MODE_RENTING : MODE_WAITING_FOR_CONTRACT;
         if(Config.COLLECTIBLE_FEATURE_ENABLED)
         {
            if(CollectibleManager.getInstance().hasPendingCollectible(mItemObject.mSid))
            {
               if(Config.COLLECTIBLE_COMMERCES_FEATURE)
               {
                  _loc1_ = MODE_COLLECTIBLE;
               }
               else
               {
                  _loc1_ = mItemObject.itemDefinition.isACommerce() ? MODE_RENTING : MODE_COLLECTIBLE;
               }
            }
         }
         return _loc1_;
      }
      
      private function viewUpdate() : void
      {
      }
      
      override protected function doUndoMouseOver() : void
      {
         if(this.mInfoBox != null)
         {
            infoBoxEnd();
         }
         var _loc1_:int = Cursor.CURSOR_SELECT;
         var _loc2_:Tool = this.mMap.currentTool;
         if(_loc2_ != null)
         {
            _loc1_ = _loc2_.getDefaultCursorID();
         }
         Dollars.getCurrentCursor().changeCursor(_loc1_);
      }
      
      public function accelerateIncomeTime(param1:int) : void
      {
         var _loc2_:int = 0;
         if(this.canBeAccelerated())
         {
            _loc2_ = this.mMaxIncomeTime * param1 / 100;
            this.mIncomeTimeTarget = this.mIncomeTime - _loc2_;
            if(this.mIncomeTimeTarget < 0)
            {
               this.mIncomeTimeTarget = 0;
            }
            this.mIsAccelerated = true;
            startParticles();
         }
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         this.mMap = mItemObject.company.world.map;
         super.enter();
         if(mItemObject.itemDefinition.isAClub())
         {
            mItemObject.changeAnim(ItemObject.STATE_HQ_NORMAL);
         }
         else
         {
            mItemObject.changeAnim(ItemObject.STATE_NORMAL);
         }
         this.doEnter(param1);
         if(mItemObject.isSuspended)
         {
            this.onSuspend();
         }
      }
      
      override public function setPersistence(param1:XML) : void
      {
         var _loc2_:String = null;
         this.mMode = param1.@mode;
         this.mIncomeTime = param1.@time;
         this.mIncomeTimeTarget = this.mIncomeTime;
         if("@contractSku" in param1)
         {
            _loc2_ = param1.@contractSku;
            if(_loc2_ != "")
            {
               mItemObject.setContractSku(_loc2_);
            }
         }
         if("@accelerated" in param1)
         {
            this.mIsAccelerated = param1.@accelerated == "1";
         }
      }
      
      override protected function infoBoxRefresh() : void
      {
         super.infoBoxRefresh();
         var _loc1_:InfoBox = this.doInfoBoxGetBox();
         _loc1_.setExp(mItemObject.incomeXP);
         _loc1_.setTimer(mItemObject,this.mIncomeTime);
         _loc1_.setIncome(mItemObject.getIncomeValue());
         if(!mItemObject.itemDefinition.isACommerce())
         {
            _loc1_.setAttendance(mItemObject.getPopulation());
         }
      }
      
      override protected function doIsMoveable() : Boolean
      {
         return this.mMode == MODE_WAITING_FOR_CONTRACT || this.mMode == MODE_RENTING || this.mMode == MODE_ABANDONED;
      }
      
      private function animateCollectible(param1:Boolean) : void
      {
         if(param1)
         {
            if(this.mDOGetCollectibleIcon.scaleX > 1.25)
            {
               this.mCollectibleScaleFactor = -0.02;
            }
            else if(this.mDOGetCollectibleIcon.scaleX < 0.75)
            {
               this.mCollectibleScaleFactor = 0.02;
            }
            this.mDOGetCollectibleIcon.scaleX += this.mCollectibleScaleFactor;
            this.mDOGetCollectibleIcon.scaleY += this.mCollectibleScaleFactor;
         }
         else
         {
            clearInterval(this.mCollectibleInterval);
            this.mDOGetCollectibleIcon.scaleX = 1;
            this.mDOGetCollectibleIcon.scaleY = 1;
         }
      }
      
      private function disposeCollectible() : void
      {
         var _loc2_:Sprite = null;
         var _loc1_:Vector2D = DollarsGame.getCurrentRole().toolsBar.getGiftButtonCoordinates();
         if(this.mMovingCollectibleIcon.y >= _loc1_.y || this.mCurrentVelocity.isEqualTo(new Vector2D(0,0)))
         {
            this.mVaultReached = true;
            _loc2_ = DollarsGame.smInstance.mPopupClip;
            _loc2_.removeChild(this.mMovingCollectibleIcon);
            clearInterval(this.mIntervalId);
            DollarsGame.getCurrentRole().toolsBar.setCollectibleForBar(CollectibleManager.getInstance().getPendingCollectibleSku(mItemObject.mSid));
            CollectibleManager.getInstance().keepCollectibleTask(mItemObject);
            DollarsGame.getCurrentRole().toolsBar.getDisplayObject().dispatchEvent(new Event(ToolsBar.SHOW_COLLECTIBLE_BAR_EVENT));
         }
      }
      
      private function contractCheckEnd(param1:int, param2:Event) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:MovieClip = this.mContractDOs[param1];
         if(_loc4_.currentFrame == _loc4_.totalFrames || param2 == null)
         {
            this.contractRemoveView(param1);
            if(param2 != null)
            {
               _loc3_ = true;
            }
         }
         return _loc3_;
      }
      
      private function moveCollectible() : void
      {
         var _loc1_:Vector2D = DollarsGame.getCurrentRole().toolsBar.getGiftButtonCoordinates();
         this.mStartMoving = true;
         var _loc2_:Number = mItemObject.itemDefinition.baseWidth >> 1;
         var _loc3_:Number = mItemObject.itemDefinition.baseHeight >> 1;
         var _loc4_:Number = mItemObject.worldX + _loc2_;
         var _loc5_:Number = mItemObject.worldY + _loc3_;
         var _loc6_:Number = this.mMap.getWorldXToScreen(_loc4_);
         var _loc7_:Number = this.mMap.getWorldYToScreen(_loc5_);
         var _loc8_:Number = _loc1_.x;
         this.mMovingCollectibleIcon.x = _loc6_;
         this.mMovingCollectibleIcon.y = _loc7_;
         this.mInitialPosition = new Vector2D(_loc6_,_loc7_);
         this.mFinalPosition = new Vector2D(_loc1_.x,_loc1_.y);
         var _loc9_:Vector2D = new Vector2D(this.mFinalPosition).minus(new Vector2D(this.mInitialPosition));
         this.mCurrentVelocity = new Vector2D(_loc9_).normalize().times(3);
         var _loc10_:Vector2D = _loc9_.times(2);
         var _loc11_:Number = 2;
         var _loc12_:Number = 1 / (_loc11_ * _loc11_);
         this.mAcceleration = _loc10_.times(_loc12_);
      }
      
      override protected function onResume() : void
      {
         switch(this.mMode)
         {
            case MODE_WAITING_FOR_CONTRACT:
               this.refreshPositionOfSprites();
               this.mContractDOs[CONTRACT_ICON_ID].visible = true;
               break;
            case MODE_GET_RENT:
               this.refreshPositionOfSprites();
               break;
            case MODE_SIGNING_CONTRACT:
               this.mContractDOs[CONTRACT_SIGN_BAR_ID].visible = true;
               break;
            case MODE_CANCELING_CONTRACT:
               this.mContractDOs[CONTRACT_CANCEL_BAR_ID].visible = true;
               break;
            case MODE_ABANDONED:
               this.mContractDOs[CONTRACT_ABANDONED_ID].visible = true;
         }
      }
      
      private function isAnimated() : Boolean
      {
         return Dollars.smStage.quality.toUpperCase() == StageQuality.HIGH.toString().toUpperCase();
      }
      
      override public function signContract(param1:ContractDefinition) : void
      {
         mItemObject.setContractSku(param1.sku);
         this.setMode(MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT,true);
      }
      
      override public function isIncomeReady() : Boolean
      {
         return this.mMode == MODE_GET_RENT;
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      private function isModeMouseOverEnabled() : Boolean
      {
         return this.mMode != MODE_SIGNING_CONTRACT && this.mMode != MODE_CANCELING_CONTRACT && this.mMode != MODE_WAITING_FOR_TURN_TO_SIGN_CONTRACT;
      }
      
      private function checkIfCollectible() : int
      {
         var _loc1_:int = mItemObject.itemDefinition.isACommerce() ? MODE_RENTING : MODE_WAITING_FOR_CONTRACT;
         if(Config.COLLECTIBLE_FEATURE_ENABLED)
         {
            if(CollectibleManager.getInstance().hasPendingCollectible(mItemObject.mSid))
            {
               if(Config.COLLECTIBLE_COMMERCES_FEATURE)
               {
                  _loc1_ = MODE_COLLECTIBLE;
               }
               else
               {
                  _loc1_ = mItemObject.itemDefinition.isACommerce() ? MODE_RENTING : MODE_COLLECTIBLE;
               }
            }
         }
         return _loc1_;
      }
      
      private function hideIcons() : void
      {
         mItemObject.setVisibilityIcon(false);
         if(this.mContractAnimatingSprite != null)
         {
            this.mMap.getTopLayer().removeItemInLayer(this.mContractAnimatingSprite,mItemObject);
            this.mContractAnimatingSprite = null;
         }
         if(this.mRentAnimationSprite != null)
         {
            this.mMap.getTopLayer().removeItemInLayer(this.mRentAnimationSprite,mItemObject);
            this.mRentAnimationSprite = null;
         }
      }
      
      override public function isContractSignReady() : Boolean
      {
         return this.mMode == MODE_WAITING_FOR_CONTRACT;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.exit();
         this.viewEnd();
      }
      
      override protected function doIsDestroyable() : Boolean
      {
         return true;
      }
   }
}

