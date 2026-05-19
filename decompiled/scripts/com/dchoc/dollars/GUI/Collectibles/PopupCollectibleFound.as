package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupCollectibleFound extends Popup
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_KEEP:int = 1;
      
      private var mItemObject:ItemObject;
      
      private var mCollectibleSku:String;
      
      private var mKeepButton:DynamicButton;
      
      private var mSendButton:DynamicButton;
      
      private var mState:int;
      
      private var mSellButton:DynamicButton;
      
      private var mTitle:TextField;
      
      private var mWelcome:Boolean;
      
      private var mText:TextField;
      
      private var mItemCollectible:CollectibleObject = CollectibleManager.getInstance().getCollectibleBySku(this.mCollectibleSku);
      
      private var mSenderId:String = "-1";
      
      public function PopupCollectibleFound(param1:int, param2:String, param3:Boolean = false, param4:ItemObject = null)
      {
         this.mWelcome = param3;
         this.mState = param1;
         this.mCollectibleSku = param2;
         this.mItemObject = param4;
         this.load();
         super();
      }
      
      private function onKeep(param1:MouseEvent) : void
      {
         CollectibleManager.getInstance().keepCollectibleTask(this.mItemObject);
         onClose(null);
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
         if(Config.COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED)
         {
            if(PopupCollectibleManager.getInstance().smPopupCollectiblePendingList)
            {
               PopupCollectibleManager.getInstance().smPopupCollectiblePendingList.dispatchEvent(new Event(PopupPendingCollectiblesList.EVENT_PENDING_COLLECTIBLE_REMOVED));
               PopupCollectibleManager.getInstance().smPopupCollectiblePendingList.dispatchEvent(new Event(PopupPendingCollectiblesList.EVENT_CHECK_EMPTY_LIST));
            }
         }
      }
      
      private function onSell(param1:MouseEvent) : void
      {
         PopupCollectibleManager.getInstance().smPopupCollectibleSell = new PopupCollectibleConfirmSell(this.mCollectibleSku,this.mSenderId,this.mItemCollectible,this.mItemObject);
         PopupCollectibleManager.getInstance().smPopupCollectibleSell.showPopup();
      }
      
      private function onSendGift(param1:MouseEvent) : void
      {
         onClose(null);
         PopupCollectibleManager.getInstance().smPopupCollectibleSend = new PopupSendCollectible(this.mCollectibleSku,this.mSenderId,this.mItemObject);
         PopupCollectibleManager.getInstance().smPopupCollectibleSend.showPopup();
      }
      
      private function load() : void
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"popup_new_gift_found"))();
         this.mTitle = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mText = mBox.getChildByName("TextInfo_02") as TextField;
         TextManager.reformatTextField(this.mText);
         this.mSellButton = new DynamicButton(mBox.getChildByName("sell") as MovieClip);
         this.mSendButton = new DynamicButton(mBox.getChildByName("share") as MovieClip);
         switch(this.mState)
         {
            case STATE_IDLE:
               if(this.mWelcome)
               {
                  this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_TITLE);
                  this.mText.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_BODY);
                  this.mSellButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_BUTTON01));
                  this.mSendButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_BUTTON02));
                  break;
               }
               this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_TITLE);
               this.mText.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_BODY);
               this.mSellButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_BUTTON01));
               this.mSendButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_BUTTON02));
               break;
            case STATE_KEEP:
               if(this.mWelcome)
               {
                  this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_TITLE);
                  this.mText.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_BODY);
                  this.mSellButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_BUTTON01));
                  this.mSendButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_BUTTON02));
                  break;
               }
               this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_TITLE);
               this.mText.text = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_FIND_NOKEEP,new Array(RulesFacade.getInstance().settingsGetCollectibleMaxUnitsPerItem().toString()));
               this.mSellButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_BUTTON01));
               this.mSendButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_BUTTON02));
         }
         this.mKeepButton = new DynamicButton(mBox.getChildByName("keep") as MovieClip);
         this.mKeepButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_NEW_GIFT_BUTTON01));
         var _loc1_:Sprite = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"coll_" + this.mCollectibleSku))();
         mBox.addChild(_loc1_);
         _loc1_.y = -50;
         TextManager.setTextScaled(this.mTitle);
         TextManager.setTextScaled(this.mText);
         this.startButtons();
         this.endButtons();
      }
      
      override protected function endButtons() : void
      {
         this.mSendButton.end();
         this.mSendButton.removeEventListener(MouseEvent.CLICK,this.onSendGift);
         this.mKeepButton.end();
         this.mSellButton.end();
         switch(this.mState)
         {
            case STATE_IDLE:
               this.mKeepButton.removeEventListener(MouseEvent.CLICK,this.onKeep);
               break;
            case STATE_KEEP:
               this.mSellButton.removeEventListener(MouseEvent.CLICK,this.onSell);
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow(false);
      }
      
      public function setSenderId(param1:String) : void
      {
         this.mSenderId = param1;
      }
      
      override protected function startButtons() : void
      {
         this.mSendButton.start();
         this.mSendButton.addEventListener(MouseEvent.CLICK,this.onSendGift);
         this.mKeepButton.start();
         this.mSellButton.start();
         switch(this.mState)
         {
            case STATE_IDLE:
               this.mSellButton.visible = false;
               this.mKeepButton.addEventListener(MouseEvent.CLICK,this.onKeep);
               break;
            case STATE_KEEP:
               this.mKeepButton.visible = false;
               this.mSellButton.addEventListener(MouseEvent.CLICK,this.onSell);
         }
      }
   }
}

