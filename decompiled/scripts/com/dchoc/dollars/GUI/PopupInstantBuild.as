package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.GUI.instantBuild.PopupInstantBuildSecondStep;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import com.dchoc.framework.purchase.FBCreditsPurchaseInterface;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class PopupInstantBuild extends Popup implements FBCreditsPurchaseInterface
   {
      
      public static const EVENT_ASKHELP:String = "EventAskForHelp";
      
      private const NUM_ITEMS:int = 5;
      
      private var mScrolling:Boolean;
      
      private var mMaxScrolls:int;
      
      private var mOkFBCButton:DynamicButton = new DynamicButton(mBox.getChildByName("instant_build_fbc") as MovieClip);
      
      private var mItemDefinition:ItemDefinition;
      
      private var mScrollRect:Sprite;
      
      private var mHelpButton:DynamicButton = new DynamicButton(mBox.getChildByName("ask_for_help") as MovieClip);
      
      private var mMaxOffset:int;
      
      private const YOFFSET:Number = 50;
      
      private var mNumScrolls:int;
      
      private var mDist:Number;
      
      private var mArrowLeft:DynamicButton = new DynamicButton(mBox.getChildByName("mArrowLeft") as MovieClip);
      
      private var mScrollTimer:int;
      
      private var mScrollSpeed:Number;
      
      private var mArrowRight:DynamicButton = new DynamicButton(mBox.getChildByName("mArrowRight") as MovieClip);
      
      private var mScrollOrigin:int;
      
      private const XINIT:Number = -147.5;
      
      private const YINIT:Number = -10.1;
      
      private const XOFFSET:Number = 60;
      
      private var mFriends:Vector.<String>;
      
      public function PopupInstantBuild()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"Popup_wonders"))();
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         mOkButton = new DynamicButton(mBox.getChildByName("instant_build") as MovieClip);
         super();
      }
      
      public function onInstantBuild(param1:MouseEvent) : void
      {
         mNeedsToUpdateOutline = false;
         super.onAccept(param1);
      }
      
      public function showPopupParams(param1:ItemDefinition) : void
      {
         var _loc4_:DollarsGame = null;
         super.show();
         this.mItemDefinition = param1;
         var _loc2_:Number = 100 / this.mItemDefinition.getAmountOfHelp();
         var _loc3_:String = _loc2_.toFixed(0);
         TextManager.reformatTextField(TextField(mBox.getChildByName("TextInfo")));
         if(this.mFriends == null || this.mFriends.length == 0)
         {
            TextField(mBox.getChildByName("TextInfo")).text = TextManager.replaceParameters(TextIDs.TID_INSTANTBUILD_TEXT1,new Array(_loc3_));
         }
         else
         {
            TextField(mBox.getChildByName("TextInfo")).text = TextManager.replaceParameters(TextIDs.TID_INSTANTBUILD_TEXT2,new Array("" + this.mFriends.length,_loc3_));
         }
         TextManager.reformatTextField(TextField(mBox.getChildByName("wonder")));
         TextField(mBox.getChildByName("wonder")).text = TextManager.getText(TextIDs[this.mItemDefinition.textID]);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         if(param1.getInstantBuildType() == ItemDefinition.INSTANT_BUILD_A4H)
         {
            mOkButton.visible = false;
            this.mOkFBCButton.visible = false;
         }
         else if(this.mItemDefinition.getInstantBuildType() == ItemDefinition.INSTANT_BUILD_FBC_A4H)
         {
            mOkButton.visible = false;
            this.mOkFBCButton.visible = true;
            this.mOkFBCButton.start();
            this.mOkFBCButton.addEventListener(MouseEvent.CLICK,this.onFBCBuy);
            this.mOkFBCButton.setLabel(TextManager.convertNumberToString(this.mItemDefinition.getInstantBuildFBC(),TextManager.TRUNCATE_MILLIONS,6));
         }
         else
         {
            mOkButton.visible = true;
            this.mOkFBCButton.visible = false;
            mOkButton.start();
            mOkButton.addEventListener(MouseEvent.CLICK,this.onInstantBuild);
            mOkButton.setLabel(TextManager.getText(TextIDs.TID_TUTORIAL_TITLE_6));
         }
         this.mHelpButton.start();
         this.mHelpButton.addEventListener(MouseEvent.CLICK,this.onHelp);
         this.mHelpButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_ASK_HELP));
         _loc4_ = DollarsGame.smInstance;
         _loc4_.mGameClip.mouseChildren = false;
         _loc4_.mGameClip.mouseEnabled = false;
         startShow();
      }
      
      public function buyWithCredits() : Object
      {
         return {
            "price":this.mItemDefinition.getInstantBuildFBC(),
            "orderInfo":{
               "sku":this.mItemDefinition.sku,
               "type":FBCreditsPurchase.TYPE_INSTANT_BUILD
            }
         };
      }
      
      public function onScrollLeft(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!this.mScrolling)
         {
            this.mScrollOrigin = this.mScrollRect.scrollRect.x;
            _loc2_ = this.NUM_ITEMS;
            if(this.mNumScrolls - _loc2_ < 0)
            {
               _loc2_ = this.mNumScrolls;
            }
            if(this.mNumScrolls > 0)
            {
               this.mMaxOffset = -this.XOFFSET * _loc2_;
               this.mScrollTimer = setInterval(this.ScrollToPrevious,5);
               this.mScrollSpeed = -this.XOFFSET;
               this.mDist = this.mMaxOffset;
               this.mScrolling = true;
               this.mArrowRight.enable();
            }
         }
      }
      
      private function loadSilhouette(param1:int) : void
      {
         var _loc2_:Sprite = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_wonders_friend_x"))();
         this.addImage(_loc2_,param1);
      }
      
      private function loadImageFromID(param1:String, param2:int) : void
      {
         var _loc3_:String = UserDataFacade.getInstance().mSocial.getAPIPictureURL(param1);
         Debug.trace("Requesting picture from: " + _loc3_);
         var _loc4_:Loader = new Loader();
         var _loc5_:URLRequest = new URLRequest(_loc3_);
         var _loc6_:LoaderContext = new LoaderContext();
         _loc4_.name = "" + param2;
         _loc4_.load(_loc5_,_loc6_);
         this.addImage(_loc4_,param2);
      }
      
      private function addImage(param1:DisplayObject, param2:int) : void
      {
         param1.x = this.XINIT + this.XOFFSET * param2;
         param1.y = this.YINIT;
         if(this.mScrollRect != null)
         {
            this.mScrollRect.addChild(param1);
         }
      }
      
      public function loadFriends(param1:String) : void
      {
         if(this.mScrollRect != null && mBox.contains(this.mScrollRect))
         {
            mBox.removeChild(this.mScrollRect);
         }
         this.mScrollRect = new Sprite();
         this.mScrollRect.x = this.XINIT;
         this.mScrollRect.y = this.YINIT;
         mBox.addChild(this.mScrollRect);
         this.mScrollRect.scrollRect = new Rectangle(this.XINIT,this.YINIT,this.XOFFSET * this.NUM_ITEMS,this.YOFFSET);
         this.mFriends = FriendsManager.getBuildingHelp(param1);
         var _loc2_:int = int(this.mFriends.length);
         if(_loc2_ < this.NUM_ITEMS)
         {
            _loc2_ = this.NUM_ITEMS;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc3_ < this.mFriends.length)
            {
               this.loadSilhouette(_loc3_);
               this.loadImageFromID(this.mFriends[_loc3_],_loc3_);
            }
            else
            {
               this.loadSilhouette(_loc3_);
            }
            _loc3_++;
         }
         TextField(mBox.getChildByName("TextInfo_2")).visible = false;
         this.mArrowLeft.start();
         this.mArrowLeft.addEventListener(MouseEvent.CLICK,this.onScrollLeft);
         this.mArrowRight.start();
         this.mArrowRight.addEventListener(MouseEvent.CLICK,this.onScrollRight);
         this.mArrowLeft.enable();
         this.mArrowRight.enable();
         if(_loc2_ <= this.NUM_ITEMS)
         {
            this.mArrowLeft.disable();
            this.mArrowRight.disable();
         }
         else
         {
            this.mArrowLeft.disable();
         }
         this.mMaxScrolls = _loc2_ - this.NUM_ITEMS;
         this.mNumScrolls = 0;
         this.mScrolling = false;
      }
      
      private function ScrollToNext() : void
      {
         var _loc1_:Rectangle = this.mScrollRect.scrollRect;
         _loc1_.x += this.mScrollSpeed;
         this.mDist -= this.mScrollSpeed;
         if(_loc1_.x > this.mScrollOrigin + this.mMaxOffset)
         {
            clearInterval(this.mScrollTimer);
            _loc1_.x = this.mScrollOrigin + this.mMaxOffset;
            this.mNumScrolls += int(this.mMaxOffset / this.XOFFSET);
            this.mScrolling = false;
            mBox.mouseChildren = true;
         }
         this.mScrollRect.scrollRect = _loc1_;
         this.mScrollSpeed = this.mDist * this.XOFFSET / this.mMaxOffset + 2;
         if(this.mNumScrolls == this.mMaxScrolls)
         {
            this.mArrowLeft.enable();
            this.mArrowRight.disable();
         }
      }
      
      private function ScrollToPrevious() : void
      {
         var _loc1_:Rectangle = this.mScrollRect.scrollRect;
         _loc1_.x += this.mScrollSpeed;
         this.mDist -= this.mScrollSpeed;
         if(_loc1_.x < this.mScrollOrigin + this.mMaxOffset)
         {
            clearInterval(this.mScrollTimer);
            _loc1_.x = this.mScrollOrigin + this.mMaxOffset;
            this.mNumScrolls += int(this.mMaxOffset / this.XOFFSET);
            this.mScrolling = false;
            mBox.mouseChildren = true;
         }
         this.mScrollRect.scrollRect = _loc1_;
         this.mScrollSpeed = this.mDist * -this.XOFFSET / this.mMaxOffset - 2;
         if(this.mNumScrolls == 0)
         {
            this.mArrowLeft.disable();
            this.mArrowRight.enable();
         }
      }
      
      private function onFBCBuy(param1:Event) : void
      {
         FBCreditsPurchase.getInstance().startPurchaseProcess(this);
      }
      
      private function onHelp(param1:MouseEvent) : void
      {
         onClose(null);
         dispatchEvent(new Event(EVENT_ASKHELP));
      }
      
      public function onScrollRight(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!this.mScrolling)
         {
            this.mScrollOrigin = this.mScrollRect.scrollRect.x;
            _loc2_ = this.NUM_ITEMS;
            if(this.mNumScrolls + _loc2_ > this.mMaxScrolls)
            {
               _loc2_ = this.mMaxScrolls - this.mNumScrolls;
            }
            if(this.mNumScrolls < this.mMaxScrolls)
            {
               this.mMaxOffset = this.XOFFSET * _loc2_;
               this.mScrollTimer = setInterval(this.ScrollToNext,5);
               this.mScrollSpeed = this.XOFFSET;
               this.mDist = this.mMaxOffset;
               this.mScrolling = true;
               this.mArrowLeft.enable();
            }
         }
      }
      
      public function buyWithCreditsCallback(param1:String) : void
      {
         if(param1 == FBCreditsPurchase.RESPONSE_OK)
         {
            dispatchEvent(new Event(PopupInstantBuildSecondStep.EVENT_BUY_FBC));
            onClose(null);
         }
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         if(this.mItemDefinition.getInstantBuildType() == ItemDefinition.INSTANT_BUILD_FBC_A4H)
         {
            this.mOkFBCButton.removeEventListener(MouseEvent.CLICK,this.onFBCBuy);
            this.mOkFBCButton.end();
         }
         else
         {
            mOkButton.removeEventListener(MouseEvent.CLICK,this.onInstantBuild);
            mOkButton.end();
         }
         this.mHelpButton.end();
         this.mHelpButton.removeEventListener(MouseEvent.CLICK,this.onHelp);
         this.mArrowLeft.end();
         this.mArrowLeft.removeEventListener(MouseEvent.CLICK,this.onScrollLeft);
         this.mArrowRight.end();
         this.mArrowRight.removeEventListener(MouseEvent.CLICK,this.onScrollRight);
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mGameClip.mouseChildren = true;
         _loc1_.mGameClip.mouseEnabled = true;
         if(!mAccepted)
         {
            dispatchEvent(new Event(EVENT_CLOSE));
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.mScrollRect.numChildren)
         {
            this.mScrollRect.removeChild(this.mScrollRect.getChildAt(_loc2_));
            _loc2_++;
         }
         if(this.mScrollRect != null && mBox.contains(this.mScrollRect))
         {
            mBox.removeChild(this.mScrollRect);
         }
         this.mScrollRect = null;
         this.mItemDefinition = null;
      }
   }
}

