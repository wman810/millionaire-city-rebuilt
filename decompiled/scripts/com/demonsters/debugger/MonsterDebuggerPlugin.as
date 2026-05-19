package com.demonsters.debugger
{
   public class MonsterDebuggerPlugin
   {
      
      private var _id:String;
      
      public function MonsterDebuggerPlugin(param1:String)
      {
         super();
         _id = param1;
      }
      
      protected function send(param1:Object) : void
      {
         MonsterDebugger.send(_id,param1);
      }
      
      public function get id() : String
      {
         return _id;
      }
      
      public function handle(param1:MonsterDebuggerData) : void
      {
      }
   }
}

