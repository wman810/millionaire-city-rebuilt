package com.dchoc.dollars.rewards
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.text.TextManager;
   
   public class RewardTypeDefinition extends Definition
   {
      
      private const TID_NEWS_FEED_POST_POPUP_OFF:int = 1;
      
      private var mClickSoundFx:String;
      
      public function RewardTypeDefinition(param1:uint)
      {
         super(param1);
      }
      
      override public function getTidsCount() : int
      {
         return 2;
      }
      
      public function getNewsFeedPostPopupText() : String
      {
         return TextManager.getText(tid + this.TID_NEWS_FEED_POST_POPUP_OFF);
      }
      
      public function setClickSoundFx(param1:String) : void
      {
         this.mClickSoundFx = param1;
      }
      
      public function getClickSoundFx() : String
      {
         return this.mClickSoundFx;
      }
   }
}

