package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class CollectibleRewardDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantation:Boolean;
      
      private static var smInstance:CollectibleRewardDefinitionManager;
      
      public function CollectibleRewardDefinitionManager()
      {
         super();
         if(!smAllowInstantation)
         {
            throw new Error("ERROR: CollectiblRewardeDefinitionManager Error: Instantiation failed: Use CollectibleRewardDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : CollectibleRewardDefinitionManager
      {
         if(!smInstance)
         {
            smAllowInstantation = true;
            smInstance = new CollectibleRewardDefinitionManager();
            smAllowInstantation = false;
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

