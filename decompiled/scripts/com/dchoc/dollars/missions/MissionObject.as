package com.dchoc.dollars.missions
{
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.iconLayer.MissionIcon;
   import com.dchoc.dollars.missions.unlock.UnlockMission;
   import com.dchoc.dollars.missions.unlock.UnlockMissionManager;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.rewards.RewardManager;
   import com.dchoc.dollars.utils.poll.PollEvent;
   import com.dchoc.dollars.utils.poll.PollManager;
   
   public class MissionObject
   {
      
      public static const HEURISTIC_STATE_WEIGHT:int = 100000000;
      
      public static const STATE_LOCKED:uint = 0;
      
      public static const STATE_UNLOCKED:uint = 1;
      
      public static const STATE_REACHED:uint = 2;
      
      public static const STATE_GIVEN:uint = 3;
      
      public static const STATE_COUNT:uint = 4;
      
      private var mIcon:MissionIcon;
      
      private var mChanged:Boolean;
      
      private var mMissionDefinition:MissionDefinition;
      
      private var mUnlockMissionID:int;
      
      private var mHeuristic:int;
      
      private var mState:uint;
      
      private var mIsNew:Boolean;
      
      private var mOldState:int;
      
      private var mUnlockMission:UnlockMission;
      
      private var mAlertID:int;
      
      private var mNewState:int;
      
      private var mEuristicOld:int;
      
      public function MissionObject(param1:MissionDefinition, param2:uint = 0)
      {
         var _loc3_:PollEvent = null;
         super();
         this.mMissionDefinition = param1;
         if(this.mMissionDefinition.hasTrigger())
         {
            _loc3_ = PollManager.getInstance().getEvent(this.mMissionDefinition.getEventSku());
            if(_loc3_ == null || this.mMissionDefinition.getCheckCondition())
            {
               _loc3_ = new PollEvent(this.mMissionDefinition.eventType,this.mMissionDefinition.eventParameter,this.mMissionDefinition.eventCondition);
               PollManager.getInstance().addEvent(_loc3_);
            }
         }
         this.mUnlockMission = UnlockMissionManager.getInstance().getUnlockMission(this.mMissionDefinition);
         this.mHeuristic = 0;
         this.mEuristicOld = 0;
         this.mIsNew = false;
         this.mChanged = false;
         this.changeState(param2);
         this.mOldState = param2;
         this.mAlertID = -1;
         this.mIcon = null;
      }
      
      public function setUnlockMissionID(param1:int) : void
      {
         this.mUnlockMissionID = param1;
      }
      
      public function get heuristic() : int
      {
         return this.mHeuristic;
      }
      
      public function getUnlockMissionID() : int
      {
         return this.mUnlockMissionID;
      }
      
      public function get state() : uint
      {
         return this.mState;
      }
      
      public function hasBeenReached() : Boolean
      {
         return this.mState >= MissionObject.STATE_REACHED;
      }
      
      public function set newState(param1:uint) : void
      {
         this.mNewState = param1;
      }
      
      public function getReward() : Reward
      {
         return RewardManager.getInstance().getReward(this.mMissionDefinition.getRewards());
      }
      
      public function getProgressAsString() : String
      {
         var _loc2_:int = 0;
         var _loc1_:String = "";
         if(this.mMissionDefinition.showProgress())
         {
            _loc2_ = this.mMissionDefinition.eventAmount < 2 ? int(this.mMissionDefinition.eventCondition) : int(this.mMissionDefinition.eventAmount);
            _loc1_ = this.getProgressSoFar() + "/" + _loc2_;
         }
         return _loc1_;
      }
      
      public function get unlockMission() : UnlockMission
      {
         return this.mUnlockMission;
      }
      
      public function get oldState() : uint
      {
         return this.mOldState;
      }
      
      public function isNew() : Boolean
      {
         return this.mIsNew;
      }
      
      public function getProgressAsPercentage() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(this.mMissionDefinition.showProgress())
         {
            _loc2_ = this.mMissionDefinition.eventAmount < 2 ? int(this.mMissionDefinition.eventCondition) : int(this.mMissionDefinition.eventAmount);
            _loc1_ = Math.ceil(this.getProgressSoFar() * 100 / _loc2_);
         }
         else if(this.hasBeenReached())
         {
            _loc1_ = 100;
         }
         return _loc1_;
      }
      
      public function setAlertID(param1:int) : void
      {
         if(this.mAlertID != ToolsBar.BOSS_ALERT_MISSION_REACHED)
         {
            this.mAlertID = param1;
         }
      }
      
      public function getProgressSoFar() : int
      {
         var _loc2_:PollEvent = null;
         var _loc3_:int = 0;
         var _loc1_:int = -1;
         if(this.mMissionDefinition.showProgress())
         {
            _loc2_ = PollManager.getInstance().getEvent(this.mMissionDefinition.getEventSku());
            if(_loc2_ != null)
            {
               _loc3_ = _loc2_.getIdByCondition(this.mMissionDefinition.eventCondition);
               _loc1_ = int(_loc2_.getProgress(_loc3_));
            }
         }
         return _loc1_;
      }
      
      public function applyReward() : void
      {
         RewardManager.getInstance().getReward(this.mMissionDefinition.getRewards()).apply();
         this.changeState(STATE_GIVEN);
         MissionObjectManager.getInstance().changeStateMissionsApplyMission(this,this.oldState,this.newState);
      }
      
      public function getAlertID() : int
      {
         return this.mAlertID;
      }
      
      private function calculateHeuristic() : void
      {
         this.mHeuristic = MissionObject.HEURISTIC_STATE_WEIGHT;
         switch(this.mState)
         {
            case STATE_LOCKED:
               this.mHeuristic *= STATE_COUNT;
               break;
            default:
               this.mHeuristic *= this.mState;
         }
         var _loc1_:int = int(this.getProgressAsPercentage() * 99 / 100);
         this.mHeuristic += (99 - _loc1_) * 1000000;
         this.mHeuristic += parseInt(this.missionDefinition.sku);
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:PollEvent = null;
         var _loc4_:int = 0;
         switch(this.mState)
         {
            case STATE_LOCKED:
               if(this.checkUnlock())
               {
                  this.changeState(STATE_UNLOCKED);
               }
               break;
            case STATE_UNLOCKED:
               if(this.mMissionDefinition.hasTrigger())
               {
                  _loc2_ = false;
                  if(this.mMissionDefinition.eventParameter == "Friend")
                  {
                     _loc2_ = true;
                  }
                  else
                  {
                     _loc3_ = PollManager.getInstance().getEvent(this.mMissionDefinition.getEventSku());
                     _loc4_ = _loc3_.getIdByCondition(this.mMissionDefinition.eventCondition);
                     _loc2_ = _loc3_.getCount(_loc4_) >= this.mMissionDefinition.eventAmount;
                  }
                  if(_loc2_)
                  {
                     if(Config.DEBUG_MISSIONS)
                     {
                        trace();
                        trace("===========================================");
                        trace("MISSION_OBJECT.logicUpdate : " + this.mMissionDefinition.getEventSku() + ", " + this.mMissionDefinition.sku + " has been REACHED");
                        trace("===========================================");
                        trace();
                     }
                     this.changeState(STATE_REACHED);
                  }
               }
         }
         this.calculateHeuristic();
      }
      
      public function hasChanged() : Boolean
      {
         var _loc1_:Boolean = this.mChanged;
         this.mChanged = false;
         return _loc1_;
      }
      
      public function needsToBeChecked(param1:int) : Boolean
      {
         var _loc2_:Boolean = true;
         if(param1 == DollarsGame.ROLE_VISITOR)
         {
            _loc2_ = false;
         }
         return _loc2_;
      }
      
      public function changeState(param1:uint) : void
      {
         if(param1 != this.mState)
         {
            MissionObjectManager.getInstance().changeStateMissionsAddChange(this,this.mState,param1);
         }
         switch(this.mState)
         {
            case STATE_LOCKED:
         }
         this.mState = param1;
         switch(this.mState)
         {
            case STATE_LOCKED:
               if(!this.checkUnlock())
               {
                  this.mAlertID = -1;
               }
               break;
            case STATE_UNLOCKED:
               this.mIsNew = true;
               this.mChanged = true;
               this.mAlertID = ToolsBar.BOSS_ALERT_NEW_MISSION;
               break;
            case STATE_REACHED:
               this.mAlertID = -1;
               if(this.mIcon != null)
               {
                  this.mIcon.removeLabel();
                  this.mIcon.blink();
               }
               break;
            case STATE_GIVEN:
               this.mAlertID = -1;
         }
         this.calculateHeuristic();
      }
      
      public function get newState() : uint
      {
         return this.mNewState;
      }
      
      public function set oldState(param1:uint) : void
      {
         this.mOldState = param1;
      }
      
      public function heuristicChanged() : Boolean
      {
         var _loc1_:Boolean = this.mHeuristic != this.mEuristicOld;
         this.mEuristicOld = this.mHeuristic;
         return _loc1_;
      }
      
      private function checkUnlock() : Boolean
      {
         var _loc1_:Boolean = this.mUnlockMission == null || this.mUnlockMission.checkUnlock();
         if(this.mMissionDefinition.eventParameter == "Friend")
         {
            _loc1_ = false;
         }
         return _loc1_;
      }
      
      public function set icon(param1:MissionIcon) : void
      {
         this.mIcon = param1;
      }
      
      public function removeFlagNew() : void
      {
         this.mIsNew = false;
      }
      
      public function destroy() : void
      {
      }
      
      public function get missionDefinition() : MissionDefinition
      {
         return this.mMissionDefinition;
      }
   }
}

