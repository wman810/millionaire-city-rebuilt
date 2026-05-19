package com.dchoc.dollars.world.items.decorations
{
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class ItemDecorationDefinition extends Definition
   {
      
      public static const TYPE_SKINS_ID:uint = 0;
      
      public static const TYPE_FLAGS_ID:uint = 1;
      
      public static const TYPE_COUNT:uint = 2;
      
      private var mShadowRows:int;
      
      private var mExp:uint;
      
      private var mDCCoins:uint;
      
      private var mDCCash:uint;
      
      public function ItemDecorationDefinition(param1:uint)
      {
         super(param1);
         this.mShadowRows = -1;
      }
      
      public function set shadowRows(param1:int) : void
      {
         this.mShadowRows = param1;
      }
      
      public function get DCCoins() : uint
      {
         return this.mDCCoins;
      }
      
      public function set DCCash(param1:uint) : void
      {
         this.mDCCash = param1;
      }
      
      public function set DCCoins(param1:uint) : void
      {
         this.mDCCoins = param1;
      }
      
      public function isForFree() : Boolean
      {
         return this.mDCCoins == 0 && this.mDCCash == 0;
      }
      
      public function get DCCash() : uint
      {
         return this.mDCCash;
      }
      
      override public function isDefault() : Boolean
      {
         return this.isForFree();
      }
      
      public function get shadowRows() : int
      {
         return this.mShadowRows;
      }
      
      public function set exp(param1:uint) : void
      {
         this.mExp = param1;
      }
      
      public function get exp() : uint
      {
         return this.mExp;
      }
   }
}

