package com.dchoc.dollars.friends
{
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   
   public class FriendsBarContent extends EventDispatcher
   {
      
      protected var mNeighborObject:NeighborObject;
      
      protected var mEnabled:Boolean;
      
      protected var mIsLoadComplete:Boolean;
      
      protected var mRank:int;
      
      protected var mBox:Sprite;
      
      public function FriendsBarContent()
      {
         super();
         this.mEnabled = true;
         this.setIsLoadComplete(false);
      }
      
      public function getRank() : int
      {
         return this.mRank;
      }
      
      public function loadFriend(param1:NeighborObject, param2:int) : void
      {
         this.mRank = param2;
      }
      
      public function getNeighborObject() : NeighborObject
      {
         return this.mNeighborObject;
      }
      
      public function isLoadComplete() : Boolean
      {
         return this.mIsLoadComplete;
      }
      
      public function setIsLoadComplete(param1:Boolean) : void
      {
         this.mIsLoadComplete = param1;
      }
      
      public function getBox() : Sprite
      {
         return this.mBox;
      }
      
      public function loadImage() : void
      {
      }
      
      public function removeImage() : void
      {
      }
      
      public function destroy() : void
      {
         this.setIsLoadComplete(false);
      }
      
      public function updateExp() : void
      {
      }
      
      public function updateCompanyValue() : void
      {
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         this.mEnabled = param1;
      }
   }
}

