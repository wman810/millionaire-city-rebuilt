package com.dchoc.dollars.GUI.storage
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxWonder;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoClub;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoCommerce;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoDeco;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoHouse;
   import com.dchoc.dollars.GUI.infoBox.ShopMenuInfoWonder;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.freeGift.FreeGiftDefinition;
   import com.dchoc.dollars.freeGift.FreeGiftDefinitionManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.storage.StoredItem;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class StorageItemContent extends Sprite
   {
      
      public var mStoredItem:StoredItem;
      
      private var mIsClaimed:Boolean = false;
      
      private var mBox:Sprite;
      
      private var mImage:Bitmap;
      
      private var mItemIcon:Object;
      
      private var mInfo:InfoBox;
      
      private var mButton:DynamicButton;
      
      public function StorageItemContent(param1:StoredItem)
      {
         var _loc2_:Sprite = null;
         super();
         this.mStoredItem = param1;
         this.mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.STORAGE_SWF,"storage_box"))();
         addChild(this.mBox);
         this.mButton = new DynamicButton(this.mBox.getChildByName("button_use") as MovieClip);
         this.mButton.setLabel(TextManager.getText(TextIDs.TID_STORAGE_USE_BUTTON));
         this.mButton.start();
         this.mButton.addEventListener(MouseEvent.CLICK,this.onClaim);
         var _loc3_:TextField = this.mBox.getChildByName("title") as TextField;
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = TextManager.getText(TextIDs[this.mStoredItem.mTid]);
         TextManager.setTextScaled(_loc3_);
         this.buildAvailableText();
         this.setupIcon();
      }
      
      private function showInfoBox(param1:MouseEvent) : void
      {
         var _loc4_:FreeGiftDefinition = null;
         var _loc2_:ItemDefinition = ItemDefinitionManager.getInstance().getDefinitionBySku(this.mStoredItem.mSku) as ItemDefinition;
         var _loc3_:Point = new Point(this.mBox.x,this.mBox.y);
         _loc3_ = this.mBox.localToGlobal(_loc3_);
         this.mInfo.show(_loc2_,_loc3_.x + this.mBox.width - 15,_loc3_.y + this.mBox.height / 2,this.mBox.width - 20);
         if(this.mStoredItem.mAction == StoredItem.ACTION_RENT_ACCELERATOR)
         {
            _loc4_ = FreeGiftDefinitionManager.getInstance().getDefinition(this.mStoredItem.mSku) as FreeGiftDefinition;
            (this.mInfo as InfoBoxWonder).setCustomText(TextManager.getText(TextIDs[this.mStoredItem.mTid]),TextManager.replaceParameters(TextIDs.TID_FGIFT_015_TOOLTIP,[_loc4_.value]));
         }
      }
      
      private function onClaim(param1:MouseEvent) : void
      {
         dispatchEvent(new MouseEvent(PopupStorage.EVENT_USE_ITEM));
      }
      
      private function closeInfoBox(param1:MouseEvent) : void
      {
         this.mInfo.close();
      }
      
      public function buildAvailableText() : void
      {
         var _loc1_:TextField = this.mBox.getChildByName("counter") as TextField;
         TextManager.reformatTextField(_loc1_);
         _loc1_.text = String(this.mStoredItem.getAmount());
         if(this.mStoredItem.getMaxAmount() > -1)
         {
            _loc1_.text = _loc1_.text + "/" + this.mStoredItem.getMaxAmount();
         }
         TextManager.setTextScaled(_loc1_);
      }
      
      private function setupBox(param1:ItemDefinition) : void
      {
         this.mItemIcon.icon.addEventListener(MouseEvent.ROLL_OVER,this.showInfoBox);
         this.mItemIcon.icon.addEventListener(MouseEvent.ROLL_OUT,this.closeInfoBox);
         switch(param1.type)
         {
            case ItemDefinition.TYPE_HOUSES_ID:
               this.mInfo = new ShopMenuInfoHouse(DollarsGame.smInstance.mPopupClip,param1);
               break;
            case ItemDefinition.TYPE_COMMERCES_ID:
               this.mInfo = new ShopMenuInfoCommerce(DollarsGame.smInstance.mPopupClip,param1);
               break;
            case ItemDefinition.TYPE_DECORATIONS_ID:
               this.mInfo = new ShopMenuInfoDeco(DollarsGame.smInstance.mPopupClip,param1);
               break;
            case ItemDefinition.TYPE_WONDERS_ID:
               this.mInfo = new ShopMenuInfoWonder(DollarsGame.smInstance.mPopupClip,param1);
               break;
            case ItemDefinition.TYPE_CLUBS_ID:
               this.mInfo = new ShopMenuInfoClub(DollarsGame.smInstance.mPopupClip,param1);
         }
      }
      
      public function setupIcon() : void
      {
         var _loc2_:ItemDefinition = null;
         var _loc1_:MovieClip = this.mBox.getChildByName("instance") as MovieClip;
         if(this.mImage == null)
         {
            this.mImage = new Bitmap(DCResourceManager.getInstance().get(this.mStoredItem.mType));
            this.mImage.x = (_loc1_.width - this.mImage.width) / 2;
            this.mImage.y = (_loc1_.height - this.mImage.height) / 2;
            _loc1_.addChild(this.mImage);
            if(this.mStoredItem.mAction == StoredItem.ACTION_RENT_ACCELERATOR)
            {
               this.mInfo = new InfoBoxWonder(DollarsGame.smInstance.mPopupClip,null);
               _loc1_.addEventListener(MouseEvent.ROLL_OVER,this.showInfoBox);
               _loc1_.addEventListener(MouseEvent.ROLL_OUT,this.closeInfoBox);
            }
         }
         if(this.mStoredItem.mAction == StoredItem.ACTION_PLACE)
         {
            _loc2_ = ItemDefinitionManager.getInstance().getDefinitionBySku(this.mStoredItem.mSku) as ItemDefinition;
            if(this.mItemIcon == null && PriorityLoader.getInstance().isLoaded(_loc2_.getSkuToLoad()))
            {
               this.mItemIcon = _loc2_.getIcon(_loc1_);
               this.setupBox(_loc2_);
               _loc1_.addChild(this.mItemIcon.icon);
            }
         }
      }
      
      public function destroy() : void
      {
         this.mStoredItem = null;
         this.mButton.removeEventListener(MouseEvent.CLICK,this.onClaim);
         this.mButton.disable();
         this.mButton = null;
         var _loc1_:MovieClip = this.mBox.getChildByName("instance") as MovieClip;
         if(this.mImage != null)
         {
            _loc1_.removeChild(this.mImage);
         }
         if(this.mInfo != null)
         {
            this.mInfo.close();
            _loc1_.removeEventListener(MouseEvent.ROLL_OVER,this.showInfoBox);
            _loc1_.removeEventListener(MouseEvent.ROLL_OUT,this.closeInfoBox);
            this.mInfo.destroy();
            this.mInfo = null;
         }
         this.mImage = null;
         if(this.mItemIcon != null)
         {
            this.mItemIcon.icon.removeEventListener(MouseEvent.ROLL_OVER,this.showInfoBox);
            this.mItemIcon.icon.removeEventListener(MouseEvent.ROLL_OUT,this.closeInfoBox);
            _loc1_.removeChild(this.mItemIcon.icon);
            this.mItemIcon.icon = null;
            this.mItemIcon = null;
         }
         removeChild(this.mBox);
         this.mBox = null;
      }
      
      public function isItem() : Boolean
      {
         return this.mBox != null;
      }
   }
}

