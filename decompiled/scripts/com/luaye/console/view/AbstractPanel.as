package com.luaye.console.view
{
   import com.luaye.console.Console;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class AbstractPanel extends Sprite
   {
      
      public static const STARTED_DRAGGING:String = "startedDragging";
      
      public static const STARTED_SCALING:String = "startedScaling";
      
      public static const TEXT_LINK:String = "textLinkEvent";
      
      protected var bg:Sprite;
      
      private var _dragOffset:Point;
      
      protected var minimumHeight:int = 18;
      
      protected var minimumWidth:int = 18;
      
      private var _resizeTxt:TextField;
      
      protected var master:Console;
      
      protected var scaler:Sprite;
      
      private var _snaps:Array;
      
      public var moveable:Boolean = true;
      
      protected var style:Style;
      
      public var snapping:uint = 3;
      
      public function AbstractPanel(param1:Console)
      {
         super();
         this.master = param1;
         this.style = this.master.style;
         this.bg = new Sprite();
         this.bg.name = "background";
         addChild(this.bg);
      }
      
      public static function registerRollOverTextField(param1:TextField) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_MOVE,onTextFieldMouseMove,false,0,true);
         param1.addEventListener(MouseEvent.ROLL_OUT,onTextFieldMouseMove,false,0,true);
      }
      
      private static function onTextFieldMouseMove(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:XML = null;
         var _loc9_:XML = null;
         var _loc2_:TextField = param1.currentTarget as TextField;
         if(!_loc2_.stage || !_loc2_.visible || Boolean(_loc2_.parent) && Boolean(!_loc2_.parent.visible))
         {
            _loc2_.dispatchEvent(new TextEvent(TEXT_LINK));
            return;
         }
         if(_loc2_.scrollH > 0)
         {
            _loc6_ = _loc2_.scrollH;
            _loc7_ = _loc2_.width;
            _loc2_.width = _loc7_ + _loc6_;
            _loc3_ = _loc2_.getCharIndexAtPoint(_loc2_.mouseX + _loc6_,_loc2_.mouseY);
            _loc2_.width = _loc7_;
            _loc2_.scrollH = _loc6_;
         }
         else
         {
            _loc3_ = _loc2_.getCharIndexAtPoint(_loc2_.mouseX,_loc2_.mouseY);
         }
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(_loc3_ > 0)
         {
            _loc8_ = new XML(_loc2_.getXMLText(_loc3_,_loc3_ + 1));
            if(_loc8_.hasOwnProperty("textformat"))
            {
               _loc9_ = _loc8_["textformat"][0] as XML;
               if(_loc9_)
               {
                  _loc4_ = _loc9_.@url;
                  _loc5_ = _loc9_.toString();
               }
            }
         }
         _loc2_.dispatchEvent(new TextEvent(TEXT_LINK,false,false,_loc4_));
      }
      
      private function stopDragging() : void
      {
         this._snaps = null;
         if(stage)
         {
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.onDraggerMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDraggerMouseMove);
         }
         if(Boolean(this._resizeTxt) && Boolean(this._resizeTxt.parent))
         {
            this._resizeTxt.parent.removeChild(this._resizeTxt);
         }
         this._resizeTxt = null;
      }
      
      private function updateScale(param1:Event = null) : void
      {
         var _loc2_:Point = this.returnSnappedFor(x + mouseX - this._dragOffset.x,y + mouseY - this._dragOffset.x);
         _loc2_.x -= x;
         _loc2_.y -= y;
         this.width = _loc2_.x < this.minimumWidth ? this.minimumWidth : _loc2_.x;
         this.height = _loc2_.y < this.minimumHeight ? this.minimumHeight : _loc2_.y;
         this.updateScaleText();
      }
      
      private function updateDragText() : void
      {
         this._resizeTxt.text = "<s>" + x + "," + y + "</s>";
      }
      
      private function onScalerMouseDown(param1:Event) : void
      {
         this._resizeTxt = new TextField();
         this._resizeTxt.name = "resizingField";
         this._resizeTxt.autoSize = TextFieldAutoSize.RIGHT;
         this._resizeTxt.x = -4;
         this._resizeTxt.y = -17;
         this.formatText(this._resizeTxt);
         this.scaler.addChild(this._resizeTxt);
         this.updateScaleText();
         this._dragOffset = new Point(this.scaler.mouseX,this.scaler.mouseY);
         this._snaps = [[],[]];
         this.scaler.stage.addEventListener(MouseEvent.MOUSE_UP,this.onScalerMouseUp,false,0,true);
         this.scaler.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.updateScale,false,0,true);
         dispatchEvent(new Event(STARTED_SCALING));
      }
      
      private function onScalerMouseUp(param1:Event) : void
      {
         this.scaler.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onScalerMouseUp);
         this.scaler.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.updateScale);
         this.updateScale();
         this._snaps = null;
         if(Boolean(this._resizeTxt) && Boolean(this._resizeTxt.parent))
         {
            this._resizeTxt.parent.removeChild(this._resizeTxt);
         }
         this._resizeTxt = null;
      }
      
      protected function drawBG(param1:Number = 0, param2:Number = 0.6, param3:int = 10) : void
      {
         this.bg.graphics.clear();
         this.bg.graphics.beginFill(param1,param2);
         var _loc4_:int = 100;
         var _loc5_:int = 100 - param3 * 2;
         this.bg.graphics.drawRoundRect(0,0,_loc4_,_loc4_,param3,param3);
         var _loc6_:Rectangle = new Rectangle(param3,param3,_loc5_,_loc5_);
         this.bg.scale9Grid = _loc6_;
      }
      
      private function formatText(param1:TextField) : void
      {
         param1.background = true;
         param1.backgroundColor = this.style.panelBackgroundColor;
         param1.styleSheet = this.style.css;
         param1.mouseEnabled = false;
      }
      
      override public function get width() : Number
      {
         return this.bg.width;
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 < this.minimumHeight)
         {
            param1 = this.minimumHeight;
         }
         if(this.scaler)
         {
            this.scaler.y = param1;
         }
         this.bg.height = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 < this.minimumWidth)
         {
            param1 = this.minimumWidth;
         }
         if(this.scaler)
         {
            this.scaler.x = param1;
         }
         this.bg.width = param1;
      }
      
      public function init(param1:Number, param2:Number, param3:Boolean = false, param4:Number = -1, param5:Number = -1, param6:int = 10) : void
      {
         this.drawBG(param4 >= 0 ? param4 : this.style.panelBackgroundColor,param5 >= 0 ? param5 : this.style.panelBackgroundAlpha,param6);
         this.scalable = param3;
         this.width = param1;
         this.height = param2;
      }
      
      private function returnSnappedFor(param1:Number, param2:Number) : Point
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:Number = NaN;
         var _loc3_:Number = param1 + this.width;
         var _loc4_:Array = this._snaps[0];
         for each(_loc5_ in _loc4_)
         {
            if(Math.abs(_loc5_ - param1) < this.snapping)
            {
               param1 = _loc5_;
               break;
            }
            if(Math.abs(_loc5_ - _loc3_) < this.snapping)
            {
               param1 = _loc5_ - this.width;
               break;
            }
         }
         _loc6_ = param2 + this.height;
         _loc7_ = this._snaps[1];
         for each(_loc8_ in _loc7_)
         {
            if(Math.abs(_loc8_ - param2) < this.snapping)
            {
               param2 = _loc8_;
               break;
            }
            if(Math.abs(_loc8_ - _loc6_) < this.snapping)
            {
               param2 = _loc8_ - this.height;
               break;
            }
         }
         return new Point(param1,param2);
      }
      
      private function onDraggerMouseMove(param1:MouseEvent = null) : void
      {
         if(this.snapping == 0)
         {
            return;
         }
         var _loc2_:Point = this.returnSnappedFor(parent.mouseX - this._dragOffset.x,parent.mouseY - this._dragOffset.y);
         x = _loc2_.x;
         y = _loc2_.y;
         this.updateDragText();
      }
      
      public function registerSnaps(param1:Array, param2:Array) : void
      {
         this._snaps = [param1,param2];
      }
      
      private function onDraggerMouseUp(param1:MouseEvent) : void
      {
         this.stopDragging();
      }
      
      public function set scalable(param1:Boolean) : void
      {
         if(param1 && !this.scaler)
         {
            this.scaler = new Sprite();
            this.scaler.name = "scaler";
            this.scaler.graphics.beginFill(this.style.panelScalerColor,this.style.panelBackgroundAlpha);
            this.scaler.graphics.lineTo(-10,0);
            this.scaler.graphics.lineTo(0,-10);
            this.scaler.graphics.endFill();
            this.scaler.buttonMode = true;
            this.scaler.doubleClickEnabled = true;
            this.scaler.addEventListener(MouseEvent.MOUSE_DOWN,this.onScalerMouseDown,false,0,true);
            addChild(this.scaler);
         }
         else if(!param1 && Boolean(this.scaler))
         {
            if(contains(this.scaler))
            {
               removeChild(this.scaler);
            }
            this.scaler = null;
         }
      }
      
      public function get scalable() : Boolean
      {
         return this.scaler ? true : false;
      }
      
      public function stopScaling() : void
      {
         this.onScalerMouseUp(null);
      }
      
      private function onDraggerMouseDown(param1:MouseEvent) : void
      {
         if(!stage || !this.moveable)
         {
            return;
         }
         this._resizeTxt = new TextField();
         this._resizeTxt.name = "positioningField";
         this._resizeTxt.autoSize = TextFieldAutoSize.LEFT;
         this.formatText(this._resizeTxt);
         addChild(this._resizeTxt);
         this.updateDragText();
         this._dragOffset = new Point(mouseX,mouseY);
         this._snaps = [[],[]];
         dispatchEvent(new Event(STARTED_DRAGGING));
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onDraggerMouseUp,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onDraggerMouseMove,false,0,true);
      }
      
      override public function get height() : Number
      {
         return this.bg.height;
      }
      
      private function updateScaleText() : void
      {
         this._resizeTxt.text = "<s>" + this.width + "," + this.height + "</s>";
      }
      
      protected function registerDragger(param1:DisplayObject, param2:Boolean = false) : void
      {
         if(param2)
         {
            param1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDraggerMouseDown);
         }
         else
         {
            param1.addEventListener(MouseEvent.MOUSE_DOWN,this.onDraggerMouseDown,false,0,true);
         }
      }
      
      public function close() : void
      {
         this.stopDragging();
         this.master.panels.tooltip();
         if(parent)
         {
            parent.removeChild(this);
         }
      }
   }
}

