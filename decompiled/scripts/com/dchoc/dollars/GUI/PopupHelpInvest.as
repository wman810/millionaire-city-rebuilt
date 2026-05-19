package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.invests.InvestObject;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class PopupHelpInvest extends PopupHelp
   {
      
      public function PopupHelpInvest()
      {
         super();
         var _loc1_:Sprite = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"help_text"))();
         mTextBox = _loc1_.getChildAt(0) as TextField;
         TextManager.reformatTextField(mTextBox);
         mImageBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"help_image_text"))();
         mImage = mImageBox.getChildByName("image") as MovieClip;
         mBox.addChild(mTextBox);
         mBox.addChild(mImageBox);
      }
      
      private function createImages() : Array
      {
         var _loc4_:FriendObject = null;
         var _loc5_:InvestFriendInvestor = null;
         var _loc6_:Bitmap = null;
         var _loc7_:BitmapData = null;
         var _loc8_:Number = NaN;
         var _loc1_:Array = InvestManager.getInstance().getInvestmentsHelpUI();
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            _loc4_ = FriendsManager.getFriendByID(_loc1_[_loc3_].getExtId());
            _loc5_ = new InvestFriendInvestor(_loc1_[_loc3_],_loc4_);
            _loc6_ = new Bitmap();
            _loc7_ = new BitmapData(_loc5_.width,_loc5_.height);
            _loc8_ = 0.8;
            _loc5_.scaleX = _loc8_;
            _loc5_.scaleY = _loc8_;
            _loc5_.cacheAsBitmap = true;
            _loc7_.draw(_loc5_);
            _loc6_.bitmapData = _loc7_;
            _loc6_.smoothing = true;
            _loc2_.push(_loc6_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      override protected function getImagesArray() : Array
      {
         var _loc1_:Array = this.createImages();
         var _loc2_:Array = new Array(_loc1_.length);
         _loc2_[0] = _loc1_[InvestObject.STATE_WAITING];
         _loc2_[1] = _loc1_[InvestObject.STATE_EXPIRED];
         _loc2_[2] = _loc1_[InvestObject.STATE_RUNNING];
         _loc2_[3] = _loc1_[InvestObject.STATE_DONE];
         return _loc2_;
      }
      
      override protected function getPagesFormat(param1:int = -1) : Array
      {
         return new Array(PAGE_TYPE_TEXT,PAGE_TYPE_IMAGE,PAGE_TYPE_IMAGE,PAGE_TYPE_IMAGE,PAGE_TYPE_IMAGE);
      }
      
      override protected function getTitleId() : int
      {
         return TextIDs.TID_INVEST_HELP_TITLE;
      }
      
      override protected function getTextId() : int
      {
         return TextIDs.TID_INVEST_HELP1;
      }
   }
}

