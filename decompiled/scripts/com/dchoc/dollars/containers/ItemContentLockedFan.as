package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class ItemContentLockedFan extends ItemContentLocked
   {
      
      private var buy:Sprite;
      
      public function ItemContentLockedFan(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         super(param1,param2,param3);
      }
      
      override public function start() : void
      {
         mButton.start();
         mButton.addEventListener(MouseEvent.CLICK,this.onUnlock);
         mButton.enable();
         if(!Tutorial.smTutorialEnd)
         {
            mButton.disable();
         }
      }
      
      private function onUnlock(param1:MouseEvent) : void
      {
         unlock();
      }
      
      override public function end() : void
      {
         mButton.end();
         mButton.removeEventListener(MouseEvent.CLICK,this.onUnlock);
      }
      
      override protected function setupBox() : void
      {
         super.setupBox();
         var _loc1_:MovieClip = mBox["unlock_FC"];
         var _loc2_:MovieClip = mBox["fan"];
         mBox.removeChild(_loc1_);
         var _loc3_:MovieClip = mBox["locked"];
         var _loc4_:TextField = _loc3_["Locked"];
         _loc3_.removeChild(_loc4_);
         mButton = new DynamicButton(_loc2_);
         mButton.setLabel(mDef.getUnlockText());
         mButton.disable();
         mUnlockWithFBCredits = false;
      }
   }
}

