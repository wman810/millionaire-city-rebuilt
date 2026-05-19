package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.traffic.TrafficAgentManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilter;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.GlowFilter;
   
   public class ToolSelect extends Tool
   {
      
      private var mTransformSelectedFilters:Array;
      
      private var mCarCount:int = 0;
      
      private var mCurrentArea:int = -1;
      
      private var mItemSelected:ItemObject;
      
      private var mOriginalFilters:Array;
      
      public function ToolSelect(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         this.load();
      }
      
      override public function enable(param1:Boolean = false) : void
      {
         var _loc2_:Profile = null;
         super.enable(param1);
         if(Tutorial.smTutorialEnd && mRole.checksExpansionIsMine())
         {
            _loc2_ = DollarsGame.getProfileUniverse();
            if(!_loc2_.isExpansionAreaMine(this.mCurrentArea))
            {
               mMap.activeExpansion(this.mCurrentArea);
               Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_BUY_AREA);
            }
         }
      }
      
      private function getBitmapFilter(param1:Number) : BitmapFilter
      {
         var _loc2_:Number = 0.5;
         var _loc3_:Number = 32;
         var _loc4_:Number = 32;
         var _loc5_:Number = 2;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Number = BitmapFilterQuality.HIGH;
         return new GlowFilter(param1,_loc2_,_loc3_,_loc4_,_loc5_,_loc8_,_loc6_,_loc7_);
      }
      
      override public function load() : void
      {
         this.mTransformSelectedFilters = new Array();
         var _loc1_:BitmapFilter = this.getBitmapFilter(255);
         this.mTransformSelectedFilters.push(_loc1_);
      }
      
      override public function start(param1:Boolean = false, param2:String = null) : void
      {
         super.start(param1);
         this.mItemSelected = null;
      }
      
      override public function end() : void
      {
         super.end();
         this.unattachItem(null);
         if(mRole.checksExpansionIsMine())
         {
            mMap.desactiveExpansion(this.mCurrentArea);
            this.mCurrentArea = -1;
         }
      }
      
      override public function reportMouseUp(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(Config.DEBUG_MODE)
         {
            _loc3_ = mMap.getScreenToTileIndex(mMap.mouseX,mMap.mouseY);
         }
         var _loc2_:ItemObject = mMap.getItemFromScreen(mMap.mouseX,mMap.mouseY);
         if(_loc2_ != null)
         {
            _loc2_.doClick();
         }
         else if(mRole.isMouseTerrainAllowed())
         {
            _loc4_ = mMap.getScreenToTileIndex(mMap.mouseX,mMap.mouseY);
            if(Config.CHEAT_TRAFFIC_AGENT)
            {
               TrafficAgentManager.getInstance().reportMouseClick(mMap.mouseX,mMap.mouseY,_loc4_);
            }
            else
            {
               mMap.clickOnTerrain(_loc4_);
            }
         }
      }
      
      override protected function doReportMouseOverTerrain(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Profile = null;
         var _loc2_:int = mMap.getScreenToTileIndex(mMap.mouseX,mMap.mouseY);
         if(DollarsGame != null && mRole.checksExpansionIsMine() && mMap.isValidTileIndex(_loc2_))
         {
            _loc3_ = mMap.getAreaIndexFromTileIndex(_loc2_);
            _loc4_ = DollarsGame.getProfileUniverse();
            if(this.mCurrentArea != _loc3_)
            {
               if(_loc4_.isExpansionAreaMine(this.mCurrentArea) && !_loc4_.isExpansionAreaMine(_loc3_))
               {
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_BUY_AREA);
               }
               else if(!_loc4_.isExpansionAreaMine(this.mCurrentArea) && _loc4_.isExpansionAreaMine(_loc3_))
               {
                  Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
               }
               if(!_loc4_.isExpansionAreaMine(this.mCurrentArea))
               {
                  mMap.desactiveExpansion(this.mCurrentArea);
               }
               this.mCurrentArea = _loc3_;
               if(!_loc4_.isExpansionAreaMine(this.mCurrentArea))
               {
                  mMap.activeExpansion(this.mCurrentArea);
               }
            }
            if(_loc4_.isExpansionAreaMine(this.mCurrentArea))
            {
               mMap.setTerrainCursor(param1);
            }
         }
      }
      
      override public function disable(param1:Boolean = false) : void
      {
         var _loc2_:Profile = null;
         var _loc3_:Cursor = null;
         if(mRole.checksExpansionIsMine())
         {
            _loc2_ = DollarsGame.getProfileUniverse();
            if(!_loc2_.isExpansionAreaMine(this.mCurrentArea))
            {
               mMap.desactiveExpansion(this.mCurrentArea);
               _loc3_ = Dollars.getCurrentCursor();
               if(_loc3_ != null)
               {
                  _loc3_.changeCursor(Cursor.CURSOR_SELECT);
               }
            }
         }
         super.disable(param1);
      }
      
      override public function unattachItem(param1:ItemObject) : void
      {
         if(param1 == null || param1 == this.mItemSelected)
         {
            this.selectItem(null);
         }
      }
      
      override public function canBuildTerrain() : Boolean
      {
         return true;
      }
      
      override public function destroy() : void
      {
         this.end();
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_SELECT;
      }
      
      private function selectItem(param1:ItemObject) : void
      {
         if(param1 != this.mItemSelected)
         {
            if(this.mItemSelected != null)
            {
               this.mItemSelected.displayObjectL0.filters = this.mOriginalFilters;
               this.mItemSelected.undoSelection();
            }
            if(param1 != null && !param1.isSelectable())
            {
               param1 = null;
            }
            if(param1 != null)
            {
               this.mOriginalFilters = param1.displayObjectL0.filters;
               param1.displayObjectL0.filters = this.mTransformSelectedFilters;
               param1.doSelection();
            }
            this.mItemSelected = param1;
         }
      }
   }
}

