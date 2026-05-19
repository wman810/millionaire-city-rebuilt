package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   
   public class CollectibleDefinition extends Definition
   {
      
      private var mCollectionSku:String;
      
      private var mPriceCoins:Number;
      
      private var mTextID:String;
      
      private var mPriceFBCredits:int;
      
      private var mContractsGroupList:String;
      
      private var mOrderInCollection:int;
      
      private var mPrioritySku:String;
      
      private var mPriceCash:int;
      
      public function CollectibleDefinition(param1:int)
      {
         super(param1);
      }
      
      public function set prioritySku(param1:String) : void
      {
         this.mPrioritySku = param1;
      }
      
      public function getPriceFBCredits() : int
      {
         return this.mPriceFBCredits;
      }
      
      public function get textID() : String
      {
         return this.mTextID;
      }
      
      public function set textID(param1:String) : void
      {
         this.mTextID = param1;
      }
      
      public function get orderInCollection() : int
      {
         return this.mOrderInCollection;
      }
      
      public function setPriceFBCredits(param1:int) : void
      {
         this.mPriceFBCredits = param1;
      }
      
      public function get prioritySku() : String
      {
         return this.mPrioritySku;
      }
      
      public function get priceCash() : int
      {
         return this.mPriceCash;
      }
      
      public function get collectionSku() : String
      {
         return this.mCollectionSku;
      }
      
      public function get contractsGroupList() : String
      {
         return this.mContractsGroupList;
      }
      
      public function set orderInCollection(param1:int) : void
      {
         this.mOrderInCollection = param1;
      }
      
      public function set priceCoins(param1:Number) : void
      {
         this.mPriceCoins = param1;
      }
      
      public function set priceCash(param1:int) : void
      {
         this.mPriceCash = param1;
      }
      
      public function get priceCoins() : Number
      {
         return this.mPriceCoins;
      }
      
      public function getIconDO() : DisplayObject
      {
         return new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,mSku))();
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return true;
      }
      
      public function set collectionSku(param1:String) : void
      {
         this.mCollectionSku = param1;
      }
      
      public function set contractsGroupList(param1:String) : void
      {
         this.mContractsGroupList = param1;
      }
   }
}

