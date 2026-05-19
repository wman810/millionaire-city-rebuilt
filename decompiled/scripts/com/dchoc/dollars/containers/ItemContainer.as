package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.Popup;
   import flash.display.Sprite;
   
   public class ItemContainer extends Popup
   {
      
      private var mScrollRect:Sprite;
      
      public function ItemContainer(param1:Sprite)
      {
         super();
         this.mScrollRect = param1;
      }
      
      public function getX() : int
      {
         return this.mScrollRect.x;
      }
      
      public function getScrolledX() : int
      {
         return this.mScrollRect.scrollRect.x;
      }
   }
}

