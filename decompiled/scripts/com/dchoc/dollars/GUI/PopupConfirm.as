package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupConfirm extends Popup
   {
      
      public static const EVENT_USE_FB_CREDITS:String = "EventUseFBC";
      
      public static const EVENT_USE_FBC_CONTINUE:String = "EventUseFBCContinue";
      
      public static const EVENT_EXCHANGE:String = "EventExchange";
      
      public static const EVENT_CANCEL:String = "EventCancel";
      
      private var mTitleText:TextField = mBox["title"];
      
      private var mGoldToExchange:int;
      
      private var mButton1:DynamicButton;
      
      private var mButton2:DynamicButton;
      
      private var mCloseButton:DynamicButton = new DynamicButton(mBox["button_close"]);
      
      private var mBodyText:TextField = mBox["text"];
      
      public function PopupConfirm()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM,"popup_confirm"))();
         super();
      }
      
      private function onAddGold(param1:MouseEvent) : void
      {
         DollarsGame.addGold();
         onClose(null);
      }
      
      private function onFBCreditsContinue(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(EVENT_USE_FBC_CONTINUE));
         onClose(null);
      }
      
      private function convertToGold(param1:int) : int
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         var _loc3_:int = RulesFacade.getDCCashToDCCoins();
         var _loc4_:int = param1 - _loc2_.DCCoins;
         var _loc5_:int = int(_loc4_ / _loc3_);
         if(_loc4_ % _loc3_ > 0)
         {
            _loc5_++;
         }
         return _loc5_;
      }
      
      public function startNoAction(param1:int) : void
      {
         var _loc2_:Sprite = null;
         if(this.hasEnoughGold(param1))
         {
            this.startExchangeGold(param1);
         }
         else
         {
            this.mGoldToExchange = 0;
            TextManager.reformatTextField(this.mBodyText);
            this.mBodyText.text = TextManager.getText(TextIDs.TID_NO_CASH_BODY_FAKE_FBC);
            TextManager.setTextScaled(this.mBodyText,false);
            TextManager.reformatTextField(this.mTitleText);
            this.mTitleText.text = TextManager.getText(TextIDs.TID_NO_CASH_TITLE);
            TextManager.setTextScaled(this.mTitleText);
            this.mCloseButton.start();
            this.mCloseButton.addEventListener(MouseEvent.CLICK,this.onCancel);
            _loc2_ = mBox["button_1"];
            _loc2_.visible = false;
            _loc2_ = mBox["button_3"];
            _loc2_.visible = false;
            _loc2_ = mBox["button_2"];
            _loc2_.visible = false;
            this.mButton1 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM,"button_green"))());
            this.mButton1.start();
            this.mButton1.setLabel(TextManager.getText(TextIDs.TID_INVEST_POST1_TARGET));
            this.mButton1.addEventListener(MouseEvent.CLICK,this.onCancel);
            this.mButton1.getButtonMc().x = _loc2_.x;
            this.mButton1.getButtonMc().y = _loc2_.y;
            mBox.addChild(this.mButton1.getButtonMc());
            this.showPopup();
         }
      }
      
      public function startNoEnoughGold(param1:int, param2:int = 0) : void
      {
         var _loc3_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mGoldToExchange = 0;
         if(param1 != 0)
         {
            param2 = this.convertToGold(param1);
         }
         var _loc4_:String = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param2 * RulesFacade.getDCCashToDCCoins(),0,0);
         TextManager.reformatTextField(this.mBodyText);
         if(param1 > 0 && param2 > 0)
         {
            this.mBodyText.text = TextManager.replaceParameters(TextIDs.TID_NOT_ENOUGH_CASH_AND_GOLD,new Array(_loc4_,param2,_loc3_.DCCash));
         }
         else
         {
            this.mBodyText.text = TextManager.replaceParameters(TextIDs.TID_NOT_ENOUGH_GOLD,new Array(0,"" + (param2 - _loc3_.DCCash)));
         }
         TextManager.changColors(this.mBodyText);
         TextManager.setTextScaled(this.mBodyText,false);
         TextManager.reformatTextField(this.mTitleText);
         this.mTitleText.text = TextManager.getText(TextIDs.TID_NO_GOLD_TITLE);
         TextManager.setTextScaled(this.mTitleText);
         this.mCloseButton.start();
         this.mCloseButton.addEventListener(MouseEvent.CLICK,this.onCancel);
         var _loc5_:Sprite = mBox["button_1"];
         _loc5_.visible = false;
         _loc5_ = mBox["button_3"];
         _loc5_.visible = false;
         _loc5_ = mBox["button_2"];
         _loc5_.visible = false;
         this.mButton1 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUTTON_LIBRARY,"button_gold"))());
         this.mButton1.start();
         this.mButton1.setLabel(TextManager.getText(TextIDs.TID_BUTTON_TEXT_ADDCASH));
         this.mButton1.addEventListener(MouseEvent.CLICK,this.onAddGold);
         this.mButton1.getButtonMc().x = _loc5_.x;
         this.mButton1.getButtonMc().y = _loc5_.y;
         mBox.addChild(this.mButton1.getButtonMc());
         this.showPopup();
      }
      
      public function startFBCreditsOffer(param1:int, param2:int) : Boolean
      {
         var _loc3_:Sprite = null;
         if(this.hasEnoughGold(param1))
         {
            this.startExchangeGold(param1);
            return false;
         }
         if(!Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.startNoEnoughGold(param1);
            return false;
         }
         this.mGoldToExchange = 0;
         TextManager.reformatTextField(this.mBodyText);
         this.mBodyText.text = TextManager.getText(TextIDs.TID_NO_CASH_OFFER_BODY_FBC);
         TextManager.setTextScaled(this.mBodyText,false);
         TextManager.reformatTextField(this.mTitleText);
         this.mTitleText.text = TextManager.getText(TextIDs.TID_NO_CASH_OFFER_TITLE_FBC);
         TextManager.setTextScaled(this.mTitleText);
         this.mCloseButton.start();
         this.mCloseButton.addEventListener(MouseEvent.CLICK,this.onCancel);
         _loc3_ = mBox["button_1"];
         _loc3_.visible = false;
         _loc3_ = mBox["button_3"];
         _loc3_.visible = false;
         _loc3_ = mBox["button_2"];
         _loc3_.visible = false;
         this.mButton1 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM,"button_fbc"))());
         this.mButton1.start();
         this.mButton1.setLabel(String(param2));
         this.mButton1.addEventListener(MouseEvent.CLICK,this.onFBCredits);
         this.mButton1.getButtonMc().x = _loc3_.x;
         this.mButton1.getButtonMc().y = _loc3_.y;
         mBox.addChild(this.mButton1.getButtonMc());
         this.showPopup();
         return true;
      }
      
      private function startExchangeGold(param1:int) : void
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mGoldToExchange = this.convertToGold(param1);
         var _loc3_:String = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(this.mGoldToExchange * RulesFacade.getDCCashToDCCoins(),0,0);
         TextManager.reformatTextField(this.mBodyText);
         this.mBodyText.text = TextManager.replaceParameters(TextIDs.TID_NOT_ENOUGH_CASH,new Array("" + this.mGoldToExchange,_loc3_));
         TextManager.setTextScaled(this.mBodyText,false);
         TextManager.changColors(this.mBodyText);
         TextManager.reformatTextField(this.mTitleText);
         this.mTitleText.text = TextManager.getText(TextIDs.TID_NO_CASH_TITLE);
         TextManager.setTextScaled(this.mTitleText);
         this.mCloseButton.start();
         this.mCloseButton.addEventListener(MouseEvent.CLICK,this.onCancel);
         var _loc4_:Sprite = mBox["button_1"];
         _loc4_.visible = false;
         _loc4_ = mBox["button_3"];
         _loc4_.visible = false;
         _loc4_ = mBox["button_2"];
         _loc4_.visible = false;
         this.mButton1 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM,"button_green"))());
         this.mButton1.start();
         this.mButton1.setLabel(TextManager.getText(TextIDs.TID_EXCHANGE_POPUP_BUTTON_EXCHANGE));
         this.mButton1.addEventListener(MouseEvent.CLICK,this.onExangeGold);
         this.mButton1.getButtonMc().x = _loc4_.x;
         this.mButton1.getButtonMc().y = _loc4_.y;
         mBox.addChild(this.mButton1.getButtonMc());
         this.showPopup();
      }
      
      private function hasEnoughGold(param1:int) : Boolean
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         return _loc2_.DCCash >= this.convertToGold(param1);
      }
      
      public function startAskForHelpFBCredits(param1:int) : void
      {
         var _loc3_:Sprite = null;
         var _loc2_:int = FBCreditsPurchase.SKIP_ACTION_PRICE;
         if(this.hasEnoughGold(param1))
         {
            this.startExchangeGold(param1);
         }
         else if(!Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.startNoEnoughGold(param1);
         }
         else
         {
            this.mGoldToExchange = 0;
            TextManager.reformatTextField(this.mBodyText);
            this.mBodyText.text = TextManager.getText(TextIDs.TID_NO_CASH_BODY_FBC);
            TextManager.setTextScaled(this.mBodyText,false);
            TextManager.reformatTextField(this.mTitleText);
            this.mTitleText.text = TextManager.getText(TextIDs.TID_NO_CASH_TITLE);
            TextManager.setTextScaled(this.mTitleText);
            this.mCloseButton.start();
            this.mCloseButton.addEventListener(MouseEvent.CLICK,this.onCancel);
            _loc3_ = mBox["button_2"];
            _loc3_.visible = false;
            _loc3_ = mBox["button_1"];
            _loc3_.visible = false;
            this.mButton1 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM,"button_fbc"))());
            this.mButton1.start();
            this.mButton1.setLabel(String(_loc2_));
            this.mButton1.addEventListener(MouseEvent.CLICK,this.onFBCreditsContinue);
            this.mButton1.getButtonMc().x = _loc3_.x;
            this.mButton1.getButtonMc().y = _loc3_.y;
            mBox.addChild(this.mButton1.getButtonMc());
            _loc3_ = mBox["button_3"];
            _loc3_.visible = false;
            this.mButton2 = new DynamicButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.POPUP_CONFIRM,"button_green"))());
            this.mButton2.start();
            this.mButton2.setLabel(TextManager.getText(TextIDs.TID_BUTTON_ASK_HELP));
            this.mButton2.addEventListener(MouseEvent.CLICK,this.onAskForHelp);
            this.mButton2.getButtonMc().x = _loc3_.x;
            this.mButton2.getButtonMc().y = _loc3_.y;
            mBox.addChild(this.mButton2.getButtonMc());
            this.showPopup();
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         startShow();
      }
      
      private function onAskForHelp(param1:MouseEvent) : void
      {
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_ASK_FOR_CASH);
         onClose(null);
      }
      
      override protected function close() : void
      {
         super.close();
         if(mBox != null)
         {
            this.mCloseButton.end();
            this.mCloseButton.removeEventListener(MouseEvent.CLICK,this.onCancel);
            if(this.mButton1 != null)
            {
               this.mButton1.end();
               this.mButton1.removeEventListener(MouseEvent.CLICK,this.onExangeGold);
               this.mButton1.removeEventListener(MouseEvent.CLICK,onAccept);
               this.mButton1.removeEventListener(MouseEvent.CLICK,this.onCancel);
               this.mButton1.removeEventListener(MouseEvent.CLICK,this.onAddGold);
               if(mBox.contains(this.mButton1.getButtonMc()))
               {
                  mBox.removeChild(this.mButton1.getButtonMc());
               }
            }
            if(this.mButton2 != null)
            {
               this.mButton2.end();
               this.mButton2.removeEventListener(MouseEvent.CLICK,this.onAskForHelp);
               if(mBox.contains(this.mButton2.getButtonMc()))
               {
                  mBox.removeChild(this.mButton2.getButtonMc());
               }
            }
            DollarsGame.smInstance.mPopupClip.removeChild(mBox);
            dispatchEvent(new Event(EVENT_CLOSE));
         }
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(EVENT_CANCEL));
         onClose(null);
      }
      
      private function onExangeGold(param1:MouseEvent) : void
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         _loc2_.DCCoins += this.mGoldToExchange * RulesFacade.getDCCashToDCCoins();
         _loc2_.DCCash -= this.mGoldToExchange;
         DollarsGame.getProfile().exchangeDone(this.mGoldToExchange);
         dispatchEvent(new Event(EVENT_EXCHANGE));
         onClose(null);
      }
      
      private function onFBCredits(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(EVENT_USE_FB_CREDITS));
         onClose(null);
      }
   }
}

