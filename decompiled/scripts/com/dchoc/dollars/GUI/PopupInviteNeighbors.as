package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupInviteNeighbors extends Popup
   {
      
      private var mShareButton:DynamicButton;
      
      private var mTextInfo:TextField;
      
      private var mTitle:TextField;
      
      public function PopupInviteNeighbors()
      {
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_invite_neighbor_1"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_invite_neighbor_2"))();
         }
         this.mTitle = mBox.getChildByName("Title") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_INVITATION_POPUP_NEWUSERS_TITLE);
         TextManager.setTextScaled(this.mTitle);
         this.mShareButton = new DynamicButton(mBox.getChildByName("actionButton") as MovieClip);
         this.mShareButton.setLabel(TextManager.getText(TextIDs.TID_INVITATION_POPUP_BUTTON));
         mBox.addChild(this.mShareButton.getButtonMc());
         mCancelButton = new DynamicButton(mBox.getChildByName("skipButton") as MovieClip);
         mBox.addChild(mCancelButton.getButtonMc());
         this.mTextInfo = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(this.mTextInfo);
         this.mTextInfo.text = TextManager.getText(TextIDs.TID_INVITATION_POPUP_NEWUSERS_TITLE_BODY);
         TextManager.setTextScaled(this.mTextInfo);
         super();
      }
      
      private function onInvite(param1:MouseEvent) : void
      {
         onClose(null);
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_NEIGHBOR_REQUEST,{});
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow(false);
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(Popup.EVENT_CLOSE));
      }
      
      override protected function endButtons() : void
      {
         this.mShareButton.end();
         this.mShareButton.removeEventListener(MouseEvent.CLICK,this.onInvite);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
      }
      
      override protected function startButtons() : void
      {
         this.mShareButton.start();
         this.mShareButton.addEventListener(MouseEvent.CLICK,this.onInvite);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
      }
   }
}

