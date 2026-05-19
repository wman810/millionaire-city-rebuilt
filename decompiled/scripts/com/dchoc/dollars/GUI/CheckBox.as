package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.utils.Cursor;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class CheckBox extends Sprite
   {
      
      private var mSelected:Boolean;
      
      private var mCheckBox:MovieClip;
      
      public function CheckBox(param1:MovieClip)
      {
         super();
         this.buttonMode = true;
         this.mCheckBox = param1;
         this.mCheckBox.stop();
         this.mSelected = false;
      }
      
      public function resetFrameCheckbox() : void
      {
         this.mCheckBox.gotoAndStop(1);
         this.mSelected = false;
      }
      
      public function start() : void
      {
         addChild(this.mCheckBox);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseClickDown);
      }
      
      public function mouseClickDown(param1:MouseEvent) : void
      {
         if(this.mSelected)
         {
            this.mCheckBox.gotoAndStop(1);
            this.mSelected = false;
         }
         else
         {
            this.mCheckBox.gotoAndStop(2);
            this.mSelected = true;
         }
      }
      
      public function get Checked() : Boolean
      {
         return this.mSelected;
      }
      
      public function set Checked(param1:Boolean) : void
      {
         this.mSelected = param1;
      }
      
      public function getCheckBoxMc() : MovieClip
      {
         return this.mCheckBox;
      }
      
      public function destroy() : void
      {
         this.end();
         this.mCheckBox = null;
      }
      
      public function end() : void
      {
         var _loc1_:Cursor = null;
         if(contains(this.mCheckBox))
         {
            _loc1_ = Dollars.getCurrentCursor();
            if(_loc1_ != null)
            {
               _loc1_.changeCursor(_loc1_.mCurrentCursorID);
            }
            removeChild(this.mCheckBox);
            this.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseClickDown);
         }
      }
   }
}

