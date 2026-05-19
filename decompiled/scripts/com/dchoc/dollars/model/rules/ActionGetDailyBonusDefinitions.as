package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinition;
   import com.dchoc.dollars.dailyBonus.DailyBonusDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   
   public class ActionGetDailyBonusDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetDailyBonusDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(DailyBonusDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:DailyBonusDefinition = super.itemFromXML(param1) as DailyBonusDefinition;
         _loc2_.bonusType = param1.@bonusType;
         _loc2_.value = param1.@bonusValue;
         _loc2_.group = int(param1.@group);
         _loc2_.chances = Number(param1.@chances);
         _loc2_.setDate(param1.@date);
         if(_loc2_.bonusType == "item")
         {
            PriorityLoader.getInstance().queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_ITEMS + _loc2_.value + ".swf",_loc2_.value,".swf");
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new DailyBonusDefinition(mType);
      }
   }
}

