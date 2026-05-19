package com.dchoc.dollars.GUI.exchangeForCash
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupExchange extends Popup
   {
      
      public static const EVENT_EXCHANGED:String = "EventExchanged";
      
      private var mExchangeButton:DynamicButton;
      
      private var mGoldValue:int;
      
      private var mCompany:Company;
      
      private var mCoins:uint;
      
      private var mAnim:MovieClip;
      
      private var mGold:uint;
      
      private var mLaunchAnim:Boolean;
      
      private var mCoinsBox:Sprite;
      
      private var mCancelButton2:DynamicButton;
      
      private var mGoldButton:DynamicButton;
      
      public function PopupExchange()
      {
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"exchange_01"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"exchange_02"))();
         }
         this.mExchangeButton = new DynamicButton(mBox.getChildByName("exchange_cash") as MovieClip);
         this.mExchangeButton.setLabel(TextManager.getText(TextIDs.TID_EXCHANGE_POPUP_BUTTON_EXCHANGE));
         this.mGoldButton = new DynamicButton(mBox.getChildByName("add_gold") as MovieClip);
         this.mGoldButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_TEXT_ADDCASH));
         mCancelButton = new DynamicButton(mBox.getChildByName("CancelButton") as MovieClip);
         mCancelButton.setLabel(TextManager.getText(TextIDs.TID_GEN_BUTTON_CANCEL));
         this.mCancelButton2 = new DynamicButton(mBox.getChildByName("CancelButton_02") as MovieClip);
         this.mCancelButton2.setLabel(TextManager.getText(TextIDs.TID_GEN_BUTTON_CANCEL));
         mOkButton = new DynamicButton(mBox.getChildByName("DoneButton") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_CONFIRM));
         this.mGoldValue = RulesFacade.getDCCashToDCCoins();
         this.mAnim = new AssetManager.NextButtonAnim();
         this.mAnim.stop();
         this.mCoinsBox = mBox.getChildByName("Coins") as Sprite;
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_EXCHANGE_POPUP_TITLE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo")));
         TextField(mBox.getChildByName("TextInfo")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_EXCHANGE_POPUP_HAVE));
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo1")));
         TextField(mBox.getChildByName("TextInfo1")).text = TextManager.rtlText(TextManager.getText(TextIDs.TID_EXCHANGE_POPUP_TRADE));
         super();
      }
      
      private function checkAnim(param1:Event) : void
      {
         if(this.mAnim.currentFrame == this.mAnim.totalFrames)
         {
            if(this.mCoinsBox.contains(this.mAnim))
            {
               this.mCoinsBox.removeChild(this.mAnim);
            }
            this.mAnim.stop();
            this.mAnim.removeEventListener(Event.ENTER_FRAME,this.checkAnim);
         }
      }
      
      private function onAddGold(param1:MouseEvent) : void
      {
         onClose(null);
         DollarsGame.addGold();
      }
      
      private function onDoChanges(param1:MouseEvent) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         onClose(null);
         if(this.mCompany.DCCash != this.mGold)
         {
            _loc2_ = this.mCompany.DCCash;
            _loc3_ = this.mCompany.DCCash - this.mGold;
            this.mCompany.DCCash = this.mGold;
            this.mCompany.DCCoins = this.mCoins;
            DollarsGame.getProfile().exchangeDone(_loc3_);
            if(_loc3_ < 0)
            {
               _loc4_ = "Initial Gold: " + _loc2_ + " | Gold: " + this.mGold + " | Cash: " + this.mCoins;
               MyMetrics.send_GA_metric("Hacking",MetricConstants.LABEL_ECONOMY_CONVERT_HUD_GOLD,_loc4_,_loc3_);
            }
            else
            {
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_CONVERT_HUD_GOLD,null,null,null,0,_loc3_);
            }
            dispatchEvent(new Event(EVENT_EXCHANGED));
         }
      }
      
      private function fillFields() : void
      {
         var _loc1_:Sprite = mBox.getChildByName("DCcash") as Sprite;
         TextManager.reformatTextField(TextField(this.mCoinsBox.getChildByName("DCCoins")),false);
         TextManager.setTextScaled(TextField(this.mCoinsBox.getChildByName("DCCoins")),true);
         TextField(this.mCoinsBox.getChildByName("DCCoins")).text = TextManager.convertNumberToString(this.mCoins,TextManager.TRUNCATE_MILLIONS,8);
         TextManager.reformatTextField(TextField(_loc1_.getChildByName("DCCash")),false);
         TextManager.setTextScaled(TextField(_loc1_.getChildByName("DCCash")),true);
         TextField(_loc1_.getChildByName("DCCash")).text = TextManager.convertNumberToString(this.mGold,TextManager.TRUNCATE_THOUSAND,4);
         TextField(mBox.getChildByName("gold")).text = "" + 1;
         TextManager.reformatTextField(TextField(mBox.getChildByName("cash")),false);
         TextManager.setTextScaled(TextField(mBox.getChildByName("cash")),true);
         TextField(mBox.getChildByName("cash")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(this.mGoldValue,TextManager.TRUNCATE_THOUSAND,6);
      }
      
      private function onExchange(param1:Event) : void
      {
         this.mCoins += this.mGoldValue;
         --this.mGold;
         this.mLaunchAnim = true;
         this.fillFields();
         if(this.mGold == 0)
         {
            this.mExchangeButton.removeEventListener(MouseEvent.CLICK,this.onExchange);
            this.mExchangeButton.getButtonMc().mouseEnabled = false;
            this.mExchangeButton.getButtonMc().alpha = 0.3;
         }
         if(!this.mCoinsBox.contains(this.mAnim))
         {
            this.mCoinsBox.addChild(this.mAnim);
            this.mAnim.gotoAndPlay(1);
            this.mAnim.addEventListener(Event.ENTER_FRAME,this.checkAnim);
            this.mAnim.y = 20;
            this.mAnim.x = 100;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         this.mCompany = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mGold = this.mCompany.DCCash;
         this.mCoins = this.mCompany.DCCoins;
         this.mExchangeButton.start();
         this.mExchangeButton.addEventListener(MouseEvent.CLICK,this.onExchange);
         this.mExchangeButton.enable();
         this.mExchangeButton.visible = true;
         this.mExchangeButton.getButtonMc().mouseEnabled = true;
         this.mExchangeButton.getButtonMc().alpha = 1;
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         mCancelButton.visible = true;
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.onDoChanges);
         mOkButton.visible = true;
         this.mCancelButton2.start();
         this.mCancelButton2.addEventListener(MouseEvent.CLICK,onClose);
         this.mCancelButton2.visible = false;
         if(this.mGold == 0)
         {
            this.mExchangeButton.visible = false;
            this.mExchangeButton.getButtonMc().mouseEnabled = false;
            this.mExchangeButton.getButtonMc().alpha = 0.3;
            mCancelButton.visible = false;
            this.mCancelButton2.visible = true;
            mOkButton.visible = false;
         }
         this.mGoldButton.start();
         this.mGoldButton.addEventListener(MouseEvent.CLICK,this.onAddGold);
         this.mGoldButton.visible = true;
         if(this.mGold > 0)
         {
            this.mGoldButton.visible = false;
         }
         startShow();
         this.fillFields();
         this.mLaunchAnim = false;
      }
      
      override protected function close() : void
      {
         super.close();
         this.mExchangeButton.end();
         this.mExchangeButton.removeEventListener(MouseEvent.CLICK,this.onExchange);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mCancelButton2.end();
         this.mCancelButton2.removeEventListener(MouseEvent.CLICK,onClose);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.onDoChanges);
         this.mGoldButton.end();
         this.mGoldButton.removeEventListener(MouseEvent.CLICK,this.onAddGold);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mShowPopup = false;
         this.mAnim.gotoAndStop(this.mAnim.totalFrames);
         this.checkAnim(null);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      override public function destroy() : void
      {
         this.mExchangeButton.destroy();
         this.mGoldButton.destroy();
         mCancelButton.destroy();
         this.mCancelButton2.destroy();
         mOkButton.destroy();
         this.mCoinsBox = null;
         this.mAnim = null;
         this.mExchangeButton = null;
         this.mGoldButton = null;
         mCancelButton = null;
         this.mCancelButton2 = null;
         mOkButton = null;
      }
   }
}

