package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupConfirmExpansion extends Popup implements FBCreditsPurchaseInterface
   {
      
      public static const EVENT_UNLOCK_EXPANSION_FBC:String = "EventUnlockExpFBC";
      
      public static const SKU:String = "Expansions";
      
      private var mIsInvesting:Boolean;
      
      private var mPriceGold:int = 0;
      
      private var mButtonRight:DynamicButton = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(SKU,"button_buy_fbc"))() as MovieClip);
      
      private var mButtonLeft:DynamicButton = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(SKU,"button_buy"))() as MovieClip);
      
      private var mPriceFBC:int = 0;
      
      private var mButtonCenter:DynamicButton = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(SKU,"button_invest"))() as MovieClip);
      
      private var mPriceCash:int = 0;
      
      private var mPopupFeed:PopupPartner;
      
      public function PopupConfirmExpansion()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(SKU,"popup_confirm_expansion"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_01")));
         TextField(mBox.getChildByName("TextInfo_01")).text = TextManager.getText(TextIDs.TID_CONFIRM_EXP_PAY_INVEST);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_03")));
         TextField(mBox.getChildByName("TextInfo_03")).text = TextManager.getText(TextIDs.TID_CONFIRM_EXP_PAY_COINS);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo_02")));
         TextField(mBox.getChildByName("TextInfo_02")).text = TextManager.getText(TextIDs.TID_CONFIRM_EXP_PAY_GOLD);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Expand")));
         TextField(mBox.getChildByName("Expand")).text = TextManager.getText(TextIDs.TID_CONFIRM_EXP_TITLE);
         super();
      }
      
      private function onBuyFBC(param1:MouseEvent) : void
      {
         this.onBuy(false);
      }
      
      private function onBuyCash(param1:MouseEvent) : void
      {
         this.onBuy(true);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         var _loc2_:int = 0;
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            _loc2_ = DollarsGame.getCurrentWorld().map.getPlotIdToBuy();
            dispatchEvent(new Event(PopupConfirmExpansion.EVENT_UNLOCK_EXPANSION_FBC));
            onClose(null);
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_EXPANSION,MetricConstants.PRODUCT_EXPANSION,"expansion " + _loc2_,null,0,this.mPriceFBC);
            this.launchNewFeed();
         }
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":this.mPriceFBC,
            "orderInfo":{
               "sku":DollarsGame.getProfile().getExpansionCount(),
               "type":FBCreditsPurchase.TYPE_UNLOCK_EXPANSION
            }
         };
      }
      
      private function onCloseFeed(param1:Event) : void
      {
         this.mPopupFeed.removeEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         this.mPopupFeed = null;
      }
      
      private function onBuyCashDiscount(param1:MouseEvent) : void
      {
         this.onBuy(true,true);
      }
      
      private function onExchange(param1:Event) : void
      {
         this.onCancelExchange(null);
         var _loc2_:Profile = DollarsGame.getProfile();
         var _loc3_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         _loc2_.setUpdateEnabled(false);
         _loc3_.DCCoins -= this.mPriceCash;
         DollarsGame.getCurrentWorld().map.gainedAccumDCCoins(-this.mPriceCash);
         MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_CONVERT_GOLD_EXPANSION);
         onAccept(null);
         this.launchNewFeed();
      }
      
      private function onBuy(param1:Boolean, param2:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc3_:Profile = DollarsGame.getProfile();
         var _loc4_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc5_:int = DollarsGame.getCurrentWorld().map.getPlotIdToBuy();
         if(param2)
         {
            onAccept(null);
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,MetricConstants.LABEL_ECONOMY_BUY_EXPANSION,MetricConstants.PRODUCT_EXPANSION,"expansion " + _loc5_,null,0,0);
            this.launchNewFeed();
         }
         else if(!param1)
         {
            if(this.mPriceFBC > 0)
            {
               FBCreditsPurchase.getInstance().startPurchaseProcess(this);
            }
            else if(_loc4_.DCCash >= this.mPriceGold)
            {
               _loc3_.setUpdateEnabled(false);
               _loc4_.DCCash -= this.mPriceGold;
               DollarsGame.getCurrentWorld().map.gainedAccumDCCash(-this.mPriceGold);
               onAccept(null);
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_EXPANSION,MetricConstants.PRODUCT_EXPANSION,"expansion " + _loc5_,null,0,this.mPriceGold);
               this.launchNewFeed();
            }
            else
            {
               DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,this.mPriceGold);
            }
         }
         else if(_loc4_.DCCoins >= this.mPriceCash)
         {
            _loc3_.setUpdateEnabled(false);
            _loc4_.DCCoins -= this.mPriceCash;
            DollarsGame.getCurrentWorld().map.gainedAccumDCCoins(-this.mPriceCash);
            onAccept(null);
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,MetricConstants.LABEL_ECONOMY_BUY_EXPANSION,MetricConstants.PRODUCT_EXPANSION,"expansion " + _loc5_,null,this.mPriceCash,0);
            this.launchNewFeed();
         }
         else
         {
            DollarsGame.smInstance.mPopupConfirm.startAskForHelpFBCredits(this.mPriceCash);
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelExchange);
         }
      }
      
      override public function showPopup() : void
      {
         var _loc4_:Sprite = null;
         var _loc5_:MovieClip = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:TextField = null;
         super.show();
         var _loc1_:Profile = DollarsGame.getProfile();
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc3_:int = DollarsGame.getCurrentWorld().map.getPlotIdToBuy();
         this.mIsInvesting = false;
         this.mPriceGold = _loc1_.expansionsGetDCCash(_loc3_);
         this.mPriceCash = _loc1_.expansionsGetDCCoins(_loc3_);
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc2_.DCCash < this.mPriceGold)
         {
            this.mPriceFBC = _loc1_.expansionsGetFBCredits(_loc3_);
         }
         _loc6_ = InvestManager.getInstance().statsGetInvestmentsSuccesfullyCount();
         _loc7_ = _loc1_.expansionsGetFriendsNeeded(_loc3_);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mButtonLeft.start();
         this.mButtonLeft.setLabel(TextManager.convertNumberToString(this.mPriceCash,TextManager.TRUNCATE_MILLIONS,6));
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && this.mPriceCash > _loc2_.DCCoins)
         {
            this.mButtonLeft.disable();
         }
         else
         {
            this.mButtonLeft.addEventListener(MouseEvent.CLICK,this.onBuyCash);
         }
         _loc4_ = mBox["button_buy_1"];
         this.mButtonLeft.getButtonMc().x = _loc4_.x;
         this.mButtonLeft.getButtonMc().y = _loc4_.y;
         mBox.removeChild(_loc4_);
         mBox.addChild(this.mButtonLeft.getButtonMc());
         _loc4_ = mBox["box_1"];
         _loc5_ = new (DCResourceManager.getInstance().getSWFClass(SKU,"box_cash"))() as MovieClip;
         _loc5_.x = _loc4_.x;
         _loc5_.y = _loc4_.y;
         mBox.removeChild(_loc4_);
         mBox.addChild(_loc5_);
         _loc4_ = mBox["button_buy_2"];
         _loc9_ = mBox["Friends"];
         TextManager.reformatTextField(_loc9_);
         _loc5_ = new (DCResourceManager.getInstance().getSWFClass(SKU,"box_invest_pending"))() as MovieClip;
         var _loc10_:TextField = _loc5_["Caption"];
         _loc10_.text = TextManager.getText(TextIDs.TID_GEN_FREE);
         TextManager.setTextScaled(_loc10_);
         if(_loc6_ < _loc7_)
         {
            this.mButtonCenter.setLabel(TextManager.getText(TextIDs.TID_INVEST_POPUP1_TITLE));
            this.mButtonCenter.addEventListener(MouseEvent.CLICK,this.onInvest);
            _loc8_ = TextIDs.TID_NEED_FRIENDS;
            _loc9_.textColor = 13369344;
         }
         else
         {
            this.mButtonCenter.destroy();
            this.mButtonCenter = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(SKU,"button_buy"))() as MovieClip);
            this.mButtonCenter.setLabel(TextManager.getText(TextIDs.TID_HINT_BUTTON_BUY));
            this.mButtonCenter.addEventListener(MouseEvent.CLICK,this.onBuyCashDiscount);
            _loc8_ = TextIDs.TID_HAVE_FRIENDS;
            _loc9_.textColor = 39218;
         }
         this.mButtonCenter.start();
         this.mButtonCenter.getButtonMc().x = _loc4_.x;
         this.mButtonCenter.getButtonMc().y = _loc4_.y;
         mBox.removeChild(_loc4_);
         mBox.addChild(this.mButtonCenter.getButtonMc());
         _loc4_ = mBox["box_2"];
         _loc5_.x = _loc4_.x;
         _loc5_.y = _loc4_.y;
         mBox.removeChild(_loc4_);
         mBox.addChild(_loc5_);
         _loc9_.text = TextManager.replaceParameters(_loc8_,new Array("" + _loc7_));
         TextManager.setTextScaled(_loc9_);
         _loc4_ = mBox["button_buy_3"];
         if(this.mPriceFBC > 0)
         {
            this.mButtonRight.setLabel(TextManager.convertNumberToString(this.mPriceFBC,TextManager.TRUNCATE_MILLIONS,6));
            _loc5_ = new (DCResourceManager.getInstance().getSWFClass(SKU,"box_fbc"))() as MovieClip;
            TextField(mBox.getChildByName("TextInfo_02")).text = TextManager.getText(TextIDs.TID_CONFIRM_EXP_PAY_FBC);
         }
         else
         {
            this.mButtonRight.destroy();
            this.mButtonRight = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(SKU,"button_buy"))() as MovieClip);
            this.mButtonRight.setLabel(TextManager.convertNumberToString(this.mPriceGold,TextManager.TRUNCATE_MILLIONS,6));
            _loc5_ = new (DCResourceManager.getInstance().getSWFClass(SKU,"box_gold"))() as MovieClip;
         }
         this.mButtonRight.addEventListener(MouseEvent.CLICK,this.onBuyFBC);
         this.mButtonRight.start();
         this.mButtonRight.getButtonMc().x = _loc4_.x;
         this.mButtonRight.getButtonMc().y = _loc4_.y;
         mBox.removeChild(_loc4_);
         mBox.addChild(this.mButtonRight.getButtonMc());
         _loc4_ = mBox["box_3"];
         _loc5_.x = _loc4_.x;
         _loc5_.y = _loc4_.y;
         mBox.removeChild(_loc4_);
         mBox.addChild(_loc5_);
         startShow();
      }
      
      private function launchNewFeed() : void
      {
         this.mPopupFeed = new PopupPartner(PopupPartner.TYPE_SHARE_NEW_EXPANSION);
         this.mPopupFeed.showPopupParams(null);
         this.mPopupFeed.addEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
      }
      
      private function onInvest(param1:MouseEvent) : void
      {
         onClose(null);
         this.mIsInvesting = true;
      }
      
      private function onCancelExchange(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelExchange);
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mButtonLeft.end();
         this.mButtonLeft.removeEventListener(MouseEvent.CLICK,this.onBuyCash);
         this.mButtonCenter.end();
         this.mButtonCenter.removeEventListener(MouseEvent.CLICK,this.onBuyCashDiscount);
         this.mButtonCenter.removeEventListener(MouseEvent.CLICK,this.onInvest);
         this.mButtonRight.end();
         this.mButtonRight.removeEventListener(MouseEvent.CLICK,this.onBuyFBC);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mShowPopup = false;
         dispatchEvent(new Event(EVENT_CLOSE));
         if(this.mIsInvesting)
         {
            DollarsGame.getCurrentRole().toolsBar.showInvestMenu();
            DollarsGame.getCurrentRole().toolsBar.mPopupInvest.onNewInvest(null);
         }
      }
   }
}

