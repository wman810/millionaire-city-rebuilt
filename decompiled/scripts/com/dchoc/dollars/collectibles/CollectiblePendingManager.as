package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import flash.utils.Dictionary;
   
   public class CollectiblePendingManager
   {
      
      private static var smAllowInstantation:Boolean;
      
      private static var smInstance:CollectiblePendingManager;
      
      private var mKeys:Array;
      
      private var mCollectibleDict:Dictionary;
      
      private var mCollectibleList:Array;
      
      public function CollectiblePendingManager()
      {
         super();
         if(!smAllowInstantation)
         {
            throw new Error("ERROR: CollectiblePendingManager Error: Instantiation failed: Use CollectiblePendingManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : CollectiblePendingManager
      {
         if(!smInstance)
         {
            smAllowInstantation = true;
            smInstance = new CollectiblePendingManager();
            smAllowInstantation = false;
         }
         return smInstance;
      }
      
      private function load() : void
      {
         this.mCollectibleDict = new Dictionary();
         this.mKeys = new Array();
         this.mCollectibleList = new Array();
      }
      
      public function addCollectibleToPending(param1:String, param2:String) : void
      {
         var _loc3_:String = param2 + ":" + param1;
         this.mCollectibleList.push(_loc3_);
      }
      
      public function removePendingCollectible(param1:String, param2:String) : Boolean
      {
         var _loc5_:int = 0;
         var _loc3_:String = param2 + ":" + param1;
         var _loc4_:int = -1;
         while(_loc5_ < this.mCollectibleList.length)
         {
            if(this.mCollectibleList[_loc5_] == _loc3_)
            {
               _loc4_ = _loc5_;
            }
            _loc5_++;
         }
         if(_loc4_ > -1)
         {
            this.mCollectibleList.splice(_loc4_,1);
            return true;
         }
         return false;
      }
      
      public function build() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_COLLECTIBLE_PENDING_LIST);
         for each(_loc2_ in _loc1_.item)
         {
            _loc3_ = _loc2_.@sku;
            if(CollectibleManager.getInstance().getCollectibleBySku(_loc3_))
            {
               _loc4_ = _loc2_.@extId;
               this.addCollectibleToPending(_loc3_,_loc4_);
            }
         }
      }
      
      public function inPendingList(param1:String, param2:String) : Boolean
      {
         var _loc5_:int = 0;
         var _loc3_:String = param2 + ":" + param1;
         var _loc4_:int = -1;
         while(_loc5_ < this.mCollectibleList.length)
         {
            if(this.mCollectibleList[_loc5_] == _loc3_)
            {
               _loc4_ = _loc5_;
            }
            _loc5_++;
         }
         if(_loc4_ > -1)
         {
            return true;
         }
         return false;
      }
      
      public function getPendingCollectibles() : Array
      {
         return this.mCollectibleList;
      }
      
      public function getNumberOfPendingCollectibles() : int
      {
         return this.mCollectibleList.length;
      }
   }
}

