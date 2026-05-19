package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinition;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinitionManager;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedsIDs;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Utils;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class PopupLevel extends Popup
   {
      
      private var mIncrement:Number;
      
      private var mPageWidth:int;
      
      private var mItemContentWidth:Number;
      
      private var mContainerWidth:Number;
      
      private var mContainer:Sprite = mBox["container"];
      
      private var mRightArrow:DynamicButton = new DynamicButton(mBox["right_arrow"]);
      
      private var mScroll:Number = 0;
      
      private var mUnlockedItems:int;
      
      private const SCROLL_SPEED:Number = 0.5;
      
      private var mScrollDistance:int = 0;
      
      private var mTitleText:TextField = mBox["title_text"];
      
      private var mItemContentHeight:Number;
      
      private var mInfo:MovieClip;
      
      private var mShareButton:DynamicButton;
      
      private const ITEMS_PER_PAGE:Number = 3;
      
      private var mItems:Array;
      
      private var mLeftArrow:DynamicButton = new DynamicButton(mBox["left_arrow"]);
      
      private var mBmp:Bitmap;
      
      private var mUnlockText:TextField;
      
      private var mLevelText:TextField;
      
      private var mMaxScroll:int;
      
      private var mLoadingItems:Array;
      
      private var mFeedImage:MovieClip;
      
      public function PopupLevel()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level"))();
         this.mContainerWidth = this.mContainer.width;
         this.mContainer.scrollRect = new Rectangle(0,0,this.mContainer.width,this.mContainer.height);
         TextManager.reformatTextField(this.mTitleText);
         this.mTitleText.text = TextManager.getText(TextIDs.TID_POPUP_LEVEL_TITLE);
         TextManager.setTextScaled(this.mTitleText);
         this.mLevelText = mBox["level"]["level_text"];
         TextManager.reformatTextField(this.mLevelText);
         this.mLevelText.text = TextManager.replaceParameters(TextIDs.TID_POPUP_LEVEL_TEXT,new Array("" + DollarsGame.getProfile().level));
         TextManager.setTextScaled(this.mLevelText);
         this.mUnlockText = mBox["unlock_text"];
         TextManager.reformatTextField(this.mUnlockText);
         this.mUnlockText.text = TextManager.getText(TextIDs.TID_POPUP_LEVEL_UNLOCK);
         TextManager.setTextScaled(this.mUnlockText);
         mCancelButton = new DynamicButton(mBox["close_button"]);
         this.mShareButton = new DynamicButton(mBox["share_button"]);
         this.mShareButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_SHARE));
         this.mFeedImage = mBox["feed_image"];
         this.mFeedImage.visible = false;
         var _loc1_:NewsFeedDefinition = NewsFeedDefinitionManager.getInstance().getDefinitionBySku(NewsFeedsIDs.SKU_LEVEL_UP) as NewsFeedDefinition;
         var _loc2_:TextField = mBox["background"]["feed_text"]["TextInfo_02"];
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[_loc1_.getTextID()]);
         TextManager.setTextScaled(_loc2_);
         super();
      }
      
      private function getItems() : void
      {
         var _loc1_:ItemDefinition = null;
         var _loc4_:TextField = null;
         var _loc5_:Sprite = null;
         var _loc6_:Sprite = null;
         var _loc2_:MovieClip = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_box_new_building"))();
         this.mItemContentWidth = _loc2_.width;
         this.mItemContentHeight = _loc2_.height;
         if(this.mUnlockedItems <= this.ITEMS_PER_PAGE)
         {
            this.mIncrement = (this.mContainerWidth - this.mItemContentWidth * this.mUnlockedItems) / (this.mUnlockedItems + 1);
         }
         else
         {
            this.mIncrement = (this.mContainerWidth - this.mItemContentWidth * this.ITEMS_PER_PAGE) / (this.ITEMS_PER_PAGE + 1);
         }
         this.mIncrement = Math.ceil(this.mIncrement);
         var _loc3_:int = 0;
         while(_loc3_ < this.mUnlockedItems)
         {
            _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_box_new_building"))();
            _loc1_ = this.mItems[_loc3_];
            _loc4_ = _loc2_["title"];
            TextManager.reformatTextField(_loc4_);
            _loc4_.text = TextManager.getText(TextIDs[_loc1_.textID]);
            TextManager.setTextScaled(_loc4_);
            _loc5_ = _loc2_["container"];
            _loc6_ = this.setupImage(_loc1_,_loc5_);
            if(_loc6_ != null)
            {
               _loc5_.addChild(_loc6_);
               _loc2_["loading"].visible = false;
               this.mLoadingItems.push(null);
            }
            else
            {
               this.mLoadingItems.push(_loc2_);
            }
            this.mContainer.addChild(_loc2_);
            _loc2_.x = (this.mItemContentWidth + this.mIncrement) * _loc3_ + this.mIncrement;
            _loc2_.y = this.mContainer.height - this.mItemContentHeight >> 1;
            _loc3_++;
         }
         this.mMaxScroll = (this.mItemContentWidth + this.mIncrement) * this.mUnlockedItems + this.mIncrement;
         this.mPageWidth = (this.mItemContentWidth + this.mIncrement) * this.ITEMS_PER_PAGE + this.mIncrement;
      }
      
      private function loadImage(param1:String) : void
      {
         var _loc2_:Loader = new Loader();
         var _loc3_:URLRequest = new URLRequest(param1);
         var _loc4_:LoaderContext = new LoaderContext();
         _loc2_.load(_loc3_,_loc4_);
         this.mFeedImage.addChild(_loc2_);
         this.mFeedImage.visible = true;
      }
      
      private function setFeedImage() : void
      {
         if(this.mBmp != null && this.mFeedImage.contains(this.mBmp))
         {
            this.mFeedImage.removeChild(this.mBmp);
            this.mBmp = null;
         }
         var _loc1_:int = int(DollarsGame.getProfile().level);
         var _loc2_:String = "level_15_up.jpg";
         if(_loc1_ == 2)
         {
            _loc2_ = "level_2.jpg";
         }
         else if(_loc1_ == 3)
         {
            _loc2_ = "level_3.jpg";
         }
         else if(_loc1_ < 6)
         {
            _loc2_ = "level_4_5.jpg";
         }
         else if(_loc1_ < 8)
         {
            _loc2_ = "level_6_7.jpg";
         }
         else if(_loc1_ < 10)
         {
            _loc2_ = "level_8_9.jpg";
         }
         else if(_loc1_ < 15)
         {
            _loc2_ = "level_10_14.jpg";
         }
         this.loadImage(Config.getRoot() + ModelConfig.DIR_FEEDS + _loc2_);
      }
      
      override public function showPopup() : void
      {
         var _loc1_:DollarsGame = null;
         var _loc2_:MovieClip = null;
         var _loc3_:TextField = null;
         var _loc4_:Sprite = null;
         super.show();
         startShow(false);
         if(mBox != null)
         {
            _loc1_ = DollarsGame.smInstance;
            _loc1_.mPopupClip.addChild(mBox);
            if(this.mFeedImage != null)
            {
               this.setFeedImage();
            }
            _loc1_.mRain.start(_loc1_.mRainClip);
            _loc1_.mRain2.start(_loc1_.mRainClip2);
            if(Config.USE_SOUNDS)
            {
               SoundManager.getInstance().playSound(ModelConfig.SOUND_LEVEL);
            }
            mCancelButton.start();
            mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
            this.mShareButton.start();
            this.mShareButton.addEventListener(MouseEvent.CLICK,this.onShare);
            changeCursor();
            this.mItems = ItemDefinitionManager.getInstance().getItemsByLevel(DollarsGame.getProfile().level,-1,ItemDefinition.isAllowedToBeInLevelUp);
            this.mLoadingItems = new Array();
            this.mLeftArrow.addEventListener(MouseEvent.CLICK,this.scrollLeft);
            this.mLeftArrow.disable();
            this.mLeftArrow.visible = false;
            this.mRightArrow.addEventListener(MouseEvent.CLICK,this.scrollRight);
            this.mRightArrow.disable();
            this.mRightArrow.visible = false;
            if(this.mItems == null || this.mItems.length == 0)
            {
               this.mUnlockedItems = 0;
               this.mUnlockText.visible = false;
               this.mInfo = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information"))();
               _loc3_ = this.mInfo["info_text"];
               TextManager.reformatTextField(_loc3_);
               _loc4_ = this.mInfo["box_info"];
               if(DollarsGame.getProfile().level == 2)
               {
                  _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP1);
                  _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_05"))();
               }
               else if(DollarsGame.getProfile().level == 4)
               {
                  _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP2);
                  if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
                  {
                     _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_02"))();
                  }
                  else
                  {
                     _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_03"))();
                  }
               }
               else if(DollarsGame.getProfile().level == 5)
               {
                  if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
                  {
                     _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP3_FBC);
                     _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_08"))();
                  }
                  else
                  {
                     _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP3);
                     _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_01"))();
                  }
               }
               else
               {
                  switch(Utils.randomNumber(0,3))
                  {
                     case 0:
                        _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP1);
                        _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_05"))();
                        break;
                     case 1:
                        _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP2);
                        if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
                        {
                           _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_02"))();
                           break;
                        }
                        _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_03"))();
                        break;
                     case 2:
                        _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP4);
                        _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_04"))();
                        break;
                     case 3:
                        if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
                        {
                           _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP3_FBC);
                           _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_08"))();
                           break;
                        }
                        _loc3_.text = TextManager.getText(TextIDs.TID_LEVELUP_HELP3);
                        _loc2_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"popup_next_level_information_image_01"))();
                  }
               }
               TextManager.setTextScaled(_loc3_,false);
               _loc4_.addChild(_loc2_);
               mBox.addChild(this.mInfo);
            }
            else
            {
               this.mUnlockedItems = this.mItems.length;
               TextManager.reformatTextField(this.mUnlockText);
               this.mUnlockText.text = TextManager.replaceParameters(TextIDs.TID_LEVELUP_NEW_BUILDINGS,new Array("" + this.mUnlockedItems));
               TextManager.setTextScaled(this.mUnlockText);
               this.getItems();
               if(this.mUnlockedItems > this.ITEMS_PER_PAGE)
               {
                  this.mLeftArrow.start();
                  this.mLeftArrow.disable();
                  this.mLeftArrow.visible = true;
                  this.mRightArrow.start();
                  this.mRightArrow.visible = true;
               }
            }
         }
         MyMetrics.sendMetric(MetricConstants.EVENT_LEVEL_UP,"" + DollarsGame.getProfile().level);
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{"postId":UserDataFacade.POST_LEVEL_UP});
         MyMetrics.sendMetric(MetricConstants.EVENT_FACEBOOK_FEED_LEVEL_UP,MetricConstants.LABEL_FB_STARTED);
         onClose(null);
      }
      
      public function logicUpdate(param1:Number) : void
      {
         var _loc2_:int = this.mScroll * param1;
         this.mScrollDistance -= Math.abs(_loc2_);
         if(this.mScrollDistance <= 0)
         {
            if(_loc2_ < 0)
            {
               _loc2_ -= this.mScrollDistance;
            }
            else
            {
               _loc2_ += this.mScrollDistance;
            }
            this.mScroll = 0;
            this.mScrollDistance = 0;
         }
         this.updateIcons();
         var _loc3_:Rectangle = this.mContainer.scrollRect;
         _loc3_.x += _loc2_;
         this.mContainer.scrollRect = _loc3_;
      }
      
      private function updateIcons() : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.mUnlockedItems)
         {
            if(this.mLoadingItems[_loc1_] != null)
            {
               _loc2_ = (this.mLoadingItems[_loc1_] as Sprite)["container"];
               _loc3_ = this.setupImage(this.mItems[_loc1_],_loc2_);
               if(_loc3_ != null)
               {
                  _loc2_.addChild(_loc3_);
                  (this.mLoadingItems[_loc1_] as Sprite)["loading"].visible = false;
                  this.mLoadingItems[_loc1_] = null;
               }
            }
            _loc1_++;
         }
      }
      
      private function scrollRight(param1:MouseEvent = null) : void
      {
         if(this.mContainer.scrollRect.x + this.mPageWidth >= this.mMaxScroll)
         {
            this.mScroll = 0;
            this.mScrollDistance = 0;
         }
         else if(this.mScrollDistance == 0)
         {
            this.mScroll = this.SCROLL_SPEED;
            this.mScrollDistance = this.mItemContentWidth + this.mIncrement;
         }
         if(this.mContainer.scrollRect.x + this.mPageWidth + this.mScrollDistance >= this.mMaxScroll)
         {
            this.mRightArrow.disable();
         }
         this.mLeftArrow.enable();
      }
      
      private function setupImage(param1:ItemDefinition, param2:Sprite) : Sprite
      {
         if(PriorityLoader.getInstance().isLoaded(param1.sku))
         {
            return param1.getIcon(param2).icon;
         }
         return null;
      }
      
      private function scrollLeft(param1:MouseEvent = null) : void
      {
         if(this.mContainer.scrollRect.x <= 0)
         {
            this.mScroll = 0;
            this.mScrollDistance = 0;
         }
         else if(this.mScrollDistance == 0)
         {
            this.mScroll = -this.SCROLL_SPEED;
            this.mScrollDistance = this.mItemContentWidth + this.mIncrement;
         }
         if(this.mContainer.scrollRect.x - this.mScrollDistance <= 0)
         {
            this.mLeftArrow.disable();
         }
         if(this.mUnlockedItems > this.ITEMS_PER_PAGE)
         {
            this.mRightArrow.enable();
         }
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         dispatchEvent(new Event(EVENT_CLOSE));
         DollarsGame.smInstance.mRain.stop();
         DollarsGame.smInstance.mRain2.stop();
      }
      
      override public function destroy() : void
      {
         this.mTitleText = null;
         this.mLevelText = null;
         this.mUnlockText = null;
         this.mUnlockedItems = 0;
         mCancelButton = null;
         this.mShareButton = null;
         this.mFeedImage = null;
         this.mContainer = null;
         this.mLeftArrow.destroy();
         this.mRightArrow.destroy();
         this.mLeftArrow = null;
         this.mRightArrow = null;
         this.mScroll = 0;
         this.mScrollDistance = 0;
         this.mItems.length = 0;
         this.mLoadingItems.length = 0;
         super.destroy();
      }
   }
}

