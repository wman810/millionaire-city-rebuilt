package com.dchoc.dollars.GUI.crosspromotion
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class CrosspromotionDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:CrosspromotionDefinitionManager;
      
      public function CrosspromotionDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ShopTabDefinitionManager Error: Instantiation failed: Use ShopTabDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : CrosspromotionDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new CrosspromotionDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
   }
}

