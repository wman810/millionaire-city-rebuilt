package com.dchoc.dollars.GUI.hud
{
   import com.dchoc.dollars.utils.Cursor;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   
   public class Plot extends Sprite
   {
      
      public static const TYPE_LOCKED:int = 0;
      
      public static const TYPE_NORMAL:int = 1;
      
      public static const TYPE_FULL:int = 2;
      
      private var mState:int;
      
      private var mPlot:MovieClip;
      
      public function Plot(param1:MovieClip)
      {
         super();
         mouseChildren = false;
         this.mPlot = param1;
         this.mPlot.stop();
         addChild(this.mPlot);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         buttonMode = true;
      }
      
      public function changeState(param1:int) : void
      {
         this.mState = param1;
         if(this.mState == TYPE_LOCKED)
         {
            this.mPlot.visible = true;
            this.mPlot.gotoAndStop("Locked");
         }
         else if(this.mState == TYPE_FULL)
         {
            this.setFull();
         }
         else
         {
            this.unselect();
         }
      }
      
      public function setFull() : void
      {
         this.mPlot.gotoAndStop("Full");
         this.mPlot.visible = true;
      }
      
      public function unselect() : void
      {
         this.mPlot.gotoAndStop("empty");
      }
      
      public function get state() : int
      {
         return this.mState;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this.mState == TYPE_NORMAL)
         {
            this.select();
            Mouse.hide();
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
         }
      }
      
      public function select() : void
      {
         this.mPlot.gotoAndStop("Selected");
         this.mPlot.visible = true;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.mState == TYPE_NORMAL)
         {
            this.unselect();
            Mouse.show();
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
         }
      }
   }
}

