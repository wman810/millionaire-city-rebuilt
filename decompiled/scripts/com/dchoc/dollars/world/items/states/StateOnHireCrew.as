package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.states.StateMachine;
   
   public class StateOnHireCrew extends StateItemObject
   {
      
      public static const ID:int = STATE_ON_HIRE_CREW;
      
      protected static const MODE_NONE:int = 0;
      
      protected static const MODE_INIT:int = 1;
      
      protected static const MODE_HIRING:int = 2;
      
      protected var mMode:int = 0;
      
      public function StateOnHireCrew(param1:StateMachine)
      {
         super(param1);
      }
      
      private function setMode(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         if(this.mMode != param1)
         {
            _loc2_ = this.mMode;
            this.mMode = param1;
            _loc3_ = UserDataFacade.securityCreateObj(mGainedExp,mGainedDCCoins,mGainedDCCash);
            _loc4_ = mItemObject.getPersistence(true);
            _loc5_ = int(_loc4_.@isSuspended);
            _loc6_ = {
               "mode":this.mMode,
               "isSuspended":_loc5_
            };
            if(mItemObject.getUseAsGift())
            {
               _loc6_.freeGift = true;
            }
            UserDataFacade.getInstance().updateItem(mItemObject.mSid,"new_mode",_loc6_,_loc4_,_loc3_);
            Debug.trace("item (" + mItemObject.mSid + ") State_onHireCrew: setMode: from " + _loc2_ + " to " + this.mMode);
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
         return _loc1_;
      }
      
      override protected function doIsSelectable() : Boolean
      {
         return mItemObject.company.isMine();
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
               if(_loc1_.getExperience() > 0)
               {
                  ParticlesManager.addParticle(new PointsAnimation(_loc1_.getExperience(),PointsAnimation.TYPE_XP,mItemObject.displayObjectL0.x,mItemObject.displayObjectL0.y));
               }
            }
            this.setMode(MODE_HIRING);
         }
      }
      
      override protected function hasCompanyValue() : Boolean
      {
         return false;
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      override public function isBuilt() : Boolean
      {
         return false;
      }
      
      override public function canBeSold() : Boolean
      {
         return false;
      }
      
      override protected function isSuspensionCheckForMouseOverEnabled() : Boolean
      {
         return false;
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         super.enter(param1);
         mItemObject.changeAnim(ItemObject.STATE_BUILDING);
         if(param1)
         {
            mItemObject.doConstruction();
            this.setMode(MODE_INIT);
         }
      }
      
      override public function destroy() : void
      {
         exit();
         super.destroy();
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         this.doDoLogicUpdate(param1);
      }
      
      override public function setPersistence(param1:XML) : void
      {
         this.mMode = param1.@mode;
      }
      
      protected function doDoLogicUpdate(param1:int) : void
      {
      }
      
      override protected function doIsDestroyable() : Boolean
      {
         return true;
      }
   }
}

