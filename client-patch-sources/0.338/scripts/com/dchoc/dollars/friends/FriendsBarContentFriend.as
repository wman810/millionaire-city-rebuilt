package com.dchoc.dollars.friends
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.ui.Mouse;
   
   public class FriendsBarContentFriend extends FriendsBarContent
   {
      
      public static const TYPE_MYSELF:int = 0;
      
      public static const TYPE_PARTNER:int = 1;
      
      public static const TYPE_NORMAL:int = 2;
      
      private var mNeighborObject:NeighborObject;
      
      private var mImage:Bitmap;

      private var mImageLoader:Loader;

      private var mLoadedUrl:String;
      
      private var mCurrentCursor:int;
      
      private var mColorTransform:ColorTransform;
      
      private var mFriendPhoto:Sprite;
      
      private var mNameField:TextField;
      
      private var mLevelField:TextField;
      
      private var mMoneyField:TextField;
      
      private var mPositionField:TextField;
      
      private var mIsLoadingImage:Boolean;
      
      private var isOver:Boolean;
      
      public function FriendsBarContentFriend(type:int)
      {
         super();
         switch(type)
         {
            case TYPE_MYSELF:
               mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box_yourself"))();
               break;
            case TYPE_PARTNER:
               mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box_partner"))();
               break;
            default:
               mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"hud_friend_box"))();
         }
         this.mNameField = mBox.getChildByName("Name") as TextField;
         TextManager.reformatTextField(this.mNameField);
         this.mLevelField = mBox.getChildByName("ExLevel") as TextField;
         this.mMoneyField = mBox.getChildByName("Dollars") as TextField;
         this.mPositionField = TextField(mBox.getChildByName("position"));
         this.mFriendPhoto = mBox.getChildByName("photo") as Sprite;
         this.mFriendPhoto.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.mFriendPhoto.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.mFriendPhoto.mouseChildren = false;
         this.mColorTransform = this.mFriendPhoto.transform.colorTransform;
         mBox.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         mBox.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         mBox.addEventListener(MouseEvent.CLICK,this.onVisit);
         mBox.buttonMode = true;
      }
      
      public function loadFriend(friendObject:NeighborObject, rankPos:int) : void
      {
         var pos2:Sprite = null;
         this.mNeighborObject = friendObject;
         this.mNameField.text = this.mNeighborObject.nameFriend;
         this.mLevelField.text = "" + this.calculateLevel(this.mNeighborObject.exp);
         this.mMoneyField.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberRanking(this.mNeighborObject.companyValue);
         this.mPositionField.text = "" + rankPos;
         var pos1:Sprite = mBox.getChildByName("position_1") as Sprite;
         pos2 = mBox.getChildByName("position_2") as Sprite;
         var pos3:Sprite = mBox.getChildByName("position_3") as Sprite;
         if(rankPos == 1)
         {
            pos2.visible = false;
            pos3.visible = false;
         }
         else if(rankPos == 2)
         {
            pos1.visible = false;
            pos3.visible = false;
         }
         else if(rankPos == 3)
         {
            pos1.visible = false;
            pos2.visible = false;
         }
         else
         {
            pos1.visible = false;
            pos2.visible = false;
            pos3.visible = false;
         }
      }
      
      override public function loadImage() : void
      {
         var loader:Loader = null;
         var request:URLRequest = null;
         var loaderContext:LoaderContext = null;
         var pictureUrl:String = this.mNeighborObject == null ? null : this.mNeighborObject.url;
         if(this.mImageLoader != null && this.mLoadedUrl != pictureUrl)
         {
            this.removeImage();
         }
         if(this.mImageLoader == null && !this.mIsLoadingImage)
         {
            if(pictureUrl != null)
            {
               loader = new Loader();
               this.mImageLoader = loader;
               this.mLoadedUrl = pictureUrl;
               request = new URLRequest(pictureUrl);
               loaderContext = null;
               loaderContext = new LoaderContext();
               loaderContext.checkPolicyFile = false;
               loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.setImage);
               loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onErrorLoad);
               this.mIsLoadingImage = true;
               try
               {
                  loader.load(request,loaderContext);
               }
               catch(error:Error)
               {
                  this.disposeImageLoader(loader);
               }
            }
         }
      }
      
      private function onErrorLoad(e:IOErrorEvent) : void
      {
         var loader:Loader = Loader(e.target.loader);
         if(loader != this.mImageLoader)
         {
            this.disposeImageLoader(loader);
            return;
         }
         this.disposeImageLoader(loader);
         this.mColorTransform = this.mFriendPhoto.transform.colorTransform;
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("Error loading Image");
         }
      }
      
      private function setImage(e:Event) : void
      {
         var loader:Loader = null;
         var scale:Number = NaN;
         if(e != null)
         {
            loader = e.target.loader as Loader;
            if(loader != this.mImageLoader)
            {
               this.disposeImageLoader(loader);
               return;
            }
            scale = Math.min(Math.min(50,loader.width),Math.min(50,loader.height));
            loader.width = scale;
            loader.height = scale;
            this.mFriendPhoto.addChildAt(loader,1);
         }
         this.mIsLoadingImage = false;
         this.mColorTransform = this.mFriendPhoto.transform.colorTransform;
         if(e != null)
         {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.setImage);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onErrorLoad);
         }
      }
      
      override public function removeImage() : void
      {
         if(this.mImageLoader != null)
         {
            this.disposeImageLoader(this.mImageLoader);
         }
         if(this.mImage != null)
         {
            this.mFriendPhoto.removeChild(this.mImage);
            this.mImage.bitmapData.dispose();
            this.mImage = null;
         }
         this.mIsLoadingImage = false;
      }

      private function disposeImageLoader(loader:Loader) : void
      {
         if(loader == null)
         {
            return;
         }
         loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.setImage);
         loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onErrorLoad);
         try
         {
            loader.close();
         }
         catch(closeError:Error)
         {
         }
         if(loader.parent == this.mFriendPhoto)
         {
            this.mFriendPhoto.removeChild(loader);
         }
         try
         {
            loader.unload();
         }
         catch(unloadError:Error)
         {
         }
         if(loader == this.mImageLoader)
         {
            this.mImageLoader = null;
            this.mLoadedUrl = null;
            this.mIsLoadingImage = false;
         }
      }
      
      private function calculateLevel(xp:int) : int
      {
         for(var level:int = 0; level < RulesFacade.maxLevel; level++)
         {
            if(xp < RulesFacade.getLevelXP(level))
            {
               return level;
            }
         }
         return 1;
      }
      
      private function onVisit(e:MouseEvent) : void
      {
         DollarsGame.visitUniverse(this.mNeighborObject.userId);
      }
      
      private function onMouseOver(e:MouseEvent = null) : void
      {
         if(!this.isOver)
         {
            Mouse.show();
            this.mCurrentCursor = Dollars.getCurrentCursor().mCurrentCursorID;
            Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
            this.mFriendPhoto.transform.colorTransform = FiltersManager.setInk(this.mColorTransform,16777215,0.5);
            this.isOver = true;
         }
      }
      
      private function onMouseOut(e:MouseEvent = null) : void
      {
         if(this.isOver)
         {
            Mouse.hide();
            Dollars.getCurrentCursor().changeCursor(this.mCurrentCursor);
            this.mFriendPhoto.transform.colorTransform = this.mColorTransform;
            this.isOver = false;
         }
      }
      
      override public function updateCompanyValue() : void
      {
         var coinsBox:TextField = mBox.getChildByName("Dollars") as TextField;
         coinsBox.text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberRanking(this.mNeighborObject.companyValue);
      }
      
      override public function updateExp() : void
      {
         var levelBox:TextField = mBox.getChildByName("ExLevel") as TextField;
         if(this.mNameField != null && this.mNeighborObject != null)
         {
            this.mNameField.text = this.mNeighborObject.nameFriend;
         }
         levelBox.text = "" + this.calculateLevel(this.mNeighborObject.exp);
      }
   }
}

