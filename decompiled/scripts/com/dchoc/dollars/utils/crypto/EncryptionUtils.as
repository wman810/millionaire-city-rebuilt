package com.dchoc.dollars.utils.crypto
{
   public class EncryptionUtils
   {
      
      public function EncryptionUtils()
      {
         super();
      }
      
      private static function decryptCustom(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = Number(param1 ^ param3);
         var _loc5_:int = int(param2) % 32;
         var _loc6_:int = _loc4_ << _loc5_;
         if(_loc5_ == 0)
         {
            return _loc6_;
         }
         var _loc7_:int = _loc4_ >>> 32 - _loc5_;
         return int(_loc6_ + _loc7_);
      }
      
      public static function calculateChecksumFrom(param1:Array) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ += param1[_loc3_];
            _loc2_ ^= 47856487 + (_loc3_ << 3);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function decrypt(param1:int, param2:Number, param3:Number, param4:Number = 0) : Number
      {
         var _loc5_:Number = 0;
         var _loc6_:int = param1;
         switch(0)
         {
         }
         return decryptCustom(param2,param3,param4);
      }
      
      public static function encrypt(param1:int, param2:Number, param3:Number, param4:Number = 0) : Number
      {
         var _loc5_:Number = 0;
         var _loc6_:int = param1;
         switch(0)
         {
         }
         return encryptCustom(param2,param3,param4);
      }
      
      private static function encryptCustom(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:int = int(param2) % 32;
         var _loc5_:int = param1 >> _loc4_;
         var _loc6_:int = _loc4_ == 0 ? 0 : param1 << 32 - _loc4_;
         var _loc7_:int = _loc5_ + _loc6_;
         return Number(_loc7_ ^ param3);
      }
   }
}

