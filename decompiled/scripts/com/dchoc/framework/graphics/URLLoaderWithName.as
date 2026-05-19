package com.dchoc.framework.graphics
{
   import flash.net.URLLoader;
   
   public class URLLoaderWithName extends URLLoader
   {
      
      private static var counter:int;
      
      private var id:int;
      
      public function URLLoaderWithName()
      {
         super();
         this.id = counter;
         ++counter;
      }
      
      public function get name() : String
      {
         return this.toString() + this.id;
      }
   }
}

