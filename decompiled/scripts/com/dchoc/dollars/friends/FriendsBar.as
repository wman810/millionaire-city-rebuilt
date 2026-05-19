package com.dchoc.dollars.friends
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.accelerators.AcceleratorDefinition;
   import com.dchoc.dollars.world.accelerators.AcceleratorDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class FriendsBar extends EventDispatcher
   {
      
      private static var mFriendsBarHeight:Number;
      
      private static var mFriendsBarWidth:Number;
      
      private static const FRIENDS_PER_PAGE:int = 8;
      
      private var mNext:DynamicButton;
      
      private var mBackgroundHeight:Number;
      
      private var mLoadingIndex:int;
      
      private var mNeighborsContent:Vector.<FriendsBarContent>;
      
      private var mPrevious:DynamicButton;
      
      private var mLoading:MovieClip;
      
      private var mEnabled:Boolean;
      
      private var mMyContainer:FriendsBarContentFriend;
      
      private var mFriendsContainer:Sprite;
      
      private var mLast:DynamicButton;
      
      private var mDisplaySave:TextField;
      
      private var mCurrentCursor:int;
      
      private var mFirst:DynamicButton;
      
      private var mMyRank:int;
      
      private var mTimeButtons:Array;
      
      private var mFakeFriends:int;
      
      private var mFriendContentWidth:int;
      
      private var mTimerBox:TextField;
      
      private var mScrollIndex:int;
      
      private var mIsMouseOver:Boolean;
      
      private var mNeighborsLoaded:Boolean;
      
      private var mBackground:Sprite;
      
      private var mLoadingTimer:Number;
      
      public function FriendsBar()
      {
         super();
         this.mBackground = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"friends_bar"))();
         this.mBackgroundHeight = this.mBackground.height;
         mFriendsBarHeight = this.mBackground.height;
         mFriendsBarWidth = this.mBackground.width;
         this.mLoading = this.mBackground["loading"];
         this.mLoading.gotoAndPlay(1);
         this.mLoadingTimer = 0;
         this.mFriendsContainer = this.mBackground["friends_container"];
         this.mFriendsContainer.scrollRect = new Rectangle(0,0,this.mFriendsContainer.width,this.mFriendsContainer.height);
         var _loc1_:Sprite = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box"))();
         this.mFriendContentWidth = _loc1_.width;
         this.mScrollIndex = 0;
         this.mPrevious = new DynamicButton(this.mBackground["mArrowLeft01"]);
         this.mPrevious.start();
         this.mFirst = new DynamicButton(this.mBackground["mArrowLeft03"]);
         this.mFirst.start();
         this.mNext = new DynamicButton(this.mBackground["mArrowRight01"]);
         this.mNext.start();
         this.mLast = new DynamicButton(this.mBackground["mArrowRight03"]);
         this.mLast.start();
         this.mNeighborsLoaded = FriendsManager.smFriendsLoaded;
         var _loc2_:MovieClip = this.mBackground["InviteRandom"];
         var _loc3_:TextField = _loc2_["Invite"];
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = TextManager.getText(TextIDs.TID_BUTTON_TEXT_ADDNEIGHBORS);
         TextManager.setTextScaled(_loc3_,false);
         this.setEnabled(true);
      }
      
      public static function getWidth() : Number
      {
         return mFriendsBarWidth;
      }
      
      public static function getHeight() : Number
      {
         return mFriendsBarHeight;
      }
      
      private function createNeighborContent(param1:NeighborObject, param2:int) : FriendsBarContent
      {
         var _loc3_:FriendsBarContent = null;
         if(param1.isPartner())
         {
            _loc3_ = new FriendsBarContentFriend(FriendsBarContentFriend.TYPE_PARTNER);
         }
         else if(param1.isMyself())
         {
            this.mMyContainer = new FriendsBarContentFriend(FriendsBarContentFriend.TYPE_MYSELF);
            _loc3_ = this.mMyContainer;
            this.mMyRank = param2;
         }
         else
         {
            _loc3_ = new FriendsBarContentFriend(FriendsBarContentFriend.TYPE_NORMAL);
         }
         _loc3_.loadFriend(param1,param2);
         return _loc3_;
      }
      
      private function buildNeighborsContent() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:FriendsBarContent = null;
         var _loc5_:int = 0;
         var _loc6_:NeighborObject = null;
         var _loc1_:Vector.<NeighborObject> = FriendsManager.getSortedNeightbors();
         if(_loc1_ != null && _loc1_.length > 0)
         {
            _loc2_ = FriendsBar.FRIENDS_PER_PAGE - _loc1_.length;
            this.mNeighborsContent = new Vector.<FriendsBarContent>();
            this.mLoadingIndex = 0;
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            if(_loc1_ != null)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc2_)
               {
                  _loc4_ = new FriendsBarContentAdd();
                  this.mNeighborsContent.push(_loc4_);
                  _loc5_++;
               }
               for each(_loc6_ in _loc1_)
               {
                  _loc3_ = _loc1_.length - (this.mNeighborsContent.length - _loc2_);
                  _loc4_ = this.createNeighborContent(_loc6_,_loc3_);
                  this.mNeighborsContent.push(_loc4_);
               }
            }
         }
      }
      
      private function onSaveWorld(param1:MouseEvent) : void
      {
         UserDataFacade.getInstance().saveUniverse(DollarsGame.getCurrentUniverse().getPersistence());
      }
      
      private function mouseOver() : void
      {
         this.mCurrentCursor = Dollars.getCurrentCursor().mCurrentCursorID;
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
      }
      
      private function lastPageIndex() : int
      {
         return this.mNeighborsContent.length - FriendsBar.FRIENDS_PER_PAGE;
      }
      
      public function centerFriendsBar() : void
      {
         var _loc1_:int = Math.floor((this.mNeighborsContent.length + 1 - this.mMyRank) / FriendsBar.FRIENDS_PER_PAGE);
         var _loc2_:int = Math.floor(this.mScrollIndex / FriendsBar.FRIENDS_PER_PAGE);
         var _loc3_:* = int(_loc1_ - _loc2_);
         if(_loc3_ < 0)
         {
            while(_loc3_ < 0)
            {
               this.scrollPrevious(null);
               _loc3_++;
            }
         }
         else if(_loc3_ > 0)
         {
            while(_loc3_ > 0)
            {
               this.scrollNext(null);
               _loc3_--;
            }
         }
         this.loadNeighborsPictures(this.mScrollIndex,this.mScrollIndex + FriendsBar.FRIENDS_PER_PAGE);
      }
      
      private function destroyNeighborsContent() : void
      {
         var _loc1_:FriendsBarContent = null;
         if(this.mNeighborsContent != null)
         {
            this.ereaseNeighbors();
            for each(_loc1_ in this.mNeighborsContent)
            {
               _loc1_.destroy();
               _loc1_ = null;
            }
            this.mNeighborsContent.length = 0;
         }
      }
      
      public function visibleTimeButtons() : void
      {
         var _loc2_:Sprite = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.mTimeButtons.length)
         {
            _loc2_ = this.mTimeButtons[_loc1_];
            _loc2_.visible = true;
            _loc1_++;
         }
         this.mTimerBox = new TextField();
         this.mTimerBox.width = 100;
         this.mTimerBox.height = 30;
         this.mTimerBox.y = Config.SCREEN_HEIGHT - 100;
         this.mTimerBox.backgroundColor = 65280;
         this.mTimerBox.background = true;
         this.mBackground.addChild(this.mTimerBox);
         this.showSaveButton();
      }
      
      public function getBackground() : Sprite
      {
         return this.mBackground;
      }
      
      private function scrollLast(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = this.mFriendsContainer.scrollRect;
         _loc2_.x = (this.mNeighborsContent.length - FriendsBar.FRIENDS_PER_PAGE) * this.mFriendContentWidth;
         this.mFriendsContainer.scrollRect = _loc2_;
         this.mScrollIndex = this.lastPageIndex();
         this.loadNeighborsPictures(this.mScrollIndex,this.mNeighborsContent.length);
      }
      
      public function resize() : void
      {
         this.mBackground.x = (Dollars.smStage.stageWidth - mFriendsBarWidth) / 2;
         this.mBackground.y = Dollars.smStage.stageHeight;
      }
      
      public function refreshBar() : void
      {
         if(this.mNeighborsContent != null && this.mNeighborsContent.length > 0)
         {
            this.destroyNeighborsContent();
            this.buildNeighborsContent();
         }
      }
      
      public function enable() : void
      {
         this.mBackground.mouseEnabled = true;
         this.mBackground.mouseChildren = true;
      }
      
      private function showSaveButton() : void
      {
         this.mDisplaySave = new TextField();
         this.mDisplaySave.text = "SAVE WORLD";
         this.mDisplaySave.background = true;
         this.mDisplaySave.backgroundColor = 16711680;
         this.mDisplaySave.x = this.mBackground.x + this.mDisplaySave.width;
         this.mDisplaySave.y = this.mBackground.y - this.mBackground.height;
         this.mDisplaySave.width = this.mDisplaySave.textWidth + 10;
         this.mDisplaySave.height = this.mDisplaySave.textHeight + 10;
         this.mDisplaySave.addEventListener(MouseEvent.CLICK,this.onSaveWorld);
         this.mBackground.addChild(this.mDisplaySave);
      }
      
      private function onInvite(param1:MouseEvent) : void
      {
         if(Config.USE_NEIGHBOR_REQUESTS)
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_NEIGHBOR_REQUEST,{});
         }
         else
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_HELP_INVITE_FRIEND);
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         this.mLoadingTimer += param1;
         var _loc2_:Number = Dollars.smStage.mouseX;
         var _loc3_:Number = Dollars.smStage.mouseY;
         if(!this.mIsMouseOver && this.isOverBar(_loc2_,_loc3_))
         {
            this.mIsMouseOver = true;
            this.mouseOver();
         }
         else if(this.mIsMouseOver && !this.isOverBar(_loc2_,_loc3_))
         {
            this.mIsMouseOver = false;
            this.mouseOut();
         }
         if(!this.mNeighborsLoaded && FriendsManager.smFriendsLoaded)
         {
            this.mLoading.visible = false;
            this.buildNeighborsContent();
            this.drawNeighbors();
            this.centerFriendsBar();
            this.mNeighborsLoaded = true;
         }
         if(this.mNeighborsLoaded)
         {
            if(this.mFriendsContainer.scrollRect.x <= 0)
            {
               this.mFirst.disable();
               this.mPrevious.disable();
            }
            else if(!this.mFirst.Enabled)
            {
               this.mFirst.enable();
               this.mPrevious.enable();
            }
            if(this.mFriendsContainer.scrollRect.x >= (this.mNeighborsContent.length - FriendsBar.FRIENDS_PER_PAGE) * this.mFriendContentWidth)
            {
               this.mLast.disable();
               this.mNext.disable();
            }
            else if(!this.mLast.Enabled)
            {
               this.mLast.enable();
               this.mNext.enable();
            }
            if(this.mMyRank > 1)
            {
               if(this.mNeighborsContent[this.mNeighborsContent.length - this.mMyRank].getNeighborObject().companyValue > this.mNeighborsContent[this.mNeighborsContent.length - this.mMyRank + 1].getNeighborObject().companyValue)
               {
                  this.refreshBar();
               }
            }
         }
      }
      
      public function setTime(param1:int) : void
      {
         if(this.mTimerBox != null)
         {
            this.mTimerBox.text = TextManager.getStringFromTime(param1);
         }
      }
      
      private function loadNeighborsPictures(param1:int, param2:int) : void
      {
         var _loc3_:int = param1;
         while(_loc3_ < param2)
         {
            if(!this.mNeighborsContent[_loc3_].isLoadComplete())
            {
               this.mNeighborsContent[_loc3_].loadImage();
               this.mNeighborsContent[_loc3_].setIsLoadComplete(true);
            }
            _loc3_++;
         }
      }
      
      private function getExtraTime(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc2_:TextField = param1.target as TextField;
         if(_loc2_ != null)
         {
            _loc3_ = TextManager.convertStringToTime(_loc2_.text);
            _loc4_ = _loc3_ / 60000;
            DollarsGame.setTimeOffset(_loc4_);
         }
      }
      
      public function refreshFriend(param1:int) : void
      {
         var _loc2_:FriendsBarContent = this.mNeighborsContent[this.getNeighborContentId(param1)];
         _loc2_.updateCompanyValue();
         _loc2_.updateExp();
      }
      
      public function end() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         this.mPrevious.removeEventListener(MouseEvent.CLICK,this.scrollPrevious);
         this.mFirst.removeEventListener(MouseEvent.CLICK,this.scrollFirst);
         this.mNext.removeEventListener(MouseEvent.CLICK,this.scrollNext);
         this.mLast.removeEventListener(MouseEvent.CLICK,this.scrollLast);
         var _loc1_:MovieClip = this.mBackground["InviteRandom"];
         _loc1_.removeEventListener(MouseEvent.CLICK,this.onInvite);
         if(this.mBackground != null)
         {
            if(this.mDisplaySave != null)
            {
               this.mDisplaySave.removeEventListener(MouseEvent.CLICK,this.onSaveWorld);
               this.mBackground.removeChild(this.mDisplaySave);
               this.mDisplaySave = null;
            }
            if(Config.cheatsAreEnabled(Config.CHEAT_TIME_ID))
            {
               _loc2_ = 0;
               while(_loc2_ < this.mTimeButtons.length)
               {
                  _loc3_ = this.mTimeButtons[_loc2_] as Sprite;
                  this.mBackground.removeChild(_loc3_);
                  _loc2_++;
               }
               this.mTimeButtons = null;
            }
         }
      }
      
      private function drawNeighbors() : void
      {
         var _loc2_:FriendsBarContent = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.mNeighborsContent)
         {
            if(_loc2_ != null && !this.mFriendsContainer.contains(_loc2_.getBox()))
            {
               this.mFriendsContainer.addChild(_loc2_.getBox());
               _loc2_.getBox().x = this.mFriendContentWidth * _loc1_;
            }
            _loc1_++;
         }
      }
      
      private function scrollNext(param1:MouseEvent) : void
      {
         var _loc2_:Number = (this.mNeighborsContent.length - FriendsBar.FRIENDS_PER_PAGE) * this.mFriendContentWidth;
         var _loc3_:Rectangle = this.mFriendsContainer.scrollRect;
         _loc3_.x += FriendsBar.FRIENDS_PER_PAGE * this.mFriendContentWidth;
         this.mScrollIndex += FriendsBar.FRIENDS_PER_PAGE;
         if(_loc3_.x > _loc2_)
         {
            _loc3_.x = _loc2_;
            this.mScrollIndex = _loc2_ / this.mFriendContentWidth;
         }
         this.mFriendsContainer.scrollRect = _loc3_;
         if(this.mNeighborsLoaded)
         {
            this.loadNeighborsPictures(this.mScrollIndex,this.mScrollIndex + FriendsBar.FRIENDS_PER_PAGE);
         }
      }
      
      private function scrollFirst(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = this.mFriendsContainer.scrollRect;
         _loc2_.x = 0;
         this.mFriendsContainer.scrollRect = _loc2_;
         this.mScrollIndex = 0;
         this.loadNeighborsPictures(this.mScrollIndex,FriendsBar.FRIENDS_PER_PAGE);
      }
      
      private function ereaseNeighbors() : void
      {
         var _loc2_:FriendsBarContent = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.mNeighborsContent)
         {
            if(_loc2_ != null && this.mFriendsContainer.contains(_loc2_.getBox()))
            {
               this.mFriendsContainer.removeChild(_loc2_.getBox());
            }
         }
         this.mNeighborsLoaded = false;
      }
      
      public function disable() : void
      {
         this.mBackground.mouseEnabled = false;
         this.mBackground.mouseChildren = false;
      }
      
      private function mouseOut() : void
      {
         Dollars.getCurrentCursor().changeCursor(this.mCurrentCursor);
      }
      
      public function refreshMySelf() : void
      {
         if(this.mMyContainer != null)
         {
            this.mMyContainer.updateCompanyValue();
            this.mMyContainer.updateExp();
         }
      }
      
      public function start() : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Sprite = null;
         var _loc5_:TextField = null;
         var _loc6_:AcceleratorDefinition = null;
         this.mPrevious.addEventListener(MouseEvent.CLICK,this.scrollPrevious);
         this.mFirst.addEventListener(MouseEvent.CLICK,this.scrollFirst);
         this.mNext.addEventListener(MouseEvent.CLICK,this.scrollNext);
         this.mLast.addEventListener(MouseEvent.CLICK,this.scrollLast);
         var _loc1_:MovieClip = this.mBackground["InviteRandom"];
         _loc1_.addEventListener(MouseEvent.CLICK,this.onInvite);
         if(Config.cheatsAreEnabled(Config.CHEAT_TIME_ID))
         {
            this.mTimeButtons = new Array();
            _loc2_ = AcceleratorDefinitionManager.getInstance().getDefinitions(0);
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = new Sprite();
               _loc5_ = new TextField();
               _loc6_ = _loc2_[_loc3_];
               _loc5_.text = _loc6_.sku;
               _loc5_.width = _loc5_.textWidth + 10;
               _loc5_.height = _loc5_.textHeight + 10;
               _loc5_.selectable = false;
               _loc4_.addChild(_loc5_);
               _loc4_.graphics.beginFill(65280);
               _loc4_.graphics.drawRect(-5,-5,_loc5_.width + 10,_loc5_.height + 10);
               _loc4_.graphics.endFill();
               this.mBackground.addChild(_loc4_);
               this.mTimeButtons.push(_loc4_);
               _loc4_.addEventListener(MouseEvent.CLICK,this.getExtraTime);
               _loc4_.visible = false;
               _loc4_.x = _loc3_ * (_loc5_.width + 30);
               _loc4_.y = -_loc5_.height;
               _loc3_++;
            }
         }
      }
      
      private function getNeighborContentId(param1:int) : int
      {
         var _loc3_:FriendsBarContent = null;
         var _loc2_:* = int(this.mNeighborsContent.length);
         for each(_loc3_ in this.mNeighborsContent)
         {
            if(_loc3_.getNeighborObject().userId == param1)
            {
               return _loc2_;
            }
            _loc2_--;
         }
         return this.mMyRank;
      }
      
      private function isOverBar(param1:Number, param2:Number) : Boolean
      {
         if(this.mBackground.x <= param1 <= this.mBackground.x + this.mBackground.width && param2 >= this.mBackground.y - this.mBackgroundHeight)
         {
            return true;
         }
         return false;
      }
      
      public function destroy() : void
      {
         this.end();
         this.destroyNeighborsContent();
         if(this.mBackground != null)
         {
            this.mBackground = null;
         }
         if(this.mDisplaySave != null)
         {
            this.mDisplaySave = null;
         }
         this.mNeighborsContent.length = 0;
      }
      
      private function scrollPrevious(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = this.mFriendsContainer.scrollRect;
         _loc2_.x -= FriendsBar.FRIENDS_PER_PAGE * this.mFriendContentWidth;
         this.mScrollIndex -= FriendsBar.FRIENDS_PER_PAGE;
         if(_loc2_.x < 0)
         {
            _loc2_.x = 0;
            this.mScrollIndex = 0;
         }
         this.mFriendsContainer.scrollRect = _loc2_;
         if(this.mNeighborsLoaded)
         {
            this.loadNeighborsPictures(this.mScrollIndex,this.mScrollIndex + FriendsBar.FRIENDS_PER_PAGE);
         }
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         var _loc2_:FriendsBarContent = null;
         this.mEnabled = param1;
         for each(_loc2_ in this.mNeighborsContent)
         {
            if(_loc2_ != null)
            {
               _loc2_.setEnabled(param1);
            }
         }
      }
   }
}

