package com.dchoc.dollars.utils.astar
{
   public class PriorityQueue
   {
      
      private var items:Array;
      
      public function PriorityQueue()
      {
         super();
         this.items = new Array();
      }
      
      public function hasNextItem() : Boolean
      {
         return this.items.length > 0;
      }
      
      public function getNextItem() : Path
      {
         return Path(this.items.shift());
      }
      
      public function enqueue(param1:Path) : void
      {
         var _loc5_:Path = null;
         var _loc2_:Number = param1.getF();
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         while(_loc4_ < this.items.length)
         {
            _loc5_ = Path(this.items[_loc4_]);
            if(_loc2_ < _loc5_.getF())
            {
               this.items.splice(_loc4_,0,param1);
               _loc3_ = true;
               break;
            }
            _loc4_++;
         }
         if(!_loc3_)
         {
            this.items.push(param1);
         }
      }
   }
}

