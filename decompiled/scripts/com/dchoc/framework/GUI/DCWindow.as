package com.dchoc.framework.GUI
{
   import com.dchoc.framework.events.*;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.utils.*;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Keyboard;
   
   public class DCWindow extends DCComponent
   {
      
      public static const EVENT_BUTTON_CLICKED:String = "BUTTON_CLICKED";
      
      public static const ALIGN_LEFT:int = 1;
      
      public static const ALIGN_RIGHT:int = 2;
      
      public static const ALIGN_HCENTER:int = 4;
      
      public static const ALIGN_TOP:int = 8;
      
      public static const ALIGN_DOWN:int = 16;
      
      public static const ALIGN_VCENTER:int = 32;
      
      public static const RES_TYPE_TEXT:int = 0;
      
      public static const RES_TYPE_ICON:int = 1;
      
      public static const RES_TYPE_ICON_FROM_RES_MANAGER:int = 2;
      
      public static const INSTANCE_NAME_WINDOW_TEXT_FIELD_TITLE:String = "Text_Title";
      
      public static const INSTANCE_NAME_WINDOW_MOVIE_CLIP_TITLE:String = "Title";
      
      public static const INSTANCE_NAME_MOVIE_CLIP_MAIN_TEXT:String = "Text";
      
      public static const INSTANCE_NAME_PANEL_TITLE:String = "Panel_Title";
      
      public static const INSTANCE_NAME_SCROLL_BAR_BUTTON_UP:String = "Button_Up";
      
      public static const INSTANCE_NAME_SCROLL_BAR_BUTTON_DOWN:String = "Button_Down";
      
      public static const INSTANCE_NAME_SCROLL_BAR_BUTTON_LEFT:String = "Button_Left";
      
      public static const INSTANCE_NAME_SCROLL_BAR_BUTTON_RIGHT:String = "Button_Right";
      
      public static const INSTANCE_NAME_SCROLL_BAR_BUTTON_HOME:String = "Button_Home";
      
      public static const INSTANCE_NAME_SCROLL_BAR_BUTTON_END:String = "Button_End";
      
      public static const INSTANCE_NAME_SCROLL_BAR_HANDLE:String = "Handle";
      
      public static const INSTANCE_NAME_BUTTON:String = "Button_";
      
      public static const INSTANCE_NAME_MASK:String = "Mask";
      
      public static const INSTANCE_NAME_TEXTBOX_CONTENTS_IN_OPEN_ANIM:String = "Contents";
      
      public static const INSTANCE_NAME_BUTTON_CLOSE:String = "Button_Close";
      
      public static const INSTANCE_NAME_BUTTON_OK:String = "Button_Ok";
      
      public static const INSTANCE_NAME_BACKGROUND:String = "Background";
      
      public static const INSTANCE_NAME_BACKGROUND_LEFT:String = "Background_Left";
      
      public static const INSTANCE_NAME_BACKGROUND_MIDDLE:String = "Background_Middle";
      
      public static const INSTANCE_NAME_BACKGROUND_RIGHT:String = "Background_Right";
      
      public static const INSTANCE_NAME_HUD_SOUND_OPTIONS:String = "HUD_Sound_Options";
      
      public static const INSTANCE_NAME_HUD_SOUND_OPTIONS_BUTTON_MUSIC:String = "Button_Music";
      
      public static const INSTANCE_NAME_HUD_SOUND_OPTIONS_BUTTON_SFX:String = "Button_SFX";
      
      public static const INSTANCE_NAME_HUD_PANEL_FRIENDS:String = "HUD_Friends";
      
      public static const INSTANCE_NAME_HUD_PANEL_INVENTORY_EGGS:String = "HUD_Inventory_Panel_Eggs";
      
      public static const INSTANCE_NAME_HUD_PANEL_INVENTORY:String = "HUD_Inventory_Panel";
      
      private var mScrollBars:Array;
      
      private var mTabs:DCTabs;
      
      protected var mDesign:Sprite;
      
      private var mButtons:Array;
      
      private var mButtonClickedFunction:Function;
      
      private var mIsButtonClose:Boolean;
      
      public function DCWindow(param1:DisplayObjectContainer, param2:String = null, param3:Function = null)
      {
         super();
         addChild(param1);
         if(param1 is MovieClip && MovieClip(param1).totalFrames > 1)
         {
            mOpenAnimation = MovieClip(param1);
            this.mDesign = param1.getChildByName(INSTANCE_NAME_TEXTBOX_CONTENTS_IN_OPEN_ANIM) as Sprite;
         }
         else
         {
            mOpenAnimation = null;
            this.mDesign = param1 as Sprite;
         }
         this.init();
         this.mIsButtonClose = false;
         this.mButtonClickedFunction = param3;
         this.setTitle(param2);
      }
      
      public function resizeBackground(param1:DisplayObjectContainer, param2:int) : void
      {
         var _loc3_:DisplayObjectContainer = param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND) as DisplayObjectContainer;
         if(_loc3_ != null)
         {
            _loc3_.width += param2;
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
      }
      
      public function changePanelsFrameAt(param1:Sprite, param2:String, param3:String, param4:int, param5:String) : void
      {
         var _loc7_:MovieClip = null;
         var _loc6_:DisplayObjectContainer = this.getPanelAt(param1,param2,param4);
         if(param3)
         {
            _loc6_ = _loc6_.getChildByName(param3) as MovieClip;
         }
         if(_loc6_)
         {
            _loc7_ = _loc6_ as MovieClip;
            MovieClip(_loc6_).gotoAndStop(param5);
         }
      }
      
      override protected function clean() : void
      {
         var _loc2_:DCButton = null;
         var _loc3_:DCScrollBar = null;
         removeEventListener(EVENT_BUTTON_CLICKED,this.buttonClicked);
         mParent.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDown);
         super.clean();
         var _loc1_:int = 0;
         while(_loc1_ < this.mButtons.length)
         {
            _loc2_ = this.mButtons[_loc1_];
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.mScrollBars.length)
         {
            _loc3_ = this.mScrollBars[_loc1_];
            _loc1_++;
         }
         if(!this.mTabs)
         {
         }
      }
      
      override public function open(param1:DisplayObjectContainer, param2:Boolean = false) : void
      {
         super.open(param1,param2);
         addEventListener(EVENT_BUTTON_CLICKED,this.buttonClicked);
         param1.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDown);
      }
      
      public function isButtonOfType(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.mButtons.length)
         {
            if(DCButton(this.mButtons[_loc2_]).getType() == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function getPanelsNumber(param1:Sprite, param2:String) : int
      {
         var _loc3_:Sprite = param1.getChildByName(param2) as Sprite;
         var _loc4_:int = 0;
         do
         {
            _loc4_++;
            _loc3_ = param1.getChildByName(param2 + _loc4_) as Sprite;
         }
         while(_loc3_ != null);
         return _loc4_;
      }
      
      protected function setIcon(param1:DisplayObjectContainer, param2:String, param3:DisplayObject, param4:String = null, param5:Boolean = true) : Number
      {
         var _loc6_:DisplayObjectContainer = param1;
         if(param2)
         {
            _loc6_ = DCUtils.getChildByPath(param1,param2) as DisplayObjectContainer;
         }
         var _loc7_:DisplayObject = _loc6_.getChildAt(0);
         var _loc8_:int = _loc7_.x;
         var _loc9_:int = _loc7_.y;
         var _loc10_:int = _loc7_.width;
         var _loc11_:int = _loc7_.height;
         var _loc12_:Number = _loc10_;
         _loc6_.removeChildAt(0);
         if(param4)
         {
            param3.name = param4;
         }
         param3.x = _loc8_;
         param3.y = _loc9_;
         if(param5)
         {
            param3.width = _loc10_;
            param3.height = _loc11_;
         }
         _loc6_.addChild(param3);
         return param3.width - _loc12_;
      }
      
      private function init() : void
      {
         this.mButtons = new Array();
         this.mScrollBars = new Array();
      }
      
      public function setDisplayObjectVisible(param1:String, param2:Boolean) : void
      {
         var _loc3_:DisplayObject = DCUtils.getChildByPath(this.mDesign,param1) as DisplayObject;
         _loc3_.visible = param2;
      }
      
      public function createButton(param1:Class, param2:String, param3:int, param4:String = null, param5:String = null, param6:String = null) : DCButton
      {
         var _loc7_:MovieClip = DCUtils.getChildByPath(this.mDesign,param2) as MovieClip;
         if(_loc7_ == null)
         {
            trace("ERROR: DCWindow::CreateButton Cannot find the movieClip with instanceName = " + param2);
            return null;
         }
         return this.createButtonOutOfClip(param1,_loc7_,param3,param4,param5,param6);
      }
      
      protected function getTextField(param1:DisplayObjectContainer, param2:String) : String
      {
         var _loc3_:DisplayObject = DCUtils.getChildByPath(param1,param2);
         return TextField(_loc3_).text;
      }
      
      protected function setIconFromSku(param1:DisplayObjectContainer, param2:String, param3:String, param4:String = null, param5:Boolean = true) : Number
      {
         if(!AssetManager.SKU[param3])
         {
            return 0;
         }
         var _loc6_:String = AssetManager.SKU[param3][AssetManager.SKU_GFX_SWF_FILE];
         if(_loc6_ == null)
         {
            return this.setIconFromResManager(param1,param2,AssetManager.SKU[param3][AssetManager.SKU_GFX],param4,param5);
         }
         if(_loc6_ == "constructor")
         {
            return this.setIcon(param1,param2,AssetManager.getInstance().getAssetByName(AssetManager.SKU[param3][AssetManager.SKU_GFX]),param4,param5);
         }
         return this.setIconFromSwf(param1,param2,_loc6_,AssetManager.SKU[param3][AssetManager.SKU_GFX],param4,param5);
      }
      
      protected function setIconFromResManager(param1:DisplayObjectContainer, param2:String, param3:String, param4:String = null, param5:Boolean = true) : Number
      {
         if(param3 == null || param3 == "")
         {
            return 0;
         }
         var _loc6_:DisplayObject = DCResourceManager.getInstance().get(param3) as Sprite;
         if(_loc6_ == null)
         {
            return 0;
         }
         return this.setIcon(param1,param2,_loc6_,param4,param5);
      }
      
      public function focusTextField(param1:String) : void
      {
         var _loc2_:TextField = this.mDesign.getChildByName(param1) as TextField;
         _loc2_.stage.focus = _loc2_;
         _loc2_.setSelection(0,_loc2_.text.length);
      }
      
      public function createButtonOutOfClip(param1:Class, param2:MovieClip, param3:int, param4:String = null, param5:String = null, param6:String = null) : DCButton
      {
         var _loc7_:DCButton = new param1(this,param2,param3,param5,this);
         if(param4 != null)
         {
            _loc7_.setText(param4);
         }
         if(param6)
         {
            _loc7_.setHelper(param6);
         }
         this.mButtons.push(_loc7_);
         return _loc7_;
      }
      
      public function getPanelAt(param1:DisplayObjectContainer, param2:String, param3:int) : DisplayObjectContainer
      {
         var _loc4_:DisplayObjectContainer = null;
         if(param3 == 0)
         {
            _loc4_ = param1.getChildByName(param2) as Sprite;
         }
         else
         {
            _loc4_ = param1.getChildByName(param2 + param3) as Sprite;
         }
         return _loc4_;
      }
      
      public function getChildByPath(param1:String) : DisplayObject
      {
         return DCUtils.getChildByPath(this.mDesign,param1);
      }
      
      public function setPanelVisibleAt(param1:Sprite, param2:String, param3:String, param4:int, param5:Boolean) : void
      {
         var _loc6_:DisplayObjectContainer = this.getPanelAt(param1,param2,param4);
         if(param3)
         {
            _loc6_ = _loc6_.getChildByName(param3) as Sprite;
         }
         if(_loc6_)
         {
            _loc6_.visible = param5;
         }
      }
      
      public function createPanelsButton(param1:Sprite, param2:String, param3:String, param4:Object, param5:int, param6:String = null, param7:Array = null) : void
      {
         var _loc10_:* = undefined;
         var _loc11_:* = undefined;
         var _loc12_:* = undefined;
         var _loc8_:DisplayObjectContainer = param1.getChildByName(param2) as DisplayObjectContainer;
         var _loc9_:int = 0;
         do
         {
            _loc10_ = param7 == null ? _loc9_ : param7[_loc9_];
            if(param3)
            {
               _loc11_ = _loc8_.getChildByName(param3) as MovieClip;
            }
            else
            {
               _loc11_ = _loc8_ as MovieClip;
            }
            _loc12_ = new DCButton(this,_loc11_,param5,_loc10_ as String,this);
            if(param4 is Array)
            {
               _loc12_.setText(param4[_loc9_] as String);
            }
            else
            {
               _loc12_.setText(param4 as String);
            }
            if(param6 != null)
            {
               _loc12_.setHelper(param6);
            }
            _loc9_++;
         }
         while(_loc8_ = param1.getChildByName(param2 + _loc9_) as Sprite, _loc8_ != null);
      }
      
      public function addPanelsEventListener(param1:DisplayObjectContainer, param2:String, param3:String, param4:String, param5:Function) : void
      {
         var _loc8_:* = undefined;
         var _loc6_:DisplayObjectContainer = param1.getChildByName(param2) as DisplayObjectContainer;
         var _loc7_:int = 0;
         do
         {
            if(param3 == null)
            {
               _loc6_.addEventListener(param4,param5);
            }
            else
            {
               _loc8_ = DCUtils.getChildByPath(_loc6_,param3);
               _loc8_.addEventListener(param4,param5);
            }
            _loc7_++;
         }
         while(_loc6_ = param1.getChildByName(param2 + _loc7_) as DisplayObjectContainer, _loc6_ != null);
      }
      
      public function constructPanels(param1:Sprite, param2:String, param3:int) : Number
      {
         var _loc4_:DisplayObject = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc13_:DisplayObject = null;
         _loc4_ = param1.getChildByName(param2);
         var _loc5_:MovieClip = param1.getChildByName(param2 + "_Copy") as MovieClip;
         _loc4_.visible = true;
         _loc5_.visible = false;
         _loc7_ = _loc5_.x - _loc4_.x;
         _loc8_ = _loc5_.y - _loc4_.y;
         var _loc9_:Number = _loc5_.x;
         var _loc10_:Number = _loc5_.y;
         if(_loc7_ != 0)
         {
            _loc6_ = Math.abs(_loc7_);
         }
         else if(_loc8_ != 0)
         {
            _loc6_ = Math.abs(_loc8_);
         }
         var _loc11_:int = this.getPanelsNumber(param1,param2);
         if(_loc11_ > 1)
         {
            param3 = _loc11_ + param3;
         }
         _loc9_ += (_loc11_ - 1) * _loc7_;
         _loc10_ += (_loc11_ - 1) * _loc8_;
         var _loc12_:int = _loc11_;
         while(_loc12_ < param3)
         {
            _loc13_ = AssetManager.getInstance().getAssetByName(param2);
            _loc13_.name = param2 + _loc12_;
            _loc13_.x = _loc9_;
            _loc13_.y = _loc10_;
            param1.addChild(_loc13_);
            _loc9_ += _loc7_;
            _loc10_ += _loc8_;
            _loc12_++;
         }
         return _loc6_;
      }
      
      public function setTextAlignedInContainer(param1:String, param2:String, param3:int) : void
      {
         var _loc8_:DisplayObject = null;
         var _loc4_:TextField = DCUtils.getChildByPath(this.mDesign,param1) as TextField;
         var _loc5_:Number = _loc4_.textWidth;
         _loc4_.text = param2;
         _loc5_ = _loc4_.textWidth - _loc5_;
         var _loc6_:DisplayObjectContainer = _loc4_.parent;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_.numChildren)
         {
            _loc8_ = _loc6_.getChildAt(_loc7_);
            if(ALIGN_RIGHT & param3)
            {
               if(_loc8_.x <= _loc4_.x)
               {
                  _loc8_.x -= _loc5_;
               }
            }
            if(ALIGN_LEFT & param3)
            {
               if(_loc8_.x >= _loc4_.x)
               {
                  _loc8_.x += _loc5_;
               }
            }
            _loc7_++;
         }
      }
      
      public function addCloseButton() : void
      {
         this.mIsButtonClose = true;
         this.createButton(DCButton,INSTANCE_NAME_BUTTON_CLOSE,DCButton.BUTTON_TYPE_X);
      }
      
      protected function getText(param1:DisplayObjectContainer, param2:String) : String
      {
         var _loc3_:DisplayObject = DCUtils.getChildByPath(param1,param2);
         return TextField(_loc3_).text;
      }
      
      public function constructScrollButtons(param1:Sprite, param2:MovieClip, param3:Number, param4:Number, param5:Number, param6:Number, param7:int = 2147483647, param8:int = 2147483647) : DCScrollButtons
      {
         var _loc9_:DCScrollButtons = new DCScrollButtons(param1,param2,param5,param6);
         _loc9_.setPosition(param7,param8);
         return _loc9_;
      }
      
      protected function setItem(param1:int, param2:DisplayObjectContainer, param3:String, param4:String) : void
      {
         switch(param1)
         {
            case RES_TYPE_TEXT:
               this.setText(param2,param3,param4);
               break;
            case RES_TYPE_ICON:
               trace("RES_TYPE_ICON: FUNCTION TO DO!!!");
               break;
            case RES_TYPE_ICON_FROM_RES_MANAGER:
               this.setIconFromResManager(param2,param3,param4,null,true);
         }
      }
      
      public function setTitle(param1:String) : void
      {
         var _loc2_:TextField = null;
         if(param1 != null)
         {
            _loc2_ = this.mDesign.getChildByName(INSTANCE_NAME_WINDOW_TEXT_FIELD_TITLE) as TextField;
            if(_loc2_ != null)
            {
               _loc2_.text = param1;
               _loc2_.width = 300;
               _loc2_.autoSize = TextFieldAutoSize.CENTER;
            }
            else
            {
               DCGuiUtils.setTextAndResizeBackground(this.mDesign.getChildByName(INSTANCE_NAME_WINDOW_MOVIE_CLIP_TITLE) as MovieClip,param1);
            }
         }
      }
      
      public function setFillBar(param1:String, param2:String, param3:int, param4:int, param5:int = 0) : int
      {
         var _loc6_:TextField = DCUtils.getChildByPath(this.mDesign,param2) as TextField;
         _loc6_.text = param3 + "/" + param4;
         var _loc7_:MovieClip = DCUtils.getChildByPath(this.mDesign,param1) as MovieClip;
         return _loc7_.totalFrames * (param3 - param5) / (param4 - param5);
      }
      
      public function changePanelsItem(param1:DisplayObjectContainer, param2:String, param3:int, param4:String, param5:Array) : void
      {
         if(param5 == null || param5.length == 0)
         {
            return;
         }
         var _loc6_:DisplayObjectContainer = param1.getChildByName(param2) as DisplayObjectContainer;
         var _loc7_:int = 0;
         do
         {
            this.setItem(param3,_loc6_,param4,param5[_loc7_]);
            _loc7_++;
         }
         while(_loc6_ = param1.getChildByName(param2 + _loc7_) as DisplayObjectContainer, _loc6_ != null && param5[_loc7_] != null);
      }
      
      protected function setTextForResize(param1:DisplayObjectContainer, param2:String, param3:String) : Number
      {
         var _loc4_:TextField = DCUtils.getChildByPath(param1,param2) as TextField;
         var _loc5_:int = _loc4_.width;
         _loc4_.text = param3;
         _loc4_.width = _loc4_.textWidth + 5;
         return _loc4_.width - _loc5_;
      }
      
      public function constructScrollBar(param1:MovieClip, param2:MovieClip, param3:Number, param4:Number) : DCScrollBar
      {
         return new DCScrollBar(param1,param2,param3,param4);
      }
      
      private function buttonClicked(param1:ButtonEvent) : void
      {
         if(this.mButtonClickedFunction != null)
         {
            this.mButtonClickedFunction(param1);
         }
         switch(param1.mButtonType)
         {
            case DCButton.BUTTON_TYPE_OK:
            case DCButton.BUTTON_TYPE_X:
            case DCButton.BUTTON_TYPE_COMMON_CLOSE_TEXT_BOX:
               close();
         }
         trace("win button click " + param1.type + " buttn type " + param1.mButtonType);
      }
      
      private function keyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ESCAPE)
         {
            if(this.mIsButtonClose || this.isButtonOfType(DCButton.BUTTON_TYPE_CANCEL))
            {
               close();
            }
         }
         else if(param1.keyCode == Keyboard.ENTER)
         {
            if(this.isButtonOfType(DCButton.BUTTON_TYPE_OK))
            {
               close();
            }
         }
      }
      
      protected function noMouseAction() : void
      {
         mouseEnabled = false;
         buttonMode = false;
         mouseChildren = false;
      }
      
      public function addTab(param1:DisplayObjectContainer, param2:String, param3:DisplayObjectContainer, param4:String = null) : void
      {
         if(this.mTabs == null)
         {
            this.mTabs = new DCTabs(this);
         }
         var _loc5_:int = this.mTabs.getSize();
         this.mTabs.addTab(_loc5_,param4,DCUtils.getChildByPath(param1,param2) as MovieClip,param3);
         this.mTabs.selectTab(0);
      }
      
      protected function setIconFromSwf(param1:DisplayObjectContainer, param2:String, param3:String, param4:String, param5:String = null, param6:Boolean = true) : Number
      {
         if(param4 == null || param4 == "")
         {
            return 0;
         }
         var _loc7_:DisplayObject = new (DCResourceManager.getInstance().getSWFClass(param3,param4))();
         return this.setIcon(param1,param2,_loc7_,param5,param6);
      }
      
      protected function setText(param1:DisplayObjectContainer, param2:String, param3:String) : void
      {
         var _loc4_:TextField = DCUtils.getChildByPath(param1,param2) as TextField;
         _loc4_.text = param3;
      }
   }
}

