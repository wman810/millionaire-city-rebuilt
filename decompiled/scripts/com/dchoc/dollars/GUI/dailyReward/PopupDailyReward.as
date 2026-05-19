package com.dchoc.dollars.GUI.dailyReward
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.dailyBonus.DailyBonusManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupDailyReward extends Popup
   {
      
      public static const EVENT_ANIMATION_END:String = "eventanimationend";
      
      private const LAST_DAY:Number = 5;
      
      private var mTutorialArrow:MovieClip;
      
      private var mBigReward:DailyBigReward;
      
      protected var mConfirmButton:DynamicButton;
      
      private var mCollectedRewards:Array;
      
      private const YINIT:Number = -800;
      
      protected var mTitle:TextField;
      
      private const YOFFSET:Number = -100;
      
      private const XINIT:Number = -235;
      
      private var mCollectedReward:String;
      
      private var mRewards:Array;
      
      private const XOFFSET:Number = 110;
      
      public function PopupDailyReward()
      {
         this.load();
         super();
      }
      
      override protected function startButtons() : void
      {
         this.mConfirmButton.start();
         this.mConfirmButton.disable();
      }
      
      private function onConfirm(param1:MouseEvent) : void
      {
         onClose(null);
      }
      
      protected function load() : void
      {
         var _loc1_:Sprite = null;
         var _loc2_:Sprite = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,"popup_dailyreward"))();
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_FEMALE)
         {
            _loc1_ = mBox.getChildByName("boss") as Sprite;
            _loc2_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,"boss_02"))();
            _loc2_.x = _loc1_.x;
            _loc2_.y = _loc1_.y;
            mBox.addChildAt(_loc2_,mBox.getChildIndex(_loc1_));
            mBox.removeChild(_loc1_);
         }
         this.mTitle = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.getText(TextIDs.TID_DAILY_BONUS_TITLE);
         TextManager.setTextScaled(this.mTitle);
         mBox.addChild(this.mTitle);
         mTextBox = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(mTextBox);
         mTextBox.text = TextManager.getText(TextIDs.TID_DAILY_BONUS_BODY);
         TextManager.setTextScaled(mTextBox);
         mBox.addChild(mTextBox);
         this.mConfirmButton = new DynamicButton(mBox.getChildByName("ConfirmButton") as MovieClip);
         this.mConfirmButton.setLabel(TextManager.getText(TextIDs.TID_DAILY_BONUS_BUTTON));
         this.getRewards();
      }
      
      private function onEnableConfirmButton(param1:Event) : void
      {
         this.mConfirmButton.enable();
         this.mConfirmButton.addEventListener(MouseEvent.CLICK,this.onConfirm);
      }
      
      private function getRewards() : void
      {
         var _loc4_:DailyReward = null;
         var _loc5_:DailyBigReward = null;
         var _loc1_:int = 1;
         var _loc2_:int = 0;
         var _loc3_:int = DailyBonusManager.getInstance().getDailyBonusCount();
         _loc3_ %= this.LAST_DAY;
         if(_loc3_ == 0)
         {
            _loc3_ = this.LAST_DAY;
         }
         this.mRewards = new Array();
         this.mCollectedRewards = DailyBonusManager.getInstance().getCollectedDailyBonuses();
         var _loc6_:Array = DailyBonusManager.getInstance().getCollectedDailyBonuses();
         var _loc7_:int = _loc6_.length - 1;
         var _loc8_:int = _loc7_ - (_loc3_ - 1) < 0 ? 0 : int(_loc7_ - (_loc3_ - 1));
         _loc6_ = _loc6_.slice(_loc8_,_loc7_);
         while(_loc1_ < this.LAST_DAY)
         {
            if(_loc1_ < _loc3_)
            {
               _loc4_ = new DailyReward(_loc1_,DailyReward.COLLECTED,_loc6_[_loc1_ - 1]);
               _loc4_.x = this.XINIT + (_loc1_ - 1) * this.XOFFSET;
               _loc4_.y = this.YOFFSET;
               this.mRewards.push(_loc4_);
               mBox.addChild(_loc4_);
            }
            else if(_loc1_ == _loc3_)
            {
               _loc4_ = new DailyReward(_loc1_,DailyReward.CURRENT,DailyBonusManager.getInstance().getCurrentDailyBonusSku());
               _loc4_.x = this.XINIT + (_loc1_ - 1) * this.XOFFSET;
               _loc4_.y = this.YOFFSET;
               _loc4_.addEventListener(EVENT_ANIMATION_END,this.onEnableConfirmButton);
               this.mRewards.push(_loc4_);
               mBox.addChild(_loc4_);
            }
            else
            {
               _loc4_ = new DailyReward(_loc1_,DailyReward.PENDING);
               _loc4_.x = this.XINIT + (_loc1_ - 1) * this.XOFFSET;
               _loc4_.y = this.YOFFSET;
               this.mRewards.push(_loc4_);
               mBox.addChild(_loc4_);
            }
            _loc4_.start();
            _loc1_++;
         }
         if(_loc3_ == this.LAST_DAY)
         {
            _loc5_ = new DailyBigReward(this.LAST_DAY,DailyBigReward.CURRENT,DailyBonusManager.getInstance().getCurrentDailyBonusSku());
            _loc5_.x = this.XINIT + (this.LAST_DAY - 1) * this.XOFFSET;
            _loc5_.y = this.YOFFSET;
            mBox.addChild(_loc5_);
            _loc5_.start();
            _loc5_.addEventListener(EVENT_ANIMATION_END,this.onEnableConfirmButton);
         }
         else
         {
            _loc5_ = new DailyBigReward(this.LAST_DAY,DailyBigReward.PENDING);
            _loc5_.x = this.XINIT + (this.LAST_DAY - 1) * this.XOFFSET;
            _loc5_.y = this.YOFFSET;
            mBox.addChild(_loc5_);
            _loc5_.start();
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow(false);
      }
      
      public function setRewardSku(param1:String) : void
      {
         this.mCollectedReward = param1;
      }
      
      override protected function endButtons() : void
      {
         this.mConfirmButton.end();
         this.mConfirmButton.removeEventListener(MouseEvent.CLICK,this.onConfirm);
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
      }
   }
}

