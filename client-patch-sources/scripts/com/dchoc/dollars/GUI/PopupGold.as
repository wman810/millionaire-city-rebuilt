package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.metrics.PaymentManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   
   public class PopupGold extends Popup implements FBCreditsPurchaseInterface
   {
      
      private static var mFBNormalIds:Array;
      
      private static var mFBCredits:Dictionary;
      
      private var mContinueButton:DynamicButton;
      
      private var mBestY:Number;
      
      private const NUM_FB_ITEMS:uint = 6;
      
      private var mTimerText:TextField;
      
      public var mPopupOpen:Boolean;
      
      private var mNumExtra:int = PaymentManager.getInstance().paymentCount;
      
      private const YOFFSET:Number = 55;
      
      private var mTimerSpr:Sprite;
      
      private var mSecureTip:TipBox;
      
      private var mSecure:Sprite;
      
      private var mItems:Array;
      
      private var mBestIndex:int;
      
      private const XINIT:Number = -186.7;
      
      private var YINIT:Number = -173.3;
      
      private var mTitle:TextField;
      
      private var mBest:Sprite;
      
      private var mCurrentItem:int;
      
      public function PopupGold()
      {
         this.load();
         if(mFBCredits == null)
         {
            this.fbCreditsLoad();
         }
         super();
      }
      
      public function setTimer(param1:String) : void
      {
         this.mTimerText.text = param1;
      }
      
      private function getItems() : void
      {
         var optionIds:Array = null;
         var optionsFBCount:int = 0;
         var numItems:int = 0;
         var offerpalIndex:int = 0;
         var i:int = 0;
         var option:Object = null;
         var item:ItemPopupGold = null;
         try
         {
            this.mItems = new Array();
            optionIds = mFBNormalIds;
            if(CustomizerManager.getInstance().crmOfferState == CustomizerManager.CRM_OFFER_ENABLED && CustomizerManager.getInstance().crmOfferIds != null)
            {
               optionIds = CustomizerManager.getInstance().crmOfferIds;
            }
            optionsFBCount = 0;
            if(optionIds != null)
            {
               optionsFBCount = int(optionIds.length);
            }
            numItems = optionsFBCount;
            if(!Config.FACEBOOK_CREDITS_TO_BUY_GOLD && Config.USE_OFFERPAL_IN_POPUP_GOLD)
            {
               if(Config.USE_OFFERPAL_EXTRA_OPTIONS && PaymentManager.getInstance().paymentCount > 0)
               {
                  numItems += PaymentManager.getInstance().paymentCount;
               }
               else if(!Config.USE_OFFERPAL_EXTRA_OPTIONS)
               {
                  numItems += 1;
               }
            }
            offerpalIndex = PaymentManager.getInstance().initIndex;
            i = 0;
            while(i < numItems)
            {
               option = null;
               if(i < optionsFBCount)
               {
                  if(CustomizerManager.getInstance().crmOfferState == CustomizerManager.CRM_OFFER_ENABLED && CustomizerManager.getInstance().crmOfferIds != null)
                  {
                     option = mFBCredits[optionIds[i].priceId];
                  }
                  else
                  {
                     option = mFBCredits[optionIds[i]];
                  }
               }
               if(option == null && !Config.USE_OFFERPAL_IN_POPUP_GOLD)
               {
                  break;
               }
               if(Boolean(CustomizerManager.getInstance().crmOfferState == CustomizerManager.CRM_OFFER_ENABLED && option != null) && Boolean(optionIds[i].hasOwnProperty("best")) && Boolean(optionIds[i].best))
               {
                  this.mBestIndex = i;
               }
               if(!Config.FACEBOOK_CREDITS_TO_BUY_GOLD && Config.USE_OFFERPAL_IN_POPUP_GOLD && Config.USE_OFFERPAL_EXTRA_OPTIONS && option == null)
               {
                  item = new ItemPopupGold(option,offerpalIndex);
                  offerpalIndex++;
               }
               else
               {
                  item = new ItemPopupGold(option);
               }
               item.x = this.XINIT;
               item.y = this.YINIT + this.YOFFSET * i;
               mBox.addChild(item);
               item.addEventListener(MouseEvent.CLICK,this.selectItem);
               this.mItems.push(item);
               i++;
            }
            this.mCurrentItem = 0;
            this.mItems[0].select();
         }
         catch(e:Error)
         {
            Debug.trace("getItems error message: " + e.message);
            Debug.trace(e.getStackTrace());
         }
      }
      
      public function buyWithCredits() : Object
      {
         var _loc1_:ItemPopupGold = this.mItems[this.mCurrentItem];
         var _loc2_:String = FBCreditsPurchase.TYPE_BUY_GOLD;
         return {
            "price":_loc1_.fbObject.credits,
            "orderInfo":{
               "type":_loc2_,
               "sku":_loc1_.fbObject.sku
            }
         };
      }
      
      private function fbCreditsLoadOnComplete(param1:Event) : void
      {
         var _loc4_:XML = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.fbCreditsLoadOnComplete);
         var _loc3_:XML = new XML(_loc2_.data);
         mFBCredits = new Dictionary(true);
         mFBNormalIds = new Array();
         for each(_loc4_ in _loc3_.Definition)
         {
            _loc5_ = new Object();
            _loc6_ = _loc4_.@item_id;
            _loc5_.sku = _loc6_;
            _loc5_.gold = int(_loc4_.@gold);
            if(Config.FACEBOOK_CREDITS_TO_BUY_GOLD)
            {
               _loc5_.credits = int(_loc4_.@fb_credits);
            }
            else
            {
               _loc5_.credits = Number(_loc4_.@dolars).toFixed(2).replace(".",TextManager.getText(TextIDs.TID_DECIMAL_DELIMETER));
            }
            _loc5_.freeGold = String(_loc4_.@freeGold);
            if("@priceOld" in _loc4_)
            {
               _loc5_.creditsOld = int(_loc4_.@priceOld);
            }
            else
            {
               _loc5_.creditsOld = "";
            }
            _loc5_.freeGoldOld = String(_loc4_.@freeGoldOld);
            _loc7_ = false;
            if("@checkCRM" in _loc4_)
            {
               _loc7_ = int(_loc4_.@checkCRM) == 1;
            }
            _loc5_.checkCRM = _loc7_;
            if(!_loc7_)
            {
               mFBNormalIds.push(_loc6_);
            }
            mFBCredits[_loc6_] = _loc5_;
         }
      }
      
      private function removeItems() : void
      {
         var _loc2_:ItemPopupGold = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.mItems.length)
         {
            _loc2_ = this.mItems[_loc1_];
            _loc2_.destroy();
            _loc2_.removeEventListener(MouseEvent.CLICK,this.selectItem);
            mBox.removeChild(_loc2_);
            _loc2_ = null;
            this.mItems[_loc1_] = null;
            _loc1_++;
         }
         this.mItems = null;
      }
      
      private function onContinue(param1:MouseEvent) : void
      {
         if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            Dollars.smStage.displayState = StageDisplayState.NORMAL;
         }
         FBCreditsPurchase.getInstance().startPurchaseProcess(this,false);
         MyMetrics.sendMetricNG(MetricConstants.EVENT_ADD_GOLD,MetricConstants.LABEL_ECONOMY_ADD_GOLD_CONTINUE,MetricConstants.PRODUCT_GOLD);
      }
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mContinueButton.end();
         this.mContinueButton.removeEventListener(MouseEvent.CLICK,this.onContinue);
         this.mSecure.removeEventListener(MouseEvent.MOUSE_OVER,this.showTip);
         this.mSecure.removeEventListener(MouseEvent.MOUSE_OUT,this.hideTip);
      }
      
      override public function showPopup() : void
      {
         super.show();
         if(CustomizerManager.getInstance().crmOfferState != CustomizerManager.CRM_OFFER_ENABLED)
         {
            this.mTimerSpr.visible = false;
         }
         startShow();
         this.getItems();
         mBox.addChild(this.mBest);
         mBox.addChild(this.mSecure);
         this.mBest.y = this.mBestY + this.mBestIndex * this.YOFFSET;
         MyMetrics.sendMetricNG(MetricConstants.EVENT_ADD_GOLD,MetricConstants.LABEL_ECONOMY_ADD_GOLD_STARTED,MetricConstants.PRODUCT_GOLD);
         this.mPopupOpen = true;
      }
      
      private function selectItem(param1:MouseEvent) : void
      {
         var _loc2_:ItemPopupGold = param1.target as ItemPopupGold;
         if(this.mItems.indexOf(_loc2_) != this.mCurrentItem)
         {
            this.mItems[this.mCurrentItem].unselect();
            this.mCurrentItem = this.mItems.indexOf(_loc2_);
            this.mItems[this.mCurrentItem].select();
         }
      }
      
      override protected function startButtons() : void
      {
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mContinueButton.start();
         this.mContinueButton.addEventListener(MouseEvent.CLICK,this.onContinue);
         this.mSecure.addEventListener(MouseEvent.MOUSE_OVER,this.showTip);
         this.mSecure.addEventListener(MouseEvent.MOUSE_OUT,this.hideTip);
      }
      
      private function fbCreditsLoad() : void
      {
         var request:URLRequest;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.fbCreditsLoadOnComplete);
         request = new URLRequest(Config.getRoot() + ModelConfig.FBCREDITS_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load " + Config.getRoot() + ModelConfig.FBCREDITS_XML_FILE + " document.");
         }
      }
      
      private function showTip(param1:MouseEvent) : void
      {
         this.mSecureTip.visible = true;
      }
      
      private function load() : void
      {
         var _loc2_:TextFormat = null;
         if(!Config.FACEBOOK_CREDITS_TO_BUY_GOLD && Config.USE_OFFERPAL_IN_POPUP_GOLD)
         {
            if(Config.USE_OFFERPAL_EXTRA_OPTIONS && this.mNumExtra > 1)
            {
               mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value_offer_02"))();
               this.YINIT = -213.3;
            }
            else if(Config.USE_OFFERPAL_EXTRA_OPTIONS && this.mNumExtra > 0)
            {
               mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value_offer"))();
               this.YINIT = -213.3;
            }
            else
            {
               mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value"))();
            }
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value"))();
         }
         this.mTimerSpr = mBox.getChildByName("timer") as Sprite;
         this.mTimerText = this.mTimerSpr.getChildByName("timertext") as TextField;
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         this.mContinueButton = new DynamicButton(mBox.getChildByName("ContinueButton") as MovieClip);
         this.mContinueButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_CONTINUE));
         this.mSecure = mBox.getChildByName("secure") as Sprite;
         this.mSecureTip = new TipBox(TextManager.getText(TextIDs.TID_TOOLTIP_FB_CREDITS));
         this.mSecure.addChild(this.mSecureTip);
         this.mSecureTip.y = -this.mSecureTip.height / 2;
         this.mSecureTip.visible = false;
         this.mBest = mBox.getChildByName("best") as Sprite;
         var _loc1_:TextField = TextField(this.mBest.getChildByName("best"));
         this.mBestY = this.mBest.y;
         TextManager.reformatTextField(_loc1_);
         _loc1_.multiline = true;
         _loc1_.wordWrap = true;
         _loc1_.text = TextManager.getText(TextIDs.TID_POPUP_GOLD_BEST_VALUE);
         if(TextManager.smChangeFont && _loc1_.rotation != 0)
         {
            _loc1_.rotation = 0;
            _loc2_ = _loc1_.defaultTextFormat;
            _loc2_.align = TextFormatAlign.CENTER;
            _loc2_.size = int(_loc2_.size) - 2;
            _loc1_.defaultTextFormat = _loc2_;
            _loc1_.text = _loc1_.text;
            TextManager.setTextScaled(_loc1_);
            _loc1_.y -= 10;
         }
         this.mTitle = TextField(mBox.getChildByName("TextInfo"));
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_POPUP_GOLD_TEXT1));
         TextManager.reformatTextField(TextField(mBox.getChildByName("facebook")));
         TextField(mBox.getChildByName("facebook")).text = TextManager.getText(TextIDs.TID_POPUP_GOLD_TEXT2);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         var _loc2_:Company = null;
         var _loc3_:ItemPopupGold = null;
         var _loc4_:int = 0;
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
            _loc3_ = this.mItems[this.mCurrentItem];
            _loc4_ = _loc3_.fbObject.gold + int(_loc3_.fbObject.freeGold);
            _loc2_.DCCash += _loc4_;
            UserDataFacade.getInstance().updateMoney("buyGold",{"sku":_loc3_.fbObject.sku});
            MyMetrics.sendMetricNG(MetricConstants.EVENT_ADD_GOLD,MetricConstants.LABEL_ECONOMY_ADD_GOLD_CONFIRMED,MetricConstants.PRODUCT_GOLD,"" + _loc4_,null,0,_loc3_.fbObject.credits);
            onClose(null);
         }
      }
      
      override protected function close() : void
      {
         super.close();
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         if(!_loc1_.mShopIsOpen)
         {
            _loc1_.mShowPopup = false;
         }
         _loc1_.mPopupClip.removeChild(mBox);
         this.removeItems();
         this.mPopupOpen = false;
      }
      
      private function hideTip(param1:MouseEvent) : void
      {
         this.mSecureTip.visible = false;
      }
   }
}

