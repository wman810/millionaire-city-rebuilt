package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.states.StateMachine;
   import flash.events.MouseEvent;
   
   public class StateOnConstruction extends StateItemObject
   {
      
      public static const ID:int = STATE_ON_CONSTRUCTION_ID;
      
      protected static const MODE_NONE:int = 0;
      
      protected static const MODE_INIT:int = 1;
      
      protected static const MODE_RESUME:int = 2;
      
      protected static const MODE_PAUSED:int = 3;
      
      protected static const MODE_INSTANT_BUILD:int = 4;
      
      protected static const TOOLTIP_DELAY:Number = 300;
      
      protected var mConstructionTime:Number;
      
      protected var mTime:Number;
      
      protected var mMaxTime:Number;
      
      protected var mMode:int = 0;
      
      private var mEffectiveMode:Boolean;
      
      public function StateOnConstruction(param1:StateMachine, param2:int = -1)
      {
         super(param1);
         this.mConstructionTime = param2;
         this.viewStart();
      }
      
      override public function suspend() : void
      {
         super.suspend();
         this.setMode(MODE_PAUSED);
      }
      
      private function viewStart() : void
      {
      }
      
      protected function doExit() : void
      {
      }
      
      protected function doEnter() : void
      {
      }
      
      private function viewUpdate() : void
      {
         var _loc1_:int = 0;
         if(this.mTime <= 0)
         {
            if(mItemObject.getCurrentAnimIndex() != ItemObject.STATE_NORMAL)
            {
               _loc1_ = mItemObject.getCurrentAnimIndex();
               mItemObject.changeAnim(ItemObject.STATE_NORMAL);
               if(_loc1_ == ItemObject.STATE_BUILDING)
               {
                  mItemObject.destroyAnim(ItemObject.STATE_BUILDING);
               }
            }
         }
      }
      
      override public function isAffectedByType(param1:int) : Boolean
      {
         return false;
      }
      
      override protected function doIsSelectable() : Boolean
      {
         return mItemObject.company.isMine();
      }
      
      public function get time() : int
      {
         return this.mTime;
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         super.enter(param1);
         mItemObject.changeAnim(ItemObject.STATE_BUILDING);
         if(this.mConstructionTime > -1)
         {
            this.mMaxTime = this.mConstructionTime;
         }
         else
         {
            this.mMaxTime = mItemObject.getConstructionTime();
         }
         if(param1)
         {
            this.mTime = this.mMaxTime;
            if(this.mConstructionTime == -1)
            {
               mItemObject.doConstruction();
            }
            this.setMode(MODE_INIT);
         }
         this.doEnter();
      }
      
      override public function setBehaviorTutorial(param1:int = -1) : void
      {
         if(param1 == Tutorial.TUTORIAL_STEP_INSTANT_BUILD_ID)
         {
            this.mTime -= 100;
         }
      }
      
      override public function setPersistence(param1:XML) : void
      {
         this.mMode = param1.@mode;
         this.mTime = param1.@time;
         if(this.mTime == 0)
         {
            mItemObject.company.progressRegisterEvent(Company.PROGRESS_EVENT_CONSTRUCTION_FINISHED);
            if(FriendsManager.getBuildingHelp(mItemObject.mSid).length > 0)
            {
               mItemObject.company.progressRegisterEvent(Company.PROGRESS_EVENT_CONSTRUCTION_FINISHED_WITH_HELP);
               FriendsManager.addExtIdsToThankForHelpingBuilding(mItemObject.mSid);
            }
         }
      }
      
      override public function exit() : void
      {
         super.exit();
         this.doExit();
         this.viewEnd();
      }
      
      protected function setMode(param1:int, param2:Boolean = true, param3:Boolean = true) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:XML = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         if(this.mMode != param1)
         {
            if(!(this.mMode == MODE_INIT && param1 == MODE_PAUSED || this.mMode == MODE_INSTANT_BUILD))
            {
               _loc4_ = this.mMode;
               this.mMode = param1;
               _loc5_ = UserDataFacade.securityCreateObj(mGainedExp,mGainedDCCoins,mGainedDCCash);
               _loc6_ = mItemObject.getPersistence(true);
               _loc7_ = int(_loc6_.@isSuspended);
               _loc8_ = {
                  "mode":this.mMode,
                  "time":this.mTime,
                  "isSuspended":_loc7_
               };
               if(mItemObject.getUseAsGift())
               {
                  _loc8_.freeGift = true;
               }
               UserDataFacade.getInstance().updateItem(mItemObject.mSid,"new_mode",_loc8_,_loc6_,_loc5_);
               Debug.trace("item (" + mItemObject.mSid + ") State_onConstruction: setMode: from " + _loc4_ + " to " + this.mMode);
            }
         }
         gainedReset();
      }
      
      override protected function doIsMoveable() : Boolean
      {
         return true;
      }
      
      override public function getPersistence() : XML
      {
         var _loc1_:XML = super.getPersistence();
         _loc1_.@mode = this.mMode;
         _loc1_.@time = this.mTime;
         return _loc1_;
      }
      
      override public function resume() : void
      {
         var _loc1_:ItemDefinition = null;
         if(this.mMode == MODE_INIT)
         {
            if(!itemObject.getUseAsGift())
            {
               _loc1_ = itemObject.itemDefinition;
               itemObject.company.exp += _loc1_.getExperience();
               gainedAccumExp(_loc1_.getExperience());
               ParticlesManager.addParticle(new PointsAnimation(_loc1_.getExperience(),PointsAnimation.TYPE_XP,mItemObject.displayObjectL0.x,mItemObject.displayObjectL0.y));
            }
         }
         this.setMode(MODE_RESUME);
      }
      
      override public function canBeSold() : Boolean
      {
         return false;
      }
      
      protected function doDoLogicUpdate(param1:int) : void
      {
      }
      
      override protected function hasCompanyValue() : Boolean
      {
         return false;
      }
      
      private function viewEnd() : void
      {
      }
      
      override protected function isSuspensionCheckForMouseOverEnabled() : Boolean
      {
         return false;
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      public function onCancel(param1:MouseEvent = null) : void
      {
         super.demolish();
      }
      
      override public function isBuilt() : Boolean
      {
         return false;
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         if(isTimerCountDownEnabled() && Tutorial.smTutorialEnd)
         {
            if(this.mTime > 0 && (this.mTime = this.mTime - param1) <= 0)
            {
               this.mTime = 0;
            }
         }
         this.doDoLogicUpdate(param1);
         this.viewUpdate();
      }
      
      override protected function doIsDestroyable() : Boolean
      {
         return true;
      }
   }
}

