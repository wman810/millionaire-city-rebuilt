package com.dchoc.dollars.utils.traffic
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   
   public class TrafficAgentManagerDefinition
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:TrafficAgentManagerDefinition;
      
      private var mAgentExpireTime:int;
      
      private var mSpawnAgentsMax:int;
      
      private var mSpawnProbabilityMin:int;
      
      private var mSpawnAskForANewAgentTime:int;
      
      private var mSpawnAgentsLimit:int;
      
      private var mSpawnProbabilityMax:int;
      
      private var mSpawnMinTilesBetweenAgents:int;
      
      private var mSpawnAgentsMin:int;
      
      public function TrafficAgentManagerDefinition()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: TrafficAgentManagerDefinition Error: Instantiation failed: Use TrafficAgentManagerDefinition.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : TrafficAgentManagerDefinition
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new TrafficAgentManagerDefinition();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function get agentExpireTime() : int
      {
         return this.mAgentExpireTime;
      }
      
      public function get spawnProbabilityMax() : int
      {
         return this.mSpawnProbabilityMax;
      }
      
      public function get spawnAgentsLimit() : int
      {
         return this.mSpawnAgentsLimit;
      }
      
      public function get spawnAskForANewAgentTime() : int
      {
         return this.mSpawnAskForANewAgentTime;
      }
      
      public function setPersistence(param1:XML) : void
      {
         this.mSpawnProbabilityMin = param1.@spawnProbabilityMin;
         this.mSpawnProbabilityMax = param1.@spawnProbabilityMax;
         this.mSpawnAgentsMin = param1.@spawnAgentsMin;
         this.mSpawnAgentsMax = param1.@spawnAgentsMax;
         this.mSpawnAgentsLimit = param1.@spawnAgentsLimit;
         this.mSpawnAskForANewAgentTime = param1.@spawnAskForANewAgentTime;
         this.mSpawnMinTilesBetweenAgents = param1.@spawnMinTilesBetweenAgents;
         this.mAgentExpireTime = TimerUtil.minToMs(param1.@agentExpireTime);
      }
      
      private function load() : void
      {
      }
      
      public function get spawnMinTilesBetweenAgents() : int
      {
         return this.mSpawnMinTilesBetweenAgents;
      }
      
      public function get spawnAgentsMin() : int
      {
         return this.mSpawnAgentsMin;
      }
      
      public function set spawnAgentsLimit(param1:int) : void
      {
         this.mSpawnAgentsLimit = param1;
      }
      
      public function get spawnProbabilityMin() : int
      {
         return this.mSpawnProbabilityMin;
      }
      
      public function destroy() : void
      {
      }
      
      public function get spawnAgentsMax() : int
      {
         return this.mSpawnAgentsMax;
      }
      
      public function setBuildParameters() : void
      {
         var _loc1_:int = DollarsGame.getCurrentWorld().map.getRoadTilesCount();
         if(_loc1_ > 0)
         {
            this.mSpawnAgentsMax = this.mSpawnAgentsMax * _loc1_ / 100;
            this.mSpawnAgentsMin = this.mSpawnAgentsMin;
            this.mSpawnAskForANewAgentTime = TimerUtil.secondToMs(30 / this.mSpawnAgentsMin);
         }
      }
   }
}

