package com.luaye.console.core
{
   public class Log
   {
      
      public var next:Log;
      
      public var c:String;
      
      public var prev:Log;
      
      public var p:int;
      
      public var r:Boolean;
      
      public var s:Boolean;
      
      public var text:String;
      
      public function Log(param1:String, param2:String, param3:int, param4:Boolean = false, param5:Boolean = false)
      {
         super();
         this.text = param1;
         this.c = param2;
         this.p = param3;
         this.r = param4;
         this.s = param5;
      }
      
      public function toObject() : Object
      {
         return {
            "text":this.text,
            "c":this.c,
            "p":this.p,
            "r":this.r,
            "s":this.s
         };
      }
      
      public function toString() : String
      {
         return "[" + this.c + "] " + this.text;
      }
   }
}

