package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.model.services.ServiceDefinition;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetServiceDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetServiceDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(ServiceDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:ServiceDefinition = super.itemFromXML(param1) as ServiceDefinition;
         _loc2_.fromXML(param1);
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new ServiceDefinition(mType);
      }
   }
}

