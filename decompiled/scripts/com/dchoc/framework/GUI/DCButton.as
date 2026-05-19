package com.dchoc.framework.GUI
{
   import com.dchoc.framework.events.ButtonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class DCButton extends EventDispatcher
   {
      
      public static const BUTTON_TYPE_NAMES:Array = ["BUTTON_TYPE_OK","BUTTON_TYPE_YES","BUTTON_TYPE_NO","BUTTON_TYPE_CANCEL","BUTTON_TYPE_X","BUTTON_TYPE_SCROLL_UP","BUTTON_TYPE_SCROLL_DOWN","BUTTON_TYPE_SCROLL_LEFT","BUTTON_TYPE_SCROLL_RIGHT","BUTTON_TYPE_SCROLL_HANDLE_VERTICAL","BUTTON_TYPE_SCROLL_HANDLE_HORIZONTAL","BUTTON_TYPE_TAB","BUTTON_TYPE_ICON","BUTTON_TYPE_SCROLL_HOME","BUTTON_TYPE_SCROLL_END","BUTTON_COMMON","BUTTON_TYPE_COMMON_CLOSE_TEXT_BOX"];
      
      public static const BUTTON_FRAME_NAME_UP:String = "UpState";
      
      public static const BUTTON_FRAME_NAME_DOWN:String = "DownState";
      
      public static const BUTTON_FRAME_NAME_OVER:String = "OverState";
      
      public static const BUTTON_FRAME_NAME_DISABLED_UP:String = "DisabledUpState";
      
      public static const BUTTON_FRAME_NAME_DISABLED_OVER:String = "DisabledOverState";
      
      public static const BUTTON_FRAME_NAME_DISABLED_DOWN:String = "DisabledDownState";
      
      public static const BUTTON_FRAME_NAME_SELECTED_UP:String = "SelectedStateUp";
      
      public static const BUTTON_FRAME_NAME_SELECTED_OVER:String = "SelectedStateOver";
      
      public static const BUTTON_FRAME_NAME_COLLISION_BOX_EVENT:String = "Collision_Box_Event";
      
      public static const BUTTON_TYPE_OK:int = 0;
      
      public static const BUTTON_TYPE_YES:int = 1;
      
      public static const BUTTON_TYPE_NO:int = 2;
      
      public static const BUTTON_TYPE_CANCEL:int = 3;
      
      public static const BUTTON_TYPE_X:int = 4;
      
      public static const BUTTON_TYPE_SCROLL_UP:int = 5;
      
      public static const BUTTON_TYPE_SCROLL_DOWN:int = 6;
      
      public static const BUTTON_TYPE_SCROLL_LEFT:int = 7;
      
      public static const BUTTON_TYPE_SCROLL_RIGHT:int = 8;
      
      public static const BUTTON_TYPE_SCROLL_HANDLE_VERTICAL:int = 9;
      
      public static const BUTTON_TYPE_SCROLL_HANDLE_HORIZONTAL:int = 10;
      
      public static const BUTTON_TYPE_TAB:int = 11;
      
      public static const BUTTON_TYPE_ICON:int = 12;
      
      public static const BUTTON_TYPE_SCROLL_HOME:int = 13;
      
      public static const BUTTON_TYPE_SCROLL_END:int = 14;
      
      public static const BUTTON_TYPE_COMMON:int = 15;
      
      public static const BUTTON_TYPE_COMMON_CLOSE_TEXT_BOX:int = 16;
      
      public static const BUTTON_ID_MENU_BAR:int = 1000;
      
      private var mMouseUpFunction:Function;
      
      private var mCollisionBox:MovieClip;
      
      private var mType:int;
      
      private var mID:String;
      
      private var mEnabled:Boolean;
      
      private var mMouseOverFunction:Function;
      
      private var mObjectToWarnForClick:Object;
      
      private var mMouseOutFunction:Function;
      
      private var mMouseDownFunction:Function;
      
      private var mParent:DisplayObjectContainer;
      
      private var mEnterFrameFunction:Function;
      
      protected var mButton:MovieClip;
      
      public function DCButton(param1:DisplayObjectContainer, param2:MovieClip, param3:int, param4:String = null, param5:Object = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Function = null, param10:Function = null)
      {
         super();
         this.mParent = param1;
         this.mButton = param2;
         this.mType = param3;
         this.mID = param4;
         this.setEnabled(true);
         this.mCollisionBox = this.mButton.getChildByName(BUTTON_FRAME_NAME_COLLISION_BOX_EVENT) as MovieClip;
         if(this.mCollisionBox)
         {
            this.mCollisionBox.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            this.mCollisionBox.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
            this.mCollisionBox.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
            this.mCollisionBox.addEventListener(MouseEvent.MOUSE_UP,this.mouseUp);
            if(Config.BUTTON_USE_HAND_CURSOR)
            {
               this.mCollisionBox.buttonMode = true;
               this.mCollisionBox.mouseChildren = false;
               this.mCollisionBox.useHandCursor = true;
            }
            this.mButton.setChildIndex(this.mCollisionBox,this.mButton.numChildren - 1);
         }
         else
         {
            this.mButton.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            this.mButton.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
            this.mButton.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
            this.mButton.addEventListener(MouseEvent.MOUSE_UP,this.mouseUp);
            if(Config.BUTTON_USE_HAND_CURSOR)
            {
               this.mButton.buttonMode = true;
               this.mButton.mouseChildren = false;
               this.mButton.useHandCursor = true;
            }
         }
         if(param10 != null)
         {
            this.mButton.addEventListener(Event.ENTER_FRAME,param10);
         }
         this.mMouseDownFunction = param6;
         this.mMouseOutFunction = param8;
         this.mMouseOverFunction = param7;
         this.mMouseUpFunction = param9;
         this.mEnterFrameFunction = param10;
         this.mObjectToWarnForClick = param5;
      }
      
      public static function getStringFromType(param1:int) : String
      {
         return BUTTON_TYPE_NAMES[param1];
      }
      
      public function getX() : int
      {
         return this.mButton.x;
      }
      
      public function clean() : void
      {
         if(this.mCollisionBox != null)
         {
            this.mCollisionBox.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            this.mCollisionBox.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
            this.mCollisionBox.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
            this.mCollisionBox.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUp);
         }
         else
         {
            this.mButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            this.mButton.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
            this.mButton.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
            this.mButton.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUp);
         }
         this.mParent.removeChildAt(this.mParent.getChildIndex(this.mButton));
      }
      
      public function getY() : int
      {
         return this.mButton.y;
      }
      
      public function showHelper() : void
      {
      }
      
      public function isEnable() : Boolean
      {
         return this.mEnabled;
      }
      
      public function setHelper(param1:String) : void
      {
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         this.mEnabled = param1;
         if(param1)
         {
            this.mButton.gotoAndStop(BUTTON_FRAME_NAME_UP);
         }
         else
         {
            this.mButton.gotoAndStop(BUTTON_FRAME_NAME_DISABLED_UP);
         }
      }
      
      public function setY(param1:int) : void
      {
         this.mButton.y = param1;
      }
      
      public function getHeight() : int
      {
         return this.mButton.height;
      }
      
      public function getWidth() : int
      {
         return this.mButton.width;
      }
      
      protected function mouseOver(param1:MouseEvent) : void
      {
         if(!this.mEnabled)
         {
            return;
         }
         this.mButton.gotoAndStop(BUTTON_FRAME_NAME_OVER);
         if(this.mMouseOverFunction != null)
         {
            this.mMouseOverFunction(param1);
         }
         this.showHelper();
      }
      
      public function stopDrag() : void
      {
         this.mButton.stopDrag();
      }
      
      public function putToFront() : void
      {
         this.mButton.parent.setChildIndex(this.mButton,this.mButton.parent.numChildren - 1);
      }
      
      protected function mouseDown(param1:MouseEvent) : void
      {
         if(!this.mEnabled)
         {
            return;
         }
         this.mButton.gotoAndStop(BUTTON_FRAME_NAME_DOWN);
         if(this.mObjectToWarnForClick != null)
         {
            this.mObjectToWarnForClick.dispatchEvent(new ButtonEvent(this,DCWindow.EVENT_BUTTON_CLICKED,this.mType,this.mID,true));
         }
         if(this.mMouseDownFunction != null)
         {
            this.mMouseDownFunction(param1);
         }
      }
      
      protected function mouseOut(param1:MouseEvent) : void
      {
         if(!this.mEnabled)
         {
            return;
         }
         this.mButton.gotoAndStop(BUTTON_FRAME_NAME_UP);
         if(this.mMouseOutFunction != null)
         {
            this.mMouseOutFunction(param1);
         }
         this.hideHelper();
      }
      
      public function getMovieClip() : DisplayObjectContainer
      {
         return this.mButton;
      }
      
      public function setText(param1:String) : void
      {
         if(param1 != null && param1 != "")
         {
            DCGuiUtils.setTextAndResizeBackground(this.mButton,param1);
         }
      }
      
      public function getType() : int
      {
         return this.mType;
      }
      
      public function putToBack() : void
      {
         this.mButton.parent.setChildIndex(this.mButton,0);
      }
      
      public function setX(param1:int) : void
      {
         this.mButton.x = param1;
      }
      
      protected function mouseUp(param1:MouseEvent) : void
      {
         if(!this.mEnabled)
         {
            return;
         }
         this.mButton.gotoAndStop(BUTTON_FRAME_NAME_UP);
         if(this.mMouseUpFunction != null)
         {
            this.mMouseUpFunction(param1);
         }
      }
      
      public function hideHelper() : void
      {
      }
      
      public function startDrag(param1:Boolean = false, param2:Rectangle = null) : void
      {
         this.mButton.startDrag(param1,param2);
      }
   }
}

