package com.dchoc.dollars.utils.behaviors
{
   import com.dchoc.dollars.utils.animations.ItemSprite;
   
   public class Behavior
   {
      
      protected var mAcceleration:Number;
      
      protected var mTime:int;
      
      protected var mEndTime:int;
      
      protected var mStartTime:int;
      
      protected var mVelocity:Number;
      
      protected var mDO:ItemSprite;
      
      public function Behavior(param1:int = 0, param2:int = -1)
      {
         super();
         this.mStartTime = param1;
         if(param2 > -1)
         {
            this.mEndTime = param1 + param2;
         }
         else
         {
            this.mEndTime = -1;
         }
         this.mVelocity = 1;
         this.mAcceleration = 0;
      }
      
      public function setAcceleration(param1:Number) : void
      {
         this.mAcceleration = param1;
      }
      
      public function isFinished() : Boolean
      {
         return this.checkEndTime() && this.doIsFinished();
      }
      
      public function setEndTime(param1:int) : void
      {
         this.mEndTime = param1;
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Boolean = false;
         if(!this.isFinished())
         {
            _loc2_ = this.mTime <= this.mStartTime;
            if(this.mTime > this.mStartTime)
            {
               this.mVelocity += this.mAcceleration * param1;
            }
            this.mTime += this.mVelocity * param1;
            if(this.mTime > this.mStartTime)
            {
               if(_loc2_)
               {
                  this.start();
               }
               if(this.isFinished())
               {
                  this.end();
               }
               this.doLogicUpdate(param1);
            }
         }
      }
      
      public function reset() : void
      {
         this.mTime = 0;
         this.mVelocity = 1;
         if(this.mDO != null)
         {
            this.mDO.visible = true;
         }
      }
      
      public function getEndTime() : int
      {
         return this.mEndTime;
      }
      
      private function checkEndTime() : Boolean
      {
         return this.mEndTime > -1;
      }
      
      protected function doIsFinished() : Boolean
      {
         return this.mTime >= this.mEndTime;
      }
      
      public function start() : void
      {
      }
      
      public function setDO(param1:ItemSprite) : void
      {
         this.mDO = param1;
      }
      
      public function destroy() : void
      {
         this.mDO = null;
      }
      
      protected function doLogicUpdate(param1:int) : void
      {
      }
      
      public function end() : void
      {
         this.mTime = this.mEndTime;
      }
   }
}

