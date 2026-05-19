package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.dollars.world.contracts.ContractDefinitionManager;
   
   public class ActionGetContractDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetContractDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(ContractDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:ContractDefinition = null;
         _loc2_ = super.itemFromXML(param1) as ContractDefinition;
         _loc2_.setCostCoins(int(param1.@costCoins));
         _loc2_.setIncomeCoins(int(param1.@incomeCoins));
         _loc2_.setIncomeXP(int(param1.@incomeXp));
         _loc2_.setIncomeTime(String(param1.@incomeTime));
         _loc2_.setIconSku(param1.@icon);
         _loc2_.setNameSku(param1.@name);
         mSig += param1.@incomeCoins + param1.@incomeTime;
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new ContractDefinition(mType);
      }
   }
}

