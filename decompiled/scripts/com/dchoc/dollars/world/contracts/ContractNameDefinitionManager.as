package com.dchoc.dollars.world.contracts
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class ContractNameDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ContractNameDefinitionManager;
      
      public function ContractNameDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ContractNameDefinitionManager Error: Instantiation failed: Use ContractNameDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : ContractNameDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ContractNameDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
   }
}

