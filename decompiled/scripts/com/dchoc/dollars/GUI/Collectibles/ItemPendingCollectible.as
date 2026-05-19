package com.dchoc.dollars.GUI.Collectibles
{
   import com.dchoc.dollars.collectibles.CollectibleDefinition;
   import com.dchoc.dollars.collectibles.CollectibleObject;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class ItemPendingCollectible extends Sprite
   {
      
      protected var mPhoto:Sprite;
      
      private var mCollectibleImage:MovieClip;
      
      private var mLoadCompleted:Boolean;
      
      private var mMark:MovieClip;
      
      private var mLoadingImage:Boolean;
      
      protected var mBox:Sprite;
      
      private var mLoader:Loader;
      
      protected var mFriendId:String;
      
      private var mFriend:FriendObject;
      
      protected var mCollectibleObject:CollectibleObject;
      
      protected var mTitle:TextField;
      
      private var mImage:Bitmap;
      
      public function ItemPendingCollectible(param1:CollectibleObject, param2:String)
      {
         var _loc3_:Sprite = null;
         var _loc5_:String = null;
         super();
         this.mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"Reward_friend_gift"))();
         addChild(this.mBox);
         this.mFriendId = param2;
         this.mMark = this.mBox.getChildByName("reward_mark") as MovieClip;
         this.mFriend = FriendsManager.getFriendByID(param2);
         this.loadImage();
         this.mCollectibleObject = param1;
         _loc3_ = this.mBox.getChildByName("gift") as Sprite;
         this.mTitle = this.mBox.getChildByName("text") as TextField;
         this.mPhoto = this.mBox.getChildByName("photo") as Sprite;
         this.mCollectibleImage = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.COLLECTABLES_SWF,"button_gift_new"))();
         this.mCollectibleImage.x = this.mMark.x - 10;
         this.mCollectibleImage.y = this.mMark.y;
         this.mBox.addChild(this.mCollectibleImage);
         this.mBox.removeChild(_loc3_);
         TextManager.reformatTextField(this.mTitle);
         var _loc4_:CollectibleDefinition = this.mCollectibleObject.getCollectibleDefinition();
         if(_loc4_ == null)
         {
            this.mTitle.text = "";
         }
         else
         {
            if(this.mFriend)
            {
               _loc5_ = this.mFriend.nameFriend;
            }
            else
            {
               _loc5_ = "";
            }
            this.mTitle.text = TextManager.replaceParameters(TextIDs.TID_COLLECTIBLES_GIFT_POST_TITLE,new Array(_loc5_));
         }
         TextManager.setTextScaled(this.mTitle);
         this.mTitle.y += (this.mTitle.height - this.mTitle.textHeight) / 2;
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
      
      public function getCollectibleObject() : CollectibleObject
      {
         return this.mCollectibleObject;
      }
      
      public function getSenderId() : String
      {
         return this.mFriendId;
      }
      
      public function destroy() : void
      {
         this.mTitle = null;
      }
   }
}

