package com.dchoc.dollars.rewards
{
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class RewardCoins extends RewardSingle
   {
      
      public function RewardCoins(param1:int = 0, param2:String = null)
      {
         super(param1,param2);
      }
      
      override public function getText() : String
      {
         return TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(mAmount,0,0);
      }
      
      override public function getDOName() : String
      {
         return "popup_reward_coins";
      }
      
      override public function doApply() : void
      {
         var _loc1_:Company = DollarsGame.getCurrentWorld().getCompanyMine();
         _loc1_.delayedPaymentSetCoins(-mAmount);
      }
      
      override public function draw() : Sprite
      {
         var _loc1_:Sprite = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"container_reward"))();
         var _loc2_:Sprite = _loc1_.getChildByName("mission_reward") as Sprite;
         var _loc3_:TextField = _loc1_.getChildByName("text_reward") as TextField;
         _loc1_.removeChild(_loc3_);
         _loc3_ = _loc1_.getChildByName("text_reward_2") as TextField;
         _loc3_.text = this.getText();
         TextManager.setTextScaled(_loc3_);
         var _loc4_:Bitmap = new Bitmap(DCResourceManager.getInstance().get(this.getDOName()));
         _loc4_.smoothing = true;
         _loc2_.addChild(_loc4_);
         return _loc1_;
      }
      
      override protected function doGetRewardID() : String
      {
         return RewardManager.REWARD_COINS_ID;
      }
   }
}

