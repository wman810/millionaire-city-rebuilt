package com.dchoc.dollars.world.items
{
   import com.dchoc.dollars.GUI.shop.ShopTabDefinition;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   
   public class ItemDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ItemDefinitionManager;
      
      private var mItemDefinitionFan:ItemDefinition;
      
      private var mLimEdItems:Array;
      
      private var mItemDefinitionsFeatured:Array;
      
      private var mFeaturedIndex:int = -1;
      
      private var mLimEdExpireTimes:Array;
      
      private var mNeedsToBeUpdated:Boolean = false;
      
      public function ItemDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ItemDefinitionManager Error: Instantiation failed: Use ItemDefinitionManager.getInstance() instead of new.");
         }
         this.mItemDefinitionsFeatured = new Array();
         mLoader = PriorityLoader.getInstance();
         this.load();
      }
      
      public static function getInstance() : ItemDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ItemDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(this.mItemDefinitionsFeatured != null)
         {
            this.mItemDefinitionsFeatured.splice(0,this.mItemDefinitionsFeatured.length);
            this.mItemDefinitionsFeatured = null;
         }
      }
      
      public function getItemDefinitionsFeatured() : Array
      {
         return this.mItemDefinitionsFeatured;
      }
      
      public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:ShopTabDefinition = null;
         var _loc3_:ItemDefinition = null;
         if(this.mNeedsToBeUpdated)
         {
            if(this.mFeaturedIndex == -1)
            {
               _loc2_ = ShopTabDefinitionManager.getInstance().getDefinitionBySku("featured") as ShopTabDefinition;
               this.mFeaturedIndex = _loc2_.index;
            }
            _loc1_ = 0;
            while(_loc1_ < this.mItemDefinitionsFeatured.length)
            {
               _loc3_ = this.mItemDefinitionsFeatured[_loc1_];
               if(!_loc3_.isAllowedToBeInShop())
               {
                  this.mItemDefinitionsFeatured.splice(_loc1_,1);
               }
               else
               {
                  _loc1_++;
               }
            }
            this.mNeedsToBeUpdated = true;
         }
      }
      
      override public function getDefinitions(param1:uint = 0, param2:Array = null) : Array
      {
         if(param1 == this.mFeaturedIndex)
         {
            return this.getItemDefinitionsFeatured();
         }
         return super.getDefinitions(param1,param2);
      }
      
      override protected function getTypeEnd() : int
      {
         return ItemDefinition.TYPE_COUNT - 1;
      }
      
      public function disableOffers() : void
      {
         var _loc1_:ItemDefinition = null;
         for each(_loc1_ in getDefinitionsWithCondition(this.hasOffer,0))
         {
            _loc1_.offerDef = null;
         }
      }
      
      override protected function sortCompareSameLevelFunction(param1:Definition, param2:Definition) : Number
      {
         var _loc3_:ItemDefinition = param1 as ItemDefinition;
         var _loc4_:ItemDefinition = param2 as ItemDefinition;
         var _loc5_:Number = 0;
         if(_loc3_.getConstructionFBCredits() > _loc4_.getConstructionFBCredits() && _loc4_.getConstructionFBCredits() > 0)
         {
            _loc5_ = 1;
         }
         else if(_loc3_.getConstructionFBCredits() < _loc4_.getConstructionFBCredits() && _loc3_.getConstructionFBCredits() > 0)
         {
            _loc5_ = -1;
         }
         else if(_loc3_.getConstructionCoins() > _loc4_.getConstructionCoins() && _loc4_.getConstructionCoins() > 0)
         {
            _loc5_ = 1;
         }
         else if(_loc3_.getConstructionCoins() < _loc4_.getConstructionCoins() && _loc3_.getConstructionCoins() > 0)
         {
            _loc5_ = -1;
         }
         else
         {
            _loc5_ = this.sortCompareSameCostFunction(param1,param2);
         }
         return _loc5_;
      }
      
      public function limEdRegisterItemDefinition(param1:ItemDefinition) : void
      {
         if(this.mLimEdExpireTimes == null)
         {
            this.mLimEdExpireTimes = new Array();
         }
         if(this.mLimEdItems == null)
         {
            this.mLimEdItems = new Array();
         }
         var _loc2_:int = this.mLimEdExpireTimes.indexOf(param1.getExpireTime());
         if(_loc2_ == -1)
         {
            this.mLimEdExpireTimes.push(param1.getExpireTime());
            _loc2_ = this.mLimEdExpireTimes.length - 1;
         }
         if(this.mLimEdItems.length < _loc2_ + 1)
         {
            this.mLimEdItems.push(new Array());
         }
         this.mLimEdItems[_loc2_].push(param1);
      }
      
      private function sortCompareSameCostFunction(param1:Definition, param2:Definition) : Number
      {
         var _loc3_:ItemDefinition = param1 as ItemDefinition;
         var _loc4_:ItemDefinition = param2 as ItemDefinition;
         var _loc5_:Number = 0;
         if(_loc3_.getExperience() > _loc4_.getExperience())
         {
            _loc5_ = 1;
         }
         else
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      public function addItemDefinitionFeatured(param1:ItemDefinition) : void
      {
         if(this.mItemDefinitionsFeatured == null)
         {
            this.mItemDefinitionsFeatured = new Array();
         }
         var _loc2_:int = this.mItemDefinitionsFeatured.indexOf(param1);
         if(_loc2_ < 0)
         {
            this.mItemDefinitionsFeatured.push(param1);
         }
      }
      
      public function requestLoadResourcesBySku(param1:String, param2:int) : void
      {
         this.requestLoadResourcesByDefinition(getDefinitionBySku(param1),param2);
      }
      
      override protected function checkLevel(param1:Definition, param2:int) : Boolean
      {
         var _loc3_:ItemDefinition = param1 as ItemDefinition;
         return _loc3_.getUnlockConditionID() == ItemDefinition.UNLOCK_CONDITION_LEVEL_ID && param1.level == param2;
      }
      
      public function requestLoadResourcesWithConditions(param1:Boolean = true, param2:int = 0, param3:int = 0, param4:int = -1, param5:int = 1) : void
      {
         var _loc7_:ItemDefinition = null;
         var _loc6_:uint = 0;
         while(_loc6_ < mDefinitions.length)
         {
            if(param4 == -1 || _loc6_ == param4)
            {
               for each(_loc7_ in mDefinitions[_loc6_])
               {
                  if(!_loc7_.mResourcesRequested && (param1 && _loc7_.isAllowedToBeInShop()) && (param2 == 0 || _loc7_.level >= param2) && (param3 == 0 || _loc7_.level <= param3))
                  {
                     this.requestLoadResourcesByDefinition(_loc7_,param5);
                  }
               }
            }
            _loc6_++;
         }
      }
      
      override public function sort() : void
      {
         super.sort();
         if(this.mItemDefinitionsFeatured != null)
         {
            this.mItemDefinitionsFeatured.sort(this.sortCompareFeaturedFunction);
         }
      }
      
      public function isFBCreditsItem(param1:ItemDefinition, param2:int) : Boolean
      {
         return param1.getConstructionFBCredits() > param2;
      }
      
      public function hasOffer(param1:ItemDefinition, param2:int) : Boolean
      {
         return param1.offerDef != null && param1.offerDef.amount > param2;
      }
      
      override public function getDefinitionsCount(param1:uint = 0) : int
      {
         if(param1 == this.mFeaturedIndex)
         {
            return this.mItemDefinitionsFeatured.length;
         }
         return super.getDefinitionsCount(param1);
      }
      
      override public function load(param1:String = "") : void
      {
         super.load(Config.getRoot() + ModelConfig.DIR_ITEMS);
      }
      
      public function setItemDefinitionFan(param1:ItemDefinition) : void
      {
         this.mItemDefinitionFan = param1;
      }
      
      private function sortCompareFeaturedFunction(param1:Definition, param2:Definition) : Number
      {
         var _loc3_:ItemDefinition = param1 as ItemDefinition;
         var _loc4_:ItemDefinition = param2 as ItemDefinition;
         var _loc5_:Boolean = _loc3_.offerDef != null;
         var _loc6_:Boolean = _loc4_.offerDef != null;
         var _loc7_:Number = 0;
         if(_loc5_ && !_loc6_)
         {
            _loc7_ = -1;
         }
         else if(!_loc5_ && _loc6_)
         {
            _loc7_ = 1;
         }
         else
         {
            _loc5_ = _loc3_ is BundleDefinition;
            _loc6_ = _loc4_ is BundleDefinition;
            if(_loc5_ && !_loc6_)
            {
               _loc7_ = -1;
            }
            else if(!_loc5_ && _loc6_)
            {
               _loc7_ = 1;
            }
            else
            {
               _loc7_ = super.sortCompareFunction(param1,param2);
            }
         }
         return _loc7_;
      }
      
      override public function build() : void
      {
         super.build();
         this.mNeedsToBeUpdated = true;
      }
      
      public function getItemDefinitionFan() : ItemDefinition
      {
         return this.mItemDefinitionFan;
      }
      
      public function removeItemDefinitionFeatured(param1:ItemDefinition) : void
      {
         var _loc2_:int = 0;
         if(this.mItemDefinitionsFeatured != null)
         {
            _loc2_ = this.mItemDefinitionsFeatured.indexOf(param1);
            if(_loc2_ > -1)
            {
               this.mItemDefinitionsFeatured.splice(_loc2_,1);
            }
         }
      }
      
      override public function requestLoadResourcesByDefinition(param1:Definition, param2:int) : void
      {
         super.requestLoadResourcesByDefinition(param1,param2);
         var _loc3_:ItemDefinition = param1 as ItemDefinition;
         if(_loc3_.type == ItemDefinition.TYPE_COMMERCES_ID)
         {
            if(!Config.USE_OLD_ICON_SYSTEM || Config.USE_BITMAP_DATA_ANIMATIONS)
            {
               PriorityLoader.getInstance().queueLoad(PriorityLoader.QUEUE_LOADING,Config.getRoot() + ModelConfig.COMMERCE_ICONS_FOLDER + _loc3_.getCommerceIcon(),_loc3_.getCommerceIcon(),".png");
            }
         }
         if(_loc3_.constructionCrewSku != "")
         {
            PriorityLoader.getInstance().queueLoad(PriorityLoader.QUEUE_ASYNC,Config.getRoot() + ModelConfig.DIR_CREW_MECHANICS_ICONS + _loc3_.getSkuToLoad() + "_icon.png",_loc3_.getSkuToLoad() + "_icon",".png");
         }
      }
      
      private function limEdCheckExpireTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ItemDefinition = null;
         if(this.mLimEdExpireTimes != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.mLimEdExpireTimes.length)
            {
               if(param1 > this.mLimEdExpireTimes[_loc2_])
               {
                  this.mLimEdExpireTimes.splice(_loc2_,1);
                  for each(_loc3_ in this.mLimEdItems[_loc2_])
                  {
                     this.removeDefinition(_loc3_.type,_loc3_.sku);
                  }
                  this.mLimEdItems.splice(_loc2_,1);
               }
               else
               {
                  _loc2_++;
               }
            }
         }
      }
      
      override public function removeDefinition(param1:int, param2:String) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:ItemDefinition = getDefinitionBySku(param2) as ItemDefinition;
         var _loc4_:int = this.mItemDefinitionsFeatured.indexOf(_loc3_);
         if(_loc4_ > -1)
         {
            this.mItemDefinitionsFeatured.splice(_loc4_,1);
         }
         super.removeDefinition(param1,param2);
         if(param1 < ItemDefinition.TYPE_COUNT)
         {
            _loc5_ = ShopTabDefinitionManager.getInstance().getDefinitionsCount() - ItemDefinition.TYPE_COUNT;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               this.removeDefinition(ItemDefinition.TYPE_COUNT + _loc6_,param2);
               _loc6_++;
            }
         }
      }
      
      override public function getTypeCount() : int
      {
         return ItemDefinition.TYPE_COUNT + ShopTabDefinitionManager.getInstance().getDefinitionsCount();
      }
   }
}

