package com.dchoc.dollars.world.companies
{
   import com.dchoc.dollars.world.World;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateOnIA;
   
   public class CompanyRival extends Company
   {
      
      public function CompanyRival(param1:World, param2:uint)
      {
         super(param1,param2);
      }
      
      public function doAction(param1:int) : void
      {
      }
      
      override public function initItemAfterBuying(param1:ItemObject, param2:Boolean = true) : void
      {
         if(param2)
         {
            param1.changeState(new StateOnIA(param1));
         }
      }
      
      override public function logicUpdate(param1:int) : void
      {
         super.logicUpdate(param1);
      }
   }
}

