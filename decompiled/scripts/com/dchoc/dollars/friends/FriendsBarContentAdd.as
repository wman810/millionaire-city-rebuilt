package com.dchoc.dollars.friends
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.ui.Mouse;
   
   public class FriendsBarContentAdd extends FriendsBarContent
   {
      
      private var mCurrentCursor:int;
      
      private var mColorTransform:ColorTransform;
      
      public function FriendsBarContentAdd()
      {
         super();
         mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box_add_friend"))();
         mBox.addEventListener(MouseEvent.CLICK,this.onAddFriends);
         mBox.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         mBox.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.mColorTransform = mBox.transform.colorTransform;
         mBox.buttonMode = true;
         mBox.mouseChildren = false;
         var _loc1_:TextField = TextField(mBox.getChildByName("Name"));
         TextManager.reformatTextField(_loc1_);
         _loc1_.text = TextManager.getText(TextIDs.TID_BUTTON_TEXT_ADDNEIGHBORS);
         TextManager.setTextScaled(_loc1_,false);
      }
      
      private function onMouseOver(param1:MouseEvent = null) : void
      {
         Mouse.show();
         this.mCurrentCursor = Dollars.getCurrentCursor().mCurrentCursorID;
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
         mBox.transform.colorTransform = FiltersManager.setInk(this.mColorTransform,16777215,0.5);
      }
      
      private function onAddFriends(param1:MouseEvent) : void
      {
         if(Config.USE_NEIGHBOR_REQUESTS)
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_NEIGHBOR_REQUEST,{});
         }
         else
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_HELP_INVITE_FRIEND);
         }
      }
      
      private function onMouseOut(param1:MouseEvent = null) : void
      {
         Mouse.hide();
         Dollars.getCurrentCursor().changeCursor(this.mCurrentCursor);
         mBox.transform.colorTransform = this.mColorTransform;
      }
   }
}

