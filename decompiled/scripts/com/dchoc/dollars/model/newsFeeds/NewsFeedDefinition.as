package com.dchoc.dollars.model.newsFeeds
{
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class NewsFeedDefinition extends Definition
   {
      
      private var mTextID:String;
      
      private var mRewardType:String;
      
      private var mRewards:Array;
      
      private var mReward:Reward;
      
      public function NewsFeedDefinition(param1:uint)
      {
         super(param1);
         this.mRewards = new Array();
      }
      
      public function getReward() : Reward
      {
         if(this.mReward == null && this.mRewards != null)
         {
            this.mReward = RewardManager.getInstance().getReward(this.mRewards);
         }
         return this.mReward;
      }
      
      public function hasReward() : Boolean
      {
         return this.mRewards.length > 0;
      }
      
      public function setRewardType(param1:String) : void
      {
         this.mRewardType = param1;
      }
      
      public function getRewards() : Array
      {
         return this.mRewards;
      }
      
      public function addReward(param1:Reward) : void
      {
         this.mRewards.push(param1);
      }
      
      public function setTextID(param1:String) : void
      {
         this.mTextID = param1;
      }
      
      public function getTextID() : String
      {
         return this.mTextID;
      }
      
      public function getRewardType() : String
      {
         return this.mRewardType;
      }
   }
}

