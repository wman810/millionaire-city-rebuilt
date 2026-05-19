package com.dchoc.framework.GUI
{
   import com.dchoc.framework.utils.DCUtils;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class DCScrollBar extends MovieClip
   {
      
      public static const MOVE_PIXELS:int = 4;
      
      private var mButtonDown:DCButton;
      
      private var mRootMC:MovieClip;
      
      private var mButtonHandle:DCButton;
      
      private var mScrollBarClip:Sprite;
      
      private var mTargetClip:MovieClip;
      
      private var mHandlerRange:Number;
      
      private var mTargetClipOriginalY:int;
      
      private var mHandlerBottom:Number;
      
      private var mHandlerRatio:Number;
      
      private var mIsUp:Boolean;
      
      private var mHandlerDragRect:Rectangle;
      
      private var mHandlerTop:Number;
      
      private var mIsDown:Boolean;
      
      private var mButtonUp:DCButton;
      
      public function DCScrollBar(param1:MovieClip, param2:MovieClip, param3:Number, param4:Number)
      {
         super();
         this.mScrollBarClip = param1;
         this.mTargetClip = param2;
         this.mButtonUp = new DCButton(this,this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_SCROLL_BAR_BUTTON_UP) as MovieClip,DCButton.BUTTON_TYPE_SCROLL_UP,null,null,this.upScroll,null,null,this.stopScroll,this.upScrollControlHandler);
         this.mButtonDown = new DCButton(this,this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_SCROLL_BAR_BUTTON_DOWN) as MovieClip,DCButton.BUTTON_TYPE_SCROLL_DOWN,null,null,this.downScroll,null,null,this.stopScroll,this.downScrollControlHandler);
         this.mButtonHandle = new DCButton(this,this.mScrollBarClip.getChildByName(DCWindow.INSTANCE_NAME_SCROLL_BAR_HANDLE) as MovieClip,DCButton.BUTTON_TYPE_SCROLL_HANDLE_VERTICAL,null,null,this.dragScroll,null,null,this.stopScroll,null);
         this.init();
         this.setMask(param3,param4);
      }
      
      public function upScroll(param1:MouseEvent) : void
      {
         trace("upscroll");
         this.mIsUp = true;
      }
      
      public function downScroll(param1:MouseEvent) : void
      {
         trace("downScroll");
         this.startScroll();
         this.mIsDown = true;
      }
      
      public function startScroll() : void
      {
         var _loc1_:Number = (this.mTargetClip.height - this.mHandlerRange) / this.mHandlerRange;
         var _loc2_:Number = (this.mButtonHandle.getY() - this.mHandlerTop) * _loc1_;
         this.mTargetClip.y = this.mTargetClipOriginalY - _loc2_;
      }
      
      private function init() : void
      {
         this.mTargetClipOriginalY = this.mTargetClip.y;
         if(this.mTargetClip.height > DCUtils.getLowestChildY(this.mTargetClip))
         {
            this.mScrollBarClip.visible = false;
         }
         this.mHandlerTop = this.mButtonHandle.getY();
         this.mHandlerBottom = this.mButtonDown.getY();
         this.mHandlerRange = this.mHandlerBottom - this.mHandlerTop;
         this.mHandlerDragRect = new Rectangle(0,this.mHandlerTop,0,this.mHandlerBottom - this.mButtonHandle.getHeight() * 2);
         this.mRootMC = DCUtils.getRoot(this.mTargetClip);
      }
      
      protected function clean() : void
      {
      }
      
      public function dragScroll(param1:MouseEvent) : void
      {
         this.mButtonHandle.startDrag(false,this.mHandlerDragRect);
         this.mRootMC.addEventListener(MouseEvent.MOUSE_MOVE,this.moveScroll);
         this.mRootMC.addEventListener(MouseEvent.MOUSE_UP,this.stopScroll);
         addEventListener(MouseEvent.MOUSE_MOVE,this.moveScroll);
      }
      
      public function downScrollControlHandler(param1:Event) : void
      {
         if(this.mIsDown)
         {
            if(this.mButtonHandle.getY() + this.mButtonHandle.getHeight() < this.mHandlerBottom)
            {
               this.mButtonHandle.setY(this.mButtonHandle.getY() + MOVE_PIXELS);
               if(this.mButtonHandle.getY() + this.mButtonHandle.getHeight() > this.mHandlerBottom)
               {
                  this.mButtonHandle.setY(this.mHandlerBottom - this.mButtonHandle.getHeight());
               }
               this.startScroll();
            }
         }
      }
      
      public function upScrollControlHandler(param1:Event) : void
      {
         if(this.mIsUp)
         {
            if(this.mButtonHandle.getY() > this.mHandlerTop)
            {
               this.mButtonHandle.setY(this.mButtonHandle.getY() - MOVE_PIXELS);
               if(this.mButtonHandle.getY() < this.mHandlerTop)
               {
                  this.mButtonHandle.setY(this.mHandlerTop);
               }
               this.startScroll();
            }
         }
      }
      
      public function stopScroll(param1:MouseEvent) : void
      {
         this.mIsDown = this.mIsUp = false;
         this.mButtonHandle.stopDrag();
         this.mRootMC.removeEventListener(MouseEvent.MOUSE_MOVE,this.moveScroll);
         this.mRootMC.removeEventListener(MouseEvent.MOUSE_UP,this.stopScroll);
         removeEventListener(MouseEvent.MOUSE_MOVE,this.moveScroll);
      }
      
      private function setMask(param1:Number, param2:Number) : void
      {
         var _loc4_:Sprite = null;
         var _loc3_:Sprite = this.mTargetClip.parent.getChildByName(DCWindow.INSTANCE_NAME_MASK) as Sprite;
         if(_loc3_)
         {
            param1 = _loc3_.width;
            param2 = _loc3_.height;
         }
         else
         {
            _loc4_ = new Sprite();
            _loc4_.graphics.beginFill(0);
            _loc4_.graphics.drawRect(this.mTargetClip.x,this.mTargetClip.y,param1,param2);
            this.mTargetClip.parent.addChild(_loc4_);
            this.mTargetClip.mask = _loc4_;
         }
      }
      
      public function moveScroll(param1:MouseEvent) : void
      {
         this.startScroll();
      }
   }
}

