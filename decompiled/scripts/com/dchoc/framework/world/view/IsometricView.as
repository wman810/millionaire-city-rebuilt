package com.dchoc.framework.world.view
{
   import com.dchoc.framework.world.WorldElement;
   import flash.display.Graphics;
   
   public class IsometricView extends View
   {
      
      public function IsometricView()
      {
         super();
      }
      
      override public function getScreenToWorldX(param1:Number, param2:Number, param3:Boolean = false) : int
      {
         return param1 * mTileSizeX / mTileWidthScreen + param2 * mTileSizeY / mTileHeightScreen;
      }
      
      override public function getScreenToWorldY(param1:Number, param2:Number, param3:Boolean = false) : int
      {
         return param2 * mTileSizeY / mTileHeightScreen - param1 * mTileSizeX / mTileWidthScreen;
      }
      
      override public function getWorldToScreenX(param1:Number, param2:Number, param3:Number) : int
      {
         return mTileWidthScreen * (param1 - param2) * 0.5 / mTileSizeX;
      }
      
      override public function getWorldToScreenY(param1:Number, param2:Number, param3:Number) : int
      {
         return mTileHeightScreen * ((param1 + param2) * 0.5 - param3) / mTileSizeY;
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
         var _loc12_:Number = this.getWorldToScreenX(_loc4_ + _loc7_,_loc5_,_loc6_);
         var _loc13_:Number = this.getWorldToScreenY(_loc4_ + _loc7_,_loc5_,_loc6_);
         var _loc14_:Number = this.getWorldToScreenX(_loc4_ + _loc7_,_loc5_ + _loc8_,_loc6_);
         var _loc15_:Number = this.getWorldToScreenY(_loc4_ + _loc7_,_loc5_ + _loc8_,_loc6_);
         var _loc16_:Number = this.getWorldToScreenX(_loc4_,_loc5_ + _loc8_,_loc6_);
         var _loc17_:Number = this.getWorldToScreenY(_loc4_,_loc5_ + _loc8_,_loc6_);
         var _loc18_:Number = this.getWorldToScreenX(_loc4_,_loc5_,_loc6_ + _loc9_);
         var _loc19_:Number = this.getWorldToScreenY(_loc4_,_loc5_,_loc6_ + _loc9_);
         var _loc20_:Number = this.getWorldToScreenX(_loc4_ + _loc7_,_loc5_,_loc6_ + _loc9_);
         var _loc21_:Number = this.getWorldToScreenY(_loc4_ + _loc7_,_loc5_,_loc6_ + _loc9_);
         var _loc22_:Number = this.getWorldToScreenX(_loc4_ + _loc7_,_loc5_ + _loc8_,_loc6_ + _loc9_);
         var _loc23_:Number = this.getWorldToScreenY(_loc4_ + _loc7_,_loc5_ + _loc8_,_loc6_ + _loc9_);
         var _loc24_:Number = this.getWorldToScreenX(_loc4_,_loc5_ + _loc8_,_loc6_ + _loc9_);
         var _loc25_:Number = this.getWorldToScreenY(_loc4_,_loc5_ + _loc8_,_loc6_ + _loc9_);
         param1.lineStyle(0.3,param2);
         param1.moveTo(_loc10_,_loc11_);
         param1.lineTo(_loc12_,_loc13_);
         param1.lineTo(_loc14_,_loc15_);
         param1.lineTo(_loc16_,_loc17_);
         param1.lineTo(_loc10_,_loc11_);
         param1.lineTo(_loc18_,_loc19_);
         param1.lineTo(_loc20_,_loc21_);
         param1.lineTo(_loc22_,_loc23_);
         param1.lineTo(_loc24_,_loc25_);
         param1.lineTo(_loc18_,_loc19_);
         param1.moveTo(_loc12_,_loc13_);
         param1.lineTo(_loc20_,_loc21_);
         param1.moveTo(_loc14_,_loc15_);
         param1.lineTo(_loc22_,_loc23_);
         param1.moveTo(_loc16_,_loc17_);
         param1.lineTo(_loc24_,_loc25_);
      }
   }
}

