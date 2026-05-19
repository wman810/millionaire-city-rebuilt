package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.map.logicTiles.LogicTile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.MouseEvent;
   
   public class ToolDestroy extends Tool
   {
      
      private var mItemToDestroy:ItemObject;
      
      public function ToolDestroy(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         load();
      }
      
      override protected function doReportMouseUp(param1:MouseEvent, param2:ItemObject) : void
      {
         var _loc3_:int = 0;
         var _loc4_:TileData = null;
         this.mItemToDestroy = param2;
         if(this.mItemToDestroy == null)
         {
            _loc3_ = mMap.getScreenToTileIndex(mMap.mouseX,mMap.mouseY);
            if(mMap.isTileInAreaMine(_loc3_))
            {
               _loc4_ = mMap.getTileDataFromIndex(_loc3_);
               if(_loc4_ != null)
               {
                  if(_loc4_.isRoad)
                  {
                     mMap.roadTileDestroy(_loc3_);
                  }
                  else if(_loc4_.isMyTerrain)
                  {
                     mMap.destroyTile(_loc3_);
                  }
                  else if(DollarsGame.getCurrentRole().isLogicTilesEditionAllowed())
                  {
                     mMap.logicTileDestroy(_loc3_);
                  }
               }
            }
         }
         else if((mWhose == WHOSE_ANY || this.mItemToDestroy.company.whose == mWhose) && this.mItemToDestroy.isDestroyable())
         {
            this.mItemToDestroy.demolish(Cursor.CURSOR_DEMOLITION);
            super.reportMouseOver(null);
         }
      }
      
      override public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         if(param1.company.whose == mWhose)
         {
            return Boolean(super.isMouseOverEnabled(param1)) && param1.isDestroyable();
         }
         return false;
      }
      
      override protected function cursorIsApplicable() : Boolean
      {
         var _loc4_:LogicTile = null;
         var _loc1_:Boolean = false;
         var _loc2_:int = mMap.getScreenToTileIndex(mMap.mouseX,mMap.mouseY);
         var _loc3_:TileData = mMap.getTileDataFromIndex(_loc2_);
         if(_loc3_ != null)
         {
            _loc1_ = mMap.isTileInAreaMine(_loc2_) && (_loc3_.isRoad || _loc3_.isMyTerrain) && _loc3_.baseItem == null;
            if(!_loc1_ && DollarsGame.getCurrentRole().isLogicTilesEditionAllowed())
            {
               _loc4_ = _loc3_.getLogicTile();
               _loc1_ = _loc4_ != null;
            }
         }
         return _loc1_;
      }
      
      override protected function cursorIsEnabled() : Boolean
      {
         return true;
      }
      
      override public function itemMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return this.isMouseOverEnabled(param1);
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_DEMOLITION;
      }
   }
}

