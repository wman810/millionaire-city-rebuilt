package com.dchoc.dollars.utils.particles
{
   import flash.filters.GlowFilter;
   import flash.text.TextFieldAutoSize;
   
   public class TextAnimation extends Particles
   {
      
      private var SPEED:Number = 3.5;
      
      private var mTime:int;
      
      public function TextAnimation(param1:String, param2:int, param3:int)
      {
         var _loc4_:String = null;
         var _loc5_:GlowFilter = null;
         super();
         this.mTime = 1500;
         x = param2;
         y = param3;
         mFormat.color = 16777215;
         _loc5_ = new GlowFilter(10485760,255,2,2,2,3);
         mTextField.autoSize = TextFieldAutoSize.LEFT;
         mTextField.filters = [_loc5_];
         mTextField.defaultTextFormat = mFormat;
         mTextField.text = param1;
         x -= mTextField.width / 2;
         y -= mTextField.height;
         addChild(mTextField);
         cacheAsBitmap = true;
      }
      
      override public function destroy() : void
      {
         removeChild(mTextField);
         mTextField = null;
         mFormat = null;
      }
      
      override public function update(param1:int) : void
      {
         this.mTime -= param1;
         y -= this.SPEED;
         mAlive = this.mTime > 0;
      }
   }
}

