package com.dchoc.dollars.model.roles
{
   import com.dchoc.dollars.GUI.hud.Hud;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.tools.Tool;
   import com.dchoc.dollars.map.tools.ToolBuild;
   import com.dchoc.dollars.map.tools.ToolContractSignator;
   import com.dchoc.dollars.map.tools.ToolDecorator;
   import com.dchoc.dollars.map.tools.ToolDecoratorScroll;
   import com.dchoc.dollars.map.tools.ToolDestroy;
   import com.dchoc.dollars.map.tools.ToolMoneyCollector;
   import com.dchoc.dollars.map.tools.ToolMove;
   import com.dchoc.dollars.map.tools.ToolRoad;
   import com.dchoc.dollars.map.tools.ToolSelect;
   import com.dchoc.dollars.map.tools.ToolSetLogicTile;
   import com.dchoc.dollars.map.tools.ToolTerrain;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateOnBuilt;
   import com.dchoc.dollars.world.items.states.StateOnConstruction;
   import com.dchoc.dollars.world.items.states.StateOnDemolition;
   import com.dchoc.dollars.world.items.states.StateOnHeadQuarter;
   import com.dchoc.dollars.world.items.states.StateOnIA;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   import com.dchoc.dollars.world.items.states.StateOnSelling;
   
   public class RoleEditor extends Role
   {
      
      public function RoleEditor()
      {
         super();
      }
      
      override public function needsToBeUpdated() : Boolean
      {
         return false;
      }
      
      override public function requiresTerrainMine() : Boolean
      {
         return false;
      }
      
      override protected function setStatesClasses() : void
      {
         STATES_ITEM_OBJECT_CLASS = [StateOnConstruction,StateOnRent,StateOnSelling,StateOnIA,StateOnHeadQuarter,StateOnBuilt,StateOnDemolition,StateOnRent];
      }
      
      override protected function hudCreate() : void
      {
         mHud = new Hud();
      }
      
      override public function usesMaxExp() : Boolean
      {
         return true;
      }
      
      override protected function doGetInitialItemState(param1:ItemDefinition) : int
      {
         var _loc2_:int = super.doGetInitialItemState(param1);
         if(_loc2_ == StateOnConstruction.ID)
         {
            _loc2_ = StateOnIA.ID;
         }
         return _loc2_;
      }
      
      override public function demolitionConfirmationRequired() : Boolean
      {
         return false;
      }
      
      override public function buildItem(param1:ItemObject) : void
      {
         super.buildItem(param1);
      }
      
      override public function isLogicTilesEditionAllowed() : Boolean
      {
         return true;
      }
      
      override public function getTools() : Array
      {
         var _loc1_:Array = new Array();
         var _loc2_:ToolDecorator = new ToolDecoratorScroll(this);
         var _loc3_:Tool = new ToolSelect(this);
         var _loc4_:int = 0;
         _loc3_.setId(_loc4_);
         _loc2_.setTool(_loc3_);
         _loc1_.push(_loc2_);
         var _loc5_:ToolTerrain = new ToolTerrain(this,_loc2_);
         _loc4_++;
         _loc5_.setId(_loc4_);
         _loc2_ = new ToolDecoratorScroll(this);
         _loc2_.setTool(_loc5_);
         _loc1_.push(_loc2_);
         var _loc6_:ToolBuild = new ToolBuild(this);
         _loc4_++;
         _loc6_.setId(_loc4_);
         _loc6_.setWhose(Company.WHOSE_RIVAL);
         _loc2_ = new ToolDecoratorScroll(this);
         _loc2_.setTool(_loc6_);
         _loc1_.push(_loc2_);
         _loc2_ = new ToolDecoratorScroll(this);
         var _loc7_:ToolDestroy = new ToolDestroy(this);
         _loc4_++;
         _loc7_.setId(_loc4_);
         _loc2_.setTool(_loc7_);
         _loc1_.push(_loc2_);
         _loc2_ = new ToolDecoratorScroll(this);
         var _loc8_:ToolMove = new ToolMove(this);
         _loc4_++;
         _loc8_.setId(_loc4_);
         _loc2_.setTool(_loc8_);
         _loc1_.push(_loc2_);
         _loc2_ = new ToolDecoratorScroll(this);
         var _loc9_:ToolMoneyCollector = new ToolMoneyCollector(this);
         _loc4_++;
         _loc9_.setId(_loc4_);
         _loc2_.setTool(_loc9_);
         _loc1_.push(_loc2_);
         _loc2_ = new ToolDecoratorScroll(this);
         var _loc10_:ToolContractSignator = new ToolContractSignator(this);
         _loc4_++;
         _loc10_.setId(_loc4_);
         _loc2_.setTool(_loc10_);
         _loc1_.push(_loc2_);
         _loc2_ = new ToolDecoratorScroll(this);
         var _loc11_:ToolRoad = new ToolRoad(this);
         _loc4_++;
         _loc11_.setId(_loc4_);
         _loc2_.setTool(_loc11_);
         _loc1_.push(_loc2_);
         _loc2_ = new ToolDecoratorScroll(this);
         var _loc12_:ToolSetLogicTile = new ToolSetLogicTile(this,Map.LOGIC_TILE_SOLID);
         _loc4_++;
         _loc12_.setId(_loc4_);
         _loc2_.setTool(_loc12_);
         _loc1_.push(_loc2_);
         return _loc1_;
      }
      
      override public function getCompanyWhoseBuilding(param1:int) : int
      {
         var _loc2_:int = int(Company.WHOSE_RIVAL);
         if(param1 == ItemDefinition.TYPE_DECORATIONS_ID)
         {
            _loc2_ = int(Company.WHOSE_MINE);
         }
         return _loc2_;
      }
   }
}

