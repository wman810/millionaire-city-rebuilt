package com.dchoc.dollars.world.accelerators
{
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class AcceleratorDefinition extends Definition
   {
      
      private var mTime:uint;
      
      public function AcceleratorDefinition(param1:uint)
      {
         super(param1);
      }
      
      override public function set sku(param1:String) : void
      {
         mSku = param1;
         this.mTime = parseInt(param1);
      }
      
      public function get time() : uint
      {
         return this.mTime;
      }
   }
}

