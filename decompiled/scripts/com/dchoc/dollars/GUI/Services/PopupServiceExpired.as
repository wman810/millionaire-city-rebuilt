package com.dchoc.dollars.GUI.Services
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupServiceExpired extends Popup
   {
      
      public static const TYPE_MONEY_COLLECTOR:String = "moneyCollector";
      
      public static const TYPE_CONTRACT_SIGNATOR:String = "contractSignator";
      
      private var mAcceptButton:DynamicButton;
      
      private var mTextInfo:TextField;
      
      private var mTitle:TextField;
      
      private var mType:String;
      
      public function PopupServiceExpired()
      {
         super();
      }
      
      private function onCloseOffer(param1:MouseEvent) : void
      {
         if(DollarsGame.getProfile().servicesIsOfferEnabled(this.mType))
         {
            DollarsGame.getProfile().setServicesIsOfferEnabled(this.mType,false);
         }
         onClose(null);
      }
      
      override protected function startButtons() : void
      {
         this.mAcceptButton.start();
         this.mAcceptButton.addEventListener(MouseEvent.CLICK,this.onAcceptOffer);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,this.onCloseOffer);
      }
      
      override protected function endButtons() : void
      {
         this.mAcceptButton.end();
         this.mAcceptButton.removeEventListener(MouseEvent.CLICK,this.onAcceptOffer);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,this.onCloseOffer);
      }
      
      override public function showPopup() : void
      {
         super.show();
         startShow(false);
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      public function resetParameters() : void
      {
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,this.mType))();
         resize();
         this.mAcceptButton = new DynamicButton(mBox.getChildByName("AcceptButton") as MovieClip);
         this.mAcceptButton.setLabel("Accept");
         mCancelButton = new DynamicButton(mBox.getChildByName("CancelButton") as MovieClip);
         mCancelButton.setLabel("Cancel");
         this.mTitle = mBox.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(this.mTitle);
         TextManager.setTextScaled(this.mTitle);
         this.mTextInfo = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(this.mTextInfo);
         TextManager.setTextScaled(this.mTextInfo);
         switch(this.mType)
         {
            case TYPE_CONTRACT_SIGNATOR:
               this.mAcceptButton.setLabel(TextManager.getText(TextIDs.TID_CONTRACTOR_CONTRACT_BUTTON));
               this.mTitle.text = TextManager.getText(TextIDs.TID_CONTRACTOR_CONTRACT_TITLE);
               this.mTextInfo.text = TextManager.getText(TextIDs.TID_CONTRACTOR_CONTRACT_BODY);
               break;
            case TYPE_MONEY_COLLECTOR:
               this.mAcceptButton.setLabel(TextManager.getText(TextIDs.TID_CONTRACTOR_COLLECT_BUTTON));
               this.mTitle.text = TextManager.getText(TextIDs.TID_CONTRACTOR_COLLECT_TITLE);
               this.mTextInfo.text = TextManager.getText(TextIDs.TID_CONTRACTOR_COLLECT_BODY);
         }
      }
      
      public function get type() : String
      {
         return this.mType;
      }
      
      public function setSku(param1:String) : void
      {
         this.mType = param1;
      }
      
      private function onAcceptOffer(param1:MouseEvent) : void
      {
         onAccept(null);
      }
   }
}

