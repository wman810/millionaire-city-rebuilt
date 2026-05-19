package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.collectibles.CollectiblePendingManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupCollectibleConfirmSell extends Popup
   {
      
      private var mItemCollectible:CollectibleObject;
      
      private var mPrize:TextField;
      
      private var mTitle:TextField;
      
      private var mCollectibleSku:String;
      
      private var mSenderId:String;
      
      private var mItemObject:ItemObject;
      
      public function PopupCollectibleConfirmSell(param1:String, param2:String, param3:CollectibleObject, param4:ItemObject)
      {
         this.mItemCollectible = param3;
         this.mItemObject = param4;
         this.mCollectibleSku = param1;
         this.mSenderId = param2;
         this.load();
         super();
      }
      
      private function load() : void
      {
         var _loc1_:MovieClip = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_confirm_buy"))();
         _loc1_ = mBox.getChildByName("gold") as MovieClip;
         _loc1_.stop();
         _loc1_.gotoAndStop(1);
         this.mPrize = mBox.getChildByName("mPrize") as TextField;
         this.mPrize.text = String("$" + this.mItemCollectible.getCollectibleDefinition().priceCoins);
         TextManager.setTextScaled(this.mPrize);
         this.mPrize.x += 35;
         _loc1_.x -= 125;
         this.mTitle = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_SELL_ITEM_TITLE);
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_OLD_GIFT_BUTTON01));
         mCancelButton = new DynamicButton(mBox.getChildByName("CancelButton") as MovieClip);
         mCancelButton.setLabel(TextManager.getText(TextIDs.TID_GEN_BUTTON_CANCEL));
      }
      
      override protected function close() : void
      {
         super.close();
         PopupCollectibleManager.getInstance().dispatchEvent(new Event(PopupCollectibleManager.WELLCOME_EVENT));
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      override public function onAccept(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         onClose(null);
         var _loc2_:Number = CollectibleManager.getInstance().sellItem(this.mCollectibleSku);
         var _loc3_:Object = UserDataFacade.securityCreateObj(0,_loc2_,0);
         if(this.mItemObject != null)
         {
            _loc4_ = this.mItemObject.mSid;
            if(this.mItemObject.itemDefinition.isACommerce())
            {
               this.mItemObject.getCurrentState().eventsProcess({"cmd":StateOnRent.CMD_COMMERCE_COLLECTIBLE_GOTTEN});
            }
            else
            {
               this.mItemObject.getCurrentState().eventsProcess({"cmd":StateOnRent.CMD_COLLECTIBLE_GOTTEN});
            }
            CollectibleManager.getInstance().removeCollectibleFromPending(_loc4_);
         }
         else
         {
            _loc4_ = "f" + this.mSenderId;
         }
         if(this.mSenderId != "-1")
         {
            if(Config.COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED)
            {
               CollectiblePendingManager.getInstance().removePendingCollectible(this.mCollectibleSku,this.mSenderId);
            }
         }
         UserDataFacade.getInstance().updateCollectible(_loc4_,this.mCollectibleSku,"SELL",null,{},_loc3_);
         var _loc5_:PopupCollectibleFound = PopupCollectibleManager.getInstance().smPopupCollectibleFound;
         _loc5_.onClose(null);
      }
      
      override protected function endButtons() : void
      {
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.onAccept);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.onCancelSell);
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
      }
      
      private function onCancelSell(param1:MouseEvent) : void
      {
         onClose(null);
      }
      
      override protected function startButtons() : void
      {
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.onAccept);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,this.onCancelSell);
      }
   }
}

