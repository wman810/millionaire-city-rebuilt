package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.services.ServiceDefinition;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupPayMove extends Popup implements FBCreditsPurchaseInterface
   {
      
      public static const EVENT_RENT:String = "EventRent";
      
      private var mPopupConfirm:PopupConfirm;
      
      private var mIsCash:Boolean;
      
      private var mRentButton:DynamicButton;
      
      private var mPrice:int;
      
      private var mUseFAcebookCredits:Boolean;
      
      private var mRentPrice:int;
      
      private var mGold:MovieClip;
      
      private var mPopupFeed:PopupPartner;
      
      public function PopupPayMove()
      {
         var _loc2_:ServiceDefinition = null;
         var _loc4_:MovieClip = null;
         var _loc1_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         _loc2_ = ServiceDefinitionManager.getInstance().getServiceDefinition(Profile.SERVICES_MOVE_SKU) as ServiceDefinition;
         var _loc3_:int = _loc2_.getPriceCash();
         this.mUseFAcebookCredits = Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc1_.DCCash < _loc3_;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_confirm_buy_rent_crane_operator"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         mOkButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
         if(this.mUseFAcebookCredits)
         {
            this.mRentPrice = _loc2_.getPriceFBCredits();
            _loc4_ = mBox["RentButton"];
            _loc4_.visible = false;
            _loc4_ = mBox["unlock_fc"];
         }
         else
         {
            this.mRentPrice = _loc2_.getPriceCash();
            _loc4_ = mBox["unlock_fc"];
            _loc4_.visible = false;
            _loc4_ = mBox["RentButton"];
         }
         this.mRentButton = new DynamicButton(_loc4_);
         this.mRentButton.setLabel("Rent");
         this.mGold = mBox.getChildByName("gold") as MovieClip;
         this.mGold.stop();
         super();
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.finishRent();
         }
      }
      
      public function buyWithCredits() : Object
      {
         var _loc1_:ServiceDefinition = ServiceDefinitionManager.getInstance().getServiceDefinition(Profile.SERVICES_MOVE_SKU) as ServiceDefinition;
         return {
            "price":_loc1_.getPriceFBCredits(),
            "orderInfo":{
               "type":FBCreditsPurchase.TYPE_RENT_TOOL,
               "sku":_loc1_.sku
            }
         };
      }
      
      private function onCancelRent(param1:Event) : void
      {
         this.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelRent);
         this.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchangeRent);
      }
      
      public function showPopupParams(param1:int, param2:Boolean) : void
      {
         super.show();
         this.mPrice = param1;
         this.mIsCash = param2;
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         mOkButton.start();
         if(this.mUseFAcebookCredits && this.mPrice > DollarsGame.getCurrentWorld().getCompanyMine().DCCoins)
         {
            mOkButton.disable();
         }
         else
         {
            mOkButton.addEventListener(MouseEvent.CLICK,this.onAcceptBuy);
         }
         this.mRentButton.start();
         this.mRentButton.addEventListener(MouseEvent.CLICK,this.onRent);
         var _loc3_:TextField = TextField(mBox.getChildByName("Expand"));
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = TextManager.getText(TextIDs.TID_MOVE_TITLE);
         var _loc4_:TextField = TextField(mBox.getChildByName("TextInfo_01"));
         TextManager.reformatTextField(_loc4_);
         _loc4_.text = TextManager.getText(TextIDs.TID_MOVE_TEXT1);
         var _loc5_:TextField = TextField(mBox.getChildByName("TextInfo_02"));
         TextManager.reformatTextField(_loc5_);
         _loc5_.text = TextManager.getText(TextIDs.TID_MOVE_TEXT2);
         TextManager.changColors(_loc5_);
         var _loc6_:TextField = TextField(mBox.getChildByName("mPrize"));
         if(param2)
         {
            _loc6_.text = TextManager.convertNumberToString(param1,TextManager.TRUNCATE_THOUSAND,7);
            this.mGold.gotoAndStop(2);
         }
         else
         {
            _loc6_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param1,TextManager.TRUNCATE_THOUSAND,7);
            this.mGold.gotoAndStop(1);
         }
         if(this.mUseFAcebookCredits)
         {
            mBox["DCCash"].visible = false;
            mBox["goldicon"].visible = false;
            this.mRentButton.setLabel("" + this.mRentPrice);
         }
         else
         {
            TextField(mBox.getChildByName("DCCash")).text = TextManager.convertNumberToString(this.mRentPrice,TextManager.TRUNCATE_THOUSAND,7);
         }
         this.mPopupConfirm = new PopupConfirm();
         startShow();
      }
      
      private function onAcceptBuy(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         if(_loc2_.DCCoins < this.mPrice)
         {
            this.mPopupConfirm.startNoAction(this.mPrice);
            this.mPopupConfirm.addEventListener(PopupConfirm.EVENT_CANCEL,this.onCancel);
            this.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         }
         else
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
            onAccept(null);
         }
      }
      
      private function onCloseFeed(param1:Event) : void
      {
         this.mPopupFeed.removeEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         this.mPopupFeed = null;
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_MOVE);
      }
      
      private function onExchange(param1:Event) : void
      {
         this.onCancel(null);
         dispatchEvent(new Event(EVENT_ACCEPT));
         onAccept(null);
      }
      
      private function finishRent() : void
      {
         this.mPopupFeed = new PopupPartner(PopupPartner.TYPE_SHARE_RENT_MOVE);
         this.mPopupFeed.showPopupParams(null);
         this.mPopupFeed.addEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         dispatchEvent(new Event(EVENT_RENT));
         onClose(null);
      }
      
      private function onRent(param1:MouseEvent) : void
      {
         var _loc2_:Company = null;
         if(this.mUseFAcebookCredits)
         {
            FBCreditsPurchase.getInstance().startPurchaseProcess(this);
         }
         else
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
            if(_loc2_.DCCash < this.mRentPrice)
            {
               this.mPopupConfirm.startNoEnoughGold(0,this.mRentPrice);
            }
            else
            {
               DollarsGame.getCurrentWorld().getCompanyMine().delayedPaymentSetGold(this.mRentPrice,MetricConstants.LABEL_ECONOMY_MOVE_ITEM);
               this.finishRent();
            }
         }
      }
      
      private function onCancel(param1:Event) : void
      {
         this.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onCancel);
         this.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         if(param1 != null)
         {
            onClose(null);
         }
      }
      
      private function onExchangeRent(param1:Event) : void
      {
         this.onCancelRent(null);
         this.onRent(null);
      }
      
      override protected function close() : void
      {
         super.close();
         dispatchEvent(new Event(EVENT_CLOSE));
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mShowPopup = false;
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.onAcceptBuy);
         this.mRentButton.end();
         this.mRentButton.removeEventListener(MouseEvent.CLICK,this.onRent);
         this.mPopupConfirm = null;
      }
   }
}

