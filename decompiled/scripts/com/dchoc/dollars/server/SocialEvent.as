package com.dchoc.dollars.server
{
   import flash.events.Event;
   
   public class SocialEvent extends Event
   {
      
      public static const onCommandResponse:String = "onCommandResponse";
      
      public var params:Object;
      
      public function SocialEvent(param1:String, param2:Object)
      {
         super(param1);
         this.params = param2;
      }
   }
}

