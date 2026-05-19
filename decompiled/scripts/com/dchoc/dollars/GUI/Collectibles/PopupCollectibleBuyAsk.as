package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class PopupCollectibleBuyAsk extends Popup implements FBCreditsPurchaseInterface
   {
      
      public static const TYPE_SHOP_POPUP:int = 0;
      
      public static const TYPE_WELCOME_SEND:int = 1;
      
      public static const TYPE_WELCOME_NOT_SEND:int = 2;
      
      private var mPhoto:Sprite;
      
      private var mType:int;
      
      private var mFeedImg:String;
      
      private var mAskButton:DynamicButton;
      
      private var mTitle:TextField;
      
      private var mFriendId:String;
      
      private var mImage:Bitmap;
      
      private var mBuyButton:DynamicButton;
      
      private var mCollectibleObject:CollectibleObject;
      
      private var mText:TextField;
      
      public function PopupCollectibleBuyAsk(param1:CollectibleObject, param2:int, param3:String = "", param4:Boolean = false)
      {
         var _loc6_:DynamicButton = null;
         this.mType = param2;
         this.mFriendId = param3;
         this.mCollectibleObject = param1;
         var _loc5_:int = this.mCollectibleObject.getCollectibleDefinition().priceCash;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_found_gift"))();
         this.mTitle = mBox.getChildByName("Caption") as TextField;
         this.mText = mBox.getChildByName("TextInfo") as TextField;
         this.mAskButton = new DynamicButton(mBox.getChildByName("AcceptButton") as MovieClip);
         this.mBuyButton = new DynamicButton(mBox.getChildByName("CancelButton") as MovieClip);
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         TextManager.reformatTextField(this.mTitle);
         TextManager.reformatTextField(this.mText);
         switch(this.mType)
         {
            case TYPE_SHOP_POPUP:
               this.mTitle.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_GET_TITLE);
               this.mText.text = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_GET_BODY,new Array(this.mCollectibleObject.getCollectibleDefinition().priceCash.toString()));
               this.mAskButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_ASK_ITEM_BUTTON));
               if(Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc5_ > DollarsGame.getCurrentWorld().getCompanyMine().DCCash)
               {
                  mBox.removeChild(this.mBuyButton.getButtonMc());
                  this.mBuyButton.destroy();
                  this.mBuyButton = new DynamicButton(mBox.getChildByName("FCButton") as MovieClip);
                  this.mBuyButton.setLabel("" + this.mCollectibleObject.getCollectibleDefinition().getPriceFBCredits());
                  this.mText.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_GET_BODY_FBC);
                  break;
               }
               _loc6_ = new DynamicButton(mBox.getChildByName("FCButton") as MovieClip);
               mBox.removeChild(_loc6_.getButtonMc());
               _loc6_.destroy();
               this.mBuyButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_BUY_ITEM_BUTTON));
               break;
            case TYPE_WELCOME_SEND:
               _loc6_ = new DynamicButton(mBox.getChildByName("FCButton") as MovieClip);
               mBox.removeChild(_loc6_.getButtonMc());
               _loc6_.destroy();
               this.mTitle.text = TextManager.getText(TextIDs.TID_SEND_GIFT_ITEM_CONFIRMATION_TITLE);
               this.mText.text = TextManager.replaceParameters(TextIDs.TID_SEND_GIFT_ITEM_CONFIRMATION,new Array(TextManager.getText(TextIDs[this.mCollectibleObject.getCollectibleDefinition().textID]),FriendsManager.getFriendByID(this.mFriendId).nameFriend,String(this.mCollectibleObject.getCount())));
               this.mAskButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_YES));
               this.mBuyButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_NO));
               break;
            case TYPE_WELCOME_NOT_SEND:
               _loc6_ = new DynamicButton(mBox.getChildByName("FCButton") as MovieClip);
               mBox.removeChild(_loc6_.getButtonMc());
               _loc6_.destroy();
               this.mAskButton.visible = false;
               this.mBuyButton.getButtonMc().x = this.mBuyButton.getButtonMc().x + 85;
               this.mTitle.text = TextManager.getText(TextIDs.TID_SEND_GIFT_NOITEM_TITLE);
               this.mText.text = TextManager.replaceParameters(TextIDs.TID_SEND_GIFT_NOITEM,new Array(TextManager.getText(TextIDs[this.mCollectibleObject.getCollectibleDefinition().textID])));
               this.mAskButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_OK));
               this.mBuyButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_OK));
         }
         this.mAskButton.start();
         this.mBuyButton.start();
         mCancelButton.start();
         if(param4)
         {
            this.mBuyButton.disable();
            this.mBuyButton.visible = false;
            this.mAskButton.getButtonMc().x = this.mAskButton.getButtonMc().x - this.mBuyButton.getButtonMc().width / 2;
            this.mText.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_ASK_BODY);
         }
         TextManager.setTextScaled(this.mTitle);
         TextManager.setTextScaled(this.mText);
         TextManager.changColors(this.mText);
         this.mPhoto = mBox.getChildByName("photo") as Sprite;
         super();
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            this.completeBuy(0);
         }
      }
      
      private function completeBuy(param1:int) : void
      {
         var _loc2_:Object = UserDataFacade.securityCreateObj(0,0,-param1);
         var _loc3_:String = "-1";
         UserDataFacade.getInstance().updateCollectible(_loc3_,this.mCollectibleObject.getCollectibleDefinition().sku,"BUY",null,{},_loc2_);
         CollectibleManager.getInstance().keepCollectible(this.mCollectibleObject.getCollectibleDefinition().sku,true);
         PopupCollectibleManager.getInstance().smPopupCollectibleShop.refreshGroups();
         if(param1 == 0)
         {
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_FB_CREDITS,MetricConstants.LABEL_ECONOMY_BUY_COLLECTIBLE,MetricConstants.PRODUCT_COLLECTIBLE,"collectible " + this.mCollectibleObject.getCollectibleDefinition().sku,null,0,this.mCollectibleObject.getCollectibleDefinition().getPriceFBCredits());
         }
         else
         {
            MyMetrics.sendMetricNG(MetricConstants.EVENT_SPEND_GOLD,MetricConstants.LABEL_ECONOMY_BUY_COLLECTIBLE,MetricConstants.PRODUCT_COLLECTIBLE,"collectible " + this.mCollectibleObject.getCollectibleDefinition().sku,null,0,param1);
         }
         onClose(null);
      }
      
      private function loadImage() : void
      {
         var _loc2_:Loader = null;
         var _loc3_:URLRequest = null;
         var _loc4_:LoaderContext = null;
         var _loc1_:String = null;
         this.mFeedImg = this.mCollectibleObject.getCollectibleDefinition().getFeedImg();
         if(this.mFeedImg != null)
         {
            _loc1_ = Config.getRoot() + ModelConfig.DIR_FEEDS + this.mFeedImg;
         }
         if(_loc1_ != null)
         {
            _loc2_ = new Loader();
            _loc3_ = new URLRequest(_loc1_);
            _loc4_ = new LoaderContext();
            _loc2_.load(_loc3_,_loc4_);
            this.mPhoto.addChild(_loc2_);
            this.mPhoto.visible = true;
         }
      }
      
      private function onAsk(param1:MouseEvent) : void
      {
         onClose(null);
         Debug.trace("Collectible, textID: " + this.mCollectibleObject.getCollectibleDefinition().textID + ". Name: " + TextManager.getText(TextIDs[this.mCollectibleObject.getCollectibleDefinition().textID]));
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
            "postId":UserDataFacade.POST_ASK_COLLECTIBLE,
            "feedImg":this.mFeedImg,
            "name":TextManager.getText(TextIDs[this.mCollectibleObject.getCollectibleDefinition().textID]),
            "sku":this.mCollectibleObject.getCollectibleDefinition().sku,
            "image":this.mCollectibleObject.getCollectibleDefinition().getFeedImg()
         });
         UserDataFacade.getInstance().updateCollectible(null,this.mCollectibleObject.getCollectibleDefinition().sku,"ASK",null,{},null);
      }
      
      private function onSend(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = UserDataFacade.securityCreateObj(0,0,0);
         var _loc4_:String = UserDataFacade.getInstance().mUserExtId;
         _loc3_ = "v";
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_SEND_COLLECTIBLE,{
            "fExtId":this.mFriendId,
            "sku":this.mCollectibleObject.getCollectibleDefinition().sku,
            "CollectibleName":TextManager.getText(TextIDs[this.mCollectibleObject.getCollectibleDefinition().textID]),
            "collectibleFeed":this.mCollectibleObject.getCollectibleDefinition().getFeedImg()
         });
         UserDataFacade.getInstance().updateCollectible(_loc3_,this.mCollectibleObject.getCollectibleDefinition().sku,"SEND",String(this.mFriendId),{},_loc2_);
         onClose(null);
      }
      
      override protected function endButtons() : void
      {
         this.mAskButton.end();
         this.mBuyButton.end();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         switch(this.mType)
         {
            case TYPE_SHOP_POPUP:
               this.mAskButton.removeEventListener(MouseEvent.CLICK,this.onAsk);
               this.mBuyButton.removeEventListener(MouseEvent.CLICK,this.onBuy);
               break;
            case TYPE_WELCOME_SEND:
               this.mAskButton.removeEventListener(MouseEvent.CLICK,this.onSend);
               this.mBuyButton.removeEventListener(MouseEvent.CLICK,onClose);
               break;
            case TYPE_WELCOME_NOT_SEND:
               this.mAskButton.removeEventListener(MouseEvent.CLICK,onClose);
         }
      }
      
      private function onBuy(param1:MouseEvent) : void
      {
         var _loc2_:int = this.mCollectibleObject.getCollectibleDefinition().priceCash;
         var _loc3_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && _loc2_ > _loc3_.DCCash)
         {
            FBCreditsPurchase.getInstance().startPurchaseProcess(this);
         }
         else if(_loc3_.DCCash >= _loc2_)
         {
            DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash - this.mCollectibleObject.getCollectibleDefinition().priceCash;
            this.completeBuy(_loc2_);
         }
         else
         {
            DollarsGame.smInstance.mPopupConfirm.startNoEnoughGold(0,_loc2_);
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
         this.loadImage();
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         onClose(null);
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":this.mCollectibleObject.getCollectibleDefinition().getPriceFBCredits(),
            "orderInfo":{
               "sku":this.mCollectibleObject.getCollectibleDefinition().sku,
               "type":FBCreditsPurchase.TYPE_BUY_COLLECTIBLE
            }
         };
      }
      
      override protected function startButtons() : void
      {
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         switch(this.mType)
         {
            case TYPE_SHOP_POPUP:
               this.mAskButton.addEventListener(MouseEvent.CLICK,this.onAsk);
               this.mBuyButton.addEventListener(MouseEvent.CLICK,this.onBuy);
               break;
            case TYPE_WELCOME_SEND:
               this.mAskButton.addEventListener(MouseEvent.CLICK,this.onSend);
               this.mBuyButton.addEventListener(MouseEvent.CLICK,onClose);
               break;
            case TYPE_WELCOME_NOT_SEND:
               this.mBuyButton.addEventListener(MouseEvent.CLICK,onClose);
         }
      }
   }
}

