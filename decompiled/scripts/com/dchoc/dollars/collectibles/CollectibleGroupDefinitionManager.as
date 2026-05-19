package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class CollectibleGroupDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:CollectibleGroupDefinitionManager;
      
      public static const EVENT_COLLECTIBLE_GROUP_COMPLETE:String = "EventCollectibleGroupComplete";
      
      public function CollectibleGroupDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: CollectibleGroupDefinitionManager Error: Instantiation failed: Use CollectibleGroupDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : CollectibleGroupDefinitionManager
      {
         if(!smInstance)
         {
            smAllowInstantiation = true;
            smInstance = new CollectibleGroupDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override protected function sortIsNeeded() : Boolean
      {
         return false;
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

