package com.dchoc.dollars.GUI.hireCrew
{
   import com.dchoc.dollars.GUI.PopupExtended;
   import com.dchoc.dollars.crewMechanics.CrewMechanicsManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.notifications.NotificationConstructionEnd;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import flash.text.Font;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class PopupHireCrew extends PopupExtended implements FBCreditsPurchaseInterface
   {
      
      private static const ITEMS_PER_ROW:int = 4;
      
      private static const MARGIN:Number = 10;
      
      private static const STATUS_UNCOMPLETED:int = 0;
      
      private static const STATUS_COMPLETED:int = 1;
      
      private var mCrewCount:int;
      
      private var mPriceSingle:int;
      
      private var mStatus:int;
      
      private var mDescription:TextField;
      
      private var mPriceAll:int;
      
      private var mBuyButtonIndex:int;
      
      private var mCrew:Array;
      
      private var mEmptySlots:int;
      
      private var mItemObject:ItemObject;
      
      public function PopupHireCrew(param1:ItemObject)
      {
         var _loc4_:CrewItemContent = null;
         var _loc8_:FriendObject = null;
         this.mItemObject = param1;
         this.mStatus = PopupHireCrew.STATUS_COMPLETED;
         super();
         this.mCrew = new Array();
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:Array = this.mItemObject.getCrewBought();
         var _loc6_:Array = this.mItemObject.getCrewHired();
         this.mCrewCount = CrewMechanicsManager.getInstance().getCrewCount(this.mItemObject.getConstructionCrewSku());
         this.mPriceSingle = CrewMechanicsManager.getInstance().getCrewPrice(this.mItemObject.getConstructionCrewSku(),Config.FACEBOOK_CREDITS_AS_CURRENCY);
         var _loc7_:int = 0;
         while(_loc7_ < this.mCrewCount)
         {
            if(_loc5_.indexOf(_loc7_) > -1)
            {
               _loc4_ = new CrewItemContent(this.mItemObject,CrewItemContent.CREW_BOUGHT,null,_loc7_,this.mPriceSingle);
            }
            else if(_loc3_ < _loc6_.length)
            {
               _loc8_ = FriendsManager.getFriendByID(_loc6_[_loc3_]);
               _loc4_ = new CrewItemContent(this.mItemObject,CrewItemContent.CREW_HIRED,_loc8_,_loc7_,this.mPriceSingle);
               _loc3_++;
            }
            else
            {
               _loc4_ = new CrewItemContent(this.mItemObject,CrewItemContent.CREW_FREE,null,_loc7_,this.mPriceSingle);
               this.mStatus = PopupHireCrew.STATUS_UNCOMPLETED;
            }
            this.mCrew.push(_loc4_);
            _loc7_++;
         }
         this.drawCrew();
         this.drawButtons(false);
         if(PriorityLoader.getInstance().isLoaded(param1.itemDefinition.getSkuToLoad() + "_icon"))
         {
            setIcon(new Bitmap(DCResourceManager.getInstance().get(param1.itemDefinition.getSkuToLoad() + "_icon")));
         }
         setTitle(TextManager.getText(TextIDs[this.mItemObject.itemDefinition.textID]));
         showPopup();
      }
      
      private function drawCrew() : void
      {
         var _loc2_:CrewItemContent = null;
         var _loc1_:Number = 0;
         this.mDescription = new TextField();
         var _loc3_:Font = new AssetManager.HelveticaRounded() as Font;
         var _loc4_:String = _loc3_.fontName;
         this.mDescription.embedFonts = true;
         if(TextManager.smChangeFont)
         {
            this.mDescription.embedFonts = false;
            _loc4_ = TextManager.ARIAL_UNICODE_FONT;
         }
         var _loc5_:TextFormat = new TextFormat(_loc4_,32,78659);
         _loc5_.align = TextFormatAlign.CENTER;
         _loc5_.size = 14;
         this.mDescription.defaultTextFormat = _loc5_;
         this.mDescription.selectable = false;
         this.mDescription.autoSize = TextFieldAutoSize.LEFT;
         var _loc6_:int = PopupHireCrew.ITEMS_PER_ROW;
         if(this.mCrewCount < _loc6_)
         {
            _loc6_ = this.mCrewCount;
         }
         this.mDescription.width = _loc6_ * (this.mCrew[0].width + PopupHireCrew.MARGIN);
         this.mDescription.wordWrap = true;
         if(this.mStatus == PopupHireCrew.STATUS_COMPLETED)
         {
            this.mDescription.text = TextManager.getText(TextIDs.TID_CREW_01_HIRE_ACHIEVED);
         }
         else
         {
            this.mDescription.text = TextManager.getText(TextIDs.TID_CREW_01_HIRE_DESCRIPTION);
         }
         this.mDescription.x = 0;
         this.mDescription.y = 0;
         addContentElement(this.mDescription);
         var _loc7_:int = 0;
         while(_loc7_ < this.mCrew.length)
         {
            _loc2_ = this.mCrew[_loc7_];
            _loc2_.x = _loc2_.width / 2 + (_loc2_.width + PopupHireCrew.MARGIN) * (_loc7_ % PopupHireCrew.ITEMS_PER_ROW);
            _loc2_.y = this.mDescription.height + _loc2_.height / 2 + (_loc2_.height + PopupHireCrew.MARGIN) * int(_loc7_ / PopupHireCrew.ITEMS_PER_ROW);
            addContentElement(_loc2_);
            _loc7_++;
         }
      }
      
      override public function logicUpdate(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(this.mStatus == PopupHireCrew.STATUS_UNCOMPLETED)
         {
            _loc2_ = this.mCrewCount - (this.mItemObject.getCrewBought().length + this.mItemObject.getCrewHired().length);
            if(_loc2_ != this.mEmptySlots)
            {
               this.mEmptySlots = _loc2_;
               if(this.mEmptySlots == 0)
               {
                  this.mStatus = PopupHireCrew.STATUS_COMPLETED;
                  this.drawButtons(true);
               }
               else
               {
                  this.setCompletePrice();
               }
            }
         }
      }
      
      private function completeCrew() : void
      {
         var _loc2_:CrewItemContent = null;
         var _loc3_:int = 0;
         var _loc1_:String = "";
         for each(_loc2_ in this.mCrew)
         {
            if(_loc2_.getStatus() == CrewItemContent.CREW_FREE)
            {
               _loc3_ = _loc2_.buyCrew(false);
               if(_loc1_ != "")
               {
                  _loc1_ += ",";
               }
               _loc1_ += _loc3_;
            }
         }
         UserDataFacade.getInstance().updateItem(this.mItemObject.sid,"buy_crew",{
            "sku":_loc1_.length,
            "position":_loc1_
         });
      }
      
      private function onHire(param1:MouseEvent) : void
      {
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_CREW_REQUEST,{"sid":this.mItemObject.sid});
      }
      
      private function setCompletePrice() : void
      {
         this.mEmptySlots = this.mCrewCount - (this.mItemObject.getCrewBought().length + this.mItemObject.getCrewHired().length);
         this.mPriceAll = this.mEmptySlots * this.mPriceSingle;
         setButtonLabel(this.mBuyButtonIndex,"" + this.mPriceAll);
      }
      
      private function drawButtons(param1:Boolean) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            removeAllButtons();
         }
         if(this.mStatus == PopupHireCrew.STATUS_COMPLETED)
         {
            this.changeDescriptionText(TextManager.getText(TextIDs.TID_CREW_01_HIRE_ACHIEVED));
            addButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUTTON_LIBRARY,"button_possitive"))(),[TextManager.getText(TextIDs.TID_COMPLETE)],this.onComplete);
         }
         else
         {
            _loc2_ = "button_gold_icon";
            if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
            {
               _loc2_ = "button_fc_icon";
            }
            this.mBuyButtonIndex = addButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUTTON_LIBRARY,_loc2_))(),[""],this.onBuy);
            addButton(new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUTTON_LIBRARY,"button_possitive"))(),[TextManager.getText(TextIDs.TID_HIRE_FRIENDS)],this.onHire);
            this.setCompletePrice();
         }
         if(param1)
         {
            startButtons();
         }
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.completeCrew();
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_CREW,MetricConstants.PRODUCT_CREW,"quantity: " + this.mEmptySlots,null,0,this.mPriceAll);
         }
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":this.mPriceAll,
            "orderInfo":{
               "sku":this.mItemObject.itemDefinition.sku,
               "qty":this.mEmptySlots,
               "type":FBCreditsPurchase.TYPE_BUY_CREW
            }
         };
      }
      
      private function onBuy(param1:MouseEvent) : void
      {
         var _loc2_:Company = null;
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            FBCreditsPurchase.getInstance().startPurchaseProcess(this);
         }
         else
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine();
            if(_loc2_.DCCash < this.mPriceAll)
            {
               DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,this.mPriceAll);
            }
            else
            {
               _loc2_.DCCash -= this.mPriceAll;
               this.completeCrew();
               MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_CREW,MetricConstants.PRODUCT_CREW,"quantity: " + this.mEmptySlots,null,0,this.mPriceAll);
            }
         }
      }
      
      private function onComplete(param1:MouseEvent) : void
      {
         this.mItemObject.getCurrentState().setNotification(new NotificationConstructionEnd(this.mItemObject,false));
         onClose(null);
      }
      
      private function changeDescriptionText(param1:String) : void
      {
         var _loc3_:CrewItemContent = null;
         var _loc2_:Number = this.mDescription.height;
         this.mDescription.text = param1;
         _loc2_ = this.mDescription.height - _loc2_;
         for each(_loc3_ in this.mCrew)
         {
            _loc3_.y += _loc2_;
         }
         updateContentSize();
      }
      
      override public function destroy() : void
      {
         var _loc1_:CrewItemContent = null;
         mOpen = false;
         this.mItemObject = null;
         for each(_loc1_ in this.mCrew)
         {
            _loc1_.destroy();
         }
         this.mCrew.length = 0;
         this.mStatus = 0;
         this.mBuyButtonIndex = 0;
         this.mPriceAll = 0;
         this.mEmptySlots = 0;
         super.destroy();
      }
   }
}

