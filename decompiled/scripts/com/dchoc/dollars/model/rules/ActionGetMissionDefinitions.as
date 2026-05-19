package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.missions.MissionDefinition;
   import com.dchoc.dollars.missions.MissionDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   
   public class ActionGetMissionDefinitions extends ActionGetDefinitions
   {
      
      public function ActionGetMissionDefinitions(param1:String, param2:int = -1, param3:int = 0)
      {
         super(MissionDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc3_:int = 0;
         var _loc2_:MissionDefinition = super.itemFromXML(param1) as MissionDefinition;
         _loc2_.missionName = param1.@missionName;
         _loc2_.eventType = param1.@type;
         _loc2_.eventParameter = param1.@parameter;
         _loc2_.eventAmount = param1.@amount;
         PriorityLoader.getInstance().queueLoad(PriorityLoader.QUEUE_ASYNC,Config.getRoot() + ModelConfig.DIR_MISSIONS_ICONS + _loc2_.eventType + ".png",_loc2_.eventType,".png");
         if("@condition" in param1)
         {
            _loc2_.eventCondition = param1.@condition;
         }
         if("@rewardType" in param1 && "@rewardAmount" in param1)
         {
            _loc2_.setRewardType(param1.@rewardType);
            _loc2_.setRewardAmount(param1.@rewardAmount);
         }
         if("@rewardTypeABtest1" in param1 && "@rewardAmountABtest1" in param1)
         {
            _loc2_.setRewardTypeABTest(1,param1.@rewardTypeABtest1);
            _loc2_.setRewardAmountABTest(1,param1.@rewardAmountABtest1);
         }
         if("@rewardTypeABtest2" in param1 && "@rewardAmountABtest2" in param1)
         {
            _loc2_.setRewardTypeABTest(2,param1.@rewardTypeABtest2);
            _loc2_.setRewardAmountABTest(2,param1.@rewardAmountABtest2);
         }
         if("@showInABtest" in param1)
         {
            _loc2_.setShowInABTest(param1.@showInABtest);
         }
         if("@unlockLevel" in param1)
         {
            _loc2_.unlockLevel = int(param1.@unlockLevel);
         }
         if("@unlockSku" in param1)
         {
            _loc2_.unlockSku = param1.@unlockSku;
         }
         if("@showProgress" in param1)
         {
            _loc3_ = int(param1.@showProgress);
            _loc2_.setShowProgress(_loc3_ == 1);
         }
         if("@imageIsRequired" in param1)
         {
            _loc3_ = int(param1.@imageIsRequired);
            _loc2_.setImageIsRequired(_loc3_ == 1);
         }
         if("@checkedInRoleVisitor" in param1)
         {
            _loc3_ = int(param1.@checkInRoleVisitor);
            _loc2_.setCheckInRoleVisitor(_loc3_ == 1);
         }
         if("@tid" in param1)
         {
            _loc2_.textID = param1.@tid;
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new MissionDefinition(mType);
      }
   }
}

