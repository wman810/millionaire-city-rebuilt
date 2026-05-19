package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinitionManager;
   
   public class ActionGetContractsTypesDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetContractsTypesDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(ContractsTypeDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:ContractsTypeDefinition = null;
         _loc2_ = super.itemFromXML(param1) as ContractsTypeDefinition;
         _loc2_.setContractsSkus(param1.@contractsSkus);
         mSig += param1.@sku + param1.@contractsSkus;
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new ContractsTypeDefinition(mType);
      }
   }
}

