package com.dchoc.dollars.world.items.states
{
   import com.dchoc.framework.states.StateMachine;
   
   public class StateOnConstructionVisitor extends StateOnConstruction
   {
      
      public function StateOnConstructionVisitor(param1:StateMachine)
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

