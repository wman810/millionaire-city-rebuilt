package com.dchoc.dollars.invests
{
   import com.dchoc.dollars.model.rules.RulesFacade;
   
   public class InvestObject
   {
      
      public static const STATE_WAITING:int = 0;
      
      public static const STATE_RUNNING:int = 1;
      
      public static const STATE_DONE:int = 2;
      
      public static const STATE_DONE_CLAIMED:int = 4;
      
      public static const STATE_EXPIRED:int = 3;
      
      private static const STATE_NONE:int = 5;
      
      public static const STATE_COUNT:int = STATE_NONE;
      
      private static const STATE_TO_STRING:Array = ["STATE_WAITING","STATE_RUNNING","STATE_DONE","STATE_DONE_CLAIMED","STATE_EXPIRED","STATE_NONE"];
      
      private var mCompanyValue:int;
      
      private var mTimeLeft:int;
      
      private var mUserId:int;
      
      private var mState:int;
      
      private var mRemindTimeLeft:int;
      
      private var mExtId:String;
      
      public function InvestObject(param1:int = 0)
      {
         super();
         this.mState = param1;
         this.changeState(this.mState);
      }
      
      public function remind() : void
      {
         if(this.mState == STATE_WAITING)
         {
            this.mRemindTimeLeft = RulesFacade.getInstance().socialInvestRemindTime();
            trace("############# INVESTMENTS: add REMIND investment server call in InvestObject.remind() method");
         }
         else
         {
            this.mRemindTimeLeft = RulesFacade.getInstance().socialInvestAskForSpeedTime();
            trace("############# INVESTMENTS: add ASK FOR SPEED investment server call in InvestObject.remind() method");
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         if(this.needsToUpdateRemindTimeLeft())
         {
            this.mRemindTimeLeft -= param1;
            if(this.mRemindTimeLeft < 0)
            {
               this.mRemindTimeLeft = 0;
            }
         }
      }
      
      public function getRemindTimeLeft() : int
      {
         return this.mRemindTimeLeft;
      }
      
      public function isClaimed() : Boolean
      {
         return this.mState == STATE_DONE_CLAIMED;
      }
      
      public function setUserId(param1:int) : void
      {
         this.mUserId = param1;
      }
      
      public function changeState(param1:int) : void
      {
         this.mState = param1;
      }
      
      public function setExtId(param1:String) : void
      {
         this.mExtId = param1;
      }
      
      public function setRemindTimeLeft(param1:int) : void
      {
         this.mRemindTimeLeft = param1;
      }
      
      public function setStatePersistence(param1:int) : void
      {
         var _loc2_:int = STATE_WAITING;
         if(param1 == -1)
         {
            _loc2_ = STATE_EXPIRED;
         }
         else if(param1 == 2)
         {
            _loc2_ = STATE_RUNNING;
         }
         else if(param1 == 3)
         {
            _loc2_ = STATE_DONE;
         }
         else if(param1 == 10)
         {
            _loc2_ = STATE_DONE_CLAIMED;
         }
         this.changeState(_loc2_);
      }
      
      public function setClaimed(param1:Boolean) : void
      {
         if(param1)
         {
            this.changeState(STATE_DONE_CLAIMED);
         }
      }
      
      private function needsToUpdateRemindTimeLeft() : Boolean
      {
         return this.mRemindTimeLeft > 0 && (this.mState == STATE_WAITING || this.mState == STATE_RUNNING);
      }
      
      public function getState() : int
      {
         return this.mState;
      }
      
      public function isSuccesfully() : Boolean
      {
         var _loc1_:InvestDefinition = InvestDefinitionManager.getInstance().getInvestDefinition();
         return this.isDoable() && _loc1_ != null && this.mCompanyValue >= _loc1_.target;
      }
      
      public function getCompanyValue() : int
      {
         return this.mCompanyValue;
      }
      
      public function getTimeLeft() : int
      {
         return this.mTimeLeft;
      }
      
      public function traceContent() : void
      {
         trace("extId = " + this.mExtId + " userId = " + this.mUserId + " mState = " + STATE_TO_STRING[this.mState] + " mTimeLeft = " + this.mTimeLeft + " mCompanyValue = " + this.mCompanyValue);
      }
      
      public function getExtId() : String
      {
         return this.mExtId;
      }
      
      public function setCompanyValue(param1:int) : void
      {
         this.mCompanyValue = param1;
      }
      
      public function destroy() : void
      {
      }
      
      public function isCancellable() : Boolean
      {
         return this.mState == STATE_WAITING || this.mState == STATE_EXPIRED;
      }
      
      public function getUserId() : int
      {
         return this.mUserId;
      }
      
      public function setTimeLeft(param1:int) : void
      {
         this.mTimeLeft = param1;
      }
      
      public function isDoable() : Boolean
      {
         return this.mState == STATE_DONE;
      }
   }
}

