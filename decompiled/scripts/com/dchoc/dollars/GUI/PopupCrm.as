package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.WelcomeProgress;
   import com.dchoc.dollars.utils.actions.ActionsLibrary;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.CRMCustomizerDefinition;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupCrm extends Popup
   {
      
      private var mImageInstance:Sprite;
      
      private var mSetImageTimerId:int;
      
      private var mDef:CRMCustomizerDefinition;
      
      public function PopupCrm(param1:CRMCustomizerDefinition)
      {
         this.mDef = param1;
         mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_Crm"))();
         mOkButton = new DynamicButton(mBox.getChildByName("actionButton") as MovieClip);
         mBox.addChild(mOkButton.getButtonMc());
         mOkButton.setLabel(this.mDef.actionButtonLabel);
         mCancelButton = new DynamicButton(mBox.getChildByName("skipButton") as MovieClip);
         var _loc2_:TextField = mBox.getChildByName("Title") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = this.mDef.title;
         TextManager.setTextScaled(_loc2_);
         var _loc3_:TextField = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(_loc3_);
         var _loc4_:String = this.mDef.text.replace(/\"/g,"\'");
         _loc3_.text = _loc4_;
         TextManager.setTextScaled(_loc3_,false);
         _loc3_.y += (_loc3_.height - _loc3_.textHeight) / 2;
         this.mImageInstance = mBox.getChildByName("image") as Sprite;
         this.mImageInstance.visible = false;
         this.setImageCrm();
         super();
      }
      
      private function doAction(param1:MouseEvent) : void
      {
         onAccept(null);
         var _loc2_:Object = this.mDef.crmParams[CRMCustomizerDefinition.TRACKING_ONCLICK];
         if(_loc2_ != null)
         {
            MyMetrics.sendMetric(_loc2_.event,_loc2_.label,null,_loc2_.product,0,0,_loc2_.group);
         }
      }
      
      private function setImageCrm() : void
      {
         var _loc1_:int = 0;
         if(this.mDef.image != null)
         {
            _loc1_ = mBox.getChildIndex(this.mImageInstance);
            mBox.addChildAt(this.mDef.image,_loc1_);
            this.mDef.image.x = this.mImageInstance.x - this.mDef.image.width / 2;
            this.mDef.image.y = this.mImageInstance.y - this.mDef.image.height / 2;
            mBox.removeChild(this.mImageInstance);
         }
      }
      
      override public function destroy() : void
      {
         if(this.mDef.image != null)
         {
            mBox.removeChild(this.mDef.image);
         }
      }
      
      private function onError(param1:IOErrorEvent) : void
      {
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("Error loading Image popup crm");
         }
      }
      
      override protected function endButtons() : void
      {
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.doAction);
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
      }
      
      override public function showPopup() : void
      {
         super.show();
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.doAction);
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         startShow(false);
         var _loc1_:Object = this.mDef.crmParams[CRMCustomizerDefinition.TRACKING_ONDISPLAY];
         if(_loc1_ != null)
         {
            MyMetrics.sendMetricNG(_loc1_.event,_loc1_.label,_loc1_.product,_loc1_.product_detail,null,0,0,_loc1_.group);
         }
      }
      
      override protected function close() : void
      {
         super.close();
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
         if(mAccepted)
         {
            dispatchEvent(new Event(EVENT_ACCEPT));
            ActionsLibrary.getInstance().launchAction(this.mDef.actionButtonAction,this.mDef.actionButtonParams);
            if(this.mDef.actionButtonAction != null)
            {
               DollarsGame.smInstance.mWelcomProgress.dispatchEvent(new Event(WelcomeProgress.EVENT_WELCOME_END));
            }
         }
         dispatchEvent(new Event(EVENT_CLOSE));
      }
      
      private function setImage(param1:Event) : void
      {
         var _loc2_:Loader = param1.target.loader as Loader;
         var _loc3_:Bitmap = Bitmap(_loc2_.content);
         var _loc4_:int = mBox.getChildIndex(this.mImageInstance);
         mBox.addChildAt(_loc3_,_loc4_);
         _loc3_.x -= _loc3_.width / 2;
         _loc3_.y = this.mImageInstance.y;
         mBox.removeChild(this.mImageInstance);
      }
   }
}

