package com.dchoc.framework.world
{
   import flash.display.MovieClip;
   
   public class WorldDisplayContainerSorted extends MovieClip
   {
      
      public function WorldDisplayContainerSorted()
      {
         super();
      }
      
      public function sortChildren() : void
      {
         var _loc2_:WorldElement = null;
         var _loc3_:WorldElement = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.numChildren - 1)
         {
            _loc2_ = this.getChildAt(_loc1_) as WorldElement;
            _loc3_ = this.getChildAt(_loc1_ + 1) as WorldElement;
            if(_loc3_.mWorldX + _loc3_.mWorldSizeX < _loc2_.mWorldX || _loc3_.mWorldY + _loc3_.mWorldSizeY < _loc2_.mWorldY)
            {
               this.swapChildren(_loc3_,_loc2_);
            }
            _loc1_++;
         }
      }
   }
}

