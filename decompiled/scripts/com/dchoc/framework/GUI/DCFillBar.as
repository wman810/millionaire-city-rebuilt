package com.dchoc.framework.GUI
{
   import flash.display.MovieClip;
   
   public class DCFillBar
   {
      
      private static const ANIMATION_SPEED:Number = 0.1;
      
      private static const MIN_WIDTH:int = 1;
      
      private static const RES_NAME_BOUNDING_BOX:String = "bar_size";
      
      private static const RES_NAME_BAR:String = "bar";
      
      private var mValue:Number;
      
      private var mBar:MovieClip;
      
      private var mWidthTarget:Number;
      
      private var mMinValue:Number;
      
      private var mMaxWidth:Number;
      
      private var mContainer:MovieClip;
      
      private var mMaxValue:Number;
      
      public function DCFillBar(param1:MovieClip, param2:Number, param3:Number)
      {
         super();
         var _loc4_:MovieClip = param1.getChildByName(RES_NAME_BOUNDING_BOX) as MovieClip;
         this.mBar = param1.getChildByName(RES_NAME_BAR) as MovieClip;
         this.mContainer = param1;
         this.mMaxWidth = _loc4_.width;
         this.mWidthTarget = MIN_WIDTH;
         this.mValue = 0;
         this.setMinValue(param2);
         this.setMaxValue(param3);
      }
      
      public function setMinValue(param1:Number) : void
      {
         this.mMinValue = param1;
         this.setValueWithoutBarAnimation(this.mValue);
      }
      
      public function setValue(param1:Number) : void
      {
         this.mValue = param1;
         if(this.mValue > this.mMaxValue)
         {
            this.mValue = this.mMaxValue;
         }
         if(this.mValue < this.mMinValue)
         {
            this.mValue = this.mMinValue;
         }
         this.mWidthTarget = MIN_WIDTH + (this.mValue - this.mMinValue) * (this.mMaxWidth - MIN_WIDTH) / (this.mMaxValue - this.mMinValue);
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Number = NaN;
         if(this.mBar.width < this.mWidthTarget)
         {
            _loc2_ = param1 * ANIMATION_SPEED;
            this.mBar.width += _loc2_;
            if(this.mBar.width > this.mWidthTarget || _loc2_ == 0)
            {
               this.mBar.width = this.mWidthTarget;
            }
         }
      }
      
      public function setValueWithoutBarAnimation(param1:Number) : void
      {
         this.setValue(param1);
         this.mBar.width = this.mWidthTarget;
      }
      
      public function setMaxValue(param1:Number) : void
      {
         this.mMaxValue = param1;
         this.setValueWithoutBarAnimation(this.mValue);
      }
   }
}

