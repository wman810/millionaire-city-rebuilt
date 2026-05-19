package com.dchoc.dollars.utils.traffic
{
   import com.dchoc.dollars.utils.definitions.Definition;
   
   public class TrafficAgentDefinition extends Definition
   {
      
      private var mHeigh:int;
      
      private var mSpawnCondition:Array;
      
      private var mWidth:int;
      
      private var mSpeed:int;
      
      public function TrafficAgentDefinition(param1:uint)
      {
         super(param1);
      }
      
      public function get width() : int
      {
         return this.mWidth;
      }
      
      public function set heigh(param1:int) : void
      {
         this.mHeigh = param1;
      }
      
      public function set width(param1:int) : void
      {
         this.mWidth = param1;
      }
      
      public function set speed(param1:int) : void
      {
         this.mSpeed = param1;
      }
      
      public function get spawnCondition() : Array
      {
         return this.mSpawnCondition;
      }
      
      public function get speed() : int
      {
         return this.mSpeed;
      }
      
      public function set spawnCondition(param1:Array) : void
      {
         this.mSpawnCondition = param1;
      }
      
      public function get heigh() : int
      {
         return this.mHeigh;
      }
   }
}

