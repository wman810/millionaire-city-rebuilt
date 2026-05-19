package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.contracts.ContractNameDefinition;
   import com.dchoc.dollars.world.contracts.ContractNameDefinitionManager;
   
   public class ActionGetContractNameDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetContractNameDefinitions(param1:String, param2:int, param3:int = 0)
      {
         super(ContractNameDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new ContractNameDefinition(mType);
      }
   }
}

