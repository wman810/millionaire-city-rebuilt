package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupVisit extends Popup
   {
      
      public function PopupVisit()
      {
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_wellcome_city_01"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_wellcome_city_02"))();
         }
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         super();
         this.showPopup();
      }
      
      override protected function close() : void
      {
         super.close();
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      override public function destroy() : void
      {
         mOkButton.destroy();
         mOkButton = null;
         mBox = null;
      }
      
      override public function showPopup() : void
      {
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,onClose);
         TextManager.reformatTextField(TextField(mBox.getChildByName("FriendUpgrade")));
         TextField(mBox.getChildByName("FriendUpgrade")).text = TextManager.getText(TextIDs.TID_VISIT_FRIEND_POPUP_TITLE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_01")));
         TextField(mBox.getChildByName("TextInfo_01")).text = TextManager.getText(TextIDs.TID_VISIT_FRIEND_POPUP_TEXT1);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_02")));
         TextField(mBox.getChildByName("TextInfo_02")).text = TextManager.getText(TextIDs.TID_VISIT_FRIEND_POPUP_TEXT2);
         startShow();
      }
   }
}

