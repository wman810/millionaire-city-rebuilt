package com.dchoc.dollars.utils.debug
{
   import com.demonsters.debugger.MonsterDebugger;
   import com.luaye.console.C;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.system.System;
   import flash.ui.Keyboard;
   
   public class Debug
   {
      
      private static var smContext:InteractiveObject;
      
      public static var DEBUG:Boolean = Config.DEBUG_CONSOLE;
      
      private static var pows:Object = {
         "b":0,
         "k":10,
         "m":20,
         "t":30
      };
      
      private static var digits:Object = {
         "b":0,
         "k":0,
         "m":2,
         "t":4
      };
      
      public function Debug()
      {
         super();
      }
      
      public static function traceXML(param1:XML) : void
      {
         if(DEBUG)
         {
            Debug.trace("-*-*-*-*-*-*-*-*-*-*");
            Debug.trace(param1.toXMLString());
            Debug.trace("-*-*-*-*-*-*-*-*-*-*");
         }
      }
      
      public static function traceDisplayDist(param1:DisplayObjectContainer) : void
      {
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         if(DEBUG)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               _loc3_ = param1.getChildAt(_loc2_);
               Dollars.println("child[" + _loc2_ + "] = " + _loc3_);
               _loc2_++;
            }
         }
      }
      
      public static function set visible(param1:Boolean) : void
      {
         if(DEBUG)
         {
            C.visible = param1;
         }
      }
      
      public static function trace(param1:String) : void
      {
         if(DEBUG)
         {
            Dollars.println(param1);
            C.add(param1);
         }
         if(Config.DEBUG_MONSTER)
         {
            MonsterDebugger.trace(smContext,param1);
         }
      }
      
      public static function traceCh(param1:String, param2:String) : void
      {
         if(DEBUG)
         {
            Dollars.println(param2);
            C.ch(param1,param2);
         }
      }
      
      public static function traceObject(param1:Object, param2:int = 0) : void
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            _loc3_ += "  -  ";
            _loc4_++;
         }
         if(DEBUG)
         {
            for(_loc5_ in param1)
            {
               Debug.trace(_loc3_ + "- param: " + _loc5_ + " = " + param1[_loc5_]);
               if(param1[_loc5_] is Array)
               {
                  for(_loc6_ in param1[_loc5_])
                  {
                     traceObject(_loc6_,param2 + 1);
                  }
               }
               if(param1[_loc5_] is Object)
               {
                  traceObject(param1[_loc5_],param2 + 1);
               }
            }
         }
      }
      
      public static function startDebug(param1:Stage, param2:InteractiveObject) : void
      {
         if(Config.DEBUG_MONSTER)
         {
            smContext = param2;
            MonsterDebugger.initialize(param2);
            trace("Monster Debugger Working");
         }
      }
      
      public static function get visible() : Boolean
      {
         if(DEBUG)
         {
            return C.visible;
         }
         return false;
      }
      
      public static function getMemoryUsed(param1:String) : Number
      {
         var _loc2_:uint = uint(pows[param1.toLowerCase()]);
         return Number(System.totalMemory / Math.pow(2,_loc2_));
      }
      
      public static function getMemoryUsedAsString(param1:String) : String
      {
         var _loc2_:Number = getMemoryUsed(param1);
         var _loc3_:uint = uint(digits[param1.toLowerCase()]);
         return _loc2_.toFixed(_loc3_).toString();
      }
      
      public static function onKeyUp(param1:KeyboardEvent) : void
      {
         if(DEBUG)
         {
            switch(param1.keyCode)
            {
               case Keyboard.NUMPAD_0:
                  visible = !visible;
                  break;
               case Keyboard.NUMPAD_1:
                  visible = false;
                  C.x = 5;
                  C.y = 5;
                  C.width = 750;
                  C.height = 580;
                  visible = true;
                  break;
               case Keyboard.NUMPAD_2:
                  visible = false;
                  C.x = 300;
                  C.y = 490;
                  C.width = 460;
                  C.height = 100;
                  visible = true;
            }
         }
      }
      
      public static function startConsole(param1:Stage) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(!DEBUG)
         {
            _loc2_ = param1.root.loaderInfo.parameters;
            _loc3_ = _loc2_.console;
            DEBUG = _loc3_ == "1";
         }
         C.start(param1);
         C.x = 300;
         C.y = 490;
         C.width = 460;
         C.visible = false;
         if(DEBUG)
         {
            C.visible = true;
         }
      }
   }
}

