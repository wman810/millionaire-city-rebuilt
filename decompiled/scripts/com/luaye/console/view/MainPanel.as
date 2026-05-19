package com.luaye.console.view
{
   import com.luaye.console.Console;
   import com.luaye.console.core.CommandLine;
   import com.luaye.console.core.Log;
   import com.luaye.console.core.Logs;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.system.SecurityPanel;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   
   public class MainPanel extends AbstractPanel
   {
      
      private static const CHANNELS_IN_MENU:int = 7;
      
      public static const TOOLTIPS:Object = {
         "fps":"Frames Per Second",
         "mm":"Memory Monitor",
         "roller":"Display Roller::Map the display list under your mouse",
         "ruler":"Screen Ruler::Measure the distance and angle between two points on screen.",
         "command":"Command Line",
         "copy":"Copy to clipboard",
         "clear":"Clear log",
         "trace":"Trace",
         "pause":"Pause updates",
         "resume":"Resume updates",
         "priority":"Priority filter",
         "channels":"Expand channels",
         "close":"Close",
         "closemain":"Close::Type password to show again",
         "viewall":"View all channels",
         "defaultch":"Default channel::Logs with no channel",
         "consolech":"Console\'s channel::Logs generated from Console",
         "filterch":"Filtering channel",
         "channel":"Change channel::Hold shift to select multiple channels",
         "scrollUp":"Scroll up",
         "scrollDown":"Scroll down",
         "scope":"Current scope::(CommandLine)"
      };
      
      private var _lines:Logs;
      
      private var _shift:Boolean;
      
      private var _commandPrefx:TextField;
      
      private var _enteringLogin:Boolean;
      
      public var topMenuClick:Function;
      
      private var _scrolldelay:uint;
      
      private var _scroller:Sprite;
      
      private var _needUpdateMenu:Boolean;
      
      private var _lockScrollUpdate:Boolean;
      
      private var _scrolldir:int;
      
      private var _extraMenuKeys:Array = [];
      
      private var _scrollbar:Sprite;
      
      private var _atBottom:Boolean = true;
      
      private var _commandsHistory:Array = [];
      
      private var _canUseTrace:Boolean;
      
      private var _channels:Array;
      
      private var _needUpdateTrace:Boolean;
      
      private var _commandField:TextField;
      
      private var _traceField:TextField;
      
      private var _commandBackground:Shape;
      
      private var _menuField:TextField;
      
      public var topMenuRollOver:Function;
      
      private var _bottomLine:Shape;
      
      private var _isMinimised:Boolean;
      
      private var _commandsInd:int;
      
      public function MainPanel(param1:Console, param2:Logs, param3:Array)
      {
         super(param1);
         this._canUseTrace = Capabilities.playerType == "External" || Capabilities.isDebugger;
         this._channels = param3;
         this._lines = param2;
         name = Console.PANEL_MAIN;
         minimumWidth = 50;
         minimumHeight = 18;
         this._traceField = new TextField();
         this._traceField.name = "traceField";
         this._traceField.wordWrap = true;
         this._traceField.background = false;
         this._traceField.multiline = true;
         this._traceField.styleSheet = style.css;
         this._traceField.y = 12;
         this._traceField.addEventListener(Event.SCROLL,this.onTraceScroll,false,0,true);
         addChild(this._traceField);
         this._menuField = new TextField();
         this._menuField.name = "menuField";
         this._menuField.styleSheet = style.css;
         this._menuField.height = 18;
         this._menuField.y = -2;
         registerRollOverTextField(this._menuField);
         this._menuField.addEventListener(AbstractPanel.TEXT_LINK,this.onMenuRollOver,false,0,true);
         addChild(this._menuField);
         this._commandBackground = new Shape();
         this._commandBackground.name = "commandBackground";
         this._commandBackground.graphics.beginFill(style.commandLineColor,0.1);
         this._commandBackground.graphics.drawRoundRect(0,0,100,18,12,12);
         this._commandBackground.scale9Grid = new Rectangle(9,9,80,1);
         addChild(this._commandBackground);
         this._commandField = new TextField();
         this._commandField.name = "commandField";
         this._commandField.type = TextFieldType.INPUT;
         this._commandField.x = 40;
         this._commandField.height = 18;
         this._commandField.addEventListener(KeyboardEvent.KEY_DOWN,this.commandKeyDown,false,0,true);
         this._commandField.addEventListener(KeyboardEvent.KEY_UP,this.commandKeyUp,false,0,true);
         this._commandField.defaultTextFormat = style.textFormat;
         addChild(this._commandField);
         this._commandPrefx = new TextField();
         this._commandPrefx.name = "commandPrefx";
         this._commandPrefx.type = TextFieldType.DYNAMIC;
         this._commandPrefx.x = 2;
         this._commandPrefx.height = 18;
         this._commandPrefx.selectable = false;
         this._commandPrefx.styleSheet = style.css;
         this._commandPrefx.text = " ";
         this._commandPrefx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCmdPrefMouseDown,false,0,true);
         this._commandPrefx.addEventListener(MouseEvent.MOUSE_MOVE,this.onCmdPrefRollOverOut,false,0,true);
         this._commandPrefx.addEventListener(MouseEvent.ROLL_OUT,this.onCmdPrefRollOverOut,false,0,true);
         addChild(this._commandPrefx);
         this._bottomLine = new Shape();
         this._bottomLine.name = "blinkLine";
         this._bottomLine.alpha = 0.2;
         addChild(this._bottomLine);
         this._scrollbar = new Sprite();
         this._scrollbar.name = "scrollbar";
         this._scrollbar.buttonMode = true;
         this._scrollbar.addEventListener(MouseEvent.MOUSE_DOWN,this.onScrollbarDown,false,0,true);
         this._scrollbar.y = 16;
         addChild(this._scrollbar);
         this._scroller = new Sprite();
         this._scroller.name = "scroller";
         this._scroller.graphics.beginFill(style.panelScalerColor,1);
         this._scroller.graphics.drawRect(-5,0,5,30);
         this._scroller.graphics.beginFill(0,0);
         this._scroller.graphics.drawRect(-10,0,10,30);
         this._scroller.graphics.endFill();
         this._scroller.buttonMode = true;
         this._scroller.addEventListener(MouseEvent.MOUSE_DOWN,this.onScrollerDown,false,0,true);
         addChild(this._scroller);
         this._commandField.visible = false;
         this._commandPrefx.visible = false;
         this._commandBackground.visible = false;
         init(420,100,true);
         registerDragger(this._menuField);
         addEventListener(TextEvent.LINK,this.linkHandler,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle,false,0,true);
         master.cl.addEventListener(CommandLine.CHANGED_SCOPE,this.onUpdateCommandLineScope,false,0,true);
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.SHIFT)
         {
            this._shift = true;
         }
      }
      
      private function makeLine(param1:Log) : String
      {
         var _loc2_:String = "";
         var _loc3_:String = param1.text;
         if(master.prefixChannelNames && (master.viewingChannels.indexOf(Console.GLOBAL_CHANNEL) >= 0 || master.viewingChannels.length > 1) && param1.c != Console.DEFAULT_CHANNEL)
         {
            _loc3_ = "[<a href=\"event:channel_" + param1.c + "\">" + param1.c + "</a>] " + _loc3_;
         }
         var _loc4_:String = "p" + param1.p;
         return _loc2_ + ("<p><" + _loc4_ + ">" + _loc3_ + "</" + _loc4_ + "></p>");
      }
      
      private function linkHandler(param1:TextEvent) : void
      {
         var _loc2_:String = null;
         this._menuField.setSelection(0,0);
         stopDrag();
         if(this.topMenuClick != null && Boolean(this.topMenuClick(param1.text)))
         {
            return;
         }
         if(param1.text == "pause")
         {
            if(master.paused)
            {
               master.paused = false;
               master.panels.tooltip(TOOLTIPS["pause"],this);
            }
            else
            {
               master.paused = true;
               master.panels.tooltip(TOOLTIPS["resume"],this);
            }
         }
         else if(param1.text == "trace")
         {
            master.tracing = !master.tracing;
            if(master.tracing)
            {
               master.report("Tracing turned [<b>On</b>]",-1);
            }
            else
            {
               master.report("Tracing turned [<b>Off</b>]",-1);
            }
         }
         else if(param1.text == "close")
         {
            master.panels.tooltip();
            visible = false;
         }
         else if(param1.text == "channels")
         {
            master.channelsPanel = !master.channelsPanel;
         }
         else if(param1.text == "fps")
         {
            master.fpsMonitor = !master.fpsMonitor;
         }
         else if(param1.text == "priority")
         {
            if(master.priority < 10)
            {
               ++master.priority;
            }
            else
            {
               master.priority = 0;
            }
         }
         else if(param1.text == "mm")
         {
            master.memoryMonitor = !master.memoryMonitor;
         }
         else if(param1.text == "roller")
         {
            master.displayRoller = !master.displayRoller;
         }
         else if(param1.text == "ruler")
         {
            master.panels.tooltip();
            master.panels.startRuler();
         }
         else if(param1.text == "command")
         {
            this.commandLine = !this.commandLine;
         }
         else if(param1.text == "copy")
         {
            System.setClipboard(master.getAllLog());
            master.report("Copied log to clipboard.",-1);
         }
         else if(param1.text == "clear")
         {
            master.clear();
         }
         else if(param1.text == "settings")
         {
            master.report("A new window should open in browser. If not, try searching for \'Flash Player Global Security Settings panel\' online :)",-1);
            Security.showSettings(SecurityPanel.SETTINGS_MANAGER);
         }
         else if(param1.text.substring(0,8) == "channel_")
         {
            this.onChannelPressed(param1.text.substring(8));
         }
         else if(param1.text.substring(0,5) == "clip_")
         {
            _loc2_ = "/remap " + param1.text.substring(5);
            master.runCommand(_loc2_);
         }
         else if(param1.text.substring(0,6) == "sclip_")
         {
            master.runCommand("/remap 0" + Console.MAPPING_SPLITTER + param1.text.substring(6));
         }
         this._menuField.setSelection(0,0);
         param1.stopPropagation();
      }
      
      public function onChannelPressed(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Array = master.viewingChannels.concat();
         if(this._shift && master.viewingChannel != Console.GLOBAL_CHANNEL && param1 != Console.GLOBAL_CHANNEL)
         {
            _loc3_ = _loc2_.indexOf(param1);
            if(_loc3_ >= 0)
            {
               _loc2_.splice(_loc3_,1);
               if(_loc2_.length == 0)
               {
                  _loc2_.push(Console.GLOBAL_CHANNEL);
               }
            }
            else
            {
               _loc2_.push(param1);
            }
            master.viewingChannels = _loc2_;
         }
         else
         {
            master.viewingChannel = param1;
         }
      }
      
      override public function set width(param1:Number) : void
      {
         this._lockScrollUpdate = true;
         super.width = param1;
         this._traceField.width = param1 - 4;
         this._menuField.width = param1;
         this._commandField.width = width - 15 - this._commandField.x;
         this._commandBackground.width = param1;
         this._bottomLine.graphics.clear();
         this._bottomLine.graphics.lineStyle(1,style.bottomLineColor);
         this._bottomLine.graphics.moveTo(10,-1);
         this._bottomLine.graphics.lineTo(param1 - 10,-1);
         this._scroller.x = param1;
         this._scrollbar.x = param1;
         this.onUpdateCommandLineScope();
         this._atBottom = true;
         this._needUpdateMenu = true;
         this._needUpdateTrace = true;
         this._lockScrollUpdate = false;
      }
      
      private function keyUpHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.SHIFT)
         {
            this._shift = false;
         }
      }
      
      public function updateCLScope(param1:String) : void
      {
         if(this._enteringLogin)
         {
            this._enteringLogin = false;
            this.requestLogin(false);
         }
         this._commandPrefx.autoSize = TextFieldAutoSize.LEFT;
         this._commandPrefx.htmlText = "<w><p1>" + param1 + ":</p1></w>";
         var _loc2_:Number = width - 48;
         if(this._commandPrefx.width > 120 || this._commandPrefx.width > _loc2_)
         {
            this._commandPrefx.autoSize = TextFieldAutoSize.NONE;
            this._commandPrefx.width = _loc2_ > 120 ? 120 : _loc2_;
            this._commandPrefx.scrollH = this._commandPrefx.maxScrollH;
         }
         this._commandField.x = this._commandPrefx.width + 2;
         this._commandField.width = width - 15 - this._commandField.x;
      }
      
      private function onTraceScroll(param1:Event = null) : void
      {
         var _loc3_:int = 0;
         if(this._lockScrollUpdate)
         {
            return;
         }
         var _loc2_:Boolean = this._traceField.scrollV >= this._traceField.maxScrollV - 1;
         if(!master.paused && this._atBottom != _loc2_)
         {
            _loc3_ = this._traceField.maxScrollV - this._traceField.scrollV;
            this._atBottom = _loc2_;
            this._updateTraces();
            this._traceField.scrollV = this._traceField.maxScrollV - _loc3_;
         }
         this.updateScroller();
      }
      
      public function requestLogin(param1:Boolean = true) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         if(param1)
         {
            master.commandLine = true;
            master.report("//",-2);
            master.report("// <b>Enter remoting password</b> in CommandLine below...",-2);
            this.updateCLScope("Password");
            _loc2_.color = style.bottomLineColor;
            this._commandBackground.transform.colorTransform = _loc2_;
            this._traceField.transform.colorTransform = new ColorTransform(0.7,0.7,0.7);
         }
         else
         {
            this.updateCLScope("?");
            this._commandBackground.transform.colorTransform = _loc2_;
            this._traceField.transform.colorTransform = _loc2_;
         }
         this._commandField.displayAsPassword = param1;
         this._enteringLogin = param1;
      }
      
      public function addMenuKey(param1:String) : void
      {
         this._extraMenuKeys.push(param1);
         this._needUpdateMenu = true;
      }
      
      private function updateScroller() : void
      {
         var _loc1_:Number = NaN;
         if(this._traceField.maxScrollV <= 1 || this.scrollerMaxY < 22)
         {
            this._scroller.visible = false;
            this._scrollbar.visible = false;
         }
         else
         {
            this._scrollbar.visible = true;
            this._scroller.visible = true;
            if(this._atBottom)
            {
               this._scroller.y = this.scrollerMaxY;
            }
            else
            {
               _loc1_ = (this._traceField.scrollV - 1) / (this._traceField.maxScrollV - 1);
               this._scroller.y = 21 + (this.scrollerMaxY - 21) * _loc1_;
            }
         }
      }
      
      private function onCmdPrefRollOverOut(param1:MouseEvent) : void
      {
         master.panels.tooltip(param1.type == MouseEvent.MOUSE_MOVE ? TOOLTIPS["scope"] : "",this);
      }
      
      private function onScrollerMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = 21;
         var _loc3_:Number = (this._scroller.y - _loc2_) / (this.scrollerMaxY - _loc2_);
         this._lockScrollUpdate = true;
         this._traceField.scrollV = Math.round(_loc3_ * (this._traceField.maxScrollV - 1) + 1);
         this._lockScrollUpdate = false;
      }
      
      public function setPaused(param1:Boolean) : void
      {
         if(param1 && this._atBottom)
         {
            this._atBottom = false;
            this.updateTraces(true);
            this._traceField.scrollV = this._traceField.maxScrollV;
         }
         else if(!param1)
         {
            this._atBottom = true;
            this.updateBottom();
         }
         this.updateMenu();
      }
      
      private function onScrollerUp(param1:MouseEvent) : void
      {
         this._scroller.stopDrag();
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onScrollerMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onScrollerUp);
         this.onTraceScroll();
      }
      
      public function set commandLine(param1:Boolean) : void
      {
         if(param1 && master.commandLineAllowed > 0)
         {
            this._commandField.visible = true;
            this._commandPrefx.visible = true;
            this._commandBackground.visible = true;
         }
         else
         {
            this._commandField.visible = false;
            this._commandPrefx.visible = false;
            this._commandBackground.visible = false;
         }
         this.height = height;
      }
      
      private function onScrollBarFrame(param1:Event) : void
      {
         ++this._scrolldelay;
         if(this._scrolldelay > 10)
         {
            this._scrolldelay = 9;
            if(this._scrolldir < 0 && this._scroller.y > mouseY || this._scrolldir > 0 && this._scroller.y + this._scroller.height < mouseY)
            {
               this._traceField.scrollV += this._scrolldir;
            }
         }
      }
      
      public function update(param1:Boolean) : void
      {
         if(this._bottomLine.alpha > 0)
         {
            this._bottomLine.alpha -= 0.25;
         }
         if(param1)
         {
            this._bottomLine.alpha = 1;
            this._needUpdateMenu = true;
            this._needUpdateTrace = true;
         }
         if(this._needUpdateTrace)
         {
            this._needUpdateTrace = false;
            this._updateTraces(true);
         }
         if(this._needUpdateMenu)
         {
            this._needUpdateMenu = false;
            this._updateMenu();
         }
      }
      
      private function get scrollerMaxY() : Number
      {
         return this._bottomLine.y - this._scroller.height - (this._commandField.visible ? 5 : 15);
      }
      
      private function onScrollbarDown(param1:MouseEvent) : void
      {
         if(this._scroller.mouseY > 0)
         {
            this._traceField.scrollV += 3;
            this._scrolldir = 3;
         }
         else
         {
            this._traceField.scrollV -= 3;
            this._scrolldir = -3;
         }
         this._scrolldelay = 0;
         this._scrollbar.addEventListener(Event.ENTER_FRAME,this.onScrollBarFrame,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onScrollBarUp,false,0,true);
      }
      
      private function stageRemovedHandle(param1:Event = null) : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
      }
      
      private function _updateTraces(param1:Boolean = false) : void
      {
         if(this._atBottom)
         {
            this.updateBottom();
         }
         else if(!param1)
         {
            this.updateFull();
         }
      }
      
      public function updateMenu(param1:Boolean = false) : void
      {
         if(param1)
         {
            this._updateMenu();
         }
         else
         {
            this._needUpdateMenu = true;
         }
      }
      
      private function updateBottom() : void
      {
         var _loc1_:Array = new Array();
         var _loc2_:* = int(Math.round(this._traceField.height / 10));
         var _loc3_:Log = this._lines.last;
         while(_loc3_)
         {
            if(master.lineShouldShow(_loc3_))
            {
               _loc2_--;
               _loc1_.push(this.makeLine(_loc3_));
               if(_loc2_ <= 0)
               {
                  break;
               }
            }
            _loc3_ = _loc3_.prev;
         }
         this._lockScrollUpdate = true;
         this._traceField.htmlText = _loc1_.reverse().join("");
         this._traceField.scrollV = this._traceField.maxScrollV;
         this._lockScrollUpdate = false;
         this.updateScroller();
      }
      
      override public function set height(param1:Number) : void
      {
         this._lockScrollUpdate = true;
         super.height = param1;
         var _loc2_:Boolean = false;
         if(param1 < (this._commandField.visible ? 42 : 24))
         {
            _loc2_ = true;
         }
         if(this._isMinimised != _loc2_)
         {
            registerDragger(this._menuField,_loc2_);
            registerDragger(this._traceField,!_loc2_);
            this._isMinimised = _loc2_;
         }
         this._menuField.visible = !_loc2_;
         this._traceField.y = _loc2_ ? 0 : 12;
         this._traceField.height = param1 - (this._commandField.visible ? 16 : 0) - (_loc2_ ? 0 : 12);
         var _loc3_:Number = param1 - 18;
         this._commandField.y = _loc3_;
         this._commandPrefx.y = _loc3_;
         this._commandBackground.y = _loc3_;
         this._bottomLine.y = this._commandField.visible ? _loc3_ : param1;
         var _loc4_:Number = this._bottomLine.y - (this._commandField.visible ? 0 : 10) - this._scrollbar.y;
         this._scrollbar.graphics.clear();
         this._scrollbar.graphics.beginFill(style.panelScalerColor,0.7);
         this._scrollbar.graphics.drawRect(-5,0,5,5);
         this._scrollbar.graphics.drawRect(-5,_loc4_ - 5,5,5);
         this._scrollbar.graphics.beginFill(style.panelScalerColor,0.25);
         this._scrollbar.graphics.drawRect(-5,5,5,_loc4_ - 10);
         this._scrollbar.graphics.endFill();
         this._atBottom = true;
         this._needUpdateTrace = true;
         this._lockScrollUpdate = false;
      }
      
      public function get commandLine() : Boolean
      {
         return this._commandField.visible;
      }
      
      public function getChannelsLink(param1:Boolean = false) : String
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:String = "<chs>";
         var _loc3_:int = int(this._channels.length);
         if(param1 && _loc3_ > CHANNELS_IN_MENU)
         {
            _loc3_ = CHANNELS_IN_MENU;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = this._channels[_loc4_];
            _loc6_ = master.viewingChannels.indexOf(_loc5_) >= 0 ? "<ch><b>" + _loc5_ + "</b></ch>" : _loc5_;
            _loc2_ += "<a href=\"event:channel_" + _loc5_ + "\">[" + _loc6_ + "]</a> ";
            _loc4_++;
         }
         if(param1)
         {
            _loc2_ += "<ch><a href=\"event:channels\"><b>" + (this._channels.length > _loc3_ ? "..." : "") + "</b>^^ </a></ch>";
         }
         return _loc2_ + "</chs> ";
      }
      
      private function onScrollBarUp(param1:Event) : void
      {
         this._scrollbar.removeEventListener(Event.ENTER_FRAME,this.onScrollBarFrame);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onScrollBarUp);
      }
      
      private function onUpdateCommandLineScope(param1:Event = null) : void
      {
         if(!master.remote)
         {
            this.updateCLScope(master.cl.scopeString);
         }
      }
      
      private function _updateMenu() : void
      {
         var _loc2_:String = null;
         var _loc1_:String = "<r><w>";
         if(!master.channelsPanel)
         {
            _loc1_ += this.getChannelsLink(true);
         }
         _loc1_ += "<menu>[ <b>";
         _loc1_ += this.doActive("<a href=\"event:fps\">F</a>",master.fpsMonitor > 0);
         _loc1_ += this.doActive(" <a href=\"event:mm\">M</a>",master.memoryMonitor > 0);
         if(master.commandLineAllowed)
         {
            _loc1_ += this.doActive(" <a href=\"event:command\">CL</a>",this.commandLine);
         }
         if(!master.remote)
         {
            _loc1_ += this.doActive(" <a href=\"event:roller\">Ro</a>",master.displayRoller);
            _loc1_ += this.doActive(" <a href=\"event:ruler\">RL</a>",master.panels.rulerActive);
         }
         _loc1_ += " ¦</b>";
         for each(_loc2_ in this._extraMenuKeys)
         {
            _loc1_ += " <a href=\"event:" + _loc2_ + "\">" + _loc2_ + "</a>";
         }
         if(this._canUseTrace)
         {
            _loc1_ += this.doActive(" <a href=\"event:trace\">T</a>",master.tracing);
         }
         _loc1_ += " <a href=\"event:copy\">Cc</a>";
         _loc1_ += " <a href=\"event:priority\">P" + master.priority + "</a>";
         _loc1_ += this.doActive(" <a href=\"event:pause\">P</a>",master.paused);
         _loc1_ += " <a href=\"event:clear\">C</a> <a href=\"event:close\">X</a>";
         _loc1_ += " ]</menu> </w></r>";
         this._menuField.htmlText = _loc1_;
         this._menuField.scrollH = this._menuField.maxScrollH;
      }
      
      private function onCmdPrefMouseDown(param1:MouseEvent) : void
      {
         stage.focus = this._commandField;
         this._commandField.setSelection(this._commandField.text.length,this._commandField.text.length);
      }
      
      private function stageAddedHandle(param1:Event = null) : void
      {
         stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
      }
      
      private function commandKeyDown(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
      }
      
      public function updateToBottom() : void
      {
         this._atBottom = true;
         this._needUpdateTrace = true;
      }
      
      private function doActive(param1:String, param2:Boolean) : String
      {
         if(param2)
         {
            return "<y>" + param1 + "</y>";
         }
         return param1;
      }
      
      public function updateTraces(param1:Boolean = false) : void
      {
         if(param1)
         {
            this._updateTraces();
         }
         else
         {
            this._needUpdateTrace = true;
         }
      }
      
      private function onScrollerDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!master.paused)
         {
            this._atBottom = false;
            _loc2_ = this._scroller.y;
            this._updateTraces();
            this._scroller.y = _loc2_;
         }
         this._scroller.startDrag(false,new Rectangle(this._scroller.x,21,0,this.scrollerMaxY - 21));
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onScrollerMove,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onScrollerUp,false,0,true);
      }
      
      private function commandKeyUp(param1:KeyboardEvent) : void
      {
         if(!master.enabled)
         {
            return;
         }
         if(param1.keyCode == 13)
         {
            if(this._enteringLogin)
            {
               master.sendLogin(this._commandField.text);
               this._commandField.text = "";
               this.requestLogin(false);
            }
            else
            {
               master.runCommand(this._commandField.text);
               this._commandsHistory.unshift(this._commandField.text);
               this._commandsInd = -1;
               this._commandField.text = "";
               if(this._commandsHistory.length > 20)
               {
                  this._commandsHistory.splice(20);
               }
            }
         }
         else if(param1.keyCode == 38)
         {
            if(Boolean(this._commandField.text) && this._commandsInd < 0)
            {
               this._commandsHistory.unshift(this._commandField.text);
               ++this._commandsInd;
            }
            if(this._commandsInd < this._commandsHistory.length - 1)
            {
               ++this._commandsInd;
               this._commandField.text = this._commandsHistory[this._commandsInd];
               this._commandField.setSelection(this._commandField.text.length,this._commandField.text.length);
            }
            else
            {
               this._commandsInd = this._commandsHistory.length;
               this._commandField.text = "";
            }
         }
         else if(param1.keyCode == 40)
         {
            if(this._commandsInd > 0)
            {
               --this._commandsInd;
               this._commandField.text = this._commandsHistory[this._commandsInd];
               this._commandField.setSelection(this._commandField.text.length,this._commandField.text.length);
            }
            else
            {
               this._commandsInd = -1;
               this._commandField.text = "";
            }
         }
         param1.stopPropagation();
      }
      
      public function onMenuRollOver(param1:TextEvent, param2:AbstractPanel = null) : void
      {
         var _loc4_:String = null;
         if(param2 == null)
         {
            param2 = this;
         }
         var _loc3_:String = param1.text ? param1.text.replace("event:","") : "";
         if(this.topMenuRollOver != null)
         {
            _loc4_ = this.topMenuRollOver(_loc3_);
            if(_loc4_)
            {
               master.panels.tooltip(_loc4_,param2);
               return;
            }
         }
         if(_loc3_ == "channel_" + Console.GLOBAL_CHANNEL)
         {
            _loc3_ = TOOLTIPS["viewall"];
         }
         else if(_loc3_ == "channel_" + Console.DEFAULT_CHANNEL)
         {
            _loc3_ = TOOLTIPS["defaultch"];
         }
         else if(_loc3_ == "channel_" + Console.CONSOLE_CHANNEL)
         {
            _loc3_ = TOOLTIPS["consolech"];
         }
         else if(_loc3_ == "channel_" + Console.FILTERED_CHANNEL)
         {
            _loc3_ = TOOLTIPS["filterch"] + "::*" + master.filterText + "*";
         }
         else if(_loc3_.indexOf("channel_") == 0)
         {
            _loc3_ = TOOLTIPS["channel"];
         }
         else if(_loc3_ == "pause")
         {
            if(master.paused)
            {
               _loc3_ = TOOLTIPS["resume"];
            }
            else
            {
               _loc3_ = TOOLTIPS["pause"];
            }
         }
         else if(_loc3_ == "copy")
         {
            _loc3_ = TOOLTIPS["copy"];
         }
         else if(_loc3_ == "close" && param2 == this)
         {
            _loc3_ = TOOLTIPS["closemain"];
         }
         else
         {
            _loc3_ = TOOLTIPS[_loc3_];
         }
         master.panels.tooltip(_loc3_,param2);
      }
      
      private function updateFull() : void
      {
         var _loc1_:String = "";
         var _loc2_:Log = this._lines.first;
         while(_loc2_)
         {
            if(master.lineShouldShow(_loc2_))
            {
               _loc1_ += this.makeLine(_loc2_);
            }
            _loc2_ = _loc2_.next;
         }
         this._lockScrollUpdate = true;
         this._traceField.htmlText = _loc1_;
         this._lockScrollUpdate = false;
         this.updateScroller();
      }
   }
}

