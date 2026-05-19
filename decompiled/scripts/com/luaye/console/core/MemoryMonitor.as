package com.luaye.console.core
{
   import flash.events.EventDispatcher;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class MemoryMonitor extends EventDispatcher
   {
      
      private var _namesList:Object;
      
      private var _objectsList:Dictionary;
      
      public function MemoryMonitor()
      {
         super();
         this._namesList = new Object();
         this._objectsList = new Dictionary(true);
      }
      
      public function update() : Array
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc1_:Array = new Array();
         var _loc2_:Object = new Object();
         for(_loc3_ in this._objectsList)
         {
            _loc2_[this._objectsList[_loc3_]] = true;
         }
         for(_loc4_ in this._namesList)
         {
            if(!_loc2_[_loc4_])
            {
               _loc1_.push(_loc4_);
               delete this._namesList[_loc4_];
            }
         }
         return _loc1_;
      }
      
      public function gc() : Boolean
      {
         if(System["gc"] != null)
         {
            System["gc"]();
            return true;
         }
         return false;
      }
      
      public function unwatch(param1:String) : void
      {
         var _loc2_:Object = null;
         for(_loc2_ in this._objectsList)
         {
            if(this._objectsList[_loc2_] == param1)
            {
               delete this._objectsList[_loc2_];
            }
         }
         delete this._namesList[param1];
      }
      
      public function watch(param1:Object, param2:String) : String
      {
         var _loc3_:String = null;
         if(this._objectsList[param1])
         {
            if(this._namesList[this._objectsList[param1]])
            {
               this.unwatch(this._objectsList[param1]);
            }
         }
         if(Boolean(this._namesList[param2]) && this._objectsList[param1] != param2)
         {
            _loc3_ = param2 + "@" + getTimer() + "_" + Math.floor(Math.random() * 100);
            param2 = _loc3_;
         }
         this._namesList[param2] = true;
         this._objectsList[param1] = param2;
         return param2;
      }
   }
}

