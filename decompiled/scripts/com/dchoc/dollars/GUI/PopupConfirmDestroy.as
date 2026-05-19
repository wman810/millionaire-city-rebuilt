package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Mouse;
   
   public class PopupConfirmDestroy extends Popup
   {
      
      public function PopupConfirmDestroy()
      {
         mBox = new AssetManager.PopupDestroy();
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_YES));
         mCancelButton = new DynamicButton(mBox.getChildByName("CancelButton") as MovieClip);
         mCancelButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_NO));
         mTextBox = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(mTextBox);
         super();
      }
      
      override protected function close() : void
      {
         var _loc1_:DollarsGame = null;
         super.close();
         if(mBox != null)
         {
            mOkButton.end();
            mCancelButton.end();
            mOkButton.removeEventListener(MouseEvent.CLICK,this.onAccept);
            mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
            Mouse.hide();
            Dollars.getCurrentCursor().changeCursor(mPreviousCursorID);
            _loc1_ = DollarsGame.smInstance;
            _loc1_.mPopupClip.removeChild(mBox);
            _loc1_.mShowPopup = false;
            dispatchEvent(new Event(EVENT_CLOSE));
         }
      }
      
      override public function onAccept(param1:MouseEvent) : void
      {
         onClose(null);
         dispatchEvent(new Event(EVENT_ACCEPT));
      }
      
      public function showPopUp(param1:int = 0, param2:String = "", param3:int = 0) : void
      {
         var _loc4_:String = null;
         super.show();
         if(param1 == 0)
         {
            param1 = Cursor.CURSOR_DEMOLITION;
         }
         if(mBox != null)
         {
            mOkButton.start();
            mCancelButton.start();
            mOkButton.addEventListener(MouseEvent.CLICK,this.onAccept);
            mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
            mPreviousCursorID = param1;
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
            mTextBox.text = param2;
            startShow();
            if(param3 > 0)
            {
               _loc4_ = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param3,TextManager.TRUNCATE_THOUSAND,7);
               mTextBox.text = TextManager.replaceParameters(param2,new Array(_loc4_));
               TextManager.changColors(mTextBox);
            }
         }
      }
   }
}

