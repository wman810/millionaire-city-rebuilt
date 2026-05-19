package com.dchoc.dollars.utils.animations
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class DCBitmapSprite
   {
      
      protected var mVisible:Boolean;
      
      protected var mFrame:int;
      
      private var mAlphaBmp:BitmapData;
      
      private var mBmp:BitmapData;
      
      private var mAlphaPos:Point;
      
      private var mRect:Rectangle;
      
      protected var mHasToDraw:Boolean;
      
      protected var mPosition:Point;
      
      private var mErase:Rectangle;
      
      public function DCBitmapSprite(param1:BitmapData, param2:BitmapData, param3:int, param4:int)
      {
         super();
         this.mBmp = param1;
         this.mAlphaBmp = param2;
         this.mVisible = true;
         this.mHasToDraw = false;
         this.mRect = new Rectangle(0,0,param3,param4);
         this.mErase = new Rectangle(0,0,param3,param4);
         this.mAlphaPos = new Point();
         this.mPosition = new Point();
      }
      
      public function get visible() : Boolean
      {
         return this.mVisible;
      }
      
      public function draw(param1:BitmapData) : void
      {
         if(this.mVisible && this.mHasToDraw)
         {
            param1.copyPixels(this.mBmp,this.mRect,this.mPosition,this.mAlphaBmp,this.mAlphaPos,true);
         }
      }
      
      public function get y() : Number
      {
         return this.mPosition.y;
      }
      
      public function remove(param1:BitmapData) : void
      {
         if(this.mHasToDraw)
         {
            param1.fillRect(this.mErase,0);
         }
      }
      
      public function set hasToDraw(param1:Boolean) : void
      {
         this.mHasToDraw = param1;
      }
      
      public function get hasToDraw() : Boolean
      {
         return this.mHasToDraw;
      }
      
      public function getPosition() : Point
      {
         return this.mPosition;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.mVisible = param1;
      }
      
      public function getCurrentFrame() : int
      {
         return this.mFrame;
      }
      
      public function setPosition(param1:int, param2:int) : void
      {
         this.mErase.x = param1;
         this.mErase.y = param2;
         this.mPosition.x = param1;
         this.mPosition.y = param2;
      }
      
      public function get x() : Number
      {
         return this.mPosition.x;
      }
      
      public function setCurrentFrame(param1:int) : void
      {
         this.mRect.x = this.mRect.width * param1;
         this.mFrame = param1;
      }
   }
}

