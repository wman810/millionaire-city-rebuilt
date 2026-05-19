package com.dchoc.dollars.GUI.hud
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.TipBox;
   import com.dchoc.dollars.GUI.exchangeForCash.PopupExchange;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.utils.traffic.TrafficAgent;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.GUI.DCFillBar;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Bitmap;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class HudOwner extends Hud
   {
      
      private static const ARROW_VALUE_DOWN_FRAME:int = 1;
      
      private static const ARROW_VALUE_UP_FRAME:int = 2;
      
      private static const SERVER_BUSY_LIGHT_RED:int = 0;
      
      private static const SERVER_BUSY_LIGHT_YELLOW:int = 1;
      
      private static const SERVER_BUSY_LIGHT_GREEN:int = 2;
      
      private static const SERVER_BUSY_LIGHT_COUNT:int = 3;
      
      private static const SERVER_BUSY_LIGHT_COLOR:Array = [16711680,16776960,65280];
      
      private var mExpFillBar:DCFillBar;
      
      private var mCompanyValue:TextField;
      
      private var mFXStateBeforeVideo:Boolean = false;
      
      private var mTipBox:TipBox;
      
      private var mFriendBmp:Bitmap;
      
      private var mCityName:String;
      
      private var mStarsAnim:MovieClip;
      
      private const MAX_COINS:Number = 99999999000000;
      
      private var mServiceTipSku:String;
      
      private var mArrowValue:MovieClip;
      
      private var mArrowValueFrame:int;
      
      private var mAddCoinsButton:DynamicButton;
      
      private var mAddFCButton:DynamicButton;
      
      private var mHud:Sprite;
      
      private var mRoleText:TextField;
      
      private var mTrafficHUDdirection:TextField;
      
      private var mAddCashButton:DynamicButton;
      
      private const BLINK_TIMER:int = 400;
      
      private var mDCCoinsCounter:Sprite;
      
      private var mServicesSkuDictionary:Dictionary;
      
      private var mExpCounter:int;
      
      private var mExp:Number;
      
      private var mExpBarStar:MovieClip;
      
      private var mProfile:Profile;
      
      private var mPopupExchange:Popup;
      
      private var mExpBar:Sprite;
      
      private var mFriendPhoto:Sprite;
      
      private var mOldCompanyValue:Number;
      
      private var mBlinking:Array;
      
      private var mServerBusyLights:Array;
      
      private var mCoinsCounter:Number;
      
      private var mCityNameBox:TextField;
      
      private var mFCCounter:Sprite;
      
      private var mExpSpeed:Number;
      
      private const INCREMENT_TIME:int = 500;
      
      private var mCoinsSpeed:Number;
      
      private var mBlinkValue:Array;
      
      private var mMusicStateBeforeVideo:Boolean = false;
      
      private var mBlinkInterval:Array;
      
      private var mTipServiceShowing:Array;
      
      private var mServerBusyLightCurrentIndex:int;
      
      private var mVideoButton:DynamicButton;
      
      private var mTrafficHUDstatus:TextField;
      
      private var mServicesIcons:Array;
      
      private var mDCCashCounter:Sprite;
      
      public function HudOwner(param1:Profile)
      {
         super();
         this.mProfile = param1;
      }
      
      private function setTipName(param1:MouseEvent) : void
      {
         var _loc2_:DollarsGame = null;
         var _loc3_:Rectangle = null;
         if(this.mTipBox == null)
         {
            _loc2_ = DollarsGame.smInstance;
            this.mTipBox = new TipBox(TextManager.getText(TextIDs.TID_HINT_CITY_NAME));
            _loc3_ = this.mCityNameBox.getBounds(stage);
            this.mTipBox.x = _loc3_.x + (_loc3_.width - this.mTipBox.width >> 1);
            this.mTipBox.y = _loc3_.y + _loc3_.height + 1;
            _loc2_.mPopupClip.addChild(this.mTipBox);
            this.adjustTipPosition();
         }
      }
      
      private function trafficHUDDestroy() : void
      {
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            removeChild(this.mTrafficHUDstatus);
            this.mTrafficHUDstatus = null;
            removeChild(this.mTrafficHUDdirection);
            this.mTrafficHUDdirection = null;
         }
      }
      
      private function serverBusyLightDestroy() : void
      {
         var _loc1_:int = 0;
         if(this.mServerBusyLights != null)
         {
            _loc1_ = 0;
            while(_loc1_ < SERVER_BUSY_LIGHT_COUNT)
            {
               removeChild(this.mServerBusyLights[_loc1_]);
               _loc1_++;
            }
            this.mServerBusyLights.splice(0,this.mServerBusyLights.length);
            this.mServerBusyLights = null;
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:Sprite = null;
         super.destroy();
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.mAddFCButton.destroy();
            this.mAddFCButton = null;
            this.mFCCounter = null;
         }
         this.mAddCashButton.destroy();
         this.mAddCashButton = null;
         this.mAddCoinsButton.destroy();
         this.mAddCoinsButton = null;
         this.mExpBar = null;
         this.mExpBarStar = null;
         this.mDCCoinsCounter = null;
         this.mDCCashCounter = null;
         this.mRoleText = null;
         if(this.mServicesIcons != null)
         {
            for each(_loc1_ in this.mServicesIcons)
            {
               _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.setTipService);
               _loc1_.removeEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
            }
            this.mServicesIcons = null;
         }
         this.mServicesSkuDictionary = null;
         this.serverBusyLightDestroy();
         this.trafficHUDDestroy();
      }
      
      private function setTipValue(param1:MouseEvent) : void
      {
         var _loc2_:DollarsGame = null;
         var _loc3_:Rectangle = null;
         if(this.mTipBox == null)
         {
            _loc2_ = DollarsGame.smInstance;
            this.mTipBox = new TipBox(TextManager.getText(TextIDs.TID_HINT_VALUE));
            _loc3_ = this.mCompanyValue.getBounds(stage);
            this.mTipBox.x = _loc3_.x + (_loc3_.width - this.mTipBox.width >> 1);
            this.mTipBox.y = _loc3_.y + _loc3_.height + 1;
            _loc2_.mPopupClip.addChild(this.mTipBox);
            this.adjustTipPosition();
         }
      }
      
      public function setCityName(param1:String) : void
      {
         if(param1 == null)
         {
            param1 = TextManager.getText(TextIDs.TID_INITIAL_CITY_NAME);
         }
         this.mCityName = param1;
         this.mCityNameBox.text = this.mCityName;
         if(this.mCityNameBox.textWidth > this.mCityNameBox.width)
         {
            TextManager.setTextScaled(this.mCityNameBox);
         }
      }
      
      override public function startIconBlink(param1:String) : void
      {
         this.mBlinkValue[param1] = true;
         this.mBlinkInterval[param1] = setInterval(this.changeIconState,this.BLINK_TIMER,param1);
         this.mBlinking[param1] = true;
      }
      
      public function getArrowValueFrame() : int
      {
         return this.mArrowValueFrame;
      }
      
      public function setFacebookCredits(param1:int) : void
      {
         var _loc2_:TextField = this.mFCCounter.getChildByName("Facebook_Credits") as TextField;
         TextManager.reformatTextField(_loc2_,false);
         _loc2_.text = "" + TextManager.convertNumberToString(param1,TextManager.TRUNCATE_THOUSAND,3);
         TextManager.setTextScaled(_loc2_);
      }
      
      private function closeExchange(param1:Event) : void
      {
         this.mPopupExchange.removeEventListener(Popup.EVENT_CLOSE,this.closeExchange);
         this.mPopupExchange.destroy();
         this.mPopupExchange = null;
      }
      
      public function setLevel(param1:uint) : void
      {
         var _loc2_:TextField = null;
         _loc2_ = this.mExpBar.getChildByName("ExLevel") as TextField;
         TextManager.setTextScaled(_loc2_,true);
         _loc2_.text = "" + param1;
         this.mExpFillBar.setMinValue(this.mProfile.minExp);
         this.mExpFillBar.setMaxValue(this.mProfile.maxExp);
      }
      
      public function setRoleText(param1:String) : void
      {
         this.mRoleText.text = param1;
      }
      
      private function removeGoldFromHud() : void
      {
         this.mDCCashCounter.visible = false;
         this.mAddCoinsButton.visible = false;
      }
      
      public function setExp(param1:Number) : void
      {
         var _loc2_:TextField = null;
         _loc2_ = this.mExpBar.getChildByName("ExPoints") as TextField;
         TextManager.reformatTextField(_loc2_,false);
         TextManager.setTextScaled(_loc2_,true);
         _loc2_.text = TextManager.convertNumberToString(param1,0,0);
         this.mExpFillBar.setValueWithoutBarAnimation(param1);
         if(this.mExp != param1)
         {
            this.mExp = param1;
            this.mExpBarStar.addEventListener(Event.ENTER_FRAME,this.checkEnd);
            this.mExpBarStar.play();
         }
      }
      
      private function trafficHUDSetCurrentStatusDirection() : void
      {
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            switch(TrafficAgent.SPAWN_DIRECTION)
            {
               case 0:
                  this.mTrafficHUDdirection.text = "RIGHT/UP";
                  break;
               case 1:
                  this.mTrafficHUDdirection.text = "LEFT/DOWN";
            }
            switch(TrafficAgent.SPAWN_STATUS)
            {
               case 0:
                  this.mTrafficHUDstatus.text = "RESUME";
                  break;
               case 1:
                  this.mTrafficHUDstatus.text = "PAUSE";
            }
         }
      }
      
      private function serverBusyLightSetCurrentIndex(param1:int) : void
      {
         this.mServerBusyLightCurrentIndex = param1;
         var _loc2_:int = 0;
         while(_loc2_ < SERVER_BUSY_LIGHT_COUNT)
         {
            this.mServerBusyLights[_loc2_].visible = _loc2_ == param1;
            _loc2_++;
         }
      }
      
      override public function start(param1:Hud = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         super.start();
         this.mProfile.addEventListener(Event.CHANGE,this.onUpdate);
         this.mCoinsCounter = this.mProfile.DCCoins;
         this.mExpCounter = this.mProfile.exp;
         this.onUpdate();
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_VISITOR)
         {
            this.setFriendPhoto(DollarsGame.getCurrentUniverse().owner);
         }
         this.setCityName(DollarsGame.getProfileUniverse().cityname);
         var _loc2_:ServiceDefinitionManager = ServiceDefinitionManager.getInstance();
         var _loc3_:Array = _loc2_.getTypeSkus();
         for each(_loc4_ in _loc3_)
         {
            if(_loc2_.hasTimeAvailable(_loc4_))
            {
               _loc5_ = false;
               if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
               {
                  _loc5_ = this.mProfile.servicesIsAvailable(_loc4_);
               }
               this.setIconVisible(_loc4_,_loc5_);
            }
         }
      }
      
      private function launchAnim(param1:Event) : void
      {
         this.mPopupExchange.removeEventListener(PopupExchange.EVENT_EXCHANGED,this.launchAnim);
         if(this.mStarsAnim == null)
         {
            this.mStarsAnim = new AssetManager.NextButtonAnim();
            this.mStarsAnim.stop();
            this.mDCCoinsCounter.addChild(this.mStarsAnim);
            this.mStarsAnim.gotoAndPlay(1);
            this.mStarsAnim.addEventListener(Event.ENTER_FRAME,this.checkStarsAnim);
            this.mStarsAnim.y = 20;
            this.mStarsAnim.x = 100;
         }
      }
      
      public function setFriendPhoto(param1:int) : void
      {
         var _loc3_:Loader = null;
         var _loc4_:URLRequest = null;
         var _loc5_:LoaderContext = null;
         var _loc2_:NeighborObject = FriendsManager.getNeighborByID(param1);
         if(this.mFriendBmp != null && this.mFriendPhoto.contains(this.mFriendBmp))
         {
            this.mFriendPhoto.removeChild(this.mFriendBmp);
         }
         this.mFriendPhoto.visible = true;
         if(_loc2_ != null && _loc2_.getPictureURL() != null)
         {
            _loc3_ = new Loader();
            _loc4_ = new URLRequest(_loc2_.getPictureURL());
            _loc5_ = new LoaderContext();
            _loc3_.load(_loc4_,_loc5_);
            this.mFriendPhoto.addChild(_loc3_);
            this.mFriendPhoto.visible = true;
         }
      }
      
      public function set oldCompanyValue(param1:Number) : void
      {
         this.mOldCompanyValue = param1;
      }
      
      private function removeTip(param1:MouseEvent) : void
      {
         var _loc2_:DollarsGame = DollarsGame.smInstance;
         if(this.mTipBox != null && _loc2_.mPopupClip.contains(this.mTipBox))
         {
            Debug.trace("Remove TIPS");
            _loc2_.mPopupClip.removeChild(this.mTipBox);
            this.mTipBox = null;
            if(this.mTipServiceShowing[this.mServiceTipSku])
            {
               this.mTipServiceShowing[this.mServiceTipSku] = false;
            }
         }
      }
      
      private function disableButtons() : void
      {
         this.mAddCashButton.disable();
         this.mAddCoinsButton.disable();
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.mAddFCButton.disable();
         }
      }
      
      public function setCompanyValue(param1:Number) : void
      {
         var _loc2_:Number = this.mProfile.getOldCompanyValue();
         if(UserDataFacade.getInstance().isNPC(DollarsGame.getCurrentUniverse().owner))
         {
            this.setArrowValueFrame(ARROW_VALUE_UP_FRAME);
         }
         else if(param1 < _loc2_)
         {
            this.setArrowValueFrame(ARROW_VALUE_DOWN_FRAME);
         }
         else
         {
            this.setArrowValueFrame(ARROW_VALUE_UP_FRAME);
         }
         TextManager.reformatTextField(this.mCompanyValue,false);
         TextManager.setTextScaled(this.mCompanyValue,true);
         this.mCompanyValue.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param1,TextManager.TRUNCATE_MILLIONS,10);
         this.mCompanyValue.width = this.mCompanyValue.textWidth + 10;
         if(this.mOldCompanyValue != param1)
         {
            this.mOldCompanyValue = param1;
         }
      }
      
      public function enableButtons() : void
      {
         this.mAddCashButton.enable();
         this.mAddCoinsButton.enable();
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.mAddFCButton.enable();
         }
      }
      
      override public function stopIconBlink(param1:String) : void
      {
         clearInterval(this.mBlinkInterval[param1]);
         this.mBlinking[param1] = false;
      }
      
      private function setTipFBCredits(param1:MouseEvent) : void
      {
         var _loc2_:DollarsGame = null;
         var _loc3_:Rectangle = null;
         if(this.mTipBox == null)
         {
            Debug.trace("TIP FB Credits");
            _loc2_ = DollarsGame.smInstance;
            this.mTipBox = new TipBox(TextManager.getText(TextIDs.TID_HINT_FACEBOOKCREDITS));
            _loc3_ = this.mFCCounter.getBounds(stage);
            this.mTipBox.x = _loc3_.x + (_loc3_.width - this.mTipBox.width >> 1);
            this.mTipBox.y = _loc3_.y + _loc3_.height + 1;
            _loc2_.mPopupClip.addChild(this.mTipBox);
            this.adjustTipPosition();
         }
      }
      
      private function onUpdate(param1:Event = null) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:NeighborObject = null;
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.setFacebookCredits(this.mProfile.facebookCredits);
            this.setFacebookCreditsNotSpent(this.mProfile.facebookCreditsNotSpent);
         }
         this.setCash(this.mProfile.DCCash);
         this.setCoins(this.mProfile.DCCoins);
         this.setLevel(this.mProfile.level);
         this.setExp(this.mProfile.exp);
         this.setCityName(DollarsGame.getProfileUniverse().cityname);
         if(UserDataFacade.getInstance().isNPC(DollarsGame.getCurrentUniverse().owner))
         {
            _loc3_ = FriendsManager.getNeighborByID(DollarsGame.getCurrentUniverse().owner);
            _loc2_ = _loc3_.companyValue;
         }
         else if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
         {
            _loc2_ = this.mProfile.companyValue;
         }
         else
         {
            _loc2_ = DollarsGame.getCurrentWorld().getCompanyMine().getCompanyValue();
         }
         this.setCompanyValue(_loc2_);
         if(Config.DEBUG_MODE)
         {
            this.mRoleText.visible = true;
         }
         if(this.mDCCashCounter.visible && this.mProfile.DCCash < 1 && Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.removeGoldFromHud();
         }
      }
      
      private function textEffectCoins(param1:TextField, param2:Boolean) : void
      {
         if(param2)
         {
            param1.textColor = 16711680;
         }
         else
         {
            param1.textColor = 16777215;
         }
      }
      
      private function onAddCash(param1:MouseEvent) : void
      {
         DollarsGame.addGold();
      }
      
      private function onAddFC(param1:MouseEvent) : void
      {
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_FACEBOOK_CREDITS);
      }
      
      override public function reload() : void
      {
      }
      
      private function setTipService(param1:MouseEvent) : void
      {
         var _loc3_:DollarsGame = null;
         this.mServiceTipSku = this.mServicesSkuDictionary[param1.currentTarget.name];
         var _loc2_:Sprite = param1.target as Sprite;
         if(!this.mTipServiceShowing[this.mServiceTipSku] && this.mTipBox == null && !this.mBlinking[this.mServiceTipSku])
         {
            _loc3_ = DollarsGame.smInstance;
            this.mTipBox = new TipBox(TextManager.convertTimeToString(TimerUtil.DAY_TO_MS - 1000,false,true));
            this.mTipBox.setText(TextManager.convertTimeToString(this.mProfile.servicesGetTimeLeft(this.mServiceTipSku),false,true));
            this.mTipBox.x = _loc2_.x + this.mHud.x + _loc2_.width;
            this.mTipBox.y = _loc2_.y + 25 + this.mHud.y;
            _loc3_.mPopupClip.addChild(this.mTipBox);
            this.mTipServiceShowing[this.mServiceTipSku] = true;
            this.adjustTipPosition();
         }
      }
      
      public function setArrowValueFrame(param1:int) : void
      {
         this.mArrowValueFrame = param1;
         this.mArrowValue.gotoAndStop(this.mArrowValueFrame);
      }
      
      private function setTipCoins(param1:MouseEvent) : void
      {
         var _loc2_:DollarsGame = null;
         var _loc3_:Rectangle = null;
         if(this.mTipBox == null)
         {
            Debug.trace("TIP Coins");
            _loc2_ = DollarsGame.smInstance;
            this.mTipBox = new TipBox(TextManager.getText(TextIDs.TID_HINT_BANK_BAR));
            _loc3_ = this.mDCCoinsCounter.getBounds(stage);
            this.mTipBox.x = _loc3_.x + (_loc3_.width - this.mTipBox.width >> 1);
            this.mTipBox.y = _loc3_.y + _loc3_.height + 1;
            _loc2_.mPopupClip.addChild(this.mTipBox);
            this.adjustTipPosition();
         }
      }
      
      private function setTipCash(param1:MouseEvent) : void
      {
         var _loc2_:DollarsGame = null;
         var _loc3_:Rectangle = null;
         if(this.mTipBox == null)
         {
            Debug.trace("TIP Cash");
            _loc2_ = DollarsGame.smInstance;
            this.mTipBox = new TipBox(TextManager.getText(TextIDs.TID_HINT_GOLD_BAR));
            _loc3_ = this.mDCCashCounter.getBounds(stage);
            this.mTipBox.x = _loc3_.x + (_loc3_.width - this.mTipBox.width >> 1);
            this.mTipBox.y = _loc3_.y + _loc3_.height + 1;
            _loc2_.mPopupClip.addChild(this.mTipBox);
            this.adjustTipPosition();
         }
      }
      
      public function setFacebookCreditsNotSpent(param1:int) : void
      {
         var _loc2_:TextField = this.mFCCounter.getChildByName("Facebook_Credits_2") as TextField;
         var _loc3_:TextField = this.mFCCounter.getChildByName("Facebook_Credits") as TextField;
         if(param1 < 1)
         {
            _loc3_.x = _loc2_.x + _loc2_.width - _loc3_.width - 2;
            _loc2_.visible = false;
         }
         else
         {
            _loc2_.visible = true;
            _loc3_.x = _loc2_.x - _loc3_.width - 2;
            TextManager.reformatTextField(_loc2_,false);
            _loc2_.text = "+" + param1;
            TextManager.setTextScaled(_loc2_);
         }
      }
      
      private function checkEnd(param1:Event) : void
      {
         if(this.mExpBarStar.currentFrame == this.mExpBarStar.totalFrames)
         {
            this.mExpBarStar.removeEventListener(Event.ENTER_FRAME,this.checkEnd);
            this.mExpBarStar.stop();
         }
      }
      
      override public function resize() : void
      {
         var _loc1_:Sprite = null;
         this.mHud.x = (Dollars.smStage.stageWidth - Config.SCREEN_WIDTH) / 2;
         this.mVideoButton.getButtonMc().x = Dollars.smStage.stageWidth - (Dollars.smStage.stageWidth - Config.SCREEN_WIDTH + this.mVideoButton.getButtonMc().width) / 2;
         for each(_loc1_ in this.mServicesIcons)
         {
            _loc1_.x = this.mVideoButton.getButtonMc().x;
         }
      }
      
      public function setCash(param1:int) : void
      {
         var _loc2_:TextField = null;
         _loc2_ = this.mDCCashCounter.getChildByName("DCCash") as TextField;
         TextManager.reformatTextField(_loc2_,false);
         _loc2_.text = TextManager.convertNumberToString(param1,TextManager.TRUNCATE_THOUSAND,4);
         TextManager.setTextScaled(_loc2_);
      }
      
      private function serverBusyLightLoad() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Shape = null;
         var _loc3_:Graphics = null;
         if(Config.serverBusyLightIsEnabled())
         {
            this.mServerBusyLights = new Array();
            _loc1_ = 0;
            while(_loc1_ < SERVER_BUSY_LIGHT_COUNT)
            {
               _loc2_ = new Shape();
               _loc3_ = _loc2_.graphics;
               _loc3_.beginFill(SERVER_BUSY_LIGHT_COLOR[_loc1_]);
               _loc3_.drawCircle(200,28,10);
               _loc3_.endFill();
               addChild(_loc2_);
               this.mServerBusyLights.push(_loc2_);
               _loc2_.visible = false;
               _loc1_++;
            }
            this.serverBusyLightSetCurrentIndex(SERVER_BUSY_LIGHT_GREEN);
         }
      }
      
      public function get oldCompanyValue() : Number
      {
         return this.mOldCompanyValue;
      }
      
      public function setCoins(param1:Number) : void
      {
         var _loc2_:TextField = null;
         if(param1 > this.MAX_COINS)
         {
            param1 = this.MAX_COINS;
         }
         _loc2_ = this.mDCCoinsCounter.getChildByName("DCCoins") as TextField;
         TextManager.reformatTextField(_loc2_,false);
         _loc2_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(param1,TextManager.TRUNCATE_MILLIONS,8);
         TextManager.setTextScaled(_loc2_,true);
         if(param1 < 1001)
         {
            this.textEffectCoins(_loc2_,true);
         }
         else
         {
            this.textEffectCoins(_loc2_,false);
         }
      }
      
      private function changeIconState(param1:String) : void
      {
         this.mBlinkValue[param1] = !this.mBlinkValue[param1];
         this.setIconVisible(param1,this.mBlinkValue[param1]);
         this.removeTip(null);
      }
      
      override public function logicUpdate(param1:int) : void
      {
         var _loc2_:int = 0;
         if(Boolean(this.mTipServiceShowing[this.mServiceTipSku]) && this.mTipBox != null)
         {
            this.mTipBox.setText(TextManager.convertTimeToString(this.mProfile.servicesGetTimeLeft(this.mServiceTipSku),false,true));
         }
         if(this.mServerBusyLights != null)
         {
            _loc2_ = UserDataFacade.getInstance().serverIsBusy();
            if(_loc2_ != this.mServerBusyLightCurrentIndex)
            {
               this.serverBusyLightSetCurrentIndex(_loc2_);
            }
         }
         if(this.mExpFillBar != null)
         {
            this.mExpFillBar.logicUpdate(param1);
         }
         this.trafficHUDSetCurrentStatusDirection();
      }
      
      private function trafficHUDLoad() : void
      {
         if(Config.CHEAT_TRAFFIC_AGENT)
         {
            this.mTrafficHUDdirection = new TextField();
            this.mTrafficHUDdirection.textColor = 16711680;
            this.mTrafficHUDdirection.x = 170;
            this.mTrafficHUDdirection.y = 50;
            addChild(this.mTrafficHUDdirection);
            this.mTrafficHUDstatus = new TextField();
            this.mTrafficHUDstatus.textColor = 65280;
            this.mTrafficHUDstatus.x = 170;
            this.mTrafficHUDstatus.y = 65;
            addChild(this.mTrafficHUDstatus);
            this.trafficHUDSetCurrentStatusDirection();
         }
      }
      
      override public function resumeSounds() : void
      {
         if(Config.USE_SOUNDS)
         {
            if(this.mMusicStateBeforeVideo)
            {
               SoundManager.getInstance().setMusicOn(true);
            }
            if(this.mFXStateBeforeVideo)
            {
               SoundManager.getInstance().setSfxOn(true);
            }
         }
         this.mMusicStateBeforeVideo = false;
         this.mFXStateBeforeVideo = false;
      }
      
      private function adjustTipPosition() : void
      {
         if(this.mTipBox.x + this.mTipBox.width > Dollars.smStage.stageWidth)
         {
            this.mTipBox.x = Dollars.smStage.stageWidth - this.mTipBox.width;
         }
         else if(this.mTipBox.x <= 0)
         {
            this.mTipBox.x = 0;
         }
      }
      
      override public function end() : void
      {
         var _loc3_:String = null;
         super.end();
         this.mProfile.removeEventListener(Event.CHANGE,this.onUpdate);
         var _loc1_:ServiceDefinitionManager = ServiceDefinitionManager.getInstance();
         var _loc2_:Array = ServiceDefinitionManager.getInstance().getTypeSkus();
         for each(_loc3_ in _loc2_)
         {
            if(_loc1_.hasTimeAvailable(_loc3_))
            {
               this.stopIconBlink(_loc3_);
               this.setIconVisible(_loc3_,false);
            }
         }
      }
      
      private function onAddCoins(param1:MouseEvent) : void
      {
         var _loc2_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         this.mPopupExchange = new PopupExchange();
         this.mPopupExchange.addEventListener(PopupExchange.EVENT_EXCHANGED,this.launchAnim);
         this.mPopupExchange.addEventListener(Popup.EVENT_CLOSE,this.closeExchange);
         this.mPopupExchange.showPopup();
      }
      
      private function onShowVideoAd(param1:MouseEvent) : void
      {
         if(Config.USE_SOUNDS)
         {
            this.mMusicStateBeforeVideo = SoundManager.getInstance().isMusicOn();
            this.mFXStateBeforeVideo = SoundManager.getInstance().isSfxOn();
            SoundManager.getInstance().stopAll();
         }
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_VIDEO_AD,{"func":CustomizerManager.getInstance().getVideoFunctionName()});
      }
      
      override public function load() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:Sprite = null;
         super.load();
         this.mHud = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_new"))();
         this.mAddFCButton = new DynamicButton(this.mHud.getChildByName("add_Facebook_Credits") as MovieClip);
         this.mAddFCButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_TEXT_ADD));
         this.mAddFCButton.addEventListener(MouseEvent.CLICK,this.onAddFC);
         this.mAddFCButton.start();
         this.mFCCounter = this.mHud.getChildByName("FC") as Sprite;
         this.mFCCounter.addEventListener(MouseEvent.MOUSE_OVER,this.setTipFBCredits);
         this.mFCCounter.addEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
         this.mAddCoinsButton = new DynamicButton(this.mHud.getChildByName("exchange_cash") as MovieClip);
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY && DollarsGame.getCurrentWorld().getCompanyMine().DCCash < 1)
         {
            this.mAddCoinsButton.visible = false;
         }
         else
         {
            this.mAddCoinsButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_TEXT_ADD));
            this.mAddCoinsButton.addEventListener(MouseEvent.CLICK,this.onAddCoins);
            this.mAddCoinsButton.start();
         }
         this.mAddCashButton = new DynamicButton(this.mHud.getChildByName("add_gold") as MovieClip);
         if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            this.mAddCashButton.visible = false;
         }
         else
         {
            this.mAddCashButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_TEXT_ADD));
            this.mAddCashButton.addEventListener(MouseEvent.CLICK,this.onAddCash);
            this.mAddCashButton.start();
         }
         this.mExpBar = this.mHud.getChildByName("XP") as Sprite;
         this.mExpBarStar = this.mExpBar.getChildByName("ExperienceStar") as MovieClip;
         this.mExpBarStar.stop();
         this.mExpBar.addEventListener(MouseEvent.MOUSE_OVER,this.setTipExpBar);
         this.mExpBar.addEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
         this.mExpFillBar = new DCFillBar(this.mExpBar.getChildByName("fill_bar") as MovieClip,0,340);
         this.mDCCoinsCounter = this.mHud.getChildByName("Coins") as Sprite;
         this.mDCCoinsCounter.addEventListener(MouseEvent.MOUSE_OVER,this.setTipCoins);
         this.mDCCoinsCounter.addEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
         this.mDCCashCounter = this.mHud.getChildByName("DCcash") as Sprite;
         this.mDCCashCounter.addEventListener(MouseEvent.MOUSE_OVER,this.setTipCash);
         this.mDCCashCounter.addEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
         if(!Config.FACEBOOK_CREDITS_AS_CURRENCY)
         {
            _loc5_ = this.mFCCounter.width;
            this.mDCCoinsCounter.x += _loc5_;
            this.mDCCashCounter.x += _loc5_;
            this.mAddCoinsButton.getButtonMc().x = this.mAddCoinsButton.getButtonMc().x + _loc5_;
            this.mAddCashButton.getButtonMc().x = this.mAddCashButton.getButtonMc().x + _loc5_;
            this.mFCCounter.visible = false;
            this.mAddFCButton.visible = false;
         }
         this.mCityNameBox = MovieClip(this.mHud.getChildByName("name_city")).getChildByName("name_city") as TextField;
         TextManager.reformatTextField(this.mCityNameBox);
         this.mCityNameBox.addEventListener(MouseEvent.MOUSE_OVER,this.setTipName);
         this.mCityNameBox.addEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
         this.mCompanyValue = MovieClip(this.mHud.getChildByName("name_city")).getChildByName("total") as TextField;
         this.mCompanyValue.addEventListener(MouseEvent.MOUSE_OVER,this.setTipValue);
         this.mCompanyValue.addEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
         var _loc1_:ServiceDefinitionManager = ServiceDefinitionManager.getInstance();
         this.mServicesIcons = new Array(_loc1_.getDefinitionsCount());
         var _loc2_:Array = _loc1_.getTypeSkus();
         var _loc3_:int = int(_loc2_.length);
         this.mBlinkInterval = new Array();
         this.mBlinkValue = new Array();
         this.mBlinking = new Array();
         this.mTipServiceShowing = new Array();
         this.mServicesSkuDictionary = new Dictionary(true);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = _loc2_[_loc4_];
            if(_loc1_.hasTimeAvailable(_loc6_))
            {
               _loc7_ = this.mHud.getChildByName(_loc6_) as Sprite;
               this.mServicesSkuDictionary[_loc7_.name] = _loc6_;
               _loc7_.addEventListener(MouseEvent.MOUSE_OVER,this.setTipService);
               _loc7_.addEventListener(MouseEvent.MOUSE_OUT,this.removeTip);
               this.mServicesIcons[_loc4_] = _loc7_;
               _loc7_.mouseChildren = false;
               this.mBlinking.push(false);
               this.mTipServiceShowing.push(false);
            }
            _loc4_++;
         }
         if(Config.DEBUG_MODE)
         {
            this.mRoleText = new TextField();
            this.mRoleText.x = 0;
            this.mRoleText.y = 50;
         }
         addChild(this.mHud);
         this.serverBusyLightLoad();
         this.trafficHUDLoad();
         this.mFriendPhoto = Sprite(Sprite(this.mHud.getChildByName("name_city")).getChildByName("photo"));
         this.mArrowValue = MovieClip(Sprite(this.mHud.getChildByName("name_city")).getChildByName("arrow_down_red"));
         this.setArrowValueFrame(ARROW_VALUE_UP_FRAME);
         this.mFriendPhoto.visible = false;
         this.mVideoButton = new DynamicButton(this.mHud["button_video"]);
         this.mVideoButton.visible = false;
         if(!Tutorial.smTutorialEnd)
         {
            this.disableButtons();
         }
      }
      
      private function checkStarsAnim(param1:Event) : void
      {
         if(this.mStarsAnim.currentFrame == this.mStarsAnim.totalFrames)
         {
            if(this.mDCCoinsCounter.contains(this.mStarsAnim))
            {
               this.mDCCoinsCounter.removeChild(this.mStarsAnim);
            }
            this.mStarsAnim.stop();
            this.mStarsAnim.removeEventListener(Event.ENTER_FRAME,this.checkStarsAnim);
            this.mStarsAnim = null;
         }
      }
      
      override public function setIconVisible(param1:String, param2:Boolean) : void
      {
         var _loc3_:int = ServiceDefinitionManager.getInstance().getIdFromTypeSku(param1);
         if(_loc3_ > -1)
         {
            this.mServicesIcons[_loc3_].visible = param2;
         }
         else if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("############# ERROR in HudOwner.setIconVisible(): Index not found for type sku = " + param1);
         }
      }
      
      private function setTipExpBar(param1:MouseEvent) : void
      {
         var _loc2_:DollarsGame = null;
         var _loc3_:Rectangle = null;
         if(this.mTipBox == null)
         {
            _loc2_ = DollarsGame.smInstance;
            this.mTipBox = new TipBox(TextManager.replaceParameters(TextIDs.TID_HINT_EXP_BAR,new Array("" + (this.mProfile.maxExp - this.mExp),"" + (this.mProfile.level + 1))));
            _loc3_ = this.mExpBar.getBounds(stage);
            this.mTipBox.x = _loc3_.x + (_loc3_.width - this.mTipBox.width >> 1);
            this.mTipBox.y = _loc3_.y + _loc3_.height;
            _loc2_.mPopupClip.addChild(this.mTipBox);
            this.adjustTipPosition();
         }
      }
   }
}

