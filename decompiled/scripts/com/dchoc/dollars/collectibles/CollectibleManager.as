package com.dchoc.dollars.collectibles
{
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleGroupComplete;
   import com.dchoc.dollars.GUI.Collectibles.PopupCollectibleManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.dollars.world.items.states.StateOnRent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class CollectibleManager extends EventDispatcher
   {
      
      private static var smAllowed:Boolean;
      
      private static var smInstance:CollectibleManager;
      
      public static const EVENT_COLLECTIBLE_GROUP_COMPLETE:String = "EventCollectibleGroupComplete";
      
      private var mCollectiblePendingList:Dictionary;
      
      private var mCollectibleGroupsByCollectible:Dictionary;
      
      private var mCollectibleGroupsByGroup:Dictionary;
      
      private var mCollectibleGroupInfluences:Dictionary;
      
      private var mCollectibleGroupByReward:Dictionary;
      
      public function CollectibleManager()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: CollectibleManager Error: Instantiation failed: Use CollectibleManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : CollectibleManager
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new CollectibleManager();
            smAllowed = false;
         }
         return smInstance;
      }
      
      public function areCollectibleAllowed() : Boolean
      {
         return DollarsGame.getProfile().level >= RulesFacade.getInstance().settingsGetCollectiblesUnlockLevel();
      }
      
      public function getCollectibleGroups() : Dictionary
      {
         return this.mCollectibleGroupsByGroup;
      }
      
      public function getPendingCollectibleSku(param1:String) : String
      {
         return this.mCollectiblePendingList[param1];
      }
      
      public function sellItem(param1:String) : Number
      {
         var _loc2_:CollectibleObject = this.getCollectibleBySku(param1);
         DollarsGame.getCurrentWorld().getCompanyMine().DCCoins = DollarsGame.getCurrentWorld().getCompanyMine().DCCoins + _loc2_.getCollectibleDefinition().priceCoins;
         return _loc2_.getCollectibleDefinition().priceCoins;
      }
      
      private function showPopupComplete(param1:Event) : void
      {
         var _loc2_:CollectibleGroupObject = param1.target as CollectibleGroupObject;
         if(!_loc2_.getCollectibleGroupDefinition().getCanbeReclaimed())
         {
            _loc2_.removeEventListener(EVENT_COLLECTIBLE_GROUP_COMPLETE,this.showPopupComplete);
         }
         PopupCollectibleManager.getInstance().smPopupCollectibleGroupComplete = new PopupCollectibleGroupComplete(_loc2_);
         PopupCollectibleManager.getInstance().smPopupCollectibleGroupComplete.showPopup();
      }
      
      public function sortCompareOrderInShop(param1:CollectibleGroupObject, param2:CollectibleGroupObject) : int
      {
         var _loc3_:int = param1.getCollectibleGroupDefinition().order;
         var _loc4_:int = param2.getCollectibleGroupDefinition().order;
         var _loc5_:int = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ < _loc4_)
         {
            _loc5_ = -1;
         }
         else if(_loc3_ == _loc4_)
         {
            _loc5_ = 0;
         }
         return _loc5_;
      }
      
      public function getCollectibleGroupByGroupSku(param1:String) : CollectibleGroupObject
      {
         return this.mCollectibleGroupsByGroup[param1];
      }
      
      public function removeCollectibleFromPending(param1:String) : void
      {
         this.mCollectiblePendingList[param1] = null;
      }
      
      public function keepCollectibleTask(param1:ItemObject, param2:String = "") : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc3_:String = this.getPendingCollectibleSku(param1.mSid);
         var _loc4_:Object = UserDataFacade.securityCreateObj(0,0,0);
         if(param1 == null)
         {
            _loc5_ = "f" + param2;
         }
         else
         {
            _loc5_ = param1.mSid;
            this.removeCollectibleFromPending(_loc5_);
            if(Config.COLLECTIBLE_COMMERCES_FEATURE)
            {
               _loc6_ = param1.itemDefinition.isACommerce() ? StateOnRent.CMD_COMMERCE_COLLECTIBLE_GOTTEN : StateOnRent.CMD_COLLECTIBLE_GOTTEN;
            }
            else
            {
               _loc6_ = StateOnRent.CMD_COLLECTIBLE_GOTTEN;
            }
            param1.getCurrentState().eventsProcess({"cmd":_loc6_});
         }
         if(param2 != "-1")
         {
            if(Config.COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED)
            {
               CollectiblePendingManager.getInstance().removePendingCollectible(_loc3_,param2);
            }
         }
         if(this.canCollectibleBeKept(_loc3_))
         {
            UserDataFacade.getInstance().updateCollectible(_loc5_,_loc3_,"KEEP",null,{},_loc4_);
         }
         this.keepCollectible(_loc3_,true);
      }
      
      public function hasPendingCollectible(param1:String) : Boolean
      {
         if(this.mCollectiblePendingList[param1])
         {
            return true;
         }
         return false;
      }
      
      public function getCollectibleBySku(param1:String) : CollectibleObject
      {
         var _loc2_:CollectibleGroupObject = this.mCollectibleGroupsByCollectible[param1] as CollectibleGroupObject;
         if(_loc2_ != null)
         {
            return _loc2_.getCollectibleBySku(param1);
         }
         return null;
      }
      
      private function load() : void
      {
         this.mCollectibleGroupsByCollectible = new Dictionary();
         this.mCollectibleGroupsByGroup = new Dictionary();
         this.mCollectibleGroupByReward = new Dictionary();
         this.mCollectiblePendingList = new Dictionary();
         this.mCollectibleGroupInfluences = new Dictionary();
      }
      
      public function populate() : void
      {
         var _loc3_:CollectibleGroupObject = null;
         var _loc4_:CollectibleGroupDefinition = null;
         var _loc5_:CollectibleDefinition = null;
         var _loc6_:CollectibleObject = null;
         var _loc1_:Array = CollectibleDefinitionManager.getInstance().getDefinitions();
         var _loc2_:Array = CollectibleGroupDefinitionManager.getInstance().getDefinitions();
         for each(_loc4_ in _loc2_)
         {
            _loc3_ = new CollectibleGroupObject(_loc4_);
            this.mCollectibleGroupsByGroup[_loc4_.sku] = _loc3_;
            this.mCollectibleGroupByReward[_loc4_.rewardSku] = _loc3_;
         }
         for each(_loc5_ in _loc1_)
         {
            _loc3_ = this.mCollectibleGroupsByGroup[_loc5_.collectionSku] as CollectibleGroupObject;
            _loc6_ = new CollectibleObject(_loc5_);
            _loc3_.initializeCollectible(_loc6_);
            this.mCollectibleGroupsByCollectible[_loc5_.sku] = _loc3_;
         }
      }
      
      public function giveCollectible(param1:String) : void
      {
         var _loc2_:CollectibleObject = this.getCollectibleBySku(param1);
         _loc2_.setCount(_loc2_.getCount() - 1);
      }
      
      public function canCollectibleBeKept(param1:String) : Boolean
      {
         var _loc2_:CollectibleObject = CollectibleManager.getInstance().getCollectibleBySku(param1);
         var _loc3_:int = _loc2_.getCount();
         return _loc3_ < RulesFacade.getInstance().settingsGetCollectibleMaxUnitsPerItem();
      }
      
      public function wouldThisCollectibleCompleteTheGroup(param1:String) : Boolean
      {
         var _loc2_:CollectibleGroupObject = this.mCollectibleGroupsByCollectible[param1] as CollectibleGroupObject;
         var _loc3_:CollectibleDefinition = CollectibleDefinition(CollectibleDefinitionManager.getInstance().getDefinitionBySku(param1));
         return _loc2_ == null ? false : _loc2_.wouldThisCollectibleCompleteTheGroup(_loc3_);
      }
      
      public function inCollection(param1:String) : Boolean
      {
         var _loc2_:CollectibleGroupObject = this.mCollectibleGroupsByCollectible[param1] as CollectibleGroupObject;
         if(_loc2_ != null)
         {
            return _loc2_.inGroup(param1);
         }
         return false;
      }
      
      public function canCollectibleBeGivenAway(param1:String) : Boolean
      {
         var _loc2_:CollectibleObject = this.getCollectibleBySku(param1);
         if(_loc2_ != null && _loc2_.getCount() > 1)
         {
            return true;
         }
         return false;
      }
      
      public function build() : void
      {
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:CollectibleGroupObject = null;
         var _loc15_:CollectibleGroupObject = null;
         var _loc16_:Array = null;
         var _loc17_:CollectibleObject = null;
         var _loc18_:CollectibleGroupObject = null;
         var _loc19_:Array = null;
         var _loc20_:String = null;
         var _loc21_:String = null;
         var _loc1_:XML = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_COLLECTIBLE_LIST);
         var _loc2_:XMLList = _loc1_.Objects;
         var _loc3_:XMLList = _loc1_.Rewards;
         var _loc4_:XMLList = _loc1_.Pending;
         var _loc5_:String = _loc4_.@tupla;
         var _loc6_:String = _loc2_.@skus;
         var _loc7_:String = _loc3_.@skus;
         var _loc8_:Array = _loc6_.split(",");
         var _loc9_:Array = _loc7_.split(",");
         var _loc10_:Array = _loc5_.split(",");
         for each(_loc11_ in _loc8_)
         {
            if(_loc11_ != "")
            {
               if(_loc11_.indexOf(":") > -1)
               {
                  _loc16_ = _loc11_.split(":");
                  if(_loc16_[1] != "0")
                  {
                     _loc15_ = this.mCollectibleGroupsByCollectible[_loc16_[0] as String] as CollectibleGroupObject;
                     if(_loc15_ != null)
                     {
                        _loc17_ = _loc15_.getCollectibleBySku(_loc16_[0] as String);
                        _loc17_.setCount(_loc16_[1]);
                        _loc15_.registerCollectible(_loc16_[0]);
                     }
                  }
               }
               else
               {
                  _loc15_ = this.mCollectibleGroupsByCollectible[_loc11_] as CollectibleGroupObject;
                  if(_loc15_ != null)
                  {
                     _loc17_ = _loc15_.getCollectibleBySku(_loc11_);
                     _loc17_.setCount(1);
                     _loc15_.registerCollectible(_loc11_);
                  }
               }
            }
         }
         for each(_loc12_ in _loc9_)
         {
            if(_loc12_ != "")
            {
               _loc18_ = this.mCollectibleGroupsByGroup[_loc12_];
               if(_loc18_ != null)
               {
                  _loc18_.tradeIn();
               }
            }
         }
         for each(_loc13_ in _loc10_)
         {
            if(_loc13_ != "")
            {
               _loc19_ = _loc13_.split(":");
               _loc20_ = _loc19_[0] as String;
               _loc21_ = _loc19_[1] as String;
               this.addCollectibleToPendingList(_loc20_,_loc21_);
            }
         }
         for each(_loc14_ in this.mCollectibleGroupsByGroup)
         {
            _loc14_.addEventListener(EVENT_COLLECTIBLE_GROUP_COMPLETE,this.showPopupComplete);
         }
      }
      
      public function keepCollectible(param1:String, param2:Boolean = false) : void
      {
         var _loc3_:CollectibleGroupObject = this.mCollectibleGroupsByCollectible[param1] as CollectibleGroupObject;
         var _loc4_:Boolean = false;
         if(_loc3_ != null)
         {
            _loc3_.registerCollectible(param1,param2);
            if(_loc3_.isComplete() && _loc3_.getState() == CollectibleGroupObject.STATE_INCOMPLETED)
            {
               if(param2)
               {
                  _loc3_.changeState(CollectibleGroupObject.STATE_PENDING_TO_GET_REWARD);
               }
               _loc3_.dispatchEvent(new Event(EVENT_COLLECTIBLE_GROUP_COMPLETE));
            }
         }
         else if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("############# ERROR in CollectibleManager.keepCollectible(): collectible with sku: " + param1 + " does not belong to any group");
         }
      }
      
      public function getCollectibleGroupsInfluences() : Dictionary
      {
         return this.mCollectibleGroupInfluences;
      }
      
      public function destroy() : void
      {
      }
      
      public function getGroupBySku(param1:String) : CollectibleGroupObject
      {
         return this.mCollectibleGroupsByCollectible[param1] as CollectibleGroupObject;
      }
      
      public function addCollectibleToPendingList(param1:String, param2:String) : void
      {
         if(this.getCollectibleBySku(param2))
         {
            this.mCollectiblePendingList[param1] = param2;
         }
      }
   }
}

