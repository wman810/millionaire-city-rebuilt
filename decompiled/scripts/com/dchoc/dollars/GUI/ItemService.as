package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.services.ServiceDefinition;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class ItemService extends Sprite implements FBCreditsPurchaseInterface
   {
      
      public static const EVENT_CONTRACT:String = "EventContract";
      
      private var mPriceCoins:int;
      
      private var mType:String;
      
      private var mItem:Sprite;
      
      private var mUseFBCredits:Boolean;
      
      private var mIsOffer:Boolean;
      
      private var mPriceFBCredits:int;
      
      private var mServiceDef:ServiceDefinition;
      
      private var mPriceCash:int;
      
      private var mContractButton:DynamicButton;
      
      public function ItemService(param1:ServiceDefinition, param2:String)
      {
         var _loc3_:Sprite = null;
         var _loc4_:TextField = null;
         var _loc5_:TextField = null;
         var _loc6_:TextField = null;
         var _loc7_:TextField = null;
         var _loc8_:TextField = null;
         var _loc9_:TextFormat = null;
         var _loc10_:MovieClip = null;
         var _loc11_:TextField = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         super();
         this.mType = param2;
         this.mServiceDef = param1;
         if(this.mServiceDef.isAvailable())
         {
            this.mIsOffer = DollarsGame.getProfile().servicesIsOfferEnabled(this.mType);
            if(this.mIsOffer)
            {
               this.mPriceCoins = this.mServiceDef.getOfferPriceCoins();
               this.mPriceCash = this.mServiceDef.getOfferPriceCash();
               this.mPriceFBCredits = this.mServiceDef.getOfferPriceFBCredits();
            }
            else
            {
               this.mPriceCoins = this.mServiceDef.getPriceCoins();
               this.mPriceCash = this.mServiceDef.getPriceCash();
               this.mPriceFBCredits = this.mServiceDef.getPriceFBCredits();
            }
            this.mUseFBCredits = Config.FACEBOOK_CREDITS_AS_CURRENCY && DollarsGame.getProfile().DCCash < this.mPriceCash && this.mPriceFBCredits > 0;
            if(this.mType == Profile.SERVICES_MONEY_COLLECTOR_SKU)
            {
               if(this.mUseFBCredits)
               {
                  this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_collect_box_fbc"))();
               }
               else if(!this.mIsOffer || this.mPriceCoins == 0 && this.mPriceCash == 0)
               {
                  this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_collect_box_cash"))();
               }
               else
               {
                  this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_collect_box_offer"))();
               }
            }
            else if(this.mType == Profile.SERVICES_CONTRACT_SIGNATOR_SKU)
            {
               if(this.mUseFBCredits)
               {
                  this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_contract_box_fbc"))();
               }
               else if(!this.mIsOffer || this.mPriceCoins == 0 && this.mPriceCash == 0)
               {
                  this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_contract_box"))();
               }
               else
               {
                  this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_contract_box_offer"))();
               }
            }
            _loc3_ = this.mItem.getChildByName("best") as Sprite;
            if(this.mServiceDef.getContractId() > 0)
            {
               _loc3_.visible = false;
            }
            else
            {
               _loc8_ = _loc3_.getChildByName("best") as TextField;
               TextManager.reformatTextField(_loc8_);
               if(TextManager.smChangeFont && _loc8_.rotation != 0)
               {
                  _loc8_.rotation = 0;
                  _loc9_ = _loc8_.defaultTextFormat;
                  _loc9_.align = TextFormatAlign.CENTER;
                  _loc9_.size = int(_loc9_.size) - 2;
                  _loc8_.defaultTextFormat = _loc9_;
                  _loc8_.text = _loc8_.text;
                  TextManager.setTextScaled(_loc8_);
                  _loc8_.y -= 10;
               }
               _loc8_.text = TextManager.getText(TextIDs.TID_GEN_SPECIALOFFER);
            }
            if(!this.mUseFBCredits)
            {
               _loc10_ = this.mItem.getChildByName("gold") as MovieClip;
               _loc10_.stop();
               if(this.mPriceCash > 0)
               {
                  _loc10_.gotoAndStop(2);
               }
            }
            _loc4_ = this.mItem.getChildByName("days") as TextField;
            TextManager.reformatTextField(_loc4_);
            _loc4_.text = TextManager.convertTimeToString(this.mServiceDef.getTimeAvailable(),true,true);
            _loc5_ = this.mItem.getChildByName("mPrize") as TextField;
            _loc6_ = this.mItem.getChildByName("trial") as TextField;
            TextManager.reformatTextField(_loc6_);
            _loc6_.visible = false;
            if(this.mUseFBCredits && this.mPriceFBCredits > 0)
            {
               _loc5_.text = TextManager.convertNumberToString(this.mPriceFBCredits,TextManager.TRUNCATE_THOUSAND,6);
               if(this.mIsOffer)
               {
                  _loc7_ = this.mItem.getChildByName("mPrize_old") as TextField;
                  _loc7_.text = TextManager.convertNumberToString(this.mServiceDef.getPriceFBCredits(),TextManager.TRUNCATE_THOUSAND,6);
               }
               else
               {
                  this.mItem["mPrize_old"].visible = false;
                  this.mItem["old_prize_symbol"].visible = false;
               }
            }
            else if(this.mPriceCoins > 0)
            {
               _loc5_.text = TextManager.convertNumberToString(this.mPriceCoins,TextManager.TRUNCATE_THOUSAND,6);
               if(this.mIsOffer)
               {
                  _loc7_ = this.mItem.getChildByName("mPrize_old") as TextField;
                  _loc7_.text = TextManager.convertNumberToString(this.mServiceDef.getPriceCoins(),TextManager.TRUNCATE_THOUSAND,6);
               }
            }
            else if(this.mPriceCash > 0)
            {
               _loc5_.text = TextManager.convertNumberToString(this.mPriceCash,0,0);
               if(this.mIsOffer)
               {
                  _loc7_ = this.mItem.getChildByName("mPrize_old") as TextField;
                  _loc7_.text = TextManager.convertNumberToString(this.mServiceDef.getPriceCash(),0,0);
               }
            }
            else
            {
               _loc10_.visible = false;
               _loc5_.visible = false;
               _loc6_.visible = true;
               _loc6_.text = TextManager.getText(TextIDs.TID_FREE_TRIAL);
               TextManager.setTextScaled(_loc6_);
            }
         }
         else
         {
            if(this.mType == Profile.SERVICES_MONEY_COLLECTOR_SKU)
            {
               this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_collect_box_cash_locked"))();
            }
            else
            {
               this.mItem = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_contract_box_cash_locked"))();
            }
            _loc11_ = this.mItem.getChildByName("TopText") as TextField;
            TextManager.reformatTextField(_loc11_);
            _loc12_ = this.mServiceDef.getWaitingTimeLeft();
            _loc13_ = TimerUtil.msToDays(_loc12_);
            _loc14_ = TimerUtil.msToHour(_loc12_);
            if(_loc13_ == 0)
            {
               if(_loc12_ % TimerUtil.HOUR_TO_MS > 0)
               {
                  _loc14_++;
               }
               _loc14_ = TimerUtil.hourToMs(_loc14_);
               _loc11_.text = TextManager.replaceParameters(TextIDs.TID_AVAILABLE_IN,[TextManager.convertTimeToString(_loc14_,true,false)]);
            }
            else
            {
               if(_loc12_ % TimerUtil.DAY_TO_MS > 0)
               {
                  _loc13_++;
               }
               _loc13_ = TimerUtil.daysToMs(_loc13_);
               _loc11_.text = TextManager.replaceParameters(TextIDs.TID_AVAILABLE_IN,[TextManager.convertTimeToString(_loc13_,true,false)]);
            }
         }
         this.mContractButton = new DynamicButton(this.mItem.getChildByName("ContractButton") as MovieClip);
         this.mContractButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_CONTRACT));
         this.mContractButton.start();
         if(_loc3_ != null)
         {
            this.mItem.addChild(_loc3_);
         }
         if(this.mServiceDef.isAvailable())
         {
            this.mContractButton.addEventListener(MouseEvent.CLICK,this.onContract);
         }
         else
         {
            this.mContractButton.disable();
         }
         addChild(this.mItem);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         var _loc2_:String = null;
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.finishContract();
            if(this.mType == Profile.SERVICES_MONEY_COLLECTOR_SKU)
            {
               _loc2_ = MetricConstants.LABEL_ECONOMY_MONEY_COLLECTOR;
            }
            else if(this.mType == Profile.SERVICES_CONTRACT_SIGNATOR_SKU)
            {
               _loc2_ = MetricConstants.LABEL_ECONOMY_MULTICONTRACT;
            }
            else if(this.mType == Profile.SERVICES_MOVE_SKU)
            {
               _loc2_ = MetricConstants.LABEL_ECONOMY_CONTRACT_CRANE;
            }
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,_loc2_,null,null,null,0,this.mPriceFBCredits);
         }
      }
      
      private function finishContract() : void
      {
         DollarsGame.getProfile().servicesContract(this.mType,this.mServiceDef.getContractId());
         dispatchEvent(new Event(EVENT_CONTRACT));
      }
      
      public function destroy() : void
      {
         this.mContractButton.removeEventListener(MouseEvent.CLICK,this.onContract);
         this.mContractButton.destroy();
         this.mContractButton = null;
         removeChild(this.mItem);
         this.mItem = null;
      }
      
      private function onExchange(param1:Event) : void
      {
         this.onCancelExchange(null);
         this.onContract(null);
      }
      
      private function onContract(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && this.mUseFBCredits)
         {
            FBCreditsPurchase.getInstance().startPurchaseProcess(this);
         }
         else if(_loc2_.DCCoins < this.mPriceCoins && this.mPriceCoins > 0)
         {
            DollarsGame.smInstance.mPopupConfirm.startAskForHelpFBCredits(this.mPriceCoins);
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
            DollarsGame.smInstance.mPopupConfirm.addEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelExchange);
         }
         else if(_loc2_.DCCash < this.mPriceCash && this.mPriceCash > 0)
         {
            DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,this.mPriceCash);
         }
         else
         {
            _loc3_ = MetricConstants.LABEL_ECONOMY_MULTICONTRACT;
            if(this.mType == Profile.SERVICES_MONEY_COLLECTOR_SKU)
            {
               _loc3_ = MetricConstants.LABEL_ECONOMY_MONEY_COLLECTOR;
            }
            if(this.mPriceCash > 0)
            {
               _loc2_.delayedPaymentSetGold(this.mPriceCash,_loc3_);
            }
            else
            {
               _loc2_.delayedPaymentSetCoins(this.mPriceCoins,_loc3_);
            }
            this.finishContract();
         }
      }
      
      public function buyWithCredits() : Object
      {
         var _loc1_:String = FBCreditsPurchase.TYPE_RENT_TOOL;
         if(this.mIsOffer)
         {
            _loc1_ = FBCreditsPurchase.TYPE_RENT_TOOL_OFFER;
         }
         return {
            "price":this.mPriceFBCredits,
            "orderInfo":{
               "type":_loc1_,
               "sku":this.mServiceDef.sku
            }
         };
      }
      
      private function onCancelExchange(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_EXCHANGE,this.onExchange);
         DollarsGame.smInstance.mPopupConfirm.removeEventListener(PopupConfirm.EVENT_CANCEL,this.onCancelExchange);
      }
   }
}

