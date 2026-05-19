package com.dchoc.framework.world
{
   import flash.display.*;
   import flash.events.*;
   import flash.utils.ByteArray;
   
   public class WorldElement extends Sprite
   {
      
      protected var mDisplayObjects:Array;
      
      public var mWorldSizeX:Number;
      
      public var mWorldSizeY:Number;
      
      protected var mEnabled:Boolean = true;
      
      public var mWorldY:Number;
      
      public var mWorldZ:Number;
      
      public var mWorldX:Number;
      
      public var mWorldSizeZ:Number;
      
      protected var mWorld:World;
      
      protected var mScreenOffsetX:Number = 0;
      
      protected var mScreenOffsetY:Number = 0;
      
      public function WorldElement(param1:World)
      {
         super();
         this.mWorld = param1;
         this.mDisplayObjects = new Array();
         this.mWorldSizeX = 1;
         this.mWorldSizeY = 1;
         this.mWorldSizeZ = 0.5;
         addEventListener(MouseEvent.MOUSE_MOVE,this.reportMouseMove);
         this.cacheAsBitmap = true;
      }
      
      protected function reportMouseMove(param1:MouseEvent) : void
      {
         this.mWorld.setSelectedElement(this);
      }
      
      public function logicUpdate(param1:Number) : void
      {
      }
      
      public function storeToByteArray(param1:ByteArray) : void
      {
         param1.writeFloat(this.mWorldX);
         param1.writeFloat(this.mWorldY);
         param1.writeFloat(this.mWorldZ);
      }
      
      public function setWorldPosition(param1:Number, param2:Number, param3:Number) : void
      {
         this.mWorldX = param1;
         this.mWorldY = param2;
         this.mWorldZ = param3;
         this.updateDisplayObjects();
      }
      
      public function drawOnGC(param1:Graphics, param2:int) : void
      {
         this.mWorld.view.drawOnGC(param1,param2,this);
      }
      
      public function restoreFromByteArray(param1:ByteArray) : void
      {
         this.mWorldX = param1.readFloat();
         this.mWorldY = param1.readFloat();
         this.mWorldZ = param1.readFloat();
         this.updateDisplayObjects();
      }
      
      public function updateDisplayObjects() : void
      {
         var _loc1_:int = 0;
         var _loc2_:DisplayObject = null;
         _loc1_ = 0;
         while(_loc1_ < this.numChildren)
         {
            this.removeChildAt(_loc1_);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.mDisplayObjects.length)
         {
            _loc2_ = this.mDisplayObjects[_loc1_];
            _loc2_.x = this.mWorld.getWorldToScreenX(this.mWorldX,this.mWorldY,this.mWorldZ) + this.mScreenOffsetX;
            _loc2_.y = this.mWorld.getWorldToScreenY(this.mWorldX,this.mWorldY,this.mWorldZ) + this.mScreenOffsetY;
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.mDisplayObjects.length)
         {
            _loc2_ = this.mDisplayObjects[_loc1_];
            addChild(_loc2_);
            _loc1_++;
         }
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         this.mEnabled = param1;
      }
   }
}

