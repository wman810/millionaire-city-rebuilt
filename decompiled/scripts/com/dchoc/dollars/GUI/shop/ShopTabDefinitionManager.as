package com.dchoc.dollars.GUI.shop
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class ShopTabDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ShopTabDefinitionManager;
      
      public function ShopTabDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ShopTabDefinitionManager Error: Instantiation failed: Use ShopTabDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : ShopTabDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ShopTabDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function getShopTabAsIndex(param1:String) : int
      {
         var _loc2_:int = -1;
         var _loc3_:ShopTabDefinition = getDefinitionBySku(param1) as ShopTabDefinition;
         if(_loc3_ != null)
         {
            _loc2_ = _loc3_.index;
         }
         return _loc2_;
      }
   }
}

