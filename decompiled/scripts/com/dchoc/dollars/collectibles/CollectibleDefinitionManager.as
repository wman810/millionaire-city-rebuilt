package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class CollectibleDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:CollectibleDefinitionManager;
      
      public function CollectibleDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: CollectibleDefinitionManager Error: Instantiation failed: Use CollectibleDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : CollectibleDefinitionManager
      {
         if(!smInstance)
         {
            smAllowInstantiation = true;
            smInstance = new CollectibleDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override public function getDefinitionBySku(param1:String) : Definition
      {
         var _loc2_:Definition = super.getDefinitionBySku(param1) as Definition;
         if(_loc2_ == null)
         {
            _loc2_ = super.getDefinitionBySku("default") as Definition;
         }
         return _loc2_;
      }
   }
}

