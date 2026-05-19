package com.dchoc.dollars.utils.poll
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionDefinition;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   
   public class PollEvent
   {
      
      private var mProgress:int;
      
      private var mConditions:Array;
      
      private var mEventType:String;
      
      private var mCheckCondition:Boolean;
      
      private var mCounts:Array;
      
      private var mSku:String;
      
      private var mProgressSid:String;
      
      private var mEventParameter:String;
      
      public function PollEvent(param1:String, param2:String, param3:int)
      {
         super();
         this.mEventType = param1;
         this.mEventParameter = param2;
         this.mSku = this.mEventType + this.mEventParameter;
         this.mCounts = new Array();
         this.mCounts.push(0);
         this.mConditions = new Array();
         this.mConditions.push(param3);
         this.mProgress = 0;
         this.mCheckCondition = param3 > MissionDefinition.NO_CONDITION;
      }
      
      public function getIdByCondition(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(this.mCheckCondition)
         {
            _loc3_ = int(this.mConditions.length);
            while(_loc2_ < _loc3_ && this.mConditions[_loc2_] != param1)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function needsToBeChecked() : Boolean
      {
         var _loc2_:Role = null;
         var _loc3_:Boolean = false;
         var _loc4_:* = 0;
         var _loc1_:Boolean = PollManager.getInstance().getEnabled();
         if(_loc1_)
         {
            _loc2_ = DollarsGame.getCurrentRole();
            _loc3_ = _loc2_ != null && _loc2_.needsToCheckPollEvent(this.mEventType);
            if(_loc3_)
            {
               if(this.mCheckCondition)
               {
                  _loc1_ = false;
                  _loc4_ = int(this.mCounts.length - 1);
                  while(_loc4_ > -1 && !_loc1_)
                  {
                     _loc1_ = this.mCounts[_loc4_] == 0;
                     _loc4_--;
                  }
               }
            }
            else
            {
               _loc1_ = false;
            }
         }
         return _loc1_;
      }
      
      public function setCount(param1:uint, param2:int = 0) : void
      {
         this.mCounts[param2] = param1;
      }
      
      public function getCount(param1:int = 0) : uint
      {
         return this.mCounts[param1];
      }
      
      public function get sku() : String
      {
         return this.mSku;
      }
      
      public function register(param1:int = 0) : void
      {
         this.mProgress = 0;
         ++this.mCounts[param1];
         if(this.mCheckCondition)
         {
            UserDataFacade.getInstance().updatePollManager("update",{
               "type":this.mEventType,
               "parameter":this.mEventParameter,
               "value":this.getProgressAsString()
            },PollManager.getInstance().getPersistence());
         }
         else
         {
            UserDataFacade.getInstance().updatePollManager("add",{
               "type":this.mEventType,
               "parameter":this.mEventParameter
            },PollManager.getInstance().getPersistence());
         }
      }
      
      public function needsToRegisterPersistence() : Boolean
      {
         return this.mCounts[0] > 0;
      }
      
      public function getCondition(param1:int = 0) : int
      {
         return this.mConditions[param1];
      }
      
      private function getProgressAsString() : String
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         if(this.mCheckCondition)
         {
            _loc2_ = int(this.mCounts.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_ && this.mCounts[_loc3_] > 0)
            {
               _loc3_++;
            }
            _loc1_ = _loc3_;
         }
         else
         {
            _loc1_ += this.mCounts[0];
         }
         return _loc1_ + "";
      }
      
      public function getCheckCondition() : Boolean
      {
         return this.mCheckCondition;
      }
      
      public function getProgress(param1:int) : uint
      {
         var _loc2_:int = int(this.getCount(param1));
         if(this.mProgress > 0)
         {
            _loc2_ = this.mProgress;
         }
         return _loc2_;
      }
      
      public function getPersistenceAsString() : String
      {
         return this.sku + "/" + this.getProgressAsString();
      }
      
      public function build(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = parseInt(param1);
         if(this.mCheckCondition)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this.mCounts[_loc3_] = 1;
               _loc3_++;
            }
         }
         else
         {
            this.mCounts[0] = _loc2_;
         }
      }
      
      public function setCondition(param1:int, param2:int = 0) : void
      {
         this.mConditions[param2] = param1;
      }
      
      public function checkCondition(param1:int, param2:String = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.mCheckCondition)
         {
            _loc3_ = int(this.mConditions.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(this.mCounts[_loc4_] == 0)
               {
                  if(param2 != null && param2 == this.mProgressSid)
                  {
                     this.mProgress = param1;
                  }
                  if(param1 >= this.mConditions[_loc4_])
                  {
                     this.register(_loc4_);
                  }
                  else if(param1 > this.mProgress)
                  {
                     this.mProgress = param1;
                     this.mProgressSid = param2;
                  }
               }
               _loc4_++;
            }
         }
      }
      
      public function addEvent(param1:PollEvent) : void
      {
         this.mConditions.push(param1.getCondition());
         this.mCounts.push(param1.getCount());
      }
      
      public function destroy() : void
      {
         this.mConditions = null;
         this.mCounts = null;
      }
   }
}

