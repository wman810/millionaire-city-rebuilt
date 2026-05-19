package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupCollectibleCelebrate extends Popup
   {
      
      private var mRewardDescription:TextField;
      
      private var mShareButton:DynamicButton;
      
      private var mRewardDef:CollectibleRewardDefinition;
      
      private var mTitle:TextField;
      
      private var mReward:String;
      
      private var mPopupFeed:PopupPartner;
      
      private var mSkipButton:DynamicButton;
      
      public function PopupCollectibleCelebrate(param1:String)
      {
         this.mReward = param1;
         this.mRewardDef = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mReward) as CollectibleRewardDefinition;
         this.load();
         super();
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         onClose(null);
         this.mPopupFeed = new PopupPartner(PopupPartner.TYPE_SHARE_COMPLETE_COLLECTIBLE_COLLECTION);
         this.mPopupFeed.showPopupParams(null);
         this.mPopupFeed.addEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
      }
      
      private function onSkip(param1:MouseEvent) : void
      {
         onClose(null);
      }
      
      private function load() : void
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"popup_celebrate_building"))();
         this.mTitle = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_REWARD_CLAIMED_TITLE);
         TextManager.setTextScaled(this.mTitle);
         this.mShareButton = new DynamicButton(mBox.getChildByName("share") as MovieClip);
         this.mShareButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_REWARD_CLAIMED_BUTTON));
         this.mSkipButton = new DynamicButton(mBox.getChildByName("skip") as MovieClip);
         this.mRewardDescription = mBox.getChildByName("TextInfo_02") as TextField;
         TextManager.reformatTextField(this.mRewardDescription);
         this.mRewardDescription.text = TextManager.replaceParameters(TextIDs.TID_POPUP_COLLECTIBLES_REWARD_CLAIMED_BODY,new Array(TextManager.getText(TextIDs[this.mRewardDef.textID])));
         TextManager.setTextScaled(this.mRewardDescription);
      }
      
      override protected function endButtons() : void
      {
         this.mShareButton.end();
         this.mShareButton.removeEventListener(MouseEvent.CLICK,this.onShare);
         this.mSkipButton.end();
         this.mSkipButton.removeEventListener(MouseEvent.CLICK,this.onSkip);
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
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function onCloseFeed(param1:Event) : void
      {
         PopupCollectibleManager.getInstance().dispatchEvent(new Event(PopupCollectibleManager.WELLCOME_EVENT));
         this.mPopupFeed.removeEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         this.mPopupFeed = null;
      }
      
      override protected function startButtons() : void
      {
         this.mShareButton.start();
         this.mShareButton.addEventListener(MouseEvent.CLICK,this.onShare);
         this.mSkipButton.start();
         this.mSkipButton.addEventListener(MouseEvent.CLICK,this.onSkip);
      }
   }
}

