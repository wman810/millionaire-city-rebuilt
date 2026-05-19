package com.dchoc.dollars.GUI.dailyReward
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinition;
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinitionManager;
   import com.dchoc.dollars.dailyBonus.DailyBonusManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class DailyReward extends Sprite
   {
      
      public static const COLLECTED:uint = 0;
      
      public static const CURRENT:uint = 1;
      
      public static const PENDING:uint = 2;
      
      private var mStatus:Number;
      
      private var mImage:MovieClip;
      
      public var mRewardDefinition:DailyBonusDefinition;
      
      private var mSku:String;
      
      private var mCaption:TextField;
      
      private var mReward:Sprite;
      
      private var mButton:DynamicButton;
      
      public function DailyReward(param1:Number, param2:Number, param3:String = null)
      {
         var _loc4_:TextField = null;
         var _loc5_:String = null;
         super();
         this.mStatus = param2;
         this.mSku = param3;
         this.mRewardDefinition = DailyBonusDefinitionManager.getInstance().getDefinitionBySku(this.mSku) as DailyBonusDefinition;
         switch(param2)
         {
            case COLLECTED:
               this.mReward = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,"popup_box_dailyreward"))();
               addChild(this.mReward);
               if(this.mRewardDefinition != null)
               {
                  this.mImage = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,this.rewardType(this.mRewardDefinition)))();
                  this.mReward.addChild(this.mImage);
                  _loc4_ = this.mImage.getChildByName("TextInfo") as TextField;
                  _loc5_ = this.mRewardDefinition.value;
                  if(this.mRewardDefinition)
                  {
                     if(this.mRewardDefinition.bonusType == "coins")
                     {
                        _loc5_ = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + _loc5_;
                     }
                  }
                  _loc4_.text = _loc5_;
                  TextManager.setTextScaled(_loc4_);
               }
               else
               {
                  this.mImage = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,this.rewardBox(param1)))();
                  this.mImage.x = this.mImage.width + 7;
                  this.mImage.y = this.mImage.height + 23;
                  this.mImage.gotoAndStop(32);
                  this.mReward.addChild(this.mImage);
               }
               this.mButton = new DynamicButton(this.mReward.getChildByName("okButton") as MovieClip);
               break;
            case CURRENT:
               this.mReward = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,"popup_box_dailyreward"))();
               addChild(this.mReward);
               this.mImage = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,this.rewardBox(param1)))();
               this.mImage.x = this.mImage.width + 7;
               this.mImage.y = this.mImage.height + 23;
               this.mImage.gotoAndStop(32);
               this.mReward.addChild(this.mImage);
               this.mButton = new DynamicButton(this.mReward.getChildByName("okButton") as MovieClip);
               break;
            case PENDING:
               this.mReward = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,"popup_box_dailyreward_lock"))();
               addChild(this.mReward);
               this.mImage = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,this.rewardBox(param1)))();
               this.mImage.x = this.mImage.width + 7;
               this.mImage.y = this.mImage.height + 23;
               this.mImage.gotoAndStop(32);
               this.mReward.addChild(this.mImage);
               this.mButton = new DynamicButton(this.mReward.getChildByName("okButton") as MovieClip);
         }
         this.mCaption = this.mReward.getChildByName("mTitle") as TextField;
         TextManager.reformatTextField(this.mCaption);
         this.mCaption.text = TextManager.replaceParameters(TextIDs.TID_DAILY_BONUS_DAY,new Array(param1.toString()));
         TextManager.setTextScaled(this.mCaption);
      }
      
      private function rewardType(param1:DailyBonusDefinition) : String
      {
         if(param1 != null)
         {
            if(param1.bonusType == "exp")
            {
               return "Reward_Xp_2";
            }
            if(param1.bonusType == "coins")
            {
               return "Reward_coins_2";
            }
            if(param1.bonusType == "cash")
            {
               return "Reward_DC_cash_2";
            }
         }
         return "Daily_Reward_01";
      }
      
      public function start() : void
      {
         if(this.mStatus == CURRENT)
         {
            this.mButton.start();
            this.mButton.addEventListener(MouseEvent.CLICK,this.onClaim);
         }
         else if(this.mStatus == PENDING)
         {
            this.mButton.disable();
         }
         else
         {
            this.mButton.start();
            this.mButton.getButtonMc().visible = false;
         }
      }
      
      private function checkAnimEnd(param1:Event) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:TextField = null;
         var _loc5_:String = null;
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_.currentFrame == _loc2_.totalFrames)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
            _loc2_.stop();
            DollarsGame.smInstance.mGameClip.mouseEnabled = true;
            this.mButton.end();
            this.mReward.removeChild(this.mButton.getButtonMc());
            this.mReward.removeChild(_loc2_);
            _loc3_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.DAILY_REWARD_SWF,this.rewardType(this.mRewardDefinition)))();
            this.mReward.addChild(_loc3_);
            _loc4_ = _loc3_.getChildByName("TextInfo") as TextField;
            _loc5_ = this.mRewardDefinition.value;
            if(this.mRewardDefinition)
            {
               if(this.mRewardDefinition.bonusType == "coins")
               {
                  _loc5_ = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + _loc5_;
               }
            }
            _loc4_.text = _loc5_;
            TextManager.setTextScaled(_loc4_);
            DollarsGame.smInstance.mPopupDailyReward.setRewardSku(this.mSku);
            dispatchEvent(new Event(PopupDailyReward.EVENT_ANIMATION_END));
         }
      }
      
      private function rewardBox(param1:Number) : String
      {
         var _loc2_:String = "Daily_Reward_01";
         switch(param1)
         {
            case 1:
               _loc2_ = "Daily_Reward_01";
               break;
            case 2:
               _loc2_ = "Daily_Reward_02";
               break;
            case 3:
               _loc2_ = "Daily_Reward_03";
               break;
            case 4:
               _loc2_ = "Daily_Reward_04";
               break;
            default:
               _loc2_ = "Daily_Reward_01";
         }
         return _loc2_;
      }
      
      private function onClaim(param1:MouseEvent) : void
      {
         this.mButton.removeEventListener(MouseEvent.CLICK,this.onClaim);
         if(Dollars.smStage.quality.toUpperCase() == StageQuality.LOW.toUpperCase())
         {
            this.mImage.gotoAndStop(this.mImage.totalFrames);
         }
         else
         {
            this.mImage.play();
         }
         this.mImage.addEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
         DailyBonusManager.getInstance().keepDailyBonus(this.mSku);
      }
   }
}

