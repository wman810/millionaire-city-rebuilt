package com.dchoc.dollars.world.items.states
{
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.model.upgrades.UpgradesManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.dchoc.framework.states.StateMachine;
   
   public class StateOnRentVisitor extends StateOnRent
   {
      
      private static const VISITOR_UPGRADES_SWFS:Array = [Config.getRoot() + ModelConfig.VISITOR_UPGRADES_SWF,Config.getRoot() + ModelConfig.VISITOR_SUPER_UPGRADES_SWF];
      
      public function StateOnRentVisitor(param1:StateMachine)
      {
         super(param1);
      }
      
      override protected function doDoLogicUpdate(param1:int) : void
      {
      }
      
      override protected function doDoClick() : void
      {
         var _loc2_:Object = null;
         var _loc1_:UpgradesManager = UpgradesManager.getInstance();
         if(_loc1_.isAnyUpgradeAllowed())
         {
            upgradeApply();
            mItemObject.registerEvent(MissionsEventIDs.MISSION_EVENT_UPGRADE);
            giveDCCoins(_loc1_.getDCCoinsPerUpgrade());
            giveExp(_loc1_.getExpPerUpgrade());
            _loc1_.upgradeItem(mItemObject);
            _loc2_ = new Object();
            _loc2_.ownerId = DollarsGame.getProfileUniverse().owner;
            _loc2_.visitorId = DollarsGame.getProfile().owner;
            _loc2_.sid = mItemObject.sid;
            _loc2_.type = _loc1_.getType();
            UserDataFacade.getInstance().requestTask(UserDataFacade.TAG_UPGRADES_ADD_ITEM,_loc2_);
            mItemObject.undoMouseOver(true);
         }
      }
      
      override protected function doIsMouseOverEnabled() : Boolean
      {
         return UpgradesManager.getInstance().isAnyUpgradeAllowed() && mMode == MODE_RENTING && !upgradeGetEnabled() && mItemObject.itemDefinition.isUpgradeAllowed();
      }
      
      override public function isInfoBoxAllowed() : Boolean
      {
         return false;
      }
      
      override protected function doDoDoMouseOver(param1:Boolean = false) : void
      {
         var _loc2_:Role = mItemObject.company.world.role;
         if(_loc2_ != null && mItemObject.company.world.role.toolsBar.currentToolIndex == ToolsBar.SELECT_BUTTON)
         {
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HELP_UPGRADE_ITEM + UpgradesManager.getInstance().getType());
         }
      }
      
      override protected function doUndoMouseOver() : void
      {
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_SELECT);
      }
      
      override protected function upgradeDoSetDOs() : void
      {
         mUpgradeDOs[UPGRADE_DO_APPLY] = new (DCResourceManager.getInstance().getSWFClass(VISITOR_UPGRADES_SWFS[UpgradesManager.getInstance().getType()],"Event_upgrade"))();
      }
      
      override protected function doEnter(param1:Boolean = true) : void
      {
         mMode = MODE_RENTING;
         setMode(mMode,false);
      }
   }
}

