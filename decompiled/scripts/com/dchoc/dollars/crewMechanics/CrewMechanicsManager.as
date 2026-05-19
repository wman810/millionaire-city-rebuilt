package com.dchoc.dollars.crewMechanics
{
   public class CrewMechanicsManager
   {
      
      private static var smInstance:CrewMechanicsManager;
      
      private static var smAllowed:Boolean;
      
      private static const JOB_LIST:int = 0;
      
      private static const WORKER_TID:int = 1;
      
      private static const FBC_PRICE:int = 2;
      
      private static const GOLD_PRICE:int = 3;
      
      private var mDefinitions:Array;
      
      public function CrewMechanicsManager()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: StorageManager Error: Instantiation failed: Use StorageManager.getInstance() instead of new.");
         }
         this.mDefinitions = new Array();
      }
      
      public static function getInstance() : CrewMechanicsManager
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new CrewMechanicsManager();
            smAllowed = false;
         }
         return smInstance;
      }
      
      public function getJobsTIDs(param1:String) : Array
      {
         if(this.mDefinitions[param1] != null)
         {
            return this.mDefinitions[param1][CrewMechanicsManager.JOB_LIST];
         }
         return null;
      }
      
      public function getCrewCount(param1:String) : int
      {
         if(this.mDefinitions[param1] != null)
         {
            return this.mDefinitions[param1][CrewMechanicsManager.JOB_LIST].length;
         }
         return 0;
      }
      
      public function getCrewPrice(param1:String, param2:Boolean = false) : int
      {
         if(this.mDefinitions[param1] != null)
         {
            if(param2)
            {
               return this.mDefinitions[param1][CrewMechanicsManager.FBC_PRICE];
            }
            return this.mDefinitions[param1][CrewMechanicsManager.GOLD_PRICE];
         }
         return 0;
      }
      
      public function destroy() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         for each(_loc1_ in this.mDefinitions)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               _loc1_[_loc2_].length = 0;
               _loc2_++;
            }
            _loc1_.length = 0;
         }
         this.mDefinitions.length = 0;
         this.mDefinitions = null;
      }
      
      public function getWorkerTID(param1:String) : String
      {
         if(this.mDefinitions[param1] != null)
         {
            return this.mDefinitions[param1][CrewMechanicsManager.WORKER_TID];
         }
         return null;
      }
      
      public function setJobsTIDs(param1:String, param2:String) : void
      {
         if(this.mDefinitions[param1] != null)
         {
            this.mDefinitions[param1][CrewMechanicsManager.JOB_LIST] = param2.split(",");
         }
      }
      
      public function build(param1:XML) : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc2_:XMLList = param1.Definition;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.@sku;
            this.mDefinitions[_loc4_] = new Array();
            this.mDefinitions[_loc4_][CrewMechanicsManager.JOB_LIST] = String(_loc3_.@jobs).split(",");
            this.mDefinitions[_loc4_][CrewMechanicsManager.WORKER_TID] = _loc3_.@workerTID;
            this.mDefinitions[_loc4_][CrewMechanicsManager.FBC_PRICE] = int(_loc3_.@FBCprice);
            this.mDefinitions[_loc4_][CrewMechanicsManager.GOLD_PRICE] = int(_loc3_.@goldPrice);
         }
      }
   }
}

