package com.dchoc.dollars.model.roles
{
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.hud.Hud;
   import com.dchoc.dollars.GUI.hud.HudOwner;
   import com.dchoc.dollars.crewMechanics.CrewMechanicsManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.*;
   
   public class Role
   {
      
      protected var mToolsBar:ToolsBar;
      
      protected var STATES_ITEM_OBJECT_CLASS:Array;
      
      protected var mHud:Hud;
      
      protected var mCursor:Cursor;
      
      public function Role()
      {
         super();
         this.load();
      }
      
      protected function setStatesClasses() : void
      {
         this.STATES_ITEM_OBJECT_CLASS = [StateOnConstructionOwner,StateOnRent,StateOnSelling,StateOnIA,StateOnHeadQuarter,StateOnBuilt,StateOnDemolition,StateOnHireCrew];
      }
      
      public function needsToCheckPollEvent(param1:String) : Boolean
      {
         return false;
      }
      
      public function needsToUpdateProfile() : Boolean
      {
         return false;
      }
      
      public function isAgeAllowed() : Boolean
      {
         return false;
      }
      
      protected function doGetInitialItemState(param1:ItemDefinition) : int
      {
         var _loc2_:int = param1 == null ? int(ItemDefinition.TYPE_HOUSES_ID) : int(param1.type);
         var _loc3_:int = CrewMechanicsManager.getInstance().getCrewCount(param1.constructionCrewSku);
         if(_loc3_ > 0)
         {
            return StateOnHireCrew.ID;
         }
         if(_loc2_ == ItemDefinition.TYPE_DECORATIONS_ID)
         {
            return StateOnBuilt.ID;
         }
         if(param1.isHeadQuarters())
         {
            return StateOnHeadQuarter.ID;
         }
         return StateOnConstruction.ID;
      }
      
      public function demolitionConfirmationRequired() : Boolean
      {
         return true;
      }
      
      public function needsToShowMissionArrow() : Boolean
      {
         return false;
      }
      
      protected function hudCreate() : void
      {
         this.mHud = new HudOwner(DollarsGame.getProfile());
      }
      
      public function get cursor() : Cursor
      {
         return this.mCursor;
      }
      
      public function checksExpansionIsMine() : Boolean
      {
         return false;
      }
      
      public function isProgressEnabled() : Boolean
      {
         return false;
      }
      
      public function requiresTerrainMine() : Boolean
      {
         return true;
      }
      
      public function end() : void
      {
      }
      
      public function getCompanyWhoseBuilding(param1:int) : int
      {
         return Company.WHOSE_MINE;
      }
      
      public function needsToBeUpdated() : Boolean
      {
         return true;
      }
      
      public function buildItem(param1:ItemObject) : void
      {
         param1.stateId = this.doGetInitialItemState(param1.itemDefinition);
         param1.attachRole(this);
      }
      
      public function start() : void
      {
      }
      
      public function getTools() : Array
      {
         return null;
      }
      
      public function load() : void
      {
         this.mCursor = new Cursor();
         this.mCursor.changeCursor(Cursor.CURSOR_SELECT);
         this.mToolsBar = new ToolsBar(this);
         this.setStatesClasses();
         this.hudCreate();
      }
      
      public function usesMaxExp() : Boolean
      {
         return false;
      }
      
      public function unbuildItem(param1:ItemObject) : void
      {
         this.mToolsBar.unattachItem(param1);
         var _loc2_:StateItemObject = param1.getCurrentState();
         _loc2_.destroy();
      }
      
      public function isItemStateAllowed(param1:int) : Boolean
      {
         return true;
      }
      
      public function getStateItemObject(param1:ItemObject) : StateItemObject
      {
         var _loc2_:StateItemObject = null;
         if(this.STATES_ITEM_OBJECT_CLASS[param1.stateId] != null)
         {
            _loc2_ = new this.STATES_ITEM_OBJECT_CLASS[param1.stateId](param1);
         }
         return _loc2_;
      }
      
      public function isMouseTerrainAllowed() : Boolean
      {
         return true;
      }
      
      public function isMouseOverEnabled() : Boolean
      {
         return true;
      }
      
      public function get hud() : Hud
      {
         return this.mHud;
      }
      
      public function get toolsBar() : ToolsBar
      {
         return this.mToolsBar;
      }
      
      public function destroy() : void
      {
         this.end();
         this.mHud.destroy();
         this.mHud = null;
         this.mCursor.destroy();
         this.mCursor = null;
         this.mToolsBar.destroy();
         this.mToolsBar = null;
      }
      
      public function isLogicTilesEditionAllowed() : Boolean
      {
         return false;
      }
      
      public function needsToCheckHQConnection() : Boolean
      {
         return false;
      }
   }
}

