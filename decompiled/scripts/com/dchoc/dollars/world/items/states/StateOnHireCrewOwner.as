package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.hireCrew.PopupHireCrew;
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.states.StateMachine;
   import flash.utils.setTimeout;
   
   public class StateOnHireCrewOwner extends StateOnHireCrew
   {
      
      protected static const TOOLTIP_DELAY:Number = 300;
      
      private var mConstructionInfo:InfoBox;
      
      public function StateOnHireCrewOwner(param1:StateMachine)
      {
         super(param1);
      }
      
      override protected function doDoLogicUpdate(param1:int) : void
      {
         if(DollarsGame.smInstance.mPopupHireCrew != null && !DollarsGame.smInstance.mPopupHireCrew.isOpen())
         {
            DollarsGame.smInstance.mPopupHireCrew = null;
         }
      }
      
      override protected function doDoClick() : void
      {
         if(mMode == MODE_HIRING && mItemObject.isHQConnected())
         {
            trace("Lets hire!!!");
            DollarsGame.smInstance.mPopupHireCrew = new PopupHireCrew(mItemObject);
         }
      }
      
      override protected function doDoMouseOver(param1:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!mItemObject.isSuspended)
         {
            _loc2_ = DollarsGame.getCurrentWorld().map.getWorldXToScreen(mItemObject.worldX) + mItemObject.worldSizeX;
            _loc3_ = DollarsGame.getCurrentWorld().map.getWorldYToScreen(mItemObject.worldY) + mItemObject.worldSizeY / 2;
            this.mConstructionInfo = new ItemDefinition.TYPE_INFO_BOX[ItemDefinition.TYPE_WONDERS_ID](DollarsGame.smInstance.mGameClip,mItemObject.itemDefinition);
            setTimeout(this.mConstructionInfo.show,StateOnHireCrewOwner.TOOLTIP_DELAY,mItemObject.itemDefinition,_loc2_,_loc3_,mItemObject.worldSizeX);
         }
      }
      
      override public function destroy() : void
      {
         this.mConstructionInfo = null;
         super.destroy();
      }
      
      override protected function doUndoMouseOver() : void
      {
         if(this.mConstructionInfo != null)
         {
            this.mConstructionInfo.close();
            this.mConstructionInfo.destroy();
            this.mConstructionInfo = null;
         }
      }
   }
}

