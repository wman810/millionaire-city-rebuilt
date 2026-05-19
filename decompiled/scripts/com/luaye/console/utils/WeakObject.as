package com.luaye.console.utils
{
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public class WeakObject extends Proxy
   {
      
      private var _dir:Object;
      
      private var _item:Array;
      
      public function WeakObject()
      {
         super();
         this._dir = new Object();
      }
      
      public function set(param1:String, param2:Object, param3:Boolean = false) : void
      {
         if(param2 == null)
         {
            return;
         }
         this._dir[param1] = new WeakRef(param2,param3);
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         return this.get(param1);
      }
      
      public function toString() : String
      {
         return "[WeakObject]";
      }
      
      override flash_proxy function nextNameIndex(param1:int) : int
      {
         var _loc2_:* = undefined;
         if(param1 == 0)
         {
            this._item = new Array();
            for(_loc2_ in this._dir)
            {
               this._item.push(_loc2_);
            }
         }
         if(param1 < this._item.length)
         {
            return param1 + 1;
         }
         return 0;
      }
      
      public function get(param1:String) : Object
      {
         if(this._dir[param1])
         {
            return this._dir[param1].reference;
         }
         return null;
      }
      
      override flash_proxy function setProperty(param1:*, param2:*) : void
      {
         this.set(param1,param2);
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         var _loc3_:Object = this.get(param1);
         if(_loc3_ is Function)
         {
            return (_loc3_ as Function).apply(this,rest);
         }
         return null;
      }
      
      override flash_proxy function nextName(param1:int) : String
      {
         return this._item[param1 - 1];
      }
   }
}

