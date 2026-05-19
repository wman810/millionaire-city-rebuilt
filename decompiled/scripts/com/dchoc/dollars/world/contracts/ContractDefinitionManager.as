package com.dchoc.dollars.world.contracts
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class ContractDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ContractDefinitionManager;
      
      public function ContractDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ContractDefinitionManager Error: Instantiation failed: Use ContractDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : ContractDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ContractDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
   }
}

