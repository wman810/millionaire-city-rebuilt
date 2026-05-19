package com.dchoc.dollars.world.items.wonders
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class WonderTypeDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:WonderTypeDefinitionManager;
      
      public function WonderTypeDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: WonderTypeDefinitionManager Error: Instantiation failed: Use WonderTypeDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : WonderTypeDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new WonderTypeDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
   }
}

