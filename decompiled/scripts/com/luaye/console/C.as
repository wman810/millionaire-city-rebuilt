package com.luaye.console
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class C
   {
      
      private static var _console:Console;
      
      private static const ERROR_EXISTS:String = "[CONSOLE] already exists. Will keep using the previously created console. If you want to create a fresh 1, C.remove() first.";
      
      public function C()
      {
         super();
         throw new Error("[CONSOLE] Do not construct class. Please use C.start(mc:DisplayObjectContainer, password:String=\'\')");
      }
      
      public static function fatal(... rest) : void
      {
         if(_console)
         {
            _console.fatal.apply(null,rest);
         }
      }
      
      public static function set remoting(param1:Boolean) : void
      {
         setter("remoting",param1);
      }
      
      public static function error(... rest) : void
      {
         if(_console)
         {
            _console.error.apply(null,rest);
         }
      }
      
      private static function getter(param1:String) : *
      {
         if(_console)
         {
            return _console[param1];
         }
         return null;
      }
      
      public static function set tracingPriority(param1:int) : void
      {
         setter("tracingPriority",param1);
      }
      
      public static function get viewingChannels() : Array
      {
         return getter("viewingChannels") as Array;
      }
      
      public static function inspect(param1:Object, param2:Boolean = true) : void
      {
         if(_console)
         {
            _console.inspect(param1,param2);
         }
      }
      
      public static function get memoryMonitor() : Boolean
      {
         return getter("memoryMonitor") as Boolean;
      }
      
      public static function set viewingChannels(param1:Array) : void
      {
         setter("viewingChannels",param1);
      }
      
      public static function get height() : Number
      {
         return getter("height") as Number;
      }
      
      public static function removeGraph(param1:String, param2:Object = null, param3:String = null) : void
      {
         if(_console)
         {
            _console.removeGraph(param1,param2,param3);
         }
      }
      
      private static function addedToStageHandle(param1:Event) : void
      {
         var _loc2_:DisplayObjectContainer = param1.currentTarget as DisplayObjectContainer;
         _loc2_.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandle);
         if(Boolean(_console) && _console.parent == null)
         {
            _loc2_.stage.addChild(_console);
         }
      }
      
      public static function get viewingChannel() : String
      {
         return getter("viewingChannel") as String;
      }
      
      public static function get paused() : Boolean
      {
         return getter("paused") as Boolean;
      }
      
      public static function get fpsMonitor() : Boolean
      {
         return getter("fpsMonitor") as Boolean;
      }
      
      public static function set memoryMonitor(param1:Boolean) : void
      {
         setter("memoryMonitor",param1);
      }
      
      public static function get maxRepeats() : Number
      {
         return getter("maxRepeats") as Number;
      }
      
      public static function get alwaysOnTop() : Boolean
      {
         return getter("alwaysOnTop") as Boolean;
      }
      
      public static function get quiet() : Boolean
      {
         return getter("quiet") as Boolean;
      }
      
      public static function addGraph(param1:String, param2:Object, param3:String, param4:Number = -1, param5:String = null, param6:Rectangle = null, param7:Boolean = false) : void
      {
         if(_console)
         {
            _console.addGraph(param1,param2,param3,param4,param5,param6,param7);
         }
      }
      
      public static function runCommand(param1:String) : *
      {
         if(_console)
         {
            return _console.runCommand(param1);
         }
         return null;
      }
      
      public static function get enabled() : Boolean
      {
         return getter("enabled") as Boolean;
      }
      
      public static function get traceCall() : Function
      {
         return getter("traceCall") as Function;
      }
      
      public static function log(... rest) : void
      {
         if(_console)
         {
            _console.log.apply(null,rest);
         }
      }
      
      public static function setRollerCaptureKey(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : void
      {
         if(_console)
         {
            _console.setRollerCaptureKey(param1,param2,param3,param4);
         }
      }
      
      public static function get remote() : Boolean
      {
         return getter("remote") as Boolean;
      }
      
      public static function get rulerHidesMouse() : Boolean
      {
         return getter("rulerHidesMouse") as Boolean;
      }
      
      public static function set viewingChannel(param1:String) : void
      {
         setter("viewingChannel",param1);
      }
      
      public static function clear(param1:String = null) : void
      {
         if(_console)
         {
            _console.clear(param1);
         }
      }
      
      public static function set height(param1:Number) : void
      {
         setter("height",param1);
      }
      
      public static function debug(... rest) : void
      {
         if(_console)
         {
            _console.debug.apply(null,rest);
         }
      }
      
      public static function set alwaysOnTop(param1:Boolean) : void
      {
         setter("alwaysOnTop",param1);
      }
      
      public static function get displayRoller() : Boolean
      {
         return getter("displayRoller") as Boolean;
      }
      
      public static function set paused(param1:Boolean) : void
      {
         setter("paused",param1);
      }
      
      public static function start(param1:DisplayObjectContainer, param2:String = "", param3:int = 1) : void
      {
         if(_console)
         {
            trace(ERROR_EXISTS);
         }
         else
         {
            _console = new Console(param2,param3);
            if(param1 != null)
            {
               param1.addChild(_console);
            }
         }
      }
      
      public static function map(param1:DisplayObjectContainer, param2:uint = 0) : void
      {
         if(_console)
         {
            _console.map(param1,param2);
         }
      }
      
      public static function set tracingChannels(param1:Array) : void
      {
         setter("tracingChannels",param1);
      }
      
      public static function ch(param1:*, param2:*, param3:Number = 2, param4:Boolean = false) : void
      {
         if(_console)
         {
            _console.ch(param1,param2,param3,param4);
         }
      }
      
      public static function set maxRepeats(param1:Number) : void
      {
         setter("maxRepeats",param1);
      }
      
      public static function fatalch(param1:*, ... rest) : void
      {
         if(_console)
         {
            _console.fatalch.apply(null,[param1].concat(rest));
         }
      }
      
      public static function warnch(param1:*, ... rest) : void
      {
         if(_console)
         {
            _console.warnch.apply(null,[param1].concat(rest));
         }
      }
      
      public static function errorch(param1:*, ... rest) : void
      {
         if(_console)
         {
            _console.errorch.apply(null,[param1].concat(rest));
         }
      }
      
      public static function set prefixChannelNames(param1:Boolean) : void
      {
         setter("prefixChannelNames",param1);
      }
      
      public static function setPanelArea(param1:String, param2:Rectangle) : void
      {
         if(_console)
         {
            _console.setPanelArea(param1,param2);
         }
      }
      
      public static function set fpsMonitor(param1:Boolean) : void
      {
         setter("fpsMonitor",param1);
      }
      
      public static function get visible() : Boolean
      {
         return getter("visible") as Boolean;
      }
      
      public static function get exists() : Boolean
      {
         return _console ? true : false;
      }
      
      public static function set quiet(param1:Boolean) : void
      {
         setter("quiet",param1);
      }
      
      public static function set commandBase(param1:Object) : void
      {
         setter("commandBase",param1);
      }
      
      public static function get y() : Number
      {
         return getter("y") as Number;
      }
      
      public static function get strongRef() : Boolean
      {
         return getter("strongRef") as Boolean;
      }
      
      private static function setter(param1:String, param2:*) : void
      {
         if(_console)
         {
            _console[param1] = param2;
         }
      }
      
      public static function set enabled(param1:Boolean) : void
      {
         setter("enabled",param1);
      }
      
      public static function get remoting() : Boolean
      {
         return getter("remoting") as Boolean;
      }
      
      public static function set tracing(param1:Boolean) : void
      {
         setter("tracing",param1);
      }
      
      public static function warn(... rest) : void
      {
         if(_console)
         {
            _console.warn.apply(null,rest);
         }
      }
      
      public static function get x() : Number
      {
         return getter("x") as Number;
      }
      
      public static function set filterText(param1:String) : void
      {
         setter("filterText",param1);
      }
      
      public static function remove() : void
      {
         if(_console)
         {
            if(_console.parent != null)
            {
               _console.parent.removeChild(_console);
            }
            _console.destroy();
            _console = null;
         }
      }
      
      public static function set width(param1:Number) : void
      {
         setter("width",param1);
      }
      
      public static function get tracingPriority() : int
      {
         return getter("tracingChannels") as int;
      }
      
      public static function set commandLineAllowed(param1:Boolean) : void
      {
         setter("commandLineAllowed",param1);
      }
      
      public static function set rulerHidesMouse(param1:Boolean) : void
      {
         setter("rulerHidesMouse",param1);
      }
      
      public static function set traceCall(param1:Function) : void
      {
         setter("traceCall",param1);
      }
      
      public static function set displayRoller(param1:Boolean) : void
      {
         setter("displayRoller",param1);
      }
      
      public static function infoch(param1:*, ... rest) : void
      {
         if(_console)
         {
            _console.infoch.apply(null,[param1].concat(rest));
         }
      }
      
      public static function set remote(param1:Boolean) : void
      {
         setter("remote",param1);
      }
      
      public static function fixGraphRange(param1:String, param2:Number = NaN, param3:Number = NaN) : void
      {
         if(_console)
         {
            _console.fixGraphRange(param1,param2,param3);
         }
      }
      
      public static function startOnStage(param1:DisplayObject, param2:String = "", param3:int = 1) : void
      {
         if(_console)
         {
            trace(ERROR_EXISTS);
         }
         else if(param1 != null && param1.stage != null)
         {
            start(param1.stage,param2,param3);
         }
         else
         {
            _console = new Console(param2,param3);
            if(param1 != null)
            {
               param1.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandle);
            }
         }
      }
      
      public static function set remotingPassword(param1:String) : void
      {
         setter("remotingPassword",param1);
      }
      
      public static function add(param1:*, param2:Number = 2, param3:Boolean = false) : void
      {
         if(_console)
         {
            _console.add(param1,param2,param3);
         }
      }
      
      public static function get instance() : Console
      {
         return _console;
      }
      
      public static function logch(param1:*, ... rest) : void
      {
         if(_console)
         {
            _console.logch.apply(null,[param1].concat(rest));
         }
      }
      
      public static function info(... rest) : void
      {
         if(_console)
         {
            _console.info.apply(null,rest);
         }
      }
      
      public static function get tracingChannels() : Array
      {
         return getter("tracingChannels") as Array;
      }
      
      public static function get prefixChannelNames() : Boolean
      {
         return getter("prefixChannelNames") as Boolean;
      }
      
      public static function set remoteDelay(param1:int) : void
      {
         setter("remoteDelay",param1);
      }
      
      public static function get commandBase() : Object
      {
         return getter("commandBase") as Object;
      }
      
      public static function set commandLine(param1:Boolean) : void
      {
         setter("commandLine",param1);
      }
      
      public static function get tracing() : Boolean
      {
         return getter("tracing") as Boolean;
      }
      
      public static function get filterText() : String
      {
         return getter("filterText") as String;
      }
      
      public static function get width() : Number
      {
         return getter("width") as Number;
      }
      
      public static function get commandLineAllowed() : Boolean
      {
         return getter("commandLineAllowed") as Boolean;
      }
      
      public static function watch(param1:Object, param2:String = null) : String
      {
         if(_console)
         {
            return _console.watch(param1,param2);
         }
         return null;
      }
      
      public static function unwatch(param1:String) : void
      {
         if(_console)
         {
            _console.unwatch(param1);
         }
      }
      
      public static function getAllLog(param1:String = "\n") : String
      {
         if(_console)
         {
            return _console.getAllLog(param1);
         }
         return "";
      }
      
      public static function gc() : void
      {
         if(_console)
         {
            _console.gc();
         }
      }
      
      public static function get remoteDelay() : int
      {
         return getter("remoteDelay") as int;
      }
      
      public static function get commandLine() : Boolean
      {
         return getter("commandLine") as Boolean;
      }
      
      public static function store(param1:String, param2:Object, param3:Boolean = false) : void
      {
         if(_console)
         {
            _console.store(param1,param2,param3);
         }
      }
      
      public static function bindKey(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Function = null, param6:Array = null) : void
      {
         if(_console)
         {
            _console.bindKey(param1,param2,param3,param4,param5,param6);
         }
      }
      
      public static function set visible(param1:Boolean) : void
      {
         setter("visible",param1);
      }
      
      public static function set x(param1:Number) : void
      {
         setter("x",param1);
      }
      
      public static function set y(param1:Number) : void
      {
         setter("y",param1);
      }
      
      public static function set maxLines(param1:int) : void
      {
         setter("maxLines",param1);
      }
      
      public static function set strongRef(param1:Boolean) : void
      {
         setter("strongRef",param1);
      }
      
      public static function get maxLines() : int
      {
         return getter("maxLines") as int;
      }
      
      public static function debugch(param1:*, ... rest) : void
      {
         if(_console)
         {
            _console.debugch.apply(null,[param1].concat(rest));
         }
      }
   }
}

