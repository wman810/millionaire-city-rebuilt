package com.luaye.console.utils
{
   import flash.display.Graphics;
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   
   public class Utils
   {
      
      public function Utils()
      {
         super();
      }
      
      public static function averageOut(param1:Number, param2:Number, param3:Number) : Number
      {
         return param1 + (param2 - param1) / param3;
      }
      
      public static function angle(param1:Point, param2:Point) : Number
      {
         var _loc3_:Number = param2.x - param1.x;
         var _loc4_:Number = param2.y - param1.y;
         var _loc5_:Number = Math.atan2(_loc4_,_loc3_) / Math.PI * 180;
         _loc5_ = _loc5_ + 90;
         if(_loc5_ > 180)
         {
            _loc5_ -= 360;
         }
         return _loc5_;
      }
      
      public static function replaceByIndexes(param1:String, param2:String, param3:int, param4:int) : String
      {
         return param1.substring(0,param3) + param2 + param1.substring(param4);
      }
      
      public static function shortClassName(param1:Object) : String
      {
         var _loc2_:String = getQualifiedClassName(param1);
         var _loc3_:int = _loc2_.lastIndexOf("::");
         return _loc2_.substring(_loc3_ >= 0 ? _loc3_ + 2 : 0);
      }
      
      public static function getPointOnCircle(param1:Number, param2:Number) : Point
      {
         return new Point(param1 * Math.cos(param2),param1 * Math.sin(param2));
      }
      
      public static function round(param1:Number, param2:uint) : Number
      {
         return Math.round(param1 * param2) / param2;
      }
      
      public static function drawCircleSegment(param1:Graphics, param2:Number, param3:Point = null, param4:Number = 180, param5:Number = 0) : Point
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Point = null;
         if(!param3)
         {
            param3 = new Point();
         }
         var _loc6_:Boolean = false;
         if(param4 < 0)
         {
            _loc6_ = true;
            param4 = Math.abs(param4);
         }
         var _loc7_:Number = param4 * Math.PI / 180;
         var _loc8_:Number = param5 * Math.PI / 180;
         var _loc9_:Point = getPointOnCircle(param2,_loc8_);
         _loc9_.offset(param3.x,param3.y);
         param1.moveTo(_loc9_.x,_loc9_.y);
         var _loc10_:Number = 0;
         var _loc11_:int = 1;
         while(_loc11_ <= _loc7_ + 1)
         {
            _loc12_ = _loc11_ <= _loc7_ ? _loc11_ : _loc7_;
            _loc13_ = _loc12_ - _loc10_;
            _loc14_ = 1 + 0.12 * _loc13_ * _loc13_;
            _loc15_ = getPointOnCircle(param2 * _loc14_,(_loc12_ - _loc13_ / 2) * (_loc6_ ? -1 : 1) + _loc8_);
            _loc15_.offset(param3.x,param3.y);
            _loc9_ = getPointOnCircle(param2,_loc12_ * (_loc6_ ? -1 : 1) + _loc8_);
            _loc9_.offset(param3.x,param3.y);
            param1.curveTo(_loc15_.x,_loc15_.y,_loc9_.x,_loc9_.y);
            _loc10_ = _loc12_;
            _loc11_++;
         }
         return _loc9_;
      }
   }
}

