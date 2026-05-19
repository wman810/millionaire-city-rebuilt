package com.dchoc.dollars.utils.behaviors
{
   public class BehaviorScale extends BehaviorSimple
   {
      
      public function BehaviorScale(param1:Number, param2:Number, param3:int, param4:int)
      {
         super(param1,param2,param3,param4);
      }
      
      private function setScale(param1:Number) : void
      {
         mDO.scaleX = param1;
         mDO.scaleY = param1;
         mDO.recalculatePosition();
      }
      
      override public function start() : void
      {
         super.start();
         this.setScale(mValueStart);
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         var _loc2_:Number = calculateValue();
         this.setScale(_loc2_);
      }
      
      override public function reset() : void
      {
         super.reset();
         this.setScale(mValueStart);
      }
   }
}

