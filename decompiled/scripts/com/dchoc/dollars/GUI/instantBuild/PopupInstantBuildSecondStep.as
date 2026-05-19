package com.dchoc.dollars.GUI.instantBuild
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupInstantBuildSecondStep extends Popup implements FBCreditsPurchaseInterface
   {
      
      public static const EVENT_BUY_FBC:String = "buyFBC";
      
      public static const EVENT_BUY_CASH:String = "buyCash";
      
      private var mItemDefinition:ItemDefinition;
      
      private var mPriceText:TextField;
      
      private var mTitle:TextField;
      
      private var mButton1:DynamicButton;
      
      private var mButton2:DynamicButton;
      
      private var mText1:TextField;
      
      private var mText2:TextField;
      
      private var mCloseButton:DynamicButton;
      
      public function PopupInstantBuildSecondStep()
      {
         var _loc1_:Sprite = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_INSTANT_BUILD,"popup_instant_build"))();
         this.mCloseButton = new DynamicButton(mBox["button_close"]);
         _loc1_ = mBox["button_1"];
         this.mButton1 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_INSTANT_BUILD,"button_green"))());
         this.mButton1.getButtonMc().x = _loc1_.x;
         this.mButton1.getButtonMc().y = _loc1_.y;
         mBox.addChild(this.mButton1.getButtonMc());
         mBox.removeChild(_loc1_);
         _loc1_ = mBox["button_2"];
         this.mButton2 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_INSTANT_BUILD,"button_fbc"))());
         this.mButton2.getButtonMc().x = _loc1_.x;
         this.mButton2.getButtonMc().y = _loc1_.y;
         mBox.addChild(this.mButton2.getButtonMc());
         mBox.removeChild(_loc1_);
         this.mTitle = mBox["title"];
         this.mText1 = mBox["text_1"];
         this.mText2 = mBox["text_3"];
         this.mPriceText = mBox["text_2"];
         super();
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            dispatchEvent(new Event(EVENT_BUY_FBC));
            onClose(null);
         }
      }
      
      public function start(param1:Number, param2:ItemDefinition) : void
      {
         var _loc4_:DollarsGame = null;
         super.show();
         this.mItemDefinition = param2;
         var _loc3_:int = RulesFacade.getInstantBuildPrice(param1,this.mItemDefinition.getInstantBuildFactor());
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_MISSION_005_TITLE);
         TextManager.setTextScaled(this.mTitle);
         TextManager.reformatTextField(this.mText1);
         this.mText1.text = TextManager.getText(TextIDs.TID_CONFIRM_EXP_PAY_COINS);
         TextManager.setTextScaled(this.mText1,false);
         TextManager.reformatTextField(this.mText2);
         this.mText2.text = TextManager.getText(TextIDs.TID_CONFIRM_EXP_PAY_FBC);
         TextManager.setTextScaled(this.mText2,false);
         TextManager.reformatTextField(this.mPriceText);
         this.mPriceText.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc3_,0,0);
         TextManager.setTextScaled(this.mPriceText,false);
         this.mCloseButton.start();
         this.mCloseButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mButton1.start();
         this.mButton1.setLabel(TextManager.getText(TextIDs.TID_HINT_BUTTON_BUY));
         if(_loc3_ <= DollarsGame.getCurrentWorld().getCompanyMine().DCCoins)
         {
            this.mButton1.addEventListener(MouseEvent.CLICK,this.onCashBuy);
         }
         else
         {
            this.mButton1.disable();
         }
         this.mButton2.start();
         this.mButton2.addEventListener(MouseEvent.CLICK,this.onFBCBuy);
         this.mButton2.setLabel(TextManager.convertNumberToString(this.mItemDefinition.getInstantBuildFBC(),TextManager.TRUNCATE_MILLIONS,6));
         mNeedsToUpdateOutline = true;
         _loc4_ = DollarsGame.smInstance;
         _loc4_.mGameClip.mouseChildren = false;
         _loc4_.mGameClip.mouseEnabled = false;
         startShow();
      }
      
      private function onCashBuy(param1:Event) : void
      {
         dispatchEvent(new Event(EVENT_BUY_CASH));
         onClose(null);
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":this.mItemDefinition.getInstantBuildFBC(),
            "orderInfo":{
               "sku":this.mItemDefinition.sku,
               "type":FBCreditsPurchase.TYPE_INSTANT_BUILD
            }
         };
      }
      
      private function onFBCBuy(param1:Event) : void
      {
         FBCreditsPurchase.getInstance().startPurchaseProcess(this);
      }
      
      override protected function close() : void
      {
         var _loc1_:DollarsGame = null;
         super.close();
         if(mBox != null)
         {
            this.mCloseButton.end();
            this.mButton1.end();
            this.mButton2.end();
            this.mCloseButton.removeEventListener(MouseEvent.CLICK,onClose);
            this.mButton1.removeEventListener(MouseEvent.CLICK,this.onCashBuy);
            this.mButton2.removeEventListener(MouseEvent.CLICK,this.onFBCBuy);
            _loc1_ = DollarsGame.smInstance;
            _loc1_.mPopupClip.removeChild(mBox);
            _loc1_.mGameClip.mouseChildren = true;
            _loc1_.mGameClip.mouseEnabled = true;
            dispatchEvent(new Event(EVENT_CLOSE));
         }
      }
   }
}

