package com.dchoc.dollars.utils.behaviors
{
   public class BehaviorAlpha extends BehaviorSimple
   {
      
      public function BehaviorAlpha(param1:Number, param2:Number, param3:int, param4:int)
      {
         super(param1,param2,param3,param4);
      }
      
      override public function start() : void
      {
         super.start();
         mDO.alpha = mValueStart;
      }
      
      override protected function doLogicUpdate(param1:int) : void
      {
         var _loc2_:Number = calculateValue();
         mDO.alpha = _loc2_;
         mDO.visible = mDO.alpha > 0;
      }
      
      override public function end() : void
      {
         super.end();
      }
   }
}

