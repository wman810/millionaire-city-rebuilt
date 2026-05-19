package com.dchoc.dollars.world.contracts
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class ContractsTypeDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ContractsTypeDefinitionManager;
      
      public function ContractsTypeDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ContractsTypeDefinitionManager Error: Instantiation failed: Use ContractsTypeDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : ContractsTypeDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ContractsTypeDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override protected function sortIsNeeded() : Boolean
      {
         return false;
      }
   }
}

