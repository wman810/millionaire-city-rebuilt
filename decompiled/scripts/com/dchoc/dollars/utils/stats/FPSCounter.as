package com.dchoc.dollars.utils.stats
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.getTimer;
   
   public class FPSCounter extends Sprite
   {
      
      private var mFPSData:Array;
      
      private var dataIndex:int = 0;
      
      private var tf:TextField;
      
      private var ticks:uint = 0;
      
      private var mFPS:Number = 0;
      
      private var last:uint = getTimer();
      
      private const MAX_FPS_SAMPLES:int = 20;
      
      public function FPSCounter(param1:int = 0, param2:int = 0, param3:uint = 16777215, param4:Boolean = false, param5:uint = 0)
      {
         super();
         x = param1;
         y = param2;
         this.tf = new TextField();
         this.tf.textColor = param3;
         this.tf.text = "----- fps";
         this.tf.selectable = false;
         this.tf.background = param4;
         this.tf.backgroundColor = param5;
         this.tf.autoSize = TextFieldAutoSize.LEFT;
         addChild(this.tf);
         width = this.tf.textWidth;
         height = this.tf.textHeight;
         addEventListener(Event.ENTER_FRAME,this.tick);
         this.mFPSData = new Array(this.MAX_FPS_SAMPLES);
      }
      
      public function stopSampling() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.tick);
      }
      
      public function getValue() : Number
      {
         var _loc1_:int = Math.round(this.mFPS);
         if(_loc1_ > 25)
         {
            _loc1_ = 25;
         }
         else if(_loc1_ < 1)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         this.visible = param1;
      }
      
      public function getTextValue() : String
      {
         var _loc1_:int = Math.round(this.mFPS);
         if(_loc1_ > 25)
         {
            _loc1_ = 25;
         }
         else if(_loc1_ < 1)
         {
            _loc1_ = 0;
         }
         return Math.round(_loc1_).toFixed(1) + " ";
      }
      
      public function tick(param1:Event) : void
      {
         var _loc4_:int = 0;
         ++this.ticks;
         var _loc2_:uint = uint(getTimer());
         var _loc3_:uint = _loc2_ - this.last;
         if(_loc3_ >= 1000)
         {
            this.mFPSData[this.dataIndex] = this.ticks / _loc3_ * 1000;
            this.ticks = 0;
            this.last = _loc2_;
            ++this.dataIndex;
            _loc4_ = 0;
            while(_loc4_ < this.mFPSData.length)
            {
               if(this.mFPSData[_loc4_] == null)
               {
                  break;
               }
               this.mFPS += this.mFPSData[_loc4_];
               _loc4_++;
            }
            this.mFPS /= _loc4_;
            if(this.dataIndex == this.MAX_FPS_SAMPLES)
            {
               this.dataIndex = 0;
            }
            this.tf.text = this.mFPS.toFixed(1) + " fps";
         }
      }
   }
}

