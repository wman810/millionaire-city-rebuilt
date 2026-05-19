package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.GUI.PopupHelp;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class PopupHelpCollectibles extends PopupHelp
   {
      
      public static const STATE_PREV:int = 0;
      
      public static const STATE_FINAL:int = 1;
      
      private var mState:int;
      
      private var mListImages:MovieClip;
      
      public function PopupHelpCollectibles(param1:int)
      {
         super();
         this.mState = param1;
         var _loc2_:Sprite = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"help_text"))();
         mTextBox = _loc2_.getChildAt(0) as TextField;
         TextManager.reformatTextField(mTextBox);
         mImageBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"help_image_text"))() as Sprite;
         mImage = mImageBox.getChildByName("pruebaparaluismi") as MovieClip;
         this.mListImages = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"pruebaparaluismi_02"))() as MovieClip;
         this.mListImages.x = mImage.x;
         this.mListImages.y = mImage.y;
         mImageBox.removeChild(mImage);
         mBox.addChild(mTextBox);
         mBox.addChild(mImageBox);
         switch(this.mState)
         {
            case STATE_FINAL:
               mBox.addChild(this.mListImages);
         }
      }
      
      override protected function getPagesFormat(param1:int = -1) : Array
      {
         switch(this.mState)
         {
            case STATE_PREV:
               return new Array(PAGE_TYPE_TEXT,PAGE_TYPE_TEXT,PAGE_TYPE_TEXT,PAGE_TYPE_TEXT);
            case STATE_FINAL:
               return new Array(PAGE_TYPE_IMAGE,PAGE_TYPE_IMAGE,PAGE_TYPE_IMAGE,PAGE_TYPE_IMAGE);
            default:
               return new Array();
         }
      }
      
      override protected function getTitleId() : int
      {
         return TextIDs.TID_INVEST_HELP_TITLE;
      }
      
      override protected function getTextId() : int
      {
         if(this.mState == STATE_FINAL)
         {
            return TextIDs.TID_COLLECTIBLES_HELP1;
         }
         return TextIDs.TID_COLLECTIBLES_HELP1;
      }
      
      override protected function updateText(param1:Boolean = true) : void
      {
         var _loc3_:TextField = null;
         var _loc2_:TextField = TextField(mBox.getChildByName("Step"));
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.replaceParameters(TextIDs.TID_TUTORIAL_STEP,new Array("" + (mCurrentPage + 1),"" + mMaxPages));
         TextManager.setTextScaled(_loc2_);
         if(mPageFormat[mCurrentPage] == PAGE_TYPE_TEXT)
         {
            if(mImageBox)
            {
               mImageBox.visible = false;
            }
            mTextBox.visible = true;
            mTextBox.text = TextManager.getText(this.getTextId() + mCurrentPage);
            if(!param1 && mPageFormat[mCurrentPage + 1] == PAGE_TYPE_IMAGE)
            {
               --mCurrentImageIndex;
            }
         }
         else
         {
            if(mImageBox)
            {
               mImageBox.visible = true;
            }
            mTextBox.visible = false;
            if(param1)
            {
               ++mCurrentImageIndex;
            }
            else
            {
               --mCurrentImageIndex;
            }
            if(mImageBox)
            {
               _loc3_ = TextField(mImageBox.getChildByName("TextInfo_01"));
               TextManager.reformatTextField(_loc3_);
               TextField(_loc3_).text = TextManager.getText(this.getTextId() + mCurrentPage);
               TextManager.setTextScaled(_loc3_);
            }
            if(this.mListImages)
            {
               this.mListImages.gotoAndStop(mCurrentImageIndex);
            }
         }
      }
   }
}

