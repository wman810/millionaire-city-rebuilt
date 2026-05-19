package com.dchoc.framework.GUI
{
   import com.dchoc.framework.utils.DCUtils;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DCScrollButtons extends MovieClip
   {
      
      public static const MOVE_PIXELS:int = 25;
      
      private var mTargetClipDestinationY:Number;
      
      private var mIsUp:Boolean;
      
      private var mTargetClipDestinationX:Number;
      
      private var mScrollBarClip:Sprite;
      
      private var mLastTime:Number;
      
      private var mHandlerRange:Number;
      
      private var mButtonLeft:DCButton;
      
      private var mHandlerBottom:Number;
      
      private var mTargetOriginalWidth:Number;
      
      private var mIsDown:Boolean;
      
      private var mTargetClipOriginalEndX:Number;
      
      private var mTargetClipOriginalEndY:Number;
      
      private var mAmountToMoveOnAClickX:Number;
      
      private var mAmountToMoveOnAClickY:Number;
      
      private var mRootMC:MovieClip;
      
      private var mTargetClip:MovieClip;
      
      private var mTargetOriginalHeight:Number;
      
      private var mButtonEnd:DCButton;
      
      private var mButtonRight:DCButton;
      
      private var mTargetClipOriginalY:Number;
      
      private var mHandlerRatio:Number;
      
      private var mTargetClipOriginalX:Number;
      
      private var mButtonHome:DCButton;
      
      private var mHandlerTop:Number;
      
      public function DCScrollButtons(param1:Sprite, param2:MovieClip, param3:Number, param4:Number)
      {
         super();
         this.mAmountToMoveOnAClickX = param3;
         this.mAmountToMoveOnAClickY = param4;
         this.mScrollBarClip = param1;
         this.mTargetClip = param2;
         var _loc5_:MovieClip = this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_SCROLL_BAR_BUTTON_LEFT) as MovieClip;
         if(_loc5_)
         {
            this.mButtonLeft = new DCButton(this,_loc5_,DCButton.BUTTON_TYPE_SCROLL_LEFT,null,null,this.leftScroll,null,null,null,null);
         }
         _loc5_ = this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_SCROLL_BAR_BUTTON_RIGHT) as MovieClip;
         if(_loc5_)
         {
            this.mButtonRight = new DCButton(this,_loc5_,DCButton.BUTTON_TYPE_SCROLL_RIGHT,null,null,this.rightScroll,null,null,null,null);
         }
         _loc5_ = this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_SCROLL_BAR_BUTTON_HOME) as MovieClip;
         if(_loc5_)
         {
            this.mButtonHome = new DCButton(this,_loc5_,DCButton.BUTTON_TYPE_SCROLL_HOME,null,null,this.home,null,null,null,null);
         }
         _loc5_ = this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_SCROLL_BAR_BUTTON_END) as MovieClip;
         if(_loc5_)
         {
            this.mButtonEnd = new DCButton(this,_loc5_,DCButton.BUTTON_TYPE_SCROLL_END,null,null,this.end,null,null,null,null);
         }
         this.setMask();
         this.init();
         this.checkBoundaries();
      }
      
      public function enterFrameFunction(param1:Event) : void
      {
         this.mLastTime = new Date().time;
         if(this.mTargetClip.x > this.mTargetClipDestinationX)
         {
            this.mTargetClip.x = Math.max(this.mTargetClipDestinationX,this.mTargetClip.x - MOVE_PIXELS);
            this.checkBoundaries();
         }
         else if(this.mTargetClip.x < this.mTargetClipDestinationX)
         {
            this.mTargetClip.x = Math.min(this.mTargetClipDestinationX,this.mTargetClip.x + MOVE_PIXELS);
            this.checkBoundaries();
         }
      }
      
      private function checkBoundaries() : void
      {
         if(this.mAmountToMoveOnAClickX != 0)
         {
            if(this.mTargetClip.x + this.mAmountToMoveOnAClickX / 2 >= this.mTargetClipOriginalX)
            {
               if(this.mButtonLeft)
               {
                  this.mButtonLeft.setEnabled(false);
               }
               if(this.mButtonHome)
               {
                  this.mButtonHome.setEnabled(false);
               }
            }
            else
            {
               if(this.mButtonLeft)
               {
                  this.mButtonLeft.setEnabled(true);
               }
               if(this.mButtonHome)
               {
                  this.mButtonHome.setEnabled(true);
               }
            }
            if(this.mTargetClip.x - this.mAmountToMoveOnAClickX / 2 <= this.mTargetClipOriginalEndX)
            {
               if(this.mButtonRight)
               {
                  this.mButtonRight.setEnabled(false);
               }
               if(this.mButtonEnd)
               {
                  this.mButtonEnd.setEnabled(false);
               }
            }
            else
            {
               if(this.mButtonRight)
               {
                  this.mButtonRight.setEnabled(true);
               }
               if(this.mButtonEnd)
               {
                  this.mButtonEnd.setEnabled(true);
               }
            }
         }
      }
      
      private function init() : void
      {
         this.mTargetClipOriginalX = this.mTargetClipDestinationX = this.mTargetClip.x;
         this.mTargetClipOriginalY = this.mTargetClipDestinationY = this.mTargetClip.y;
         this.updateSize();
         if(this.mTargetClip.height > DCUtils.getLowestChildY(this.mTargetClip))
         {
            this.mScrollBarClip.visible = false;
         }
         addEventListener(Event.ENTER_FRAME,this.enterFrameFunction);
         this.mRootMC = DCUtils.getRoot(this.mTargetClip);
      }
      
      public function rightScroll(param1:MouseEvent) : void
      {
         if(this.mTargetClip.x - this.mAmountToMoveOnAClickX / 2 > this.mTargetClipOriginalEndX)
         {
            this.mTargetClipDestinationX = this.mTargetClip.x - this.mAmountToMoveOnAClickX;
         }
      }
      
      public function setPosition(param1:int = 2147483647, param2:int = 2147483647, param3:Boolean = true) : void
      {
         if(param1 != int.MAX_VALUE)
         {
            this.mTargetClipDestinationX = this.mTargetClipOriginalX - param1 * this.mAmountToMoveOnAClickX;
            if(param3)
            {
               this.mTargetClip.x = this.mTargetClipOriginalX - param1 * this.mAmountToMoveOnAClickX;
            }
         }
         if(param2 != int.MAX_VALUE)
         {
            this.mTargetClipDestinationY = this.mTargetClipOriginalY - param2 * this.mAmountToMoveOnAClickY;
            if(param3)
            {
               this.mTargetClip.y = this.mTargetClipOriginalY - param2 * this.mAmountToMoveOnAClickY;
            }
         }
      }
      
      public function leftScroll(param1:MouseEvent) : void
      {
         if(this.mTargetClip.x + this.mAmountToMoveOnAClickX / 2 < this.mTargetClipOriginalX)
         {
            this.mTargetClipDestinationX = this.mTargetClip.x + this.mAmountToMoveOnAClickX;
         }
      }
      
      protected function clean() : void
      {
      }
      
      public function end(param1:MouseEvent) : void
      {
         this.mTargetClipDestinationX = this.mTargetClipOriginalEndX;
      }
      
      public function home(param1:MouseEvent) : void
      {
         this.mTargetClipDestinationX = this.mTargetClipOriginalX;
      }
      
      public function updateSize() : void
      {
         this.mTargetClipOriginalEndX = this.mTargetClipOriginalX - this.mTargetClip.width + this.mTargetOriginalWidth;
         this.mTargetClipOriginalEndY = this.mTargetClipOriginalY - this.mTargetClip.height + this.mTargetOriginalHeight;
         this.checkBoundaries();
      }
      
      private function setMask() : void
      {
         var _loc1_:Sprite = this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_MASK) as Sprite;
         this.mTargetOriginalWidth = _loc1_.width;
         this.mTargetOriginalHeight = _loc1_.height;
      }
   }
}

