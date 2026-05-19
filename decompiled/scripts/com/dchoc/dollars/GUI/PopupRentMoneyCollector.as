package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.WelcomeProgress;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupRentMoneyCollector extends Popup
   {
      
      private static const XINIT:Number = -168.83;
      
      private static const YINIT:Number = -81;
      
      private static const YOFFSET:Number = 53.5;
      
      private static const NUM_ITEMS:int = 4;
      
      private var mItems:Array;
      
      private var mPopupFeed:PopupPartner;
      
      private var mContracted:Boolean;
      
      public function PopupRentMoneyCollector()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"PopupRentMoneyCollector"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_POPUP_RENT_COLLECTOR_TITLE);
         super();
      }
      
      private function getItems() : void
      {
         var _loc6_:DisplayObject = null;
         var _loc7_:ItemService = null;
         this.mItems = new Array();
         var _loc1_:int = ServiceDefinitionManager.getInstance().getIdFromTypeSku(Profile.SERVICES_MONEY_COLLECTOR_SKU);
         var _loc2_:Array = ServiceDefinitionManager.getInstance().getDefinitions(_loc1_);
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 1;
         var _loc5_:int = 0;
         while(_loc5_ < mBox.numChildren)
         {
            _loc6_ = mBox.getChildAt(_loc5_);
            if(_loc6_.name.indexOf("box_0" + _loc4_) > -1)
            {
               _loc7_ = new ItemService(_loc2_[_loc4_ - 1],Profile.SERVICES_MONEY_COLLECTOR_SKU);
               _loc7_.x = _loc6_.x;
               _loc7_.y = _loc6_.y;
               _loc7_.addEventListener(ItemService.EVENT_CONTRACT,this.onContract);
               this.mItems.push(_loc7_);
               mBox.addChild(_loc7_);
               _loc6_.visible = false;
               _loc4_++;
            }
            _loc5_++;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         startShow();
         this.getItems();
         this.mContracted = false;
      }
      
      private function onContract(param1:Event) : void
      {
         this.mPopupFeed = new PopupPartner(PopupPartner.TYPE_SHARE_COLLECT);
         this.mPopupFeed.showPopupParams(null);
         this.mPopupFeed.addEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         onClose(null);
         this.mContracted = true;
      }
      
      private function onCloseFeed(param1:Event) : void
      {
         this.mPopupFeed.removeEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         this.mPopupFeed = null;
         if(DollarsGame.smInstance.mWelcomProgress)
         {
            DollarsGame.smInstance.mWelcomProgress.dispatchEvent(new Event(WelcomeProgress.EVENT_SERVICE_SHOP_CLOSE));
         }
         DollarsGame.getCurrentRole().toolsBar.setToolMoneyCollector();
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         this.removeItems();
         if(this.mContracted)
         {
            dispatchEvent(new Event(ItemService.EVENT_CONTRACT));
         }
         else if(DollarsGame.smInstance.mWelcomProgress)
         {
            DollarsGame.smInstance.mWelcomProgress.dispatchEvent(new Event(WelcomeProgress.EVENT_SERVICE_SHOP_CLOSE));
         }
         if(DollarsGame.getProfile().servicesIsOfferEnabled(Profile.SERVICES_MONEY_COLLECTOR_SKU))
         {
            DollarsGame.getProfile().setServicesIsOfferEnabled(Profile.SERVICES_MONEY_COLLECTOR_SKU,false);
         }
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         dispatchEvent(new Event(EVENT_CLOSE));
         DollarsGame.getCurrentRole().toolsBar.setToolToSelect();
      }
      
      private function removeItems() : void
      {
         var _loc3_:ItemService = null;
         var _loc1_:int = int(this.mItems.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this.mItems[_loc2_];
            _loc3_.removeEventListener(ItemService.EVENT_CONTRACT,this.onContract);
            mBox.removeChild(_loc3_);
            _loc3_.destroy();
            _loc3_ = null;
            this.mItems[_loc2_] = null;
            _loc2_++;
         }
         this.mItems = null;
      }
   }
}

