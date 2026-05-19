package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.GUI.DCFillBar;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.states.StateMachine;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class StateOnDemolition extends StateItemObject
   {
      
      public static const ID:int = STATE_ON_DEMOLITION_ID;
      
      private var mProgressBar:Sprite;
      
      private var mTime:int;
      
      private const TIME_SELL_TOTAL:int = 3000;
      
      private var mProgressFillBar:DCFillBar;
      
      public function StateOnDemolition(param1:StateMachine)
      {
         super(param1);
         this.load();
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         if(this.mTime >= 0)
         {
            this.mTime -= param1;
            this.mProgressFillBar.setValueWithoutBarAnimation(this.TIME_SELL_TOTAL - this.mTime);
            if(this.mTime <= 0)
            {
               this.mTime = 0;
               undoMouseOver();
               this.viewEnd();
               this.destroy();
               super.demolish(true);
            }
         }
      }
      
      override protected function doIsMouseOverEnabled() : Boolean
      {
         return false;
      }
      
      private function viewEnd() : void
      {
         if(this.mProgressBar != null && mItemObject.displayObjectL1.contains(this.mProgressBar))
         {
            mItemObject.displayObjectL1.removeChild(this.mProgressBar);
         }
      }
      
      private function load() : void
      {
         this.mProgressBar = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"Bar_building"))();
         this.mProgressFillBar = new DCFillBar(this.mProgressBar.getChildByName("FillBar") as MovieClip,0,0);
         var _loc1_:Number = this.mProgressBar.width;
         var _loc2_:Number = mItemObject.itemDefinition.baseWidth;
         if(_loc1_ > _loc2_)
         {
            this.mProgressBar.scaleX = _loc2_ / _loc1_;
            this.mProgressBar.scaleY = this.mProgressBar.scaleX;
         }
         var _loc3_:TextField = TextField(this.mProgressBar.getChildByName("TextBox"));
         _loc3_.text = "";
      }
      
      override public function isAffectedByType(param1:int) : Boolean
      {
         return false;
      }
      
      override public function getPersistence() : XML
      {
         var _loc1_:XML = super.getPersistence();
         _loc1_.@time = this.mTime;
         return _loc1_;
      }
      
      override public function getID() : int
      {
         return ID;
      }
      
      private function viewStart() : void
      {
         this.mProgressFillBar.setMaxValue(this.TIME_SELL_TOTAL);
         this.mProgressFillBar.setMinValue(0);
         this.mProgressBar.x = mItemObject.getBarX();
         this.mProgressBar.y = mItemObject.getBarY();
         mItemObject.displayObjectL1.addChild(this.mProgressBar);
         mUIIsSelected = false;
      }
      
      override public function enter(param1:Boolean = true) : void
      {
         if(param1)
         {
            this.mTime = this.TIME_SELL_TOTAL;
         }
         else
         {
            mItemObject.changeAnim(ItemObject.STATE_NORMAL);
         }
         mItemObject.resume();
         this.viewStart();
      }
      
      override public function destroy() : void
      {
         this.exit();
         this.mProgressFillBar = null;
         this.mProgressBar = null;
         super.destroy();
      }
      
      override public function suspend() : void
      {
         mItemObject.resume();
      }
      
      override public function setPersistence(param1:XML) : void
      {
         this.mTime = param1.@time;
      }
      
      override public function exit() : void
      {
         super.exit();
         this.viewEnd();
         if(mUIIsSelected)
         {
            mItemObject.company.world.role.toolsBar.unattachItem(mItemObject);
         }
      }
   }
}

