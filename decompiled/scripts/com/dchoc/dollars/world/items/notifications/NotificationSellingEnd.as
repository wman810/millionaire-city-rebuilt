package com.dchoc.dollars.world.items.notifications
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.utils.poll.PollManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.states.StateMachine;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class NotificationSellingEnd extends Notification
   {
      
      private var mCompanyBuyer:Company;
      
      private var mPrice:int;
      
      public function NotificationSellingEnd(param1:StateMachine, param2:int, param3:Company, param4:Boolean = false)
      {
         super(param1,param4);
         this.mPrice = param2;
         this.mCompanyBuyer = param3;
         if(param3.isMine())
         {
            this.doTransaction();
         }
      }
      
      override protected function getButtonClass() : DisplayObject
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Contract_Broken_anim_ok"))();
      }
      
      private function doTransaction() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         mItemObject.company.DCCoins += this.mPrice;
         if(this.mCompanyBuyer.DCCoins >= this.mPrice)
         {
            this.mCompanyBuyer.DCCoins -= this.mPrice;
            mItemObject.getCurrentState().gainedAccumDCCoins(-this.mPrice);
            _loc1_ = mItemObject.itemDefinition.baseCols * mItemObject.itemDefinition.baseRows;
            _loc2_ = mItemObject.displayObjectL0.x;
            _loc3_ = mItemObject.displayObjectL0.y;
            if(this.mCompanyBuyer.isMine())
            {
               ParticlesManager.addParticle(new PointsAnimation(-this.mPrice,PointsAnimation.TYPE_COINS,_loc2_,_loc3_));
            }
            else
            {
               ParticlesManager.addParticle(new PointsAnimation(this.mPrice,PointsAnimation.TYPE_COINS,_loc2_,_loc3_));
            }
         }
      }
      
      override protected function getButtonEndClass() : MovieClip
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Event_Contract_Broken_anim_ok"))();
      }
      
      override protected function onAccept(param1:MouseEvent = null) : void
      {
         mItemObject.getCurrentState().setNotification(null,false);
         if(this.mCompanyBuyer.isMine())
         {
            PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_BUY_ITEM,mItemObject.itemDefinition.nameType);
            PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_BUY_ITEM,mItemObject.itemDefinition.sku);
         }
         else
         {
            this.doTransaction();
            PollManager.getInstance().registerEvent(MissionsEventIDs.MISSION_EVENT_SELL_ITEM,mItemObject.itemDefinition.nameType);
         }
         DollarsGame.getCurrentWorld().changeCompanyItem(mItemObject,this.mCompanyBuyer.whose);
         DollarsGame.getCurrentWorld().map.sellTerrain(mItemObject);
         this.mCompanyBuyer.initItemAfterBuying(mItemObject);
         if(!Tutorial.smTutorialEnd)
         {
            Tutorial.activeOkButton();
         }
      }
      
      override public function blocksState() : Boolean
      {
         return false;
      }
   }
}

