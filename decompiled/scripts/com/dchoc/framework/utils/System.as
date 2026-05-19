package com.dchoc.framework.utils
{
   public class System
   {
      
      private static var mDate:Date = new Date();
      
      public function System()
      {
         super();
      }
      
      public static function currentTimeMillis() : Number
      {
         mDate = new Date();
         return mDate.getTime();
      }
   }
}

