package com.dchoc.dollars.utils.abtest
{
   public class ABTestManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:ABTestManager;
      
      public static const CREW_INVITES_CHANGE:String = "mc_crew_invites_number";
      
      public static const CHANGE_FBC_PRICES:String = "mc_change_fbc_prices";
      
      public static const MISSION_ALT_REWARDS_1:String = "mc_exp_new_mission_alt_rewards_1";
      
      public static const MISSION_ALT_REWARDS_2:String = "mc_exp_new_mission_alt_rewards_2";
      
      public static const ALT_MISSIONS:String = "mc_exp_new_alt_missions";
      
      public static const INVESTMENT_REMINDER:String = "mc_exp_all_investment_reminder";
      
      public static const ENABLE_GOLD_CURRENCY:String = "mc_exp_new_gold_currency";
      
      private var mABTestGroups:Array;
      
      public function ABTestManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: ABTestManager Error: Instantiation failed: Use ABTestManager.getInstance() instead of new.");
         }
         this.mABTestGroups = new Array();
      }
      
      public static function getInstance() : ABTestManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new ABTestManager();
            smAllowInstantiation = false;
         }
         return ABTestManager.smInstance;
      }
      
      private function isEnabled(param1:String) : Boolean
      {
         return this.mABTestGroups[param1] != null;
      }
      
      public function destroy() : void
      {
         this.mABTestGroups = null;
      }
      
      public function addABTestGroup(param1:String, param2:XML) : void
      {
         this.mABTestGroups[param1] = param2;
      }
      
      public function isABTest(param1:String) : Boolean
      {
         return this.isEnabled(param1);
      }
      
      public function getABTestValue(param1:String, param2:String) : String
      {
         if(this.isEnabled(param1))
         {
            return this.mABTestGroups[param1]["@" + param2];
         }
         return null;
      }
   }
}

