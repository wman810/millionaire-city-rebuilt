package com.dchoc.dollars.model.upgrades
{
   import com.dchoc.dollars.GUI.PopupPartner;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.friends.NeighborObject;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.utils.Dictionary;
   
   public class UpgradesManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:UpgradesManager;
      
      public static const UPGRADE_TYPE_NORMAL:int = 0;
      
      public static const UPGRADE_TYPE_SUPER:int = 1;
      
      public static const UPGRADE_TYPE_COUNT:int = 2;
      
      private var mType:int;
      
      private var mUpgradesPerItem:Dictionary;
      
      private var mSidsToUpgrade:Array;
      
      private var mUpgradesCurrentVisitorCount:int;
      
      private var mPartnersLoaded:Boolean;
      
      private var mPopupShare:PopupPartner;
      
      private var mNeighborObject:NeighborObject;
      
      private var mUpgradesTypePerItem:Dictionary;
      
      public function UpgradesManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: UpgradesManager Error: Instantiation failed: Use UpgradesManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : UpgradesManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new UpgradesManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      private function setUpgradesCurrentVisitorCount(param1:int, param2:Boolean = true) : void
      {
         this.mUpgradesCurrentVisitorCount = param1;
         if(param2)
         {
            DollarsGame.getCurrentRole().toolsBar.setUpgrades(this.mUpgradesCurrentVisitorCount);
         }
      }
      
      public function isItemUpgraded(param1:String) : Boolean
      {
         if(this.mUpgradesPerItem != null)
         {
            return this.mUpgradesPerItem[param1] != null;
         }
         return false;
      }
      
      public function getExpPerUpgrade() : int
      {
         return RulesFacade.getInstance().socialGetUpgradesVisitorExpPerUpgrade(this.mType);
      }
      
      public function sidsToUpgradeGetNextSid() : String
      {
         return this.mSidsToUpgrade != null && this.mSidsToUpgrade.length > 0 ? this.mSidsToUpgrade[0] : null;
      }
      
      private function getUpgradesCurrentVisitorCount() : int
      {
         return this.mUpgradesCurrentVisitorCount;
      }
      
      public function getDCCoinsPerUpgrade() : int
      {
         return RulesFacade.getInstance().socialGetUpgradesVisitorDCCoinsPerUpgrade(this.mType);
      }
      
      public function getExtraPercentage(param1:String) : Number
      {
         var _loc2_:Number = 100;
         if(this.mUpgradesTypePerItem[param1] != null)
         {
            _loc2_ = RulesFacade.getInstance().socialGetUpgradesOwnerExtraPercentage(this.mUpgradesTypePerItem[param1] as int);
         }
         return _loc2_;
      }
      
      private function partnersDestroy() : void
      {
         if(Config.USE_SUPERUPGRADES)
         {
            this.mPartnersLoaded = false;
         }
      }
      
      public function sidsToUpgradeShiftSid() : void
      {
         if(this.mSidsToUpgrade != null && this.mSidsToUpgrade.length > 0)
         {
            this.mSidsToUpgrade.shift();
         }
      }
      
      public function partnersIsPartner(param1:String) : Boolean
      {
         var _loc3_:NeighborObject = null;
         var _loc2_:Boolean = false;
         if(Config.USE_SUPERUPGRADES && this.mPartnersLoaded)
         {
            _loc3_ = FriendsManager.getNeighborByExtID(param1);
            if(_loc3_ != null)
            {
               _loc2_ = _loc3_.isPartner();
            }
            else if(Config.DEBUG_ASSERTS)
            {
               Debug.trace("############# ERROR in UpgradesManager.partnersIsPartner: partner with extId = " + param1 + " is not a neighbor");
            }
         }
         return _loc2_;
      }
      
      public function partnersIsLoaded() : Boolean
      {
         return this.mPartnersLoaded;
      }
      
      public function getNeighborObject() : NeighborObject
      {
         return this.mNeighborObject;
      }
      
      public function getUpgradeType(param1:String) : int
      {
         return this.mUpgradesTypePerItem[param1];
      }
      
      public function isCurrentVisitAPartner() : Boolean
      {
         return this.mNeighborObject != null && this.mNeighborObject.isPartner();
      }
      
      public function load() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         this.mSidsToUpgrade = new Array();
         this.mUpgradesPerItem = new Dictionary();
         this.mUpgradesTypePerItem = new Dictionary();
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_UPGRADES_LIST);
         this.setUpgradesCurrentVisitorCount(_loc1_.@upgradesUniverseAvailable,false);
         for each(_loc2_ in _loc1_.upgrade)
         {
            _loc3_ = _loc2_.@sid;
            _loc4_ = _loc2_.@extId;
            this.addFriendHelper(_loc3_,_loc4_);
         }
      }
      
      public function upgradeItem(param1:ItemObject) : void
      {
         this.setUpgradesCurrentVisitorCount(this.getUpgradesCurrentVisitorCount() - 1);
         if(this.getUpgradesCurrentVisitorCount() == 0 && !this.mNeighborObject.isAdvisor())
         {
            if(this.mPopupShare == null)
            {
               this.mPopupShare = new PopupPartner(PopupPartner.TYPE_SHARE_UPGRADES);
            }
            this.mPopupShare.showPopupParams(this.getNeighborObject());
         }
      }
      
      public function partnersReload() : void
      {
         var _loc1_:XML = null;
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:NeighborObject = null;
         var _loc5_:Number = NaN;
         if(Config.USE_SUPERUPGRADES)
         {
            _loc1_ = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_UPGRADES_PARTNER_LIST);
            if(_loc1_ != null)
            {
               for each(_loc2_ in _loc1_.partner)
               {
                  _loc3_ = _loc2_.@extId;
                  _loc4_ = FriendsManager.getNeighborByExtID(_loc3_);
                  if(_loc4_ != null)
                  {
                     if("@remindTimeLeft" in _loc2_)
                     {
                        _loc5_ = Number(_loc2_.@remindTimeLeft);
                        _loc4_.setSuperUpgradeTimeToAllowRemaining(_loc5_);
                     }
                     else
                     {
                        _loc4_.setIsPartner(true);
                     }
                  }
                  else if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in UpgradesManager.partnersLoad: partner with extId = " + _loc3_ + " is not a neighbor");
                  }
               }
            }
            this.mPartnersLoaded = true;
         }
      }
      
      private function addFriendHelper(param1:String, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Array = this.mUpgradesPerItem[param1] as Array;
         if(_loc3_ == null)
         {
            _loc3_ = new Array();
         }
         _loc3_.push(param2);
         this.mUpgradesPerItem[param1] = _loc3_;
         if(this.mUpgradesTypePerItem[param1] == null || this.mUpgradesTypePerItem[param1] != UPGRADE_TYPE_SUPER)
         {
            _loc4_ = UPGRADE_TYPE_NORMAL;
            if(this.partnersIsPartner(param2))
            {
               _loc4_ = UPGRADE_TYPE_SUPER;
               this.mSidsToUpgrade.push(param1);
            }
            this.mUpgradesTypePerItem[param1] = _loc4_;
         }
      }
      
      public function build() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         this.partnersLoad();
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_UPGRADES_LIST);
         for each(_loc2_ in _loc1_.upgrade)
         {
            _loc3_ = _loc2_.@sid;
            _loc4_ = _loc2_.@extId;
            if(this.partnersIsPartner(_loc4_))
            {
               this.mUpgradesTypePerItem[_loc3_] = UPGRADE_TYPE_SUPER;
               this.mSidsToUpgrade.push(_loc3_);
            }
         }
         this.mSidsToUpgrade.sort(Array.DESCENDING);
      }
      
      public function setNeighborId(param1:int) : void
      {
         var _loc2_:int = UPGRADE_TYPE_NORMAL;
         this.mNeighborObject = FriendsManager.getNeighborByID(param1);
         if(this.mNeighborObject != null)
         {
            if(this.mNeighborObject.isPartner())
            {
               _loc2_ = UPGRADE_TYPE_SUPER;
            }
         }
         else if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("############# ERROR in UpgradesManager.setNeighborID: partner with id = " + param1 + " is not a neighbor");
         }
         this.setType(_loc2_);
         DollarsGame.getCurrentRole().toolsBar.setUpgrades(this.mUpgradesCurrentVisitorCount);
      }
      
      public function getType() : int
      {
         return this.mType;
      }
      
      private function partnersLoad() : void
      {
         var _loc1_:XML = null;
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:NeighborObject = null;
         var _loc5_:Number = NaN;
         if(Config.USE_SUPERUPGRADES && !this.mPartnersLoaded)
         {
            _loc1_ = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_UPGRADES_PARTNER_LIST);
            if(_loc1_ != null)
            {
               for each(_loc2_ in _loc1_.partner)
               {
                  _loc3_ = _loc2_.@extId;
                  _loc4_ = FriendsManager.getNeighborByExtID(_loc3_);
                  if(_loc4_ != null)
                  {
                     if("@remindTimeLeft" in _loc2_)
                     {
                        _loc5_ = Number(_loc2_.@remindTimeLeft);
                        _loc4_.setSuperUpgradeTimeToAllowRemaining(_loc5_);
                     }
                     else
                     {
                        _loc4_.setIsPartner(true);
                     }
                  }
                  else if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("############# ERROR in UpgradesManager.partnersLoad: partner with extId = " + _loc3_ + " is not a neighbor");
                  }
               }
            }
            this.mPartnersLoaded = true;
         }
      }
      
      public function isAnyUpgradeAllowed() : Boolean
      {
         return this.getUpgradesCurrentVisitorCount() > 0;
      }
      
      public function partnersBecomePartner(param1:String) : void
      {
         var _loc2_:NeighborObject = FriendsManager.getNeighborByExtID(param1);
         if(_loc2_ != null)
         {
            if(!_loc2_.isPartner())
            {
               _loc2_.setIsPartner(true);
            }
            else if(Config.DEBUG_ASSERTS)
            {
               Debug.trace("############# ERROR in UpgradesManager.partnersBecomePartner: neighbor with extId = " + param1 + " is already a partner");
            }
         }
         else if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("############# ERROR in UpgradesManager.partnersBecomePartner: neighbor with extId = " + param1 + " doesn\'t exist");
         }
      }
      
      public function destroy() : void
      {
         this.mSidsToUpgrade = null;
         this.mUpgradesTypePerItem = null;
         this.mUpgradesPerItem = null;
      }
      
      public function setType(param1:int) : void
      {
         this.mType = param1;
      }
   }
}

