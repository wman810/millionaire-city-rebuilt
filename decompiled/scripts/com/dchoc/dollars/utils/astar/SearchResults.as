package com.dchoc.dollars.utils.astar
{
   public class SearchResults
   {
      
      private var path:Path;
      
      private var isSuccess:Boolean;
      
      public function SearchResults()
      {
         super();
      }
      
      public function getIsSuccess() : Boolean
      {
         return this.isSuccess;
      }
      
      public function setPath(param1:Path) : void
      {
         this.path = param1;
      }
      
      public function getPath() : Path
      {
         return this.path;
      }
      
      public function setIsSuccess(param1:Boolean) : void
      {
         this.isSuccess = param1;
      }
   }
}

