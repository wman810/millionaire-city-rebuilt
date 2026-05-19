package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirmMma;
   import com.dchoc.dollars.GUI.crosspromotion.CrosspromotionDefinition;
   import com.dchoc.dollars.GUI.crosspromotion.CrosspromotionDefinitionManager;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ItemContentLockCrossPromotion extends ItemContentLocked
   {
      
      public function ItemContentLockCrossPromotion(param1:ItemContainer, param2:uint, param3:ItemDefinition)
      {
         super(param1,param2,param3);
         var _loc4_:MovieClip = mBox["unlock_FC"];
         mBox.removeChild(_loc4_);
         _loc4_ = mBox["locked"];
         mBox.removeChild(_loc4_);
         var _loc5_:MovieClip = mBox["fan"];
         mButton = new DynamicButton(_loc5_);
         mButton.setLabel(TextManager.getText(TextIDs.TID_PLAY_MMA));
         mButton.disable();
         mUnlockWithFBCredits = false;
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
         var _loc2_:CrosspromotionDefinition = CrosspromotionDefinitionManager.getInstance().getDefinitionBySku("" + mDef.getUnlockConditionCrossAppID()) as CrosspromotionDefinition;
         var _loc3_:PopupConfirmMma = new PopupConfirmMma(_loc2_);
         _loc3_.showPopUp(Dollars.getCurrentCursor().mCurrentCursorID);
         _loc3_.addEventListener(Popup.EVENT_ACCEPT,this.unlockMma);
         _loc3_.addEventListener(Popup.EVENT_CLOSE,this.onCloseMma);
         if(Config.OFFLINE_GAMEPLAY_MODE)
         {
            this.unlock();
         }
      }
      
      override public function unlock() : void
      {
         var _loc1_:CrosspromotionDefinition = CrosspromotionDefinitionManager.getInstance().getDefinitionBySku("" + mDef.getUnlockConditionCrossAppID()) as CrosspromotionDefinition;
         dispatchEvent(new Event(EVENT_UNLOCK_ITEM));
         mDef.shopClickUnlockButton(_loc1_);
      }
      
      private function onCloseMma(param1:Event) : void
      {
         var _loc2_:PopupConfirmMma = param1.target as PopupConfirmMma;
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.unlockMma);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.onCloseMma);
      }
      
      override public function end() : void
      {
         mButton.end();
         mButton.removeEventListener(MouseEvent.CLICK,this.onUnlock);
      }
      
      private function unlockMma(param1:Event) : void
      {
         this.onCloseMma(param1);
         this.unlock();
      }
   }
}

