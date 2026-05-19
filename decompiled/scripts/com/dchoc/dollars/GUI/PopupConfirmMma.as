package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.GUI.crosspromotion.CrosspromotionDefinition;
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Mouse;
   
   public class PopupConfirmMma extends Popup
   {
      
      private var mTextInfo:TextField;
      
      private var mTitle:TextField;
      
      private var mDef:CrosspromotionDefinition;
      
      public function PopupConfirmMma(param1:CrosspromotionDefinition)
      {
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         this.mDef = param1;
         mBox = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"popup_mission_Mma"))();
         super();
         mOkButton = new DynamicButton(mBox.getChildByName("YesButton") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_YES));
         mCancelButton = new DynamicButton(mBox.getChildByName("NoButton") as MovieClip);
         mCancelButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_NO));
         this.mTextInfo = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(this.mTextInfo);
         this.mTextInfo.text = TextManager.getText(TextIDs[this.mDef.tidBody]);
         TextManager.setTextScaled(this.mTextInfo);
         this.mTitle = mBox.getChildByName("Title") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs[this.mDef.tidTitle]);
         TextManager.setTextScaled(this.mTitle);
         if(this.mDef.image != "logomma")
         {
            _loc2_ = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,this.mDef.image))();
            _loc3_ = mBox.getChildByName("logo") as Sprite;
            _loc4_ = mBox.getChildIndex(_loc3_);
            _loc2_.x = _loc3_.x;
            _loc2_.y = _loc3_.y;
            mBox.addChildAt(_loc2_,_loc4_);
            mBox.removeChild(_loc3_);
         }
      }
      
      override public function onAccept(param1:MouseEvent) : void
      {
         onClose(null);
         dispatchEvent(new Event(EVENT_ACCEPT));
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
      
      public function showPopUp(param1:int = 0, param2:String = "", param3:int = 0) : void
      {
         super.show();
         if(mBox != null)
         {
            mOkButton.start();
            mCancelButton.start();
            mOkButton.addEventListener(MouseEvent.CLICK,this.onAccept);
            mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
            mPreviousCursorID = param1;
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
            startShow();
         }
      }
   }
}

