package com.dchoc.dollars.utils.math
{
   public class DChocMath
   {
      
      public function DChocMath()
      {
         super();
      }
      
      public static function rad2Degree(param1:Number) : Number
      {
         return param1 * 180 / Math.PI;
      }
      
      public static function randomNumber(param1:Number = 0, param2:Number = 1) : Number
      {
         return Math.floor(Math.random() * (1 + param2 - param1)) + param1;
      }
      
      public static function degree2Rad(param1:Number) : Number
      {
         return param1 * Math.PI / 180;
      }
   }
}

