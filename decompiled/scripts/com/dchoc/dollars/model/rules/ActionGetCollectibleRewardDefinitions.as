package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetCollectibleRewardDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetCollectibleRewardDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(CollectibleRewardDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:CollectibleRewardDefinition = super.itemFromXML(param1) as CollectibleRewardDefinition;
         if("@rewardType" in param1)
         {
            _loc2_.rewardType = param1.@rewardType;
         }
         if("@value" in param1)
         {
            _loc2_.Value = param1.@value;
         }
         if("@tid" in param1)
         {
            _loc2_.textID = param1.@tid;
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new CollectibleRewardDefinition(mType);
      }
   }
}

