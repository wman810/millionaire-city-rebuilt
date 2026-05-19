package com.dchoc.dollars.GUI.bundles
{
   import com.dchoc.dollars.GUI.PopupExtended;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.WelcomeProgress;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.BundleDefinition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormatAlign;
   
   public class PopupConfirmBundle extends PopupExtended implements FBCreditsPurchaseInterface
   {
      
      private var mDescription:TextField;
      
      private var mDef:BundleDefinition;
      
      private var mPrice:int;
      
      public function PopupConfirmBundle(param1:BundleDefinition)
      {
         var _loc2_:String = null;
         var _loc3_:Function = null;
         var _loc4_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mDef = param1;
         super();
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            _loc2_ = "button_fc_icon_offer";
            _loc3_ = this.onBuyFBC;
            this.mPrice = this.mDef.getConstructionFBCredits();
         }
         else
         {
            _loc2_ = "button_gold_icon_offer";
            _loc3_ = this.onBuyCash;
            this.mPrice = this.mDef.getConstructionCash();
         }
         setTitle(param1.getCRMDefinition().title);
         var _loc5_:MovieClip = this.createContent();
         addContentElement(_loc5_);
         addButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUTTON_LIBRARY,_loc2_))(),[this.mDef.getOriginalPrice(),this.mPrice],_loc3_);
         this.showPopup();
      }
      
      private function onBuyFBC(param1:MouseEvent) : void
      {
         FBCreditsPurchase.getInstance().startPurchaseProcess(this);
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.completeBuy();
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_ITEM,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
            if(DollarsGame.smInstance.mBuyBox.getSelectedTab() == "featured")
            {
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_ITEM_SPECIALS,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
            }
            else if(DollarsGame.smInstance.mBuyBox.getSelectedTab() == "new_items")
            {
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_ITEM_WEEK,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
            }
         }
      }
      
      override protected function close() : void
      {
         super.close();
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
            if(this.mDef.getCRMDefinition().actionButtonAction != null && DollarsGame.smInstance.mWelcomProgress != null)
            {
               DollarsGame.smInstance.mWelcomProgress.dispatchEvent(new Event(WelcomeProgress.EVENT_WELCOME_END));
            }
         }
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function completeBuy() : void
      {
         var _loc2_:Array = null;
         DollarsGame.getCurrentWorld().getCompanyMine().exp = DollarsGame.getCurrentWorld().getCompanyMine().exp + this.mDef.getExperience();
         UserDataFacade.getInstance().updateMoney("buy_bundle",{"sku":this.mDef.sku});
         var _loc1_:Array = this.mDef.getItemList();
         for each(_loc2_ in _loc1_)
         {
            StorageManager.getInstance().addItem(_loc2_[BundleDefinition.LIST_ITEM_SKU],_loc2_[BundleDefinition.LIST_ITEM_QUANTITY]);
         }
         onClose(null);
         mAccepted = true;
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":this.mPrice,
            "orderInfo":{
               "sku":this.mDef.sku,
               "type":FBCreditsPurchase.TYPE_BUY_BUNDLE
            }
         };
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow(false);
      }
      
      private function onBuyCash(param1:MouseEvent) : void
      {
         if(DollarsGame.getCurrentWorld().getCompanyMine().DCCash < this.mPrice)
         {
            DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,this.mPrice);
         }
         else
         {
            DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash - this.mPrice;
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_ITEM,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
            if(DollarsGame.smInstance.mBuyBox.getSelectedTab() == "featured")
            {
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_ITEM_SPECIALS,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
            }
            else if(DollarsGame.smInstance.mBuyBox.getSelectedTab() == "new_items")
            {
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_ITEM_WEEK,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
            }
            this.completeBuy();
         }
      }
      
      private function onBuyCoins(param1:MouseEvent) : void
      {
         DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins - this.mPrice;
         MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,MetricConstants.LABEL_ECONOMY_BUY_ITEM,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
         if(DollarsGame.smInstance.mBuyBox.getSelectedTab() == "featured")
         {
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,MetricConstants.LABEL_ECONOMY_BUY_ITEM_SPECIALS,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
         }
         else if(DollarsGame.smInstance.mBuyBox.getSelectedTab() == "new_items")
         {
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_MONEY,MetricConstants.LABEL_ECONOMY_BUY_ITEM_WEEK,MetricConstants.PRODUCT_BUNDLE,this.mDef.sku,null,0,this.mPrice);
         }
         this.completeBuy();
      }
      
      private function createContent() : MovieClip
      {
         var _loc1_:Sprite = this.mDef.getBuildObject("normal");
         var _loc2_:ItemDefinition = this.mDef.getItemDefinition(0);
         var _loc3_:Number = 300;
         var _loc4_:Number = _loc1_.height > 250 ? 250 : _loc1_.height;
         var _loc5_:MovieClip = new MovieClip();
         _loc5_.graphics.beginFill(255,0);
         _loc5_.graphics.drawRect(0,0,_loc3_,_loc4_);
         _loc5_.graphics.endFill();
         var _loc6_:Object = this.mDef.getIcon(_loc5_,true);
         var _loc7_:Bitmap = new Bitmap(DCResourceManager.getInstance().get("popup_stars"));
         var _loc8_:TextField = getTextField(PopupExtended.RESOURCE_CLASS_NAME_TEXT_TITLE,25,TextFormatAlign.CENTER);
         _loc8_.text = this.mDef.getCRMDefinition().text;
         _loc8_.y = _loc1_.height;
         if(_loc8_.width > _loc7_.width)
         {
            _loc7_.x = (_loc8_.width - _loc7_.width) / 2;
            _loc6_.icon.x = (_loc8_.width - this.mDef.getItemDefinition(0).baseWidth) / 2;
         }
         else
         {
            _loc8_.x = (_loc7_.width - _loc8_.width) / 2;
         }
         var _loc9_:MovieClip = new MovieClip();
         _loc9_.addChild(_loc7_);
         _loc9_.addChild(_loc6_.icon);
         _loc9_.addChild(_loc8_);
         return _loc9_;
      }
   }
}

