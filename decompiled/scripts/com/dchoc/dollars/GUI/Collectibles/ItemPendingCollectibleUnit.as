package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.collectibles.CollectibleManager;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ItemPendingCollectibleUnit extends ItemPendingCollectible
   {
      
      private var mAcceptButton:DynamicButton;
      
      private var mSendButton:DynamicButton;
      
      public function ItemPendingCollectibleUnit(param1:CollectibleObject, param2:String)
      {
         super(param1,param2);
         this.mAcceptButton = new DynamicButton(mBox.getChildByName("send") as MovieClip);
         this.mAcceptButton.setLabel(TextManager.getText(TextIDs.TID_POPUP_COLLECTIBLES_PENDING_GIFT_BUTTON));
      }
      
      public function start() : void
      {
         this.mAcceptButton.start();
         this.mAcceptButton.addEventListener(MouseEvent.CLICK,this.onAcceptCollectible);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.mAcceptButton.destroy();
         this.mAcceptButton = null;
      }
      
      public function end() : void
      {
         this.mAcceptButton.end();
         this.mAcceptButton.removeEventListener(MouseEvent.CLICK,this.onAcceptCollectible);
      }
      
      private function onAcceptCollectible(param1:MouseEvent) : void
      {
         var _loc2_:String = mCollectibleObject.getCollectibleDefinition().sku;
         var _loc3_:PopupCollectibleFound = PopupCollectibleManager.getInstance().smPopupCollectibleFound;
         if(CollectibleManager.getInstance().canCollectibleBeKept(_loc2_))
         {
            PopupCollectibleManager.getInstance().smPopupCollectibleFound = new PopupCollectibleFound(PopupCollectibleFound.STATE_IDLE,_loc2_);
         }
         else
         {
            PopupCollectibleManager.getInstance().smPopupCollectibleFound = new PopupCollectibleFound(PopupCollectibleFound.STATE_KEEP,_loc2_);
         }
         PopupCollectibleManager.getInstance().smPopupCollectibleFound.setSenderId(mFriendId);
         PopupCollectibleManager.getInstance().smPopupCollectibleFound.showPopup();
      }
   }
}

