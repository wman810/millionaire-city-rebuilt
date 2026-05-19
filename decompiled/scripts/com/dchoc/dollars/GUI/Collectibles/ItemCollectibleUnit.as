package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.collectibles.CollectibleGroupObject;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ItemCollectibleUnit extends ItemCollectible
   {
      
      private var mBlockBuy:Boolean;
      
      private var mGiftButton:DynamicButton;
      
      private var mCollectibleGroup:CollectibleGroupObject;
      
      private var mGetButton:DynamicButton;
      
      private var mPopupFeed:PopupPartner;
      
      private var mTutorialArrow:MovieClip;
      
      public function ItemCollectibleUnit(param1:MovieClip, param2:CollectibleObject, param3:CollectibleGroupObject, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param2);
         this.mCollectibleGroup = param3;
         this.mGetButton = new DynamicButton(mBox.getChildByName("BuyButton") as MovieClip);
         this.mGetButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_GET));
         this.mGiftButton = new DynamicButton(mBox.getChildByName("askButton") as MovieClip);
         this.mGiftButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_GIFT));
         var _loc6_:Boolean = DollarsGame.getProfile().collectiblesShopGetEnhancedShown();
         var _loc7_:Boolean = !DollarsGame.getProfile().collectiblesGetFirstShown();
         if(param4 && DollarsGame.getProfile().collectiblesShopGetEnhancedShown())
         {
            this.mTutorialArrow = new AssetManager.TutorialArrow();
            this.mTutorialArrow.scaleX = 0.75;
            this.mTutorialArrow.scaleY = 0.75;
            mBox.addChild(this.mTutorialArrow);
            this.mTutorialArrow.x = this.mGetButton.getButtonMc().x;
            this.mTutorialArrow.y = this.mGetButton.getButtonMc().y;
         }
         this.mBlockBuy = param5;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.mGiftButton.destroy();
         this.mGiftButton = null;
         this.mGetButton.destroy();
         this.mGetButton = null;
      }
      
      public function start() : void
      {
         this.mGiftButton.start();
         this.mGetButton.start();
         if(this.mCollectibleGroup.getState() == CollectibleGroupObject.STATE_LOCKED)
         {
            this.mGetButton.disable();
         }
         else
         {
            this.mGetButton.addEventListener(MouseEvent.CLICK,this.onGet);
            if(!CollectibleManager.getInstance().canCollectibleBeKept(mCollectibleObject.getCollectibleDefinition().sku))
            {
               this.mGetButton.disable();
            }
         }
         this.mGiftButton.addEventListener(MouseEvent.CLICK,this.onSend);
         if(!CollectibleManager.getInstance().canCollectibleBeGivenAway(mCollectibleObject.getCollectibleDefinition().sku))
         {
            this.mGiftButton.disable();
         }
      }
      
      private function onSend(param1:MouseEvent) : void
      {
         PopupCollectibleManager.getInstance().smPopupCollectibleSend = new PopupSendCollectible(mCollectibleObject.getCollectibleDefinition().sku,"-1");
         PopupCollectibleManager.getInstance().smPopupCollectibleSend.showPopup();
      }
      
      public function end() : void
      {
         this.mGiftButton.end();
         this.mGetButton.end();
         switch(mCollectibleObject.getState())
         {
            case CollectibleObject.STATE_PENDING:
               this.mGiftButton.removeEventListener(MouseEvent.CLICK,this.onSend);
               this.mGetButton.removeEventListener(MouseEvent.CLICK,this.onGet);
         }
      }
      
      private function onGet(param1:MouseEvent) : void
      {
         DollarsGame.getProfile().collectiblesShopSetEnhancedShown(false);
         if(this.mTutorialArrow != null)
         {
            mBox.removeChild(this.mTutorialArrow);
            this.mTutorialArrow = null;
         }
         PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy = new PopupCollectibleBuyAsk(mCollectibleObject,PopupCollectibleBuyAsk.TYPE_SHOP_POPUP,"",this.mBlockBuy);
         PopupCollectibleManager.getInstance().smPopupCollectibleAskBuy.showPopup();
      }
   }
}

