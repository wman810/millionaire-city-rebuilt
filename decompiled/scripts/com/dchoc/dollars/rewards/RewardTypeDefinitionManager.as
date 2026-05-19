package com.dchoc.dollars.rewards
{
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class RewardTypeDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:RewardTypeDefinitionManager;
      
      public function RewardTypeDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: RewardTypeDefinitionManager Error: Instantiation failed: Use RewardTypeDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : RewardTypeDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new RewardTypeDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override protected function sortIsNeeded() : Boolean
      {
         return false;
      }
   }
}

