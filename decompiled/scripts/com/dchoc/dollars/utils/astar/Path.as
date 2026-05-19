package com.dchoc.dollars.utils.astar
{
   public class Path
   {
      
      private var cost:Number;
      
      private var nodes:Array;
      
      private var lastNode:INode;
      
      public function Path()
      {
         super();
         this.cost = 0;
         this.nodes = new Array();
      }
      
      public function containsNode(param1:INode) : Boolean
      {
         return this.nodes.indexOf(param1) > -1;
      }
      
      public function getCost() : Number
      {
         return this.cost;
      }
      
      public function addNode(param1:INode) : void
      {
         this.nodes.push(param1);
         this.lastNode = param1;
      }
      
      public function toString() : String
      {
         var _loc2_:INode = null;
         var _loc1_:String = "";
         for each(_loc2_ in this.nodes)
         {
            _loc1_ += _loc2_.getNodeId() + "(" + _loc2_.getCol() + "," + _loc2_.getRow() + "), ";
         }
         return _loc1_;
      }
      
      public function getLastNode() : INode
      {
         return this.lastNode;
      }
      
      public function setNodes(param1:Array) : void
      {
         this.nodes = param1;
      }
      
      public function getF() : Number
      {
         return this.getCost() + this.lastNode.getHeuristic();
      }
      
      public function getNodes() : Array
      {
         return this.nodes;
      }
      
      public function incrementCost(param1:Number) : void
      {
         this.cost = this.getCost() + param1;
      }
      
      public function clone() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.incrementCost(this.cost);
         _loc1_.setNodes(this.nodes.slice(0));
         return _loc1_;
      }
   }
}

