package com.dchoc.framework.states
{
   import com.dchoc.dollars.utils.Cursor;
   import flash.display.Sprite;
   
   public class StateMachine
   {
      
      protected var mIsSuspended:Boolean;
      
      protected var mCurrentState:FSMState;
      
      private var mPreviousState:FSMState;
      
      private var mMainClip:Sprite;
      
      private var mNextState:FSMState;
      
      public function StateMachine(param1:Sprite)
      {
         super();
         this.mCurrentState = this.mPreviousState = this.mNextState = null;
         this.mMainClip = param1;
      }
      
      public function changeState(param1:FSMState, param2:Boolean = true) : void
      {
         if(this.mCurrentState != null)
         {
            this.mCurrentState.exit();
            this.mPreviousState = this.mCurrentState;
         }
         this.mCurrentState = param1;
         this.mCurrentState.enter(param2);
      }
      
      public function setNextState(param1:FSMState) : void
      {
         this.mNextState = param1;
         this.goToNextState();
      }
      
      public function getMainClip() : Sprite
      {
         return this.mMainClip;
      }
      
      public function logicUpdate(param1:int) : void
      {
         if(this.mCurrentState)
         {
            this.mCurrentState.logicUpdate(param1);
         }
      }
      
      public function setIsSuspended(param1:Boolean) : void
      {
         this.mIsSuspended = param1;
      }
      
      public function set currentState(param1:FSMState) : void
      {
         this.mCurrentState = param1;
      }
      
      public function get isSuspended() : Boolean
      {
         return this.mIsSuspended;
      }
      
      public function resume() : void
      {
         if(this.mIsSuspended)
         {
            this.mIsSuspended = false;
            if(this.mCurrentState != null)
            {
               this.mCurrentState.resume();
            }
         }
      }
      
      public function goToPreviousState() : void
      {
         this.changeState(this.mPreviousState);
      }
      
      public function getCurrentCursor() : Cursor
      {
         return this.mCurrentState.getCurrentCursor();
      }
      
      public function goToNextState() : void
      {
         this.changeState(this.mNextState);
      }
      
      public function suspend() : void
      {
         if(!this.mIsSuspended)
         {
            this.mIsSuspended = true;
            if(this.mCurrentState != null)
            {
               this.mCurrentState.suspend();
            }
         }
      }
      
      public function get currentState() : FSMState
      {
         return this.mCurrentState;
      }
   }
}

