package com.dchoc.dollars.utils.astar
{
   public interface ISearchable
   {
      
      function getNode(param1:int, param2:int) : INode;
      
      function getCols() : int;
      
      function getNodeTransitionCost(param1:INode, param2:INode) : Number;
      
      function getRows() : int;
   }
}

