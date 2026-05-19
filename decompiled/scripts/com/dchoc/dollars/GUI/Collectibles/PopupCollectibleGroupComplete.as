package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.VaultBar;
   import com.dchoc.dollars.collectibles.CollectibleGroupObject;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinition;
   import com.dchoc.dollars.collectibles.CollectibleRewardDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupCollectibleGroupComplete extends Popup
   {
      
      private var mClaimButton:DynamicButton;
      
      private var mReward:String;
      
      private var mTitle:TextField;
      
      private var mRewardDescription:TextField;
      
      private var mCollectibleGroup:CollectibleGroupObject;
      
      private var mPopupFeed:PopupPartner;
      
      private var mSkipButton:DynamicButton;
      
      public function PopupCollectibleGroupComplete(param1:CollectibleGroupObject)
      {
         this.mCollectibleGroup = param1;
         this.load();
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
         }
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function load() : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:ItemDefinition = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"popup_celebrate_building"))();
         this.mTitle = mBox["Caption"];
         TextManager.reformatTextField(this.mTitle);
         this.mTitle.text = TextManager.replaceParameters(TextIDs.TID_POPUP_COLLECTIBLES_COLLECTION_COMPLETED_TITLE,new Array(TextManager.getText(TextIDs[this.mCollectibleGroup.getCollectibleGroupDefinition().textID])));
         this.mClaimButton = new DynamicButton(mBox["share"]);
         this.mClaimButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_COLLECTION_COMPLETED_BUTTON));
         this.mSkipButton = new DynamicButton(mBox["skip"]);
         this.mRewardDescription = mBox["TextInfo_02"];
         TextManager.reformatTextField(this.mRewardDescription);
         this.mRewardDescription.text = TextManager.replaceParameters(TextIDs.TID_POPUP_COLLECTIBLES_COLLECTION_COMPLETED_BODY,new Array(TextManager.getText(TextIDs[this.mCollectibleGroup.getCollectibleGroupDefinition().textID])));
         TextManager.setTextScaled(this.mRewardDescription);
         var _loc1_:CollectibleRewardDefinition = CollectibleRewardDefinitionManager.getInstance().getDefinitionBySku(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku) as CollectibleRewardDefinition;
         if(_loc1_.rewardType == CollectibleRewardDefinition.TYPE_ITEM)
         {
            _loc3_ = ItemDefinitionManager.getInstance().getDefinitionBySku(this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku) as ItemDefinition;
            mBox["instance"].scaleX = 1;
            mBox["instance"].scaleY = 1;
            _loc2_ = _loc3_.getIcon(mBox["instance"]).icon;
            mBox["instance"].addChild(_loc2_);
         }
         else
         {
            _loc2_ = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,this.mCollectibleGroup.getCollectibleGroupDefinition().rewardSku))();
            mBox.addChild(_loc2_);
            _loc2_.y = -40;
         }
         if(_loc1_ != null && _loc1_.rewardType == CollectibleRewardDefinition.TYPE_SET)
         {
            TextField(_loc2_.getChildByName("experience")).visible = false;
            TextField(_loc2_.getChildByName("Cash")).visible = false;
         }
      }
      
      private function onClaimReward(param1:MouseEvent) : void
      {
         onClose(null);
         if(PopupCollectibleManager.getInstance().smPopupCollectibleShop != null)
         {
            if(!PopupCollectibleManager.getInstance().smPopupCollectibleShop.isOpen())
            {
               DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.VAULT_BUTTON);
               DollarsGame.getCurrentRole().toolsBar.getVaultBar().selectTool(VaultBar.BUTTON_COLLECTIBLE);
            }
            else
            {
               PopupCollectibleManager.getInstance().claimReward(this.mCollectibleGroup);
            }
         }
         else
         {
            DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.VAULT_BUTTON);
            DollarsGame.getCurrentRole().toolsBar.getVaultBar().selectTool(VaultBar.BUTTON_COLLECTIBLE);
         }
         if(this.mCollectibleGroup.getCollectibleGroupDefinition().IsCommerceGroup())
         {
            PopupCollectibleManager.getInstance().smPopupCollectibleShop.chageTab(PopupCollectables.TAB_VAULT);
         }
         else
         {
            PopupCollectibleManager.getInstance().smPopupCollectibleShop.chageTab(PopupCollectables.TAB_COLLECTIONS);
         }
      }
      
      override protected function endButtons() : void
      {
         this.mClaimButton.end();
         this.mClaimButton.removeEventListener(MouseEvent.CLICK,this.onClaimReward);
         this.mSkipButton.end();
         this.mSkipButton.removeEventListener(MouseEvent.CLICK,this.onSkip);
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow(false);
      }
      
      private function onSkip(param1:MouseEvent) : void
      {
         PopupCollectibleManager.getInstance().dispatchEvent(new Event(PopupCollectibleManager.WELLCOME_EVENT));
         onClose(null);
      }
      
      override protected function startButtons() : void
      {
         this.mClaimButton.start();
         this.mClaimButton.addEventListener(MouseEvent.CLICK,this.onClaimReward);
         this.mSkipButton.start();
         this.mSkipButton.addEventListener(MouseEvent.CLICK,this.onSkip);
      }
   }
}

