package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.GUI.crosspromotion.CrosspromotionDefinition;
   import com.dchoc.dollars.GUI.crosspromotion.CrosspromotionDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetCrosspromotionDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetCrosspromotionDefinitions(param1:String, param2:int, param3:int = 0)
      {
         super(CrosspromotionDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:CrosspromotionDefinition = super.itemFromXML(param1) as CrosspromotionDefinition;
         if("@image" in param1)
         {
            _loc2_.image = param1.@image;
         }
         if("@url" in param1)
         {
            _loc2_.url = param1.@url;
         }
         if("@tidTitle" in param1)
         {
            _loc2_.tidTitle = param1.@tidTitle;
         }
         if("@tidBody" in param1)
         {
            _loc2_.tidBody = param1.@tidBody;
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new CrosspromotionDefinition(mType);
      }
   }
}

