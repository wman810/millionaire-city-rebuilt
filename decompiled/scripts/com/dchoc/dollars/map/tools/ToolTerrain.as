package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.MouseEvent;
   
   public class ToolTerrain extends Tool
   {
      
      public function ToolTerrain(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
      }
      
      override protected function doReportMouseUp(param1:MouseEvent, param2:ItemObject) : void
      {
         mMap.buyTerrain(param1);
      }
      
      override public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return false;
      }
      
      override public function reportMouseOver(param1:MouseEvent, param2:Boolean = false) : void
      {
         super.reportMouseOver(param1,param2);
         if(getEnabled())
         {
            mMap.setTerrainCursor(param1);
         }
      }
      
      override public function disable(param1:Boolean = false) : void
      {
         mMap.terrainDisable();
         super.disable(param1);
      }
      
      override protected function doReportMouseOver(param1:MouseEvent, param2:ItemObject) : void
      {
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_TERRAIN;
      }
   }
}

