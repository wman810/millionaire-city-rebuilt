package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.Rectangle;
   import flash.text.*;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class DynamicButton
   {
      
      private static const MIN_WIDTH:int = 100;
      
      private static const MAX_WIDTH:int = 100;
      
      private var mTipBoxAdded:Boolean;
      
      private var mButtonText:String;
      
      private var mTipTimerID:int;
      
      private var mEnabled:Boolean;
      
      private var mAlign:String;
      
      private var mMouseEnabled:Boolean;
      
      private var mSelected:Boolean;
      
      private var mTipBox:TipBox;
      
      private var mButton:MovieClip;
      
      public function DynamicButton(param1:MovieClip, param2:String = "center")
      {
         super();
         this.mButton = param1;
         this.mButton.stop();
         this.mButton.buttonMode = true;
         this.mButton.mouseChildren = false;
         this.mTipBoxAdded = false;
         this.mEnabled = true;
         this.mAlign = param2;
         param1 = this.mButton["ButtonText"];
         if(param1 != null)
         {
            param1.stop();
         }
      }
      
      public function setOfferLabel(param1:String) : void
      {
         if(this.mButton["offer"] != null)
         {
            this.mButton["offer"]["caption"].text = param1;
         }
      }
      
      public function set Enabled(param1:Boolean) : void
      {
         this.mEnabled = param1;
      }
      
      public function updateWidth(param1:Number) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:TextField = null;
         var _loc5_:Number = NaN;
         var _loc6_:TextFormat = null;
         _loc2_ = this.mButton["ButtonText"];
         if(_loc2_ != null)
         {
            _loc3_ = this.mButton["icon"];
            _loc4_ = _loc2_["Caption"];
            _loc2_ = _loc2_["base"];
            if(_loc2_ != null)
            {
               _loc5_ = param1 - _loc2_.width;
               if(_loc3_ != null)
               {
                  _loc3_.x -= _loc5_ / 2;
               }
               if(_loc4_ != null)
               {
                  _loc4_.width += _loc5_;
                  _loc4_.x -= _loc5_ / 2;
                  _loc6_ = _loc4_.defaultTextFormat;
                  _loc6_.size = 20;
                  _loc4_.defaultTextFormat = _loc6_;
                  this.changeButtonText();
                  _loc4_.y = (_loc2_.height - _loc4_.textHeight) / 4 - _loc2_.height / 2;
               }
               _loc2_.width = param1;
            }
         }
      }
      
      private function onMouseClick(param1:MouseEvent) : void
      {
         if(!this.mEnabled)
         {
            param1.stopImmediatePropagation();
         }
      }
      
      public function destroy() : void
      {
         this.end();
         this.mButton = null;
      }
      
      public function enable() : void
      {
         this.mButton.gotoAndStop("UpState");
         this.mButton.filters = null;
         this.mButton.mouseEnabled = true;
         this.mEnabled = true;
      }
      
      private function showTooltip() : void
      {
         var _loc1_:Rectangle = null;
         if(this.mTipBox != null && !this.mTipBoxAdded)
         {
            _loc1_ = this.mButton.getBounds(Dollars.smStage);
            this.mTipBox.x = _loc1_.x + (_loc1_.width - this.mTipBox.width >> 1);
            this.mTipBox.y = _loc1_.y - this.mTipBox.height - 10;
            if(this.mTipBox.x + this.mTipBox.width > Dollars.smStage.stageWidth)
            {
               this.mTipBox.x = Dollars.smStage.stageWidth - this.mTipBox.width;
            }
            else if(this.mTipBox.x <= 0)
            {
               this.mTipBox.x = 0;
            }
            this.mTipBoxAdded = true;
            DollarsGame.smInstance.mPopupClip.addChild(this.mTipBox);
            clearTimeout(this.mTipTimerID);
         }
      }
      
      private function containsFrame(param1:String) : Boolean
      {
         var _loc3_:FrameLabel = null;
         var _loc2_:Array = this.mButton.currentLabels;
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.name == "disabled")
            {
               return true;
            }
         }
         return false;
      }
      
      private function changeButtonText() : void
      {
         var _loc1_:Sprite = null;
         var _loc2_:TextField = null;
         var _loc3_:TextFormat = null;
         if(this.mButtonText != null)
         {
            _loc1_ = this.mButton.getChildByName("ButtonText") as Sprite;
            if(_loc1_ != null)
            {
               _loc2_ = _loc1_.getChildByName("Caption") as TextField;
               if(_loc2_ != null)
               {
                  TextManager.reformatTextField(_loc2_,false);
                  _loc2_.text = this.mButtonText;
                  TextManager.setTextScaled(_loc2_,false);
                  _loc3_ = new TextFormat();
                  _loc3_.align = this.mAlign;
                  _loc2_.setTextFormat(_loc3_);
               }
            }
         }
      }
      
      public function rollover(param1:MouseEvent) : void
      {
         if(!this.mSelected && this.mEnabled)
         {
            this.mButton.gotoAndStop("OverState");
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
         }
         this.mTipTimerID = setTimeout(this.showTooltip,500);
      }
      
      private function removeToolTip() : void
      {
         var _loc1_:DollarsGame = null;
         clearTimeout(this.mTipTimerID);
         if(this.mTipBox != null && this.mTipBoxAdded)
         {
            _loc1_ = DollarsGame.smInstance;
            _loc1_.mPopupClip.removeChild(this.mTipBox);
            this.mTipBoxAdded = false;
         }
      }
      
      public function end() : void
      {
         var _loc1_:Cursor = null;
         if(this.mButton != null)
         {
            _loc1_ = Dollars.getCurrentCursor();
            if(_loc1_ != null)
            {
               _loc1_.changeCursor(_loc1_.mCurrentCursorID);
            }
            this.mButton.removeEventListener(MouseEvent.MOUSE_OVER,this.rollover);
            this.mButton.removeEventListener(MouseEvent.MOUSE_OUT,this.rollout);
            this.mButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseClickDown);
            this.mButton.removeEventListener(MouseEvent.MOUSE_UP,this.mouseClickUp);
            this.mButton.removeEventListener(MouseEvent.CLICK,this.onMouseClick);
            this.removeToolTip();
         }
      }
      
      public function addEventListener(param1:String, param2:Function) : void
      {
         this.mButton.addEventListener(param1,param2);
      }
      
      public function setSelected() : void
      {
         if(this.mEnabled)
         {
            this.mButton.gotoAndStop("SelectState");
            this.mSelected = true;
         }
      }
      
      public function mouseClickUp(param1:MouseEvent) : void
      {
         if(this.mEnabled && !this.mSelected)
         {
            this.mButton.gotoAndStop("OverState");
         }
      }
      
      public function setTip(param1:String) : void
      {
         if(this.mTipBox != null)
         {
            this.mTipBox.setText(param1);
         }
         else
         {
            this.mTipBox = new TipBox(param1);
         }
      }
      
      public function get Enabled() : Boolean
      {
         return this.mEnabled;
      }
      
      public function start() : void
      {
         this.enable();
         this.mButton.addEventListener(MouseEvent.MOUSE_OVER,this.rollover);
         this.mButton.addEventListener(MouseEvent.MOUSE_OUT,this.rollout);
         this.mButton.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseClickDown);
         this.mButton.addEventListener(MouseEvent.MOUSE_UP,this.mouseClickUp);
         this.mButton.addEventListener(MouseEvent.CLICK,this.onMouseClick);
      }
      
      public function mouseClickDown(param1:MouseEvent) : void
      {
         if(this.mEnabled && !this.mSelected)
         {
            this.mButton.gotoAndStop("DownState");
         }
      }
      
      public function disable(param1:Boolean = false) : void
      {
         this.mMouseEnabled = param1;
         if(this.containsFrame("DownState"))
         {
            this.mButton.gotoAndStop("UpState");
            this.mButton.filters = FiltersManager.getSaturationFilter(0);
            this.changeButtonText();
         }
         else if(this.containsFrame("UpState"))
         {
            this.mButton.gotoAndStop("UpState");
            this.mButton.filters = FiltersManager.getSaturationFilter(0);
            this.changeButtonText();
         }
         else
         {
            this.mButton.filters = FiltersManager.getSaturationFilter(0);
         }
         this.mButton.mouseEnabled = this.mMouseEnabled;
         this.mEnabled = false;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.mButton.visible = param1;
      }
      
      public function removeEventListener(param1:String, param2:Function) : void
      {
         this.mButton.removeEventListener(param1,param2);
      }
      
      public function getButtonMc() : MovieClip
      {
         return this.mButton;
      }
      
      public function rollout(param1:MouseEvent) : void
      {
         if(!this.mSelected && this.mEnabled)
         {
            this.mButton.gotoAndStop("UpState");
            Dollars.getCurrentCursor().changeCursor(Dollars.getCurrentCursor().mCurrentCursorID);
            if(this.mSelected)
            {
               this.setSelected();
            }
         }
         else if(!this.mEnabled)
         {
            this.disable(this.mMouseEnabled);
         }
         this.removeToolTip();
      }
      
      public function setLabel(param1:String) : void
      {
         this.mButtonText = param1;
         this.changeButtonText();
      }
      
      public function changeFrame(param1:int) : void
      {
         var frame:int = param1;
         var button:MovieClip = this.mButton["ButtonText"];
         if(button != null)
         {
            try
            {
               button.gotoAndStop(frame);
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function setUnselected() : void
      {
         if(this.mEnabled)
         {
            this.mButton.gotoAndStop("UpState");
         }
         else
         {
            this.disable(this.mMouseEnabled);
         }
         this.mSelected = false;
      }
      
      public function get visible() : Boolean
      {
         return this.mButton.visible;
      }
   }
}

