package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.collectibles.CollectibleDefinition;
   import com.dchoc.dollars.collectibles.CollectibleDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetCollectibleDefinition extends ActionGetDefinitions
   {
      
      public function ActionGetCollectibleDefinition(param1:String, param2:int = -1, param3:int = 0)
      {
         super(CollectibleDefinitionManager.getInstance(),param1,param2,param3);
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:CollectibleDefinition = super.itemFromXML(param1) as CollectibleDefinition;
         _loc2_.collectionSku = param1.@collection;
         _loc2_.priceCoins = Number(param1.@priceCoins);
         _loc2_.priceCash = int(param1.@priceCash);
         _loc2_.contractsGroupList = param1.@contracsGroupList;
         _loc2_.orderInCollection = param1.@orderInCollection;
         _loc2_.prioritySku = param1.@prioritySku;
         _loc2_.setPriceFBCredits(int(param1.@priceFBC));
         if("@tid" in param1)
         {
            _loc2_.textID = param1.@tid;
         }
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new CollectibleDefinition(mType);
      }
   }
}

