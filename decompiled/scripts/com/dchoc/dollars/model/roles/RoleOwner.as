package com.dchoc.dollars.model.roles
{
   import com.dchoc.dollars.map.tools.Tool;
   import com.dchoc.dollars.map.tools.ToolBuild;
   import com.dchoc.dollars.map.tools.ToolContractSignator;
   import com.dchoc.dollars.map.tools.ToolDecorator;
   import com.dchoc.dollars.map.tools.ToolDecoratorScroll;
   import com.dchoc.dollars.map.tools.ToolDestroy;
   import com.dchoc.dollars.map.tools.ToolMoneyCollector;
   import com.dchoc.dollars.map.tools.ToolMove;
   import com.dchoc.dollars.map.tools.ToolRentAccelerator;
   import com.dchoc.dollars.map.tools.ToolRoad;
   import com.dchoc.dollars.map.tools.ToolSelect;
   import com.dchoc.dollars.map.tools.ToolTerrain;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.states.StateOnBuilt;
   import com.dchoc.dollars.world.items.states.StateOnConstructionOwner;
   import com.dchoc.dollars.world.items.states.StateOnDemolition;
   import com.dchoc.dollars.world.items.states.StateOnHeadQuarter;
   import com.dchoc.dollars.world.items.states.StateOnHireCrewOwner;
   import com.dchoc.dollars.world.items.states.StateOnIA;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   import com.dchoc.dollars.world.items.states.StateOnSelling;
   
   public class RoleOwner extends Role
   {
      
      public function RoleOwner()
      {
         super();
      }
      
      override public function checksExpansionIsMine() : Boolean
      {
         return true;
      }
      
      override protected function setStatesClasses() : void
      {
         STATES_ITEM_OBJECT_CLASS = [StateOnConstructionOwner,StateOnRent,StateOnSelling,StateOnIA,StateOnHeadQuarter,StateOnBuilt,StateOnDemolition,StateOnHireCrewOwner];
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
         var _loc5_:ToolTerrain = new ToolTerrain(this);
         _loc4_++;
         _loc5_.setId(_loc4_);
         var _loc6_:ToolDecorator = new ToolDecoratorScroll(this);
         _loc6_.setTool(_loc5_);
         _loc1_.push(_loc6_);
         var _loc7_:ToolBuild = new ToolBuild(this,_loc2_);
         _loc4_++;
         _loc7_.setId(_loc4_);
         _loc7_.setWhose(Company.WHOSE_MINE);
         _loc6_ = new ToolDecoratorScroll(this);
         _loc6_.setTool(_loc7_);
         _loc1_.push(_loc6_);
         _loc6_ = new ToolDecoratorScroll(this);
         var _loc8_:ToolDestroy = new ToolDestroy(this);
         _loc4_++;
         _loc8_.setId(_loc4_);
         _loc8_.setWhose(Company.WHOSE_MINE);
         _loc6_.setTool(_loc8_);
         _loc1_.push(_loc6_);
         _loc6_ = new ToolDecoratorScroll(this);
         var _loc9_:ToolMove = new ToolMove(this);
         _loc4_++;
         _loc9_.setId(_loc4_);
         _loc9_.setWhose(Company.WHOSE_MINE);
         _loc6_.setTool(_loc9_);
         _loc1_.push(_loc6_);
         _loc6_ = new ToolDecoratorScroll(this);
         var _loc10_:ToolMoneyCollector = new ToolMoneyCollector(this);
         _loc4_++;
         _loc10_.setId(_loc4_);
         _loc10_.setWhose(Company.WHOSE_MINE);
         _loc6_.setTool(_loc10_);
         _loc1_.push(_loc6_);
         _loc6_ = new ToolDecoratorScroll(this);
         var _loc11_:ToolContractSignator = new ToolContractSignator(this);
         _loc4_++;
         _loc11_.setId(_loc4_);
         _loc11_.setWhose(Company.WHOSE_MINE);
         _loc6_.setTool(_loc11_);
         _loc1_.push(_loc6_);
         _loc6_ = new ToolDecoratorScroll(this);
         var _loc12_:ToolRoad = new ToolRoad(this);
         _loc4_++;
         _loc12_.setId(_loc4_);
         _loc6_.setTool(_loc12_);
         _loc1_.push(_loc6_);
         _loc6_ = new ToolDecoratorScroll(this);
         var _loc13_:ToolRentAccelerator = new ToolRentAccelerator(this);
         _loc4_++;
         _loc13_.setId(_loc4_);
         _loc6_.setTool(_loc13_);
         _loc1_.push(_loc6_);
         return _loc1_;
      }
      
      override public function needsToCheckHQConnection() : Boolean
      {
         return true;
      }
      
      override public function needsToUpdateProfile() : Boolean
      {
         return true;
      }
      
      override public function needsToShowMissionArrow() : Boolean
      {
         return true;
      }
      
      override public function isProgressEnabled() : Boolean
      {
         return true;
      }
      
      override public function isAgeAllowed() : Boolean
      {
         return true;
      }
      
      override public function needsToCheckPollEvent(param1:String) : Boolean
      {
         return true;
      }
   }
}

