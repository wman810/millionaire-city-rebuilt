package com.dchoc.dollars.utils.math
{
   public class Vector2D
   {
      
      private var xValue:Number = 0;
      
      private var yValue:Number = 0;
      
      public function Vector2D(... rest)
      {
         super();
         this.xValue = 0;
         this.yValue = 0;
         if(2 == rest.length)
         {
            this.xValue = this.fixNumber(rest[0]);
            this.yValue = this.fixNumber(rest[1]);
         }
         else if(1 == rest.length)
         {
            if(rest[0] is Vector2D)
            {
               this.xValue = rest[0].x;
               this.yValue = rest[0].y;
            }
         }
      }
      
      public function cross(param1:Vector2D) : Number
      {
         if(param1 is Vector2D)
         {
            return Math.abs(this.fixNumber(this.xValue * param1.yValue - this.yValue * param1.xValue));
         }
         return 0;
      }
      
      public function set y(param1:Number) : void
      {
         this.yValue = this.fixNumber(param1);
      }
      
      public function getLeftNormal() : Vector2D
      {
         return new Vector2D(-this.yValue,this.xValue);
      }
      
      public function isEqualTo(param1:Vector2D) : Boolean
      {
         if(param1 is Vector2D)
         {
            if(this.xValue === param1.xValue && this.yValue === param1.yValue)
            {
               return true;
            }
         }
         return false;
      }
      
      public function times(... rest) : Vector2D
      {
         if(1 == rest.length)
         {
            if(rest[0] is Vector2D)
            {
               this.xValue *= rest[0].xValue;
               this.yValue *= rest[0].yValue;
            }
            else if(isNaN(Number(rest[0])))
            {
               this.xValue = this.yValue = 0;
            }
            else
            {
               this.xValue *= Number(rest[0]);
               this.yValue *= Number(rest[0]);
            }
         }
         else if(2 == rest.length)
         {
            if(isNaN(Number(rest[0])))
            {
               this.xValue = 0;
            }
            else
            {
               this.xValue *= Number(rest[0]);
            }
            if(isNaN(Number(rest[1])))
            {
               this.yValue = 0;
            }
            else
            {
               this.yValue *= Number(rest[1]);
            }
         }
         this.xValue = this.fixNumber(this.xValue);
         this.yValue = this.fixNumber(this.yValue);
         return this;
      }
      
      public function set x(param1:Number) : void
      {
         this.xValue = this.fixNumber(param1);
      }
      
      public function dot(param1:Vector2D) : Number
      {
         if(param1 is Vector2D)
         {
            return this.fixNumber(this.xValue * param1.xValue + this.yValue * param1.yValue);
         }
         return 0;
      }
      
      public function isNormalTo(param1:Vector2D) : Boolean
      {
         if(param1 is Vector2D)
         {
            return this.dot(param1) === 0;
         }
         return false;
      }
      
      public function normalize() : Vector2D
      {
         var _loc1_:Vector2D = new Vector2D();
         if(this.magnitude > 1e-8)
         {
            _loc1_.xValue = this.xValue / this.magnitude;
            _loc1_.yValue = this.yValue / this.magnitude;
         }
         return _loc1_;
      }
      
      public function get magnitude() : Number
      {
         return this.fixNumber(Math.sqrt(Math.pow(this.xValue,2) + Math.pow(this.yValue,2)));
      }
      
      public function angleBetweenCos(param1:Vector2D) : Number
      {
         if(param1 is Vector2D)
         {
            return this.fixNumber(this.dot(param1) / (this.magnitude * param1.magnitude));
         }
         return 0;
      }
      
      public function swap(param1:Vector2D) : Vector2D
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(param1 is Vector2D)
         {
            _loc2_ = this.xValue;
            _loc3_ = this.yValue;
            this.xValue = param1.xValue;
            this.yValue = param1.yValue;
            param1.xValue = _loc2_;
            param1.yValue = _loc3_;
         }
         return this;
      }
      
      public function invert() : Vector2D
      {
         this.xValue *= -1;
         this.yValue *= -1;
         return this;
      }
      
      public function project(param1:Vector2D) : Vector2D
      {
         var _loc2_:Number = NaN;
         if(param1 is Vector2D)
         {
            _loc2_ = this.dot(param1) / Math.pow(param1.magnitude,2);
            this.set(param1);
            this.times(_loc2_);
         }
         return this;
      }
      
      public function plus(... rest) : Vector2D
      {
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            if(rest[_loc2_] is Vector2D)
            {
               this.xValue += rest[_loc2_].xValue;
               this.yValue += rest[_loc2_].yValue;
            }
            _loc2_++;
         }
         this.xValue = this.fixNumber(this.xValue);
         this.yValue = this.fixNumber(this.yValue);
         return this;
      }
      
      public function rotate(param1:Number) : Vector2D
      {
         if(isNaN(Number(param1)))
         {
            return this;
         }
         var _loc2_:Number = Math.sqrt(Math.pow(this.xValue,2) + Math.pow(this.yValue,2));
         var _loc3_:Number = (Math.atan2(this.yValue,this.xValue) * (180 / Math.PI) + Number(param1)) * (Math.PI / 180);
         this.xValue = this.fixNumber(_loc2_ * Math.cos(_loc3_));
         this.yValue = this.fixNumber(_loc2_ * Math.sin(_loc3_));
         return this;
      }
      
      public function paint(param1:Object, param2:Number) : void
      {
         param1.graphics.lineStyle(0,param2);
         param1.graphics.moveTo(0,0);
         param1.graphics.lineTo(this.xValue,this.yValue);
      }
      
      public function truncate(param1:Number, param2:Number) : void
      {
         if(this.magnitude > param1)
         {
            this.normalize();
            this.times(param1);
         }
         else if(this.magnitude < param2)
         {
            this.normalize();
            this.times(param2);
         }
      }
      
      public function set(... rest) : Vector2D
      {
         this.xValue = 0;
         this.yValue = 0;
         if(2 == rest.length)
         {
            this.xValue = this.fixNumber(rest[0]);
            this.yValue = this.fixNumber(rest[1]);
         }
         else if(1 == rest.length)
         {
            if(rest[0] is Vector2D)
            {
               this.xValue = rest[0].x;
               this.yValue = rest[0].y;
            }
         }
         return this;
      }
      
      public function angleBetweenSin(param1:Vector2D) : Number
      {
         if(param1 is Vector2D)
         {
            return this.fixNumber(this.cross(param1) / (this.magnitude * param1.magnitude));
         }
         return 0;
      }
      
      public function set angle(param1:Number) : void
      {
         var _loc2_:Number = 0;
         if(!isNaN(Number(param1)))
         {
            _loc2_ = Number(param1) * (Math.PI / 180);
         }
         var _loc3_:Number = Math.sqrt(Math.pow(this.xValue,2) + Math.pow(this.yValue,2));
         this.xValue = this.fixNumber(_loc3_ * Math.cos(_loc2_));
         this.yValue = this.fixNumber(_loc3_ * Math.sin(_loc2_));
      }
      
      public function set magnitude(param1:Number) : void
      {
         if(isNaN(Number(param1)))
         {
            this.xValue = this.yValue = 0;
         }
         var _loc2_:Number = Math.sqrt(Math.pow(this.xValue,2) + Math.pow(this.yValue,2));
         if(0 < _loc2_)
         {
            this.times(Number(param1) / _loc2_);
         }
         else
         {
            this.yValue = 0;
            this.xValue = this.fixNumber(param1);
         }
      }
      
      public function get angle() : Number
      {
         return this.fixNumber(Math.atan2(this.yValue,this.xValue) * (180 / Math.PI));
      }
      
      public function toString() : String
      {
         return "[" + this.xValue + "," + this.yValue + "]";
      }
      
      public function getRightNormal() : Vector2D
      {
         return new Vector2D(this.yValue,-this.xValue);
      }
      
      public function angleBetween(param1:Vector2D) : Number
      {
         if(param1 is Vector2D)
         {
            return this.fixNumber(Math.acos(this.dot(param1) / (this.magnitude * param1.magnitude)) * (180 / Math.PI));
         }
         return 0;
      }
      
      public function minus(... rest) : Vector2D
      {
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            if(rest[_loc2_] is Vector2D)
            {
               this.xValue -= rest[_loc2_].xValue;
               this.yValue -= rest[_loc2_].yValue;
            }
            _loc2_++;
         }
         this.xValue = this.fixNumber(this.xValue);
         this.yValue = this.fixNumber(this.yValue);
         return this;
      }
      
      public function get y() : Number
      {
         return this.yValue;
      }
      
      public function reflect(param1:Vector2D) : Vector2D
      {
         var _loc2_:Vector2D = null;
         var _loc3_:Number = NaN;
         if(param1 is Vector2D)
         {
            _loc2_ = new Vector2D(param1.yValue,-param1.xValue);
            _loc3_ = 2 * this.angleBetween(param1);
            if(0 >= this.angleBetweenCos(_loc2_))
            {
               _loc3_ *= -1;
            }
            this.rotate(_loc3_);
         }
         return this;
      }
      
      private function fixNumber(param1:Number) : Number
      {
         return isNaN(Number(param1)) ? 0 : Math.round(Number(param1) * 100000) / 100000;
      }
      
      public function get x() : Number
      {
         return this.xValue;
      }
   }
}

