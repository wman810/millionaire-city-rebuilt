package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.rewards.RewardTypeDefinition;
   import com.dchoc.dollars.rewards.RewardTypeDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetRewardTypeDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetRewardTypeDefinitions(param1:String, param2:int, param3:int = 0)
      {
         super(RewardTypeDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:RewardTypeDefinition = super.itemFromXML(param1) as RewardTypeDefinition;
         if("@clickSoundFx" in param1)
         {
            _loc2_.setClickSoundFx(String(param1.@clickSoundFx));
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new RewardTypeDefinition(mType);
      }
   }
}

