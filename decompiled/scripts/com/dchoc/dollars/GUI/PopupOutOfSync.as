package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupOutOfSync extends Popup
   {
      
      public static const TYPE_CONNECTION:int = 0;
      
      public static const TYPE_GAME_PLAY_CONNECTION:int = 1;
      
      private var mButtonOk:DynamicButton = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
      
      public function PopupOutOfSync(param1:int = 0)
      {
         mBox = new AssetManager.PopupOutOfSync();
         mTextBox = mBox.getChildByName("text_body") as TextField;
         TextManager.reformatTextField(mTextBox);
         super();
      }
      
      override protected function close() : void
      {
         super.close();
         var _loc1_:DollarsGame = DollarsGame.smInstance;
         _loc1_.mPopupClip.removeChild(mBox);
         _loc1_.mGameClip.mouseChildren = true;
         _loc1_.mGameClip.mouseEnabled = true;
         _loc1_.mShowPopup = false;
         if(this.mButtonOk != null)
         {
            this.mButtonOk.removeEventListener(MouseEvent.CLICK,this.onOk);
            this.mButtonOk.end();
         }
      }
      
      private function onOk(param1:Event) : void
      {
         UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_BROWSER_REFRESH);
      }
      
      public function showPopupParams(param1:String) : void
      {
         super.show();
         var _loc2_:DollarsGame = DollarsGame.smInstance;
         _loc2_.mGameClip.mouseChildren = false;
         _loc2_.mGameClip.mouseEnabled = false;
         mTextBox.text = param1;
         startShow(false);
         if(this.mButtonOk != null)
         {
            this.mButtonOk.start();
            this.mButtonOk.addEventListener(MouseEvent.CLICK,this.onOk);
         }
      }
   }
}

