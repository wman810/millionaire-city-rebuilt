package com.dchoc.dollars.offers
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class OfferItemDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:OfferItemDefinitionManager;
      
      public function OfferItemDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: OfferItemDefinitionManager Error: Instantiation failed: Use OfferItemDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : OfferItemDefinitionManager
      {
         if(!smInstance)
         {
            smAllowInstantiation = true;
            smInstance = new OfferItemDefinitionManager();
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

