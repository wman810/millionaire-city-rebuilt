package com.dchoc.dollars.GUI.events
{
   import com.dchoc.dollars.utils.GUI.events.CustomEventManager;
   
   public class DollarsEventManager extends CustomEventManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:DollarsEventManager;
      
      public static const EVENT_SIGN_CONTRACT_ID:int = 0;
      
      public static const EVENT_COUNT:int = 1;
      
      public function DollarsEventManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: DollarsEventManager Error: Instantiation failed: Use DollarsEventManager.getInstance() instead of new.");
         }
         load();
      }
      
      public static function getInstance() : DollarsEventManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new DollarsEventManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override protected function eventsDoLoad() : void
      {
         mEvents[EVENT_SIGN_CONTRACT_ID] = new EventOnItemObject();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         smInstance = null;
      }
      
      override protected function eventsCount() : int
      {
         return EVENT_COUNT;
      }
   }
}

