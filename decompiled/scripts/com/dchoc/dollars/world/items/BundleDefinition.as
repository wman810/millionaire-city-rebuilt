package com.dchoc.dollars.world.items
{
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.metrics.CRMCustomizerDefinition;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class BundleDefinition extends ItemDefinition
   {
      
      public static var LIST_ITEM_SKU:uint = 0;
      
      public static var LIST_ITEM_QUANTITY:uint = 1;
      
      private var mCRMDefinition:CRMCustomizerDefinition;
      
      private var mImage:DisplayObject;
      
      private var mItemList:Array;
      
      private var mSetImageTimer:Number;
      
      public function BundleDefinition(param1:String, param2:String, param3:int, param4:int = 0)
      {
         super(TYPE_BUNDLE_ID);
         this.mItemList = new Array();
         this.setItemList(param2);
         sku = param1;
         constructionFBC = param3;
         if(param4 > 0)
         {
            constructionCash = param4;
         }
         else
         {
            constructionCash = param3 / 2;
         }
         setIsFeatured(true);
         ItemDefinitionManager.getInstance().addItemDefinitionFeatured(this);
         var _loc5_:ItemDefinition = this.getItemDefinition(0);
         ItemDefinitionManager.getInstance().requestLoadResourcesByDefinition(_loc5_,PriorityLoader.QUEUE_LOADING);
         setUnlockCondition(getUnlockText());
         level = _loc5_.level;
         textID = _loc5_.textID;
         var _loc6_:Number = param3 / _loc5_.getConstructionFBCredits();
         experience = _loc6_ * _loc5_.getExperience();
         ItemDefinitionManager.getInstance().addDefinitionType(this,_loc5_.type);
         ItemDefinitionManager.getInstance().addDefinition(this);
         ItemDefinitionManager.getInstance().sort();
      }
      
      public function getItemAmount(param1:int) : int
      {
         return this.mItemList[param1][1];
      }
      
      public function getItemList() : Array
      {
         return this.mItemList;
      }
      
      public function getOriginalPrice() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.mItemList.length)
         {
            if(Config.FACEBOOK_CREDITS_AS_CURRENCY)
            {
               _loc1_ += this.getItemDefinition(_loc2_).getConstructionFBCredits() * this.getItemAmount(0);
            }
            else
            {
               _loc1_ += this.getItemDefinition(_loc2_).getConstructionCash() * this.getItemAmount(0);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getItemDefinition(param1:int) : ItemDefinition
      {
         return ItemDefinitionManager.getInstance().getDefinitionBySku(this.mItemList[param1][0]) as ItemDefinition;
      }
      
      public function setCRMDefinition(param1:CRMCustomizerDefinition) : void
      {
         this.mCRMDefinition = param1;
         this.setImage();
      }
      
      private function setItemList(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         this.mItemList.length = 0;
         var _loc2_:Array = param1.split(";");
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.split(":");
            _loc4_[BundleDefinition.LIST_ITEM_QUANTITY] = parseInt(_loc4_[BundleDefinition.LIST_ITEM_QUANTITY]);
            this.mItemList.push(_loc4_);
         }
      }
      
      override public function getIcon(param1:Sprite, param2:Boolean = false, param3:Boolean = false) : Object
      {
         return this.getItemDefinition(0).getIcon(param1,param2,param3);
      }
      
      override public function getSkuToLoad() : String
      {
         return this.getItemDefinition(0).sku;
      }
      
      public function setImage() : void
      {
         this.mImage = this.mCRMDefinition.image;
      }
      
      public function destroy() : void
      {
         this.mCRMDefinition = null;
         this.mItemList.length = 0;
         this.mImage = null;
      }
      
      public function getCRMDefinition() : CRMCustomizerDefinition
      {
         return this.mCRMDefinition;
      }
   }
}

