package com.dchoc.dollars.utils.astar
{
   public interface INode
   {
      
      function canBeStepped() : Boolean;
      
      function getNeighbors() : Array;
      
      function getNodeId() : int;
      
      function getRow() : int;
      
      function setHeuristic(param1:Number) : void;
      
      function getNodeType() : String;
      
      function getCol() : int;
      
      function getHeuristic() : Number;
      
      function setNeighbors(param1:Array) : void;
   }
}

