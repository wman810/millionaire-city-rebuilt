package com.dchoc.dollars.model.roles
{
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.map.tools.Tool;
   import com.dchoc.dollars.map.tools.ToolDecorator;
   import com.dchoc.dollars.map.tools.ToolDecoratorScroll;
   import com.dchoc.dollars.map.tools.ToolSelect;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.world.items.states.StateItemObject;
   import com.dchoc.dollars.world.items.states.StateOnBuiltVisitor;
   import com.dchoc.dollars.world.items.states.StateOnConstructionVisitor;
   import com.dchoc.dollars.world.items.states.StateOnHeadQuarter;
   import com.dchoc.dollars.world.items.states.StateOnHireCrewVisitor;
   import com.dchoc.dollars.world.items.states.StateOnRentVisitor;
   import com.dchoc.dollars.world.items.states.StateOnSelling;
   
   public class RoleVisitor extends Role
   {
      
      public function RoleVisitor()
      {
         super();
      }
      
      override protected function setStatesClasses() : void
      {
         STATES_ITEM_OBJECT_CLASS = [StateOnConstructionVisitor,StateOnRentVisitor,StateOnSelling,StateOnRentVisitor,StateOnHeadQuarter,StateOnBuiltVisitor,null,StateOnHireCrewVisitor];
      }
      
      override public function isItemStateAllowed(param1:int) : Boolean
      {
         return param1 != StateItemObject.STATE_ON_DEMOLITION_ID;
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
         return _loc1_;
      }
      
      override public function needsToUpdateProfile() : Boolean
      {
         return true;
      }
      
      override public function start() : void
      {
         super.start();
         mToolsBar.disableButtons();
         mToolsBar.enableButton(ToolsBar.SELECT_BUTTON);
      }
      
      override public function needsToCheckPollEvent(param1:String) : Boolean
      {
         return param1 == MissionsEventIDs.MISSION_EVENT_UPGRADE;
      }
      
      override public function isMouseTerrainAllowed() : Boolean
      {
         return false;
      }
   }
}

