package com.dchoc.dollars.offers
{
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   
   public class OfferManager
   {
      
      private static var smAllowed:Boolean;
      
      private static var smInstance:OfferManager;
      
      public static const TYPE_NONE:String = "none";
      
      public static const TYPE_DISCOUNT:String = "discount";
      
      public static const TYPE_BUNDLE:String = "bundle";
      
      private var mFreeItems:Array;
      
      public var mFlagNewFreeItems:Boolean;
      
      public function OfferManager()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: OfferManager Error: Instantiation failed: Use OfferManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : OfferManager
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new OfferManager();
            smAllowed = false;
            smInstance.mFlagNewFreeItems = false;
            smInstance.mFreeItems = new Array();
         }
         return smInstance;
      }
      
      public function addFreeItem(param1:String) : void
      {
         var _loc2_:ItemDefinition = null;
         this.mFreeItems.push(param1);
         if(!this.hasOffer(param1))
         {
            _loc2_ = ItemDefinitionManager.getInstance().getDefinitionBySku(param1) as ItemDefinition;
            ItemDefinitionManager.getInstance().addItemDefinitionFeatured(_loc2_);
         }
         this.mFlagNewFreeItems = true;
      }
      
      public function hasFreeItems() : Boolean
      {
         return this.mFreeItems.length > 0;
      }
      
      public function hasOffer(param1:String) : Boolean
      {
         return OfferItemDefinitionManager.getInstance().getDefinitionBySku(param1) != null;
      }
      
      public function getOffer(param1:String) : OfferDefinition
      {
         var _loc2_:String = (OfferItemDefinitionManager.getInstance().getDefinitionBySku(param1) as OfferItemDefinition).offerSku;
         return OfferDefinitionManager.getInstance().getDefinitionBySku(_loc2_) as OfferDefinition;
      }
      
      public function isFreeItem(param1:String) : Boolean
      {
         return this.mFreeItems.indexOf(param1) > -1;
      }
      
      public function removeFreeItem(param1:String) : void
      {
         var _loc3_:ItemDefinition = null;
         var _loc2_:int = this.mFreeItems.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.mFreeItems.splice(_loc2_,1);
            if(!this.hasOffer(param1))
            {
               _loc3_ = ItemDefinitionManager.getInstance().getDefinitionBySku(param1) as ItemDefinition;
               ItemDefinitionManager.getInstance().removeItemDefinitionFeatured(_loc3_);
            }
         }
         if(this.mFreeItems.length == 0)
         {
            this.mFlagNewFreeItems = false;
         }
      }
      
      public function build() : void
      {
      }
   }
}

