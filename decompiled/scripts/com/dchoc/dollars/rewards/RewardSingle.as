package com.dchoc.dollars.rewards
{
   import flash.display.Sprite;
   
   public class RewardSingle extends Reward
   {
      
      protected var mAmount:int;
      
      protected var mSku:String;
      
      public function RewardSingle(param1:int, param2:String)
      {
         super();
         this.mAmount = param1;
         this.mSku = param2;
      }
      
      override public function destroy() : void
      {
      }
      
      override public function doApply() : void
      {
      }
      
      override public function draw() : Sprite
      {
         return null;
      }
      
      public function getSku() : String
      {
         return this.mSku;
      }
      
      override public function getDOName() : String
      {
         return "";
      }
      
      public function getAmount() : int
      {
         return this.mAmount;
      }
      
      override public function getText() : String
      {
         return "" + this.mAmount;
      }
      
      protected function doGetRewardID() : String
      {
         return "";
      }
      
      public function setAmount(param1:int) : void
      {
         this.mAmount = param1;
      }
      
      public function setSku(param1:String) : void
      {
         this.mSku = param1;
      }
      
      override public function getRewardType() : RewardTypeDefinition
      {
         return RewardTypeDefinitionManager.getInstance().getDefinitionBySku(this.doGetRewardID()) as RewardTypeDefinition;
      }
   }
}

