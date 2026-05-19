package com.dchoc.dollars.utils.effects
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class Flag extends Sprite
   {
      
      private var mFlagHeight:int;
      
      private var mTime:int;
      
      private var mFlagWidth:int;
      
      private var kNbrStrips:int;
      
      private var mFrequency:Number;
      
      private var mPeriod:Number;
      
      private var mFlag:Bitmap;
      
      private var mLabda:Number;
      
      private var mFlagsArray:Array;
      
      public function Flag(param1:Sprite)
      {
         super();
         this.mFlagsArray = new Array();
         this.mFlagWidth = param1.width;
         this.mFlagHeight = param1.height;
         var _loc2_:BitmapData = new BitmapData(param1.width,param1.height,true,16777215);
         _loc2_.draw(param1,null);
         this.mFlag = new Bitmap(_loc2_);
         this.mTime = 0;
      }
      
      public function start(param1:int = 50, param2:Number = 1.25, param3:Number = 0.05, param4:Number = 0.006) : void
      {
         var _loc6_:int = 0;
         var _loc8_:Shape = null;
         var _loc9_:Shape = null;
         this.mPeriod = param2;
         this.mLabda = param3;
         this.mFrequency = param4;
         this.kNbrStrips = param1;
         var _loc5_:Number = this.mFlagWidth / this.kNbrStrips;
         _loc6_ = 8;
         var _loc7_:int = 0;
         while(_loc7_ < this.kNbrStrips)
         {
            _loc8_ = new Shape();
            _loc8_.graphics.beginBitmapFill(this.mFlag.bitmapData);
            _loc8_.graphics.drawRect(0,0,this.mFlagWidth,this.mFlag.height);
            _loc8_.graphics.endFill();
            _loc8_.x = this.mFlagWidth / _loc6_;
            _loc9_ = new Shape();
            _loc9_.x = _loc7_ * _loc5_;
            _loc9_.graphics.beginFill(0,1);
            _loc9_.graphics.drawRect(-_loc6_ / 2,-_loc6_ / 2 - 10,_loc5_ + _loc6_,this.mFlagHeight + _loc6_ + 30);
            _loc9_.graphics.endFill();
            _loc8_.mask = _loc9_;
            addChild(_loc9_);
            addChild(_loc8_);
            this.mFlagsArray.push(_loc8_);
            _loc7_++;
         }
         this.mTime = 0;
      }
      
      public function updateWaveFlag(param1:int) : void
      {
         var _loc2_:* = 0;
         if(param1 > 0)
         {
            _loc2_ = int(this.kNbrStrips - 1);
            while(_loc2_ > 1)
            {
               this.mFlagsArray[_loc2_].y = this.mFlagsArray[_loc2_ - 1].y;
               _loc2_--;
            }
            this.mTime += param1;
            this.mFlagsArray[1].y = this.mPeriod * Math.sin(this.mLabda - this.mTime * this.mFrequency);
         }
      }
      
      public function destroy() : void
      {
         this.mFlagsArray = null;
         this.mFlag = null;
      }
   }
}

