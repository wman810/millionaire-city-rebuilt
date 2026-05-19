package com.dchoc.dollars.utils.GUI.events
{
   public class CustomEventManager
   {
      
      private var mWaiters:Array;
      
      protected var mEvents:Array;
      
      public function CustomEventManager()
      {
         super();
         this.load();
      }
      
      protected function eventsDestroy() : void
      {
         var _loc1_:CustomEvent = null;
         if(this.mEvents != null)
         {
            for each(_loc1_ in this.mEvents)
            {
               _loc1_.destroy();
            }
            this.mEvents.splice(0,this.mEvents.length);
            this.mEvents = null;
         }
      }
      
      private function waitersDestroy() : void
      {
         var _loc1_:Array = null;
         if(this.mWaiters != null)
         {
            for each(_loc1_ in this.mWaiters)
            {
               _loc1_.splice(0,_loc1_.length);
               _loc1_ = null;
            }
            this.mWaiters.splice(0,this.mWaiters.length);
            this.mWaiters = null;
         }
      }
      
      protected function eventsDoLoad() : void
      {
      }
      
      protected function load() : void
      {
         this.eventsLoad();
         this.waitersLoad();
      }
      
      public function waitersAddWaiter(param1:Object, param2:int) : void
      {
         var _loc3_:CustomEvent = this.eventsGetEvent(param2);
         if(_loc3_.notifyIsAllowed())
         {
            _loc3_.notifyStart(param1);
         }
         else
         {
            this.mWaiters[param2].push(param1);
         }
      }
      
      protected function eventsCount() : int
      {
         return 0;
      }
      
      private function waitersLoad() : void
      {
         var _loc1_:int = this.eventsCount();
         this.mWaiters = new Array(_loc1_);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this.mWaiters[_loc2_] = new Array();
            _loc2_++;
         }
      }
      
      public function destroy() : void
      {
         this.eventsDestroy();
         this.waitersDestroy();
      }
      
      private function eventsGetEvent(param1:int) : CustomEvent
      {
         return this.mEvents[param1] as CustomEvent;
      }
      
      public function waitersRemoveWaiter(param1:Object, param2:int) : void
      {
         var _loc3_:CustomEvent = this.eventsGetEvent(param2);
         _loc3_.notifyEnd(param1);
         var _loc4_:Array = this.mWaiters[param2] as Array;
         if(_loc4_.length > 0)
         {
            param1 = _loc4_.shift();
            _loc3_.notifyStart(param1);
         }
      }
      
      private function eventsLoad() : void
      {
         this.mEvents = new Array(this.eventsCount());
         this.eventsDoLoad();
      }
   }
}

