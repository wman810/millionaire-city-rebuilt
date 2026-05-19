package com.dchoc.dollars.GUI.payment
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupPaymentFail extends Popup
   {
      
      private var mTitleBox:TextField;
      
      public function PopupPaymentFail()
      {
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"you_dont_have_01"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"you_dont_have_02"))();
         }
         mOkButton = new DynamicButton(mBox["exchange_cash"]);
         mTextBox = mBox["TextInfo"];
         this.mTitleBox = mBox["Caption"];
         var _loc1_:DynamicButton = new DynamicButton(mBox["CancelButton"]);
         mBox.removeChild(_loc1_.getButtonMc());
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mGameClip.mouseChildren = true;
         _loc1_.mGameClip.mouseEnabled = true;
         _loc1_.mShowPopup = false;
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      public function showPopupParams(param1:String) : void
      {
         var _loc2_:DollarsGame = null;
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_PARTNER_POST_BUTTON2));
         _loc2_ = DollarsGame.smInstance;
         _loc2_.mGameClip.mouseChildren = false;
         _loc2_.mGameClip.mouseEnabled = false;
         TextManager.reformatTextField(this.mTitleBox);
         this.mTitleBox.text = TextManager.getText(TextIDs.TID_PAYMENT_FAIL_FBC_TITLE);
         TextManager.setTextScaled(this.mTitleBox);
         TextManager.reformatTextField(mTextBox);
         mTextBox.text = param1;
         TextManager.setTextScaled(mTextBox);
         startShow(false);
      }
   }
}

