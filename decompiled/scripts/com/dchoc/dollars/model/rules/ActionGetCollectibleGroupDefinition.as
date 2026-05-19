package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.collectibles.CollectibleGroupDefinition;
   import com.dchoc.dollars.collectibles.CollectibleGroupDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetCollectibleGroupDefinition extends ActionGetDefinitions
   {
      
      public function ActionGetCollectibleGroupDefinition(param1:String, param2:int = -1, param3:int = 0)
      {
         super(CollectibleGroupDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:CollectibleGroupDefinition = super.itemFromXML(param1) as CollectibleGroupDefinition;
         _loc2_.rewardSku = param1.@reward;
         if("@requirements" in param1)
         {
            _loc2_.requirements = param1.@requirements;
         }
         if("@icon" in param1)
         {
            _loc2_.icon = param1.@icon;
         }
         if("@commerce" in param1)
         {
            _loc2_.setIsCommerceGroup(param1.@commerce != "" && param1.@commerce != " ");
         }
         if("@tradein" in param1)
         {
            _loc2_.setCanBeReclaimed(param1.@tradein != "" && param1.@tradein != " ");
         }
         _loc2_.order = int(param1.@order);
         if("@tid" in param1)
         {
            _loc2_.textID = param1.@tid;
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new CollectibleGroupDefinition(mType);
      }
   }
}

