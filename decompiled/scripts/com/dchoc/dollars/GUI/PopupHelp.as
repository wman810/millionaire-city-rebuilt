package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupHelp extends Popup
   {
      
      protected var mPageFormat:Array;
      
      protected var mImageArray:Array;
      
      protected var mBackButton:DynamicButton;
      
      protected var mNextButton:DynamicButton;
      
      protected var mMaxPages:int;
      
      protected const PAGE_TYPE_TEXT:int = 0;
      
      protected var mCurrentImageIndex:int;
      
      protected const PAGE_TYPE_IMAGE:int = 1;
      
      protected var mImage:MovieClip;
      
      protected var mCurrentImage:Bitmap;
      
      protected var mCurrentPage:int;
      
      protected var mImageBox:Sprite;
      
      public function PopupHelp()
      {
         if(DollarsGame.getProfile().bossGenre == Profile.BOSS_MALE)
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_help_01"))();
         }
         else
         {
            mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_help_02"))();
         }
         mCancelButton = new DynamicButton(mBox.getChildByName("mClose") as MovieClip);
         this.mNextButton = new DynamicButton(mBox.getChildByName("NextButton") as MovieClip);
         this.mNextButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_NEXT));
         this.mBackButton = new DynamicButton(mBox.getChildByName("BackButton") as MovieClip);
         this.mBackButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_BACK));
         this.setTitle(this.getTitleId());
         this.setPages(this.getPagesFormat());
         this.setImageArray(this.getImagesArray());
         super();
      }
      
      private function setImageArray(param1:Array) : void
      {
         this.mImageArray = param1;
      }
      
      protected function updateText(param1:Boolean = true) : void
      {
         var _loc3_:TextField = null;
         var _loc2_:TextField = TextField(mBox.getChildByName("Step"));
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.replaceParameters(TextIDs.TID_TUTORIAL_STEP,new Array("" + (this.mCurrentPage + 1),"" + this.mMaxPages));
         TextManager.setTextScaled(_loc2_);
         if(this.mImage)
         {
            if(this.mCurrentImage != null && this.mImage.contains(this.mCurrentImage))
            {
               this.mImage.removeChild(this.mCurrentImage);
            }
         }
         if(this.mPageFormat[this.mCurrentPage] == this.PAGE_TYPE_TEXT)
         {
            if(this.mImageBox)
            {
               this.mImageBox.visible = false;
            }
            mTextBox.visible = true;
            mTextBox.text = TextManager.getText(this.getTextId() + this.mCurrentPage);
            if(!param1 && this.mPageFormat[this.mCurrentPage + 1] == this.PAGE_TYPE_IMAGE)
            {
               --this.mCurrentImageIndex;
            }
         }
         else
         {
            if(this.mImageBox)
            {
               this.mImageBox.visible = true;
            }
            mTextBox.visible = false;
            if(param1)
            {
               ++this.mCurrentImageIndex;
            }
            else
            {
               --this.mCurrentImageIndex;
            }
            if(this.mImageBox)
            {
               _loc3_ = TextField(this.mImageBox.getChildByName("TextInfo_01"));
               TextManager.reformatTextField(_loc3_);
               TextField(_loc3_).text = TextManager.getText(this.getTextId() + this.mCurrentPage);
               TextManager.setTextScaled(_loc3_);
            }
            if(this.mImage)
            {
               this.mCurrentImage = this.mImageArray[this.mCurrentImageIndex];
               this.mImage.addChild(this.mCurrentImage);
            }
         }
      }
      
      private function setPages(param1:Array) : void
      {
         if(param1 != null)
         {
            this.mMaxPages = param1.length;
            this.mPageFormat = param1;
         }
      }
      
      private function setTitle(param1:int) : void
      {
         TextManager.reformatTextField(TextField(mBox.getChildByName("Caption")));
         TextField(mBox.getChildByName("Caption")).text = TextManager.getText(param1);
      }
      
      protected function getTextId() : int
      {
         return -1;
      }
      
      protected function getTitleId() : int
      {
         return -1;
      }
      
      private function onNext(param1:MouseEvent) : void
      {
         if(this.mCurrentPage < this.mMaxPages - 1)
         {
            ++this.mCurrentPage;
            this.updateText();
            if(this.mCurrentPage == this.mMaxPages - 1)
            {
               this.mNextButton.disable();
            }
            if(!this.mBackButton.Enabled)
            {
               this.mBackButton.enable();
            }
         }
      }
      
      protected function getPagesFormat(param1:int = -1) : Array
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(param1 <= 0)
         {
            return null;
         }
         _loc2_ = new Array(param1);
         _loc3_ = 0;
         while(_loc3_ < param1)
         {
            _loc2_[_loc3_] = this.PAGE_TYPE_TEXT;
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function onBack(param1:MouseEvent) : void
      {
         if(this.mCurrentPage > 0)
         {
            --this.mCurrentPage;
            this.updateText(false);
            if(this.mCurrentPage == 0)
            {
               this.mBackButton.disable();
            }
            if(!this.mNextButton.Enabled)
            {
               this.mNextButton.enable();
            }
         }
      }
      
      protected function getImagesArray() : Array
      {
         return null;
      }
      
      override public function showPopup() : void
      {
         super.show();
         mCancelButton.start();
         mCancelButton.addEventListener(MouseEvent.CLICK,onClose);
         this.mNextButton.start();
         this.mNextButton.addEventListener(MouseEvent.CLICK,this.onNext);
         this.mBackButton.start();
         this.mBackButton.addEventListener(MouseEvent.CLICK,this.onBack);
         startShow();
         this.mCurrentPage = 0;
         this.mCurrentImageIndex = -1;
         this.updateText();
         this.mBackButton.disable();
         this.mNextButton.enable();
      }
      
      override protected function close() : void
      {
         super.close();
         mCancelButton.end();
         mCancelButton.removeEventListener(MouseEvent.CLICK,onClose);
         this.mNextButton.end();
         this.mNextButton.removeEventListener(MouseEvent.CLICK,this.onNext);
         this.mBackButton.end();
         this.mBackButton.removeEventListener(MouseEvent.CLICK,this.onBack);
         DollarsGame.smInstance.mPopupClip.removeChild(mBox);
      }
   }
}

