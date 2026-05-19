package com.dchoc.dollars.utils.particles
{
   import flash.display.MovieClip;
   
   public class ParticleAnimation extends Particles
   {
      
      public static const TYPE_BUILD:uint = 0;
      
      public static const TYPE_DESTROY:uint = 1;
      
      private var mAnim:MovieClip;
      
      public function ParticleAnimation(param1:int, param2:int, param3:MovieClip)
      {
         super();
         x = param1;
         y = param2;
         this.mAnim = param3;
         addChild(this.mAnim);
      }
      
      override public function update(param1:int) : void
      {
         if(this.mAnim.currentFrame == this.mAnim.totalFrames)
         {
            mAlive = false;
            this.mAnim.stop();
         }
      }
      
      override public function start() : void
      {
         this.mAnim.gotoAndPlay(1);
      }
      
      override public function destroy() : void
      {
         removeChild(this.mAnim);
         this.mAnim = null;
      }
   }
}

