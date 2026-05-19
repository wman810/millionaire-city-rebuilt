package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.containers.InvestFriendContent;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.invests.InvestDefinition;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.rewards.RewardCoins;
   import com.dchoc.dollars.rewards.RewardSingle;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class PopupInvest extends Popup
   {
      
      public static const SKU:String = "Investments";
      
      private var mInfoScreen:MovieClip;
      
      private var mScrolling:Boolean;
      
      private var mStatsButton:DynamicButton;
      
      private var mMaxScrolls:int;
      
      private var mTextInfo:TextField;
      
      private var mNewInvestButton:DynamicButton;
      
      private var mHelpButton:DynamicButton;
      
      private const TYPE_INVEST:int = 1;
      
      private var mScrollRect:Sprite;
      
      private var mPopupHelp:PopupHelpInvest;
      
      private var mMaxOffset:int;
      
      private var mScrollOffsetY:int;
      
      private var mNumScrolls:int;
      
      private var mDist:Number;
      
      private var mPopupInvestStart:PopupInvestStart;
      
      private var mSearchBox:Sprite;
      
      private const TYPE_STATS:int = 2;
      
      private var mCheckInvestButton:DynamicButton;
      
      private var mSearchText:TextField;
      
      private var mScrollTimer:int;
      
      private var mScrollSpeed:Number;
      
      private var mType:int;
      
      private var mItems:Array;
      
      private var mArrowUp:DynamicButton;
      
      private var mSelectFriendsButton:DynamicButton;
      
      private var mArrowDown:DynamicButton;
      
      private var mScrollOrigin:int;
      
      private var mTitle:TextField;
      
      private var mItemsY:int;
      
      private const TYPE_FRIENDS:int = 0;
      
      private var mStatsPanel:Sprite;
      
      private var mTutorialArrow:MovieClip;
      
      public function PopupInvest()
      {
         var _loc2_:InvestDefinition = null;
         var _loc3_:RewardSingle = null;
         var _loc4_:String = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(SKU,"popup_investment_background"))();
         this.mStatsPanel = new (DCResourceManager.getInstance().getSWFClass(SKU,"popup_investment_statistics"))();
         mBox.addChild(this.mStatsPanel);
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         if(Config.INVESTMENT_REQUEST_ENABLED)
         {
            this.mInfoScreen = new (DCResourceManager.getInstance().getSWFClass(SKU,"popup_investment_select_friends"))();
            mBox.addChild(this.mInfoScreen);
            this.mSelectFriendsButton = new DynamicButton(this.mInfoScreen.getChildByName("SelectButton") as MovieClip);
            this.mSelectFriendsButton.setLabel(TextManager.getText(TextIDs.TID_INVESTMENTS_BUTTON));
            this.mTextInfo = this.mInfoScreen.getChildByName("TextInfo_01") as TextField;
            TextManager.reformatTextField(this.mTextInfo);
            _loc2_ = InvestDefinitionManager.getInstance().getInvestDefinition();
            _loc3_ = _loc2_.getReward() as RewardSingle;
            _loc4_ = "" + _loc3_.getAmount();
            if(_loc3_ is RewardCoins)
            {
               _loc4_ = "$" + _loc4_;
            }
            this.mTextInfo.text = TextManager.replaceParameters(TextIDs.TID_INVESTMENTS_RESUME,new Array("$" + _loc2_.target,"" + TimerUtil.msToDays(_loc2_.getTime()),_loc4_));
            TextManager.setTextScaled(this.mTextInfo);
            this.mInfoScreen.y += 25;
         }
         this.mNewInvestButton = new DynamicButton(mBox.getChildByName("NewButton") as MovieClip);
         var _loc1_:String = TextManager.getText(TextIDs.TID_INVEST_BUTTON1);
         this.mNewInvestButton.setLabel(_loc1_);
         this.mCheckInvestButton = new DynamicButton(mBox.getChildByName("CheckButton") as MovieClip);
         this.mCheckInvestButton.setLabel(TextManager.getText(TextIDs.TID_INVEST_BUTTON2));
         this.mArrowUp = new DynamicButton(mBox.getChildByName("mArrowUp") as MovieClip);
         this.mArrowDown = new DynamicButton(mBox.getChildByName("mArrowDown") as MovieClip);
         this.mHelpButton = new DynamicButton(mBox.getChildByName("HelpButton") as MovieClip);
         this.mHelpButton.setTip(TextManager.getText(TextIDs.TID_INVEST_HELP_TITLE));
         this.mTutorialArrow = new AssetManager.TutorialArrow();
         this.mTutorialArrow.rotation = 45;
         mBox.addChild(this.mTutorialArrow);
         this.mTutorialArrow.x = this.mHelpButton.getButtonMc().x;
         this.mTutorialArrow.y = this.mHelpButton.getButtonMc().y;
         this.mStatsButton = new DynamicButton(mBox.getChildByName("StatisticsButton") as MovieClip);
         this.mStatsButton.setLabel(TextManager.getText(TextIDs.TID_INVEST_STATS_TITLE));
         this.mScrollRect = new Sprite();
         this.mType = this.TYPE_FRIENDS;
         this.mPopupHelp = new PopupHelpInvest();
         this.mSearchBox = Sprite(mBox.getChildByName("search"));
         this.mSearchText = this.mSearchBox.getChildByName("SearchText") as TextField;
         TextManager.reformatTextField(this.mSearchText);
         this.mSearchText.text = "";
         this.mTitle = TextField(mBox.getChildByName("Caption"));
         TextManager.reformatTextField(this.mTitle);
         super();
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
      
      private function clearResources() : void
      {
         this.mArrowUp.visible = false;
         this.mArrowDown.visible = false;
         this.mSearchBox.visible = false;
         this.removeItems(this.TYPE_STATS);
         if(Config.INVESTMENT_REQUEST_ENABLED)
         {
            this.mInfoScreen.visible = false;
            this.mSelectFriendsButton.visible = false;
         }
         this.mStatsPanel.visible = false;
      }
      
      private function getInvestItems() : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:FriendObject = null;
         var _loc11_:InvestFriendInvestor = null;
         var _loc1_:Number = -185.5;
         var _loc2_:Number = -149.85;
         var _loc3_:int = 374;
         var _loc4_:int = 69;
         var _loc5_:int = 5;
         this.removeItems(this.TYPE_INVEST);
         this.mScrollRect.scrollRect = new Rectangle(_loc1_,_loc2_ - 5,_loc3_,_loc4_ * _loc5_ + 2);
         this.mItems = new Array();
         var _loc6_:Array = InvestManager.getInstance().getInvestmentsUI();
         var _loc7_:int = int(_loc6_.length);
         if(_loc7_ > 0)
         {
            _loc8_ = 0;
            _loc9_ = 0;
            while(_loc9_ < _loc7_)
            {
               _loc10_ = FriendsManager.getFriendByID(_loc6_[_loc9_].getExtId());
               if(_loc10_ != null)
               {
                  _loc11_ = new InvestFriendInvestor(_loc6_[_loc9_],_loc10_);
                  _loc11_.x = _loc1_;
                  _loc11_.y = _loc2_ + _loc4_ * _loc8_;
                  _loc11_.addEventListener(InvestFriendInvestor.EVENT_CANCEL_INVEST,this.onCancelInvestor);
                  this.mScrollRect.addChild(_loc11_);
                  this.mItems.push(_loc11_);
                  _loc8_++;
               }
               _loc9_++;
            }
            mBox.addChild(this.mScrollRect);
            this.mScrollRect.x = _loc1_;
            this.mScrollRect.y = _loc2_ - 5;
         }
         this.mNumScrolls = 0;
         this.mMaxScrolls = this.mItems.length - _loc5_;
         this.mScrollOffsetY = _loc4_;
         this.mItemsY = _loc5_;
         this.mScrolling = false;
         this.mArrowUp.disable();
         this.mArrowDown.enable();
         if(this.mNumScrolls >= this.mMaxScrolls)
         {
            this.mArrowDown.disable();
         }
         this.checkFriendInScreen();
      }
      
      private function showStats(param1:MouseEvent) : void
      {
         this.clearResources();
         if(!this.mScrolling)
         {
            this.mStatsPanel.visible = true;
            this.mTitle.text = TextManager.getText(TextIDs.TID_INVEST_STATS_TITLE);
            TextManager.setTextScaled(this.mTitle);
            TextManager.reformatTextField(TextField(this.mStatsPanel.getChildByName("TextInfo_03")));
            TextField(this.mStatsPanel.getChildByName("TextInfo_03")).text = TextManager.getText(TextIDs.TID_INVEST_STATS_1);
            TextField(this.mStatsPanel.getChildByName("TextInfo_03_01")).text = "" + InvestManager.getInstance().statsGetInvestmentsStartedCount();
            TextManager.reformatTextField(TextField(this.mStatsPanel.getChildByName("TextInfo_01")));
            TextField(this.mStatsPanel.getChildByName("TextInfo_01")).text = TextManager.getText(TextIDs.TID_INVEST_STATS_2);
            TextField(this.mStatsPanel.getChildByName("TextInfo_01_01")).text = "" + InvestManager.getInstance().statsGetInvestmentsSuccesfullyCount();
            TextManager.reformatTextField(TextField(this.mStatsPanel.getChildByName("TextInfo_02")));
            TextField(this.mStatsPanel.getChildByName("TextInfo_02")).text = TextManager.getText(TextIDs.TID_INVEST_STATS_3);
            TextField(this.mStatsPanel.getChildByName("TextInfo_02_01")).text = "" + InvestManager.getInstance().statsGetInvestmentSuccessPercentage();
            TextManager.setTextScaled(this.mStatsPanel.getChildByName("TextInfo_01") as TextField);
            TextManager.setTextScaled(this.mStatsPanel.getChildByName("TextInfo_02") as TextField);
            TextManager.setTextScaled(this.mStatsPanel.getChildByName("TextInfo_03") as TextField);
            this.mType = this.TYPE_STATS;
            this.mNewInvestButton.setUnselected();
            this.mStatsButton.setSelected();
            this.mCheckInvestButton.setUnselected();
         }
      }
      
      private function removeItems(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:InvestFriendContent = null;
         var _loc4_:InvestFriendInvestor = null;
         if(this.mItems != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.mItems.length)
            {
               if(this.mItems[_loc2_] is InvestFriendContent)
               {
                  _loc3_ = this.mItems[_loc2_];
                  this.mScrollRect.removeChild(_loc3_);
                  _loc3_.destroy();
                  _loc3_ = null;
               }
               else
               {
                  _loc4_ = this.mItems[_loc2_];
                  this.mScrollRect.removeChild(_loc4_);
                  _loc4_.destroy();
                  _loc4_ = null;
               }
               this.mItems[_loc2_] = null;
               _loc2_++;
            }
            this.mItems = null;
         }
      }
      
      private function checkFriendInScreen() : void
      {
         var _loc2_:InvestFriendContent = null;
         var _loc3_:InvestFriendInvestor = null;
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
            else
            {
               _loc3_ = this.mItems[_loc1_];
               if(_loc3_.y + _loc3_.height - this.mScrollRect.scrollRect.y < 0 || _loc3_.y - this.mScrollRect.scrollRect.y > this.mScrollRect.scrollRect.height)
               {
                  _loc3_.removeImage();
               }
               else
               {
                  _loc3_.loadImage();
               }
            }
            _loc1_++;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mNewInvestButton.start();
         this.mNewInvestButton.addEventListener(MouseEvent.CLICK,this.onNewInvest);
         this.mCheckInvestButton.start();
         this.mCheckInvestButton.addEventListener(MouseEvent.CLICK,this.onCheckInvest);
         this.mHelpButton.start();
         this.mHelpButton.addEventListener(MouseEvent.CLICK,this.onHelp);
         this.mStatsButton.start();
         this.mStatsButton.addEventListener(MouseEvent.CLICK,this.showStats);
         this.mArrowUp.start();
         this.mArrowDown.start();
         this.mArrowUp.addEventListener(MouseEvent.CLICK,this.onScrollUp);
         this.mArrowDown.addEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mArrowUp.visible = false;
         this.mArrowDown.visible = false;
         this.mSearchBox.visible = false;
         this.mSelectFriendsButton.start();
         this.mSelectFriendsButton.addEventListener(MouseEvent.CLICK,this.onGetFriends);
         this.onNewInvest(null);
         this.mTutorialArrow.visible = !DollarsGame.getProfile().investmentGetHelpShown();
         if(!DollarsGame.getProfile().investmentGetToolbarHelpShown())
         {
            DollarsGame.getCurrentRole().toolsBar.removeInvestmentArrow();
         }
         startShow();
      }
      
      private function onGetFriends(param1:MouseEvent) : void
      {
         onClose(null);
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVESTMENT_REQUEST,{"extId":UserDataFacade.getInstance().mUserId});
      }
      
      private function onCancel(param1:Event) : void
      {
      }
      
      private function onCheckInvest(param1:MouseEvent) : void
      {
         this.clearResources();
         if(!this.mScrolling)
         {
            this.removeItems(this.TYPE_FRIENDS);
            this.mType = this.TYPE_INVEST;
            this.getInvestItems();
            this.mTitle.text = TextManager.getText(TextIDs.TID_INVEST_TITLE2);
            TextManager.setTextScaled(this.mTitle);
            this.mArrowUp.visible = true;
            this.mArrowDown.visible = true;
            this.mNewInvestButton.setUnselected();
            this.mStatsButton.setUnselected();
            this.mCheckInvestButton.setSelected();
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
      
      private function getFriends(param1:String) : void
      {
         var _loc9_:int = 0;
         var _loc10_:FriendObject = null;
         var _loc11_:InvestFriendContent = null;
         var _loc2_:Number = -181.5;
         var _loc3_:Number = -140.9;
         var _loc4_:int = 94;
         var _loc5_:int = 110;
         this.removeItems(this.TYPE_FRIENDS);
         this.mScrollRect.scrollRect = new Rectangle(_loc2_,_loc3_ - 11,_loc4_ * 4,_loc5_ * 3 + 5);
         this.mItems = new Array();
         var _loc6_:Array = InvestManager.getInstance().getFriendsToInvest();
         var _loc7_:int = int(_loc6_.length);
         var _loc8_:int = 0;
         if(_loc7_ > 0)
         {
            _loc9_ = 0;
            for(; _loc9_ < _loc7_; _loc9_++)
            {
               _loc10_ = _loc6_[_loc9_];
               if(param1 != "")
               {
                  if(_loc10_.nameFriend.toLowerCase().indexOf(param1.toLowerCase()) != 0)
                  {
                     continue;
                  }
               }
               _loc11_ = new InvestFriendContent(_loc6_[_loc9_]);
               _loc11_.x = _loc2_ + _loc4_ * (_loc8_ % 4) + _loc11_.width / 2;
               _loc11_.y = _loc3_ + _loc5_ * int(_loc8_ / 4) + _loc11_.height / 2;
               this.mScrollRect.addChild(_loc11_);
               this.mItems.push(_loc11_);
               _loc8_++;
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
      
      private function onHelp(param1:MouseEvent) : void
      {
         this.mPopupHelp.showPopup();
         if(this.mTutorialArrow.visible)
         {
            this.mTutorialArrow.visible = false;
            DollarsGame.getProfile().investmentSetHelpShown(true);
         }
      }
      
      public function onNewInvest(param1:MouseEvent) : void
      {
         this.clearResources();
         this.mInfoScreen.visible = true;
         this.mSelectFriendsButton.visible = true;
         this.mTitle.text = TextManager.getText(TextIDs.TID_INVEST_TITLE1);
         TextManager.setTextScaled(this.mTitle);
         this.mNewInvestButton.setSelected();
         this.mStatsButton.setUnselected();
         this.mCheckInvestButton.setUnselected();
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
      
      private function searchFriends(param1:Event) : void
      {
         this.getFriends(this.mSearchText.text);
      }
      
      private function onCancelInvestor(param1:Event) : void
      {
         var _loc2_:InvestFriendInvestor = param1.target as InvestFriendInvestor;
         _loc2_.addEventListener(InvestFriendInvestor.EVENT_CANCEL_INVEST,this.onCancelInvestor);
         this.getInvestItems();
      }
      
      override protected function close() : void
      {
         super.close();
         this.mScrolling = false;
         if(Config.INVESTMENT_REQUEST_ENABLED)
         {
            this.mSelectFriendsButton.end();
            this.mSelectFriendsButton.removeEventListener(MouseEvent.CLICK,this.onGetFriends);
         }
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mNewInvestButton.end();
         this.mNewInvestButton.removeEventListener(MouseEvent.CLICK,this.onNewInvest);
         this.mCheckInvestButton.end();
         this.mCheckInvestButton.removeEventListener(MouseEvent.CLICK,this.onCheckInvest);
         this.mHelpButton.end();
         this.mHelpButton.removeEventListener(MouseEvent.CLICK,this.onHelp);
         this.mStatsButton.end();
         this.mStatsButton.removeEventListener(MouseEvent.CLICK,this.showStats);
         this.mArrowUp.end();
         this.mArrowUp.removeEventListener(MouseEvent.CLICK,this.onScrollUp);
         this.mArrowDown.end();
         this.mArrowDown.removeEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.mSearchText.removeEventListener(Event.CHANGE,this.searchFriends);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mShowPopup = false;
         this.removeItems(this.mType);
         DollarsGame.getCurrentRole().toolsBar.setToolToSelect();
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function onAcceptChange(param1:Event) : void
      {
         this.onCancel(null);
         Dollars.smStage.displayState = StageDisplayState.NORMAL;
      }
      
      override public function destroy() : void
      {
         if(Config.INVESTMENT_REQUEST_ENABLED)
         {
            mBox.removeChild(this.mInfoScreen);
            this.mSelectFriendsButton.destroy();
            this.mSelectFriendsButton = null;
         }
         mCancelButton.destroy();
         mCancelButton = null;
         this.mNewInvestButton.destroy();
         this.mNewInvestButton = null;
         this.mCheckInvestButton.destroy();
         this.mCheckInvestButton = null;
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
   }
}

