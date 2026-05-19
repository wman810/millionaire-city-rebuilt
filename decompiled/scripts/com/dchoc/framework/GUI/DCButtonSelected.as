package com.dchoc.framework.GUI
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class DCButtonSelected extends DCButton
   {
      
      private var mSelected:Boolean;
      
      public function DCButtonSelected(param1:DisplayObjectContainer, param2:MovieClip, param3:int, param4:String = null, param5:Object = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Function = null, param10:Function = null)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10);
         this.mSelected = false;
      }
      
      override protected function mouseOver(param1:MouseEvent) : void
      {
         super.mouseOver(param1);
         if(this.mSelected)
         {
            mButton.gotoAndStop(BUTTON_FRAME_NAME_SELECTED_OVER);
         }
      }
      
      public function unselect() : void
      {
         this.mSelected = false;
         mButton.gotoAndStop(BUTTON_FRAME_NAME_UP);
         var _loc1_:MovieClip = mButton.getChildByName("TabIcon") as MovieClip;
         if(_loc1_)
         {
            _loc1_.gotoAndStop(BUTTON_FRAME_NAME_UP);
         }
      }
      
      override protected function mouseDown(param1:MouseEvent) : void
      {
         super.mouseDown(param1);
         this.select();
      }
      
      override protected function mouseOut(param1:MouseEvent) : void
      {
         super.mouseOut(param1);
         if(this.mSelected)
         {
            mButton.gotoAndStop(BUTTON_FRAME_NAME_SELECTED_UP);
         }
      }
      
      public function select() : void
      {
         this.mSelected = true;
         mButton.gotoAndStop(BUTTON_FRAME_NAME_SELECTED_UP);
         var _loc1_:MovieClip = mButton.getChildByName("TabIcon") as MovieClip;
         if(_loc1_)
         {
            _loc1_.gotoAndStop(BUTTON_FRAME_NAME_SELECTED_UP);
         }
      }
      
      override protected function mouseUp(param1:MouseEvent) : void
      {
         super.mouseUp(param1);
         if(this.mSelected)
         {
            mButton.gotoAndStop(BUTTON_FRAME_NAME_SELECTED_UP);
         }
      }
   }
}

