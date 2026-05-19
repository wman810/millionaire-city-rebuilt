package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.BitmapFilter;
   import flash.filters.DropShadowFilter;
   import flash.text.*;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class TabButton extends Sprite
   {
      
      private var mFilter:BitmapFilter;
      
      private var mButtonText:String;
      
      private var mFilters:Array;
      
      private var mTipTimerID:int;
      
      private var mEnabled:Boolean;
      
      private var tip:TipBox;
      
      private var tipAdded:Boolean;
      
      private var mSelected:Boolean;
      
      private var mButton:MovieClip;
      
      public function TabButton(param1:MovieClip)
      {
         super();
         this.buttonMode = true;
         this.mouseChildren = false;
         this.mButton = param1;
         this.mButton.buttonMode = true;
         this.mButton.mouseChildren = false;
         this.mButton.stop();
         this.tipAdded = false;
         addChild(this.mButton);
         this.mEnabled = true;
      }
      
      public function enable() : void
      {
         this.mButton.gotoAndStop("UpState");
         this.changeButtonText();
         this.mouseEnabled = true;
         this.mButton.filters = null;
         this.mEnabled = true;
      }
      
      private function showTooltip() : void
      {
         var _loc1_:DollarsGame = null;
         if(this.tip != null && !this.tipAdded)
         {
            _loc1_ = DollarsGame.smInstance;
            this.tip.x = _loc1_.mPopupClip.mouseX;
            this.tip.y = _loc1_.mPopupClip.mouseY - this.tip.height - this.mButton.height / 2;
            if(this.tip.x + this.tip.width > Dollars.smStage.stageWidth)
            {
               this.tip.x = Dollars.smStage.stageWidth - this.tip.width - this.tip.width / 3;
            }
            this.tipAdded = true;
            _loc1_.mPopupClip.addChild(this.tip);
            clearTimeout(this.mTipTimerID);
         }
      }
      
      private function changeFilter(param1:Array) : void
      {
         var _loc3_:TextField = null;
         var _loc2_:Sprite = this.mButton.getChildByName("ButtonText") as Sprite;
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.getChildByName("Caption") as TextField;
            if(_loc3_ != null)
            {
               _loc3_.filters = param1;
            }
         }
      }
      
      private function changeButtonText() : void
      {
         var _loc1_:Sprite = null;
         var _loc2_:TextField = null;
         if(this.mButtonText != null)
         {
            _loc1_ = this.mButton.getChildByName("ButtonText") as Sprite;
            if(_loc1_ != null)
            {
               _loc2_ = _loc1_.getChildByName("Caption") as TextField;
               if(_loc2_ != null)
               {
                  TextManager.reformatTextField(_loc2_);
                  _loc2_.text = this.mButtonText;
                  TextManager.setTextScaled(_loc2_);
               }
            }
         }
      }
      
      public function unselect() : void
      {
         this.mButton.gotoAndStop("UpState");
         this.changeButtonText();
         this.mSelected = false;
         this.changeFilter(this.mFilters);
      }
      
      private function removeToolTip() : void
      {
         var _loc1_:DollarsGame = null;
         clearTimeout(this.mTipTimerID);
         if(this.tip != null && this.tipAdded)
         {
            _loc1_ = DollarsGame.smInstance;
            _loc1_.mPopupClip.removeChild(this.tip);
            this.tipAdded = false;
         }
      }
      
      public function setTip(param1:String) : void
      {
         this.tip = new TipBox(param1);
      }
      
      public function getButtonMc() : MovieClip
      {
         return this.mButton;
      }
      
      public function rollover(param1:MouseEvent) : void
      {
         if(!this.mSelected)
         {
            this.mButton.gotoAndStop("OverState");
            this.changeButtonText();
         }
         this.mTipTimerID = setTimeout(this.showTooltip,1000);
      }
      
      public function get Enabled() : Boolean
      {
         return this.mEnabled;
      }
      
      public function start() : void
      {
         this.mButton.gotoAndStop("UpState");
         this.addEventListener(MouseEvent.MOUSE_OVER,this.rollover);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.rollout);
         this.changeButtonText();
      }
      
      public function disable() : void
      {
         this.mButton.gotoAndStop("UpState");
         this.mButton.filters = FiltersManager.getSaturationFilter(0);
         this.changeButtonText();
         this.mouseEnabled = false;
         this.mEnabled = false;
      }
      
      public function end() : void
      {
         if(contains(this.mButton))
         {
            this.removeEventListener(MouseEvent.MOUSE_OVER,this.rollover);
            this.removeEventListener(MouseEvent.MOUSE_OUT,this.rollout);
            this.removeToolTip();
         }
      }
      
      public function rollout(param1:MouseEvent) : void
      {
         if(!this.mSelected && mouseEnabled)
         {
            this.mButton.gotoAndStop("UpState");
            this.changeButtonText();
         }
         this.removeToolTip();
      }
      
      public function setLabel(param1:String) : void
      {
         var _loc3_:TextField = null;
         var _loc4_:DropShadowFilter = null;
         this.mButtonText = param1;
         var _loc2_:Sprite = this.mButton.getChildByName("ButtonText") as Sprite;
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.getChildByName("Caption") as TextField;
            if(_loc3_ != null)
            {
               this.mFilters = _loc3_.filters;
               _loc4_ = this.mFilters[0];
               this.mFilter = new DropShadowFilter(_loc4_.distance,_loc4_.color,2835082,_loc4_.alpha,_loc4_.blurX,_loc4_.blurY,_loc4_.strength,_loc4_.quality);
            }
         }
         this.changeButtonText();
      }
      
      public function destroy() : void
      {
         this.end();
         this.mButton = null;
      }
      
      public function select() : void
      {
         this.mButton.gotoAndStop("DownState");
         this.changeButtonText();
         this.mSelected = true;
         this.changeFilter(new Array(this.mFilter));
      }
   }
}

