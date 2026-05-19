package com.dchoc.framework.GUI
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class DCComponent extends MovieClip
   {
      
      public static const COMPONENT_FRAME_NAME_INTRO:String = "In";
      
      public static const COMPONENT_FRAME_NAME_NORMAL:String = "Open";
      
      public static const COMPONENT_FRAME_NAME_OUTRO:String = "Out";
      
      public static const INSTANCE_NAME_MODAL_SQUARE:String = "Modal_Square";
      
      public static const MODAL_ALPHA_RECTANGLE_COLOR:Number = 0;
      
      public static const MODAL_ALPHA_RECTANGLE_ALPHA_VALUE:Number = 0.6;
      
      public static var mIsModalWindowOpen:Boolean = false;
      
      protected static const STATE_UNDEFINED:int = 0;
      
      protected static const STATE_OPENING:int = 1;
      
      protected static const STATE_READY:int = 2;
      
      protected static const STATE_CLOSING:int = 3;
      
      protected var mState:int = 0;
      
      private var mCloseAnimationFrameNumber:int;
      
      protected var mOpenAnimation:MovieClip;
      
      private var mModalSquareChildIndex:int = -1;
      
      protected var mParent:DisplayObjectContainer;
      
      private var mModalSquare:Sprite;
      
      public function DCComponent()
      {
         super();
         gotoAndStop(1);
      }
      
      public function getY() : int
      {
         return y;
      }
      
      public function centerClip() : void
      {
         x = stage.stageWidth / 2;
         y = stage.stageHeight / 2;
      }
      
      public function open(param1:DisplayObjectContainer, param2:Boolean = false) : void
      {
         this.mParent = param1;
         if(param2)
         {
            this.setModal();
         }
         this.mParent.addChild(this);
         if(this.mOpenAnimation != null)
         {
            addEventListener(Event.ENTER_FRAME,this.enterFrame);
            this.mState = STATE_OPENING;
            gotoAndPlay(COMPONENT_FRAME_NAME_INTRO);
         }
      }
      
      private function setModal() : void
      {
         var _loc2_:Sprite = null;
         var _loc1_:DisplayObject = this.mParent.getChildByName(INSTANCE_NAME_MODAL_SQUARE) as DisplayObject;
         if(_loc1_ == null)
         {
            _loc2_ = new Sprite();
            _loc2_.name = INSTANCE_NAME_MODAL_SQUARE;
            _loc2_.graphics.beginFill(MODAL_ALPHA_RECTANGLE_COLOR);
            _loc2_.graphics.drawRect(0,0,this.mParent.width,this.mParent.height);
            _loc2_.alpha = MODAL_ALPHA_RECTANGLE_ALPHA_VALUE;
            _loc2_.graphics.endFill();
            this.mParent.addChild(_loc2_);
         }
         else
         {
            this.mModalSquareChildIndex = this.mParent.getChildIndex(_loc1_);
            this.mParent.setChildIndex(_loc1_,this.mParent.numChildren - 1);
         }
         this.mModalSquare = _loc1_ as Sprite;
         mIsModalWindowOpen = true;
      }
      
      protected function clean() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.enterFrame);
         this.mState = STATE_UNDEFINED;
         var _loc1_:DisplayObject = this.mParent.getChildByName(INSTANCE_NAME_MODAL_SQUARE) as DisplayObject;
         if(_loc1_)
         {
            if(this.mModalSquareChildIndex == -1)
            {
               mIsModalWindowOpen = false;
               this.mParent.removeChild(_loc1_);
            }
            else
            {
               this.mParent.setChildIndex(_loc1_,this.mModalSquareChildIndex);
            }
         }
         this.mParent.removeChild(this);
         this.mParent = null;
      }
      
      public function getX() : int
      {
         return x;
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         x = param1;
         y = param2;
      }
      
      public function enterFrame(param1:Event) : void
      {
         switch(this.mState)
         {
            case STATE_OPENING:
               if(this.mOpenAnimation.currentLabel == COMPONENT_FRAME_NAME_NORMAL)
               {
                  this.mOpenAnimation.stop();
                  this.mCloseAnimationFrameNumber = this.mOpenAnimation.totalFrames - this.mOpenAnimation.currentFrame - 1;
                  this.mState = STATE_READY;
               }
               break;
            case STATE_READY:
               break;
            case STATE_CLOSING:
               if(this.mOpenAnimation.currentFrame == this.mOpenAnimation.totalFrames)
               {
                  stop();
                  this.clean();
               }
               break;
            default:
               trace("DCComponent() : logicupdate error -> Unknow State");
         }
      }
      
      public function close() : void
      {
         this.mState = STATE_CLOSING;
         if(this.mOpenAnimation == null)
         {
            this.clean();
         }
         else
         {
            this.mOpenAnimation.gotoAndPlay(COMPONENT_FRAME_NAME_OUTRO);
         }
      }
   }
}

