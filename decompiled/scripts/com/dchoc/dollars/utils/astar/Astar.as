package com.dchoc.dollars.utils.astar
{
   public class Astar
   {
      
      private var mGoalNode:INode;
      
      private var mAllowDiag:Boolean;
      
      private var mMaxSearchTime:Number;
      
      private var mGrid:ISearchable;
      
      private var mStartNode:INode;
      
      private var mClosed:Object;
      
      public function Astar(param1:ISearchable)
      {
         super();
         this.mGrid = param1;
         this.setAllowDiag(false);
         this.setMaxSearchTime(2000);
      }
      
      public function destroy() : void
      {
         this.mStartNode = null;
         this.mGoalNode = null;
         this.mClosed = null;
         this.mGrid = null;
      }
      
      public function search(param1:INode, param2:Array) : SearchResults
      {
         var _loc8_:Date = null;
         var _loc9_:Path = null;
         var _loc10_:INode = null;
         var _loc11_:Array = null;
         var _loc12_:int = 0;
         var _loc13_:INode = null;
         var _loc14_:Number = NaN;
         var _loc15_:Path = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         this.mStartNode = param1;
         this.mGoalNode = param2[0];
         var _loc3_:SearchResults = new SearchResults();
         this.mClosed = new Object();
         var _loc4_:PriorityQueue = new PriorityQueue();
         var _loc5_:Path = new Path();
         _loc5_.addNode(param1);
         _loc4_.enqueue(_loc5_);
         var _loc6_:Number = Math.sqrt(2);
         var _loc7_:Date = new Date();
         while(_loc4_.hasNextItem())
         {
            _loc8_ = new Date();
            if(_loc8_.valueOf() - _loc7_.valueOf() > this.mMaxSearchTime)
            {
               break;
            }
            _loc9_ = _loc4_.getNextItem();
            _loc10_ = _loc9_.getLastNode();
            if(!this.isInClosed(_loc10_))
            {
               if(param2.indexOf(_loc10_) > -1)
               {
                  _loc3_.setIsSuccess(true);
                  _loc3_.setPath(_loc9_);
                  break;
               }
               this.mClosed[_loc10_.getNodeId()] = true;
               _loc11_ = this.getNeighbors(_loc10_);
               _loc12_ = 0;
               while(_loc12_ < _loc11_.length)
               {
                  _loc13_ = INode(_loc11_[_loc12_]);
                  _loc14_ = Math.abs(_loc10_.getCol() - _loc13_.getCol()) + Math.abs(_loc10_.getRow() - _loc13_.getRow());
                  _loc13_.setHeuristic(_loc14_);
                  _loc15_ = _loc9_.clone();
                  _loc15_.addNode(_loc13_);
                  if(_loc13_.getCol() == _loc10_.getCol() || _loc13_.getRow() == _loc10_.getRow())
                  {
                     _loc16_ = 1;
                  }
                  else
                  {
                     _loc16_ = _loc6_;
                  }
                  _loc17_ = this.mGrid.getNodeTransitionCost(_loc10_,_loc13_);
                  _loc16_ *= _loc17_;
                  _loc15_.incrementCost(_loc16_);
                  _loc4_.enqueue(_loc15_);
                  _loc12_++;
               }
            }
         }
         return _loc3_;
      }
      
      public function setAllowDiag(param1:Boolean) : void
      {
         this.mAllowDiag = param1;
      }
      
      private function getNeighbors(param1:INode) : Array
      {
         var _loc7_:INode = null;
         var _loc2_:Array = param1.getNeighbors();
         var _loc3_:int = param1.getCol();
         var _loc4_:int = param1.getRow();
         var _loc5_:int = this.mGrid.getCols();
         var _loc6_:int = this.mGrid.getRows();
         if(_loc2_ == null)
         {
            _loc2_ = new Array();
            if(_loc3_ + 1 < _loc5_)
            {
               _loc7_ = this.mGrid.getNode(_loc3_ + 1,_loc4_);
               if(_loc7_.canBeStepped())
               {
                  _loc2_.push(_loc7_);
               }
            }
            if(_loc4_ + 1 < _loc6_)
            {
               _loc7_ = this.mGrid.getNode(_loc3_,_loc4_ + 1);
               if(_loc7_ != null && _loc7_.canBeStepped())
               {
                  _loc2_.push(_loc7_);
               }
            }
            if(_loc3_ - 1 >= 0)
            {
               _loc7_ = this.mGrid.getNode(_loc3_ - 1,_loc4_);
               if(_loc7_ != null && _loc7_.canBeStepped())
               {
                  _loc2_.push(_loc7_);
               }
            }
            if(_loc4_ - 1 >= 0)
            {
               _loc7_ = this.mGrid.getNode(_loc3_,_loc4_ - 1);
               if(_loc7_ != null && _loc7_.canBeStepped())
               {
                  _loc2_.push(_loc7_);
               }
            }
            if(this.mAllowDiag)
            {
               if(_loc3_ - 1 > 0 && _loc4_ + 1 < _loc6_)
               {
                  _loc7_ = this.mGrid.getNode(_loc3_ - 1,_loc4_ + 1);
                  if(_loc7_ != null && _loc7_.canBeStepped())
                  {
                     _loc2_.push(_loc7_);
                  }
               }
               if(_loc3_ + 1 < _loc5_ && _loc4_ + 1 < _loc6_)
               {
                  _loc7_ = this.mGrid.getNode(_loc3_ + 1,_loc4_ + 1);
                  if(_loc7_ != null && _loc7_.canBeStepped())
                  {
                     _loc2_.push(_loc7_);
                  }
               }
               if(_loc3_ - 1 > 0 && _loc4_ - 1 > 0)
               {
                  _loc7_ = this.mGrid.getNode(_loc3_ - 1,_loc4_ - 1);
                  if(_loc7_ != null && _loc7_.canBeStepped())
                  {
                     _loc2_.push(_loc7_);
                  }
               }
               if(_loc3_ + 1 < _loc5_ && _loc4_ - 1 > 0)
               {
                  _loc7_ = this.mGrid.getNode(_loc3_ + 1,_loc4_ - 1);
                  if(_loc7_ != null && _loc7_.canBeStepped())
                  {
                     _loc2_.push(_loc7_);
                  }
               }
            }
            param1.setNeighbors(_loc2_);
         }
         return _loc2_;
      }
      
      private function isInClosed(param1:INode) : Boolean
      {
         return this.mClosed[param1.getNodeId()] != null;
      }
      
      public function setMaxSearchTime(param1:Number) : void
      {
         this.mMaxSearchTime = param1;
      }
   }
}

