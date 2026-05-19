package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.map.logicTiles.LogicTile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   
   public class ToolSetLogicTile extends ToolSetTile
   {
      
      private var mType:int;
      
      public function ToolSetLogicTile(param1:Role, param2:int, param3:Tool = null)
      {
         super(param1,param3);
         this.mType = param2;
         load();
      }
      
      override protected function setTile(param1:int) : void
      {
         var _loc2_:TileData = mMap.tilesData[param1] as TileData;
         var _loc3_:LogicTile = _loc2_.getLogicTile();
         if(_loc3_ != null)
         {
            _loc3_.unbuild();
         }
         mMap.logicTileBuild(param1,this.mType);
      }
      
      override protected function isSetTileAllowed(param1:int) : Boolean
      {
         var _loc2_:TileData = mMap.tilesData[param1] as TileData;
         return !_loc2_.isRoad && !_loc2_.isMyTerrain && _loc2_.baseItem == null && _loc2_.getLogicTile() == null;
      }
      
      override protected function cursorIsVisible(param1:int) : Boolean
      {
         var _loc2_:TileData = mMap.tilesData[param1] as TileData;
         return _loc2_.baseItem != null;
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_HQ_01;
      }
   }
}

