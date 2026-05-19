package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.PointsAnimation;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinition;
   import com.dchoc.framework.states.StateMachine;
   
   public class StateOnBuilt extends StateItemObject
   {
      
      public static const ID:int = STATE_ON_BUILT_ID;
      
      private var mInfoBox:InfoBox;
      
      public function StateOnBuilt(param1:StateMachine)
      {
         super(param1);
         this.viewStart();
      }
      
      override protected function doIsMoveable() : Boolean
      {
         return true;
      }
      
      override protected function doDoMouseOver(param1:Boolean = false) : void
      {
         var _loc2_:ToolsBar = mItemObject.company.world.role.toolsBar;
         if(_loc2_.currentToolIndex != ToolsBar.BUILD_BUTTON && !mUIIsMouseOver)
         {
            this.mInfoBox = new ItemDefinition.TYPE_INFO_BOX[mItemObject.itemDefinition.type](DollarsGame.smInstance.mPopupClip,mItemObject.itemDefinition);
            infoBoxStart();
         }
      }
      
      override protected function doInfoBoxGetBox() : InfoBox
      {
         return this.mInfoBox;
      }
      
      override protected function doUndoMouseOver() : void
      {
         if(this.mInfoBox != null)
         {
            infoBoxEnd();
            this.mInfoBox.close();
            this.mInfoBox.destroy();
            this.mInfoBox = null;
         }
      }
      
      override public function resume() : void
      {
         var _loc1_:WonderTypeDefinition = null;
         super.resume();
         if(mItemObject.itemDefinition.type == ItemDefinition.TYPE_WONDERS_ID)
         {
            _loc1_ = mItemObject.itemDefinition.getWonderType();
            _loc1_.doEffect(mItemObject);
         }
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      private function viewEnd() : void
      {
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         var _loc2_:WonderTypeDefinition = null;
         var _loc3_:ItemDefinition = null;
         var _loc4_:int = 0;
         var _loc5_:Map = null;
         if(mItemObject.itemDefinition.type == ItemDefinition.TYPE_WONDERS_ID)
         {
            _loc2_ = mItemObject.itemDefinition.getWonderType();
            _loc2_.doEffect(mItemObject);
         }
         else if(param1)
         {
            mItemObject.doConstruction();
            _loc3_ = itemObject.itemDefinition;
            _loc4_ = _loc3_.getExperience();
            if(!mItemObject.getUseAsGift() && _loc4_ > 0)
            {
               itemObject.company.exp += _loc4_;
               _loc5_ = itemObject.company.world.map;
               ParticlesManager.addParticle(new PointsAnimation(_loc4_,PointsAnimation.TYPE_XP,itemObject.displayObjectL0.x,itemObject.displayObjectL0.y));
            }
            mItemObject.company.initItemAfterConstruction(mItemObject,false);
         }
         mItemObject.changeAnim(ItemObject.STATE_NORMAL);
      }
      
      override public function destroy() : void
      {
         this.exit();
         this.mInfoBox = null;
         super.destroy();
      }
      
      override public function suspend() : void
      {
         var _loc1_:WonderTypeDefinition = null;
         super.suspend();
         if(itemObject.itemDefinition.type == ItemDefinition.TYPE_WONDERS_ID)
         {
            _loc1_ = mItemObject.itemDefinition.getWonderType();
            _loc1_.undoEffect(mItemObject);
         }
      }
      
      private function viewStart() : void
      {
      }
      
      override public function exit() : void
      {
         undoMouseOver();
      }
      
      override protected function doIsDestroyable() : Boolean
      {
         return true;
      }
   }
}

