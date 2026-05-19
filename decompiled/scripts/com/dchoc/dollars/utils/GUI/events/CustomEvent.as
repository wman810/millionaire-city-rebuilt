package com.dchoc.dollars.utils.GUI.events
{
   public class CustomEvent
   {
      
      private var mCurrentSimultaneously:int;
      
      private var mMaxSimultaneously:int;
      
      public function CustomEvent()
      {
         super();
         this.mCurrentSimultaneously = 0;
         this.mMaxSimultaneously = 1;
      }
      
      public function setMaxSimultaneously(param1:int) : void
      {
         this.mMaxSimultaneously = param1;
      }
      
      public function notifyEnd(param1:Object) : void
      {
         --this.mCurrentSimultaneously;
         if(this.mCurrentSimultaneously < 0)
         {
            this.mCurrentSimultaneously = 0;
         }
      }
      
      public function notifyIsAllowed() : Boolean
      {
         return this.mCurrentSimultaneously < this.mMaxSimultaneously;
      }
      
      public function getMaxSimultaneously() : int
      {
         return this.mMaxSimultaneously;
      }
      
      public function notifyStart(param1:Object) : void
      {
         ++this.mCurrentSimultaneously;
      }
      
      public function destroy() : void
      {
      }
   }
}

