package com.dchoc.framework.world
{
   import flash.utils.ByteArray;
   
   public interface IWorldInterface
   {
      
      function addObject(param1:Class) : WorldElementObject;
      
      function selectToolTile(param1:Class) : void;
      
      function addListenerObjectDestroyed(param1:Function) : void;
      
      function selectToolDestroy() : void;
      
      function getLevelData() : ByteArray;
      
      function setLevelData(param1:ByteArray) : void;
      
      function selectToolLower() : void;
      
      function selectToolSelect() : void;
      
      function selectToolRaise() : void;
      
      function setLevelDataTiles(param1:ByteArray) : void;
      
      function addListenerObjectMoved(param1:Function) : void;
   }
}

