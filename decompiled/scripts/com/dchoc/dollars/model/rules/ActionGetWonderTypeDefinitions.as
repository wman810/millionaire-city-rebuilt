package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinition;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinitionManager;
   
   public class ActionGetWonderTypeDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetWonderTypeDefinitions(param1:String, param2:int, param3:int)
      {
         super(WonderTypeDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         return super.itemFromXML(param1) as WonderTypeDefinition;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new WonderTypeDefinition(mType);
      }
   }
}

