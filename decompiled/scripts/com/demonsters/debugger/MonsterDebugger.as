package com.demonsters.debugger
{
   import flash.display.DisplayObject;
   
   public class MonsterDebugger
   {
      
      public static var logger:Function;
      
      private static var _enabled:Boolean = true;
      
      private static var _initialized:Boolean = false;
      
      internal static const VERSION:Number = 3;
      
      public function MonsterDebugger()
      {
         super();
      }
      
      public static function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public static function trace(param1:*, param2:*, param3:String = "", param4:String = "", param5:uint = 0, param6:int = 5) : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.trace(param1,param2,param3,param4,param5,param6);
         }
      }
      
      internal static function send(param1:String, param2:Object) : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerConnection.send(param1,param2,false);
         }
      }
      
      public static function log(... rest) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(_initialized && _enabled)
         {
            _loc2_ = [];
            _loc3_ = 0;
            while(_loc3_ < rest.length)
            {
               _loc2_[_loc2_.length] = String(rest[_loc3_]);
               _loc3_++;
            }
            MonsterDebuggerCore.trace("log",_loc2_.join(", "),"","",0,5);
         }
      }
      
      public static function clear() : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.clear();
         }
      }
      
      public static function unregisterPlugin(param1:String) : void
      {
         if(_initialized)
         {
            MonsterDebuggerCore.unregisterPlugin(param1);
         }
      }
      
      public static function set enabled(param1:Boolean) : void
      {
         _enabled = param1;
      }
      
      public static function snapshot(param1:*, param2:DisplayObject, param3:String = "", param4:String = "") : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.snapshot(param1,param2,param3,param4);
         }
      }
      
      public static function inspect(param1:*) : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.inspect(param1);
         }
      }
      
      public static function registerPlugin(param1:Class) : void
      {
         var _loc2_:MonsterDebuggerPlugin = null;
         if(_initialized)
         {
            _loc2_ = new param1();
            MonsterDebuggerCore.registerPlugin(_loc2_.id,_loc2_);
         }
      }
      
      public static function hasPlugin(param1:String) : Boolean
      {
         if(_initialized)
         {
            return MonsterDebuggerCore.hasPlugin(param1);
         }
         return false;
      }
      
      public static function breakpoint(param1:*, param2:String = "breakpoint") : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.breakpoint(param1,param2);
         }
      }
      
      public static function initialize(param1:Object, param2:String = "127.0.0.1", param3:Function = null) : void
      {
         if(!_initialized)
         {
            _initialized = true;
            MonsterDebuggerCore.base = param1;
            MonsterDebuggerCore.initialize();
            MonsterDebuggerConnection.initialize();
            MonsterDebuggerConnection.address = param2;
            MonsterDebuggerConnection.onConnect = param3;
            MonsterDebuggerConnection.connect();
         }
      }
   }
}

