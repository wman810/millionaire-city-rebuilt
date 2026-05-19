package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.offers.OfferDefinition;
   import com.dchoc.dollars.offers.OfferDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetOfferDefinition extends ActionGetDefinitions
   {
      
      public function ActionGetOfferDefinition(param1:String, param2:int = -1, param3:int = 0)
      {
         super(OfferDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:OfferDefinition = super.itemFromXML(param1) as OfferDefinition;
         _loc2_.sku = param1.@sku;
         _loc2_.offerType = param1.@offerType;
         if("@amount" in param1)
         {
            _loc2_.amount = Number(param1.@amount);
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new OfferDefinition(mType);
      }
   }
}

