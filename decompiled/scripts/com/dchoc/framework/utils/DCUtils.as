package com.dchoc.framework.utils
{
   import com.dchoc.framework.GUI.DCWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class DCUtils
   {
      
      public function DCUtils()
      {
         super();
      }
      
      public static function bitmap9Scale(param1:Sprite, param2:int, param3:int) : Sprite
      {
         param2 = param2 - param1.getChildByName("left").width - param1.getChildByName("right").width;
         param3 = param3 - param1.getChildByName("top").height - param1.getChildByName("bottom").height;
         param1.getChildByName("top").width = param1.getChildByName("top").width + (param2 - param1.getChildByName("top_right").width);
         param1.getChildByName("top_right").x = param1.getChildByName("top_right").x + (param2 - param1.getChildByName("top_right").width);
         param1.getChildByName("left").height = param1.getChildByName("left").height + (param3 - param1.getChildByName("bottom_left").height);
         param1.getChildByName("middle").width = param1.getChildByName("middle").width + (param2 - param1.getChildByName("right").width);
         param1.getChildByName("middle").height = param1.getChildByName("middle").height + (param3 - param1.getChildByName("bottom").height);
         param1.getChildByName("right").height = param1.getChildByName("right").height + (param3 - param1.getChildByName("bottom_right").height);
         param1.getChildByName("right").x = param1.getChildByName("right").x + (param2 - param1.getChildByName("right").width);
         param1.getChildByName("bottom_left").y = param1.getChildByName("bottom_left").y + (param3 - param1.getChildByName("bottom_left").height);
         param1.getChildByName("bottom").width = param1.getChildByName("bottom").width + (param2 - param1.getChildByName("bottom_right").width);
         param1.getChildByName("bottom").y = param1.getChildByName("bottom").y + (param3 - param1.getChildByName("bottom").height);
         param1.getChildByName("bottom_right").x = param1.getChildByName("bottom_right").x + (param2 - param1.getChildByName("bottom_right").width);
         param1.getChildByName("bottom_right").y = param1.getChildByName("bottom_right").y + (param3 - param1.getChildByName("bottom_right").height);
         return param1;
      }
      
      public static function getChildByPath(param1:DisplayObjectContainer, param2:String) : DisplayObject
      {
         if(param2 == null || param2 == "")
         {
            return param1;
         }
         var _loc3_:Array = param2.split("/");
         var _loc4_:DisplayObjectContainer = param1;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length - 1)
         {
            _loc4_ = _loc4_.getChildByName(_loc3_[_loc5_]) as DisplayObjectContainer;
            _loc5_++;
         }
         return _loc4_.getChildByName(_loc3_[_loc5_]);
      }
      
      public static function getClass(param1:Object) : Class
      {
         return Class(getDefinitionByName(getQualifiedClassName(param1)));
      }
      
      public static function sprite3Scale(param1:Sprite, param2:int) : Sprite
      {
         param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND_MIDDLE).width = param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND_MIDDLE).width + (param2 - param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND_RIGHT).width);
         param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND_RIGHT).x = param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND_RIGHT).x + (param2 - param1.getChildByName(DCWindow.INSTANCE_NAME_BACKGROUND_RIGHT).width);
         return param1;
      }
      
      public static function getLowestChildY(param1:MovieClip) : Number
      {
         var _loc4_:DisplayObject = null;
         var _loc2_:Number = 0;
         var _loc3_:int = 1;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_);
            if(_loc4_.y + _loc4_.height > _loc2_)
            {
               _loc2_ = _loc4_.y + _loc4_.height;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function centerClip(param1:DisplayObjectContainer) : void
      {
         param1.x = param1.stage.stageWidth / 2;
         param1.y = param1.stage.stageHeight / 2;
      }
      
      public static function duplicateDisplayObject(param1:DisplayObject, param2:Boolean = false) : DisplayObject
      {
         var _loc5_:Rectangle = null;
         var _loc3_:Class = Object(param1).constructor;
         var _loc4_:DisplayObject = new _loc3_();
         _loc4_.transform = param1.transform;
         _loc4_.filters = param1.filters;
         _loc4_.cacheAsBitmap = param1.cacheAsBitmap;
         _loc4_.opaqueBackground = param1.opaqueBackground;
         if(param1.scale9Grid)
         {
            _loc5_ = param1.scale9Grid;
            _loc5_.x /= 20;
            _loc5_.y /= 20;
            _loc5_.width /= 20;
            _loc5_.height /= 20;
            _loc4_.scale9Grid = _loc5_;
         }
         if(param2 && Boolean(param1.parent))
         {
            param1.parent.addChild(_loc4_);
         }
         return _loc4_;
      }
      
      public static function getRoot(param1:MovieClip) : MovieClip
      {
         var _loc2_:DisplayObject = param1;
         while(_loc2_.parent != null)
         {
            _loc2_ = _loc2_.parent;
         }
         return _loc2_ as MovieClip;
      }
      
      public static function getSpriteAsMovieClip(param1:Sprite) : MovieClip
      {
         var _loc2_:MovieClip = new MovieClip();
         _loc2_.addChild(param1);
         return _loc2_;
      }
      
      public static function bringToFront(param1:DisplayObjectContainer, param2:DisplayObject) : void
      {
         param1.setChildIndex(param2,param1.numChildren - 1);
      }
   }
}

