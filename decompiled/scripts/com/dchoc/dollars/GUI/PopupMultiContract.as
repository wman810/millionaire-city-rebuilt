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
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupMultiContract extends Popup
   {
      
      private static const XINIT:Number = -168.83;
      
      private static const YINIT:Number = -81;
      
      private static const XOFFSET:Number = 392.95;
      
      private static const YOFFSET:Number = 53.5;
      
      private static const NUM_ITEMS:int = 4;
      
      private var mScrolling:Boolean;
      
      private var mScrollTimer:int;
      
      private var mScrollSpeed:Number;
      
      private var mMaxScrolls:int;
      
      private var mItems:Array;
      
      private var mArrowUp:DynamicButton;
      
      private var mArrowDown:DynamicButton;
      
      private var mScrollOrigin:int;
      
      private var mMaxOffset:int;
      
      private var mNumScrolls:int;
      
      private var mDist:Number;
      
      private var mScrollRect:Sprite;
      
      private var mPopupFeed:PopupPartner;
      
      private var mContracted:Boolean;
      
      public function PopupMultiContract()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_contract"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(TextIDs.TID_POPUP_MULTI_CONTRACT_TITLE);
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         super();
      }
      
      private function getItems() : void
      {
         var _loc6_:DisplayObject = null;
         var _loc7_:ItemService = null;
         this.mItems = new Array();
         var _loc1_:int = ServiceDefinitionManager.getInstance().getIdFromTypeSku(Profile.SERVICES_CONTRACT_SIGNATOR_SKU);
         var _loc2_:Array = ServiceDefinitionManager.getInstance().getDefinitions(_loc1_);
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 1;
         var _loc5_:int = 0;
         while(_loc5_ < mBox.numChildren)
         {
            _loc6_ = mBox.getChildAt(_loc5_);
            if(_loc6_.name.indexOf("box_0" + _loc4_) > -1)
            {
               _loc7_ = new ItemService(_loc2_[_loc4_ - 1],Profile.SERVICES_CONTRACT_SIGNATOR_SKU);
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
      
      private function onContract(param1:Event) : void
      {
         onClose(null);
         this.mPopupFeed = new PopupPartner(PopupPartner.TYPE_SHARE_CONTRACT);
         this.mPopupFeed.showPopupParams(null);
         this.mPopupFeed.addEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         this.mContracted = true;
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
            _loc3_.destroy();
            _loc3_ = null;
            this.mItems[_loc2_] = null;
            _loc2_++;
         }
         this.mItems = null;
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
         if(DollarsGame.getProfile().servicesIsOfferEnabled(Profile.SERVICES_CONTRACT_SIGNATOR_SKU))
         {
            DollarsGame.getProfile().setServicesIsOfferEnabled(Profile.SERVICES_CONTRACT_SIGNATOR_SKU,false);
         }
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         dispatchEvent(new Event(EVENT_CLOSE));
         DollarsGame.getCurrentRole().toolsBar.setToolToSelect();
      }
      
      private function onCloseFeed(param1:Event) : void
      {
         this.mPopupFeed.removeEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         this.mPopupFeed = null;
         if(DollarsGame.smInstance.mWelcomProgress)
         {
            DollarsGame.smInstance.mWelcomProgress.dispatchEvent(new Event(WelcomeProgress.EVENT_SERVICE_SHOP_CLOSE));
         }
         DollarsGame.getCurrentRole().toolsBar.setToolContractSignator();
      }
   }
}

