package com.luaye.console.view
{
   import com.luaye.console.Console;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class PanelsManager
   {
      
      private static const USER_GRAPH_PREFIX:String = "graph_";
      
      private var _master:Console;
      
      private var _mainPanel:MainPanel;
      
      private var _tooltipField:TextField;
      
      private var _ruler:Ruler;
      
      public function PanelsManager(param1:Console, param2:MainPanel)
      {
         super();
         this._master = param1;
         this._tooltipField = new TextField();
         this._tooltipField.autoSize = TextFieldAutoSize.CENTER;
         this._tooltipField.multiline = true;
         this._tooltipField.background = true;
         this._tooltipField.backgroundColor = this._master.style.panelBackgroundColor;
         this._tooltipField.styleSheet = this._master.style.css;
         this._tooltipField.mouseEnabled = false;
         this._mainPanel = param2;
         this.addPanel(this._mainPanel);
      }
      
      public function panelExists(param1:String) : Boolean
      {
         return this._master.getChildByName(param1) as AbstractPanel ? true : false;
      }
      
      public function tooltip(param1:String = null, param2:AbstractPanel = null) : void
      {
         var _loc3_:Rectangle = null;
         var _loc4_:Rectangle = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(Boolean(param1) && !this.rulerActive)
         {
            param1 = param1.replace(/\:\:(.*)/,"<br/><s>$1</s>");
            this._master.addChild(this._tooltipField);
            this._tooltipField.wordWrap = false;
            this._tooltipField.htmlText = "<tooltip>" + param1 + "</tooltip>";
            if(this._tooltipField.width > 120)
            {
               this._tooltipField.width = 120;
               this._tooltipField.wordWrap = true;
            }
            this._tooltipField.x = this._master.mouseX - this._tooltipField.width / 2;
            this._tooltipField.y = this._master.mouseY + 20;
            if(param2)
            {
               _loc3_ = this._tooltipField.getBounds(this._master);
               _loc4_ = new Rectangle(param2.x,param2.y,param2.width,param2.height);
               _loc5_ = _loc3_.bottom - _loc4_.bottom;
               if(_loc5_ > 0)
               {
                  if(this._tooltipField.y - _loc5_ > this._master.mouseY + 15)
                  {
                     this._tooltipField.y -= _loc5_;
                  }
                  else if(_loc4_.y < this._master.mouseY - 24 && _loc3_.y > _loc4_.bottom)
                  {
                     this._tooltipField.y = this._master.mouseY - this._tooltipField.height - 15;
                  }
               }
               _loc6_ = _loc3_.left - _loc4_.left;
               _loc7_ = _loc3_.right - _loc4_.right;
               if(_loc6_ < 0)
               {
                  this._tooltipField.x -= _loc6_;
               }
               else if(_loc7_ > 0)
               {
                  this._tooltipField.x -= _loc7_;
               }
            }
         }
         else if(this._master.contains(this._tooltipField))
         {
            this._master.removeChild(this._tooltipField);
         }
      }
      
      public function fixGraphRange(param1:String, param2:Number = NaN, param3:Number = NaN) : void
      {
         var _loc4_:GraphingPanel = this.getPanel(USER_GRAPH_PREFIX + param1) as GraphingPanel;
         if(_loc4_)
         {
            _loc4_.fixRange(param2,param3);
         }
      }
      
      public function updateMenu() : void
      {
         this._mainPanel.updateMenu();
         var _loc1_:ChannelsPanel = this.getPanel(Console.PANEL_CHANNELS) as ChannelsPanel;
         if(_loc1_)
         {
            _loc1_.update();
         }
      }
      
      public function get mainPanel() : MainPanel
      {
         return this._mainPanel;
      }
      
      public function get displayRoller() : Boolean
      {
         return this.getPanel(Console.PANEL_ROLLER) as RollerPanel ? true : false;
      }
      
      public function getPanel(param1:String) : AbstractPanel
      {
         return this._master.getChildByName(param1) as AbstractPanel;
      }
      
      public function get channelsPanel() : Boolean
      {
         return this.getPanel(Console.PANEL_CHANNELS) as ChannelsPanel ? true : false;
      }
      
      private function onRulerExit(param1:Event) : void
      {
         if(Boolean(this._ruler) && this._master.contains(this._ruler))
         {
            this._master.removeChild(this._ruler);
         }
         this._ruler = null;
         this._mainPanel.updateMenu();
      }
      
      public function get memoryMonitor() : Boolean
      {
         return this.getPanel(Console.PANEL_MEMORY) as MemoryPanel != null;
      }
      
      public function get rulerActive() : Boolean
      {
         return Boolean(this._ruler) && this._master.contains(this._ruler) ? true : false;
      }
      
      public function set displayRoller(param1:Boolean) : void
      {
         var _loc2_:RollerPanel = null;
         if(this.displayRoller != param1)
         {
            if(param1)
            {
               _loc2_ = new RollerPanel(this._master);
               _loc2_.x = this._mainPanel.x + this._mainPanel.width - 160;
               _loc2_.y = this._mainPanel.y + 55;
               this.addPanel(_loc2_);
               _loc2_.start(this._master);
            }
            else
            {
               this.removePanel(Console.PANEL_ROLLER);
            }
            this._mainPanel.updateMenu();
         }
      }
      
      public function removePanel(param1:String) : void
      {
         var _loc2_:AbstractPanel = this._master.getChildByName(param1) as AbstractPanel;
         if(_loc2_)
         {
            _loc2_.close();
         }
      }
      
      public function set fpsMonitor(param1:Boolean) : void
      {
         var _loc2_:FPSPanel = null;
         if(this.fpsMonitor != param1)
         {
            if(param1)
            {
               _loc2_ = new FPSPanel(this._master);
               _loc2_.x = this._mainPanel.x + this._mainPanel.width - 160;
               _loc2_.y = this._mainPanel.y + 15;
               this.addPanel(_loc2_);
            }
            else
            {
               this.removePanel(Console.PANEL_FPS);
            }
            this._mainPanel.updateMenu();
         }
      }
      
      public function addPanel(param1:AbstractPanel) : void
      {
         if(this._master.contains(this._tooltipField))
         {
            this._master.addChildAt(param1,this._master.getChildIndex(this._tooltipField));
         }
         else
         {
            this._master.addChild(param1);
         }
         param1.addEventListener(AbstractPanel.STARTED_DRAGGING,this.onPanelStartDragScale,false,0,true);
         param1.addEventListener(AbstractPanel.STARTED_SCALING,this.onPanelStartDragScale,false,0,true);
      }
      
      public function set channelsPanel(param1:Boolean) : void
      {
         var _loc2_:ChannelsPanel = null;
         if(this.channelsPanel != param1)
         {
            if(param1)
            {
               _loc2_ = new ChannelsPanel(this._master);
               _loc2_.x = this._mainPanel.x + this._mainPanel.width - 332;
               _loc2_.y = this._mainPanel.y - 2;
               this.addPanel(_loc2_);
            }
            else
            {
               this.removePanel(Console.PANEL_CHANNELS);
               this.updateMenu();
            }
         }
      }
      
      public function removeGraph(param1:String, param2:Object = null, param3:String = null) : void
      {
         var _loc4_:GraphingPanel = this.getPanel(USER_GRAPH_PREFIX + param1) as GraphingPanel;
         if(_loc4_)
         {
            _loc4_.remove(param2,param3);
         }
      }
      
      public function addGraph(param1:String, param2:Object, param3:String, param4:Number = -1, param5:String = null, param6:Rectangle = null, param7:Boolean = false) : void
      {
         param1 = USER_GRAPH_PREFIX + param1;
         var _loc8_:GraphingPanel = this.getPanel(param1) as GraphingPanel;
         if(!_loc8_)
         {
            _loc8_ = new GraphingPanel(this._master,100,100);
            _loc8_.x = this._mainPanel.x + 80;
            _loc8_.y = this._mainPanel.y + 20;
            _loc8_.name = param1;
         }
         if(param6)
         {
            _loc8_.x = param6.x;
            _loc8_.y = param6.y;
            if(param6.width > 0)
            {
               _loc8_.width = param6.width;
            }
            if(param6.height > 0)
            {
               _loc8_.height = param6.height;
            }
         }
         _loc8_.inverse = param7;
         _loc8_.add(param2,param3,param4,param5);
         this.addPanel(_loc8_);
      }
      
      public function setPanelArea(param1:String, param2:Rectangle) : void
      {
         var _loc3_:AbstractPanel = this.getPanel(param1);
         if(_loc3_)
         {
            if(param2.x)
            {
               _loc3_.x = param2.x;
            }
            if(param2.y)
            {
               _loc3_.y = param2.y;
            }
            if(param2.width)
            {
               _loc3_.width = param2.width;
            }
            if(param2.height)
            {
               _loc3_.height = param2.height;
            }
         }
      }
      
      public function get fpsMonitor() : Boolean
      {
         return this.getPanel(Console.PANEL_FPS) as FPSPanel != null;
      }
      
      public function set memoryMonitor(param1:Boolean) : void
      {
         var _loc2_:MemoryPanel = null;
         if(this.memoryMonitor != param1)
         {
            if(param1)
            {
               _loc2_ = new MemoryPanel(this._master);
               _loc2_.x = this._mainPanel.x + this._mainPanel.width - 80;
               _loc2_.y = this._mainPanel.y + 15;
               this.addPanel(_loc2_);
            }
            else
            {
               this.removePanel(Console.PANEL_MEMORY);
            }
            this._mainPanel.updateMenu();
         }
      }
      
      public function startRuler() : void
      {
         if(this.rulerActive)
         {
            return;
         }
         this._ruler = new Ruler();
         this._ruler.addEventListener(Ruler.EXIT,this.onRulerExit,false,0,true);
         this._master.addChild(this._ruler);
         this._ruler.start(this._master);
         this._mainPanel.updateMenu();
      }
      
      private function onPanelStartDragScale(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:AbstractPanel = null;
         var _loc2_:AbstractPanel = param1.currentTarget as AbstractPanel;
         if(_loc2_.snapping)
         {
            _loc3_ = [0];
            _loc4_ = [0];
            if(this._master.stage)
            {
               _loc3_.push(this._master.stage.stageWidth);
               _loc4_.push(this._master.stage.stageHeight);
            }
            _loc5_ = this._master.numChildren;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = this._master.getChildAt(_loc6_) as AbstractPanel;
               if((Boolean(_loc7_)) && _loc7_.visible)
               {
                  _loc3_.push(_loc7_.x);
                  _loc3_.push(_loc7_.x + _loc7_.width);
                  _loc4_.push(_loc7_.y);
                  _loc4_.push(_loc7_.y + _loc7_.height);
               }
               _loc6_++;
            }
            _loc2_.registerSnaps(_loc3_,_loc4_);
         }
      }
   }
}

