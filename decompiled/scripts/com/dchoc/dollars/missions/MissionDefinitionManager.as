package com.dchoc.dollars.missions
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class MissionDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:MissionDefinitionManager;
      
      public function MissionDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: MissionDefinitionManager Error: Instantiation failed: Use MissionDefinitionManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : MissionDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new MissionDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function reload() : void
      {
         var _loc3_:int = 0;
         var _loc4_:MissionDefinition = null;
         var _loc1_:Array = null;
         var _loc2_:int = DollarsGame.getProfile().missionAltRewardGet();
         if(_loc2_ > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < getTypeCount())
            {
               _loc1_ = getDefinitions(_loc3_);
               for each(_loc4_ in _loc1_)
               {
                  if(_loc4_.getRewardTypeABTest(_loc2_) != null && _loc4_.getRewardTypeABTest(_loc2_) != "" && _loc4_.getRewardAmountABTest(_loc2_) != null && _loc4_.getRewardAmountABTest(_loc2_) != "")
                  {
                     _loc4_.setRewardType(_loc4_.getRewardTypeABTest(_loc2_));
                     _loc4_.setRewardAmount(_loc4_.getRewardAmountABTest(_loc2_));
                     _loc4_.parseRewards();
                  }
               }
               _loc3_++;
            }
         }
      }
      
      override protected function sortIsNeeded() : Boolean
      {
         return false;
      }
      
      override public function load(param1:String = "") : void
      {
         super.load(Config.getRoot() + ModelConfig.DIR_MISSIONS);
      }
   }
}

