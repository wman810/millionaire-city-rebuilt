package com.dchoc.dollars.friends
{
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.EventDispatcher;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class FriendObject extends EventDispatcher
   {
      
      public static const EVENT_IMAGE_LOADED:String = "EventImageLoaded";
      
      protected var mUrl:String;
      
      protected var mIsPartner:Boolean;
      
      protected var mUserId:int;
      
      protected var mName:String;
      
      private var mLoader:Loader;
      
      protected var mExtId:String;
      
      protected var mSku:String;
      
      public function FriendObject()
      {
         super();
         this.mIsPartner = false;
      }
      
      public function get userId() : int
      {
         return this.mUserId;
      }
      
      public function getPictureURL() : String
      {
         return this.mUrl;
      }
      
      public function get nameFriend() : String
      {
         return this.mName;
      }
      
      public function set userId(param1:int) : void
      {
         this.mUserId = param1;
      }
      
      public function set nameFriend(param1:String) : void
      {
         this.mName = param1;
      }
      
      public function loadImage() : DisplayObject
      {
         var _loc1_:URLRequest = null;
         var _loc2_:LoaderContext = null;
         if(this.mUrl != null && this.mLoader == null)
         {
            this.mLoader = new Loader();
            _loc1_ = new URLRequest(this.mUrl);
            _loc2_ = new LoaderContext();
            this.mLoader.load(_loc1_,_loc2_);
         }
         return this.mLoader;
      }
      
      public function setPictureURL(param1:String) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:LoaderContext = null;
         if(this.mUrl == param1)
         {
            return;
         }
         this.mUrl = param1;
         if(this.mLoader != null)
         {
            try
            {
               this.mLoader.unload();
            }
            catch(error:Error)
            {
            }
            if(this.mUrl != null)
            {
               _loc2_ = new URLRequest(this.mUrl);
               _loc3_ = new LoaderContext();
               this.mLoader.load(_loc2_,_loc3_);
            }
         }
      }
      
      public function get extId() : String
      {
         return this.mExtId;
      }
      
      public function isMyself() : Boolean
      {
         return this.userId == UserDataFacade.getInstance().mUserId;
      }
      
      public function isRonald() : Boolean
      {
         return this.userId == UserDataFacade.getInstance().mNPCSArray[0];
      }
      
      public function isAdvisor() : Boolean
      {
         return UserDataFacade.getInstance().isNPC(this.userId);
      }
      
      public function set extId(param1:String) : void
      {
         this.mExtId = param1;
         this.setPictureURL(UserDataFacade.getInstance().mSocial.getAPIPictureURL(this.mExtId));
      }
      
      public function destroy() : void
      {
         if(this.mLoader != null)
         {
            this.mLoader.unload();
            this.mLoader = null;
         }
      }
      
      public function setIsPartner(param1:Boolean) : void
      {
         this.mIsPartner = param1;
      }
      
      public function isPartner() : Boolean
      {
         return (this.mIsPartner || this.isAdvisor()) && Config.USE_SUPERUPGRADES;
      }
   }
}

