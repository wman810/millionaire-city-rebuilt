package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupUnlockItem;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.UnlockedListManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ItemContentLockedByCash extends ItemContentLocked implements FBCreditsPurchaseInterface
   {
      
      public static const EVENT_UNLOCK_BY_CASH:String = "EventUnlockByCash";
      
      public function ItemContentLockedByCash(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         super(param1,param2,param3);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.unlockItem();
         }
      }
      
      override public function start() : void
      {
         mButton.start();
         mButton.addEventListener(MouseEvent.CLICK,this.onUnlock);
         mButton.enable();
         if(!Tutorial.smTutorialEnd)
         {
            mButton.disable();
         }
      }
      
      private function onUnlock(param1:MouseEvent) : void
      {
         var _loc2_:PopupUnlockItem = new PopupUnlockItem(mDef);
         _loc2_.addEventListener(Popup.EVENT_ACCEPT,this.onUnlockItem);
         _loc2_.addEventListener(Popup.EVENT_CLOSE,this.onClosePopupUnlock);
         _loc2_.showPopup();
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":mDef.getUnlockPrice(),
            "orderInfo":{
               "type":FBCreditsPurchase.TYPE_EARLY_UNLOCK,
               "sku":mDef.sku,
               "name":encodeURIComponent(TextManager.getText(TextIDs[mDef.textID]))
            }
         };
      }
      
      private function onUnlockItem(param1:Event) : void
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc3_:int = mDef.getUnlockPrice(false);
         this.onClosePopupUnlock(param1);
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc2_.DCCash < _loc3_)
         {
            FBCreditsPurchase.getInstance().startPurchaseProcess(this);
         }
         else if(_loc2_.DCCash >= _loc3_)
         {
            this.unlockItem();
         }
         else
         {
            DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,_loc3_);
         }
      }
      
      private function unlockItem() : void
      {
         UnlockedListManager.getInstance().unlockItem(mDef);
      }
      
      override public function end() : void
      {
         mButton.end();
         mButton.removeEventListener(MouseEvent.CLICK,this.onUnlock);
      }
      
      override protected function setupBox() : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Sprite = null;
         var _loc5_:Bitmap = null;
         super.setupBox();
         var _loc1_:MovieClip = mBox["unlock_FC"];
         var _loc2_:MovieClip = mBox["fan"];
         if(mUnlockWithFBCredits)
         {
            mBox.removeChild(_loc2_);
            mButton = new DynamicButton(_loc1_);
            _loc3_ = mButton.getButtonMc()["ButtonText"];
            _loc4_ = _loc3_["icon"];
            _loc5_ = new Bitmap(DCResourceManager.getInstance().get("fbc"));
            _loc5_.x = _loc4_.x;
            _loc5_.y = _loc4_.y;
            _loc3_.addChild(_loc5_);
            _loc3_.removeChild(_loc4_);
            _loc3_ = mButton.getButtonMc()["ButtonText"];
            _loc3_ = mButton.getButtonMc()["ButtonText"]["offer"];
            if(_loc3_ != null)
            {
               _loc3_.visible = false;
            }
            _loc3_ = mButton.getButtonMc()["ButtonText"]["old_prize"];
            if(_loc3_ != null)
            {
               _loc3_.visible = false;
            }
            _loc3_ = mBox["bundle"];
            if(_loc3_ != null)
            {
               _loc3_.visible = false;
            }
         }
         else
         {
            mBox.removeChild(_loc1_);
            mButton = new DynamicButton(_loc2_);
         }
         mButton.setLabel(TextManager.getText(TextIDs.TID_PLAY_MMA));
      }
      
      private function onClosePopupUnlock(param1:Event) : void
      {
         var _loc2_:PopupUnlockItem = param1.target as PopupUnlockItem;
         _loc2_.removeEventListener(Popup.EVENT_ACCEPT,this.onUnlockItem);
         _loc2_.removeEventListener(Popup.EVENT_CLOSE,this.onClosePopupUnlock);
      }
   }
}

