package com.dchoc.framework.world.view
{
   import com.dchoc.framework.world.WorldElement;
   import flash.display.Graphics;
   
   public class TopDownView extends View
   {
      
      public function TopDownView()
      {
         super();
      }
      
      override public function getScreenToWorldX(param1:Number, param2:Number, param3:Boolean = false) : int
      {
         var _loc4_:uint = 0;
         if(param3)
         {
            _loc4_ = param1 / mTileWidthScreen;
            if(param1 % mTileWidthScreen > mTileWidthScreen >> 1)
            {
               _loc4_++;
            }
            param1 = _loc4_ * mTileWidthScreen;
         }
         return param1;
      }
      
      override public function getScreenToWorldY(param1:Number, param2:Number, param3:Boolean = false) : int
      {
         var _loc4_:uint = 0;
         if(param3)
         {
            _loc4_ = param2 / mTileHeightScreen;
            if(param2 % mTileHeightScreen > mTileHeightScreen >> 1)
            {
               _loc4_++;
            }
            param2 = _loc4_ * mTileHeightScreen;
         }
         return param2;
      }
      
      override public function getWorldToScreenX(param1:Number, param2:Number, param3:Number) : int
      {
         return mTileWidthScreen * param1 / mTileSizeX;
      }
      
      override public function getWorldToScreenY(param1:Number, param2:Number, param3:Number) : int
      {
         return mTileHeightScreen * param2 / mTileSizeY;
      }
      
      override public function drawOnGC(param1:Graphics, param2:int, param3:WorldElement) : void
      {
         var _loc4_:Number = param3.mWorldX;
         var _loc5_:Number = param3.mWorldY;
         var _loc6_:Number = param3.mWorldZ;
         var _loc7_:Number = param3.mWorldSizeX;
         var _loc8_:Number = param3.mWorldSizeY;
         var _loc9_:Number = param3.mWorldSizeZ;
         var _loc10_:Number = this.getWorldToScreenX(_loc4_,_loc5_,_loc6_);
         var _loc11_:Number = this.getWorldToScreenY(_loc4_,_loc5_,_loc6_);
         var _loc12_:Number = this.getWorldToScreenX(_loc4_ + _loc7_,_loc5_,_loc6_) - _loc10_;
         var _loc13_:Number = this.getWorldToScreenY(_loc4_,_loc5_ + _loc8_,_loc6_) - _loc11_;
         param1.beginFill(param2);
         param1.drawRect(_loc10_,_loc11_,_loc12_,_loc13_);
         param1.endFill();
      }
   }
}

