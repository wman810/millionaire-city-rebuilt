package com.dchoc.dollars.world.items.states
{
   import com.dchoc.framework.states.StateMachine;
   
   public class StateOnHireCrewVisitor extends StateOnHireCrew
   {
      
      public function StateOnHireCrewVisitor(param1:StateMachine)
      {
         super(param1);
      }
      
      override public function isTimerCountDownEnabled() : Boolean
      {
         return false;
      }
      
      override protected function doIsMouseOverEnabled() : Boolean
      {
         return false;
      }
   }
}

