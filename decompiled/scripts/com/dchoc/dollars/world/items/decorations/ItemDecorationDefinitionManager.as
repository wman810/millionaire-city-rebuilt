package com.dchoc.dollars.world.items.decorations
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   import flash.utils.Dictionary;
   
   public class ItemDecorationDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ItemDecorationDefinitionManager;
      
      private var mItemDecorations:Array;
      
      private var mItemDecorationsTranslatorDictionary:Dictionary;
      
      private var mItemDecorationsDictionary:Dictionary;
      
      public function ItemDecorationDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ItemDefinitionManager Error: Instantiation failed: Use ItemDefinitionManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : ItemDecorationDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ItemDecorationDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override public function load(param1:String = "") : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         super.load(Config.getRoot() + ModelConfig.DIR_ITEMS_DECORATIONS);
         this.mItemDecorationsDictionary = new Dictionary();
         this.mItemDecorations = new Array();
         this.mItemDecorationsTranslatorDictionary = new Dictionary();
         _loc2_ = "skin";
         _loc3_ = 0;
         this.mItemDecorationsTranslatorDictionary[_loc2_] = _loc3_;
         var _loc4_:ItemDecoration = new SkinDecoration(_loc3_);
         this.mItemDecorationsDictionary[_loc2_] = _loc4_;
         this.mItemDecorations.push(_loc4_);
         _loc2_ = "flag";
         _loc3_ = 1;
         this.mItemDecorationsTranslatorDictionary[_loc2_] = _loc3_;
         _loc4_ = new FlagDecoration(_loc3_);
         this.mItemDecorationsDictionary[_loc2_] = _loc4_;
         this.mItemDecorations.push(_loc4_);
      }
      
      public function getItemDecorationByType(param1:String) : ItemDecoration
      {
         var _loc3_:ItemDecoration = null;
         var _loc2_:int = int(this.mItemDecorationsTranslatorDictionary[param1]);
         if(this.mItemDecorationsDictionary[param1] == null)
         {
            return new ItemDecoration(_loc2_);
         }
         _loc3_ = this.mItemDecorationsDictionary[param1] as ItemDecoration;
         return _loc3_.clone();
      }
      
      public function getTypeAsInt(param1:String) : int
      {
         return this.mItemDecorations.indexOf(param1);
      }
      
      override public function destroy() : void
      {
         var _loc1_:ItemDecoration = null;
         super.destroy();
         for each(_loc1_ in this.mItemDecorations)
         {
            _loc1_.destroy();
         }
         this.mItemDecorationsDictionary = null;
         this.mItemDecorations = null;
         this.mItemDecorationsTranslatorDictionary = null;
      }
      
      override protected function sortIsNeeded() : Boolean
      {
         return false;
      }
      
      override public function getTypeCount() : int
      {
         return ItemDecorationDefinition.TYPE_COUNT;
      }
   }
}

