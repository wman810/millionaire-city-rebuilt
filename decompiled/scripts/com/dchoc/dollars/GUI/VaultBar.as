package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectables;
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.GUI.storage.PopupStorage;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class VaultBar extends Sprite
   {
      
      public static const BUTTON_STORAGE:int = 0;
      
      public static const BUTTON_COLLECTIBLE:int = 1;
      
      private var mStorageButton:DynamicButton;
      
      private var mCollectibleButton:DynamicButton;
      
      private var mPopupStorage:PopupStorage;
      
      private var mToolsBar:ToolsBar;
      
      private var mBar:Sprite;
      
      private var mStorageAlert:MovieClip;
      
      public function VaultBar()
      {
         super();
         this.mBar = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"button_multifuncion_storage"))();
         addChild(this.mBar);
         this.mStorageButton = new DynamicButton(this.mBar.getChildByName("storage") as MovieClip);
         this.mCollectibleButton = new DynamicButton(this.mBar.getChildByName("collectibles") as MovieClip);
         this.mStorageAlert = this.mStorageButton.getButtonMc()["alert"];
      }
      
      public function start(param1:int = -1) : void
      {
         this.mStorageButton.start();
         this.mStorageButton.addEventListener(MouseEvent.CLICK,this.setTool);
         this.mStorageButton.setUnselected();
         this.mStorageButton.setTip(TextManager.getText(TextIDs.TID_POPUP_STORAGE_TITLE));
         this.mCollectibleButton.start();
         this.mCollectibleButton.setUnselected();
         if(CollectibleManager.getInstance().areCollectibleAllowed())
         {
            this.mCollectibleButton.enable();
            this.mCollectibleButton.addEventListener(MouseEvent.CLICK,this.setTool);
            this.mCollectibleButton.setTip(TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_GIFT));
         }
         else
         {
            this.mCollectibleButton.disable(true);
            this.mCollectibleButton.setTip(TextManager.replaceParameters(TextIDs.TID_UNLOCK_LEVEL_COLLECTIBLES,new Array("" + RulesFacade.getInstance().settingsGetCollectiblesUnlockLevel())));
         }
         this.visible = true;
         this.selectTool(param1);
      }
      
      private function setTool(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         this.mStorageButton.setUnselected();
         this.mCollectibleButton.setUnselected();
         switch(_loc2_)
         {
            case this.mStorageButton.getButtonMc():
               if(this.mPopupStorage == null)
               {
                  this.mPopupStorage = new PopupStorage();
                  this.mPopupStorage.showPopup();
                  break;
               }
               this.mPopupStorage.showPopup();
               break;
            case this.mCollectibleButton.getButtonMc():
               if(PopupCollectibleManager.getInstance().smPopupCollectibleShop == null)
               {
                  PopupCollectibleManager.getInstance().smPopupCollectibleShop = new PopupCollectables();
                  break;
               }
               PopupCollectibleManager.getInstance().smPopupCollectibleShop.showPopup();
         }
         this.mToolsBar.hideVaultBar();
      }
      
      public function selectTool(param1:int) : void
      {
         switch(param1)
         {
            case BUTTON_STORAGE:
               this.mStorageButton.getButtonMc().dispatchEvent(new MouseEvent(MouseEvent.CLICK));
               break;
            case BUTTON_COLLECTIBLE:
               this.mCollectibleButton.getButtonMc().dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         }
      }
      
      public function logicUpdate(param1:Number) : void
      {
         if(this.mPopupStorage != null)
         {
            this.mPopupStorage.logicUpdate(param1);
            if(!this.mPopupStorage.isOpen())
            {
               this.mPopupStorage.destroy();
               this.mPopupStorage = null;
            }
         }
      }
      
      public function setToolsBar(param1:ToolsBar) : void
      {
         this.mToolsBar = param1;
      }
      
      public function end() : void
      {
         this.mStorageButton.end();
         this.mStorageButton.removeEventListener(MouseEvent.CLICK,this.setTool);
         this.mCollectibleButton.end();
         this.mCollectibleButton.removeEventListener(MouseEvent.CLICK,this.setTool);
         this.visible = false;
      }
      
      public function setAlert(param1:Boolean) : void
      {
         this.mStorageAlert.visible = param1;
         if(param1)
         {
            this.mStorageAlert.play();
         }
         else
         {
            this.mStorageAlert.stop();
         }
      }
   }
}

