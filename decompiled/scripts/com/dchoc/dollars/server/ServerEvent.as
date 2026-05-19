package com.dchoc.dollars.server
{
   import flash.events.Event;
   
   public class ServerEvent extends Event
   {
      
      public static const onLoginResponse:String = "onLoginResponse";
      
      public static const onCommandResponse:String = "onCommandResponse";
      
      public var params:Object;
      
      public function ServerEvent(param1:String, param2:Object)
      {
         super(param1);
         this.params = param2;
      }
   }
}

