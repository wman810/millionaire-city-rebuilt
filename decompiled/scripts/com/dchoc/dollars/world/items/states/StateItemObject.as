package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.utils.particles.ParticleUpgrade;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.notifications.Notification;
   import com.dchoc.framework.states.FSMState;
   import com.dchoc.framework.states.StateMachine;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class StateItemObject extends FSMState
   {
      
      public static const STATE_NONE:int = -1;
      
      public static const STATE_ON_CONSTRUCTION_ID:int = 0;
      
      public static const STATE_ON_RENT_ID:int = 1;
      
      public static const STATE_ON_SELLING_ID:int = 2;
      
      public static const STATE_ON_IA_ID:int = 3;
      
      public static const STATE_ON_HEADQUARTER_ID:int = 4;
      
      public static const STATE_ON_BUILT_ID:int = 5;
      
      public static const STATE_ON_DEMOLITION_ID:int = 6;
      
      public static const STATE_ON_HIRE_CREW:int = 7;
      
      public static const AGILE_BAR_TIME:int = 3000;
      
      public static const SELL_BAR_TIME:int = AGILE_BAR_TIME;
      
      protected static const UPGRADE_DO_APPLY:int = 0;
      
      protected static const UPGRADE_DO_SIGN:int = 1;
      
      protected static const UPGRADE_DO_UNAPPLY:int = 2;
      
      protected static const UPGRADE_DO_COUNT:int = 3;
      
      protected var mGainedExp:int;
      
      protected var mInfoBoxTimer:int;
      
      private var mUpgradeCurrentAnimId:int;
      
      protected var mGainedDCCoins:int;
      
      protected var mGainedDCCash:int;
      
      protected var mUpgradeEnabled:Boolean;
      
      protected var mItemObject:ItemObject;
      
      protected var mUIIsSelected:Boolean;
      
      protected var mUIIsMouseOver:Boolean;
      
      public var mUIIsSell:Boolean;
      
      protected var mLogicUpdateEnabled:Boolean;
      
      protected var mUpgradeType:int;
      
      protected var mNotification:Notification;
      
      protected var mUpgradeDOs:Array;
      
      public function StateItemObject(param1:StateMachine)
      {
         super(param1);
         this.mItemObject = ItemObject(param1);
         this.mLogicUpdateEnabled = true;
      }
      
      public static function getStateName(param1:int) : String
      {
         var _loc2_:Array = ["CONSTRUCTION","RENT","SELLING","IA","HEADQUARTER","BUILT","DEMOLITION"];
         if(param1 < 0 || param1 >= _loc2_.length)
         {
            return "id:" + param1;
         }
         return _loc2_[param1];
      }
      
      protected function checksExitCondition() : Boolean
      {
         return false;
      }
      
      public function gainedAccumExp(param1:int) : void
      {
         this.mGainedExp += param1;
      }
      
      public function isOutlineInMouseOverEnabled() : Boolean
      {
         return true;
      }
      
      public function undoSelection() : void
      {
         if(this.mNotification != null && this.mNotification.blocksState())
         {
            return this.mNotification.doUndoSelection();
         }
         return this.doUndoSelection();
      }
      
      public function isTimerCountDownEnabled() : Boolean
      {
         return true;
      }
      
      public function isMouseOver() : Boolean
      {
         return this.mUIIsMouseOver;
      }
      
      protected function upgradeLogicUpdate(param1:int) : void
      {
         ParticleUpgrade(this.mUpgradeDOs[UPGRADE_DO_SIGN]).update(param1);
      }
      
      public function eventsProcess(param1:Object) : void
      {
      }
      
      public function doUIEventWaitingFor() : void
      {
      }
      
      public function removeAllSpritesInState() : void
      {
      }
      
      protected function doIsMouseOverEnabled() : Boolean
      {
         var _loc1_:Boolean = true;
         var _loc2_:Role = this.mItemObject.company.world.role;
         if(_loc2_ != null && !this.mItemObject.company.world.role.isMouseOverEnabled())
         {
            _loc1_ = false;
         }
         if(_loc1_)
         {
            if(this.isSuspensionCheckForMouseOverEnabled())
            {
               _loc1_ = !this.mItemObject.isSuspended;
            }
            else
            {
               if(!this.mItemObject.isSuspended)
               {
                  return this.doDoIsMouseOverEnabled();
               }
               _loc1_ = Tutorial.smTutorialEnd;
            }
         }
         return _loc1_;
      }
      
      override public function exit() : void
      {
         super.exit();
         if(this.mNotification != null)
         {
            this.mNotification.destroy();
         }
         this.upgradeDestroy();
      }
      
      protected function infoBoxHide() : void
      {
         var _loc1_:InfoBox = this.infoBoxGetBox();
         this.doInfoBoxHide();
         this.mInfoBoxTimer = -1;
      }
      
      public function isSelectable() : Boolean
      {
         if(this.mNotification != null && this.mNotification.blocksState())
         {
            return this.mNotification.isSelectable();
         }
         return this.doIsSelectable();
      }
      
      public function upgradeLoad(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.mUpgradeType = 0;
         }
         else
         {
            this.mUpgradeType = UpgradesManager.getInstance().getUpgradeType(this.mItemObject.mSid);
         }
         this.mUpgradeDOs = new Array();
         this.upgradeSetDOs();
      }
      
      protected function infoBoxStart() : void
      {
         var _loc1_:Map = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.mItemObject != null)
         {
            _loc1_ = this.mItemObject.company.world.map;
            _loc2_ = this.mItemObject.worldX;
            _loc3_ = _loc1_.getWorldXToScreen(_loc2_);
            _loc4_ = this.mItemObject.worldY + this.mItemObject.itemDefinition.baseHeight - 2 * _loc1_.tileHeight;
            _loc5_ = _loc1_.getWorldYToScreen(_loc4_);
            this.mInfoBoxTimer = 400;
         }
      }
      
      override public function resume() : void
      {
         super.resume();
         if(this.isMouseOver())
         {
            this.doMouseOver(true);
         }
      }
      
      public function get itemObject() : ItemObject
      {
         return this.mItemObject;
      }
      
      protected function infoBoxIsActive() : Boolean
      {
         return this.mInfoBoxTimer <= 0;
      }
      
      public function isMouseOverEnabled() : Boolean
      {
         if(this.mNotification != null)
         {
            return false;
         }
         return this.doIsMouseOverEnabled();
      }
      
      public function getIncomeTimeLeft() : int
      {
         return 0;
      }
      
      protected function doLogicUpdate(param1:int) : void
      {
      }
      
      protected function doUndoSelection() : void
      {
      }
      
      public function upgradeDestroy() : void
      {
         var _loc1_:* = 0;
         var _loc2_:MovieClip = null;
         if(this.mUpgradeDOs != null)
         {
            _loc1_ = int(this.mUpgradeDOs.length - 1);
            while(_loc1_ > -1)
            {
               _loc2_ = this.mUpgradeDOs[_loc1_] as MovieClip;
               if(_loc2_ != null)
               {
                  _loc2_.removeEventListener(Event.ENTER_FRAME,this.upgradeStopAnim);
                  if(this.mItemObject.displayObjectL1.contains(_loc2_))
                  {
                     this.mItemObject.displayObjectL1.removeChild(_loc2_);
                  }
               }
               this.mUpgradeDOs[_loc1_] = null;
               _loc1_--;
            }
            this.mUpgradeDOs = null;
         }
      }
      
      public function doSelection() : void
      {
         if(this.mNotification != null && this.mNotification.blocksState())
         {
            return this.mNotification.doSelection();
         }
         return this.doDoSelection();
      }
      
      public function isClickPriority() : Boolean
      {
         return false;
      }
      
      override public function suspend() : void
      {
         super.suspend();
         if(this.isMouseOver())
         {
            this.undoMouseOver();
         }
      }
      
      public function gainedAccumDCCash(param1:int) : void
      {
         this.mGainedDCCash += param1;
      }
      
      public function upgradeGetEnabled() : Boolean
      {
         return this.mUpgradeEnabled;
      }
      
      protected function doDoIsMouseOverEnabled() : Boolean
      {
         return true;
      }
      
      protected function doDoMouseOver(param1:Boolean = false) : void
      {
      }
      
      protected function doIsSelectable() : Boolean
      {
         return false;
      }
      
      protected function upgradeDoSetDOs() : void
      {
      }
      
      protected function doInfoBoxShow() : void
      {
      }
      
      public function afterMoving() : void
      {
      }
      
      public function needsToBeTrackedForRent() : Boolean
      {
         return false;
      }
      
      protected function infoBoxGetBox() : InfoBox
      {
         return this.doInfoBoxGetBox();
      }
      
      public function gainedAccumDCCoins(param1:int) : void
      {
         this.mGainedDCCoins += param1;
      }
      
      public function setBehaviorTutorial(param1:int = -1) : void
      {
      }
      
      private function checkEndPArticles(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(this.mUpgradeDOs != null)
         {
            _loc2_ = this.mUpgradeDOs[UPGRADE_DO_UNAPPLY] as MovieClip;
            if(_loc2_.currentFrame == _loc2_.totalFrames)
            {
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.checkEndPArticles);
               this.mItemObject.displayObjectL1.removeChild(_loc2_);
               this.upgradeDestroy();
            }
         }
      }
      
      protected function onSuspend() : void
      {
      }
      
      protected function infoBoxEnd() : void
      {
         if(this.mInfoBoxTimer > 0)
         {
            this.mInfoBoxTimer = -1;
         }
         else
         {
            this.infoBoxHide();
         }
      }
      
      public function set itemObject(param1:ItemObject) : void
      {
         this.mItemObject = param1;
      }
      
      protected function doInfoBoxGetBox() : InfoBox
      {
         return null;
      }
      
      public function getPersistence() : XML
      {
         return <State id={this.getID()}/>;
      }
      
      protected function startParticles() : void
      {
         if(this.mUpgradeDOs == null)
         {
            this.upgradeLoad(true);
         }
         this.playParticles();
      }
      
      public function setNotification(param1:Notification, param2:Boolean = true) : void
      {
         if(param1 == null)
         {
            if(this.mNotification != null)
            {
               if(this.mNotification.blocksState())
               {
                  this.mNotification.destroy();
               }
               else
               {
                  this.mNotification.exit();
               }
            }
            if(param2)
            {
               this.enter(false);
            }
         }
         else
         {
            if(param1.blocksState())
            {
               this.exit();
            }
            param1.enter();
         }
         this.mNotification = param1;
      }
      
      private function upgradeStopAnim(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(this.mUpgradeDOs != null)
         {
            _loc2_ = this.mUpgradeDOs[this.mUpgradeCurrentAnimId] as MovieClip;
            if(_loc2_.currentFrame == _loc2_.totalFrames)
            {
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.upgradeStopAnim);
               this.mItemObject.displayObjectL1.removeChild(_loc2_);
               if(this.mUpgradeCurrentAnimId == UPGRADE_DO_UNAPPLY)
               {
                  this.upgradeSetEnabled(false);
               }
            }
         }
      }
      
      protected function isSuspensionCheckForMouseOverEnabled() : Boolean
      {
         return false;
      }
      
      public function toString() : String
      {
         var _loc1_:String = getQualifiedClassName(this);
         return "Class name = " + _loc1_;
      }
      
      public function isBuilt() : Boolean
      {
         return true;
      }
      
      public function isInfoBoxAllowed() : Boolean
      {
         return true;
      }
      
      public function attachCompany() : void
      {
      }
      
      public function isAffectedByType(param1:int) : Boolean
      {
         return true;
      }
      
      public function gainedReset() : void
      {
         this.mGainedDCCash = 0;
         this.mGainedDCCoins = 0;
         this.mGainedExp = 0;
      }
      
      public function resetMode() : void
      {
      }
      
      protected function doInfoBoxHide() : void
      {
      }
      
      public function unattachCompany() : void
      {
      }
      
      public function undoMouseOver() : void
      {
         if(this.mUIIsMouseOver)
         {
            this.doUndoMouseOver();
            this.mUIIsMouseOver = false;
         }
      }
      
      private function upgradePlayAnim(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Number = NaN;
         if(this.mUpgradeDOs != null)
         {
            _loc2_ = this.mUpgradeDOs[param1] as MovieClip;
            if(_loc2_ != null)
            {
               this.mUpgradeCurrentAnimId = param1;
               _loc2_.gotoAndPlay(1);
               _loc2_.addEventListener(Event.ENTER_FRAME,this.upgradeStopAnim);
               _loc3_ = this.mItemObject.company.world.map.scaleX;
               _loc2_.x = this.mItemObject.worldSizeX / _loc3_ >> 1;
               _loc2_.y = this.mItemObject.worldSizeY / _loc3_ >> 1;
               this.mItemObject.displayObjectL1.addChild(_loc2_);
            }
         }
      }
      
      public function canBeSold() : Boolean
      {
         return true;
      }
      
      public function changeAnimationQuality(param1:Boolean) : void
      {
      }
      
      protected function hasCompanyValue() : Boolean
      {
         return true;
      }
      
      protected function doDoClick() : void
      {
      }
      
      public function refreshPositionOfSprites() : void
      {
      }
      
      protected function doDoSelection() : void
      {
      }
      
      protected function upgradeUnapply(param1:Boolean = false) : void
      {
         if(this.mUpgradeDOs == null)
         {
            this.upgradeLoad(param1);
         }
         this.upgradePlayAnim(UPGRADE_DO_UNAPPLY);
      }
      
      public function upgradeSetEnabled(param1:Boolean) : void
      {
         var _loc2_:ParticleUpgrade = null;
         var _loc3_:Sprite = null;
         this.mUpgradeEnabled = param1;
         if(param1)
         {
            if(this.mUpgradeDOs == null)
            {
               this.upgradeLoad();
            }
            _loc2_ = this.mUpgradeDOs[UPGRADE_DO_SIGN];
            _loc3_ = this.mItemObject.displayObjectL1;
            _loc2_.start();
            _loc3_.addChild(_loc2_);
         }
         else if(this.mUpgradeDOs != null)
         {
            this.upgradeDestroy();
         }
      }
      
      public function doClick() : void
      {
         if(this.mNotification != null && this.mNotification.blocksState())
         {
            this.mNotification.doSelection();
         }
         else
         {
            this.doDoClick();
         }
      }
      
      protected function upgradeApply() : void
      {
         this.upgradeSetEnabled(true);
         this.upgradePlayAnim(UPGRADE_DO_APPLY);
      }
      
      public function isDestroyable() : Boolean
      {
         if(this.mNotification != null)
         {
            return false;
         }
         return this.doIsDestroyable();
      }
      
      override public function logicUpdate(param1:int) : void
      {
         if(this.mLogicUpdateEnabled)
         {
            super.logicUpdate(param1);
            if(this.mUpgradeDOs != null)
            {
               this.upgradeLogicUpdate(param1);
            }
            if(this.mNotification != null)
            {
               this.mNotification.logicUpdate(param1);
            }
            if(this.mNotification == null || !this.mNotification.blocksState())
            {
               if(this.mInfoBoxTimer > 0)
               {
                  this.mInfoBoxTimer -= param1;
                  if(this.mInfoBoxTimer <= 0)
                  {
                     this.mInfoBoxTimer = -1;
                     this.infoBoxShow();
                  }
               }
               this.doLogicUpdate(param1);
            }
         }
      }
      
      protected function doUndoMouseOver() : void
      {
      }
      
      public function doMouseOver(param1:Boolean = false) : void
      {
         if(param1 && this.mUIIsMouseOver)
         {
            this.infoBoxRefresh();
         }
         if(!this.mUIIsMouseOver)
         {
            this.doDoMouseOver(param1);
            this.mUIIsMouseOver = true;
         }
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         this.mItemObject.stateId = this.getID();
         super.enter(param1);
         if(UpgradesManager.getInstance().isItemUpgraded(this.mItemObject.sid))
         {
            this.upgradeSetEnabled(true);
         }
      }
      
      private function playParticles() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = NaN;
         if(this.mUpgradeDOs != null)
         {
            _loc1_ = this.mUpgradeDOs[UPGRADE_DO_UNAPPLY] as MovieClip;
            if(_loc1_ != null)
            {
               _loc1_.gotoAndPlay(1);
               _loc1_.addEventListener(Event.ENTER_FRAME,this.checkEndPArticles);
               _loc2_ = this.mItemObject.company.world.map.scaleX;
               _loc1_.x = this.mItemObject.worldSizeX / _loc2_ >> 1;
               _loc1_.y = this.mItemObject.worldSizeY / _loc2_ >> 1;
               this.mItemObject.displayObjectL1.addChild(_loc1_);
            }
         }
      }
      
      protected function infoBoxShow() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:InfoBox = this.infoBoxGetBox();
         if(_loc1_ != null)
         {
            _loc2_ = DollarsGame.getCurrentWorld().map.getWorldXToScreen(this.mItemObject.worldX) + this.mItemObject.worldSizeX;
            _loc3_ = DollarsGame.getCurrentWorld().map.getWorldYToScreen(this.mItemObject.worldY) + this.mItemObject.worldSizeY / 2;
            _loc1_.show(this.mItemObject.itemDefinition,_loc2_,_loc3_,this.mItemObject.worldSizeX);
         }
         this.doInfoBoxShow();
      }
      
      public function setPersistence(param1:XML) : void
      {
      }
      
      protected function infoBoxRefresh() : void
      {
      }
      
      protected function doIsMoveable() : Boolean
      {
         return false;
      }
      
      protected function upgradeSetDOs() : void
      {
         var _loc1_:Number = this.mItemObject.company.world.map.scaleX;
         this.mUpgradeDOs[UPGRADE_DO_SIGN] = new ParticleUpgrade(this.mItemObject.worldSizeX / _loc1_,this.mItemObject.worldSizeY / _loc1_,this.mUpgradeType);
         this.upgradeDoSetDOs();
      }
      
      public function isContractSignReady() : Boolean
      {
         return false;
      }
      
      protected function onResume() : void
      {
      }
      
      protected function needsToCheckSuspension() : Boolean
      {
         return true;
      }
      
      public function signContract(param1:ContractDefinition) : void
      {
      }
      
      public function isIncomeReady() : Boolean
      {
         return false;
      }
      
      public function getID() : int
      {
         return -1;
      }
      
      public function demolish(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:StateItemObject = null;
         if(!param1 && !this.itemObject.company.world.role.demolitionConfirmationRequired())
         {
            param1 = true;
         }
         if(param1 || !this.mItemObject.itemDefinition.showsBarDemolition())
         {
            _loc2_ = RulesFacade.getInstance().settingsGetDestroyItemProfit(this.mItemObject);
            if(_loc2_ > 0)
            {
               this.mItemObject.company.DCCoins += _loc2_;
               ParticlesManager.addParticle(new PointsAnimation(_loc2_,PointsAnimation.TYPE_COINS,this.mItemObject.displayObjectL0.x,this.mItemObject.displayObjectL0.y));
            }
            _loc3_ = this.mItemObject.getStateBeforeDemolition();
            if(_loc3_ != null && _loc3_.hasCompanyValue())
            {
               DollarsGame.getProfile().companyValue = DollarsGame.getProfile().companyValue - this.mItemObject.getCompanyValue();
            }
            if(this.mItemObject.getStateBeforeDemolition().getID() == STATE_ON_RENT_ID)
            {
               this.mItemObject.getStateBeforeDemolition().removeAllSpritesInState();
            }
            this.mItemObject.company.removeItem(this.mItemObject);
         }
         else
         {
            this.mItemObject.changeState(new StateOnDemolition(this.mItemObject));
         }
      }
      
      public function isMoveable() : Boolean
      {
         if(this.mNotification != null)
         {
            return false;
         }
         return this.doIsMoveable();
      }
      
      protected function doIsDestroyable() : Boolean
      {
         return false;
      }
   }
}

