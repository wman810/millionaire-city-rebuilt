package com.dchoc.dollars.GUI.newsfeeds
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinition;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardCoins;
   import com.dchoc.dollars.rewards.RewardExp;
   import com.dchoc.dollars.rewards.RewardTypeDefinition;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.media.SoundManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class NewsFeedRewardPresentation extends Popup
   {
      
      private var mNewsFeedDefinition:NewsFeedDefinition;
      
      private var mReward:Reward;
      
      public function NewsFeedRewardPresentation(param1:Boolean = true)
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"popup_gift_found"))();
         mOkButton = new DynamicButton(mBox.getChildByName("AcceptButton") as MovieClip);
         mOkButton.setLabel(TextManager.getText(TextIDs.TID_PARTNER_POST_BUTTON2));
         var _loc2_:TextField = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs.TID_NEWSFEED_REWARD_POST_POPUP_TITLE);
         TextManager.setTextScaled(_loc2_);
         _loc2_ = mBox.getChildByName("TextInfo_02") as TextField;
         TextManager.reformatTextField(_loc2_);
         TextManager.setTextScaled(_loc2_);
         _loc2_.visible = false;
         super(param1);
      }
      
      public function showPopupParams(param1:NewsFeedDefinition) : void
      {
         var _loc2_:Sprite = null;
         super.show();
         mOkButton.start();
         mOkButton.getButtonMc().addEventListener(MouseEvent.CLICK,this.onAccept);
         this.mNewsFeedDefinition = param1;
         this.mReward = this.mNewsFeedDefinition.getReward();
         _loc2_ = mBox["container_reward"];
         var _loc3_:Sprite = this.mReward.draw();
         var _loc4_:Number = _loc2_.width / _loc3_.width;
         var _loc5_:Number = _loc2_.height / _loc3_.height;
         var _loc6_:Number = _loc4_ < _loc5_ ? _loc4_ : _loc5_;
         if(_loc6_ > 1)
         {
            _loc6_ = 1;
         }
         _loc3_.scaleX = _loc6_;
         _loc3_.scaleY = _loc6_;
         mBox.addChild(_loc3_);
         var _loc7_:Rectangle = _loc3_.getBounds(mBox);
         var _loc8_:Rectangle = _loc2_.getBounds(mBox);
         _loc3_.x += _loc8_.x - _loc7_.x + (_loc2_.width - _loc3_.width) / 2;
         _loc3_.y += _loc8_.y - _loc7_.y + (_loc2_.height - _loc3_.height) / 2;
         _loc2_.visible = false;
         var _loc9_:TextField = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(_loc9_);
         if(this.mReward is RewardCoins)
         {
            _loc9_.text = TextManager.getText(TextIDs.TID_NEWSFEED_REWARD_POST_POPUP_DESC_DCCOINS);
         }
         else if(this.mReward is RewardExp)
         {
            _loc9_.text = TextManager.getText(TextIDs.TID_NEWSFEED_REWARD_POST_POPUP_DESC_EXP);
         }
         else
         {
            _loc9_.text = TextManager.getText(TextIDs.TID_NEWSFEED_REWARD_POST_POPUP_DESC_DCCOINS);
         }
         TextManager.setTextScaled(_loc9_);
         startShow(false);
      }
      
      override public function onAccept(param1:MouseEvent) : void
      {
         var _loc2_:RewardTypeDefinition = null;
         this.mReward.apply();
         if(Config.USE_SOUNDS)
         {
            _loc2_ = this.mReward.getRewardType();
            if(_loc2_ != null && _loc2_.getClickSoundFx() != null)
            {
               SoundManager.getInstance().playSound(_loc2_.getClickSoundFx(),1,0,0);
            }
         }
         DollarsGame.getCurrentWorld().getCompanyMine().delayedPaymentPay();
         UserDataFacade.getInstance().updateMoney("reward",{"value":this.mNewsFeedDefinition.sku});
         super.onAccept(null);
      }
      
      override protected function close() : void
      {
         super.close();
         if(this.mReward != null)
         {
            this.mReward.destroy();
            this.mReward = null;
         }
         mOkButton.end();
         mOkButton.getButtonMc().removeEventListener(MouseEvent.CLICK,this.onAccept);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
   }
}

