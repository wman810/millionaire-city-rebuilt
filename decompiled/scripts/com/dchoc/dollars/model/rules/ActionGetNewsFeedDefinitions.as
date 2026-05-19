package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinition;
   import com.dchoc.dollars.model.newsFeeds.NewsFeedDefinitionManager;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardCoins;
   import com.dchoc.dollars.rewards.RewardExp;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetNewsFeedDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetNewsFeedDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(NewsFeedDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc3_:Reward = null;
         var _loc2_:NewsFeedDefinition = super.itemFromXML(param1) as NewsFeedDefinition;
         if("@rewardType" in param1 && "@rewardAmount" in param1)
         {
            _loc2_.setRewardType(param1.@rewardType);
            if(_loc2_.getRewardType() == "Exp")
            {
               _loc3_ = new RewardExp(param1.@rewardAmount);
            }
            else
            {
               _loc3_ = new RewardCoins(param1.@rewardAmount);
            }
            _loc2_.addReward(_loc3_);
            _loc2_.setTextID(String(param1.@tid));
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new NewsFeedDefinition(mType);
      }
   }
}

