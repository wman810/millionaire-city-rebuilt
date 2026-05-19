package com.dchoc.dollars.dailyBonus
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class DailyBonusDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:DailyBonusDefinitionManager;
      
      public function DailyBonusDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: DailyBonusDefinitionManager Error: Instantiation failed: Use DailyBonusDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : DailyBonusDefinitionManager
      {
         if(!smInstance)
         {
            smAllowInstantiation = true;
            smInstance = new DailyBonusDefinitionManager();
            smAllowInstantiation = false;
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

