package com.luaye.console.view
{
   import com.luaye.console.Console;
   import com.luaye.console.utils.Utils;
   import flash.display.BlendMode;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.ui.Mouse;
   
   public class Ruler extends Sprite
   {
      
      public static const EXIT:String = "exit";
      
      private static const POINTER_DISTANCE:int = 12;
      
      private var _master:Console;
      
      private var _points:Array;
      
      private var _area:Rectangle;
      
      private var _posTxt:TextField;
      
      private var _pointer:Shape;
      
      public function Ruler()
      {
         super();
      }
      
      public function exit() : void
      {
         this._points = null;
         this._master = null;
         dispatchEvent(new Event(EXIT));
      }
      
      public function start(param1:Console) : void
      {
         this._master = param1;
         buttonMode = true;
         this._points = new Array();
         this._pointer = new Shape();
         addChild(this._pointer);
         var _loc2_:Point = new Point();
         _loc2_ = globalToLocal(_loc2_);
         this._area = new Rectangle(-stage.stageWidth * 1.5 + _loc2_.x,-stage.stageHeight * 1.5 + _loc2_.y,stage.stageWidth * 3,stage.stageHeight * 3);
         graphics.beginFill(0,0.1);
         graphics.drawRect(this._area.x,this._area.y,this._area.width,this._area.height);
         graphics.endFill();
         this._posTxt = new TextField();
         this._posTxt.name = "positionText";
         this._posTxt.autoSize = TextFieldAutoSize.LEFT;
         this._posTxt.background = true;
         this._posTxt.backgroundColor = this._master.style.panelBackgroundColor;
         this._posTxt.styleSheet = param1.style.css;
         this._posTxt.mouseEnabled = false;
         addChild(this._posTxt);
         addEventListener(MouseEvent.CLICK,this.onMouseClick,false,0,true);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,0,true);
         this.onMouseMove();
         if(this._master.rulerHidesMouse)
         {
            Mouse.hide();
         }
         this._master.report("<b>Ruler started. Click on two locations to measure.</b>",-1);
      }
      
      private function onMouseMove(param1:MouseEvent = null) : void
      {
         this._pointer.graphics.clear();
         this._pointer.graphics.lineStyle(1,11193344,1);
         this._pointer.graphics.moveTo(this._area.x,mouseY);
         this._pointer.graphics.lineTo(this._area.x + this._area.width,mouseY);
         this._pointer.graphics.moveTo(mouseX,this._area.y);
         this._pointer.graphics.lineTo(mouseX,this._area.y + this._area.height);
         this._pointer.blendMode = BlendMode.INVERT;
         this._posTxt.text = "<s>" + mouseX + "," + mouseY + "</s>";
         this._posTxt.x = mouseX - this._posTxt.width - POINTER_DISTANCE;
         this._posTxt.y = mouseY - this._posTxt.height - POINTER_DISTANCE;
         if(this._posTxt.x < 0)
         {
            this._posTxt.x = mouseX + POINTER_DISTANCE;
         }
         if(this._posTxt.y < 0)
         {
            this._posTxt.y = mouseY + POINTER_DISTANCE;
         }
      }
      
      private function onMouseClick(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc7_:Point = null;
         var _loc8_:Point = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:TextField = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         param1.stopPropagation();
         if(this._points.length == 0)
         {
            _loc2_ = new Point(param1.localX,param1.localY);
            graphics.lineStyle(1,16711680);
            graphics.drawCircle(_loc2_.x,_loc2_.y,3);
            this._points.push(_loc2_);
         }
         else if(this._points.length == 1)
         {
            if(this._master.rulerHidesMouse)
            {
               Mouse.show();
            }
            removeChild(this._pointer);
            removeChild(this._posTxt);
            removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            _loc2_ = this._points[0];
            _loc3_ = new Point(param1.localX,param1.localY);
            this._points.push(_loc3_);
            graphics.clear();
            graphics.beginFill(0,0.4);
            graphics.drawRect(this._area.x,this._area.y,this._area.width,this._area.height);
            graphics.endFill();
            graphics.lineStyle(1.5,16711680);
            graphics.drawCircle(_loc2_.x,_loc2_.y,4);
            graphics.lineStyle(1.5,16750848);
            graphics.drawCircle(_loc3_.x,_loc3_.y,4);
            _loc4_ = Point.interpolate(_loc2_,_loc3_,0.5);
            graphics.lineStyle(1,11184810);
            graphics.drawCircle(_loc4_.x,_loc4_.y,4);
            _loc5_ = _loc2_;
            _loc6_ = _loc3_;
            if(_loc2_.x > _loc3_.x)
            {
               _loc5_ = _loc3_;
               _loc6_ = _loc2_;
            }
            _loc7_ = _loc2_;
            _loc8_ = _loc3_;
            if(_loc2_.y > _loc3_.y)
            {
               _loc7_ = _loc3_;
               _loc8_ = _loc2_;
            }
            _loc9_ = _loc6_.x - _loc5_.x;
            _loc10_ = _loc8_.y - _loc7_.y;
            _loc11_ = Point.distance(_loc2_,_loc3_);
            _loc12_ = this.makeTxtField();
            _loc12_.text = Utils.round(_loc2_.x,10) + "," + Utils.round(_loc2_.y,10);
            _loc12_.x = _loc2_.x;
            _loc12_.y = _loc2_.y - (_loc7_ == _loc2_ ? 14 : 0);
            addChild(_loc12_);
            _loc12_ = this.makeTxtField();
            _loc12_.text = Utils.round(_loc3_.x,10) + "," + Utils.round(_loc3_.y,10);
            _loc12_.x = _loc3_.x;
            _loc12_.y = _loc3_.y - (_loc7_ == _loc3_ ? 14 : 0);
            addChild(_loc12_);
            if(_loc9_ > 40 || _loc10_ > 25)
            {
               _loc12_ = this.makeTxtField(43520);
               _loc12_.text = Utils.round(_loc4_.x,10) + "," + Utils.round(_loc4_.y,10);
               _loc12_.x = _loc4_.x;
               _loc12_.y = _loc4_.y;
               addChild(_loc12_);
            }
            graphics.lineStyle(1,11193344,0.5);
            graphics.moveTo(this._area.x,_loc7_.y);
            graphics.lineTo(this._area.x + this._area.width,_loc7_.y);
            graphics.moveTo(this._area.x,_loc8_.y);
            graphics.lineTo(this._area.x + this._area.width,_loc8_.y);
            graphics.moveTo(_loc5_.x,this._area.y);
            graphics.lineTo(_loc5_.x,this._area.y + this._area.height);
            graphics.moveTo(_loc6_.x,this._area.y);
            graphics.lineTo(_loc6_.x,this._area.y + this._area.height);
            _loc13_ = Utils.round(Utils.angle(_loc2_,_loc3_),100);
            _loc14_ = Utils.round(Utils.angle(_loc3_,_loc2_),100);
            graphics.lineStyle(1,11141120,0.8);
            Utils.drawCircleSegment(graphics,10,_loc2_,_loc13_,-90);
            graphics.lineStyle(1,13404160,0.8);
            Utils.drawCircleSegment(graphics,10,_loc3_,_loc14_,-90);
            graphics.lineStyle(2,65280,0.7);
            graphics.moveTo(_loc2_.x,_loc2_.y);
            graphics.lineTo(_loc3_.x,_loc3_.y);
            this._master.report("Ruler results: (red) <b>[" + _loc2_.x + "," + _loc2_.y + "]</b> to (orange) <b>[" + _loc3_.x + "," + _loc3_.y + "]</b>",-2);
            this._master.report("Distance: <b>" + Utils.round(_loc11_,100) + "</b>",-2);
            this._master.report("Mid point: <b>[" + _loc4_.x + "," + _loc4_.y + "]</b>",-2);
            this._master.report("Width:<b>" + _loc9_ + "</b>, Height: <b>" + _loc10_ + "</b>",-2);
            this._master.report("Angle from first point (red): <b>" + _loc13_ + "°</b>",-2);
            this._master.report("Angle from second point (orange): <b>" + _loc14_ + "°</b>",-2);
         }
         else
         {
            this.exit();
         }
      }
      
      private function makeTxtField(param1:Number = 65280, param2:Boolean = true) : TextField
      {
         var _loc3_:TextFormat = new TextFormat("Arial",11,param1,param2,true,null,null,TextFormatAlign.RIGHT);
         var _loc4_:TextField = new TextField();
         _loc4_.autoSize = TextFieldAutoSize.RIGHT;
         _loc4_.selectable = false;
         _loc4_.defaultTextFormat = _loc3_;
         return _loc4_;
      }
   }
}

