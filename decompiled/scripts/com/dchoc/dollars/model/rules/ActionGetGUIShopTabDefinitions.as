package com.dchoc.dollars.model.rules
{
   import com.dchoc.dollars.GUI.shop.ShopTabDefinition;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinitionManager;
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ActionGetGUIShopTabDefinitions extends ActionGetDefinitions
   {
      
      private var mIndex:int;
      
      public function ActionGetGUIShopTabDefinitions(param1:String, param2:int)
      {
         super(ShopTabDefinitionManager.getInstance(),param1,param2);
         this.mIndex = 0;
      }
      
      override protected function itemFromXML(param1:XML) : Definition
      {
         var _loc2_:ShopTabDefinition = super.itemFromXML(param1) as ShopTabDefinition;
         var _loc3_:int = 0;
         if("@usesIconOnItemShop" in param1)
         {
            _loc3_ = parseInt(param1.@usesIconOnItemShop);
         }
         _loc2_.tid = TextIDs[param1.@tid];
         _loc2_.setUsesIconOnItemShop(_loc3_ == 1);
         _loc2_.index = this.mIndex;
         ++this.mIndex;
         return _loc2_;
      }
      
      override protected function instanciateDefinition() : Definition
      {
         return new ShopTabDefinition(mType);
      }
   }
}

