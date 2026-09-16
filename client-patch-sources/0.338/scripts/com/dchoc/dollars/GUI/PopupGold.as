package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.CheckCRMEvent;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.metrics.PaymentManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
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
   
   public class PopupGold extends Popup
   {
      
      private static var mFBCredits:Dictionary;
      
      private static var mFBNormalIds:Array;
      
      private var mContinueButton:DynamicButton;
      
      private var mItems:Array;
      
      private var mCurrentItem:int;
      
      private var mBest:Sprite;
      
      private var mSecure:Sprite;
      
      private var mTitle:TextField;
      
      private var mSecureTip:TipBox;
      
      private var mTimerSpr:Sprite;
      
      private var mTimerText:TextField;
      
      private var mBestIndex:int;
      
      private var mBestY:Number;
      
      public var mPopupOpen:Boolean;
      
      private const NUM_FB_ITEMS:uint = 6;
      
      private const XINIT:Number = -186.7;
      
      private var YINIT:Number = -173.3;
      
      private const YOFFSET:Number = 55;
      
      private var mNumExtra:int = PaymentManager.getInstance().paymentCount;
      
      public function PopupGold()
      {
         this.load();
         if(mFBCredits == null)
         {
            this.fbCreditsLoad();
         }
         super();
      }
      
      private function load() : void
      {
         var format:TextFormat = null;
         if(Config.USE_OFFERPAL_IN_POPUP_GOLD)
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
         var bestText:TextField = TextField(this.mBest.getChildByName("best"));
         this.mBestY = this.mBest.y;
         TextManager.reformatTextField(bestText);
         bestText.multiline = true;
         bestText.wordWrap = true;
         bestText.text = TextManager.getText(TextIDs.TID_POPUP_GOLD_BEST_VALUE);
         if(TextManager.smChangeFont && bestText.rotation != 0)
         {
            bestText.rotation = 0;
            format = bestText.defaultTextFormat;
            format.align = TextFormatAlign.CENTER;
            format.size = int(format.size) - 2;
            bestText.defaultTextFormat = format;
            bestText.text = bestText.text;
            TextManager.setTextScaled(bestText);
            bestText.y -= 10;
         }
         this.mTitle = TextField(mBox.getChildByName("TextInfo"));
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.rtlText(TextManager.getText(TextIDs.TID_POPUP_GOLD_TEXT1));
         TextManager.reformatTextField(TextField(mBox.getChildByName("facebook")));
         TextField(mBox.getChildByName("facebook")).text = TextManager.getText(TextIDs.TID_POPUP_GOLD_TEXT2);
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
      
      private function fbCreditsLoadOnComplete(e:Event) : void
      {
         var fbc:XML = null;
         var fbcObj:Object = null;
         var sku:String = null;
         var checkCRM:Boolean = false;
         var loader:URLLoader = URLLoader(e.target);
         loader.removeEventListener(Event.COMPLETE,this.fbCreditsLoadOnComplete);
         var fbcredits:XML = new XML(loader.data);
         mFBCredits = new Dictionary(true);
         mFBNormalIds = new Array();
         for each(fbc in fbcredits.Definition)
         {
            fbcObj = new Object();
            sku = fbc.@item_id;
            fbcObj.sku = sku;
            fbcObj.gold = int(fbc.@gold);
            fbcObj.dollars = Number(fbc.@dolars).toFixed(2).replace(".",TextManager.getText(TextIDs.TID_DECIMAL_DELIMETER));
            fbcObj.freeGold = String(fbc.@freeGold);
            if("@priceOld" in fbc)
            {
               fbcObj.dollarsOld = Number(fbc.@priceOld).toFixed(2).replace(".",TextManager.getText(TextIDs.TID_DECIMAL_DELIMETER));
            }
            else
            {
               fbcObj.dollarsOld = "";
            }
            fbcObj.freeGoldOld = String(fbc.@freeGoldOld);
            checkCRM = false;
            if("@checkCRM" in fbc)
            {
               checkCRM = int(fbc.@checkCRM) == 1;
            }
            fbcObj.checkCRM = checkCRM;
            if(!checkCRM)
            {
               mFBNormalIds.push(sku);
            }
            mFBCredits[sku] = fbcObj;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         if(CheckCRMEvent.getInstance().crmOfferState != CheckCRMEvent.CRM_OFFER_GOLD_OFFER)
         {
            this.mTimerSpr.visible = false;
         }
         startShow();
         this.getItems();
         mBox.addChild(this.mBest);
         mBox.addChild(this.mSecure);
         this.mBest.y = this.mBestY + this.mBestIndex * this.YOFFSET;
         MyMetrics.sendMetric(MetricConstants.EVENT_ADD_GOLD,MetricConstants.LABEL_ECONOMY_ADD_GOLD_STARTED);
         this.mPopupOpen = true;
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
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mContinueButton.end();
         this.mContinueButton.removeEventListener(MouseEvent.CLICK,this.onContinue);
         this.mSecure.removeEventListener(MouseEvent.MOUSE_OVER,this.showTip);
         this.mSecure.removeEventListener(MouseEvent.MOUSE_OUT,this.hideTip);
      }
      
      override protected function close() : void
      {
         super.close();
         var dollarsGame:DollarsGame = DollarsGame.smInstance;
         if(!dollarsGame.mShopIsOpen)
         {
            dollarsGame.mShowPopup = false;
         }
         dollarsGame.mPopupClip.removeChild(mBox);
         this.removeItems();
         this.mPopupOpen = false;
      }
      
      private function onContinue(e:MouseEvent) : void
      {
         var item:ItemPopupGold = this.mItems[this.mCurrentItem];
         var fbObject:Object = item.fbObject;
         onClose(null);
         if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            Dollars.smStage.displayState = StageDisplayState.NORMAL;
         }
         var paramMetrics:Object = new Object();
         if(fbObject != null)
         {
            DollarsGame.getCurrentWorld().getCompanyMine().DCCash += uint(fbObject.gold) + uint(fbObject.freeGold);
            UserDataFacade.getInstance().updateMoney("buyGold",{"sku":String(fbObject.sku)});
            paramMetrics.p1 = "fb_" + fbObject.sku;
         }
         else
         {
            if(Config.USE_OFFERPAL_EXTRA_OPTIONS)
            {
               PaymentManager.getInstance().getOptions(item.extraOptionIndex);
            }
            else
            {
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_CASH_SHOP,{"currencyId":"gold"});
            }
            paramMetrics.p1 = "offerpal";
         }
         MyMetrics.sendMetric(MetricConstants.EVENT_ADD_GOLD,MetricConstants.LABEL_ECONOMY_ADD_GOLD_CONTINUE,paramMetrics);
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
            if(CheckCRMEvent.getInstance().crmOfferState == CheckCRMEvent.CRM_OFFER_GOLD_OFFER)
            {
               optionIds = CheckCRMEvent.getInstance().crmOfferIds;
            }
            else
            {
               optionIds = mFBNormalIds;
            }
            optionsFBCount = 0;
            if(optionIds != null)
            {
               optionsFBCount = int(optionIds.length);
            }
            numItems = optionsFBCount;
            if(Config.USE_OFFERPAL_IN_POPUP_GOLD)
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
            for(i = 0; i < numItems; i++)
            {
               option = null;
               if(i < optionsFBCount)
               {
                  if(CheckCRMEvent.getInstance().crmOfferState == CheckCRMEvent.CRM_OFFER_GOLD_OFFER)
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
               if(Boolean(CheckCRMEvent.getInstance().crmOfferState == CheckCRMEvent.CRM_OFFER_GOLD_OFFER && option != null) && Boolean(optionIds[i].hasOwnProperty("best")) && Boolean(optionIds[i].best))
               {
                  this.mBestIndex = i;
               }
               if(Config.USE_OFFERPAL_IN_POPUP_GOLD && Config.USE_OFFERPAL_EXTRA_OPTIONS && option == null)
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
      
      private function removeItems() : void
      {
         var item:ItemPopupGold = null;
         for(var i:int = 0; i < this.mItems.length; i++)
         {
            item = this.mItems[i];
            item.destroy();
            item.removeEventListener(MouseEvent.CLICK,this.selectItem);
            mBox.removeChild(item);
            item = null;
            this.mItems[i] = null;
         }
         this.mItems = null;
      }
      
      private function selectItem(e:MouseEvent) : void
      {
         var item:ItemPopupGold = e.target as ItemPopupGold;
         if(this.mItems.indexOf(item) != this.mCurrentItem)
         {
            this.mItems[this.mCurrentItem].unselect();
            this.mCurrentItem = this.mItems.indexOf(item);
            this.mItems[this.mCurrentItem].select();
         }
      }
      
      private function showTip(e:MouseEvent) : void
      {
         this.mSecureTip.visible = true;
      }
      
      private function hideTip(e:MouseEvent) : void
      {
         this.mSecureTip.visible = false;
      }
      
      public function setTimer(time:String) : void
      {
         this.mTimerText.text = time;
      }
   }
}

