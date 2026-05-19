package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.Tutorial;
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
   
   public class PopupTradeBox extends Popup implements FBCreditsPurchaseInterface
   {
      
      public static const TYPE_BUY:uint = 0;
      
      public static const TYPE_INSTANT_BUILD:uint = 1;
      
      public static const TYPE_MOVE:uint = 2;
      
      private var mPopupConfirm:PopupConfirm;
      
      private var mType:uint;
      
      private var mTitle:TextField;
      
      private var mPrice:int;
      
      public function PopupTradeBox(param1:uint)
      {
         var _loc2_:Sprite = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM_BUILD,"popup_confirm_buy"))();
         this.mType = param1;
         this.mTitle = mBox["title"];
         TextManager.reformatTextField(this.mTitle);
         switch(this.mType)
         {
            case TYPE_BUY:
               this.mTitle.text = TextManager.getText(TextIDs.TID_BUY_FOR);
               break;
            case TYPE_INSTANT_BUILD:
               this.mTitle.text = TextManager.getText(TextIDs.TID_TUTORIAL_TITLE_6);
         }
         _loc2_ = mBox["button_1"];
         _loc2_.visible = false;
         mOkButton = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM_BUILD,"button_green"))());
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_YES));
         mOkButton.getButtonMc().x = _loc2_.x;
         mOkButton.getButtonMc().y = _loc2_.y;
         mBox.addChild(mOkButton.getButtonMc());
         mCancelButton = new DynamicButton(mBox.getChildByName("button_close") as MovieClip);
         super();
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_SKIP_ACTION,MetricConstants.PRODUCT_FOR_SALE,null,null,0,1);
            dispatchEvent(new Event(EVENT_ACCEPT));
            this.doClose(null);
         }
      }
      
      private function onExchange(param1:Event) : void
      {
         this.removeConfirmEventListeners();
         this.doAccept(null);
      }
      
      private function removeConfirmEventListeners() : void
      {
         this.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_USE_FBC_CONTINUE,this.onFBCGoOn);
         this.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onCancel);
         this.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
      }
      
      public function changePrize(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:TextField = mBox["text"];
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param1,0,0);
         TextManager.setTextScaled(_loc3_);
         this.mPrice = param1;
         if(param2 || this.mPrice <= DollarsGame.getCurrentWorld().getCompanyMine().DCCoins)
         {
            mOkButton.enable();
            mOkButton.addEventListener(MouseEvent.CLICK,this.doAccept);
         }
         else
         {
            mOkButton.disable();
         }
      }
      
      private function doClose(param1:MouseEvent) : void
      {
         onClose(param1);
      }
      
      private function onFBCGoOn(param1:Event) : void
      {
         this.removeConfirmEventListeners();
         FBCreditsPurchase.getInstance().startPurchaseProcess(this);
      }
      
      public function start() : void
      {
         var _loc1_:DollarsGame = null;
         if(mBox != null)
         {
            super.show();
            mOkButton.start();
            mCancelButton.start();
            mCancelButton.addEventListener(MouseEvent.CLICK,this.doClose);
            _loc1_ = DollarsGame.smInstance;
            _loc1_.mGameClip.mouseChildren = false;
            _loc1_.mGameClip.mouseEnabled = false;
            startShow();
            if(!Tutorial.smTutorialEnd)
            {
               mCancelButton.disable();
            }
            else
            {
               mCancelButton.enable();
            }
            mNeedsToUpdateOutline = true;
         }
      }
      
      private function doAccept(param1:MouseEvent) : void
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         if(_loc2_.DCCoins < this.mPrice)
         {
            this.mPopupConfirm = DollarsGame.smInstance.mPopupConfirm;
            this.mPopupConfirm.startAskForHelpFBCredits(this.mPrice);
            this.mPopupConfirm.addEventListener(PopupConfirm.EVENT_USE_FBC_CONTINUE,this.onFBCGoOn);
            this.mPopupConfirm.addEventListener(PopupConfirm.EVENT_CANCEL,this.onCancel);
            this.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         }
         else
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
            this.doClose(null);
            if(param1 != null)
            {
               param1.stopPropagation();
            }
         }
      }
      
      private function onCancel(param1:Event) : void
      {
         this.removeConfirmEventListeners();
         this.doClose(null);
      }
      
      override public function destroy() : void
      {
         mOkButton.removeEventListener(MouseEvent.CLICK,this.doAccept);
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.doClose);
         mOkButton.destroy();
         mOkButton = null;
         mCancelButton.destroy();
         mCancelButton = null;
         mBox = null;
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":FBCreditsPurchase.SKIP_ACTION_PRICE,
            "orderInfo":{
               "type":FBCreditsPurchase.TYPE_SKIP_ACTION,
               "sku":"tradebox"
            }
         };
      }
      
      override protected function close() : void
      {
         var _loc1_:DollarsGame = null;
         super.close();
         if(mBox != null)
         {
            mOkButton.end();
            mOkButton.removeEventListener(MouseEvent.CLICK,this.doAccept);
            mCancelButton.end();
            mCancelButton.removeEventListener(MouseEvent.CLICK,this.doClose);
            _loc1_ = DollarsGame.smInstance;
            _loc1_.mPopupClip.removeChild(mBox);
            _loc1_.mGameClip.mouseChildren = true;
            _loc1_.mGameClip.mouseEnabled = true;
            dispatchEvent(new Event(EVENT_CLOSE));
         }
      }
   }
}

