package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.GUI.newsfeeds.NewsFeedViewManager;
   import com.dchoc.dollars.collectibles.CollectibleDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.WelcomeProgress;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinition;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinitionManager;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedsIDs;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class PopupPartner extends Popup
   {
      
      public static const TYPE_PARTNER:int = 0;
      
      public static const TYPE_SHARE_UPGRADES:int = 1;
      
      public static const TYPE_SHARE_HELP:int = 2;
      
      public static const TYPE_SHARE_FINISHED:int = 3;
      
      public static const TYPE_SHARE_NEW_PARTNERS:int = 4;
      
      public static const TYPE_SHARE_NEW_EXPANSION:int = 5;
      
      public static const TYPE_SHARE_COLLECT:int = 6;
      
      public static const TYPE_SHARE_CONTRACT:int = 7;
      
      public static const TYPE_SHARE_RENT_MOVE:int = 8;
      
      public static const TYPE_SHARE_THANKS_COLLECTIBLE:int = 9;
      
      public static const TYPE_SHARE_THANKS_COLLECTIBLE_ALL:int = 10;
      
      public static const TYPE_SHARE_COMPLETE_COLLECTIBLE_COLLECTION:int = 11;
      
      public static const TYPE_SHARE_ASK_COLLECTIBLE:int = 12;
      
      public static const TYPE_SHARE_GOLD_BOUGHT:int = 13;
      
      public static const TYPE_SHARE_ASK_FOR_CASH_DONE:int = 14;
      
      public static const TYPE_SHARE_ASK_FOR_CASH_THANKS:int = 15;
      
      private static const NEWS_FEED_SKUS:Array = [null,NewsFeedsIDs.SKU_ALL_UPGRADES_DONE,NewsFeedsIDs.SKU_ASK_FOR_HELP_HELPED,NewsFeedsIDs.SKU_ASK_FOR_HELP_THANKS,NewsFeedsIDs.SKU_BECOME_PARTNER,NewsFeedsIDs.SKU_NEW_EXPANSION,NewsFeedsIDs.SKU_COLLECT,NewsFeedsIDs.SKU_CONTRACTS,NewsFeedsIDs.SKU_RENT_MOVE,NewsFeedsIDs.SKU_THANKS_COLLECTIBLE,NewsFeedsIDs.SKU_THANKS_COLLECTIBLE,NewsFeedsIDs.SKU_COLLECTION_COMPLETED,NewsFeedsIDs.SKU_ASK_COLLECTIBLE,NewsFeedsIDs.SKU_GOLD_BOUGHT,NewsFeedsIDs.SKU_ASK_FOR_CASH_DONE,NewsFeedsIDs.SKU_ASK_FOR_CASH_THANKS];
      
      private var mRewardSku:String;
      
      private var mItemDef:ItemDefinition;
      
      private var mType:int;
      
      private var mPhoto:Sprite;
      
      private var mFeedImg:String;
      
      private var mImage:Bitmap;
      
      private var mFriendExtId:String;
      
      private var mCollectibleDef:CollectibleDefinition;
      
      private const SKU_ARRAY:Array;
      
      private var mCollectibleName:String;
      
      private var mNeighbor:FriendObject;
      
      public function PopupPartner(param1:int, param2:String = "")
      {
         var _loc7_:NewsFeedDefinition = null;
         this.SKU_ARRAY = [["superupgrade.jpg",null],["new_feed_upgrades_0.jpg","new_feed_upgrades_1.jpg"],["instand_build.jpg",null],["thx_help_buildings.jpg",null],["new_feeds_partners.jpg",null],["new_feed_expansion.jpg",null],["new_feed_moneyCollector.jpg",null],["new_feed_contractSignator.jpg",null],["new_feed_move.jpg",null],["thx_gift.jpg",null],["thx_gift.jpg",null],["new_feed_expansion.jpg",null],["new_feed_expansion.jpg",null],["fbc_ask.jpg",null],["fbc_done.jpg",null],["fbc_thanks.jpg",null]];
         this.mType = param1;
         this.mRewardSku = param2;
         var _loc3_:String = "popup_publish_nf";
         var _loc4_:Boolean = NEWS_FEED_SKUS[this.mType] != null;
         if(_loc4_)
         {
            _loc7_ = NewsFeedDefinitionManager.getInstance().getDefinitionBySku(NEWS_FEED_SKUS[this.mType]) as NewsFeedDefinition;
            _loc4_ = _loc7_ != null && _loc7_.hasReward();
            if(_loc4_)
            {
               _loc3_ += "_reward";
            }
         }
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,_loc3_))();
         if(_loc4_)
         {
            NewsFeedViewManager.getInstance().setupNewsFeedPrePopup(mBox,NEWS_FEED_SKUS[this.mType]);
         }
         mCancelButton = new DynamicButton(mBox.getChildByName("CancelButton") as MovieClip);
         mBox.addChild(mCancelButton.getButtonMc());
         mOkButton = new DynamicButton(mBox.getChildByName("AcceptButton") as MovieClip);
         var _loc5_:TextField = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(_loc5_);
         var _loc6_:String = TextManager.getText(TextIDs.TID_POPUP_BUTTON_UPGRADEME);
         _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_UPGRADEME);
         mTextBox = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(mTextBox);
         mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_TEXT_PARTNER);
         switch(param1)
         {
            case TYPE_PARTNER:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_PARTNER);
               _loc5_.text = TextManager.getText(TextIDs.TID_BUTTON_ADD_PARTNER);
               break;
            case TYPE_SHARE_NEW_PARTNERS:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_NEW_PARTNERS);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_NEW_PARTNERS);
               break;
            case TYPE_SHARE_NEW_EXPANSION:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_NEW_PARTNERS);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_NEW_EXPANSION);
               break;
            case TYPE_SHARE_FINISHED:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_NOTIFY_BUILDING_FINISHED);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_NOTIFY_BUILDING_FINISHED);
               break;
            case TYPE_SHARE_HELP:
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_NOTIFY_HELP_BUILDING);
               break;
            case TYPE_SHARE_COLLECT:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_NEW_PARTNERS);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_CONTRACTOR2);
               break;
            case TYPE_SHARE_CONTRACT:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_NEW_PARTNERS);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_CONTRACTOR3);
               break;
            case TYPE_SHARE_RENT_MOVE:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_NEW_PARTNERS);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_TITLE_CONTRACTOR1);
               break;
            case TYPE_SHARE_ASK_COLLECTIBLE:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_ASK_ITEM_BUTTON);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_ASK_ITEM_TITLE);
               break;
            case TYPE_SHARE_COMPLETE_COLLECTIBLE_COLLECTION:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_REWARD_CLAIMED_BUTTON);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_REWARD_CLAIMED_TITLE);
               break;
            case TYPE_SHARE_THANKS_COLLECTIBLE:
               _loc6_ = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_BUTTON);
               _loc5_.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_TITLE);
               break;
            case TYPE_SHARE_THANKS_COLLECTIBLE_ALL:
               _loc6_ = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_BUTTON);
               _loc5_.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_TITLE);
               break;
            case TYPE_SHARE_GOLD_BOUGHT:
               _loc6_ = TextManager.getText(TextIDs.TID_GOLDBOUGHT_POPUP_BUTTON);
               _loc5_.text = TextManager.getText(TextIDs.TID_GOLDBOUGHT_POPUP_TITLE);
               break;
            case TYPE_SHARE_ASK_FOR_CASH_DONE:
               _loc6_ = TextManager.getText(TextIDs.TID_POPUP_BUTTON_UPGRADEME);
               _loc5_.text = TextManager.getText(TextIDs.TID_POPUP_BUTTON_NOTIFY_HELP_BUILDING);
               break;
            case TYPE_SHARE_ASK_FOR_CASH_THANKS:
               _loc6_ = TextManager.getText(TextIDs.TID_POST_ASK_FOR_CASH_THANKS_TITLE);
               _loc5_.text = TextManager.getText(TextIDs.TID_INVEST_SUCCESS_THANKS);
         }
         mOkButton.setLabel(_loc6_);
         this.mPhoto = mBox.getChildByName("photo") as Sprite;
         this.mPhoto.visible = false;
         super();
      }
      
      private function onPublish(param1:MouseEvent) : void
      {
         var _loc3_:FriendObject = null;
         var _loc4_:CollectibleRewardDefinition = null;
         var _loc2_:NeighborObject = FriendsManager.getNeighborByID(DollarsGame.getCurrentUniverse().owner);
         switch(this.mType)
         {
            case TYPE_PARTNER:
               onAccept(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_PARTNER_REQUEST,{});
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_BECOME_PARTNER,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_UPGRADES:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_ALL_UPGRADES_DONE,
                  "fExtId":_loc2_.extId,
                  "feedImg":this.mFeedImg
               });
               if(this.mNeighbor.isPartner())
               {
                  MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_SUPERUPGRADES_DONE,MetricConstants.LABEL_FB_STARTED);
                  break;
               }
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_UPGRADES_DONE,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_NEW_EXPANSION:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_NEW_EXPANSION,
                  "feedImg":this.mFeedImg
               });
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_NEW_EXPANSION,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_FINISHED:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_THANK_HELPERS_WONDER,
                  "feedImg":this.mFeedImg,
                  "fExtId":FriendsManager.getExtIdsToThankForHelpingBuilding()
               });
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_THANKS_HELP,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_COLLECT:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_CONTRATOR_COLLECT,
                  "feedImg":this.mFeedImg
               });
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_CONTRATOR_COLLECT,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_RENT_MOVE:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_CONTRATOR_MOVE,
                  "feedImg":this.mFeedImg
               });
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_CONTRATOR_MOVE,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_NEW_PARTNERS:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_PARTNER_ACCEPTED,
                  "feedImg":this.mFeedImg
               });
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_NOTIFY_NEW_PARTNERS,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_CONTRACT:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_CONTRATOR_CONTRACT,
                  "feedImg":this.mFeedImg
               });
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_CONTRATOR_MOVE,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_HELP:
               onClose(null);
               _loc3_ = FriendsManager.getFriendByID(WelcomeProgress.mLoginSourceExtId);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_NOTIFY_HELP_WONDER,
                  "feedImg":this.mFeedImg,
                  "friendName":_loc3_.nameFriend,
                  "itemName":TextManager.getText(TextIDs[this.mItemDef.textID])
               });
               MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_NOTIFY_HELP,MetricConstants.LABEL_FB_STARTED);
               break;
            case TYPE_SHARE_ASK_COLLECTIBLE:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_ASK_COLLECTIBLE,
                  "feedImg":this.mFeedImg,
                  "name":TextManager.getText(TextIDs[this.mCollectibleDef.textID]),
                  "image":this.mCollectibleDef.getFeedImg()
               });
               break;
            case TYPE_SHARE_COMPLETE_COLLECTIBLE_COLLECTION:
               onClose(null);
               _loc4_ = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mRewardSku) as CollectibleRewardDefinition;
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_COLLECTIBLE_COLLECTION_COMPLETE,
                  "feedImg":this.mFeedImg,
                  "name":TextManager.getText(TextIDs[_loc4_.textID]),
                  "image":_loc4_.getFeedImg()
               });
               break;
            case TYPE_SHARE_THANKS_COLLECTIBLE:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_THANKS_COLLECTIBLE,
                  "fExtId":this.mFriendExtId,
                  "feedImg":this.mFeedImg
               });
               break;
            case TYPE_SHARE_THANKS_COLLECTIBLE_ALL:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_THANKS_COLLECTIBLE_ALL,
                  "feedImg":this.mFeedImg
               });
               break;
            case TYPE_SHARE_GOLD_BOUGHT:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_GOLD_BOUGHT,
                  "feedImg":this.mFeedImg
               });
               break;
            case TYPE_SHARE_ASK_FOR_CASH_DONE:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_ASK_FOR_CASH_DONE,
                  "fExtId":this.mFriendExtId,
                  "feedImg":this.mFeedImg
               });
               break;
            case TYPE_SHARE_ASK_FOR_CASH_THANKS:
               onClose(null);
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
                  "postId":UserDataFacade.POST_ASK_FOR_CASH_THANKS,
                  "fExtId":this.mFriendExtId,
                  "feedImg":this.mFeedImg
               });
         }
      }
      
      public function setItemDefinition(param1:ItemDefinition) : void
      {
         this.mItemDef = param1;
      }
      
      private function loadImage() : void
      {
         var _loc2_:CollectibleRewardDefinition = null;
         var _loc3_:Loader = null;
         var _loc4_:URLRequest = null;
         var _loc5_:LoaderContext = null;
         var _loc1_:String = null;
         this.mFeedImg = null;
         this.mFeedImg = this.SKU_ARRAY[this.mType][0];
         if(this.mType == TYPE_SHARE_UPGRADES)
         {
            if(this.mNeighbor.isPartner())
            {
               this.mFeedImg = this.SKU_ARRAY[this.mType][1];
            }
         }
         else if(this.mType == TYPE_SHARE_HELP && this.mItemDef != null)
         {
            this.mFeedImg = this.mItemDef.getFeedImg();
         }
         else if(this.mType == TYPE_SHARE_ASK_COLLECTIBLE)
         {
            this.mFeedImg = this.mCollectibleDef.getFeedImg();
         }
         else if(this.mType == TYPE_SHARE_COMPLETE_COLLECTIBLE_COLLECTION)
         {
            _loc2_ = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mRewardSku) as CollectibleRewardDefinition;
            this.mFeedImg = _loc2_.getFeedImg();
         }
         else
         {
            this.mFeedImg = this.SKU_ARRAY[this.mType][0];
         }
         if(this.mFeedImg != null)
         {
            _loc1_ = Config.getRoot() + ModelConfig.DIR_FEEDS + this.mFeedImg;
         }
         if(_loc1_ != null)
         {
            _loc3_ = new Loader();
            _loc4_ = new URLRequest(_loc1_);
            _loc5_ = new LoaderContext();
            _loc3_.load(_loc4_,_loc5_);
            this.mPhoto.addChild(_loc3_);
            this.mPhoto.visible = true;
         }
      }
      
      public function showPopupParams(param1:FriendObject) : void
      {
         var _loc2_:CollectibleRewardDefinition = null;
         var _loc3_:String = null;
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.onPublish);
         this.mNeighbor = param1;
         this.loadImage();
         switch(this.mType)
         {
            case TYPE_SHARE_UPGRADES:
               mTextBox.text = TextManager.replaceParameters(TextIDs.TID_POPUP_TEXT_UPGRADEME,[param1.nameFriend]);
               break;
            case TYPE_SHARE_NEW_PARTNERS:
               mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_TEXT_NEW_PARTNERS);
               break;
            case TYPE_SHARE_NEW_EXPANSION:
               mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_TEXT_NEW_EXPANSION);
               break;
            case TYPE_SHARE_FINISHED:
               mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_TEXT_NOTIFY_BUILDING_FINISHED);
               break;
            case TYPE_SHARE_HELP:
               mTextBox.text = "";
               if(this.mItemDef != null)
               {
                  mTextBox.text = TextManager.replaceParameters(TextIDs.TID_POPUP_TEXT_NOTIFY_HELP_BUILDING,[param1.nameFriend,TextManager.getText(TextIDs[this.mItemDef.textID])]);
               }
               break;
            case TYPE_SHARE_COLLECT:
               mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_BODY_CONTRACTOR2);
               break;
            case TYPE_SHARE_CONTRACT:
               mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_BODY_CONTRACTOR3);
               break;
            case TYPE_SHARE_RENT_MOVE:
               mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_BODY_CONTRACTOR1);
               break;
            case TYPE_SHARE_ASK_COLLECTIBLE:
               mTextBox.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_ASK_ITEM_BODY);
               break;
            case TYPE_SHARE_COMPLETE_COLLECTIBLE_COLLECTION:
               _loc2_ = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mRewardSku) as CollectibleRewardDefinition;
               _loc3_ = TextManager.getText(TextIDs[_loc2_.textID]);
               mTextBox.text = TextManager.replaceParameters(TextIDs.TID_POPUP_COLLECTIBLES_REWARD_CLAIMED_BODY,new Array(_loc3_));
               break;
            case TYPE_SHARE_THANKS_COLLECTIBLE:
               mTextBox.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_BODY);
               break;
            case TYPE_SHARE_THANKS_COLLECTIBLE_ALL:
               mTextBox.text = TextManager.getText(TextIDs.TID_COLLECTIBLES_THANKS_BODY);
               break;
            case TYPE_SHARE_GOLD_BOUGHT:
               mTextBox.text = TextManager.getText(TextIDs.TID_GOLDBOUGHT_POPUP_BODY);
               break;
            case TYPE_SHARE_ASK_FOR_CASH_DONE:
               mTextBox.text = TextManager.getText(TextIDs.TID_POST_ASK_FOR_CASH_DONE_DESCRIPTION);
               break;
            case TYPE_SHARE_ASK_FOR_CASH_THANKS:
               mTextBox.text = TextManager.getText(TextIDs.TID_POST_ASK_FOR_CASH_THANKS_DESCRIPTION);
         }
         startShow(false);
      }
      
      public function setFriendExtId(param1:String) : void
      {
         this.mFriendExtId = param1;
      }
      
      public function setCollectibleDefinition(param1:CollectibleDefinition) : void
      {
         this.mCollectibleDef = param1;
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.onPublish);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
   }
}

