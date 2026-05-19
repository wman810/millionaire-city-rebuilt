package com.demonsters.debugger
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   internal class MonsterDebuggerCore
   {
      
      private static var _highlightInfo:TextField;
      
      private static var _monitorStart:Number;
      
      private static var _monitorTime:Number;
      
      private static var _monitorFrames:int;
      
      private static var _highlightTarget:DisplayObject;
      
      private static var _highlight:Sprite;
      
      private static var _monitorSprite:Sprite;
      
      private static var _highlightUpdate:Boolean;
      
      private static var _monitorTimer:Timer;
      
      private static var _highlightMouse:Boolean;
      
      private static const MONITOR_UPDATE:int = 500;
      
      private static const HIGHLITE_COLOR:uint = 3381759;
      
      private static var _base:Object = null;
      
      private static var _stage:Stage = null;
      
      private static var _plugins:Object = {};
      
      internal static const ID:String = "com.demonsters.debugger.core";
      
      public function MonsterDebuggerCore()
      {
         super();
      }
      
      internal static function sendInformation() : void
      {
         var data:Object;
         var UIComponentClass:* = undefined;
         var tmpLocation:String = null;
         var tmpTitle:String = null;
         var NativeApplicationClass:* = undefined;
         var descriptor:XML = null;
         var ns:Namespace = null;
         var filename:String = null;
         var FileClass:* = undefined;
         var slash:int = 0;
         var playerType:String = Capabilities.playerType;
         var playerVersion:String = Capabilities.version;
         var isDebugger:Boolean = Capabilities.isDebugger;
         var isFlex:Boolean = false;
         var fileTitle:String = "";
         var fileLocation:String = "";
         try
         {
            UIComponentClass = getDefinitionByName("mx.core::UIComponent");
            if(UIComponentClass != null)
            {
               isFlex = true;
            }
         }
         catch(e1:Error)
         {
         }
         if(_base is DisplayObject && _base.hasOwnProperty("loaderInfo"))
         {
            if(DisplayObject(_base).loaderInfo != null)
            {
               fileLocation = unescape(DisplayObject(_base).loaderInfo.url);
            }
         }
         if(_base.hasOwnProperty("stage"))
         {
            if(_base["stage"] != null && _base["stage"] is Stage)
            {
               fileLocation = unescape(Stage(_base["stage"]).loaderInfo.url);
            }
         }
         if(playerType == "ActiveX" || playerType == "PlugIn")
         {
            if(ExternalInterface.available)
            {
               try
               {
                  tmpLocation = ExternalInterface.call("window.location.href.toString");
                  tmpTitle = ExternalInterface.call("window.document.title.toString");
                  if(tmpLocation != null)
                  {
                     fileLocation = tmpLocation;
                  }
                  if(tmpTitle != null)
                  {
                     fileTitle = tmpTitle;
                  }
               }
               catch(e2:Error)
               {
               }
            }
         }
         if(playerType == "Desktop")
         {
            try
            {
               NativeApplicationClass = getDefinitionByName("flash.desktop::NativeApplication");
               if(NativeApplicationClass != null)
               {
                  descriptor = NativeApplicationClass["nativeApplication"]["applicationDescriptor"];
                  ns = descriptor.namespace();
                  filename = descriptor.ns::filename;
                  FileClass = getDefinitionByName("flash.filesystem::File");
                  if(Capabilities.os.toLowerCase().indexOf("windows") != -1)
                  {
                     filename += ".exe";
                     fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
                  }
                  else if(Capabilities.os.toLowerCase().indexOf("mac") != -1)
                  {
                     filename += ".app";
                     fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
                  }
               }
            }
            catch(e3:Error)
            {
            }
         }
         if(fileTitle == "" && fileLocation != "")
         {
            slash = Math.max(fileLocation.lastIndexOf("\\"),fileLocation.lastIndexOf("/"));
            if(slash != -1)
            {
               fileTitle = fileLocation.substring(slash + 1,fileLocation.lastIndexOf("."));
            }
            else
            {
               fileTitle = fileLocation;
            }
         }
         data = {
            "command":MonsterDebuggerConstants.COMMAND_INFO,
            "debuggerVersion":MonsterDebugger.VERSION,
            "playerType":playerType,
            "playerVersion":playerVersion,
            "isDebugger":isDebugger,
            "isFlex":isFlex,
            "fileLocation":fileLocation,
            "fileTitle":fileTitle
         };
         send(data,true);
         MonsterDebuggerConnection.processQueue();
      }
      
      private static function handleInternal(param1:MonsterDebuggerData) : void
      {
         var obj:* = undefined;
         var xml:XML = null;
         var method:Function = null;
         var displayObject:DisplayObject = null;
         var bitmapData:BitmapData = null;
         var bytes:ByteArray = null;
         var item:MonsterDebuggerData = param1;
         switch(item.data["command"])
         {
            case MonsterDebuggerConstants.COMMAND_HELLO:
               sendInformation();
               break;
            case MonsterDebuggerConstants.COMMAND_BASE:
               obj = MonsterDebuggerUtils.getObject(_base,"",0);
               if(obj != null)
               {
                  xml = XML(MonsterDebuggerUtils.parse(obj,"",1,2,true));
                  send({
                     "command":MonsterDebuggerConstants.COMMAND_BASE,
                     "xml":xml
                  });
               }
               break;
            case MonsterDebuggerConstants.COMMAND_INSPECT:
               obj = MonsterDebuggerUtils.getObject(_base,item.data["target"],0);
               if(obj != null)
               {
                  _base = obj;
                  xml = XML(MonsterDebuggerUtils.parse(obj,"",1,2,true));
                  send({
                     "command":MonsterDebuggerConstants.COMMAND_BASE,
                     "xml":xml
                  });
               }
               break;
            case MonsterDebuggerConstants.COMMAND_GET_OBJECT:
               obj = MonsterDebuggerUtils.getObject(_base,item.data["target"],0);
               if(obj != null)
               {
                  xml = XML(MonsterDebuggerUtils.parse(obj,item.data["target"],1,2,true));
                  send({
                     "command":MonsterDebuggerConstants.COMMAND_GET_OBJECT,
                     "xml":xml
                  });
               }
               break;
            case MonsterDebuggerConstants.COMMAND_GET_PROPERTIES:
               obj = MonsterDebuggerUtils.getObject(_base,item.data["target"],0);
               if(obj != null)
               {
                  xml = XML(MonsterDebuggerUtils.parse(obj,item.data["target"],1,1,false));
                  send({
                     "command":MonsterDebuggerConstants.COMMAND_GET_PROPERTIES,
                     "xml":xml
                  });
               }
               break;
            case MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS:
               obj = MonsterDebuggerUtils.getObject(_base,item.data["target"],0);
               if(obj != null)
               {
                  xml = XML(MonsterDebuggerUtils.parseFunctions(obj,item.data["target"]));
                  send({
                     "command":MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS,
                     "xml":xml
                  });
               }
               break;
            case MonsterDebuggerConstants.COMMAND_SET_PROPERTY:
               obj = MonsterDebuggerUtils.getObject(_base,item.data["target"],1);
               if(obj == null)
               {
                  break;
               }
               try
               {
                  obj[item.data["name"]] = item.data["value"];
                  send({
                     "command":MonsterDebuggerConstants.COMMAND_SET_PROPERTY,
                     "target":item.data["target"],
                     "value":obj[item.data["name"]]
                  });
                  break;
               }
               catch(e1:Error)
               {
                  break;
               }
               break;
            case MonsterDebuggerConstants.COMMAND_GET_PREVIEW:
               obj = MonsterDebuggerUtils.getObject(_base,item.data["target"],0);
               if(obj != null && MonsterDebuggerUtils.isDisplayObject(obj))
               {
                  displayObject = obj as DisplayObject;
                  bitmapData = MonsterDebuggerUtils.snapshot(displayObject,new Rectangle(0,0,300,300));
                  if(bitmapData != null)
                  {
                     bytes = bitmapData.getPixels(new Rectangle(0,0,bitmapData.width,bitmapData.height));
                     send({
                        "command":MonsterDebuggerConstants.COMMAND_GET_PREVIEW,
                        "bytes":bytes,
                        "width":bitmapData.width,
                        "height":bitmapData.height
                     });
                  }
               }
               break;
            case MonsterDebuggerConstants.COMMAND_CALL_METHOD:
               method = MonsterDebuggerUtils.getObject(_base,item.data["target"],0);
               if(!(method != null && method is Function))
               {
                  break;
               }
               if(item.data["returnType"] == MonsterDebuggerConstants.TYPE_VOID)
               {
                  method.apply(null,item.data["arguments"]);
                  break;
               }
               try
               {
                  obj = method.apply(null,item.data["arguments"]);
                  xml = XML(MonsterDebuggerUtils.parse(obj,"",1,5,false));
                  send({
                     "command":MonsterDebuggerConstants.COMMAND_CALL_METHOD,
                     "id":item.data["id"],
                     "xml":xml
                  });
                  break;
               }
               catch(e2:Error)
               {
                  break;
               }
               break;
            case MonsterDebuggerConstants.COMMAND_PAUSE:
               MonsterDebuggerUtils.pause();
               send({"command":MonsterDebuggerConstants.COMMAND_PAUSE});
               break;
            case MonsterDebuggerConstants.COMMAND_RESUME:
               MonsterDebuggerUtils.resume();
               send({"command":MonsterDebuggerConstants.COMMAND_RESUME});
               break;
            case MonsterDebuggerConstants.COMMAND_HIGHLIGHT:
               obj = MonsterDebuggerUtils.getObject(_base,item.data["target"],0);
               if(obj != null && MonsterDebuggerUtils.isDisplayObject(obj))
               {
                  if(DisplayObject(obj).stage != null && DisplayObject(obj).stage is Stage)
                  {
                     _stage = obj["stage"];
                  }
                  if(_stage != null)
                  {
                     highlightClear();
                     send({"command":MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
                     _highlight.removeEventListener(MouseEvent.CLICK,highlightClicked);
                     _highlight.mouseEnabled = false;
                     _highlightTarget = DisplayObject(obj);
                     _highlightMouse = false;
                     _highlightUpdate = true;
                  }
               }
               break;
            case MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT:
               highlightClear();
               _highlight.addEventListener(MouseEvent.CLICK,highlightClicked,false,0,true);
               _highlight.mouseEnabled = true;
               _highlightTarget = null;
               _highlightMouse = true;
               _highlightUpdate = true;
               send({"command":MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT});
               break;
            case MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT:
               highlightClear();
               _highlight.removeEventListener(MouseEvent.CLICK,highlightClicked);
               _highlight.mouseEnabled = false;
               _highlightTarget = null;
               _highlightMouse = false;
               _highlightUpdate = false;
               send({"command":MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
         }
      }
      
      internal static function unregisterPlugin(param1:String) : void
      {
         if(param1 in _plugins)
         {
            _plugins[param1] = null;
         }
      }
      
      internal static function initialize() : void
      {
         _monitorTime = new Date().time;
         _monitorStart = new Date().time;
         _monitorFrames = 0;
         _monitorTimer = new Timer(MONITOR_UPDATE);
         _monitorTimer.addEventListener(TimerEvent.TIMER,monitorTimerCallback,false,0,true);
         _monitorTimer.start();
         if(_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage)
         {
            _stage = _base["stage"] as Stage;
         }
         _monitorSprite = new Sprite();
         _monitorSprite.addEventListener(Event.ENTER_FRAME,frameHandler,false,0,true);
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.font = "Arial";
         _loc1_.color = 16777215;
         _loc1_.size = 11;
         _loc1_.leftMargin = 5;
         _loc1_.rightMargin = 5;
         _highlightInfo = new TextField();
         _highlightInfo.embedFonts = false;
         _highlightInfo.autoSize = TextFieldAutoSize.LEFT;
         _highlightInfo.mouseWheelEnabled = false;
         _highlightInfo.mouseEnabled = false;
         _highlightInfo.condenseWhite = false;
         _highlightInfo.embedFonts = false;
         _highlightInfo.multiline = false;
         _highlightInfo.selectable = false;
         _highlightInfo.wordWrap = false;
         _highlightInfo.defaultTextFormat = _loc1_;
         _highlightInfo.text = "";
         _highlight = new Sprite();
         _highlightMouse = false;
         _highlightTarget = null;
         _highlightUpdate = false;
      }
      
      private static function highlightDraw(param1:Boolean) : void
      {
         var boundsInner:Rectangle;
         var boundsOuter:Rectangle;
         var boundsText:Rectangle;
         var fill:Boolean = param1;
         if(_highlightTarget == null)
         {
            return;
         }
         boundsOuter = _highlightTarget.getBounds(_stage);
         if(_highlightTarget is Stage)
         {
            boundsOuter.x = 0;
            boundsOuter.y = 0;
            boundsOuter.width = _highlightTarget["stageWidth"];
            boundsOuter.height = _highlightTarget["stageHeight"];
         }
         else
         {
            boundsOuter.x = int(boundsOuter.x + 0.5);
            boundsOuter.y = int(boundsOuter.y + 0.5);
            boundsOuter.width = int(boundsOuter.width + 0.5);
            boundsOuter.height = int(boundsOuter.height + 0.5);
         }
         boundsInner = boundsOuter.clone();
         boundsInner.x += 2;
         boundsInner.y += 2;
         boundsInner.width -= 4;
         boundsInner.height -= 4;
         if(boundsInner.width < 0)
         {
            boundsInner.width = 0;
         }
         if(boundsInner.height < 0)
         {
            boundsInner.height = 0;
         }
         _highlight.graphics.clear();
         _highlight.graphics.beginFill(HIGHLITE_COLOR,1);
         _highlight.graphics.drawRect(boundsOuter.x,boundsOuter.y,boundsOuter.width,boundsOuter.height);
         _highlight.graphics.drawRect(boundsInner.x,boundsInner.y,boundsInner.width,boundsInner.height);
         if(fill)
         {
            _highlight.graphics.beginFill(HIGHLITE_COLOR,0.25);
            _highlight.graphics.drawRect(boundsInner.x,boundsInner.y,boundsInner.width,boundsInner.height);
         }
         if(_highlightTarget.name != null)
         {
            _highlightInfo.text = String(_highlightTarget.name) + " - " + String(MonsterDebuggerDescribeType.get(_highlightTarget).@name);
         }
         else
         {
            _highlightInfo.text = String(MonsterDebuggerDescribeType.get(_highlightTarget).@name);
         }
         boundsText = new Rectangle(boundsOuter.x,boundsOuter.y - (_highlightInfo.textHeight + 3),_highlightInfo.textWidth + 15,_highlightInfo.textHeight + 5);
         if(boundsText.y < 0)
         {
            boundsText.y = boundsOuter.y + boundsOuter.height;
         }
         if(boundsText.y + boundsText.height > _stage.stageHeight)
         {
            boundsText.y = _stage.stageHeight - boundsText.height;
         }
         if(boundsText.x < 0)
         {
            boundsText.x = 0;
         }
         if(boundsText.x + boundsText.width > _stage.stageWidth)
         {
            boundsText.x = _stage.stageWidth - boundsText.width;
         }
         _highlight.graphics.beginFill(HIGHLITE_COLOR,1);
         _highlight.graphics.drawRect(boundsText.x,boundsText.y,boundsText.width,boundsText.height);
         _highlight.graphics.endFill();
         _highlightInfo.x = boundsText.x;
         _highlightInfo.y = boundsText.y;
         try
         {
            _stage.addChild(_highlight);
            _stage.addChild(_highlightInfo);
         }
         catch(e:Error)
         {
         }
      }
      
      internal static function inspect(param1:*) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:XML = null;
         if(MonsterDebugger.enabled)
         {
            _base = param1;
            _loc2_ = MonsterDebuggerUtils.getObject(_base,"",0);
            if(_loc2_ != null)
            {
               _loc3_ = XML(MonsterDebuggerUtils.parse(_loc2_,"",1,2,true));
               send({
                  "command":MonsterDebuggerConstants.COMMAND_BASE,
                  "xml":_loc3_
               });
            }
         }
      }
      
      private static function frameHandler(param1:Event) : void
      {
         if(MonsterDebugger.enabled)
         {
            ++_monitorFrames;
            if(_highlightUpdate)
            {
               highlightUpdate();
            }
         }
      }
      
      private static function send(param1:Object, param2:Boolean = false) : void
      {
         if(MonsterDebugger.enabled)
         {
            MonsterDebuggerConnection.send(MonsterDebuggerCore.ID,param1,param2);
         }
      }
      
      private static function highlightUpdate() : void
      {
         var _loc1_:* = undefined;
         highlightClear();
         if(_highlightMouse)
         {
            if(_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage)
            {
               _stage = _base["stage"] as Stage;
            }
            if(Capabilities.playerType == "Desktop")
            {
               _loc1_ = getDefinitionByName("flash.desktop::NativeApplication");
               if(_loc1_ != null && _loc1_["nativeApplication"]["activeWindow"] != null)
               {
                  _stage = _loc1_["nativeApplication"]["activeWindow"]["stage"];
               }
            }
            if(_stage == null)
            {
               _highlight.removeEventListener(MouseEvent.CLICK,highlightClicked);
               _highlight.mouseEnabled = false;
               _highlightTarget = null;
               _highlightMouse = false;
               _highlightUpdate = false;
               return;
            }
            _highlightTarget = MonsterDebuggerUtils.getObjectUnderPoint(_stage,new Point(_stage.mouseX,_stage.mouseY));
            if(_highlightTarget != null)
            {
               highlightDraw(true);
            }
            return;
         }
         if(_highlightTarget != null)
         {
            if(_highlightTarget.stage == null || _highlightTarget.parent == null)
            {
               _highlight.removeEventListener(MouseEvent.CLICK,highlightClicked);
               _highlight.mouseEnabled = false;
               _highlightTarget = null;
               _highlightMouse = false;
               _highlightUpdate = false;
               return;
            }
            highlightDraw(false);
         }
      }
      
      internal static function set base(param1:*) : void
      {
         _base = param1;
      }
      
      internal static function handle(param1:MonsterDebuggerData) : void
      {
         if(MonsterDebugger.enabled)
         {
            if(param1.id == null || param1.id == "")
            {
               return;
            }
            if(param1.id == MonsterDebuggerCore.ID)
            {
               handleInternal(param1);
            }
            else if(param1.id in _plugins && _plugins[param1.id] != null)
            {
               MonsterDebuggerPlugin(_plugins[param1.id]).handle(param1);
            }
         }
      }
      
      internal static function registerPlugin(param1:String, param2:MonsterDebuggerPlugin) : void
      {
         if(param1 in _plugins)
         {
            return;
         }
         _plugins[param1] = param2;
      }
      
      internal static function snapshot(param1:*, param2:DisplayObject, param3:String = "", param4:String = "") : void
      {
         var _loc5_:BitmapData = null;
         var _loc6_:ByteArray = null;
         var _loc7_:Object = null;
         if(MonsterDebugger.enabled)
         {
            _loc5_ = MonsterDebuggerUtils.snapshot(param2);
            if(_loc5_ != null)
            {
               _loc6_ = _loc5_.getPixels(new Rectangle(0,0,_loc5_.width,_loc5_.height));
               _loc7_ = {
                  "command":MonsterDebuggerConstants.COMMAND_SNAPSHOT,
                  "memory":MonsterDebuggerUtils.getMemory(),
                  "date":new Date(),
                  "target":String(param1),
                  "reference":MonsterDebuggerUtils.getReferenceID(param1),
                  "bytes":_loc6_,
                  "width":param2.width,
                  "height":param2.height,
                  "person":param3,
                  "label":param4
               };
               send(_loc7_);
            }
         }
      }
      
      internal static function trace(param1:*, param2:*, param3:String = "", param4:String = "", param5:uint = 0, param6:int = 5) : void
      {
         var _loc7_:XML = null;
         var _loc8_:Object = null;
         if(MonsterDebugger.enabled)
         {
            _loc7_ = XML(MonsterDebuggerUtils.parse(param2,"",1,param6,false));
            _loc8_ = {
               "command":MonsterDebuggerConstants.COMMAND_TRACE,
               "memory":MonsterDebuggerUtils.getMemory(),
               "date":new Date(),
               "target":String(param1),
               "reference":MonsterDebuggerUtils.getReferenceID(param1),
               "xml":_loc7_,
               "person":param3,
               "label":param4,
               "color":param5
            };
            send(_loc8_);
         }
      }
      
      internal static function clear() : void
      {
         if(MonsterDebugger.enabled)
         {
            send({"command":MonsterDebuggerConstants.COMMAND_CLEAR_TRACES});
         }
      }
      
      internal static function get base() : *
      {
         return _base;
      }
      
      private static function highlightClicked(param1:MouseEvent) : void
      {
         param1.preventDefault();
         param1.stopImmediatePropagation();
         highlightClear();
         _highlightTarget = MonsterDebuggerUtils.getObjectUnderPoint(_stage,new Point(_stage.mouseX,_stage.mouseY));
         _highlightMouse = false;
         _highlight.removeEventListener(MouseEvent.CLICK,highlightClicked);
         _highlight.mouseEnabled = false;
         if(_highlightTarget != null)
         {
            inspect(_highlightTarget);
            highlightDraw(false);
         }
         send({"command":MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
      }
      
      internal static function hasPlugin(param1:String) : Boolean
      {
         return param1 in _plugins;
      }
      
      private static function monitorTimerCallback(param1:TimerEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:Object = null;
         if(MonsterDebugger.enabled)
         {
            _loc2_ = new Date().time;
            _loc3_ = _loc2_ - _monitorTime;
            _loc4_ = _monitorFrames / _loc3_ * 1000;
            _loc5_ = 0;
            if(_stage == null)
            {
               if(_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage)
               {
                  _stage = Stage(_base["stage"]);
               }
            }
            if(_stage != null)
            {
               _loc5_ = _stage.frameRate;
            }
            _monitorFrames = 0;
            _monitorTime = _loc2_;
            if(MonsterDebuggerConnection.connected)
            {
               _loc6_ = {
                  "command":MonsterDebuggerConstants.COMMAND_MONITOR,
                  "memory":MonsterDebuggerUtils.getMemory(),
                  "fps":_loc4_,
                  "fpsMovie":_loc5_,
                  "time":_loc2_
               };
               send(_loc6_);
            }
         }
      }
      
      internal static function breakpoint(param1:*, param2:String = "breakpoint") : void
      {
         var _loc3_:XML = null;
         var _loc4_:Object = null;
         if(MonsterDebugger.enabled && MonsterDebuggerConnection.connected)
         {
            _loc3_ = MonsterDebuggerUtils.stackTrace();
            _loc4_ = {
               "command":MonsterDebuggerConstants.COMMAND_PAUSE,
               "memory":MonsterDebuggerUtils.getMemory(),
               "date":new Date(),
               "target":String(param1),
               "reference":MonsterDebuggerUtils.getReferenceID(param1),
               "stack":_loc3_,
               "id":param2
            };
            send(_loc4_);
            MonsterDebuggerUtils.pause();
         }
      }
      
      private static function highlightClear() : void
      {
         if(_highlight != null && _highlight.parent != null)
         {
            _highlight.parent.removeChild(_highlight);
            _highlight.graphics.clear();
            _highlight.x = 0;
            _highlight.y = 0;
         }
         if(_highlightInfo != null && _highlightInfo.parent != null)
         {
            _highlightInfo.parent.removeChild(_highlightInfo);
            _highlightInfo.x = 0;
            _highlightInfo.y = 0;
         }
      }
   }
}

