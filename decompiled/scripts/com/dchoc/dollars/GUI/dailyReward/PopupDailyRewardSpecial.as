package com.dchoc.dollars.GUI.dailyReward
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinition;
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinitionManager;
   import com.dchoc.dollars.dailyBonus.DailyBonusManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupDailyRewardSpecial extends PopupDailyReward
   {
      
      private var mClaimButton:DynamicButton;
      
      private var mReward:MovieClip;
      
      private var mRewardContainer:Sprite;
      
      private var mTextInfo:TextField;
      
      private var mImage:MovieClip;
      
      private var mRewardDefinition:DailyBonusDefinition;
      
      public function PopupDailyRewardSpecial()
      {
         super();
      }
      
      override protected function load() : void
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BIRTHDAY_REWARD_SWF,"popup_cake"))();
         mTitle = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(mTitle);
         mTitle.text = TextManager.getText(TextIDs.TID_BIRTHDAY_POPUP_TITLE);
         TextManager.setTextScaled(mTitle);
         this.mTextInfo = mBox.getChildByName("TextInfo_01") as TextField;
         TextManager.reformatTextField(this.mTextInfo);
         this.mTextInfo.text = TextManager.getText(TextIDs.TID_BIRTHDAY_POPUP_BODY);
         TextManager.setTextScaled(this.mTextInfo);
         this.mImage = mBox.getChildByName("cakeExplosion") as MovieClip;
         Dollars.stopChild(this.mImage);
         this.mReward = this.mImage.getChildByName("reward_container") as MovieClip;
         this.mRewardContainer = this.mReward.getChildByName("container") as Sprite;
         this.mClaimButton = new DynamicButton(mBox.getChildByName("claimButton") as MovieClip);
         this.mClaimButton.setLabel(TextManager.getText(TextIDs.TID_BIRTHDAY_POPUP_BUTTON));
         mConfirmButton = new DynamicButton(mBox.getChildByName("confirmButton") as MovieClip);
         mConfirmButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_CONTINUE));
         this.mRewardDefinition = DailyBonusDefinitionManager.getInstance().getDefinitionBySku(DailyBonusManager.getInstance().getCurrentDailyBonusSku()) as DailyBonusDefinition;
      }
      
      private function checkAnimEnd(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_.currentFrame == _loc2_.totalFrames)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
            _loc2_.stop();
            Dollars.stopChild(_loc2_);
            DollarsGame.smInstance.mGameClip.mouseEnabled = true;
            this.mClaimButton.visible = false;
            mConfirmButton.enable();
            mConfirmButton.visible = true;
            mConfirmButton.addEventListener(MouseEvent.CLICK,this.onConfirm);
         }
      }
      
      override protected function endButtons() : void
      {
         mConfirmButton.end();
         mConfirmButton.removeEventListener(MouseEvent.CLICK,this.onConfirm);
         this.mClaimButton.end();
      }
      
      private function addReward() : void
      {
         var _loc1_:Sprite = null;
         var _loc2_:TextField = null;
         var _loc3_:TextField = null;
         var _loc4_:int = 0;
         var _loc5_:ItemDefinition = null;
         switch(this.mRewardDefinition.bonusType)
         {
            case DailyBonusDefinition.TYPE_COINS:
               _loc1_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BIRTHDAY_REWARD_SWF,"reward_coins"))() as Sprite;
               _loc2_ = _loc1_.getChildByName("TextInfo") as TextField;
               TextManager.reformatTextField(_loc2_);
               _loc4_ = int(this.mRewardDefinition.value) * DollarsGame.getProfile().level;
               _loc2_.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(_loc4_,12,12);
               TextManager.setTextScaled(_loc2_);
               _loc3_ = this.mReward.getChildByName("caption") as TextField;
               TextManager.reformatTextField(_loc3_);
               _loc3_.text = TextManager.getText(TextIDs.TID_GEN_DCCOINS);
               TextManager.setTextScaled(_loc3_);
               break;
            case DailyBonusDefinition.TYPE_CASH:
               _loc1_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BIRTHDAY_REWARD_SWF,"reward_cash"))() as Sprite;
               _loc2_ = _loc1_.getChildByName("TextInfo") as TextField;
               TextManager.reformatTextField(_loc2_);
               _loc2_.text = this.mRewardDefinition.value;
               TextManager.setTextScaled(_loc2_);
               _loc3_ = this.mReward.getChildByName("caption") as TextField;
               TextManager.reformatTextField(_loc3_);
               _loc3_.text = TextManager.getText(TextIDs.TID_GEN_DCCASH);
               TextManager.setTextScaled(_loc3_);
               break;
            case DailyBonusDefinition.TYPE_ITEM:
               _loc5_ = ItemDefinitionManager.getInstance().getDefinitionBySku(this.mRewardDefinition.value) as ItemDefinition;
               _loc1_ = _loc5_.getIcon(this.mRewardContainer).icon as Sprite;
               _loc3_ = this.mReward.getChildByName("caption") as TextField;
               TextManager.reformatTextField(_loc3_);
               _loc3_.text = TextManager.getText(TextIDs[_loc5_.textID]);
               TextManager.setTextScaled(_loc3_);
         }
         this.mRewardContainer.addChild(_loc1_);
      }
      
      private function onConfirm(param1:MouseEvent) : void
      {
         onClose(null);
      }
      
      private function onClaim(param1:MouseEvent) : void
      {
         this.addReward();
         if(Dollars.smStage.quality.toUpperCase() == StageQuality.LOW.toUpperCase())
         {
            this.mImage.gotoAndStop(this.mImage.totalFrames);
         }
         else
         {
            this.mImage.play();
            Dollars.playChilds(this.mImage);
            Dollars.stopChild(this.mRewardContainer);
         }
         this.mImage.addEventListener(Event.ENTER_FRAME,this.checkAnimEnd);
         DailyBonusManager.getInstance().keepDailyBonus(this.mRewardDefinition.sku);
         this.mClaimButton.disable();
         this.mClaimButton.removeEventListener(MouseEvent.CLICK,this.onClaim);
      }
      
      override protected function startButtons() : void
      {
         mConfirmButton.start();
         mConfirmButton.disable();
         mConfirmButton.visible = false;
         this.mClaimButton.start();
         this.mClaimButton.addEventListener(MouseEvent.CLICK,this.onClaim);
      }
   }
}

