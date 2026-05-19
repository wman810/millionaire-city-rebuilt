package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class PopupConnection extends Popup
   {
      
      public static const TYPE_CONNECTION:int = 0;
      
      public static const TYPE_GAME_PLAY_CONNECTION:int = 1;
      
      private var mButtonOk:DynamicButton;
      
      public function PopupConnection(param1:int)
      {
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         if(param1 == TYPE_CONNECTION)
         {
            mBox = new AssetManager.PopupConnection();
         }
         else
         {
            mBox = new AssetManager.PopupGamePlayConnection();
            this.mButtonOk = new DynamicButton(mBox.getChildByName("OkButton") as MovieClip);
            mBox.addChild(this.mButtonOk.getButtonMc());
            _loc2_ = Sprite(mBox.getChildByName("plots_info"));
            _loc3_ = Sprite(mBox.getChildByName("locked"));
            _loc2_.visible = false;
            _loc3_.visible = false;
         }
         mTextBox = mBox.getChildByName("TextInfo_01") as TextField;
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
            mBox.removeChild(this.mButtonOk.getButtonMc());
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
         startShow();
         if(this.mButtonOk != null)
         {
            this.mButtonOk.start();
            this.mButtonOk.addEventListener(MouseEvent.CLICK,this.onOk);
         }
      }
   }
}

