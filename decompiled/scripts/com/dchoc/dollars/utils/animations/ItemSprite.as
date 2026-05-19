package com.dchoc.dollars.utils.animations
{
   import flash.display.Sprite;
   
   public class ItemSprite extends Sprite
   {
      
      private static const SORT_ITEMS_IN_MEMORY:Boolean = true;
      
      private var mDisplayAreaWidth:int;
      
      private var mDisplayAreaHeight:int;
      
      private var mNeedsSorting:Boolean = false;
      
      private var mDepth:Number;
      
      private var mDisplayAreaY:int;
      
      private var mSortIsEnabled:Boolean = true;
      
      private var mDisplayAreaX:int;
      
      public function ItemSprite()
      {
         super();
      }
      
      public function destroy() : void
      {
      }
      
      public function sortSetIsEnabled(param1:Boolean) : void
      {
         this.mSortIsEnabled = param1;
      }
      
      public function get depth() : Number
      {
         return this.mDepth;
      }
      
      public function set depth(param1:Number) : void
      {
         this.mDepth = param1;
         if(parent is ItemSprite)
         {
            ItemSprite(parent).mNeedsSorting = true;
         }
      }
      
      public function setDisplayArea(param1:int, param2:int, param3:int, param4:int) : void
      {
         this.mDisplayAreaX = param1;
         this.mDisplayAreaY = param2;
         this.mDisplayAreaWidth = param3;
         this.mDisplayAreaHeight = param4;
         this.recalculatePosition();
      }
      
      public function getWidth() : int
      {
         return int(width);
      }
      
      public function sortDisplayList(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:* = 0;
         var _loc4_:Array = null;
         if(this.mSortIsEnabled)
         {
            if(SORT_ITEMS_IN_MEMORY)
            {
               _loc4_ = new Array();
               _loc3_ = numChildren;
               while(_loc3_--)
               {
                  _loc4_[_loc3_] = getChildAt(_loc3_);
               }
               _loc4_.sortOn("depth",Array.NUMERIC);
               _loc3_ = numChildren;
               while(_loc3_--)
               {
                  if(_loc4_[_loc3_] != getChildAt(_loc3_))
                  {
                     setChildIndex(_loc4_[_loc3_],_loc3_);
                  }
               }
            }
         }
      }
      
      public function getHeight() : int
      {
         return int(height);
      }
      
      public function recalculatePosition() : void
      {
         if(this.mDisplayAreaWidth > 0)
         {
            x = this.mDisplayAreaX + (this.mDisplayAreaWidth - this.getWidth() >> 1);
            y = this.mDisplayAreaY + (this.mDisplayAreaHeight - this.getHeight() >> 1);
         }
      }
   }
}

