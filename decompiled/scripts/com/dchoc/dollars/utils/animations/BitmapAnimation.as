package com.dchoc.dollars.utils.animations
{
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import flash.events.Event;
   
   public class BitmapAnimation extends MovieClip
   {
      
      private var mCurrentFrame:int;
      
      private var mIsPlaying:Boolean;
      
      private var mBitmap:Bitmap;
      
      private var mTotalFrames:int;
      
      private var mAnimation:Object;
      
      public function BitmapAnimation(param1:Object = null)
      {
         super();
         this.setAnimation(param1);
      }
      
      public function get isPlaying() : Boolean
      {
         return this.mIsPlaying;
      }
      
      override public function gotoAndPlay(param1:Object, param2:String = null) : void
      {
         this.gotoAndStop(param1);
         this.mIsPlaying = true;
      }
      
      public function setAnimation(param1:Object) : void
      {
         if(param1 != null)
         {
            this.mAnimation = param1;
            this.mCurrentFrame = 0;
            this.mTotalFrames = param1.frames.length;
            this.mBitmap = new Bitmap();
            this.moveToFrame(this.mCurrentFrame);
            addChild(this.mBitmap);
         }
      }
      
      override public function get totalFrames() : int
      {
         return this.mTotalFrames;
      }
      
      public function update(param1:Event = null) : void
      {
         if(this.mIsPlaying)
         {
            this.mCurrentFrame = (this.mCurrentFrame + 1) % this.mTotalFrames;
            this.moveToFrame(this.mCurrentFrame);
         }
      }
      
      override public function stop() : void
      {
         this.mIsPlaying = false;
      }
      
      override public function play() : void
      {
         this.mIsPlaying = true;
      }
      
      override public function gotoAndStop(param1:Object, param2:String = null) : void
      {
         this.mCurrentFrame = int(param1) - 1;
         this.mCurrentFrame %= this.mTotalFrames;
         this.moveToFrame(this.mCurrentFrame);
         this.mIsPlaying = false;
      }
      
      private function moveToFrame(param1:int) : void
      {
         if(this.mBitmap != null)
         {
            this.mBitmap.bitmapData = this.mAnimation.frames[param1];
            this.mBitmap.x = this.mAnimation.bounds[param1].x;
            this.mBitmap.y = this.mAnimation.bounds[param1].y;
            this.mBitmap.pixelSnapping = PixelSnapping.NEVER;
         }
      }
      
      override public function get currentFrame() : int
      {
         return this.mCurrentFrame + 1;
      }
   }
}

