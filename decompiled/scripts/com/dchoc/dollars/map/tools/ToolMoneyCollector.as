package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.GUI.MultifunctionBar;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.world.items.ItemObject;
   
   public class ToolMoneyCollector extends Tool
   {
      
      public function ToolMoneyCollector(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         load();
      }
      
      override protected function areaDoClick(param1:ItemObject) : Boolean
      {
         param1.doClick(true);
         return true;
      }
      
      override protected function areaGetServiceSku() : String
      {
         return Profile.SERVICES_MONEY_COLLECTOR_SKU;
      }
      
      override protected function areaGetServiceContractsPopup() : Popup
      {
         return DollarsGame.smInstance.mPopupRentCollector;
      }
      
      override public function areaIsEnabled() : Boolean
      {
         return true;
      }
      
      override protected function getToolButtonId() : int
      {
         return MultifunctionBar.BUTTON_COLLECT;
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_MONEY_COLLECTOR;
      }
      
      override protected function areaIsItemAffected(param1:ItemObject) : Boolean
      {
         var _loc2_:Boolean = super.areaIsItemAffected(param1);
         if(_loc2_)
         {
            _loc2_ = param1.isIncomeReady();
         }
         return _loc2_;
      }
   }
}

