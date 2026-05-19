package com.dchoc.dollars.map.logicTiles
{
   import com.dchoc.dollars.map.TileData;
   
   public class LogicTileSolid extends LogicTile
   {
      
      public function LogicTileSolid(param1:int, param2:TileData)
      {
         super(param1,param2);
      }
      
      override public function unbuild() : void
      {
         mTileData.isSolid = false;
      }
      
      override public function build() : void
      {
         mTileData.isSolid = true;
      }
   }
}

