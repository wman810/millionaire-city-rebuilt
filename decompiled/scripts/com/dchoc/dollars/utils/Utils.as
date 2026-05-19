package com.dchoc.dollars.utils
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   
   public class Utils
   {
      
      public function Utils()
      {
         super();
      }
      
      public static function getChk(param1:String) : int
      {
         var _loc2_:int = 317;
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = 23 * _loc2_ + param1.charCodeAt(_loc4_);
            _loc4_++;
         }
         return _loc2_;
      }
      
      public static function randomNumber(param1:Number = 0, param2:Number = 1) : Number
      {
         return Math.floor(Math.random() * (1 + param2 - param1)) + param1;
      }
      
      public static function swapMovieClips(param1:DisplayObjectContainer, param2:DisplayObject, param3:DisplayObject) : DisplayObject
      {
         param3.x = param2.x;
         param3.y = param2.y;
         param1.removeChild(param2);
         param1.addChild(param3);
         return param3;
      }
   }
}

