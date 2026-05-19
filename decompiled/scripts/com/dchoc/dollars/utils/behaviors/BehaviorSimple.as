package com.dchoc.dollars.utils.behaviors
{
   public class BehaviorSimple extends Behavior
   {
      
      protected var mValueStart:Number;
      
      protected var mValueEnd:Number;
      
      public function BehaviorSimple(param1:Number, param2:Number, param3:int = 0, param4:int = -1)
      {
         super(param3,param4);
         this.mValueStart = param1;
         this.mValueEnd = param2;
      }
      
      protected function calculateValue() : Number
      {
         var _loc1_:Number = mEndTime - mStartTime;
         return this.mValueStart + (this.mValueEnd - this.mValueStart) * (mTime - mStartTime) / _loc1_;
      }
   }
}

