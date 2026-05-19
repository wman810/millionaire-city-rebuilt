package com.dchoc.framework.world
{
   import flash.display.*;
   import flash.events.*;
   
   public class WorldElementTile extends WorldElement
   {
      
      public var mPropertyTransparent:Boolean = false;
      
      protected var resourceClass:Class;
      
      public function WorldElementTile(param1:World)
      {
         super(param1);
         mWorldSizeX = 1;
         mWorldSizeY = 1;
         mWorldSizeZ = 0.2;
         mScreenOffsetX = -mWorld.mTileWidthScreen / 2;
      }
      
      override protected function reportMouseMove(param1:MouseEvent) : void
      {
         super.reportMouseMove(param1);
         mWorld.setSelectedTile(this);
      }
      
      public function replaceWith(param1:WorldElementTile) : void
      {
         mWorld.mTiles[mWorldY][mWorldX] = param1;
         param1.setWorldPosition(mWorldX,mWorldY,mWorldZ);
         var _loc2_:DisplayObjectContainer = this.parent;
         _loc2_.addChild(param1);
         _loc2_.swapChildren(this,param1);
         _loc2_.removeChild(this);
         mWorld.setSelectedTile(param1);
      }
      
      override public function updateDisplayObjects() : void
      {
         var _loc2_:Bitmap = null;
         var _loc3_:Number = NaN;
         var _loc6_:WorldElementTile = null;
         var _loc7_:Number = NaN;
         var _loc1_:int = 0;
         while(_loc1_ < this.numChildren)
         {
            this.removeChildAt(_loc1_);
            _loc1_++;
         }
         var _loc4_:Number = mWorldZ;
         var _loc5_:Number = mWorldZ;
         if(mWorld.isTilePositionInBoundaries(mWorldX + mWorld.mTileSizeX,mWorldY))
         {
            _loc6_ = mWorld.mTiles[mWorldY][mWorldX + mWorld.mTileSizeX];
            if(!_loc6_.mPropertyTransparent)
            {
               _loc4_ = mWorldZ - _loc6_.mWorldZ;
            }
         }
         if(mWorld.isTilePositionInBoundaries(mWorldX,mWorldY + mWorld.mTileSizeY))
         {
            _loc6_ = mWorld.mTiles[mWorldY + mWorld.mTileSizeY][mWorldX];
            if(!_loc6_.mPropertyTransparent)
            {
               _loc5_ = mWorldZ - _loc6_.mWorldZ;
            }
         }
         if(_loc5_ > _loc4_)
         {
            _loc3_ = _loc5_;
         }
         else
         {
            _loc3_ = _loc4_;
         }
         if(_loc3_ > -mWorldSizeZ)
         {
            if(!this.mPropertyTransparent)
            {
               _loc7_ = mWorldZ - _loc3_;
               while(_loc7_ < mWorldZ)
               {
                  _loc2_ = new this.resourceClass();
                  _loc2_.x = mWorld.getWorldToScreenX(mWorldX,mWorldY,_loc7_) - _loc2_.width / 2;
                  _loc2_.y = mWorld.getWorldToScreenY(mWorldX,mWorldY,_loc7_);
                  addChild(_loc2_);
                  _loc7_ += mWorldSizeZ;
               }
            }
            _loc2_ = new this.resourceClass();
            _loc2_.x = mWorld.getWorldToScreenX(mWorldX,mWorldY,mWorldZ) - _loc2_.width / 2;
            _loc2_.y = mWorld.getWorldToScreenY(mWorldX,mWorldY,mWorldZ);
            addChild(_loc2_);
         }
      }
   }
}

