package com.dchoc.dollars.utils.text
{
   import com.dchoc.dollars.utils.debug.Debug;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.text.Font;
   import flash.text.GridFitType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class TextManager extends EventDispatcher
   {
      
      private static var mLang:String;
      
      private static var smInstance:TextManager;
      
      public static var smChangeFont:Boolean;
      
      private static var smScrollTimer:int;
      
      public static var smAlign:String;
      
      private static var smTimeTable:Array;
      
      private static var mLoader:URLLoader;
      
      private static var mTexts:Array;
      
      public static const EVENT_TEXT_LOADED:String = "EventTextLoaded";
      
      private static const DEFAULT_EXPRESSION:String = "%U";
      
      public static const TEXT_LOADED:String = "TextLoaded";
      
      public static const LANG_CHINESSE:String = "TW";
      
      public static const LANG_TURKISH:String = "TR";
      
      public static const LANG_INDONESIAN:String = "ID";
      
      public static const TRUNCATE_THOUSAND:int = 1;
      
      public static const TRUNCATE_MILLIONS:int = 2;
      
      public static const ALIGN_LEFT:String = "LEFT";
      
      public static const ALIGN_RIGHT:String = "RIGHT";
      
      public static const SPACE:String = " ";
      
      public static const BLANK:String = "";
      
      public static const ZERO:String = "0";
      
      private static const RETURNSTR:String = "\\n";
      
      private static const ARROBA:String = "@";
      
      public static const MIN_FONT_SIZE:Number = 10;
      
      public static const MAX_FONT_SIZE:Number = 14;
      
      private static const HORINZONTAL_MARGIN:Number = 4;
      
      private static const VERTICAL_MARGIN:Number = 2;
      
      private static const HORIZONTAL_SCROLLING_DELAY:int = 40;
      
      private static const HORIZONTAL_SCROLLING_TURNOVER_DELAY:int = 2000;
      
      public static const ARIAL_UNICODE_FONT:String = "Arial Unicode MS";
      
      public function TextManager()
      {
         super();
      }
      
      public static function isMail(param1:String) : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         if(param1 == BLANK || param1 == null || param1 == "null" || param1 == "undefined")
         {
            return false;
         }
         if(param1.indexOf(ARROBA) == -1 || param1.indexOf(ARROBA) != param1.lastIndexOf(ARROBA))
         {
            return false;
         }
         _loc2_ = param1.split(ARROBA);
         _loc3_ = _loc2_[0];
         _loc4_ = _loc2_[1];
         if(_loc3_.length < 1)
         {
            return false;
         }
         if(_loc4_.indexOf(".") == -1 || _loc4_.length < 1)
         {
            return false;
         }
         _loc5_ = _loc4_.split(".");
         _loc6_ = _loc5_.length - 1;
         _loc7_ = _loc5_[_loc6_];
         if(_loc4_.length - _loc7_.length < 4)
         {
            return false;
         }
         if(_loc7_.length < 2 || _loc7_.length > 4)
         {
            return false;
         }
         return true;
      }
      
      public static function getTimeUnits(param1:Number) : String
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:int = 86400;
         var _loc3_:int = param1 / 1000;
         if(param1 % 1000 > 0)
         {
            _loc3_++;
         }
         if(_loc3_ >= _loc2_)
         {
            return int(_loc3_ / _loc2_) + SPACE + getText(TextIDs.TID_TIME_UNIT_DAYS);
         }
         _loc4_ = _loc3_ / 60;
         _loc3_ %= 60;
         _loc5_ = _loc4_ / 60;
         _loc6_ = BLANK + _loc5_;
         if(_loc5_ < 10)
         {
            _loc6_ = ZERO + _loc5_;
         }
         return _loc6_ + SPACE + getText(TextIDs.TID_TIME_UNIT_HOURS);
      }
      
      public static function reformatTextField(param1:TextField, param2:Boolean = true) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:TextFormat = null;
         var _loc3_:String = param1.text;
         var _loc4_:TextFormat = param1.defaultTextFormat;
         var _loc5_:int = 2;
         if(smChangeFont && _loc4_.font != ARIAL_UNICODE_FONT)
         {
            _loc6_ = int(_loc4_.size);
            if(_loc6_ > 10)
            {
               _loc6_ -= _loc5_;
            }
            _loc7_ = _loc4_.align;
            _loc8_ = int(_loc4_.indent);
            if(param2 && smAlign == ALIGN_RIGHT)
            {
               if(_loc4_.align == TextFormatAlign.RIGHT)
               {
                  _loc7_ = TextFormatAlign.LEFT;
               }
               else if(_loc4_.align == TextFormatAlign.LEFT)
               {
                  _loc7_ = TextFormatAlign.RIGHT;
               }
            }
            param1.useRichTextClipboard = true;
            _loc9_ = new TextFormat(ARIAL_UNICODE_FONT,_loc6_,_loc4_.color,_loc4_.bold,_loc4_.italic,_loc4_.underline,_loc4_.url,_loc4_.target,_loc7_,_loc4_.leftMargin,_loc4_.rightMargin,_loc8_,_loc4_.leading);
            param1.defaultTextFormat = _loc9_;
            param1.embedFonts = false;
            param1.text = _loc3_;
         }
      }
      
      public static function getInstance() : TextManager
      {
         if(smInstance == null)
         {
            smInstance = new TextManager();
         }
         return smInstance;
      }
      
      public static function init() : void
      {
         mLoader = new URLLoader();
         var _loc1_:URLRequest = new URLRequest(Config.getRoot() + Dollars.TEXTS_URL + mLang + ".txt");
         mLoader.dataFormat = URLLoaderDataFormat.TEXT;
         mLoader.load(_loc1_);
         mLoader.addEventListener(Event.COMPLETE,loadText);
         mLoader.addEventListener(IOErrorEvent.IO_ERROR,loadTextError);
         smTimeTable = new Array(5);
         smTimeTable["s"] = 1000;
         smTimeTable["m"] = 60 * smTimeTable["s"];
         smTimeTable["h"] = 60 * smTimeTable["m"];
         smTimeTable["d"] = 24 * smTimeTable["h"];
         smTimeTable["z"] = 1;
      }
      
      private static function loadTextError(param1:IOErrorEvent) : void
      {
         mLang = "EN";
         smChangeFont = false;
         if(Config.DEBUG_MODE)
         {
            Debug.trace("error loading text");
         }
         init();
      }
      
      public static function getMinutesString(param1:Number) : String
      {
         param1 /= 60000;
         return BLANK + param1;
      }
      
      public static function stringToCharacter(param1:String) : String
      {
         if(param1.length == 1)
         {
            return param1;
         }
         return param1.slice(0,1);
      }
      
      public static function restoreOriginalSize(param1:TextField, param2:Number) : void
      {
         var _loc3_:TextFormat = param1.defaultTextFormat;
         var _loc4_:TextFormat = new TextFormat(_loc3_.font,param2,_loc3_.color,_loc3_.bold,_loc3_.italic,_loc3_.underline,_loc3_.url,_loc3_.target,_loc3_.align,_loc3_.leftMargin,_loc3_.rightMargin,_loc3_.indent,_loc3_.leading);
         param1.defaultTextFormat = _loc4_;
         param1.text = "aaa";
      }
      
      public static function getText(param1:int) : String
      {
         if(param1 == -1)
         {
            return "";
         }
         return String(mTexts[param1]);
      }
      
      public static function changColors(param1:TextField) : void
      {
         var _loc3_:String = null;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc9_:* = undefined;
         var _loc10_:* = undefined;
         var _loc11_:* = undefined;
         var _loc12_:* = undefined;
         var _loc2_:String = param1.text;
         var _loc8_:Array = new Array();
         do
         {
            _loc5_ = _loc2_.indexOf("{");
            if(_loc5_ > -1)
            {
               _loc3_ = BLANK;
               _loc7_ = "{";
               _loc9_ = _loc5_ + 1;
               _loc10_ = _loc5_ + 9;
               _loc11_ = _loc9_;
               while(_loc11_ < _loc10_)
               {
                  _loc3_ += _loc2_.charAt(_loc11_);
                  _loc11_++;
               }
               _loc7_ += _loc3_ + "}";
               _loc4_ = uint(_loc3_);
               _loc2_ = _loc2_.replace(_loc7_,BLANK);
               _loc6_ = _loc2_.indexOf("{/}");
               _loc2_ = _loc2_.replace("{/}",BLANK);
               _loc12_ = new TextFormat(param1.defaultTextFormat.font,param1.defaultTextFormat.size,_loc4_,param1.defaultTextFormat.bold,param1.defaultTextFormat.italic,param1.defaultTextFormat.underline,param1.defaultTextFormat.url,param1.defaultTextFormat.target,param1.defaultTextFormat.align,param1.defaultTextFormat.leftMargin,param1.defaultTextFormat.rightMargin,param1.defaultTextFormat.indent,param1.defaultTextFormat.leading);
               _loc8_.push(new Array(_loc12_,_loc5_,_loc6_));
            }
         }
         while(_loc5_ > -1);
         param1.text = _loc2_;
         _loc11_ = 0;
         while(_loc11_ < _loc8_.length)
         {
            param1.setTextFormat(_loc8_[_loc11_][0],_loc8_[_loc11_][1],_loc8_[_loc11_][2]);
            _loc11_++;
         }
      }
      
      public static function trimFront(param1:String, param2:String) : String
      {
         param2 = stringToCharacter(param2);
         if(param1.charAt(0) == param2)
         {
            param1 = trimFront(param1.substring(1),param2);
         }
         return param1;
      }
      
      public static function convertTimeToString(param1:Number, param2:Boolean, param3:Boolean = false) : String
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc4_:int = 86400;
         var _loc5_:int = param1 / 1000;
         if(param1 % 1000 > 0)
         {
            _loc5_++;
         }
         if(_loc5_ >= _loc4_)
         {
            _loc7_ = _loc5_ / _loc4_;
            _loc8_ = _loc7_ + SPACE + getText(TextIDs.TID_TIME_UNIT_DAYS);
            if(_loc7_ == 1)
            {
               _loc8_ = _loc7_ + SPACE + getText(TextIDs.TID_TIME_UNIT_DAY);
            }
            if(param3)
            {
               _loc5_ -= _loc4_ * _loc7_;
               _loc6_ = _loc5_ / 3600;
               if(_loc6_ > 0)
               {
                  if(_loc6_ == 1)
                  {
                     _loc8_ += SPACE + _loc6_ + SPACE + getText(TextIDs.TID_TIME_UNIT_HOUR);
                  }
                  else
                  {
                     _loc8_ += SPACE + _loc6_ + SPACE + getText(TextIDs.TID_TIME_UNIT_HOURS);
                  }
               }
            }
            return _loc8_;
         }
         _loc9_ = _loc5_ / 60;
         _loc5_ %= 60;
         _loc6_ = _loc9_ / 60;
         _loc9_ %= 60;
         _loc10_ = BLANK + _loc9_;
         _loc11_ = BLANK + _loc5_;
         _loc12_ = BLANK;
         if(param2)
         {
            if(_loc6_ > 0)
            {
               _loc12_ = _loc6_ + SPACE + getText(TextIDs.TID_TIME_UNIT_HOURS);
               if(_loc6_ == 1)
               {
                  _loc12_ = _loc6_ + SPACE + getText(TextIDs.TID_TIME_UNIT_HOUR);
               }
               if(_loc9_ == 0)
               {
                  return _loc12_;
               }
               return _loc12_ + SPACE + _loc10_ + SPACE + getText(TextIDs.TID_TIME_UNIT_MINUTES);
            }
            if(_loc5_ == 0)
            {
               return _loc10_ + SPACE + getText(TextIDs.TID_TIME_UNIT_MINUTES);
            }
            if(_loc9_ == 0)
            {
               return _loc11_ + SPACE + getText(TextIDs.TID_TIME_UNIT_SECONDS);
            }
            return _loc10_ + SPACE + getText(TextIDs.TID_TIME_UNIT_MINUTES) + SPACE + _loc11_ + SPACE + getText(TextIDs.TID_TIME_UNIT_SECONDS);
         }
         if(_loc6_ > 0)
         {
            _loc12_ = _loc6_ + SPACE + getText(TextIDs.TID_TIME_UNIT_HOURS);
            if(_loc6_ == 1)
            {
               _loc12_ = _loc6_ + SPACE + getText(TextIDs.TID_TIME_UNIT_HOUR);
            }
            if(_loc9_ == 0)
            {
               return _loc12_;
            }
            return _loc12_ + SPACE + _loc10_ + SPACE + getText(TextIDs.TID_TIME_UNIT_MINUTES);
         }
         return _loc10_ + SPACE + getText(TextIDs.TID_TIME_UNIT_MINUTES) + SPACE + _loc11_ + SPACE + getText(TextIDs.TID_TIME_UNIT_SECONDS);
      }
      
      public static function setCapital(param1:String) : String
      {
         var _loc2_:String = param1.charAt();
         _loc2_ = _loc2_.toUpperCase();
         return _loc2_ + param1.substr(1);
      }
      
      public static function trimBack(param1:String, param2:String) : String
      {
         param2 = stringToCharacter(param2);
         if(param1.charAt(param1.length - 1) == param2)
         {
            param1 = trimBack(param1.substring(0,param1.length - 1),param2);
         }
         return param1;
      }
      
      public static function trim(param1:String) : String
      {
         return param1.replace(/^\s*(.*?)\s*$/g,"$1");
      }
      
      private static function loadText(param1:Event) : void
      {
         var _loc3_:String = null;
         mLoader.removeEventListener(Event.COMPLETE,loadText);
         getInstance().dispatchEvent(new Event(EVENT_TEXT_LOADED));
         mTexts = new Array();
         var _loc2_:Array = String(mLoader.data).split(/\n/);
         mLoader = null;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = String(_loc2_[_loc4_]).replace(/(\\n |\\n)/g,"\n");
            mTexts.push(_loc3_);
            _loc4_++;
         }
      }
      
      public static function rtlText(param1:String) : String
      {
         if(smAlign == ALIGN_RIGHT)
         {
            param1 = ":" + param1.substring(0,param1.length - 2);
         }
         return param1;
      }
      
      public static function convertTimeToStringCollon(param1:Number) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:int = param1 / 1000;
         if(param1 % 1000 > 0)
         {
            _loc2_++;
         }
         var _loc5_:int = _loc2_ / 60;
         _loc2_ %= 60;
         _loc3_ = _loc5_ / 60;
         _loc4_ = "" + _loc3_;
         if(_loc3_ < 10)
         {
            _loc4_ = ZERO + _loc3_;
         }
         _loc5_ %= 60;
         var _loc6_:String = BLANK + _loc5_;
         if(_loc5_ < 10)
         {
            _loc6_ = ZERO + _loc5_;
         }
         var _loc7_:String = BLANK + _loc2_;
         if(_loc2_ < 10)
         {
            _loc7_ = ZERO + _loc2_;
         }
         return _loc4_ + ":" + _loc6_ + ":" + _loc7_;
      }
      
      public static function convertNumberRanking(param1:Number) : String
      {
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:* = 0;
         var _loc2_:uint = 0;
         var _loc3_:String = BLANK;
         var _loc4_:String = BLANK;
         var _loc5_:int = 4;
         var _loc6_:int = param1.toFixed(0).length;
         if(_loc6_ > _loc5_)
         {
            param1 /= 1000;
            _loc4_ = "K";
            _loc3_ = param1.toFixed(0);
            param1 = int(_loc3_);
            if(param1 >= 1000)
            {
               param1 /= 1000;
               if(param1 < 10)
               {
                  param1 *= 100;
                  _loc3_ = param1.toFixed(0);
                  param1 = int(_loc3_);
                  param1 /= 100;
                  _loc3_ = param1.toFixed(2);
                  if(_loc3_.substr(_loc3_.length - 2) == "00")
                  {
                     _loc3_ = _loc3_.substr(0,1);
                  }
               }
               else if(param1 < 100)
               {
                  _loc3_ = param1.toFixed(1);
                  if(_loc3_.substr(_loc3_.length - 1) == "0")
                  {
                     _loc3_ = _loc3_.substr(0,2);
                  }
               }
               else
               {
                  _loc3_ = int(param1).toString();
               }
               _loc4_ = "M";
            }
            _loc3_ = _loc3_.replace(/"."/g,getText(TextIDs.TID_DECIMAL_DELIMETER));
         }
         var _loc7_:String = _loc3_;
         if(param1 >= 1000)
         {
            if(param1 == 0)
            {
               _loc3_ = "0";
            }
            else
            {
               _loc3_ = Math.round(param1).toFixed(0);
            }
            _loc8_ = _loc3_.length;
            _loc7_ = BLANK;
            _loc9_ = getText(TextIDs.TID_POINTS_DELIMITER);
            if(_loc9_ == "<space>")
            {
               _loc9_ = BLANK;
            }
            _loc10_ = int(_loc8_ - 1);
            while(_loc10_ >= 0)
            {
               _loc2_++;
               if(_loc2_ == 4)
               {
                  _loc2_ = 1;
                  _loc7_ = _loc9_ + _loc7_;
               }
               _loc7_ = _loc3_.charAt(_loc10_) + _loc7_;
               _loc10_--;
            }
         }
         return _loc7_ + _loc4_;
      }
      
      private static function getParamIndex(param1:int, param2:String) : int
      {
         var _loc6_:* = undefined;
         param1 += 2;
         var _loc3_:int = String("0").charCodeAt();
         var _loc4_:int = String("9").charCodeAt();
         var _loc5_:String = BLANK;
         while(true)
         {
            _loc6_ = param2.substr(param1,1);
            if(!(_loc6_ != "" && _loc6_ != null && _loc6_.charCodeAt() >= _loc3_ && _loc6_.charCodeAt() <= _loc4_))
            {
               break;
            }
            _loc5_ += _loc6_;
            param1++;
         }
         if(_loc5_ == "")
         {
            return -1;
         }
         return int(_loc5_);
      }
      
      public static function getTextSpriteHeight(param1:TextField) : Number
      {
         var _loc2_:TextField = new TextField();
         _loc2_.defaultTextFormat = param1.defaultTextFormat;
         _loc2_.filters = param1.filters;
         _loc2_.width = param1.width;
         _loc2_.height = param1.height;
         _loc2_.text = param1.text;
         return _loc2_.textHeight;
      }
      
      public static function replaceParameters(param1:*, param2:Array) : String
      {
         var _loc3_:String = null;
         var _loc5_:* = undefined;
         if(param1 is String)
         {
            _loc3_ = param1;
         }
         else
         {
            if(!(param1 is int))
            {
               throw Error("Object type is not valid");
            }
            if(param1 == -1)
            {
               _loc3_ = BLANK;
            }
            else
            {
               _loc3_ = getText(param1);
            }
         }
         var _loc4_:int = -1;
         do
         {
            _loc4_ = _loc3_.indexOf(DEFAULT_EXPRESSION);
            if(_loc4_ > -1)
            {
               _loc5_ = getParamIndex(_loc4_,_loc3_);
               if(_loc5_ == -1)
               {
                  _loc3_ = _loc3_.replace(DEFAULT_EXPRESSION,param2[0]);
               }
               else
               {
                  _loc3_ = _loc3_.replace(DEFAULT_EXPRESSION + _loc5_,param2[_loc5_]);
               }
            }
         }
         while(_loc4_ > -1);
         return _loc3_;
      }
      
      public static function textHeight(param1:TextField) : Number
      {
         return getTextSpriteHeight(param1);
      }
      
      public static function textResetTimer() : void
      {
         smScrollTimer = 0;
      }
      
      public static function getStringFromTime(param1:Number) : String
      {
         var _loc2_:int = param1 / 1000;
         if(param1 % 1000 > 0)
         {
            _loc2_++;
         }
         var _loc3_:int = _loc2_ / 60;
         _loc2_ %= 60;
         var _loc4_:int = _loc3_ / 60;
         var _loc5_:int = _loc4_ / 24;
         var _loc6_:String = _loc5_ + "d ";
         if(_loc5_ < 1)
         {
            _loc6_ = "";
         }
         else if(_loc5_ < 10)
         {
            _loc6_ = ZERO + _loc5_ + "d ";
         }
         _loc4_ %= 24;
         var _loc7_:String = _loc4_ + "h ";
         if(_loc4_ < 1 && _loc5_ < 1)
         {
            _loc7_ = "";
         }
         else if(_loc4_ < 10)
         {
            _loc7_ = ZERO + _loc4_ + "h ";
         }
         _loc3_ %= 60;
         var _loc8_:String = _loc3_ + "m ";
         if(_loc3_ < 1 && _loc4_ < 1 && _loc5_ < 1)
         {
            _loc8_ = "";
         }
         else if(_loc3_ < 10)
         {
            _loc8_ = ZERO + _loc3_ + "m ";
         }
         var _loc9_:String = _loc2_ + "s";
         if(_loc2_ < 10)
         {
            _loc9_ = ZERO + _loc2_ + "s";
         }
         return _loc6_ + _loc7_ + _loc8_ + _loc9_;
      }
      
      public static function getStringTimeOffer(param1:Number) : String
      {
         var _loc6_:String = null;
         var _loc2_:int = param1 / 1000;
         if(param1 % 1000 > 0)
         {
            _loc2_++;
         }
         var _loc3_:int = _loc2_ / 60;
         var _loc4_:int = _loc3_ / 60;
         var _loc5_:int = _loc4_ / 24;
         if(_loc5_ > 0)
         {
            _loc6_ = _loc5_ > 1 ? TextManager.getText(TextIDs.TID_TIME_UNIT_DAYS) : TextManager.getText(TextIDs.TID_TIME_UNIT_DAY);
            return TextManager.replaceParameters(TextIDs.TID_ITEMS_LEFT,new Array(_loc5_ + " " + _loc6_));
         }
         _loc4_ %= 24;
         if(_loc4_ > 0)
         {
            _loc6_ = _loc4_ > 1 ? TextManager.getText(TextIDs.TID_TIME_UNIT_HOURS) : TextManager.getText(TextIDs.TID_TIME_UNIT_HOUR);
            return TextManager.replaceParameters(TextIDs.TID_ITEMS_LEFT,new Array(_loc4_ + " " + _loc6_));
         }
         _loc3_ %= 60;
         if(_loc3_ == 0)
         {
            _loc3_ = 1;
         }
         return TextManager.replaceParameters(TextIDs.TID_ITEMS_LEFT,new Array(_loc3_ + " " + TextManager.getText(TextIDs.TID_TIME_UNIT_MINUTES)));
      }
      
      public static function textWidth(param1:TextField) : Number
      {
         return getTextSpriteWidth(param1);
      }
      
      public static function reverseTextfield(param1:TextField) : void
      {
         var _loc2_:TextField = new TextField();
         _loc2_.defaultTextFormat = param1.defaultTextFormat;
         _loc2_.embedFonts = param1.embedFonts;
         _loc2_.filters = _loc2_.filters;
      }
      
      public static function convertStringToTime(param1:String) : int
      {
         var _loc2_:String = param1.substr(param1.length - 1);
         var _loc3_:int = int(param1.substr(0,param1.length - 1));
         if(_loc2_ >= "0" && _loc2_ <= "9")
         {
            _loc2_ = "z";
         }
         return _loc3_ * smTimeTable[_loc2_];
      }
      
      public static function getFontHeight(param1:Font, param2:String) : int
      {
         var _loc3_:TextField = new TextField();
         _loc3_.text = param2;
         return _loc3_.getLineMetrics(0).height;
      }
      
      public static function set lang(param1:String) : void
      {
         mLang = param1;
      }
      
      public static function textUpdate(param1:int) : void
      {
         smScrollTimer += param1;
      }
      
      public static function textDrawScrolling(param1:TextField) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:Number = param1.textWidth;
         if(_loc2_ > param1.width)
         {
            _loc3_ = 0;
            _loc4_ = _loc2_ - param1.width + 5;
            _loc5_ = HORIZONTAL_SCROLLING_TURNOVER_DELAY;
            _loc6_ = _loc5_ + _loc4_ * HORIZONTAL_SCROLLING_DELAY;
            _loc7_ = _loc6_ + HORIZONTAL_SCROLLING_TURNOVER_DELAY;
            _loc9_ = _loc8_ = _loc7_ + _loc4_ * HORIZONTAL_SCROLLING_DELAY;
            _loc10_ = smScrollTimer % _loc9_;
            if(_loc10_ < _loc5_)
            {
               _loc3_ = 0;
            }
            else if(_loc10_ < _loc6_)
            {
               _loc10_ -= _loc5_;
               _loc3_ = -_loc10_ / HORIZONTAL_SCROLLING_DELAY;
            }
            else if(_loc10_ < _loc7_)
            {
               _loc3_ = -_loc4_;
            }
            else
            {
               _loc10_ -= _loc7_;
               _loc3_ = -_loc4_ + _loc10_ / HORIZONTAL_SCROLLING_DELAY;
            }
            param1.scrollH = _loc3_;
         }
      }
      
      public static function getTextSpriteWidth(param1:TextField) : Number
      {
         var _loc2_:TextField = new TextField();
         Dollars.smStage.addChild(_loc2_);
         _loc2_.defaultTextFormat = param1.defaultTextFormat;
         _loc2_.filters = param1.filters;
         _loc2_.width = param1.width;
         _loc2_.height = param1.height;
         _loc2_.text = param1.text;
         var _loc3_:Number = _loc2_.textWidth;
         Dollars.smStage.removeChild(_loc2_);
         return _loc3_;
      }
      
      public static function splitText(param1:String, param2:Font, param3:int) : Array
      {
         var _loc4_:Array = new Array();
         var _loc5_:Array = param1.split(SPACE);
         var _loc6_:String = _loc5_[0];
         var _loc7_:int = 1;
         while(_loc7_ < _loc5_.length)
         {
            if(getStringWidth(null,_loc6_ + SPACE + _loc5_[_loc7_]) > param3)
            {
               _loc4_.push(_loc6_);
               _loc6_ = _loc5_[_loc7_];
               if(_loc6_.substr(_loc6_.length - 2) == RETURNSTR)
               {
                  _loc4_.push(_loc6_.substring(0,_loc6_.length - 2));
                  _loc7_++;
                  _loc6_ = _loc5_[_loc7_];
               }
            }
            else
            {
               _loc6_ += SPACE + _loc5_[_loc7_];
               if(_loc6_.substr(_loc6_.length - 2) == RETURNSTR)
               {
                  _loc4_.push(_loc6_.substring(0,_loc6_.length - 2));
                  _loc7_++;
                  _loc6_ = _loc5_[_loc7_];
               }
            }
            _loc7_++;
         }
         if(_loc6_ != BLANK)
         {
            _loc4_.push(_loc6_);
         }
         return _loc4_;
      }
      
      public static function setTextScaled(param1:TextField, param2:Boolean = true, param3:Number = 4) : void
      {
         var _loc4_:String = param1.text;
         var _loc5_:TextFormat = param1.defaultTextFormat;
         var _loc6_:* = int(_loc5_.size);
         var _loc7_:Number = param1.textHeight;
         var _loc8_:int = MIN_FONT_SIZE;
         if(smChangeFont && _loc6_ < MAX_FONT_SIZE + _loc8_)
         {
            _loc6_ = int(MAX_FONT_SIZE);
            _loc8_ -= 2;
            _loc5_.size = _loc6_;
            param1.defaultTextFormat = _loc5_;
            param1.text = _loc4_;
         }
         while(param1.textWidth + param3 > param1.width && _loc6_ > _loc8_)
         {
            _loc6_--;
            _loc5_.size = _loc6_;
            param1.defaultTextFormat = _loc5_;
            param1.text = _loc4_;
         }
         while(param1.textHeight + VERTICAL_MARGIN > param1.height && _loc6_ > _loc8_)
         {
            _loc6_--;
            _loc5_.size = _loc6_;
            param1.defaultTextFormat = _loc5_;
            param1.text = _loc4_;
         }
         param1.useRichTextClipboard = param2;
         if(param2 && param1.useRichTextClipboard && param1.textHeight < _loc7_)
         {
            param1.y += (_loc7_ - param1.textHeight) / 2;
            param1.useRichTextClipboard = false;
         }
         param1.gridFitType = GridFitType.SUBPIXEL;
      }
      
      public static function get lang() : String
      {
         return mLang;
      }
      
      public static function convertNumberToString(param1:Number, param2:int, param3:int) : String
      {
         var _loc4_:* = 0;
         var _loc5_:String = BLANK;
         var _loc6_:String = BLANK;
         var _loc7_:int = param1.toFixed(0).length;
         if(param2 == TRUNCATE_THOUSAND)
         {
            if(_loc7_ > param3)
            {
               param1 /= 1000;
               _loc6_ = "K";
               if(param1 >= 1000)
               {
                  param1 /= 1000;
                  _loc6_ = "M";
               }
            }
         }
         if(param2 == TRUNCATE_MILLIONS)
         {
            if(_loc7_ > param3)
            {
               param1 /= 1000000;
               _loc6_ = "M";
            }
         }
         if(param1 == 0)
         {
            return "0";
         }
         if(param1 < 10 && param1 != int(param1))
         {
            _loc5_ = param1.toFixed(2);
         }
         else
         {
            _loc5_ = param1.toFixed(0);
         }
         var _loc8_:int = _loc5_.length;
         var _loc9_:String = BLANK;
         var _loc10_:String = getText(TextIDs.TID_POINTS_DELIMITER);
         if(_loc10_ == "<space>")
         {
            _loc10_ = BLANK;
         }
         var _loc11_:* = int(_loc8_ - 1);
         while(_loc11_ >= 0)
         {
            if(_loc5_.charAt(_loc11_) == ".")
            {
               _loc9_ = getText(TextIDs.TID_DECIMAL_DELIMETER) + _loc9_;
            }
            else
            {
               if(++_loc4_ == 4)
               {
                  _loc4_ = 1;
                  _loc9_ = _loc10_ + _loc9_;
               }
               _loc9_ = _loc5_.charAt(_loc11_) + _loc9_;
            }
            _loc11_--;
         }
         return _loc9_ + _loc6_;
      }
      
      public static function getPercentageText(param1:int, param2:Boolean = true) : String
      {
         var _loc3_:String = TextManager.convertNumberToString(Math.abs(param1),0,0);
         var _loc4_:String = BLANK;
         if(param2)
         {
            if(param1 > 0)
            {
               _loc4_ = "+";
            }
            else if(param1 < 0)
            {
               _loc4_ = "-";
            }
         }
         return _loc4_ + TextManager.replaceParameters(TextIDs.TID_GEN_PERCENTAGE,new Array(_loc3_));
      }
      
      public static function getStringWidth(param1:Font, param2:String) : int
      {
         var _loc3_:TextField = new TextField();
         _loc3_.text = param2;
         return _loc3_.getLineMetrics(0).width;
      }
   }
}

