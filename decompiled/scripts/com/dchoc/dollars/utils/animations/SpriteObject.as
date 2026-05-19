package com.dchoc.dollars.utils.animations
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
   public class SpriteObject
   {
      
      private var mAnims:Array;
      
      private var mParent:*;
      
      private var mCurrentAnim:int;
      
      public function SpriteObject(param1:*, param2:Array, param3:int = 0)
      {
         super();
         this.mParent = param1;
         this.mAnims = param2;
         this.start(param3);
      }
      
      public function changeAnim(param1:int) : void
      {
         var _loc2_:int = 0;
         if(this.mCurrentAnim != param1)
         {
            _loc2_ = this.removeChild();
            if(param1 > -1 && this.mAnims[param1] != null)
            {
               this.mParent.addChild(this.mAnims[param1]);
               if(_loc2_ >= 0)
               {
                  this.mParent.setChildIndex(this.mAnims[param1],_loc2_);
               }
            }
            this.mCurrentAnim = param1;
         }
      }
      
      public function start(param1:int = 0) : void
      {
         this.mCurrentAnim = -1;
         this.changeAnim(param1);
      }
      
      public function hasCurrentAnimFinished() : Boolean
      {
         var _loc1_:MovieClip = null;
         if(this.mCurrentAnim > -1 && this.mAnims[this.mCurrentAnim] != null && !(this.mAnims[this.mCurrentAnim] is Bitmap))
         {
            _loc1_ = this.mAnims[this.mCurrentAnim];
            return _loc1_.currentFrame == _loc1_.totalFrames;
         }
         return false;
      }
      
      public function setCurrentAnimInde(param1:int) : void
      {
         this.mCurrentAnim = param1;
      }
      
      public function getAnim(param1:int) : DisplayObject
      {
         if(param1 > this.mAnims.length || param1 < 0)
         {
            throw new Error("Index not valid for the array animations");
         }
         return this.mAnims[param1];
      }
      
      public function setCurrentAnim(param1:MovieClip) : void
      {
         this.mAnims[this.mCurrentAnim] = param1;
      }
      
      public function update() : void
      {
         if(this.mCurrentAnim > -1 && this.mAnims[this.mCurrentAnim] is BitmapAnimation)
         {
            this.mAnims[this.mCurrentAnim].update();
         }
      }
      
      public function get Parent() : DisplayObjectContainer
      {
         return this.mParent;
      }
      
      public function stop() : void
      {
         this.changeAnim(-1);
      }
      
      public function getCurrentAnim() : DisplayObject
      {
         return this.mAnims[this.mCurrentAnim];
      }
      
      public function removeChild() : int
      {
         var _loc1_:int = -1;
         if(this.mCurrentAnim > -1 && this.mAnims[this.mCurrentAnim] != null)
         {
            _loc1_ = int(this.mParent.getChildIndex(this.mAnims[this.mCurrentAnim]));
            this.mParent.removeChild(this.mAnims[this.mCurrentAnim]);
         }
         return _loc1_;
      }
      
      public function addAnim(param1:MovieClip) : void
      {
         this.mAnims.push(param1);
      }
      
      public function destroy() : void
      {
         var _loc1_:DisplayObject = null;
         this.stop();
         for each(_loc1_ in this.mAnims)
         {
            if(_loc1_ is Bitmap)
            {
               Bitmap(_loc1_).bitmapData.dispose();
            }
            _loc1_ = null;
         }
         this.mAnims = null;
      }
      
      public function getCurrentAnimIndex() : int
      {
         return this.mCurrentAnim;
      }
      
      public function destroyIndex(param1:int) : void
      {
         if(this.mAnims[param1] != null)
         {
            if(this.mAnims[param1] is Bitmap)
            {
               Bitmap(this.mAnims[param1]).bitmapData.dispose();
            }
            this.mAnims[param1] = null;
         }
      }
   }
}

