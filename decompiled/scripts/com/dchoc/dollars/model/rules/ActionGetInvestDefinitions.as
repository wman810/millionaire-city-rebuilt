package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.invests.InvestDefinition;
   import com.dchoc.dollars.invests.InvestDefinitionManager;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardCoins;
   import com.dchoc.dollars.rewards.RewardExp;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetInvestDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetInvestDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(InvestDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc3_:Reward = null;
         var _loc2_:InvestDefinition = super.itemFromXML(param1) as InvestDefinition;
         _loc2_.target = int(param1.@target);
         _loc2_.setCostDCCoins(param1.@inversion);
         _loc2_.setTime(param1.@time);
         if("@rewardDCCoins" in param1)
         {
            if(param1.@rewardDCCoins != "" && param1.@rewardDCCoins > 0)
            {
               _loc3_ = new RewardCoins(param1.@rewardDCCoins);
               _loc2_.addReward(_loc3_);
            }
         }
         if("@rewardExp" in param1)
         {
            if(param1.@rewardExp != "" && param1.@rewardExp > 0)
            {
               _loc3_ = new RewardExp(param1.@rewardExp);
               _loc2_.addReward(_loc3_);
            }
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new InvestDefinition(mType);
      }
   }
}

