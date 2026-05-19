package com.dchoc.dollars.invests
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.rewards.Reward;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.definitions.DefinitionManager;
   
   public class InvestDefinitionManager extends DefinitionManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:InvestDefinitionManager;
      
      public function InvestDefinitionManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: InvestDefinitionManager Error: Instantiation failed: Use InvestDefinitionManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : InvestDefinitionManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new InvestDefinitionManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function giveReward() : void
      {
         var _loc2_:Reward = null;
         var _loc1_:InvestDefinition = this.getInvestDefinition();
         if(_loc1_ != null)
         {
            _loc2_ = _loc1_.getReward();
            _loc2_.apply();
            DollarsGame.getCurrentWorld().getCompanyMine().delayedPaymentPay();
         }
      }
      
      override protected function sortIsNeeded() : Boolean
      {
         return false;
      }
      
      public function getInvestDefinition() : InvestDefinition
      {
         var _loc1_:InvestDefinition = getDefinitions()[0] as InvestDefinition;
         if(_loc1_ == null && Config.DEBUG_MODE)
         {
            Debug.trace("!!!!!!!!ASSERT InvestDefinitionManager.getInvestDefinition() method: No invests available");
         }
         return _loc1_;
      }
   }
}

