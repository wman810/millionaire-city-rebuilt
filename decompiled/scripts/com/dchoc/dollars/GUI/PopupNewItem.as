package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PopupNewItem extends Popup
   {
      
      public function PopupNewItem()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"popup_new_item"))();
         mOkButton = new DynamicButton(mBox.getChildByName("go_to_the_shop") as MovieClip);
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.goShop);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function goShop(param1:MouseEvent) : void
      {
         onClose(null);
         DollarsGame.smInstance.showBuyBox();
      }
      
      override public function showPopup() : void
      {
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.goShop);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         startShow();
      }
   }
}

