package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupConfirmMove extends Popup
   {
      
      public function PopupConfirmMove()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_confirm_buy_crane_operator"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         dispatchEvent(new Event(EVENT_CLOSE));
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mShowPopup = false;
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         mOkButton.end();
      }
      
      private function onConfirm(param1:Event) : void
      {
         dispatchEvent(new Event(EVENT_ACCEPT));
         if(param1 != null)
         {
            onClose(null);
         }
      }
      
      override public function show() : void
      {
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.onConfirm);
         var _loc1_:TextField = TextField(mBox.getChildByName("TextInfo"));
         TextManager.reformatTextField(_loc1_);
         _loc1_.text = TextManager.getText(TextIDs.TID_MOVE_TEXT1);
         TextManager.setTextScaled(_loc1_,false);
         var _loc2_:TextField = TextField(mBox.getChildByName("freemove"));
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs.TID_GEN_FREE);
         TextManager.changColors(_loc2_);
         startShow();
      }
      
      private function onCancel(param1:Event) : void
      {
         dispatchEvent(new Event(EVENT_CLOSE));
         if(param1 != null)
         {
            onClose(null);
         }
      }
   }
}

