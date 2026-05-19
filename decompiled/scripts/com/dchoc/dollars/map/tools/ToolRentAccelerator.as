package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.freeGift.FreeGiftDefinition;
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.storage.StorageManager;
   import com.dchoc.dollars.storage.StoredItem;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.MouseEvent;
   
   public class ToolRentAccelerator extends Tool
   {
      
      private var mPercentage:int;
      
      private var mAcceleratorSku:String;
      
      public function ToolRentAccelerator(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         load();
      }
      
      override protected function cursorIsEnabled() : Boolean
      {
         return true;
      }
      
      override public function start(param1:Boolean = false, param2:String = null) : void
      {
         var _loc3_:FreeGiftDefinition = FreeGiftDefinitionManager.getInstance().getDefinition(param2) as FreeGiftDefinition;
         this.mAcceleratorSku = param2;
         this.mPercentage = int(_loc3_.value);
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_RENT_ACC);
         Dollars.getCurrentCursor().setLabel(this.mPercentage + "%");
         super.start(param1);
      }
      
      override protected function doReportMouseUp(param1:MouseEvent, param2:ItemObject) : void
      {
         var _loc3_:Definition = null;
         if(param2 != null && param2.canBeAccelerated())
         {
            param2.accelerateIncomeTime(this.mPercentage);
            this.reportMouseMove(param1);
            StorageManager.getInstance().removeItem(this.mAcceleratorSku);
            _loc3_ = FreeGiftDefinitionManager.getInstance().getDefinition(this.mAcceleratorSku);
            UserDataFacade.getInstance().updateMoney(StoredItem.ACTION_RENT_ACCELERATOR,{
               "sku":_loc3_.sku,
               "itemSid":param2.sid
            });
            if(StorageManager.getInstance().getItem(this.mAcceleratorSku) == null)
            {
               DollarsGame.getCurrentRole().toolsBar.setToolToSelect();
            }
         }
      }
      
      override public function reportMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:int = mMap.getScreenToTileIndex(mMap.mouseX,mMap.mouseY);
         var _loc3_:TileData = mMap.getTileDataFromIndex(_loc2_);
         if(_loc3_.baseItem != null && !_loc3_.baseItem.canBeAccelerated())
         {
            if(Dollars.getCurrentCursor().currentCursorID != Cursor.CURSOR_RENT_ACC_NO_ACTION)
            {
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_RENT_ACC_NO_ACTION);
            }
         }
         else if(Dollars.getCurrentCursor().currentCursorID != Cursor.CURSOR_RENT_ACC)
         {
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_RENT_ACC);
            Dollars.getCurrentCursor().setLabel(this.mPercentage + "%");
         }
         super.reportMouseMove(param1);
      }
      
      override public function reportMouseUp(param1:MouseEvent) : void
      {
         var _loc2_:ItemObject = mMap.getItemFromScreen(mMap.mouseX,mMap.mouseY);
         this.doReportMouseUp(param1,_loc2_);
      }
      
      override public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         if(param1.company.whose == mWhose)
         {
            return Boolean(super.isMouseOverEnabled(param1)) && param1.canBeAccelerated();
         }
         return false;
      }
      
      private function canBeAccelerated(param1:ItemObject) : Boolean
      {
         return param1.getItemType() == ItemDefinition.TYPE_HOUSES_ID && !param1.isHeadQuarters() && param1.getContractSku() != null;
      }
      
      override public function itemMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return this.isMouseOverEnabled(param1);
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_RENT_ACC;
      }
   }
}

