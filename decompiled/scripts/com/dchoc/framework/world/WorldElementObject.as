package com.dchoc.framework.world
{
   import flash.display.*;
   import flash.events.*;
   
   public class WorldElementObject extends WorldElement
   {
      
      public function WorldElementObject(param1:World)
      {
         super(param1);
         addEventListener(MouseEvent.MOUSE_DOWN,this.reportMouseDown);
      }
      
      public function getCollisionObject() : WorldElementObject
      {
         var _loc2_:WorldElementObject = null;
         var _loc1_:int = 0;
         while(_loc1_ < mWorld.mElementObjects.length)
         {
            _loc2_ = mWorld.mElementObjects[_loc1_];
            if(!(_loc2_ == this || mWorldX + mWorldSizeX < _loc2_.mWorldX || mWorldX > _loc2_.mWorldX + _loc2_.mWorldSizeX || mWorldY + mWorldSizeY < _loc2_.mWorldY || mWorldY > _loc2_.mWorldY + _loc2_.mWorldSizeY || mWorldZ + mWorldSizeZ < _loc2_.mWorldZ || mWorldZ > _loc2_.mWorldZ + _loc2_.mWorldSizeZ))
            {
               return _loc2_;
            }
            _loc1_++;
         }
         return null;
      }
      
      public function setDisplayObjectWithObject(param1:DisplayObject, param2:int = 0) : void
      {
         mDisplayObjects[param2] = param1;
         this.updateDisplayObjects();
      }
      
      override public function logicUpdate(param1:Number) : void
      {
         this.updatePhysics(param1);
      }
      
      override protected function reportMouseMove(param1:MouseEvent) : void
      {
         if(mEnabled)
         {
            super.reportMouseMove(param1);
            mWorld.setSelectedObject(this);
         }
      }
      
      protected function reportMouseDown(param1:MouseEvent) : void
      {
         if(mEnabled)
         {
            mWorld.moveObject();
         }
      }
      
      public function getDisplayObject() : DisplayObject
      {
         if(mDisplayObjects != null)
         {
            return mDisplayObjects[0];
         }
         return null;
      }
      
      public function updatePhysics(param1:Number) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc2_:Number = 9999;
         var _loc3_:Number = 0;
         var _loc4_:int = mWorldX;
         var _loc5_:int;
         var _loc6_:Number = _loc5_ = mWorldY;
         while(_loc6_ < _loc5_ + mWorldSizeY + mWorld.mTileSizeY)
         {
            _loc7_ = _loc4_;
            while(_loc7_ < _loc4_ + mWorldSizeX + mWorld.mTileSizeY)
            {
               _loc8_ = mWorld.getGroundHeight(_loc7_,_loc6_);
               if(_loc8_ > _loc3_)
               {
                  _loc3_ = _loc8_;
               }
               if(_loc8_ < _loc2_)
               {
                  _loc2_ = _loc8_;
               }
               _loc7_ += mWorld.mTileSizeX;
            }
            _loc6_ += mWorld.mTileSizeY;
         }
         if(mWorldZ < _loc3_)
         {
            mWorldZ = _loc3_;
         }
         this.updateDisplayObjects();
      }
      
      public function setDisplayObject(param1:Class) : void
      {
         mDisplayObjects[0] = new param1();
         this.updateDisplayObjects();
      }
   }
}

