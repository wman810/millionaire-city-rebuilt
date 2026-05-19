package com.luaye.console
{
   import com.luaye.console.core.CommandLine;
   import com.luaye.console.core.Log;
   import com.luaye.console.core.Logs;
   import com.luaye.console.core.MemoryMonitor;
   import com.luaye.console.core.Remoting;
   import com.luaye.console.utils.Utils;
   import com.luaye.console.view.ChannelsPanel;
   import com.luaye.console.view.FPSPanel;
   import com.luaye.console.view.MainPanel;
   import com.luaye.console.view.PanelsManager;
   import com.luaye.console.view.RollerPanel;
   import com.luaye.console.view.Style;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.net.LocalConnection;
   import flash.system.System;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class Console extends Sprite
   {
      
      public static const VERSION:Number = 2.31;
      
      public static const VERSION_STAGE:String = "";
      
      public static const NAME:String = "Console";
      
      public static const PANEL_MAIN:String = "mainPanel";
      
      public static const PANEL_CHANNELS:String = "channelsPanel";
      
      public static const PANEL_FPS:String = "fpsPanel";
      
      public static const PANEL_MEMORY:String = "memoryPanel";
      
      public static const PANEL_ROLLER:String = "rollerPanel";
      
      public static var REMOTING_CONN_NAME:String = "_Console";
      
      public static const CONSOLE_CHANNEL:String = "C";
      
      public static const FILTERED_CHANNEL:String = "~";
      
      public static const GLOBAL_CHANNEL:String = " * ";
      
      public static const DEFAULT_CHANNEL:String = "-";
      
      public static const LOG_LEVEL:uint = 2;
      
      public static const INFO_LEVEL:uint = 4;
      
      public static const DEBUG_LEVEL:uint = 6;
      
      public static const WARN_LEVEL:uint = 8;
      
      public static const ERROR_LEVEL:uint = 10;
      
      public static const FATAL_LEVEL:uint = 100;
      
      public static const FPS_MAX_LAG_FRAMES:uint = 25;
      
      public static const MAPPING_SPLITTER:String = "|";
      
      private var _lines:Logs;
      
      private var _enabled:Boolean = true;
      
      private var _priority:int;
      
      private var _password:String;
      
      public var maxLines:int = 1000;
      
      private var _keyBinds:Object = {};
      
      private var _rollerCaptureKey:String;
      
      public var alwaysOnTop:Boolean = true;
      
      public var moveTopAttempts:int = 50;
      
      private var _channels:Array = [GLOBAL_CHANNEL,DEFAULT_CHANNEL];
      
      public var maxRepeats:Number = 75;
      
      public var quiet:Boolean;
      
      private var _previousTime:Number;
      
      public var rulerHidesMouse:Boolean = true;
      
      private var _isPaused:Boolean;
      
      private var _filterText:String;
      
      public var cl:CommandLine;
      
      private var _tracingChannels:Array = [];
      
      private var _commandLineAllowed:Boolean = true;
      
      private var _tracing:Boolean = false;
      
      public var tracingPriority:int = 0;
      
      private var _remotingPassword:String = "";
      
      private var _isRepeating:Boolean;
      
      private var mm:MemoryMonitor;
      
      public var style:Style;
      
      public var prefixChannelNames:Boolean = true;
      
      private var _traceCall:Function = trace;
      
      private var _viewingChannels:Array = [GLOBAL_CHANNEL];
      
      private var _needToMoveTop:Boolean;
      
      private var _repeated:int;
      
      public var remoteDelay:int = 20;
      
      private var remoter:Remoting;
      
      private var _lineAdded:Boolean;
      
      public var panels:PanelsManager;
      
      private var _passwordIndex:int;
      
      private var _mspf:Number;
      
      private var _strongRef:Boolean;
      
      public function Console(param1:String = "", param2:int = 1)
      {
         super();
         name = NAME;
         if(param1 == null)
         {
            param1 = "";
         }
         this._password = param1;
         this._remotingPassword = param1;
         tabChildren = false;
         this._lines = new Logs();
         this.cl = new CommandLine(this);
         this.remoter = new Remoting(this,this.remoteLogSend);
         this.mm = new MemoryMonitor();
         this.style = new Style(param2);
         this.panels = new PanelsManager(this,new MainPanel(this,this._lines,this._channels));
         this.report("<b>Console v" + VERSION + (VERSION_STAGE ? " " + VERSION_STAGE : "") + ", Happy bug fixing!</b>",-2);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle,false,0,true);
         if(this._password)
         {
            visible = false;
         }
      }
      
      public static function get remoteIsRunning() : Boolean
      {
         var sCon:LocalConnection = new LocalConnection();
         try
         {
            sCon.allowInsecureDomain("*");
            sCon.connect(REMOTING_CONN_NAME + Remoting.REMOTE_PREFIX);
         }
         catch(error:Error)
         {
            return true;
         }
         sCon.close();
         return false;
      }
      
      public function destroy() : void
      {
         this.enabled = false;
         this.remoter.close();
         removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         this.cl.destory();
         if(stage)
         {
            this.stageRemovedHandle();
         }
      }
      
      public function error(... rest) : void
      {
         this.addLine(this.joinArgs(rest),ERROR_LEVEL);
      }
      
      public function fatal(... rest) : void
      {
         this.addLine(this.joinArgs(rest),FATAL_LEVEL);
      }
      
      public function debugch(param1:*, ... rest) : void
      {
         this.ch(param1,this.joinArgs(rest),DEBUG_LEVEL);
      }
      
      public function get channelsPanel() : Boolean
      {
         return this.panels.channelsPanel;
      }
      
      public function set remoting(param1:Boolean) : void
      {
         this.remoter.remoting = param1;
      }
      
      public function get memoryMonitor() : Boolean
      {
         return this.panels.memoryMonitor;
      }
      
      public function set viewingChannels(param1:Array) : void
      {
         this._viewingChannels.splice(0);
         if(Boolean(param1) && Boolean(param1.length))
         {
            this._viewingChannels.push.apply(this,param1);
         }
         else
         {
            this._viewingChannels.push(GLOBAL_CHANNEL);
         }
         this.panels.mainPanel.updateToBottom();
         this.panels.updateMenu();
      }
      
      public function inspect(param1:Object, param2:Boolean = true) : void
      {
         this.cl.inspect(param1,param2);
      }
      
      public function get mspf() : Number
      {
         return this._mspf;
      }
      
      public function get viewingChannels() : Array
      {
         return this._viewingChannels.concat();
      }
      
      public function get viewingChannel() : String
      {
         return this._viewingChannels.join(",");
      }
      
      public function set channelsPanel(param1:Boolean) : void
      {
         var _loc2_:ChannelsPanel = null;
         this.panels.channelsPanel = param1;
         if(param1)
         {
            _loc2_ = this.panels.getPanel(PANEL_CHANNELS) as ChannelsPanel;
            _loc2_.start(this._channels);
         }
         this.panels.updateMenu();
      }
      
      private function getKey(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : String
      {
         return param1.toLowerCase() + (param2 ? "0" : "1") + (param3 ? "0" : "1") + (param4 ? "0" : "1");
      }
      
      public function addGraph(param1:String, param2:Object, param3:String, param4:Number = -1, param5:String = null, param6:Rectangle = null, param7:Boolean = false) : void
      {
         if(param2 == null)
         {
            this.report("ERROR: Graph [" + param1 + "] received a null object to graph property [" + param3 + "].",10);
            return;
         }
         this.panels.addGraph(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function get paused() : Boolean
      {
         return this._isPaused;
      }
      
      public function get fpsMonitor() : Boolean
      {
         return this.panels.fpsMonitor;
      }
      
      public function set memoryMonitor(param1:Boolean) : void
      {
         this.panels.memoryMonitor = param1;
      }
      
      private function addLine(param1:*, param2:Number = 0, param3:String = null, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc9_:int = 0;
         if(!this._enabled)
         {
            return;
         }
         var _loc6_:Boolean = param4 && this._isRepeating;
         var _loc7_:String = param1 is XML || param1 is XMLList ? param1.toXMLString() : String(param1);
         if(!param3 || param3 == GLOBAL_CHANNEL)
         {
            param3 = DEFAULT_CHANNEL;
         }
         if(this._tracing && !_loc6_ && (this._tracingChannels.length == 0 || this._tracingChannels.indexOf(param3) >= 0))
         {
            if(this.tracingPriority <= param2 || this.tracingPriority <= 0)
            {
               this._traceCall("[" + param3 + "] " + _loc7_);
            }
         }
         if(!param5)
         {
            _loc7_ = _loc7_.replace(/</gim,"&lt;");
            _loc7_ = _loc7_.replace(/>/gim,"&gt;");
         }
         if(this._channels.indexOf(param3) < 0)
         {
            this._channels.push(param3);
         }
         var _loc8_:Log = new Log(_loc7_,param3,param2,param4,param5);
         if(_loc6_)
         {
            this._lines.pop();
            this._lines.push(_loc8_);
         }
         else
         {
            this._repeated = 0;
            this._lines.push(_loc8_);
            if(this.maxLines > 0)
            {
               _loc9_ = this._lines.length - this.maxLines;
               if(_loc9_ > 0)
               {
                  this._lines.shift(_loc9_);
               }
            }
         }
         this._lineAdded = true;
         this._isRepeating = param4;
         if(this.remoter.remoting)
         {
            this.remoter.addLineQueue(_loc8_);
         }
      }
      
      override public function get height() : Number
      {
         return this.panels.mainPanel.height;
      }
      
      public function removeGraph(param1:String, param2:Object = null, param3:String = null) : void
      {
         this.panels.removeGraph(param1,param2,param3);
      }
      
      public function joinArgs(param1:Array) : String
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            if(param1[_loc2_] is XML || param1[_loc2_] is XMLList)
            {
               param1[_loc2_] = param1[_loc2_].toXMLString();
            }
         }
         return param1.join(" ");
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function setRollerCaptureKey(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : void
      {
         if(this._rollerCaptureKey)
         {
            this.bindByKey(this._rollerCaptureKey,null);
         }
         if(Boolean(param1) && param1.length == 1)
         {
            this._rollerCaptureKey = this.getKey(param1,param2,param3,param4);
            this.bindByKey(this._rollerCaptureKey,this.onRollerCaptureKey);
         }
      }
      
      public function get remote() : Boolean
      {
         return this.remoter.isRemote;
      }
      
      public function runCommand(param1:String) : *
      {
         var line:String = param1;
         if(this.remoter.isRemote)
         {
            this.report("Run command at remote: " + line,-2);
            try
            {
               this.remoter.send("runCommand",line);
            }
            catch(err:Error)
            {
               report("Command could not be sent to client: " + err,10);
            }
            return null;
         }
         return this.cl.run(line);
      }
      
      public function checkLogin(param1:String) : Boolean
      {
         return !this._remotingPassword || this._remotingPassword == param1;
      }
      
      private function bindByKey(param1:String, param2:Function, param3:Array = null) : void
      {
         if(param2 == null)
         {
            delete this._keyBinds[param1];
         }
         else
         {
            this._keyBinds[param1] = [param2,param3];
         }
      }
      
      public function get displayRoller() : Boolean
      {
         return this.panels.displayRoller;
      }
      
      public function clear(param1:String = null) : void
      {
         var _loc2_:Log = null;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = this._lines.first;
            while(_loc2_)
            {
               if(_loc2_.c == param1)
               {
                  this._lines.remove(_loc2_);
               }
               _loc2_ = _loc2_.next;
            }
            _loc3_ = this._channels.indexOf(param1);
            if(_loc3_ >= 0)
            {
               this._channels.splice(_loc3_,1);
            }
         }
         else
         {
            this._lines.clear();
            this._channels.splice(0);
            this._channels.push(GLOBAL_CHANNEL,DEFAULT_CHANNEL);
         }
         this.panels.mainPanel.updateToBottom();
         this.panels.updateMenu();
      }
      
      public function set priority(param1:int) : void
      {
         this._priority = param1;
         this.panels.mainPanel.updateToBottom();
         this.panels.updateMenu();
      }
      
      private function stageRemovedHandle(param1:Event = null) : void
      {
         removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         parent.removeEventListener(Event.ADDED,this.onParentDisplayAdded);
         stage.removeEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyUpHandler);
      }
      
      public function get traceCall() : Function
      {
         return this._traceCall;
      }
      
      public function set viewingChannel(param1:String) : void
      {
         if(param1)
         {
            this.viewingChannels = [param1];
         }
         else
         {
            this.viewingChannels = [GLOBAL_CHANNEL];
         }
      }
      
      override public function set height(param1:Number) : void
      {
         this.panels.mainPanel.height = param1;
      }
      
      public function report(param1:*, param2:Number = 0, param3:Boolean = true) : void
      {
         this.addLine(param1,param2,CONSOLE_CHANNEL,false,param3);
      }
      
      public function debug(... rest) : void
      {
         this.addLine(this.joinArgs(rest),DEBUG_LEVEL);
      }
      
      public function map(param1:DisplayObjectContainer, param2:uint = 0) : void
      {
         this.cl.map(param1,param2);
      }
      
      public function set fpsMonitor(param1:Boolean) : void
      {
         this.panels.fpsMonitor = param1;
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(this._isPaused == param1)
         {
            return;
         }
         if(param1)
         {
            this.report("Paused",10);
         }
         else
         {
            this.report("Resumed",-1);
         }
         this._isPaused = param1;
         this.panels.mainPanel.setPaused(param1);
      }
      
      public function ch(param1:*, param2:*, param3:Number = 2, param4:Boolean = false) : void
      {
         var _loc5_:String = null;
         if(param1 is String)
         {
            _loc5_ = param1 as String;
         }
         else if(param1)
         {
            _loc5_ = Utils.shortClassName(param1);
         }
         else
         {
            _loc5_ = DEFAULT_CHANNEL;
         }
         this.addLine(param2,param3,_loc5_,param4);
      }
      
      public function log(... rest) : void
      {
         this.addLine(this.joinArgs(rest),LOG_LEVEL);
      }
      
      private function onParentDisplayAdded(param1:Event) : void
      {
         if((param1.target as DisplayObject).parent == parent)
         {
            this._needToMoveTop = true;
         }
      }
      
      private function stageAddedHandle(param1:Event = null) : void
      {
         if(this.cl.base == null)
         {
            this.cl.base = parent;
         }
         addEventListener(Event.ENTER_FRAME,this._onEnterFrame,false,0,true);
         parent.addEventListener(Event.ADDED,this.onParentDisplayAdded,false,0,true);
         stage.addEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyUpHandler,false,0,true);
      }
      
      public function set tracingChannels(param1:Array) : void
      {
         this._tracingChannels = param1 ? param1.concat() : [];
      }
      
      public function errorch(param1:*, ... rest) : void
      {
         this.ch(param1,this.joinArgs(rest),ERROR_LEVEL);
      }
      
      public function warnch(param1:*, ... rest) : void
      {
         this.ch(param1,this.joinArgs(rest),WARN_LEVEL);
      }
      
      public function setPanelArea(param1:String, param2:Rectangle) : void
      {
         this.panels.setPanelArea(param1,param2);
      }
      
      override public function get x() : Number
      {
         return this.panels.mainPanel.x;
      }
      
      override public function get y() : Number
      {
         return this.panels.mainPanel.y;
      }
      
      public function get strongRef() : Boolean
      {
         return this._strongRef;
      }
      
      public function set commandBase(param1:Object) : void
      {
         if(param1)
         {
            this.cl.base = param1;
         }
      }
      
      public function fatalch(param1:*, ... rest) : void
      {
         this.ch(param1,this.joinArgs(rest),FATAL_LEVEL);
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         if(this._enabled && !param1)
         {
            this.report("Disabled",10);
         }
         var _loc2_:Boolean = this._enabled;
         this._enabled = param1;
         if(!_loc2_ && param1)
         {
            this.report("Enabled",-1);
         }
      }
      
      public function fixGraphRange(param1:String, param2:Number = NaN, param3:Number = NaN) : void
      {
         this.panels.fixGraphRange(param1,param2,param3);
      }
      
      public function get remoting() : Boolean
      {
         return this.remoter.remoting;
      }
      
      public function set remotingPassword(param1:String) : void
      {
         this._remotingPassword = param1;
         this.remoter.login(param1);
      }
      
      override public function set width(param1:Number) : void
      {
         this.panels.mainPanel.width = param1;
      }
      
      private function keyUpHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         if(!this._enabled)
         {
            return;
         }
         if(param1.keyLocation == 0)
         {
            _loc2_ = String.fromCharCode(param1.charCode);
            if(_loc2_ == this._password.substring(this._passwordIndex,this._passwordIndex + 1))
            {
               ++this._passwordIndex;
               if(this._passwordIndex >= this._password.length)
               {
                  this._passwordIndex = 0;
                  if(visible && !this.panels.mainPanel.visible)
                  {
                     this.panels.mainPanel.visible = true;
                  }
                  else
                  {
                     visible = !visible;
                  }
               }
            }
            else
            {
               this._passwordIndex = 0;
               _loc3_ = _loc2_.toLowerCase() + (param1.ctrlKey ? "0" : "1") + (param1.altKey ? "0" : "1") + (param1.shiftKey ? "0" : "1");
               if(this._keyBinds[_loc3_])
               {
                  _loc4_ = this._keyBinds[_loc3_];
                  _loc4_[0].apply(this,_loc4_[1]);
               }
            }
         }
      }
      
      public function lineShouldShow(param1:Log) : Boolean
      {
         return (this._viewingChannels.indexOf(Console.GLOBAL_CHANNEL) >= 0 || this._viewingChannels.indexOf(param1.c) >= 0 || this._filterText && this._viewingChannels.indexOf(Console.FILTERED_CHANNEL) >= 0 && param1.text.toLowerCase().indexOf(this._filterText.toLowerCase()) >= 0) && (this._priority <= 0 || param1.p >= this._priority);
      }
      
      public function set commandLineAllowed(param1:Boolean) : void
      {
         this._commandLineAllowed = param1;
         if(param1 == 0 && this.commandLine)
         {
            this.commandLine = false;
         }
      }
      
      private function _onEnterFrame(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc4_:ChannelsPanel = null;
         if(!this._enabled)
         {
            return;
         }
         var _loc2_:int = getTimer();
         this._mspf = _loc2_ - this._previousTime;
         this._previousTime = _loc2_;
         if(this._needToMoveTop && this.alwaysOnTop && this.moveTopAttempts > 0 && Boolean(parent))
         {
            this._needToMoveTop = false;
            --this.moveTopAttempts;
            parent.setChildIndex(this,parent.numChildren - 1);
            if(!this.quiet)
            {
               this.report("Moved console on top (alwaysOnTop enabled), " + this.moveTopAttempts + " attempts left.",-1);
            }
         }
         if(this._isRepeating)
         {
            ++this._repeated;
            if(this._repeated > this.maxRepeats && this.maxRepeats >= 0)
            {
               this._isRepeating = false;
            }
         }
         if(!this._isPaused)
         {
            _loc3_ = this.mm.update();
            if(_loc3_.length > 0)
            {
               this.report("<b>GARBAGE COLLECTED " + _loc3_.length + " item(s): </b>" + _loc3_.join(", "),-2);
            }
         }
         if(visible)
         {
            this.panels.mainPanel.update(!this._isPaused && this._lineAdded);
            if(this._lineAdded)
            {
               _loc4_ = this.panels.getPanel(PANEL_CHANNELS) as ChannelsPanel;
               if(_loc4_)
               {
                  _loc4_.update();
               }
               this._lineAdded = false;
            }
         }
         if(this.remoter.remoting)
         {
            this.remoter.update(this._mspf,stage ? stage.frameRate : 0);
         }
      }
      
      public function set traceCall(param1:Function) : void
      {
         if(param1 == null)
         {
            this.report("C.traceCall function setter can not be null.",10);
         }
         else
         {
            this._traceCall = param1;
         }
      }
      
      public function set displayRoller(param1:Boolean) : void
      {
         this.panels.displayRoller = param1;
      }
      
      public function set filterText(param1:String) : void
      {
         this._filterText = param1;
         if(param1)
         {
            this.clear(FILTERED_CHANNEL);
            this._channels.splice(1,0,FILTERED_CHANNEL);
            this.addLine("Filtering [" + param1 + "]",10,FILTERED_CHANNEL);
            this.viewingChannels = [FILTERED_CHANNEL];
         }
         else if(this.viewingChannel == FILTERED_CHANNEL)
         {
            this.viewingChannels = [GLOBAL_CHANNEL];
         }
      }
      
      public function infoch(param1:*, ... rest) : void
      {
         this.ch(param1,this.joinArgs(rest),INFO_LEVEL);
      }
      
      public function set remote(param1:Boolean) : void
      {
         this.remoter.isRemote = param1;
         this.panels.updateMenu();
      }
      
      public function add(param1:*, param2:Number = 2, param3:Boolean = false) : void
      {
         this.addLine(param1,param2,DEFAULT_CHANNEL,param3);
      }
      
      public function get priority() : int
      {
         return this._priority;
      }
      
      public function set tracing(param1:Boolean) : void
      {
         this._tracing = param1;
         this.panels.mainPanel.updateMenu();
      }
      
      public function logch(param1:*, ... rest) : void
      {
         this.ch(param1,this.joinArgs(rest),LOG_LEVEL);
      }
      
      public function warn(... rest) : void
      {
         this.addLine(this.joinArgs(rest),WARN_LEVEL);
      }
      
      public function info(... rest) : void
      {
         this.addLine(this.joinArgs(rest),INFO_LEVEL);
      }
      
      public function get tracingChannels() : Array
      {
         return this._tracingChannels;
      }
      
      public function get commandBase() : Object
      {
         return this.cl.base;
      }
      
      public function set commandLine(param1:Boolean) : void
      {
         if(param1 && !this._commandLineAllowed)
         {
            this.panels.updateMenu();
            this.report("CommandLine is disabled. Set commandLineAllowed from source code to allow.");
         }
         else
         {
            this.panels.mainPanel.commandLine = param1;
         }
      }
      
      public function sendLogin(param1:String) : void
      {
         this.remoter.login(param1);
      }
      
      private function onRollerCaptureKey() : void
      {
         if(this.displayRoller)
         {
            this.report("Display Roller Capture:" + RollerPanel(this.panels.getPanel(PANEL_ROLLER)).capture(),-1);
         }
      }
      
      public function get filterText() : String
      {
         return this._filterText;
      }
      
      override public function get width() : Number
      {
         return this.panels.mainPanel.width;
      }
      
      public function get tracing() : Boolean
      {
         return this._tracing;
      }
      
      private function remoteLogSend(param1:Array) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:FPSPanel = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         if(!this.remoter.isRemote || !param1)
         {
            return;
         }
         var _loc2_:Array = param1[0];
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_)
            {
               this.addLine(_loc3_.text,_loc3_.p,_loc3_.c,_loc3_.r,_loc3_.s);
            }
         }
         _loc4_ = param1[1];
         if(_loc4_)
         {
            _loc5_ = this.panels.getPanel(PANEL_FPS) as FPSPanel;
            if(_loc5_)
            {
               _loc6_ = Number(_loc4_[0]);
               _loc5_.highest = _loc6_;
               _loc5_.averaging = _loc6_;
               _loc7_ = int(_loc4_.length);
               _loc8_ = 1;
               while(_loc8_ < _loc7_)
               {
                  _loc9_ = 1000 / _loc4_[_loc8_];
                  if(_loc9_ > _loc6_)
                  {
                     _loc9_ = _loc6_;
                  }
                  _loc5_.addCurrent(_loc9_);
                  _loc8_++;
               }
               _loc5_.updateKeyText();
               _loc5_.drawGraph();
            }
         }
         this.remoter.remoteMem = param1[2];
         if(param1[3])
         {
            this.panels.mainPanel.updateCLScope(param1[3]);
         }
      }
      
      public function watch(param1:Object, param2:String = null) : String
      {
         var _loc3_:String = getQualifiedClassName(param1);
         if(!param2)
         {
            param2 = _loc3_ + "@" + getTimer();
         }
         var _loc4_:String = this.mm.watch(param1,param2);
         if(!this.quiet)
         {
            this.report("Watching <b>" + _loc3_ + "</b> as <p5>" + _loc4_ + "</p5>.",-1);
         }
         return _loc4_;
      }
      
      private function onStageMouseLeave(param1:Event) : void
      {
         this.panels.tooltip(null);
      }
      
      public function unwatch(param1:String) : void
      {
         this.mm.unwatch(param1);
      }
      
      public function gc() : void
      {
         var ok:Boolean = false;
         var str:String = null;
         if(this.remote)
         {
            try
            {
               this.report("Sending garbage collection request to client",-1);
               this.remoter.send("gc");
            }
            catch(e:Error)
            {
               report(e,10);
            }
         }
         else
         {
            ok = this.mm.gc();
            str = "Manual garbage collection " + (ok ? "successful." : "FAILED. You need debugger version of flash player.");
            this.report(str,ok ? -1 : 10);
         }
      }
      
      public function get commandLine() : Boolean
      {
         return this.panels.mainPanel.commandLine;
      }
      
      public function getAllLog(param1:String = "\n") : String
      {
         var _loc2_:String = "";
         var _loc3_:Log = this._lines.first;
         while(_loc3_)
         {
            _loc2_ += _loc3_.toString() + (_loc3_.next ? param1 : "");
            _loc3_ = _loc3_.next;
         }
         return _loc2_;
      }
      
      public function store(param1:String, param2:Object, param3:Boolean = false) : void
      {
         this.cl.store(param1,param2,param3);
      }
      
      public function bindKey(param1:String, param2:Boolean, param3:Boolean, param4:Boolean, param5:Function, param6:Array = null) : void
      {
         if(!param1 || param1.length != 1)
         {
            this.report("Binding key must be a single character. You gave [" + param1 + "]",10);
            return;
         }
         this.bindByKey(this.getKey(param1,param2,param3,param4),param5,param6);
         if(!this.quiet)
         {
            this.report((param5 is Function ? "Bined" : "Unbined") + " key <b>" + param1.toUpperCase() + "</b>" + (param2 ? "+ctrl" : "") + (param3 ? "+alt" : "") + (param4 ? "+shift" : "") + ".",-1);
         }
      }
      
      public function getLogsAsObjects() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:Log = this._lines.first;
         while(_loc2_)
         {
            _loc1_.push(_loc2_.toObject());
            _loc2_ = _loc2_.next;
         }
         return _loc1_;
      }
      
      public function get fps() : Number
      {
         return 1000 / this._mspf;
      }
      
      public function get commandLineAllowed() : Boolean
      {
         return this._commandLineAllowed;
      }
      
      override public function set y(param1:Number) : void
      {
         this.panels.mainPanel.y = param1;
      }
      
      override public function set x(param1:Number) : void
      {
         this.panels.mainPanel.x = param1;
      }
      
      public function get currentMemory() : uint
      {
         return this.remoter.isRemote ? uint(this.remoter.remoteMem) : System.totalMemory;
      }
      
      public function set strongRef(param1:Boolean) : void
      {
         this._strongRef = param1;
      }
   }
}

