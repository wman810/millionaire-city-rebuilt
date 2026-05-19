package com.luaye.console.core
{
   public class Logs
   {
      
      private var _length:uint;
      
      public var first:Log;
      
      public var last:Log;
      
      public function Logs()
      {
         super();
      }
      
      public function shift(param1:uint = 1) : void
      {
         while(this.first != null && param1 > 0)
         {
            this.first = this.first.next;
            param1--;
            --this._length;
         }
      }
      
      public function remove(param1:Log) : void
      {
         if(this.first == param1)
         {
            this.first = param1.next;
         }
         if(this.last == param1)
         {
            this.last = param1.prev;
         }
         if(param1.next != null)
         {
            param1.next.prev = param1.prev;
         }
         if(param1.prev != null)
         {
            param1.prev.next = param1.next;
         }
         --this._length;
      }
      
      public function get length() : uint
      {
         return this._length;
      }
      
      public function clear() : void
      {
         this.first = null;
         this.last = null;
         this._length = 0;
      }
      
      public function pop() : void
      {
         if(this.last)
         {
            this.last = this.last.prev;
            --this._length;
         }
      }
      
      public function push(param1:Log) : void
      {
         if(this.last == null)
         {
            this.first = param1;
         }
         else
         {
            this.last.next = param1;
            param1.prev = this.last;
         }
         this.last = param1;
         ++this._length;
      }
   }
}

