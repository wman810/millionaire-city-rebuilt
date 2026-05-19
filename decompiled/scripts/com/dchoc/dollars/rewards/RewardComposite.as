package com.dchoc.dollars.rewards
{
   import flash.display.Sprite;
   
   public class RewardComposite extends Reward
   {
      
      private var mRewards:Array;
      
      public function RewardComposite()
      {
         super();
         this.mRewards = new Array();
      }
      
      public function addReward(param1:Reward) : void
      {
         this.mRewards.push(param1);
      }
      
      override public function doApply() : void
      {
         var _loc1_:Reward = null;
         for each(_loc1_ in this.mRewards)
         {
            _loc1_.doApply();
         }
      }
      
      override public function draw() : Sprite
      {
         var _loc5_:RewardSingle = null;
         var _loc6_:Sprite = null;
         var _loc1_:Sprite = new Sprite();
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         for each(_loc5_ in this.mRewards)
         {
            _loc6_ = _loc5_.draw();
            _loc1_.addChild(_loc6_);
            _loc6_.x = _loc2_;
            _loc6_.y = _loc3_;
            _loc4_++;
            _loc2_ += _loc6_.width;
            if(_loc4_ % 4 == 0)
            {
               _loc2_ = 0;
               _loc3_ += _loc6_.height;
            }
         }
         return _loc1_;
      }
      
      override public function getRewards() : Array
      {
         return this.mRewards;
      }
      
      override public function destroy() : void
      {
         var _loc1_:Reward = null;
         for each(_loc1_ in this.mRewards)
         {
            _loc1_.destroy();
         }
      }
      
      public function removeReward(param1:Reward) : void
      {
         var _loc2_:int = this.mRewards.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.mRewards.splice(_loc2_,1);
         }
      }
   }
}

