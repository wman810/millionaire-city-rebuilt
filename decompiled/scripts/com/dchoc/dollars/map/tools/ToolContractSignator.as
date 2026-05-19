package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.GUI.MultifunctionBar;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.containers.ContractItem;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.utils.particles.TextAnimation;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinition;
   import com.dchoc.dollars.world.contracts.ContractsTypeDefinitionManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class ToolContractSignator extends Tool
   {
      
      private var mContractDefinitions:Dictionary;
      
      private var mContractName:String;
      
      private var mPopupContractsOpen:Boolean;
      
      public function ToolContractSignator(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         this.load();
      }
      
      private function onPopupContractClose(param1:Event) : void
      {
         DollarsGame.smInstance.mPopupContractMultiple.removeEventListener(Popup.EVENT_CLOSE,this.onPopupContractClose);
         DollarsGame.smInstance.mPopupContractMultiple.removeEventListener(Popup.EVENT_ACCEPT,this.onPopupContractAccept);
         this.mContractName = null;
         this.mPopupContractsOpen = false;
         DollarsGame.getProfile().servicesSetLock(Profile.SERVICES_CONTRACT_SIGNATOR_SKU,false);
         Dollars.getCurrentCursor().changeCursor(this.getDefaultCursorID());
      }
      
      override protected function areaDoNoItemsOk() : void
      {
         ParticlesManager.addParticle(new TextAnimation(TextManager.getText(TextIDs.TID_NO_CASH_TITLE),Dollars.smStage.mouseX,Dollars.smStage.mouseY));
      }
      
      override protected function areaIsItemsAffectedEnabled() : Boolean
      {
         var _loc1_:Boolean = super.areaIsItemsAffectedEnabled();
         if(_loc1_)
         {
            _loc1_ = this.areaIsEnabled() && !this.mPopupContractsOpen;
         }
         return _loc1_;
      }
      
      override public function load() : void
      {
         super.load();
         this.mContractDefinitions = new Dictionary(true);
      }
      
      private function onPopupContractAccept(param1:Event) : void
      {
         var _loc2_:ContractItem = DollarsGame.smInstance.mPopupContractMultiple.getContractItemSelected();
         this.mContractName = _loc2_.mContractDef.getNameSku();
         this.areaApplyService(null);
      }
      
      override public function start(param1:Boolean = false, param2:String = null) : void
      {
         this.mContractName = null;
         this.mPopupContractsOpen = false;
         super.start(param1);
      }
      
      override public function serviceEnd() : void
      {
         if(this.mPopupContractsOpen)
         {
            DollarsGame.smInstance.mPopupContractMultiple.onClose(null);
         }
         super.serviceEnd();
      }
      
      override protected function areaGetServiceContractsPopup() : Popup
      {
         return DollarsGame.smInstance.mPopupContractSignator;
      }
      
      override protected function areaDoClick(param1:ItemObject) : Boolean
      {
         var _loc3_:ContractDefinition = null;
         var _loc2_:Boolean = false;
         if(param1 != null)
         {
            _loc3_ = this.cacheContractDefinitionGetByName(this.mContractName,param1.itemDefinition);
            if(_loc3_ != null && _loc3_.level <= DollarsGame.getProfile().level)
            {
               _loc2_ = param1.signContract(_loc3_);
            }
         }
         return _loc2_;
      }
      
      private function cacheContractDefinitionGetByName(param1:String, param2:ItemDefinition) : ContractDefinition
      {
         var _loc4_:ContractsTypeDefinition = null;
         var _loc5_:Array = null;
         var _loc6_:ContractDefinition = null;
         var _loc7_:int = 0;
         var _loc3_:ContractDefinition = null;
         if(param1 != null && param2 != null)
         {
            if(this.mContractDefinitions[param1] == null)
            {
               this.mContractDefinitions[param1] = new Dictionary(true);
            }
            if(this.mContractDefinitions[param1][param2.sku] == null)
            {
               _loc4_ = ContractsTypeDefinitionManager.getInstance().getDefinitionBySku(param2.getContractsTypeSku()) as ContractsTypeDefinition;
               if(_loc4_ != null)
               {
                  _loc5_ = _loc4_.getContracts();
                  if(_loc5_ != null)
                  {
                     _loc7_ = 0;
                     while(_loc7_ < _loc5_.length && this.mContractDefinitions[param1][param2.sku] == null)
                     {
                        _loc6_ = _loc5_[_loc7_] as ContractDefinition;
                        if(_loc6_.getNameSku() == param1)
                        {
                           this.mContractDefinitions[param1][param2.sku] = _loc6_;
                        }
                        _loc7_++;
                     }
                  }
               }
            }
            if(this.mContractDefinitions[param1][param2.sku] != null)
            {
               _loc3_ = this.mContractDefinitions[param1][param2.sku];
            }
         }
         return _loc3_;
      }
      
      override protected function areaGetServiceSku() : String
      {
         return Profile.SERVICES_CONTRACT_SIGNATOR_SKU;
      }
      
      override public function areaIsEnabled() : Boolean
      {
         return true;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.mContractDefinitions = null;
         this.mContractName = null;
      }
      
      override protected function areaApplyService(param1:MouseEvent) : void
      {
         if(this.mContractName == null && mAreaItemsAffected.length > 0)
         {
            this.mPopupContractsOpen = true;
            DollarsGame.getProfile().servicesSetLock(Profile.SERVICES_CONTRACT_SIGNATOR_SKU,true);
            DollarsGame.smInstance.mPopupContractMultiple.showPopupParam(mAreaItemsAffected);
            DollarsGame.smInstance.mPopupContractMultiple.addEventListener(Popup.EVENT_CLOSE,this.onPopupContractClose);
            DollarsGame.smInstance.mPopupContractMultiple.addEventListener(Popup.EVENT_ACCEPT,this.onPopupContractAccept);
         }
         else if(param1 == null)
         {
            super.areaApplyService(param1);
         }
      }
      
      override public function getDefaultCursorID() : int
      {
         return Cursor.CURSOR_CONTRACT_SIGNATOR;
      }
      
      override protected function getToolButtonId() : int
      {
         return MultifunctionBar.BUTTON_CONTRACT;
      }
      
      override protected function areaIsItemAffected(param1:ItemObject) : Boolean
      {
         var _loc2_:Boolean = super.areaIsItemAffected(param1);
         if(_loc2_)
         {
            _loc2_ = param1.isContractSignReady();
         }
         return _loc2_;
      }
   }
}

