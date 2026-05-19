package com.luaye.console.view
{
   import com.luaye.console.Console;
   import com.luaye.console.utils.Utils;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.text.TextField;
   
   public class GraphingPanel extends AbstractPanel
   {
      
      private var _drawnFrame:uint = 0;
      
      private var _interests:Array = [];
      
      protected var keyTxt:TextField;
      
      public var averaging:uint;
      
      public var highest:Number;
      
      public var inverse:Boolean;
      
      public var lowest:Number;
      
      private var _isRunning:Boolean;
      
      public var drawEvery:uint = 1;
      
      private var _needRedraw:Boolean;
      
      protected var graph:Shape;
      
      private var _updatedFrame:uint = 0;
      
      public var updateEvery:uint = 1;
      
      protected var _history:Array = [];
      
      protected var highTxt:TextField;
      
      protected var fixed:Boolean;
      
      protected var lowTxt:TextField;
      
      public function GraphingPanel(param1:Console, param2:int = 0, param3:int = 0, param4:Boolean = true)
      {
         super(param1);
         registerDragger(bg);
         minimumHeight = 26;
         this.lowTxt = new TextField();
         this.lowTxt.name = "lowestField";
         this.lowTxt.mouseEnabled = false;
         this.lowTxt.styleSheet = style.css;
         this.lowTxt.height = 14;
         addChild(this.lowTxt);
         this.highTxt = new TextField();
         this.highTxt.name = "highestField";
         this.highTxt.mouseEnabled = false;
         this.highTxt.styleSheet = style.css;
         this.highTxt.height = 14;
         this.highTxt.y = 6;
         addChild(this.highTxt);
         this.keyTxt = new TextField();
         this.keyTxt.name = "menuField";
         this.keyTxt.styleSheet = style.css;
         this.keyTxt.height = 16;
         this.keyTxt.y = -3;
         this.keyTxt.addEventListener(TextEvent.LINK,this.linkHandler,false,0,true);
         registerRollOverTextField(this.keyTxt);
         this.keyTxt.addEventListener(AbstractPanel.TEXT_LINK,this.onMenuRollOver,false,0,true);
         registerDragger(this.keyTxt);
         addChild(this.keyTxt);
         this.graph = new Shape();
         this.graph.name = "graph";
         this.graph.y = 10;
         addChild(this.graph);
         init(param2 ? param2 : 100,param3 ? param3 : 80,param4);
      }
      
      public function stop() : void
      {
         this._isRunning = false;
         removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      public function remove(param1:Object = null, param2:String = null) : void
      {
         var _loc3_:String = null;
         var _loc4_:Interest = null;
         for(_loc3_ in this._interests)
         {
            _loc4_ = this._interests[_loc3_];
            if((Boolean(_loc4_)) && (Boolean(_loc4_.obj == null || _loc4_.obj == param1)) && (_loc4_.prop == null || _loc4_.prop == param2))
            {
               this._interests.splice(int(_loc3_),1);
            }
         }
         if(this._interests.length == 0)
         {
            this.close();
         }
         else
         {
            this.updateKeyText();
         }
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         this.lowTxt.width = param1;
         this.highTxt.width = param1;
         this.keyTxt.width = param1;
         graphics.clear();
         graphics.lineStyle(1,11184810,1);
         graphics.moveTo(0,this.graph.y);
         graphics.lineTo(param1,this.graph.y);
         this._needRedraw = true;
      }
      
      protected function updateData() : void
      {
         var _loc2_:Interest = null;
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         ++this._updatedFrame;
         if(this._updatedFrame < this.updateEvery)
         {
            return;
         }
         this._updatedFrame = 0;
         var _loc1_:Array = [];
         for each(_loc2_ in this._interests)
         {
            _loc5_ = _loc2_.obj;
            if(_loc5_)
            {
               _loc6_ = Number(_loc5_[_loc2_.prop]);
               if(isNaN(_loc6_))
               {
                  _loc6_ = 0;
               }
               else
               {
                  if(isNaN(this.lowest))
                  {
                     this.lowest = _loc6_;
                  }
                  if(isNaN(this.highest))
                  {
                     this.highest = _loc6_;
                  }
               }
               _loc1_.push(_loc6_);
               if(this.averaging > 0)
               {
                  _loc7_ = _loc2_.avg;
                  if(isNaN(_loc7_))
                  {
                     _loc2_.avg = _loc6_;
                  }
                  else
                  {
                     _loc2_.avg = Utils.averageOut(_loc7_,_loc6_,this.averaging);
                  }
               }
               if(!this.fixed)
               {
                  if(_loc6_ > this.highest)
                  {
                     this.highest = _loc6_;
                  }
                  if(_loc6_ < this.lowest)
                  {
                     this.lowest = _loc6_;
                  }
               }
            }
            else
            {
               this.remove(_loc5_,_loc2_.prop);
            }
         }
         this._history.push(_loc1_);
         _loc3_ = Math.floor(width) + 10;
         _loc4_ = this._history.length;
         if(_loc4_ > _loc3_)
         {
            this._history.splice(0,_loc4_ - _loc3_);
         }
      }
      
      protected function getAverageOf(param1:int) : Number
      {
         var _loc2_:Interest = this._interests[param1];
         return _loc2_ ? _loc2_.avg : 0;
      }
      
      public function add(param1:Object, param2:String, param3:Number = -1, param4:String = null) : void
      {
         var _loc5_:Number = Number(param1[param2]);
         if(!isNaN(_loc5_))
         {
            if(isNaN(this.lowest))
            {
               this.lowest = _loc5_;
            }
            if(isNaN(this.highest))
            {
               this.highest = _loc5_;
            }
         }
         if(isNaN(param3) || param3 < 0)
         {
            param3 = Math.random() * 16777215;
         }
         if(param4 == null)
         {
            param4 = param2;
         }
         this._interests.push(new Interest(param1,param2,param3,param4));
         this.updateKeyText();
         this.start();
      }
      
      public function get numInterests() : int
      {
         return this._interests.length;
      }
      
      public function get rand() : Number
      {
         return Math.random();
      }
      
      public function fixRange(param1:Number, param2:Number) : void
      {
         if(isNaN(param1) || isNaN(param2))
         {
            this.fixed = false;
            return;
         }
         this.fixed = true;
         this.lowest = param1;
         this.highest = param2;
      }
      
      public function updateKeyText() : void
      {
         var _loc2_:Interest = null;
         var _loc1_:String = "<r><s>";
         for each(_loc2_ in this._interests)
         {
            _loc1_ += " <font color=\'#" + _loc2_.col.toString(16) + "\'>" + _loc2_.key + "</font>";
         }
         _loc1_ += " | <menu><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></s></r>";
         this.keyTxt.htmlText = _loc1_;
      }
      
      public function set showBoundsText(param1:Boolean) : void
      {
         this.lowTxt.visible = param1;
         this.highTxt.visible = param1;
      }
      
      public function get running() : Boolean
      {
         return this._isRunning;
      }
      
      public function reset() : void
      {
         if(!this.fixed)
         {
            this.lowest = NaN;
            this.highest = NaN;
         }
         this._history = [];
         this.graph.graphics.clear();
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         this.lowTxt.y = param1 - 13;
         this._needRedraw = true;
      }
      
      public function set showKeyText(param1:Boolean) : void
      {
         this.keyTxt.visible = param1;
      }
      
      public function get showBoundsText() : Boolean
      {
         return this.lowTxt.visible;
      }
      
      public function start() : void
      {
         this._isRunning = true;
         addEventListener(Event.ENTER_FRAME,this.onFrame,false,0,true);
      }
      
      protected function onFrame(param1:Event) : Boolean
      {
         var _loc2_:Boolean = master.visible && master.enabled && !master.paused;
         if(_loc2_)
         {
            this.updateData();
         }
         if(_loc2_ || this._needRedraw)
         {
            this.drawGraph();
         }
         return _loc2_;
      }
      
      public function drawGraph() : void
      {
         var _loc7_:Interest = null;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         var _loc11_:Number = NaN;
         ++this._drawnFrame;
         if(!this._needRedraw && this._drawnFrame < this.drawEvery)
         {
            return;
         }
         this._needRedraw = false;
         this._drawnFrame = 0;
         var _loc1_:Number = width;
         var _loc2_:Number = height - this.graph.y;
         this.graph.graphics.clear();
         var _loc3_:Number = this.highest - this.lowest;
         var _loc4_:int = int(this._interests.length);
         var _loc5_:int = int(this._history.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = this._interests[_loc6_];
            _loc8_ = true;
            _loc9_ = 1;
            while(_loc9_ < _loc1_)
            {
               if(_loc5_ < _loc9_)
               {
                  break;
               }
               _loc10_ = this._history[_loc5_ - _loc9_];
               if(_loc8_)
               {
                  this.graph.graphics.lineStyle(1,_loc7_.col);
               }
               _loc11_ = (_loc3_ ? (_loc10_[_loc6_] - this.lowest) / _loc3_ : 0.5) * _loc2_;
               if(!this.inverse)
               {
                  _loc11_ = _loc2_ - _loc11_;
               }
               if(_loc11_ < 0)
               {
                  _loc11_ = 0;
               }
               if(_loc11_ > _loc2_)
               {
                  _loc11_ = _loc2_;
               }
               this.graph.graphics[_loc8_ ? "moveTo" : "lineTo"](_loc1_ - _loc9_,_loc11_);
               _loc8_ = false;
               _loc9_++;
            }
            if(this.averaging > 0 && Boolean(_loc3_))
            {
               _loc11_ = (_loc7_.avg - this.lowest) / _loc3_ * _loc2_;
               if(!this.inverse)
               {
                  _loc11_ = _loc2_ - _loc11_;
               }
               if(_loc11_ < -1)
               {
                  _loc11_ = -1;
               }
               if(_loc11_ > _loc2_)
               {
                  _loc11_ = _loc2_ + 1;
               }
               this.graph.graphics.lineStyle(1,_loc7_.col,0.3);
               this.graph.graphics.moveTo(0,_loc11_);
               this.graph.graphics.lineTo(_loc1_,_loc11_);
            }
            _loc6_++;
         }
         (this.inverse ? this.highTxt : this.lowTxt).text = isNaN(this.lowest) ? "" : "<s>" + this.lowest + "</s>";
         (this.inverse ? this.lowTxt : this.highTxt).text = isNaN(this.highest) ? "" : "<s>" + this.highest + "</s>";
      }
      
      public function get showKeyText() : Boolean
      {
         return this.keyTxt.visible;
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         TextField(param1.currentTarget).setSelection(0,0);
         if(param1.text == "reset")
         {
            this.reset();
         }
         else if(param1.text == "close")
         {
            this.close();
         }
         param1.stopPropagation();
      }
      
      protected function onMenuRollOver(param1:TextEvent) : void
      {
         master.panels.tooltip(param1.text ? param1.text.replace("event:","") : null,this);
      }
      
      protected function getCurrentOf(param1:int) : Number
      {
         var _loc2_:Array = this._history[this._history.length - 1];
         return _loc2_ ? Number(_loc2_[param1]) : 0;
      }
      
      override public function close() : void
      {
         this.stop();
         super.close();
      }
   }
}

import com.luaye.console.utils.WeakRef;

class Interest
{
   
   public var prop:String;
   
   public var col:Number;
   
   public var avg:Number;
   
   private var _ref:WeakRef;
   
   public var key:String;
   
   public function Interest(param1:Object, param2:String, param3:Number, param4:String)
   {
      super();
      this._ref = new WeakRef(param1);
      this.prop = param2;
      this.col = param3;
      this.key = param4;
   }
   
   public function get obj() : Object
   {
      return this._ref.reference;
   }
}
