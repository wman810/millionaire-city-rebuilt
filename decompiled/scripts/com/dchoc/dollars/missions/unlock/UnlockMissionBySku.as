package com.dchoc.dollars.missions.unlock
{
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   
   public class UnlockMissionBySku extends UnlockMission
   {
      
      private var mSku:String;
      
      private var mMission:MissionObject;
      
      public function UnlockMissionBySku(param1:String)
      {
         super();
         this.mSku = param1;
      }
      
      override public function checkUnlock() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.mMission == null)
         {
            this.mMission = MissionObjectManager.getInstance().getMissionBySku(this.mSku);
         }
         if(this.mMission != null)
         {
            _loc1_ = this.mMission.hasBeenReached();
         }
         return _loc1_;
      }
   }
}

