package com.dchoc.framework.world.view
{
   import com.dchoc.framework.world.WorldElement;
   import flash.display.Graphics;
   
   public class View
   {
      
      protected var mTileHeightScreen:Number;
      
      protected var mTileSizeX:Number;
      
      protected var mTileWidthScreen:Number;
      
      protected var mTileSizeY:Number;
      
      public function View()
      {
         super();
      }
      
      public function getScreenToWorldX(param1:Number, param2:Number, param3:Boolean = false) : int
      {
         return -1;
      }
      
      public function getScreenToWorldY(param1:Number, param2:Number, param3:Boolean = false) : int
      {
         return -1;
      }
      
      public function setParameters(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.mTileWidthScreen = param1;
         this.mTileHeightScreen = param2;
         this.mTileSizeX = param3;
         this.mTileSizeY = param4;
      }
      
      public function getWorldToScreenX(param1:Number, param2:Number, param3:Number) : int
      {
         return -1;
      }
      
      public function getWorldToScreenY(param1:Number, param2:Number, param3:Number) : int
      {
         return -1;
      }
      
      public function drawOnGC(param1:Graphics, param2:int, param3:WorldElement) : void
      {
      }
   }
}

