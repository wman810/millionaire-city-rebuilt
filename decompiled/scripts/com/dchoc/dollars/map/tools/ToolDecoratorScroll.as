package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ToolDecoratorScroll extends ToolDecorator
   {
      
      private static const CURSOR_CHANGE_TIME:int = 1;
      
      public static const SCROLL_OFF_TO_BE_ENABLED:int = 6;
      
      private var mCursorBackID:int;
      
      private var mScrollEnabled:Boolean;
      
      private var mChangeCursorTimer:int;
      
      private var mIsOut:Boolean;
      
      private var mMouseDownX:Number;
      
      private var mMouseDownY:Number;
      
      private var mCheckMovement:Boolean;
      
      public function ToolDecoratorScroll(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
      }
      
      override public function reportMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         if(this.mCheckMovement)
         {
            _loc2_ = mMap.mouseX - this.mMouseDownX;
            _loc3_ = mMap.mouseY - this.mMouseDownY;
            _loc2_ *= mMap.scaleX;
            _loc3_ *= mMap.scaleY;
            _loc4_ = Math.abs(_loc2_);
            _loc5_ = Math.abs(_loc3_);
            if(!this.mScrollEnabled && (_loc4_ > SCROLL_OFF_TO_BE_ENABLED || _loc5_ > SCROLL_OFF_TO_BE_ENABLED))
            {
               this.enableScroll();
            }
            if(this.mScrollEnabled)
            {
               _loc6_ = Dollars.smStage.stageWidth;
               if(_loc6_ < mMap.width)
               {
                  mMap.x += _loc2_;
                  _loc6_ -= mMap.getMapWidth(true);
                  if(mMap.x < _loc6_)
                  {
                     mMap.x = _loc6_;
                  }
                  else if(mMap.x > mMap.getMarginWidth())
                  {
                     mMap.x = mMap.getMarginWidth();
                  }
               }
               _loc6_ = DollarsGame.getScreenHeight();
               if(mMap.y < 0 || _loc6_ < mMap.getMapHeight(true))
               {
                  mMap.y += _loc3_;
                  if(mMap.y < mMap.getScrollBottomY())
                  {
                     mMap.y = mMap.getScrollBottomY();
                  }
                  else if(mMap.y > mMap.getMarginHeight())
                  {
                     mMap.y = mMap.getMarginHeight();
                  }
               }
               this.mMouseDownX = mMap.mouseX;
               this.mMouseDownY = mMap.mouseY;
            }
         }
         mTool.reportMouseMove(param1);
      }
      
      override public function reportMouseUp(param1:MouseEvent) : void
      {
         if(!this.mScrollEnabled)
         {
            mTool.reportMouseUp(param1);
         }
         this.disableScroll(this.mScrollEnabled);
      }
      
      override public function reportMouseDown(param1:MouseEvent) : void
      {
         if(Tutorial.smTutorialEnd)
         {
            this.mCheckMovement = true;
            this.mMouseDownX = mMap.mouseX;
            this.mMouseDownY = mMap.mouseY;
         }
         mTool.reportMouseDown(param1);
      }
      
      private function disableScroll(param1:Boolean = false) : void
      {
         this.mCheckMovement = false;
         if(param1)
         {
            this.mChangeCursorTimer = CURSOR_CHANGE_TIME;
            Dollars.getCurrentCursor().changeCursor(mTool.getDefaultCursorID());
         }
         if(mTool != null && this.mScrollEnabled)
         {
            mTool.enable(true);
         }
         this.mScrollEnabled = false;
         this.setEnabled(false);
         DollarsGame.getCurrentRole().toolsBar.enableButtons();
         if(Tutorial.smTutorialEnd)
         {
            DollarsGame.getFriendsBar().setEnabled(true);
         }
      }
      
      override public function logicUpdate(param1:int) : void
      {
         var _loc2_:int = 0;
         if(this.mChangeCursorTimer > 0 && false)
         {
            this.mChangeCursorTimer -= param1;
            if(this.mChangeCursorTimer <= 0)
            {
               _loc2_ = getEnabled() ? Cursor.CURSOR_SCROLL_FIST : this.mCursorBackID;
               Dollars.getCurrentCursor().changeCursor(_loc2_);
            }
         }
         super.logicUpdate(param1);
      }
      
      private function reportMouseUpStage(param1:MouseEvent) : void
      {
         if(this.mScrollEnabled && this.mIsOut)
         {
            this.reportMouseUp(param1);
            if(mTool != null)
            {
               mTool.reportMouseOut(param1);
            }
         }
      }
      
      override public function end() : void
      {
         super.end();
         Dollars.smStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.reportMouseMoveStage);
         Dollars.smStage.removeEventListener(MouseEvent.MOUSE_UP,this.reportMouseUpStage);
         mMap.removeEventListener(MouseEvent.MOUSE_UP,this.reportMouseUp);
         this.disableScroll();
      }
      
      private function reportMouseMoveStage(param1:MouseEvent) : void
      {
         if(this.mScrollEnabled && this.mIsOut)
         {
            this.reportMouseMove(param1);
         }
      }
      
      override public function reportMouseOver(param1:MouseEvent, param2:Boolean = false) : void
      {
         if(this.mIsOut && param1 != null)
         {
            this.mIsOut = false;
         }
         super.reportMouseOver(param1,param2);
      }
      
      override public function start(param1:Boolean = false, param2:String = null) : void
      {
         super.start(true,param2);
         Dollars.smStage.addEventListener(MouseEvent.MOUSE_MOVE,this.reportMouseMoveStage);
         Dollars.smStage.addEventListener(Event.MOUSE_LEAVE,this.reportMouseLeaveStage);
         Dollars.smStage.addEventListener(MouseEvent.MOUSE_UP,this.reportMouseUpStage);
         mMap.addEventListener(MouseEvent.MOUSE_UP,this.reportMouseUp);
         this.disableScroll();
      }
      
      private function enableScroll() : void
      {
         this.setEnabled(true);
         this.mScrollEnabled = true;
         this.mChangeCursorTimer = CURSOR_CHANGE_TIME;
         this.mCursorBackID = Dollars.getCurrentCursor().mCurrentCursorID;
         if(mTool != null)
         {
            mTool.disable(true);
         }
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SCROLL_FIST);
         DollarsGame.getCurrentRole().toolsBar.disableButtons(false);
         if(Tutorial.smTutorialEnd)
         {
            DollarsGame.getFriendsBar().setEnabled(false);
         }
      }
      
      private function reportMouseLeaveStage(param1:Event) : void
      {
         if(this.mScrollEnabled)
         {
            this.disableScroll(this.mScrollEnabled);
         }
      }
      
      override public function reportMouseOut(param1:MouseEvent) : void
      {
         this.mIsOut = true;
         if(!this.mScrollEnabled)
         {
            super.reportMouseOut(param1);
         }
      }
      
      override protected function setEnabled(param1:Boolean) : void
      {
         if(!this.mScrollEnabled)
         {
            super.setEnabled(param1);
         }
      }
   }
}

