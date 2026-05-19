package com.dchoc.dollars.world.items.decorations
{
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
   public class ItemDecoration
   {
      
      public static const TYPE_SKIN_ID:int = 0;
      
      public static const TYPE_FLAG_ID:int = 1;
      
      protected var mSkus:Array;
      
      protected var mType:int;
      
      protected var mItemObject:ItemObject;
      
      protected var mShadowRows:int;
      
      protected var mCount:int;
      
      protected var mCurrentSku:String;
      
      protected var mParent:DisplayObjectContainer;
      
      protected var mDO:MovieClip;
      
      public function ItemDecoration(param1:int)
      {
         super();
         this.mType = param1;
         this.mSkus = new Array();
         this.mCurrentSku = "";
      }
      
      public function destroy() : void
      {
         this.mSkus = null;
         if(this.mDO != null)
         {
            this.unDraw();
         }
      }
      
      public function set currentSku(param1:String) : void
      {
         var _loc4_:ItemDecorationDefinition = null;
         var _loc2_:String = this.mCurrentSku;
         var _loc3_:ItemDecorationDefinition = this.getItemDecorationDefinition(param1);
         if(this.mType == TYPE_SKIN_ID && _loc3_ == null)
         {
            _loc4_ = ItemDecorationDefinitionManager.getInstance().getDefinitionById(0) as ItemDecorationDefinition;
            param1 = _loc4_.sku;
         }
         this.mCurrentSku = param1;
         if(param1 != _loc2_)
         {
            this.changeShadowRows(param1,_loc2_);
            this.setDO();
         }
      }
      
      public function draw(param1:DisplayObjectContainer) : void
      {
         this.mParent = param1;
         this.setDO();
      }
      
      public function getShadowRows(param1:String = "") : int
      {
         if(param1 == "")
         {
            param1 = this.mCurrentSku;
         }
         var _loc2_:int = this.getItemDecorationDefinition(param1).shadowRows;
         if(_loc2_ == -1)
         {
            _loc2_ = this.mItemObject.itemDefinition.shadowRows;
         }
         return _loc2_;
      }
      
      protected function checkChangeShadowRows() : Boolean
      {
         return false;
      }
      
      public function getItemDecorationDefinition(param1:String = "") : ItemDecorationDefinition
      {
         if(param1 == "")
         {
            param1 = this.mCurrentSku;
         }
         return ItemDecorationDefinitionManager.getInstance().getDefinitionBySku(param1) as ItemDecorationDefinition;
      }
      
      public function get count() : int
      {
         return this.mCount;
      }
      
      public function shadowRows() : int
      {
         return this.getItemDecorationDefinition().shadowRows;
      }
      
      public function setSku(param1:String) : void
      {
         this.currentSku = param1;
      }
      
      public function clone() : ItemDecoration
      {
         var _loc1_:ItemDecoration = new ItemDecoration(this.mType);
         _loc1_.cloneValues(this);
         return _loc1_;
      }
      
      public function cloneValues(param1:ItemDecoration, param2:Boolean = true, param3:Boolean = false) : void
      {
         var _loc4_:String = null;
         if(param2)
         {
            this.mType = param1.mType;
            this.mItemObject = param1.itemObject;
         }
         if(this.mSkus.length > 0)
         {
            this.mSkus.splice(0,this.mSkus.length);
         }
         for each(_loc4_ in param1.mSkus)
         {
            this.mSkus.push(_loc4_);
         }
         if(param3)
         {
            this.currentSku = param1.currentSku;
         }
         else
         {
            this.mCurrentSku = param1.currentSku;
         }
      }
      
      protected function setDefaultPersistence() : void
      {
         var _loc1_:Array = ItemDecorationDefinitionManager.getInstance().getDefinitions(this.mType);
         var _loc2_:ItemDecorationDefinition = _loc1_[0] as ItemDecorationDefinition;
         this.mCurrentSku = _loc2_.sku;
      }
      
      public function get currentSku() : String
      {
         return this.mCurrentSku;
      }
      
      public function set itemObject(param1:ItemObject) : void
      {
         this.mItemObject = param1;
      }
      
      public function setPersistence(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         if(param1 == null)
         {
            this.setDefaultPersistence();
         }
         else
         {
            this.mType = param1.@type;
            for each(_loc2_ in param1.sku)
            {
               _loc3_ = _loc2_.@id;
               this.mSkus.push(_loc3_);
               ++this.mCount;
            }
            this.currentSku = param1.@currentSku;
         }
      }
      
      protected function setDO(param1:Boolean = true) : void
      {
         var _loc2_:Class = null;
         if(this.mParent != null)
         {
            if(this.mDO != null)
            {
               this.unDraw();
            }
            _loc2_ = DCResourceManager.getInstance().getSWFClass(this.mCurrentSku,"Asset_new");
            if(_loc2_ == null)
            {
               _loc2_ = DCResourceManager.getInstance().getSWFClass(this.mCurrentSku,"Asset");
            }
            this.mDO = new _loc2_() as MovieClip;
            if(this.mItemObject != null)
            {
               this.mDO.y = this.mItemObject.itemDefinition.baseHeight;
            }
            if(param1)
            {
               this.mParent.addChild(this.mDO);
            }
         }
      }
      
      public function getPersistence() : XML
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc1_:XML = <Decoration type={this.mType} currentSku={this.mCurrentSku} shadowRows={this.mShadowRows}/>;
         for each(_loc3_ in this.mSkus)
         {
            _loc2_ = <sku id={_loc3_}/>;
            _loc1_.appendChild(_loc2_);
         }
         return _loc1_;
      }
      
      public function get itemObject() : ItemObject
      {
         return this.mItemObject;
      }
      
      public function set type(param1:int) : void
      {
         this.mType = param1;
      }
      
      public function get skus() : Array
      {
         return this.mSkus;
      }
      
      protected function changeShadowRows(param1:String, param2:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Company = null;
         if(this.checkChangeShadowRows())
         {
            _loc3_ = this.getShadowRows(param2);
            _loc4_ = this.getShadowRows(param1);
            if(_loc3_ != _loc4_)
            {
               _loc5_ = this.mItemObject.company;
               if(_loc5_ != null)
               {
                  _loc5_.world.map.unregisterItemShadow(this.mItemObject,_loc3_);
                  _loc5_.world.map.registerItemShadow(this.mItemObject,_loc4_);
               }
            }
         }
      }
      
      public function get type() : int
      {
         return this.mType;
      }
      
      public function addSku(param1:String) : void
      {
         var _loc2_:int = this.mSkus.indexOf(param1);
         if(_loc2_ == -1)
         {
            this.mSkus.push(param1);
         }
      }
      
      protected function unDraw() : void
      {
         if(this.mParent != null && this.mParent.contains(this.mDO))
         {
            this.mParent.removeChild(this.mDO);
         }
         this.mDO = null;
      }
   }
}

