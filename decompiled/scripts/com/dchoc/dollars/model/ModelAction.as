package com.dchoc.dollars.model
{
   public class ModelAction
   {
      
      protected var mIsFinished:Boolean;
      
      public function ModelAction()
      {
         super();
         this.load();
      }
      
      public function doAction() : void
      {
      }
      
      protected function load() : void
      {
      }
      
      public function destroy() : void
      {
      }
      
      public function get isFinished() : Boolean
      {
         return this.mIsFinished;
      }
   }
}

