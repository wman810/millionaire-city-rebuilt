package com.dchoc.dollars.world.items.states
{
   import com.dchoc.framework.states.StateMachine;
   
   public class StateOnBuiltVisitor extends StateOnBuilt
   {
      
      public function StateOnBuiltVisitor(param1:StateMachine)
      {
         super(param1);
      }
      
      override protected function doIsMouseOverEnabled() : Boolean
      {
         return false;
      }
   }
}

