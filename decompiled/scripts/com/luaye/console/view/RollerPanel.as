package com.luaye.console.view
{
   import com.luaye.console.Console;
   import com.luaye.console.utils.Utils;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Dictionary;
   
   public class RollerPanel extends AbstractPanel
   {
      
      private var _txtField:TextField;
      
      private var _base:DisplayObjectContainer;
      
      public function RollerPanel(param1:Console)
      {
         super(param1);
         name = Console.PANEL_ROLLER;
         init(60,100,false);
         this._txtField = new TextField();
         this._txtField.name = "rollerprints";
         this._txtField.multiline = true;
         this._txtField.autoSize = TextFieldAutoSize.LEFT;
         this._txtField.styleSheet = style.css;
         this._txtField.addEventListener(TextEvent.LINK,this.linkHandler,false,0,true);
         registerRollOverTextField(this._txtField);
         this._txtField.addEventListener(AbstractPanel.TEXT_LINK,this.onMenuRollOver,false,0,true);
         registerDragger(this._txtField);
         addChild(this._txtField);
      }
      
      public function start(param1:DisplayObjectContainer) : void
      {
         this._base = param1;
         addEventListener(Event.ENTER_FRAME,this._onFrame,false,0,true);
      }
      
      public function capture() : String
      {
         return this.getMapString(true);
      }
      
      private function _onFrame(param1:Event) : void
      {
         if(!this._base.stage)
         {
            this.close();
            return;
         }
         this._txtField.htmlText = "<ro>" + this.getMapString() + "</ro>";
         this._txtField.autoSize = TextFieldAutoSize.LEFT;
         this._txtField.setSelection(0,0);
         width = this._txtField.width + 4;
         height = this._txtField.height;
      }
      
      private function onMenuRollOver(param1:TextEvent) : void
      {
         master.panels.tooltip(param1.text ? "Close" : null,this);
      }
      
      private function getMapString(param1:Boolean = false) : String
      {
         var _loc6_:DisplayObject = null;
         var _loc7_:Array = null;
         var _loc8_:DisplayObjectContainer = null;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         var _loc11_:DisplayObject = null;
         var _loc12_:uint = 0;
         var _loc2_:Stage = this._base.stage;
         var _loc3_:String = "";
         var _loc4_:Array = _loc2_.getObjectsUnderPoint(new Point(_loc2_.mouseX,_loc2_.mouseY));
         var _loc5_:Dictionary = new Dictionary(true);
         if(_loc4_.length == 0)
         {
            _loc4_.push(_loc2_);
         }
         for each(_loc6_ in _loc4_)
         {
            _loc7_ = new Array(_loc6_);
            _loc8_ = _loc6_.parent;
            while(_loc8_)
            {
               _loc7_.unshift(_loc8_);
               _loc8_ = _loc8_.parent;
            }
            _loc9_ = _loc7_.length;
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc11_ = _loc7_[_loc10_];
               if(_loc5_[_loc11_] == undefined)
               {
                  _loc5_[_loc11_] = _loc10_;
                  if(param1)
                  {
                     _loc3_ += "<br/>";
                  }
                  _loc12_ = _loc10_;
                  while(_loc12_ > 0)
                  {
                     _loc3_ += _loc12_ == 1 ? " ∟" : " -";
                     _loc12_--;
                  }
                  if(param1)
                  {
                     if(_loc11_ == _loc2_)
                     {
                        _loc3_ += "<p3><a href=\'event:sclip_\'><i>Stage</i></a> [" + _loc2_.mouseX + "," + _loc2_.mouseY + "]</p3>";
                     }
                     else if(_loc10_ == _loc9_ - 1)
                     {
                        _loc3_ += "<p5><a href=\'event:sclip_" + this.mapUpward(_loc11_) + "\'>" + _loc11_.name + "(" + Utils.shortClassName(_loc11_) + ")</a></p5>";
                     }
                     else
                     {
                        _loc3_ += "<p2><a href=\'event:sclip_" + this.mapUpward(_loc11_) + "\'><i>" + _loc11_.name + "(" + Utils.shortClassName(_loc11_) + ")</i></a></p2>";
                     }
                  }
                  else if(_loc11_ == _loc2_)
                  {
                     _loc3_ += "<menu> <a href=\"event:close\"><b>X</b></a></menu> <i>Stage</i> [" + _loc2_.mouseX + "," + _loc2_.mouseY + "]<br/>";
                  }
                  else if(_loc10_ == _loc9_ - 1)
                  {
                     _loc3_ += "<roBold>" + _loc11_.name + "(" + Utils.shortClassName(_loc11_) + ")</roBold>";
                  }
                  else
                  {
                     _loc3_ += "<i>" + _loc11_.name + "(" + Utils.shortClassName(_loc11_) + ")</i><br/>";
                  }
               }
               _loc10_++;
            }
         }
         return _loc3_;
      }
      
      override public function close() : void
      {
         removeEventListener(Event.ENTER_FRAME,this._onFrame);
         this._base = null;
         super.close();
         master.panels.updateMenu();
      }
      
      private function mapUpward(param1:DisplayObject) : String
      {
         var _loc2_:Array = [param1.name];
         param1 = param1.parent;
         while(Boolean(param1) && param1 != param1.stage)
         {
            _loc2_.push(param1.name);
            param1 = param1.parent;
         }
         return _loc2_.reverse().join(Console.MAPPING_SPLITTER);
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         TextField(param1.currentTarget).setSelection(0,0);
         if(param1.text == "close")
         {
            this.close();
         }
         param1.stopPropagation();
      }
   }
}

