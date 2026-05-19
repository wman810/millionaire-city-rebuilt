package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.accelerators.AcceleratorDefinition;
   import com.dchoc.dollars.world.accelerators.AcceleratorDefinitionManager;
   
   public class ActionGetAcceleratorDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetAcceleratorDefinitions(param1:String, param2:int = 0, param3:int = 0)
      {
         super(AcceleratorDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         return super.itemFromXML(param1) as AcceleratorDefinition;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new AcceleratorDefinition(mType);
      }
   }
}

