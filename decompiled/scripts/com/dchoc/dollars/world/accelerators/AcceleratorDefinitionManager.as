package com.dchoc.dollars.world.accelerators
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class AcceleratorDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:AcceleratorDefinitionManager;
      
      public function AcceleratorDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ItemDefinitionManager Error: Instantiation failed: Use ItemDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : AcceleratorDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new AcceleratorDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
   }
}

