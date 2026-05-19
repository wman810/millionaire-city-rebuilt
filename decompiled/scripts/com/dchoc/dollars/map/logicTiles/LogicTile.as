package com.dchoc.dollars.map.logicTiles
{
   import com.dchoc.dollars.map.TileData;
   
   public class LogicTile
   {
      
      protected var mTileData:TileData;
      
      protected var mType:int;
      
      public function LogicTile(param1:int, param2:TileData)
      {
         super();
         this.mType = param1;
         this.mTileData = param2;
      }
      
      public function getType() : int
      {
         return this.mType;
      }
      
      public function unbuild() : void
      {
      }
      
      public function build() : void
      {
      }
   }
}

