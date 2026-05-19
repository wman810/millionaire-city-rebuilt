package com.dchoc.dollars.world.companies
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.world.World;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateItemObject;
   import com.dchoc.dollars.world.items.states.StateOnBuilt;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   
   public class CompanyMine extends Company
   {
      
      public function CompanyMine(param1:World, param2:uint)
      {
         super(param1,param2);
      }
      
      public static function getPersistenceDefaultCompany() : XML
      {
         var _loc1_:XML = <Company sid={DollarsGame.smCompanySid} whose={Company.WHOSE_MINE} HQLevel={0} exp={0} DCCoins={1000000} workers={0}/>;
         ++DollarsGame.smCompanySid;
         return _loc1_;
      }
      
      override public function showsIncomeBar() : Boolean
      {
         return true;
      }
      
      override public function initItemAfterBuying(param1:ItemObject, param2:Boolean = true) : void
      {
         var _loc3_:StateItemObject = null;
         if(param2)
         {
            if(param1.itemDefinition.type == ItemDefinition.TYPE_WONDERS_ID)
            {
               _loc3_ = new StateOnBuilt(param1);
            }
            else
            {
               _loc3_ = new StateOnRent(param1);
            }
            param1.changeState(_loc3_);
         }
         DollarsGame.getProfile().companyValue = DollarsGame.getProfile().companyValue + param1.getCompanyValue();
      }
      
      override public function showsNotificationConstructionEnd() : Boolean
      {
         return true;
      }
      
      override public function showsNotificationIncome() : Boolean
      {
         return true;
      }
      
      override public function showsConstructionBar() : Boolean
      {
         return true;
      }
      
      override public function isMine() : Boolean
      {
         return true;
      }
   }
}

