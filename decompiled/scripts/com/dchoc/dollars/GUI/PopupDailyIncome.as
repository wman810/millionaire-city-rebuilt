package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupDailyIncome extends Popup
   {
      
      public function PopupDailyIncome()
      {
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_stocks_background_01"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_stocks_background_02"))();
         }
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_POPUP_LEVEL_TITLE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Text1")));
         TextField(mBox.getChildByName("Text1")).text = TextManager.getText(TextIDs.TID_POPUP_DAILY_BONUS_TEXT_1);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo")));
         TextField(mBox.getChildByName("TextInfo")).text = TextManager.getText(TextIDs.TID_POPUP_DAILY_BONUS_TEXT_2);
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      public function showPopupParams(param1:int) : void
      {
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         startShow(false);
         TextField(mBox.getChildByName("Money")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + param1;
      }
   }
}

