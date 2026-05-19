package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.items.commerces.CommerceTypeDefinition;
   import com.dchoc.dollars.world.items.commerces.CommerceTypeDefinitionManager;
   
   public class ActionGetCommerceTypeDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetCommerceTypeDefinitions(param1:String, param2:int, param3:int)
      {
         super(CommerceTypeDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         return super.itemFromXML(param1) as CommerceTypeDefinition;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new CommerceTypeDefinition(mType);
      }
   }
}

