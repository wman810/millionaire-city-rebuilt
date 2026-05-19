package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   
   public class ToolRoad extends ToolSetTile
   {
      
      public function ToolRoad(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         load();
      }
      
      override protected function setTile(param1:int) : void
      {
         mMap.roadTileBuild(param1);
      }
      
      override protected function cursorIsVisible(param1:int) : Boolean
      {
         var _loc2_:TileData = mMap.tilesData[param1] as TileData;
         return !mMap.isTileInAreaMine(param1) || _loc2_.baseItem != null && !_loc2_.isHigh();
      }
      
      override protected function isSetTileAllowed(param1:int) : Boolean
      {
         var _loc2_:TileData = mMap.tilesData[param1] as TileData;
         return _loc2_.isRoadable() && mMap.isTileInAreaMine(param1) && !_loc2_.isSolid;
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_ROAD;
      }
      
      override protected function getParticleAfterSettingTile() : MovieClip
      {
         return new AssetManager.TerrainParticle();
      }
   }
}

