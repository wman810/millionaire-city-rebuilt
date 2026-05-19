package com.dchoc.dollars.utils.timer
{
   public class TimerUtil
   {
      
      public static const SECOND_TO_MS:Number = 1000;
      
      public static const MIN_TO_MS:Number = 60 * SECOND_TO_MS;
      
      public static const HOUR_TO_MS:Number = 60 * MIN_TO_MS;
      
      public static const DAY_TO_MS:Number = 24 * HOUR_TO_MS;
      
      public function TimerUtil()
      {
         super();
      }
      
      public static function msToHour(param1:Number) : int
      {
         return param1 / HOUR_TO_MS;
      }
      
      public static function hourToMs(param1:Number) : Number
      {
         return param1 * HOUR_TO_MS;
      }
      
      public static function daysToMs(param1:Number) : Number
      {
         return param1 * DAY_TO_MS;
      }
      
      public static function msToMin(param1:Number) : Number
      {
         return param1 / MIN_TO_MS;
      }
      
      public static function minToMs(param1:Number) : Number
      {
         return param1 * MIN_TO_MS;
      }
      
      public static function secondToMs(param1:Number) : Number
      {
         return param1 * SECOND_TO_MS;
      }
      
      public static function getDateInMs(param1:String) : Number
      {
         var _loc2_:Array = param1.split(":");
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(_loc2_.length > 3)
         {
            _loc3_ = int(_loc2_[3]);
            _loc4_ = int(_loc2_[4]);
         }
         var _loc5_:Date = new Date(_loc2_[2],_loc2_[1] - 1,_loc2_[0],_loc3_,_loc4_);
         return _loc5_.getTime();
      }
      
      public static function msToDays(param1:Number) : int
      {
         return param1 / DAY_TO_MS;
      }
   }
}

