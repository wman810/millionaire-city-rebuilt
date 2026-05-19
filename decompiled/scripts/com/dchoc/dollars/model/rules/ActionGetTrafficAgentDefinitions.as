package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.traffic.TrafficAgentDefinition;
   import com.dchoc.dollars.utils.traffic.TrafficAgentDefinitionManager;
   
   public class ActionGetTrafficAgentDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetTrafficAgentDefinitions(param1:String, param2:int = 0)
      {
         super(TrafficAgentDefinitionManager.getInstance(),param1,0,param2);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:TrafficAgentDefinition = super.itemFromXML(param1) as TrafficAgentDefinition;
         _loc2_.speed = param1.@speed;
         _loc2_.width = param1.@width;
         _loc2_.heigh = param1.@heigh;
         var _loc3_:String = param1.@spawnCondition;
         _loc2_.spawnCondition = _loc3_.split(",");
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new TrafficAgentDefinition(mType);
      }
   }
}

