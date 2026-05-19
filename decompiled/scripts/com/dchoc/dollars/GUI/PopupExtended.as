package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class PopupExtended extends Popup
   {
      
      public static const RESOURCE_URL:String = "";
      
      public static const RESOURCE_FILE_NAME:String = "popup_standard.swf";
      
      public static const RESOURCE_CLASS_NAME:String = "popup";
      
      public static const RESOURCE_CLASS_NAME_TEXT_TITLE:String = "text_title";
      
      public static const RESOURCE_CLASS_NAME_TEXT_NORMAL:String = "text_normal";
      
      private static const ELEMTENT_AREA_BASE:String = "popup_base";
      
      private static const ELEMTENT_AREA_BODY:String = "body";
      
      private static const ELEMTENT_AREA_HEADER:String = "header";
      
      private static const ELEMTENT_AREA_FOOTER:String = "buttons_footer";
      
      private static const ELEMTENT_AREA_ICON:String = "icon";
      
      private static const ELEMTENT_AREA_BUTTON_CLOSE:String = "button_close";
      
      private static const ELEMTENT_AREA_BUTTON_ARROW_LEFT:String = "button_arrow_left";
      
      private static const ELEMTENT_AREA_BUTTON_ARROW_RIGHT:String = "button_arrow_right";
      
      private static const ALIGN_TOP_ELEMENTS:int = 0;
      
      private static const ALIGN_LEFT_ELEMENTS:int = 1;
      
      private static const ALIGN_RIGHT_ELEMENTS:int = 2;
      
      private static const ALIGN_BOTTOM_ELEMENTS:int = 3;
      
      private static const ALIGN_MIDDLE_ELEMENTS:int = 4;
      
      private static const BUTTON_OBJECT_LIST:int = 0;
      
      private static const BUTTON_CALLBACK_LIST:int = 1;
      
      private static const BUTTON_REGISTERED_CLOSE:int = 0;
      
      private static const BUTTON_REGISTERED_ARROW_LEFT:int = 1;
      
      private static const BUTTON_REGISTERED_ARROW_RIGHT:int = 2;
      
      private static const BUTTON_REGISTERED_FOOTER_FIRST:int = 3;
      
      private static const ELEMENT_BODY_PADDING:int = 10;
      
      private static const BUTTON_MAX_WIDTH:int = 150;
      
      private var mElements:Array;
      
      private var mIcon:DisplayObject;
      
      private var mDataContainer:MovieClip;
      
      private var mElementBody:DisplayObject;
      
      private var mMinWidth:Number;
      
      private var mMinHeight:Number;
      
      private var mRegisteredButtons:Array;
      
      private var mElementHeader:DisplayObject;
      
      private var mMaxHeight:Number;
      
      private var mElementBase:DisplayObject;
      
      private var mElementFooter:DisplayObject;
      
      private var mMaxWidth:Number;
      
      private var mTitle:TextField;
      
      private var mDecoration:MovieClip = mBox["decoration"];
      
      public function PopupExtended()
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(PopupExtended.RESOURCE_FILE_NAME,PopupExtended.RESOURCE_CLASS_NAME))();
         this.createButtonHolder();
         this.createTitleField();
         this.createLayoutHolder();
         this.setElementAreaVisibility(false);
         super();
      }
      
      protected function getBodyWidth() : Number
      {
         return this.mElementBody.width;
      }
      
      private function destroyLayoutHolder() : void
      {
         var _loc1_:Array = null;
         for each(_loc1_ in this.mElements)
         {
            _loc1_.length = 0;
            _loc1_ = null;
         }
         if(this.mElements != null)
         {
            this.mElements.length = 0;
            this.mElements = null;
         }
         this.mElementBase = null;
         this.mElementBody = null;
         this.mElementHeader = null;
         this.mElementFooter = null;
         if(mBox != null && mBox.contains(this.mDataContainer))
         {
            mBox.removeChild(this.mDataContainer);
         }
         this.mDataContainer = null;
      }
      
      private function createLayoutHolder() : void
      {
         this.mElementBase = mBox[PopupExtended.ELEMTENT_AREA_BASE];
         this.mElementBody = mBox[PopupExtended.ELEMTENT_AREA_BODY];
         this.mElementHeader = mBox[PopupExtended.ELEMTENT_AREA_HEADER];
         this.mElementFooter = mBox[PopupExtended.ELEMTENT_AREA_FOOTER];
         this.mElements = new Array();
         this.mElements[PopupExtended.ALIGN_TOP_ELEMENTS] = new Array();
         this.mElements[PopupExtended.ALIGN_TOP_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_ICON]);
         this.mElements[PopupExtended.ALIGN_TOP_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_HEADER]);
         this.mElements[PopupExtended.ALIGN_TOP_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_BUTTON_CLOSE]);
         this.mElements[PopupExtended.ALIGN_LEFT_ELEMENTS] = new Array();
         this.mElements[PopupExtended.ALIGN_LEFT_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_ICON]);
         this.mElements[PopupExtended.ALIGN_LEFT_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_BUTTON_ARROW_LEFT]);
         this.mElements[PopupExtended.ALIGN_RIGHT_ELEMENTS] = new Array();
         this.mElements[PopupExtended.ALIGN_RIGHT_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_BUTTON_CLOSE]);
         this.mElements[PopupExtended.ALIGN_RIGHT_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_BUTTON_ARROW_RIGHT]);
         this.mElements[PopupExtended.ALIGN_BOTTOM_ELEMENTS] = new Array();
         this.mElements[PopupExtended.ALIGN_BOTTOM_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_FOOTER]);
         this.mElements[PopupExtended.ALIGN_MIDDLE_ELEMENTS] = new Array();
         this.mElements[PopupExtended.ALIGN_MIDDLE_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_BODY]);
         this.mElements[PopupExtended.ALIGN_MIDDLE_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_HEADER]);
         this.mElements[PopupExtended.ALIGN_MIDDLE_ELEMENTS].push(mBox[PopupExtended.ELEMTENT_AREA_FOOTER]);
         this.mMinWidth = this.mElementBase.width;
         this.mMinHeight = this.mElementBase.height;
         this.mMaxWidth = Dollars.smStage.stageWidth - Dollars.smStage.stageWidth * 10 / 100;
         this.mMaxHeight = Dollars.smStage.stageHeight - Dollars.smStage.stageHeight * 10 / 100;
         this.mDataContainer = new MovieClip();
         mBox.addChild(this.mDataContainer);
         this.updateButtonsPosition();
      }
      
      private function destroyIcon() : void
      {
         if(this.mIcon != null)
         {
            mBox.removeChild(this.mIcon);
            this.mIcon = null;
         }
      }
      
      public function setTitle(param1:String) : void
      {
         this.mTitle.text = param1;
         this.updateTitlePosition();
      }
      
      protected function getTextField(param1:String, param2:int, param3:String, param4:Boolean = true) : TextField
      {
         var _loc5_:MovieClip = new (DCResourceManager.getInstance().getSWFClass(PopupExtended.RESOURCE_FILE_NAME,param1))();
         var _loc6_:TextFormat = _loc5_["caption"].defaultTextFormat;
         _loc6_.size = param2;
         _loc6_.align = param3;
         _loc5_["caption"].defaultTextFormat = _loc6_;
         if(param4)
         {
            _loc5_["caption"].autoSize = TextFieldAutoSize.LEFT;
         }
         _loc5_["caption"].wordWrap = false;
         return _loc5_["caption"];
      }
      
      private function destroyButtonHolder() : void
      {
         var _loc1_:DynamicButton = null;
         for each(_loc1_ in this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST])
         {
            if(_loc1_ != null)
            {
               mBox.removeChild(_loc1_.getButtonMc());
               _loc1_.destroy();
               _loc1_ = null;
            }
         }
         this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].length = 0;
         this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST].length = 0;
         this.mRegisteredButtons.length = 0;
      }
      
      private function createButtonHolder(param1:Boolean = true) : void
      {
         var _loc2_:DynamicButton = null;
         var _loc3_:MovieClip = null;
         this.mRegisteredButtons = new Array();
         this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST] = new Array();
         this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST] = new Array();
         if(param1)
         {
            _loc3_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.BUTTON_LIBRARY,"button_close"))();
            _loc2_ = new DynamicButton(_loc3_);
            mBox.addChild(_loc3_);
            _loc2_.addEventListener(MouseEvent.CLICK,onClose);
         }
         this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][PopupExtended.BUTTON_REGISTERED_CLOSE] = _loc2_;
         this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][PopupExtended.BUTTON_REGISTERED_ARROW_LEFT] = null;
         this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][PopupExtended.BUTTON_REGISTERED_ARROW_RIGHT] = null;
         this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST][PopupExtended.BUTTON_REGISTERED_CLOSE] = onClose;
         this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST][PopupExtended.BUTTON_REGISTERED_ARROW_LEFT] = null;
         this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST][PopupExtended.BUTTON_REGISTERED_ARROW_RIGHT] = null;
      }
      
      private function destroyTitleField() : void
      {
         mBox.removeChild(this.mTitle);
         this.mTitle = null;
      }
      
      public function setButtonLabel(param1:int, param2:String) : void
      {
         var _loc3_:DynamicButton = null;
         if(param1 >= PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST)
         {
            _loc3_ = this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][param1];
            if(_loc3_ != null)
            {
               _loc3_.setLabel(param2);
               this.updateButtonsPosition();
            }
         }
      }
      
      private function createTitleField() : void
      {
         this.mTitle = this.getTextField(PopupExtended.RESOURCE_CLASS_NAME_TEXT_TITLE,32,TextFormatAlign.CENTER,false);
         mBox.addChild(this.mTitle);
      }
      
      override protected function endButtons() : void
      {
         var _loc2_:DynamicButton = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].length)
         {
            _loc2_ = this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][_loc1_];
            if(_loc2_ != null)
            {
               _loc2_.removeEventListener(MouseEvent.CLICK,this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST][_loc1_]);
               _loc2_.end();
            }
            _loc1_++;
         }
      }
      
      protected function updateContentSize() : void
      {
         this.setBodySize(this.mDataContainer.width + PopupExtended.ELEMENT_BODY_PADDING * 2 - this.mElementBody.width,this.mDataContainer.height + PopupExtended.ELEMENT_BODY_PADDING * 2 - this.mElementBody.height);
         var _loc1_:Rectangle = this.mDataContainer.getBounds(mBox);
         var _loc2_:Rectangle = this.mElementBody.getBounds(mBox);
         this.mDataContainer.x += _loc2_.x - _loc1_.x + (this.mElementBody.width - this.mDataContainer.width) / 2;
         this.mDataContainer.y += _loc2_.y - _loc1_.y + (this.mElementBody.height - this.mDataContainer.height) / 2;
      }
      
      private function updateIconPosition() : void
      {
         if(this.mIcon != null)
         {
            this.mIcon.x = mBox[PopupExtended.ELEMTENT_AREA_ICON].x - this.mIcon.width / 3;
            this.mIcon.y = mBox[PopupExtended.ELEMTENT_AREA_ICON].y - this.mIcon.height / 3;
         }
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
      }
      
      public function addButton(param1:MovieClip, param2:Array, param3:Function) : int
      {
         var _loc5_:DynamicButton = null;
         var _loc4_:int = -1;
         if(param1 != null)
         {
            _loc4_ = int(this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].length);
            _loc5_ = new DynamicButton(param1);
            _loc5_.setLabel(param2[0]);
            if(param2.length > 1)
            {
               _loc5_.setOfferLabel(param2[1]);
            }
            mBox.addChild(param1);
            this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].push(_loc5_);
            this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST].push(param3);
            this.updateButtonsPosition();
         }
         return _loc4_;
      }
      
      override protected function startButtons() : void
      {
         var _loc2_:DynamicButton = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].length)
         {
            _loc2_ = this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][_loc1_];
            if(_loc2_ != null)
            {
               _loc2_.addEventListener(MouseEvent.CLICK,this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST][_loc1_]);
               _loc2_.start();
            }
            _loc1_++;
         }
      }
      
      private function updateButtonsPosition() : void
      {
         var _loc7_:MovieClip = null;
         var _loc8_:Number = NaN;
         var _loc1_:DynamicButton = this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][PopupExtended.BUTTON_REGISTERED_CLOSE];
         if(_loc1_ != null)
         {
         }
         var _loc2_:int = this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].length - PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST;
         var _loc3_:Number = this.mElementFooter.width / (_loc2_ + 1);
         var _loc4_:Number = this.mElementFooter.x - this.mElementFooter.width / 2;
         var _loc5_:Number = PopupExtended.BUTTON_MAX_WIDTH;
         if(_loc3_ < _loc5_)
         {
            _loc5_ = _loc3_ * 90 / 100;
         }
         var _loc6_:int = 0;
         while(_loc6_ < this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].length)
         {
            _loc1_ = this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][_loc6_];
            if(_loc1_ != null)
            {
               _loc7_ = _loc1_.getButtonMc();
               if(_loc6_ == PopupExtended.BUTTON_REGISTERED_CLOSE)
               {
                  _loc7_.x = mBox[PopupExtended.ELEMTENT_AREA_BUTTON_CLOSE].x;
                  _loc7_.y = mBox[PopupExtended.ELEMTENT_AREA_BUTTON_CLOSE].y;
               }
               else if(_loc6_ >= PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST)
               {
                  _loc7_.x = _loc4_ + _loc3_ * (_loc6_ - PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST + 1);
                  _loc7_.y = this.mElementFooter.y;
                  _loc8_ = _loc3_ - _loc3_ * 10 / 100;
                  _loc1_.updateWidth(_loc5_);
               }
            }
            _loc6_++;
         }
      }
      
      public function addContentElement(param1:DisplayObject) : void
      {
         this.mDataContainer.addChild(param1);
         this.updateContentSize();
      }
      
      private function setBodySize(param1:Number, param2:Number) : void
      {
         var _loc4_:DisplayObject = null;
         if(this.mElementBase.height + param2 >= this.mMaxHeight)
         {
            param2 = this.mMaxHeight - this.mElementBase.height;
         }
         else if(this.mElementBase.height + param2 <= this.mMinHeight)
         {
            param2 = this.mMinHeight - this.mElementBase.height;
         }
         if(this.mElementBase.width + param1 >= this.mMaxWidth)
         {
            param1 = this.mMaxWidth - this.mElementBase.width;
         }
         else if(this.mElementBase.width + param1 <= this.mMinWidth)
         {
            param1 = this.mMinWidth - this.mElementBase.width;
         }
         this.mElementBase.width += param1;
         this.mElementBase.height += param2;
         this.mElementBody.height += param2;
         this.mElementBase.x -= param1 / 2;
         this.mElementBase.y -= param2 / 2;
         this.mDecoration.y -= param2 / 2;
         var _loc3_:int = 0;
         while(_loc3_ < this.mElements.length)
         {
            for each(_loc4_ in this.mElements[_loc3_])
            {
               switch(_loc3_)
               {
                  case ALIGN_TOP_ELEMENTS:
                     _loc4_.y -= param2 / 2;
                     break;
                  case ALIGN_BOTTOM_ELEMENTS:
                     _loc4_.y += param2 / 2;
                     break;
                  case ALIGN_LEFT_ELEMENTS:
                     _loc4_.x -= param1 / 2;
                     break;
                  case ALIGN_RIGHT_ELEMENTS:
                     _loc4_.x += param1 / 2;
                     break;
                  case ALIGN_MIDDLE_ELEMENTS:
                     _loc4_.width += param1;
               }
            }
            _loc3_++;
         }
         this.updateIconPosition();
         this.updateTitlePosition();
         this.updateButtonsPosition();
      }
      
      public function logicUpdate(param1:Number) : void
      {
      }
      
      public function removeAllButtons() : void
      {
         var _loc1_:int = PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST;
         while(_loc1_ < this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].length)
         {
            this.removeButton(_loc1_);
            _loc1_++;
         }
         this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST].splice(PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST);
         this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST].splice(PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST);
      }
      
      private function setElementAreaVisibility(param1:Boolean) : void
      {
         var _loc2_:Array = null;
         var _loc3_:DisplayObject = null;
         for each(_loc2_ in this.mElements)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc3_.visible = param1;
            }
         }
      }
      
      private function removeButton(param1:int) : void
      {
         var _loc2_:DynamicButton = null;
         if(param1 >= PopupExtended.BUTTON_REGISTERED_FOOTER_FIRST)
         {
            _loc2_ = this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][param1];
            if(_loc2_ != null)
            {
               mBox.removeChild(_loc2_.getButtonMc());
               _loc2_.removeEventListener(MouseEvent.CLICK,this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST][param1]);
               _loc2_.destroy();
               _loc2_ = null;
               this.mRegisteredButtons[PopupExtended.BUTTON_OBJECT_LIST][param1] = null;
               this.mRegisteredButtons[PopupExtended.BUTTON_CALLBACK_LIST][param1] = null;
            }
         }
      }
      
      private function updateTitlePosition() : void
      {
         this.mTitle.width = this.mElementHeader.width;
         this.mTitle.height = this.mTitle.textHeight;
         this.mTitle.x = this.mElementHeader.x - this.mElementHeader.width / 2;
         this.mTitle.y = this.mElementHeader.y - this.mElementHeader.height / 2 - (this.mTitle.height - this.mElementHeader.height) / 2;
      }
      
      public function removeContentElement(param1:DisplayObject) : void
      {
         this.mDataContainer.removeChild(param1);
         this.updateContentSize();
      }
      
      override protected function onResize(param1:Event) : void
      {
         this.mMaxWidth = Dollars.smStage.stageWidth - Dollars.smStage.stageWidth * 10 / 100;
         this.mMaxHeight = Dollars.smStage.stageHeight - Dollars.smStage.stageHeight * 10 / 100;
         this.setBodySize(0,0);
         super.onResize(param1);
      }
      
      override public function destroy() : void
      {
         this.destroyLayoutHolder();
         this.destroyButtonHolder();
         this.destroyTitleField();
         this.destroyIcon();
         mBox = null;
         super.destroy();
      }
      
      public function setIcon(param1:DisplayObject) : void
      {
         if(param1 != null)
         {
            this.mIcon = param1;
            mBox.addChild(this.mIcon);
            this.updateIconPosition();
         }
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         this.destroy();
      }
   }
}

