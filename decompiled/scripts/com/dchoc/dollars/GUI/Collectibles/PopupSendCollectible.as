package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupConfirmDestroy;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.containers.InvestFriendContent;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class PopupSendCollectible extends Popup
   {
      
      public static const SKU:String = "Investments";
      
      private var mWishButton:DynamicButton;
      
      private var mScrolling:Boolean;
      
      private var mMaxScrolls:int;
      
      private var mAllFriendsButton:DynamicButton;
      
      private const TYPE_INVEST:int = 1;
      
      private var mSearchBox:Sprite;
      
      private var mScrollRect:Sprite;
      
      private var mHelpButton:DynamicButton;
      
      private var mCurrentTypeFriends:int;
      
      private var mScrollOffsetY:int;
      
      private const FRIENDS_WISH:int = 2;
      
      private var mDist:Number;
      
      private var mNumScrolls:int;
      
      private const FRIENDS_ALL:int = 1;
      
      private var mMaxOffset:int;
      
      private const TYPE_STATS:int = 2;
      
      private var mSenderId:String;
      
      private var mSearchText:TextField;
      
      private var mPopupConfirmDestroy:PopupConfirmDestroy;
      
      private var mScrollTimer:int;
      
      private var mScrollSpeed:Number;
      
      private var mType:int;
      
      private var mItems:Vector.<InvestFriendContent>;
      
      private var mNeighboursButton:DynamicButton = new DynamicButton(mBox.getChildByName("NewButton") as MovieClip);
      
      private var mArrowUp:DynamicButton;
      
      private const FRIENDS_MILLIONAIRE:int = 0;
      
      private var mArrowDown:DynamicButton;
      
      private var mItemsY:int;
      
      private var mScrollOrigin:int;
      
      private var mTitle:TextField;
      
      private const TYPE_FRIENDS:int = 0;
      
      private var mWished:Boolean;
      
      private var mCollectibleSku:String;
      
      private var mItemObject:ItemObject;
      
      public function PopupSendCollectible(param1:String, param2:String, param3:ItemObject = null)
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(SKU,"popup_investment_background"))();
         this.mItemObject = param3;
         this.mCollectibleSku = param1;
         this.mSenderId = param2;
         this.mCurrentTypeFriends = this.FRIENDS_MILLIONAIRE;
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         this.mNeighboursButton.setLabel(TextManager.getText(TextIDs.TID_GIFTS_TAB_MC));
         this.mAllFriendsButton = new DynamicButton(mBox.getChildByName("CheckButton") as MovieClip);
         this.mAllFriendsButton.setLabel(TextManager.getText(TextIDs.TID_GIFTS_TAB_ALL));
         this.mArrowUp = new DynamicButton(mBox.getChildByName("mArrowUp") as MovieClip);
         this.mArrowDown = new DynamicButton(mBox.getChildByName("mArrowDown") as MovieClip);
         this.mHelpButton = new DynamicButton(mBox.getChildByName("HelpButton") as MovieClip);
         this.mHelpButton.setTip(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_SEND_GIFT_BUTTON));
         this.mWishButton = new DynamicButton(mBox.getChildByName("StatisticsButton") as MovieClip);
         this.mWishButton.setLabel(TextManager.getText(TextIDs.TID_GIFTS_TAB_RECOMMENDED));
         this.mScrollRect = new Sprite();
         this.mType = this.TYPE_FRIENDS;
         this.mSearchBox = Sprite(mBox.getChildByName("search"));
         this.mSearchText = this.mSearchBox.getChildByName("SearchText") as TextField;
         TextManager.reformatTextField(this.mSearchText);
         this.mSearchText.text = "";
         this.mTitle = TextField(mBox.getChildByName("Caption"));
         this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_SEND_GIFT_BUTTON);
         TextManager.reformatTextField(this.mTitle);
         super();
      }
      
      override public function destroy() : void
      {
         mCancelButton.destroy();
         mCancelButton = null;
         this.mNeighboursButton.destroy();
         this.mNeighboursButton = null;
         this.mAllFriendsButton.destroy();
         this.mAllFriendsButton = null;
         this.mArrowUp.destroy();
         this.mArrowUp = null;
         this.mArrowDown.destroy();
         this.mArrowDown = null;
         this.mSearchBox.removeChild(this.mSearchText);
         this.mSearchText = null;
         mBox.removeChild(this.mSearchBox);
         this.mSearchBox = null;
         mBox = null;
      }
      
      private function onWishFriends(param1:MouseEvent) : void
      {
         this.removeItems(this.mType);
         this.mCurrentTypeFriends = this.FRIENDS_WISH;
         this.getFriends("");
         this.mAllFriendsButton.enable();
         this.mAllFriendsButton.getButtonMc().alpha = 1;
         this.mWishButton.disable();
         this.mWishButton.getButtonMc().alpha = 0.5;
         this.mNeighboursButton.enable();
         this.mNeighboursButton.getButtonMc().alpha = 1;
      }
      
      public function onScrollDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!this.mScrolling)
         {
            this.mScrollOrigin = this.mScrollRect.scrollRect.y;
            _loc2_ = this.mItemsY;
            if(this.mNumScrolls + _loc2_ > this.mMaxScrolls)
            {
               _loc2_ = this.mMaxScrolls - this.mNumScrolls;
            }
            if(this.mNumScrolls < this.mMaxScrolls)
            {
               this.mMaxOffset = this.mScrollOffsetY * _loc2_;
               this.mScrollTimer = setInterval(this.ScrollToNext,5);
               this.mScrollSpeed = this.mScrollOffsetY;
               this.mDist = this.mMaxOffset;
               this.mScrolling = true;
               this.mArrowUp.enable();
            }
         }
      }
      
      private function removeItems(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:InvestFriendContent = null;
         if(this.mItems != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.mItems.length)
            {
               if(this.mItems[_loc2_] is InvestFriendContent)
               {
                  _loc3_ = this.mItems[_loc2_];
                  _loc3_.removeEventListener(MouseEvent.CLICK,this.onSendCollectible);
                  this.mScrollRect.removeChild(_loc3_);
                  _loc3_.destroy();
                  _loc3_ = null;
               }
               this.mItems[_loc2_] = null;
               _loc2_++;
            }
            this.mItems = null;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mNeighboursButton.start();
         this.mNeighboursButton.addEventListener(MouseEvent.CLICK,this.onNeighbourFriends);
         this.mAllFriendsButton.start();
         this.mAllFriendsButton.addEventListener(MouseEvent.CLICK,this.onAllFriends);
         this.mHelpButton.start();
         this.mHelpButton.visible = false;
         this.mWishButton.start();
         this.mWishButton.addEventListener(MouseEvent.CLICK,this.onWishFriends);
         this.mArrowUp.start();
         this.mArrowUp.addEventListener(MouseEvent.CLICK,this.onScrollUp);
         this.mArrowDown.start();
         this.mArrowDown.addEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mSearchText.addEventListener(Event.CHANGE,this.searchFriends);
         this.mSearchText.addEventListener(MouseEvent.CLICK,this.checkFullscreen);
         startShow();
         this.onNeighbourFriends(null);
      }
      
      private function onNeighbourFriends(param1:MouseEvent) : void
      {
         this.removeItems(this.mType);
         this.mCurrentTypeFriends = this.FRIENDS_MILLIONAIRE;
         this.getFriends("");
         this.mAllFriendsButton.enable();
         this.mAllFriendsButton.getButtonMc().alpha = 1;
         this.mWishButton.enable();
         this.mWishButton.getButtonMc().alpha = 1;
         this.mNeighboursButton.disable();
         this.mNeighboursButton.getButtonMc().alpha = 0.5;
      }
      
      private function onCancel(param1:Event) : void
      {
         this.mPopupConfirmDestroy.removeEventListener(Popup.EVENT_ACCEPT,this.onAcceptChange);
         this.mPopupConfirmDestroy.removeEventListener(Popup.EVENT_CLOSE,this.onCancel);
         this.mPopupConfirmDestroy.destroy();
         this.mPopupConfirmDestroy = null;
      }
      
      public function onNewSending(param1:MouseEvent) : void
      {
         if(!this.mScrolling)
         {
            this.mType = this.TYPE_FRIENDS;
            this.mSearchBox.visible = true;
            this.mSearchText.text = "";
            this.getFriends("");
            this.mTitle.text = TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_SEND_GIFT_BUTTON);
            this.mArrowUp.visible = true;
            this.mArrowDown.visible = true;
         }
      }
      
      private function ScrollToNext() : void
      {
         var _loc1_:Rectangle = this.mScrollRect.scrollRect;
         _loc1_.y += this.mScrollSpeed;
         this.mDist -= this.mScrollSpeed;
         if(_loc1_.y > this.mScrollOrigin + this.mMaxOffset)
         {
            clearInterval(this.mScrollTimer);
            _loc1_.y = this.mScrollOrigin + this.mMaxOffset;
            this.mNumScrolls += int(this.mMaxOffset / this.mScrollOffsetY);
            this.mScrolling = false;
            mBox.mouseChildren = true;
         }
         this.mScrollRect.scrollRect = _loc1_;
         this.mScrollSpeed = this.mDist * this.mScrollOffsetY / this.mMaxOffset + 2;
         this.checkFriendInScreen();
         if(this.mNumScrolls == this.mMaxScrolls)
         {
            this.mArrowUp.enable();
            this.mArrowDown.disable();
         }
      }
      
      private function searchFriends(param1:Event) : void
      {
         this.getFriends(this.mSearchText.text);
      }
      
      private function getFriends(param1:String) : void
      {
         var _loc6_:Vector.<NeighborObject> = null;
         var _loc7_:Vector.<FriendObject> = null;
         var _loc8_:int = 0;
         var _loc10_:FriendObject = null;
         var _loc11_:int = 0;
         var _loc12_:InvestFriendContent = null;
         var _loc2_:Number = -181.5;
         var _loc3_:Number = -140.9;
         var _loc4_:int = 94;
         var _loc5_:int = 110;
         this.removeItems(this.TYPE_FRIENDS);
         this.mScrollRect.scrollRect = new Rectangle(_loc2_,_loc3_ - 11,_loc4_ * 4,_loc5_ * 3 + 5);
         this.mItems = new Vector.<InvestFriendContent>();
         switch(this.mCurrentTypeFriends)
         {
            case this.FRIENDS_MILLIONAIRE:
               _loc6_ = FriendsManager.getNeighborsNoAdvisors();
               this.mWished = false;
               _loc8_ = int(_loc6_.length);
               break;
            case this.FRIENDS_WISH:
               _loc6_ = FriendsManager.getFriendsByCollectibleSku(this.mCollectibleSku);
               this.mWished = true;
               if(_loc8_ <= 0)
               {
                  _loc6_ = FriendsManager.getNeighborsRandomly();
                  this.mWished = false;
               }
               _loc8_ = int(_loc6_.length);
               break;
            case this.FRIENDS_ALL:
               _loc7_ = FriendsManager.getFriendsNoAdvisors();
               this.mWished = false;
               _loc8_ = int(_loc7_.length);
         }
         var _loc9_:int = 0;
         if(_loc8_ > 0)
         {
            _loc11_ = 0;
            for(; _loc11_ < _loc8_; _loc11_++)
            {
               if(this.mCurrentTypeFriends == this.FRIENDS_ALL)
               {
                  _loc10_ = _loc7_[_loc11_];
               }
               else
               {
                  _loc10_ = _loc6_[_loc11_];
               }
               if(param1 != "")
               {
                  if(_loc10_.nameFriend.toLowerCase().indexOf(param1.toLowerCase()) != 0)
                  {
                     continue;
                  }
               }
               _loc12_ = new InvestFriendContent(_loc10_);
               _loc12_.x = _loc2_ + _loc4_ * (_loc9_ % 4) + _loc12_.width / 2;
               _loc12_.y = _loc3_ + _loc5_ * int(_loc9_ / 4) + _loc12_.height / 2;
               _loc12_.addEventListener(MouseEvent.CLICK,this.onSendCollectible);
               this.mScrollRect.addChild(_loc12_);
               this.mItems.push(_loc12_);
               _loc9_++;
            }
            mBox.addChild(this.mScrollRect);
            this.mScrollRect.x = _loc2_;
            this.mScrollRect.y = _loc3_ - 10;
         }
         this.mNumScrolls = 0;
         this.mMaxScrolls = int(this.mItems.length / 12) * 3 - 3;
         if(this.mItems.length % 12 != 0)
         {
            ++this.mMaxScrolls;
         }
         this.mScrollOffsetY = _loc5_;
         this.mItemsY = 3;
         this.mScrolling = false;
         this.mArrowUp.disable();
         this.mArrowDown.enable();
         if(this.mNumScrolls >= this.mMaxScrolls)
         {
            this.mArrowDown.disable();
         }
         this.checkFriendInScreen();
      }
      
      private function checkFullscreen(param1:MouseEvent) : void
      {
         if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
         {
            this.mPopupConfirmDestroy = new PopupConfirmDestroy();
            this.mPopupConfirmDestroy.showPopUp(-1,TextManager.getText(TextIDs.TID_INSERT_TEXT));
            this.mPopupConfirmDestroy.addEventListener(Popup.EVENT_ACCEPT,this.onAcceptChange);
            this.mPopupConfirmDestroy.addEventListener(Popup.EVENT_CLOSE,this.onCancel);
            Dollars.smStage.focus = Dollars.smStage;
         }
      }
      
      public function onScrollUp(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!this.mScrolling)
         {
            this.mScrollOrigin = this.mScrollRect.scrollRect.y;
            _loc2_ = this.mItemsY;
            if(this.mNumScrolls - _loc2_ < 0)
            {
               _loc2_ = this.mNumScrolls;
            }
            if(this.mNumScrolls > 0)
            {
               this.mMaxOffset = -this.mScrollOffsetY * _loc2_;
               this.mScrollTimer = setInterval(this.ScrollToPrevious,5);
               this.mScrollSpeed = -this.mScrollOffsetY;
               this.mDist = this.mMaxOffset;
               this.mScrolling = true;
               this.mArrowDown.enable();
            }
         }
      }
      
      private function onAcceptChange(param1:Event) : void
      {
         this.onCancel(null);
         Dollars.smStage.displayState = StageDisplayState.NORMAL;
      }
      
      private function onAllFriends(param1:MouseEvent) : void
      {
         this.removeItems(this.mType);
         this.mCurrentTypeFriends = this.FRIENDS_ALL;
         this.getFriends("");
         this.mAllFriendsButton.disable();
         this.mAllFriendsButton.getButtonMc().alpha = 0.5;
         this.mWishButton.enable();
         this.mWishButton.getButtonMc().alpha = 1;
         this.mNeighboursButton.enable();
         this.mNeighboursButton.getButtonMc().alpha = 1;
      }
      
      private function ScrollToPrevious() : void
      {
         var _loc1_:Rectangle = this.mScrollRect.scrollRect;
         _loc1_.y += this.mScrollSpeed;
         this.mDist -= this.mScrollSpeed;
         if(_loc1_.y < this.mScrollOrigin + this.mMaxOffset)
         {
            clearInterval(this.mScrollTimer);
            _loc1_.y = this.mScrollOrigin + this.mMaxOffset;
            this.mNumScrolls += int(this.mMaxOffset / this.mScrollOffsetY);
            this.mScrolling = false;
            mBox.mouseChildren = true;
         }
         this.mScrollRect.scrollRect = _loc1_;
         this.mScrollSpeed = this.mDist * -this.mScrollOffsetY / this.mMaxOffset - 2;
         this.checkFriendInScreen();
         if(this.mNumScrolls == 0)
         {
            this.mArrowUp.disable();
            this.mArrowDown.enable();
         }
      }
      
      override protected function close() : void
      {
         super.close();
         PopupCollectibleManager.getInstance().dispatchEvent(new Event(PopupCollectibleManager.WELLCOME_EVENT));
         this.mScrolling = false;
         mCancelButton.end();
         this.mNeighboursButton.end();
         this.mNeighboursButton.removeEventListener(MouseEvent.CLICK,this.onNeighbourFriends);
         this.mAllFriendsButton.end();
         this.mAllFriendsButton.removeEventListener(MouseEvent.CLICK,this.onAllFriends);
         this.mHelpButton.end();
         this.mWishButton.end();
         this.mWishButton.removeEventListener(MouseEvent.CLICK,this.onWishFriends);
         this.mArrowUp.end();
         this.mArrowUp.removeEventListener(MouseEvent.CLICK,this.onScrollUp);
         this.mArrowDown.end();
         this.mArrowDown.removeEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mSearchText.removeEventListener(Event.CHANGE,this.searchFriends);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         this.removeItems(this.mType);
         dispatchEvent(new Event(EVENT_CLOSE));
         if(PopupCollectibleManager.getInstance().smPopupCollectiblePendingList)
         {
            PopupCollectibleManager.getInstance().smPopupCollectiblePendingList.dispatchEvent(new Event(PopupPendingCollectiblesList.EVENT_PENDING_COLLECTIBLE_REMOVED));
            PopupCollectibleManager.getInstance().smPopupCollectiblePendingList.dispatchEvent(new Event(PopupPendingCollectiblesList.EVENT_CHECK_EMPTY_LIST));
         }
      }
      
      private function checkFriendInScreen() : void
      {
         var _loc2_:InvestFriendContent = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.mItems.length)
         {
            if(this.mType == this.TYPE_FRIENDS)
            {
               _loc2_ = this.mItems[_loc1_];
               if(_loc2_.y + _loc2_.height - this.mScrollRect.scrollRect.y < 0 || _loc2_.y - this.mScrollRect.scrollRect.y > this.mScrollRect.scrollRect.height)
               {
                  _loc2_.removeImage();
               }
               else
               {
                  _loc2_.loadImage();
               }
            }
            _loc1_++;
         }
      }
      
      private function onSendCollectible(param1:MouseEvent) : void
      {
         var _loc5_:String = null;
         var _loc2_:InvestFriendContent = param1.target as InvestFriendContent;
         var _loc3_:FriendObject = _loc2_.getFriendObject();
         var _loc4_:Object = UserDataFacade.securityCreateObj(0,0,0);
         var _loc6_:CollectibleObject = CollectibleManager.getInstance().getCollectibleBySku(this.mCollectibleSku);
         if(_loc6_ != null)
         {
            _loc6_.getCollectibleDefinition().getFeedImg();
         }
         if(this.mItemObject != null)
         {
            _loc5_ = this.mItemObject.mSid;
            CollectibleManager.getInstance().removeCollectibleFromPending(_loc5_);
            if(this.mItemObject.itemDefinition.isACommerce())
            {
               this.mItemObject.getCurrentState().eventsProcess({"cmd":StateOnRent.CMD_COMMERCE_COLLECTIBLE_GOTTEN});
            }
            else
            {
               this.mItemObject.getCurrentState().eventsProcess({"cmd":StateOnRent.CMD_COLLECTIBLE_GOTTEN});
            }
         }
         else
         {
            _loc5_ = "v";
         }
         if(this.mWished)
         {
            FriendsManager.removeCollectibleFromFriendWishedList(_loc3_.extId,this.mCollectibleSku);
         }
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_SEND_COLLECTIBLE,{
            "fExtId":_loc3_.extId,
            "sku":this.mCollectibleSku,
            "CollectibleName":TextManager.getText(TextIDs[_loc6_.getCollectibleDefinition().textID]),
            "collectibleFeed":_loc6_.getCollectibleDefinition().getFeedImg()
         });
         UserDataFacade.getInstance().updateCollectible(_loc5_,this.mCollectibleSku,"SEND",String(_loc3_.extId),{},_loc4_);
         onClose(null);
      }
   }
}

