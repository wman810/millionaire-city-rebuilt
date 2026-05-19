package com.dchoc.dollars.missions.unlock
{
   import com.dchoc.dollars.missions.MissionDefinition;
   import flash.utils.Dictionary;
   
   public class UnlockMissionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:UnlockMissionManager;
      
      private var mCatalogDictionary:Dictionary;
      
      public function UnlockMissionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: UnlockManager Error: Instantiation failed: Use UnlockMissionManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : UnlockMissionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new UnlockMissionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function destroy() : void
      {
         this.mCatalogDictionary = null;
      }
      
      private function load() : void
      {
         if(this.mCatalogDictionary == null)
         {
            this.mCatalogDictionary = new Dictionary();
            this.mCatalogDictionary["sku"] = UnlockMissionBySku;
            this.mCatalogDictionary["level"] = UnlockMissionByLevel;
         }
      }
      
      public function getUnlockMission(param1:MissionDefinition) : UnlockMission
      {
         var _loc2_:UnlockMission = null;
         if(param1.unlockLevel > -1)
         {
            _loc2_ = new UnlockMissionByLevel(param1.unlockLevel);
         }
         else if(param1.unlockSku != "")
         {
            _loc2_ = new UnlockMissionBySku(param1.unlockSku);
         }
         return _loc2_;
      }
   }
}

