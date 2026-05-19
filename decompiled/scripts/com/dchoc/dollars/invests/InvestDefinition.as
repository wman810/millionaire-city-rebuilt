package com.dchoc.dollars.invests
{
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   
   public class InvestDefinition extends Definition
   {
      
      private var mCostDCCoins:int;
      
      private var mRewards:Array;
      
      private var mTime:int;
      
      private var mReward:Reward;
      
      private var mTarget:int;
      
      public function InvestDefinition(param1:uint)
      {
         super(param1);
         this.mRewards = new Array();
      }
      
      public function getCostDCCoins() : int
      {
         return this.mCostDCCoins;
      }
      
      public function destroyReward() : void
      {
         if(this.mReward != null)
         {
            this.mRewards.length = 0;
            this.mReward.destroy();
            this.mReward = null;
         }
      }
      
      public function set target(param1:int) : void
      {
         this.mTarget = param1;
      }
      
      public function getReward() : Reward
      {
         if(this.mReward == null && this.mRewards != null)
         {
            this.mReward = RewardManager.getInstance().getReward(this.mRewards);
         }
         return this.mReward;
      }
      
      public function getTime() : int
      {
         return this.mTime;
      }
      
      public function setTime(param1:int) : void
      {
         this.mTime = TimerUtil.daysToMs(param1);
      }
      
      public function addReward(param1:Reward) : void
      {
         this.mRewards.push(param1);
      }
      
      public function get target() : int
      {
         return this.mTarget;
      }
      
      public function getRewards() : Array
      {
         return this.mRewards;
      }
      
      public function setCostDCCoins(param1:int) : void
      {
         this.mCostDCCoins = param1;
      }
   }
}

