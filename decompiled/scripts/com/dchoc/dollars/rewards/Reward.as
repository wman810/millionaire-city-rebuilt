package com.dchoc.dollars.rewards
{
   import flash.display.Sprite;
   
   public class Reward
   {
      
      public function Reward()
      {
         super();
      }
      
      public function getText() : String
      {
         return "";
      }
      
      public function draw() : Sprite
      {
         return null;
      }
      
      public function getRewards() : Array
      {
         return null;
      }
      
      public function destroy() : void
      {
      }
      
      public function doApply() : void
      {
      }
      
      public function getDOName() : String
      {
         return "";
      }
      
      public function apply() : void
      {
         this.doApply();
      }
      
      public function getRewardType() : RewardTypeDefinition
      {
         return null;
      }
   }
}

