package com.dchoc.dollars.world
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.profile.*;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   
   public class Universe
   {
      
      private var mCurrentWorldID:int;
      
      private var mOwner:int;
      
      private var mWorldsPersistence:Array;
      
      private var mPersistence:XML;
      
      private var mRoleID:int;
      
      public function Universe()
      {
         super();
         this.load();
      }
      
      public function getWorldPersistence(param1:int) : XML
      {
         return this.mWorldsPersistence[param1];
      }
      
      public function set currentWorldID(param1:int) : void
      {
         this.mCurrentWorldID = param1;
      }
      
      public function get owner() : int
      {
         return this.mOwner;
      }
      
      private function load() : void
      {
         this.mWorldsPersistence = new Array();
      }
      
      public function set roleID(param1:int) : void
      {
         this.mRoleID = param1;
      }
      
      public function getPersistence(param1:Boolean = false) : XML
      {
         var _loc5_:XML = null;
         var _loc6_:XML = null;
         this.mPersistence = <Universe/>;
         var _loc2_:Profile = DollarsGame.getProfile();
         this.mPersistence.appendChild(_loc2_.getPersistence());
         var _loc3_:int = int(this.mWorldsPersistence.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc4_ == this.mCurrentWorldID)
            {
               _loc6_ = DollarsGame.getCurrentWorld().getPersistence();
            }
            else
            {
               _loc6_ = this.getWorldPersistence(_loc4_);
            }
            this.mPersistence.appendChild(_loc6_);
            _loc4_++;
         }
         this.mWorldsPersistence.splice(0,this.mWorldsPersistence.length);
         for each(_loc5_ in this.mPersistence.World)
         {
            this.mWorldsPersistence.push(_loc5_);
         }
         return this.mPersistence;
      }
      
      public function get currentWorldID() : int
      {
         return this.mCurrentWorldID;
      }
      
      public function set owner(param1:int) : void
      {
         this.mOwner = param1;
      }
      
      public function read() : void
      {
         var _loc3_:XML = null;
         var _loc1_:UserDataFacade = UserDataFacade.getInstance();
         this.mPersistence = _loc1_.getFileXML(UserDataFacade.TAG_UNIVERSE);
         _loc1_.timerSetTimeAtGetUniverse();
         if(Config.EDIT_MODE && "@role" in this.mPersistence)
         {
            this.mRoleID = parseInt(this.mPersistence.@role);
         }
         var _loc2_:int = int(this.mWorldsPersistence.length);
         if(_loc2_ > 0)
         {
            this.mWorldsPersistence.splice(0,_loc2_);
         }
         for each(_loc3_ in this.mPersistence.World)
         {
            this.mWorldsPersistence.push(_loc3_);
         }
         this.mCurrentWorldID = 0;
      }
      
      public function get roleID() : int
      {
         return this.mRoleID;
      }
      
      public function destroy() : void
      {
         this.mWorldsPersistence = null;
      }
      
      public function getProfilePersistence() : XML
      {
         return XMLUtil.XMLListToXML(this.mPersistence.Profile);
      }
   }
}

