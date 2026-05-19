package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.collectibles.CollectibleGroupObject;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.map.tools.ToolBuild;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.particles.Plane;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class PopupCollectibleManager extends EventDispatcher
   {
      
      private static var smAllowInstantation:Boolean;
      
      private static var smInstance:PopupCollectibleManager;
      
      public static const WELLCOME_EVENT:String = "eventWellcomeEntrance";
      
      public static const STATE_WELLCOME:int = 0;
      
      public static const STATE_INGAME:int = 1;
      
      public var smPopupCollectibleShop:PopupCollectables;
      
      public var smPopupCollectibleCelebrate:PopupCollectibleCelebrate;
      
      public var smPopupCollectiblePendingList:PopupPendingCollectiblesList;
      
      public var smPopupCollectibleGroupComplete:PopupCollectibleGroupComplete;
      
      public var smPopupCollectibleSend:PopupSendCollectible;
      
      public var smPopupCollectibleAskBuy:PopupCollectibleBuyAsk;
      
      public var smPopupCollectibleSell:PopupCollectibleConfirmSell;
      
      private var mState:int;
      
      private var mCollectibleGroup:CollectibleGroupObject;
      
      public var smPopupCollectibleFound:PopupCollectibleFound;
      
      private var mPopupFeed:PopupPartner;
      
      public function PopupCollectibleManager()
      {
         super();
         if(!smAllowInstantation)
         {
            throw new Error("ERROR: PopupCollectibleManager Error: Instantiation failed: Use PopupCollectibleManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : PopupCollectibleManager
      {
         if(!smInstance)
         {
            smAllowInstantation = true;
            smInstance = new PopupCollectibleManager();
            smAllowInstantation = false;
         }
         return smInstance;
      }
      
      private function showCelebratePopup(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc5_:Map = null;
         var _loc6_:CollectibleRewardDefinition = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         var _loc2_:Object = UserDataFacade.securityCreateObj(0,0,0);
         _loc3_ = "-1";
         var _loc4_:CollectibleRewardDefinition = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku) as CollectibleRewardDefinition;
         if(_loc4_.rewardType != CollectibleRewardDefinition.TYPE_ITEM)
         {
            _loc6_ = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(_loc4_.sku) as CollectibleRewardDefinition;
            _loc7_ = 0;
            _loc8_ = 0;
            _loc9_ = 0;
            switch(_loc4_.rewardType)
            {
               case CollectibleRewardDefinition.TYPE_CASH:
                  _loc7_ = int(_loc6_.Value);
                  DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash + _loc7_;
                  break;
               case CollectibleRewardDefinition.TYPE_COINS:
                  _loc8_ = int(_loc6_.Value);
                  DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash + _loc8_;
                  break;
               case CollectibleRewardDefinition.TYPE_EXP:
                  _loc9_ = int(_loc6_.Value);
                  DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash + _loc9_;
                  break;
               case CollectibleRewardDefinition.TYPE_SET:
                  _loc10_ = _loc6_.Value.split(":");
                  _loc7_ = int(_loc10_[0]);
                  _loc8_ = int(_loc10_[1]);
                  _loc9_ = int(_loc10_[2]);
                  DollarsGame.getCurrentWorld().getCompanyMine().DCCash = DollarsGame.getCurrentWorld().getCompanyMine().DCCash + _loc7_;
                  DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins + _loc8_;
                  DollarsGame.getCurrentWorld().getCompanyMine().exp = DollarsGame.getCurrentWorld().getCompanyMine().exp + _loc9_;
            }
            _loc2_ = UserDataFacade.securityCreateObj(_loc9_,_loc8_,_loc7_);
            UserDataFacade.getInstance().updateCollectible(_loc3_,this.mCollectibleGroup.getCollectibleGroupDefinition().sku,"GET_REWARD",null,{},_loc2_);
         }
         this.mCollectibleGroup.tradeIn(this.mCollectibleGroup.getCollectibleGroupDefinition().getCanbeReclaimed());
         PopupCollectibleManager.getInstance().smPopupCollectibleShop.refreshGroups();
         if(_loc4_.rewardType == CollectibleRewardDefinition.TYPE_HQ)
         {
            _loc5_ = param1.target as Map;
            _loc5_.removeEventListener(Map.EVENT_AUTO_SCROLL_ANIM_END,this.showCelebratePopup);
         }
         else if(_loc4_.rewardType == CollectibleRewardDefinition.TYPE_PLANE)
         {
            DollarsGame.smInstance.mPlane.removeEventListener(Plane.EVENT_OPEN_POPUPCOLLECTIBLEGROUP,this.showCelebratePopup);
         }
         else if(_loc4_.rewardType == CollectibleRewardDefinition.TYPE_ITEM)
         {
            _loc5_ = param1.target as Map;
            _loc5_.removeEventListener(ToolBuild.EVENT_PLACE_GIFT_ITEM,this.showCelebratePopup);
         }
         this.mPopupFeed = new PopupPartner(PopupPartner.TYPE_SHARE_COMPLETE_COLLECTIBLE_COLLECTION,this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku);
         this.mPopupFeed.showPopupParams(null);
         this.mPopupFeed.addEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
      }
      
      public function setState(param1:int) : void
      {
         this.mState = param1;
      }
      
      public function claimReward(param1:CollectibleGroupObject) : void
      {
         var _loc3_:ItemDefinition = null;
         this.mCollectibleGroup = param1;
         if(!this.mCollectibleGroup.getCollectibleGroupDefinition().getCanbeReclaimed())
         {
            PopupCollectibleManager.getInstance().smPopupCollectibleShop.onClose(null);
         }
         var _loc2_:CollectibleRewardDefinition = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku) as CollectibleRewardDefinition;
         if(_loc2_.rewardType)
         {
            if(_loc2_.rewardType == CollectibleRewardDefinition.TYPE_HQ)
            {
               DollarsGame.getCurrentWorld().map.addEventListener(Map.EVENT_AUTO_SCROLL_ANIM_END,this.showCelebratePopup);
               DollarsGame.getCurrentWorld().map.launchAutoScroll(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku);
            }
            else if(_loc2_.rewardType == CollectibleRewardDefinition.TYPE_PLANE && !DollarsGame.smInstance.mPlane.isActive)
            {
               DollarsGame.smInstance.mPlane.addEventListener(Plane.EVENT_OPEN_POPUPCOLLECTIBLEGROUP,this.showCelebratePopup);
               DollarsGame.getCurrentWorld().map.launchAutoScroll(null);
               DollarsGame.smInstance.mPlane.setPlane(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku);
               DollarsGame.smInstance.mPlane.start(DollarsGame.getProfile().cityname);
            }
            else if(_loc2_.rewardType == CollectibleRewardDefinition.TYPE_ITEM)
            {
               _loc3_ = ItemDefinitionManager.getInstance().getDefinitionBySku(_loc2_.sku) as ItemDefinition;
               DollarsGame.getCurrentRole().toolsBar.setToolBuild(_loc3_,true,UserDataFacade.getInstance().cmdCreateNewItemFromCollectibleReward(this.mCollectibleGroup.getCollectibleGroupDefinition().sku));
               DollarsGame.getCurrentWorld().map.addEventListener(ToolBuild.EVENT_PLACE_GIFT_ITEM,this.showCelebratePopup);
            }
            else if(_loc2_.rewardType == CollectibleRewardDefinition.TYPE_CASH || _loc2_.rewardType == CollectibleRewardDefinition.TYPE_COINS || _loc2_.rewardType == CollectibleRewardDefinition.TYPE_EXP || _loc2_.rewardType == CollectibleRewardDefinition.TYPE_SET)
            {
               this.showCelebratePopup(null);
            }
         }
         else
         {
            DollarsGame.getCurrentWorld().map.addEventListener(Map.EVENT_AUTO_SCROLL_ANIM_END,this.showCelebratePopup);
            DollarsGame.getCurrentWorld().map.launchAutoScroll(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku);
         }
      }
      
      public function getState() : int
      {
         return this.mState;
      }
      
      private function onCloseFeed(param1:Event) : void
      {
         PopupCollectibleManager.getInstance().dispatchEvent(new Event(PopupCollectibleManager.WELLCOME_EVENT));
         this.mPopupFeed.removeEventListener(Popup.EVENT_CLOSE,this.onCloseFeed);
         this.mPopupFeed = null;
      }
   }
}

