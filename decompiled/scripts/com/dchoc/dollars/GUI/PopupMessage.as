package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupMessage extends Popup
   {
      
      public static const NO_ICON:int = 0;
      
      public static const ICON_TERRAIN:int = 1;
      
      public static const ICON_LOCK:int = 2;
      
      private var mCurrentCursor:int;
      
      private var mTextBoxY:Number;
      
      public function PopupMessage()
      {
         this.setBox();
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         mBox.addChild(mOkButton.getButtonMc());
         mTextBox = mBox.getChildByName("TextInfo_01") as TextField;
         this.mTextBoxY = mTextBox.y;
         TextManager.reformatTextField(mTextBox);
         super();
      }
      
      public function showPopupParams(param1:String, param2:int = 0) : void
      {
         var _loc3_:DollarsGame = null;
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         if(!mBox.contains(mOkButton.getButtonMc()))
         {
            mBox.addChild(mOkButton.getButtonMc());
         }
         _loc3_ = DollarsGame.smInstance;
         _loc3_.mGameClip.mouseChildren = false;
         _loc3_.mGameClip.mouseEnabled = false;
         mTextBox.text = param1;
         mTextBox.y = this.mTextBoxY;
         mTextBox.y += (mTextBox.height - mTextBox.textHeight) / 2;
         TextManager.reformatTextField(mTextBox);
         startShow(false);
         var _loc4_:Sprite = Sprite(mBox.getChildByName("plots_info"));
         var _loc5_:Sprite = Sprite(mBox.getChildByName("locked"));
         _loc4_.visible = false;
         _loc5_.visible = false;
         if(param2 == ICON_TERRAIN)
         {
            _loc4_.visible = true;
         }
         else if(param2 == ICON_LOCK)
         {
            _loc5_.visible = true;
         }
         this.mCurrentCursor = Dollars.getCurrentCursor().mCurrentCursorID;
      }
      
      protected function setBox() : void
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_confirm_buy_manager"))();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         if(mBox.contains(mOkButton.getButtonMc()))
         {
            mBox.removeChild(mOkButton.getButtonMc());
         }
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mGameClip.mouseChildren = true;
         _loc1_.mGameClip.mouseEnabled = true;
         _loc1_.mShowPopup = false;
         dispatchEvent(new Event(EVENT_CLOSE));
         Dollars.getCurrentCursor().changeCursor(this.mCurrentCursor);
      }
   }
}

