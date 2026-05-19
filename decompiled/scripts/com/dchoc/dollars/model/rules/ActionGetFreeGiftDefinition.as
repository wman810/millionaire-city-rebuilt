package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.freeGift.FreeGiftDefinition;
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   
   public class ActionGetFreeGiftDefinition extends ActionGetDefinitions
   {
      
      public function ActionGetFreeGiftDefinition(param1:String, param2:int = -1, param3:int = 0)
      {
         super(FreeGiftDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:FreeGiftDefinition = super.itemFromXML(param1) as FreeGiftDefinition;
         _loc2_.sku = param1.@sku;
         _loc2_.type = 0;
         _loc2_.giftType = param1.@giftType;
         _loc2_.value = param1.@value;
         _loc2_.textID = param1.@tid;
         _loc2_.order = param1.@order;
         if("@action" in param1)
         {
            _loc2_.giftAction = param1.@action;
         }
         if("@unlockCondition" in param1)
         {
            _loc2_.unlockCondition = param1.@unlockCondition;
         }
         if("@unlockValue" in param1)
         {
            _loc2_.unlockValue = int(param1.@unlockValue);
         }
         if("@maxAmount" in param1)
         {
            _loc2_.maxAmount = int(param1.@maxAmount);
         }
         PriorityLoader.getInstance().queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.DIR_FREEGIFTS + _loc2_.giftType + ".png",_loc2_.giftType,".png");
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new FreeGiftDefinition(mType);
      }
   }
}

