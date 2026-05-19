package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.PopupInvest;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class InvestFriendContent extends Sprite
   {
      
      private var mLoader:Loader;
      
      private var mPhoto:Sprite;
      
      private var mFriend:FriendObject;
      
      private var mImage:Bitmap;
      
      private var mBox:MovieClip;
      
      public function InvestFriendContent(param1:FriendObject)
      {
         super();
         this.mBox = new (DCResourceManager.getInstance().getSWFClass(PopupInvest.SKU,"friend_box"))();
         addChild(this.mBox);
         this.mBox.stop();
         mouseChildren = false;
         buttonMode = true;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.mFriend = param1;
         this.mPhoto = this.mBox.getChildByName("photo") as Sprite;
         var _loc2_:TextField = TextField(this.mBox.getChildByName("FriendName"));
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = this.mFriend.nameFriend;
         TextManager.setTextScaled(_loc2_);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.mBox.gotoAndStop(2);
         scaleX = 1.07;
         scaleY = 1.07;
      }
      
      public function getFriendObject() : FriendObject
      {
         return this.mFriend;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.mBox.gotoAndStop(1);
         scaleX = 1;
         scaleY = 1;
      }
      
      public function loadImage() : void
      {
         var _loc1_:URLRequest = null;
         var _loc2_:LoaderContext = null;
         if(this.mFriend != null && this.mFriend.getPictureURL() != null)
         {
            this.mLoader = new Loader();
            _loc1_ = new URLRequest(this.mFriend.getPictureURL());
            _loc2_ = new LoaderContext();
            this.mLoader.load(_loc1_,_loc2_);
            this.mPhoto.addChild(this.mLoader);
         }
      }
      
      public function removeImage() : void
      {
         if(this.mImage != null)
         {
            if(this.mPhoto.contains(this.mImage))
            {
               this.mPhoto.removeChild(this.mImage);
            }
            this.mImage = null;
            try
            {
               if(this.mLoader != null)
               {
                  this.mLoader.unload();
                  this.mLoader = null;
               }
            }
            catch(e:Error)
            {
               Debug.trace("Error in InvestFriendContent.removeImage(): " + e.message);
            }
         }
      }
      
      public function destroy() : void
      {
         this.mFriend = null;
         this.removeImage();
         if(this.mBox.contains(this.mPhoto))
         {
            this.mBox.removeChild(this.mPhoto);
         }
         this.mPhoto = null;
         removeChild(this.mBox);
         this.mBox = null;
         if(this.mLoader != null)
         {
            this.mLoader.unload();
         }
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
   }
}

