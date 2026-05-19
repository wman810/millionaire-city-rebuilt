package com.dchoc.dollars.missions.unlock
{
   import com.dchoc.dollars.flow.DollarsGame;
   
   public class UnlockMissionByLevel extends UnlockMission
   {
      
      private var mLevel:int;
      
      public function UnlockMissionByLevel(param1:int)
      {
         super();
         this.mLevel = param1;
      }
      
      override public function checkUnlock() : Boolean
      {
         var _loc1_:int = int(DollarsGame.getProfile().level);
         return _loc1_ >= this.mLevel;
      }
   }
}

