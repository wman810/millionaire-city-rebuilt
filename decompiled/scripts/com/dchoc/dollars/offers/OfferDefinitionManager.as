package com.dchoc.dollars.offers
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class OfferDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:OfferDefinitionManager;
      
      public function OfferDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: OfferDefinitionManager Error: Instantiation failed: Use OfferDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : OfferDefinitionManager
      {
         if(!smInstance)
         {
            smAllowInstantiation = true;
            smInstance = new OfferDefinitionManager();
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

