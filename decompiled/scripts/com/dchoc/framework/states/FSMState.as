package com.dchoc.framework.states
{
   import com.dchoc.dollars.utils.Cursor;
   import flash.display.Sprite;
   
   public class FSMState
   {
      
      public var mRainClip2:Sprite;
      
      private var mStateMachine:StateMachine;
      
      public var mMessageClip:Sprite;
      
      private var mUseCursor:Boolean;
      
      public var mRainClip:Sprite;
      
      public var mCursorClip:Sprite;
      
      private var mCursor:Cursor;
      
      private var mUseClips:Boolean;
      
      public var mGameClip:Sprite;
      
      public var mPopupClip:Sprite;
      
      public var mMainClip:Sprite;
      
      public function FSMState(param1:StateMachine, param2:Boolean = false, param3:Boolean = false)
      {
         super();
         this.mStateMachine = param1;
         this.mMainClip = this.mStateMachine.getMainClip();
         if(param2 && this.mMainClip != null)
         {
            this.mCursorClip = new Sprite();
            if(this.mGameClip == null)
            {
               this.mGameClip = new Sprite();
            }
            if(this.mPopupClip == null)
            {
               this.mPopupClip = new Sprite();
            }
            if(this.mMessageClip == null)
            {
               this.mMessageClip = new Sprite();
               this.mMessageClip.mouseChildren = false;
               this.mMessageClip.mouseEnabled = false;
            }
            if(this.mRainClip == null)
            {
               this.mRainClip = new Sprite();
               this.mRainClip.mouseChildren = false;
               this.mRainClip.mouseEnabled = false;
            }
            if(this.mRainClip2 == null)
            {
               this.mRainClip2 = new Sprite();
               this.mRainClip2.mouseChildren = false;
               this.mRainClip2.mouseEnabled = false;
            }
         }
         this.mUseCursor = param3;
         this.mUseClips = param2;
      }
      
      public function show(param1:Boolean = true) : void
      {
         if(this.mUseClips)
         {
            this.mMainClip.addChild(this.mGameClip);
            this.mMainClip.addChild(this.mRainClip);
            this.mMainClip.addChild(this.mPopupClip);
            this.mMainClip.addChild(this.mRainClip2);
            this.mMainClip.addChild(this.mMessageClip);
            this.mMainClip.addChild(this.mCursorClip);
         }
         if(this.mUseCursor && this.mCursor != null)
         {
            this.mCursorClip.addChild(this.mCursor);
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
      }
      
      public function hide(param1:Boolean = true) : void
      {
         if(this.mUseCursor && this.mCursor != null)
         {
            this.mCursorClip.removeChild(this.mCursor);
         }
         if(this.mUseClips && this.mMainClip.contains(this.mGameClip))
         {
            this.mMainClip.removeChild(this.mGameClip);
            this.mMainClip.removeChild(this.mRainClip);
            if(param1)
            {
               this.mMainClip.removeChild(this.mPopupClip);
            }
            this.mMainClip.removeChild(this.mRainClip2);
            this.mMainClip.removeChild(this.mMessageClip);
            this.mMainClip.removeChild(this.mCursorClip);
         }
      }
      
      public function doEnterFirstTime() : void
      {
      }
      
      public function enter(param1:Boolean = true) : void
      {
         if(this.mUseCursor)
         {
            this.mCursor = new Cursor();
            this.mCursor.start();
         }
         this.show();
      }
      
      public function exit() : void
      {
         this.hide();
         if(this.mUseCursor && this.mCursor != null)
         {
            this.mCursor.destroy();
            this.mCursor = null;
         }
      }
      
      public function resume() : void
      {
      }
      
      public function getCurrentCursor() : Cursor
      {
         return this.mCursor;
      }
      
      public function destroy() : void
      {
         this.exit();
         if(this.mMainClip != null)
         {
            this.mCursorClip = null;
         }
      }
      
      public function getStateMachine() : StateMachine
      {
         return this.mStateMachine;
      }
      
      public function suspend() : void
      {
      }
   }
}

