package com.dchoc.dollars.GUI.storage
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.freeGift.FreeGiftPrize;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupBoxOpen extends Popup
   {
      
      private var mIsOpen:Boolean = false;
      
      private var mPrize:FreeGiftPrize;
      
      private var mPublish:DynamicButton;
      
      private var mImage:Bitmap;
      
      private var mIconContainer:Object;
      
      public function PopupBoxOpen(param1:FreeGiftPrize)
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:ItemDefinition = null;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.STORAGE_SWF,"popup_box_open"))();
         this.mPrize = param1;
         this.mImage = new Bitmap(DCResourceManager.getInstance().get(param1.mResname));
         var _loc2_:MovieClip = mBox["instance"];
         _loc2_.addChild(this.mImage);
         var _loc3_:TextField = mBox["Title"];
         TextManager.reformatTextField(_loc3_);
         _loc3_.text = TextManager.getText(TextIDs.TID_BRIEFCASE_POPUP_TITLE);
         TextManager.setTextScaled(_loc3_);
         _loc3_ = mBox["Caption"];
         switch(param1.mType)
         {
            case FreeGiftPrize.TYPE_CASH:
               _loc4_ = int(param1.mValue) * DollarsGame.getProfile().level;
               _loc3_.text = TextManager.getText(TextIDs[param1.mTid]) + TextManager.convertNumberToString(_loc4_,0,0);
               break;
            case FreeGiftPrize.TYPE_EXP:
               _loc5_ = int(param1.mValue) / 100;
               _loc6_ = DollarsGame.getProfile().maxExp - RulesFacade.getLevelXP(DollarsGame.getProfile().level - 1);
               _loc6_ = _loc6_ * _loc5_;
               _loc3_.text = TextManager.replaceParameters(TextManager.getText(TextIDs[param1.mTid]),[_loc6_]);
               break;
            case FreeGiftPrize.TYPE_GOLD:
               _loc3_.text = param1.mValue + " " + TextManager.getText(TextIDs[param1.mTid]);
               break;
            case FreeGiftPrize.TYPE_MOVE:
               _loc3_.text = TextManager.replaceParameters(TextManager.getText(TextIDs[param1.mTid]),[param1.mValue]);
               break;
            case FreeGiftPrize.TYPE_ITEM:
               _loc7_ = ItemDefinitionManager.getInstance().getDefinitionBySku(param1.mValue) as ItemDefinition;
               if(this.mIconContainer == null && PriorityLoader.getInstance().isLoaded(param1.mValue))
               {
                  this.mIconContainer = _loc7_.getIcon(_loc2_);
                  _loc2_.addChild(this.mIconContainer.icon);
               }
               _loc3_.text = TextManager.getText(TextIDs[_loc7_.textID]);
         }
         TextManager.reformatTextField(_loc3_);
         TextManager.setTextScaled(_loc3_);
         mCancelButton = new DynamicButton(mBox["mClose"]);
         this.mPublish = new DynamicButton(mBox["publish"]);
         this.mPublish.setLabel(TextManager.getText(TextIDs.TID_POPUP_BUTTON_NEW_PARTNERS));
         super();
         this.showPopup();
      }
      
      override protected function endButtons() : void
      {
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mPublish.end();
         this.mPublish.removeEventListener(MouseEvent.CLICK,this.onPublish);
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow();
         this.mIsOpen = true;
      }
      
      private function onPublish(param1:Event) : void
      {
         Debug.trace("publishing");
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
            "postId":UserDataFacade.POST_OPEN_BOX_STORAGE,
            "feedImg":this.mPrize.mSource + ".jpg",
            "product":this.mPrize.mSource + " Open"
         });
         onClose();
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         this.mIsOpen = false;
      }
      
      override public function destroy() : void
      {
         if(mCancelButton != null)
         {
            mCancelButton.destroy();
            mCancelButton = null;
         }
         if(this.mPublish != null)
         {
            this.mPublish.removeEventListener(MouseEvent.CLICK,this.onPublish);
            this.mPublish.destroy();
            this.mPublish = null;
         }
         var _loc1_:MovieClip = mBox["instance"];
         if(this.mImage != null)
         {
            _loc1_.removeChild(this.mImage);
            this.mImage = null;
         }
         if(this.mIconContainer != null)
         {
            _loc1_.removeChild(this.mIconContainer.icon);
            this.mIconContainer.icon = null;
            this.mIconContainer.grid = null;
            this.mIconContainer = null;
         }
         this.mPrize = null;
         super.destroy();
      }
      
      public function isStorageOpen() : Boolean
      {
         return this.mIsOpen;
      }
      
      override protected function startButtons() : void
      {
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mPublish.start();
         this.mPublish.addEventListener(MouseEvent.CLICK,this.onPublish);
      }
   }
}

