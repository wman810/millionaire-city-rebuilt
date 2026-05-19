package com.dchoc.dollars.GUI.events
{
   import com.dchoc.dollars.utils.GUI.events.CustomEvent;
   import com.dchoc.dollars.world.items.ItemObject;
   
   public class EventOnItemObject extends CustomEvent
   {
      
      public function EventOnItemObject()
      {
         super();
         setMaxSimultaneously(int.MAX_VALUE);
      }
      
      override public function notifyStart(param1:Object) : void
      {
         super.notifyStart(param1);
         var _loc2_:ItemObject = param1 as ItemObject;
         _loc2_.doUIEventWaitingFor();
      }
   }
}

