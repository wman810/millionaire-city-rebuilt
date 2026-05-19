package com.dchoc.dollars.utils.loader
{
   public class QueuedItem
   {
      
      public var mPath:String;
      
      public var mType:String;
      
      public var mName:String;
      
      public function QueuedItem(param1:String, param2:String, param3:String)
      {
         super();
         this.mPath = param1;
         this.mName = param2;
         this.mType = param3;
      }
      
      public function release() : void
      {
         this.mPath = null;
         this.mName = null;
         this.mType = null;
      }
   }
}

