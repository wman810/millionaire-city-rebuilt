package com.dchoc.dollars.missions
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupEmail;
   import com.dchoc.dollars.GUI.PopupMission;
   import com.dchoc.dollars.GUI.PopupMissionUpgrades;
   import com.dchoc.dollars.GUI.PopupName;
   import com.dchoc.dollars.GUI.PopupReward;
   import com.dchoc.dollars.GUI.messages.MessageText;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.GUI.messages.Message;
   import com.dchoc.dollars.utils.GUI.messages.MessageManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import com.dchoc.dollars.world.companies.Company;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class MissionObjectManager extends EventDispatcher
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:MissionObjectManager;
      
      private static const LIST_POSITION_UP:int = 0;
      
      private static const LIST_POSITION_LOCKED:int = 1;
      
      private static const LIST_POSITION_REACHED:int = 2;
      
      private static const LIST_POSITION_GIVEN:int = 3;
      
      private static const LIST_POSITION_COUNT:int = 4;
      
      private static const LIST_UP_ENTRIES_COUNT:int = 6;
      
      private static const LIST_XML:Array = [<Up/>,<Locked/>,<Reached/>,<Given/>];
      
      private var mNeedsToCalculateMissionsLocked:Boolean;
      
      private var mMessageMissionReachedToBeLaunched:Boolean;
      
      private var mRewardPopup:PopupReward;
      
      private var mDescriptionPopup:PopupMission;
      
      private var mMissionsLocked:Array;
      
      private var mMessageMissionReached:Message;
      
      private var mInitMissions:Array;
      
      private var mMissionsDictionary:Dictionary;
      
      private var mInitialized:Boolean;
      
      private var mChangeStateMissionsList:Array;
      
      private var mMissionsByPositionList:Array;
      
      private var mPersistence:XML;
      
      private var mNotifyChangeEnabled:Boolean;
      
      public function MissionObjectManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: MissionObjectManager Error: Instantiation failed: Use MissionObjectManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : MissionObjectManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new MissionObjectManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function getMissionsAll() : Array
      {
         var _loc2_:MissionObject = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.mMissionsDictionary)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      private function sortMissionsLocked(param1:MissionObject, param2:MissionObject) : Number
      {
         var _loc3_:MissionDefinition = param1.missionDefinition;
         var _loc4_:MissionDefinition = param2.missionDefinition;
         var _loc5_:Boolean = _loc3_.hasUnlockSku();
         var _loc6_:Boolean = _loc4_.hasUnlockSku();
         var _loc7_:Number = 0;
         if(_loc5_ && !_loc6_)
         {
            _loc7_ = -1;
         }
         if(_loc6_ && !_loc5_)
         {
            _loc7_ = 1;
         }
         else if(_loc5_ && _loc6_)
         {
            if(_loc3_.unlockSku > _loc4_.unlockSku)
            {
               _loc7_ = 1;
            }
            else if(_loc3_.unlockSku < _loc4_.unlockSku)
            {
               _loc7_ = -1;
            }
            else
            {
               _loc7_ = this.sortMissionBySku(param1,param2);
            }
         }
         else if(_loc3_.unlockLevel > _loc4_.unlockLevel)
         {
            _loc7_ = 1;
         }
         else if(_loc4_.unlockLevel > _loc3_.unlockLevel)
         {
            _loc7_ = -1;
         }
         else
         {
            _loc7_ = this.sortMissionBySku(param1,param2);
         }
         return _loc7_;
      }
      
      private function changeStateMissionsDestroy() : void
      {
         this.mChangeStateMissionsList.splice(0,this.mChangeStateMissionsList.length);
         this.mChangeStateMissionsList = null;
      }
      
      public function closeDescriptionName(param1:Event) : void
      {
         this.mDescriptionPopup.removeEventListener(Popup.EVENT_CLOSE,this.closeDescription);
         if(this.mDescriptionPopup.hasEventListener(Popup.EVENT_ACCEPT))
         {
            this.mDescriptionPopup.removeEventListener(Popup.EVENT_ACCEPT,this.closeDescriptionName);
         }
         this.mDescriptionPopup = null;
      }
      
      private function openReward(param1:MissionObject) : void
      {
         this.mRewardPopup = new PopupReward(param1);
         this.mRewardPopup.addEventListener(Popup.EVENT_CLOSE,this.closeReward);
         DollarsGame.smInstance.mRain.start(DollarsGame.smInstance.mRainClip);
         DollarsGame.smInstance.mRain2.start(DollarsGame.smInstance.mRainClip);
      }
      
      public function getMissionBySku(param1:String) : MissionObject
      {
         return this.mMissionsDictionary[param1];
      }
      
      private function sortMissionsBySku(param1:MissionObject, param2:MissionObject) : Number
      {
         var _loc3_:String = param1.missionDefinition.sku;
         var _loc4_:String = param2.missionDefinition.sku;
         var _loc5_:Number = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc3_ < _loc4_)
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      private function initMissionsAddMission(param1:MissionObject) : void
      {
         this.mInitMissions.push(param1);
      }
      
      public function changeStateMissionsApplyMission(param1:MissionObject, param2:int, param3:int) : void
      {
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:MissionObject = null;
         var _loc14_:int = 0;
         var _loc15_:Object = null;
         var _loc16_:int = 0;
         var _loc17_:Company = null;
         var _loc4_:int = this.getListPosition(param2);
         var _loc5_:int = this.getListPosition(param3);
         var _loc6_:Boolean = false;
         if(_loc4_ != _loc5_)
         {
            _loc7_ = int(this.mMissionsByPositionList[_loc4_].indexOf(param1));
            if(_loc7_ > -1)
            {
               this.mMissionsByPositionList[_loc4_].splice(_loc7_,1);
               if(_loc5_ == LIST_POSITION_UP)
               {
                  if(param1.missionDefinition.needsToBeInitialized())
                  {
                     this.initMissionsAddMission(param1);
                  }
               }
               _loc6_ = true;
               if(param2 == MissionObject.STATE_LOCKED && param1.unlockMission != null)
               {
                  _loc8_ = this.mMissionsByPositionList[_loc5_];
                  _loc9_ = int(_loc8_.length);
                  _loc10_ = -1;
                  _loc11_ = parseInt(param1.missionDefinition.sku);
                  if(_loc9_ > LIST_UP_ENTRIES_COUNT)
                  {
                     _loc12_ = LIST_UP_ENTRIES_COUNT;
                     while(_loc12_ < _loc9_ && _loc10_ == -1)
                     {
                        _loc13_ = _loc8_[_loc12_] as MissionObject;
                        _loc14_ = parseInt(_loc13_.missionDefinition.sku);
                        if(_loc14_ > _loc11_)
                        {
                           _loc10_ = _loc12_;
                        }
                        _loc12_++;
                     }
                     _loc6_ = _loc10_ == -1;
                     if(!_loc6_)
                     {
                        _loc8_.splice(_loc10_,0,param1);
                     }
                  }
               }
               if(_loc6_)
               {
                  this.mMissionsByPositionList[_loc5_].push(param1);
               }
            }
         }
         if(param3 == MissionObject.STATE_REACHED || param3 == MissionObject.STATE_UNLOCKED)
         {
            _loc7_ = int(this.mMissionsByPositionList[_loc5_].indexOf(param1));
            if(param3 == MissionObject.STATE_REACHED)
            {
               if(this.mInitialized && this.mRewardPopup == null)
               {
                  this.openReward(param1);
               }
            }
            else
            {
               this.mNeedsToCalculateMissionsLocked = true;
               if(this.mInitialized)
               {
                  this.notifyChange();
               }
            }
         }
         if(param2 == MissionObject.STATE_LOCKED || _loc6_)
         {
            _loc15_ = null;
            if(param3 == MissionObject.STATE_GIVEN)
            {
               _loc17_ = DollarsGame.getCurrentWorld().getCompanyMine();
               _loc15_ = UserDataFacade.securityCreateObj(-_loc17_.delayedPaymentGetExp(),-_loc17_.delayedPaymentGetCoins(),-_loc17_.delayedPaymentGetCash());
               _loc17_.delayedPaymentPay();
            }
            _loc16_ = int(param1.missionDefinition.sku);
            UserDataFacade.getInstance().updateMissions("update",{"sku":_loc16_},this.getPersistence(),_loc15_);
            if(param3 == MissionObject.STATE_REACHED)
            {
               param1.applyReward();
            }
         }
      }
      
      public function getMissionByType(param1:String) : MissionObject
      {
         var _loc2_:MissionObject = null;
         for each(_loc2_ in this.mMissionsDictionary)
         {
            if(_loc2_.missionDefinition.eventType == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function initMissionsLoad() : void
      {
         this.mInitMissions = new Array();
      }
      
      private function initMissionsLogicUpdate(param1:int) : void
      {
         var _loc2_:MissionObject = null;
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
         {
            for each(_loc2_ in this.mInitMissions)
            {
               _loc2_.missionDefinition.initialize();
            }
            this.mInitMissions.splice(0,this.mInitMissions.length);
         }
      }
      
      private function getPersistenceList(param1:int, param2:Boolean = false) : void
      {
         var _loc4_:MissionObject = null;
         var _loc5_:XML = null;
         var _loc6_:XMLUtil = null;
         var _loc7_:String = null;
         var _loc3_:Array = new Array();
         for each(_loc4_ in this.mMissionsByPositionList[param1])
         {
            _loc7_ = _loc4_.missionDefinition.sku;
            _loc3_.push(_loc7_);
         }
         _loc5_ = LIST_XML[param1];
         _loc6_ = new XMLUtil(_loc5_,_loc3_);
         _loc6_.addToXML(this.mPersistence);
      }
      
      private function changeStateMissionsApplyAll() : void
      {
         var _loc1_:MissionObject = null;
         for each(_loc1_ in this.mChangeStateMissionsList)
         {
            this.changeStateMissionsApplyMission(_loc1_,_loc1_.oldState,_loc1_.newState);
         }
         this.mChangeStateMissionsList.splice(0,this.mChangeStateMissionsList.length);
      }
      
      public function addMissionToDictionary(param1:MissionObject) : void
      {
         if(this.mMissionsDictionary[param1.missionDefinition.sku] == null)
         {
            this.mMissionsDictionary[param1.missionDefinition.sku] = param1;
         }
      }
      
      private function buildMission(param1:Dictionary, param2:XML, param3:int, param4:int, param5:Boolean) : void
      {
         var _loc7_:MissionDefinition = null;
         var _loc10_:MissionObject = null;
         var _loc11_:String = null;
         var _loc6_:MissionDefinitionManager = MissionDefinitionManager.getInstance();
         var _loc8_:String = String(param2.@chunk);
         var _loc9_:Array = _loc8_.split(",");
         for each(_loc11_ in _loc9_)
         {
            if(_loc11_ != "")
            {
               _loc7_ = _loc6_.getDefinitionBySku(_loc11_) as MissionDefinition;
               if(_loc7_ != null)
               {
                  if(param5)
                  {
                     if(_loc7_.getShowInABTest() == null)
                     {
                        continue;
                     }
                  }
                  else if(_loc7_.getShowInABTest() != null)
                  {
                     continue;
                  }
                  param1[_loc7_.sku] = _loc7_;
                  _loc10_ = new MissionObject(_loc7_,param4);
                  this.mMissionsByPositionList[param3].push(_loc10_);
                  this.addMissionToDictionary(_loc10_);
               }
            }
         }
      }
      
      public function closeDescriptionEmail(param1:Event) : void
      {
         this.mDescriptionPopup.removeEventListener(Popup.EVENT_CLOSE,this.closeDescription);
         if(this.mDescriptionPopup.hasEventListener(Popup.EVENT_ACCEPT))
         {
            this.mDescriptionPopup.removeEventListener(Popup.EVENT_ACCEPT,this.closeDescriptionEmail);
         }
         this.mDescriptionPopup.onClose();
         this.mDescriptionPopup = null;
         DollarsGame.smInstance.mPopupMsgSmall.showPopupParams(TextManager.getText(TextIDs.TID_MISSION64_EMAIL_ADVICE));
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc4_:MissionObject = null;
         var _loc2_:int = DollarsGame.getCurrentRoleID();
         var _loc3_:int = LIST_POSITION_UP;
         while(_loc3_ <= LIST_POSITION_LOCKED)
         {
            for each(_loc4_ in this.mMissionsByPositionList[_loc3_])
            {
               if(_loc4_.needsToBeChecked(_loc2_))
               {
                  _loc4_.logicUpdate(param1);
               }
            }
            _loc3_++;
         }
         this.initMissionsLogicUpdate(param1);
         this.changeStateMissionsApplyAll();
         DollarsGame.getCurrentRole().toolsBar.bossAlertSetMissionReachedEnabled(this.mMissionsByPositionList[LIST_POSITION_REACHED].length > 0);
         if(this.mNeedsToCalculateMissionsLocked)
         {
            this.calculateMissionsLocked();
            this.mNeedsToCalculateMissionsLocked = false;
         }
         if(!this.mInitialized)
         {
            this.mInitialized = true;
         }
      }
      
      public function changeStateMissionsAddChange(param1:MissionObject, param2:int, param3:int) : void
      {
         param1.oldState = param2;
         param1.newState = param3;
         this.mChangeStateMissionsList.push(param1);
      }
      
      public function getMissionsGivenCount() : int
      {
         return this.mMissionsByPositionList[LIST_POSITION_GIVEN].length;
      }
      
      public function openDescription(param1:MissionObject) : void
      {
         if(param1.missionDefinition.eventType == MissionsEventIDs.MISSION_EVENT_NAME_CITY)
         {
            this.mDescriptionPopup = new PopupName(param1);
            this.mDescriptionPopup.addEventListener(Popup.EVENT_ACCEPT,this.closeDescriptionName);
            if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
            {
               Dollars.smStage.displayState = StageDisplayState.NORMAL;
            }
         }
         else if(param1.missionDefinition.eventType == MissionsEventIDs.MISSION_EVENT_GIVE_EMAIL)
         {
            this.mDescriptionPopup = new PopupEmail(param1);
            this.mDescriptionPopup.addEventListener(Popup.EVENT_ACCEPT,this.closeDescriptionEmail);
            if(Dollars.smStage.displayState == StageDisplayState.FULL_SCREEN)
            {
               Dollars.smStage.displayState = StageDisplayState.NORMAL;
            }
         }
         else if(param1.missionDefinition.eventType == MissionsEventIDs.MISSION_EVENT_COLLECT_UPGRADED || param1.missionDefinition.eventType == MissionsEventIDs.MISSION_EVENT_INSTALL_TOOLBAR)
         {
            this.mDescriptionPopup = new PopupMissionUpgrades(param1);
            this.mDescriptionPopup.addEventListener(Popup.EVENT_ACCEPT,this.closeDescription);
         }
         else
         {
            this.mDescriptionPopup = new PopupMission(param1);
         }
         this.mDescriptionPopup.showPopupParams(param1.missionDefinition.getTextTitle(),param1.missionDefinition.getTextDescription(true));
         this.mDescriptionPopup.addEventListener(Popup.EVENT_CLOSE,this.closeDescription);
      }
      
      public function messageMissionReachedStart() : void
      {
         if(this.mNotifyChangeEnabled)
         {
            if(!this.mMessageMissionReached.isActive())
            {
               this.mMessageMissionReached.reset();
            }
         }
      }
      
      private function closeReward(param1:Event) : void
      {
         DollarsGame.smInstance.mRain.stop();
         DollarsGame.smInstance.mRain2.stop();
         var _loc2_:MissionObject = this.mRewardPopup.missionObject;
         this.mRewardPopup.removeEventListener(Popup.EVENT_CLOSE,this.closeReward);
         this.mRewardPopup.destroy();
         this.mRewardPopup = null;
      }
      
      private function calculateMissionsLocked() : void
      {
         var _loc1_:MissionObject = null;
         this.mMissionsLocked.length = 0;
         for each(_loc1_ in this.mMissionsByPositionList[LIST_POSITION_LOCKED])
         {
            this.mMissionsLocked.push(_loc1_);
         }
         this.mMissionsLocked.sort(this.sortMissionsLocked);
      }
      
      private function sortMissionBySku(param1:MissionObject, param2:MissionObject) : Number
      {
         var _loc3_:String = param1.missionDefinition.sku;
         var _loc4_:String = param2.missionDefinition.sku;
         var _loc5_:Number = 0;
         if(_loc3_ > _loc4_)
         {
            _loc5_ = 1;
         }
         else if(_loc4_ > _loc3_)
         {
            _loc5_ = -1;
         }
         return _loc5_;
      }
      
      public function notifyChange() : void
      {
         if(this.mNotifyChangeEnabled)
         {
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function getMissionsReachedCount() : int
      {
         return this.mMissionsByPositionList[LIST_POSITION_REACHED].length;
      }
      
      private function getListPosition(param1:int) : int
      {
         var _loc2_:int = LIST_POSITION_UP;
         if(param1 == MissionObject.STATE_LOCKED)
         {
            _loc2_ = LIST_POSITION_LOCKED;
         }
         else if(param1 == MissionObject.STATE_REACHED)
         {
            _loc2_ = LIST_POSITION_REACHED;
         }
         else if(param1 == MissionObject.STATE_GIVEN)
         {
            _loc2_ = LIST_POSITION_GIVEN;
         }
         return _loc2_;
      }
      
      private function initMissionsDestroy() : void
      {
         this.mInitMissions.splice(0,this.mInitMissions.length);
         this.mInitMissions = null;
      }
      
      public function getMissions() : Array
      {
         var _loc2_:int = 0;
         var _loc3_:MissionObject = null;
         var _loc7_:int = 0;
         var _loc8_:* = 0;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc11_:* = 0;
         var _loc12_:MissionObject = null;
         this.changeStateMissionsApplyAll();
         var _loc1_:Array = new Array();
         var _loc4_:Array = this.mMissionsByPositionList[LIST_POSITION_REACHED];
         var _loc5_:int = int(_loc4_.length);
         _loc2_ = 0;
         while(_loc2_ < _loc5_)
         {
            _loc3_ = _loc4_[_loc2_] as MissionObject;
            _loc1_.push(_loc3_);
            _loc2_++;
         }
         _loc4_ = this.mMissionsByPositionList[LIST_POSITION_UP];
         var _loc6_:int = int(_loc4_.length);
         _loc2_ = 0;
         while(_loc2_ < _loc6_)
         {
            _loc3_ = _loc4_[_loc2_] as MissionObject;
            _loc1_.push(_loc3_);
            _loc2_++;
         }
         if(_loc6_ < LIST_UP_ENTRIES_COUNT)
         {
            _loc4_ = this.mMissionsLocked;
            _loc7_ = int(_loc4_.length);
            _loc8_ = int(Math.min(_loc7_,LIST_UP_ENTRIES_COUNT - _loc6_));
            _loc9_ = 0;
            while(_loc9_ < _loc7_ && _loc8_ > 0)
            {
               _loc3_ = _loc4_[_loc9_] as MissionObject;
               _loc10_ = true;
               if(_loc3_.missionDefinition.hasUnlockSku())
               {
                  _loc10_ = false;
                  _loc11_ = int(_loc6_ - 1);
                  while(_loc11_ > -1 && !_loc10_)
                  {
                     _loc12_ = this.mMissionsByPositionList[LIST_POSITION_UP][_loc11_];
                     if(_loc12_.missionDefinition.sku == _loc3_.missionDefinition.unlockSku)
                     {
                        _loc10_ = true;
                        _loc3_.setUnlockMissionID(_loc11_);
                     }
                     _loc11_--;
                  }
               }
               if(_loc10_)
               {
                  _loc1_.push(_loc3_);
                  _loc8_--;
               }
               _loc9_++;
            }
         }
         return _loc1_;
      }
      
      private function load() : void
      {
         this.mInitialized = false;
         this.mMissionsLocked = new Array();
         this.mMissionsByPositionList = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < LIST_POSITION_COUNT)
         {
            this.mMissionsByPositionList[_loc1_] = new Array();
            _loc1_++;
         }
         this.mMissionsDictionary = new Dictionary();
         this.initMissionsLoad();
         this.changeStateMissionsLoad();
         this.mMessageMissionReached = new MessageText(TextManager.getText(TextIDs.TID_MISSION_COMPLETED));
         MessageManager.getInstance().addMessage(this.mMessageMissionReached);
      }
      
      public function getPersistence(param1:Boolean = false) : XML
      {
         var _loc2_:Array = null;
         this.mPersistence = <Missions/>;
         this.getPersistenceList(LIST_POSITION_REACHED,param1);
         this.getPersistenceList(LIST_POSITION_UP,param1);
         this.getPersistenceList(LIST_POSITION_GIVEN,param1);
         return this.mPersistence;
      }
      
      public function getMissionsAvailable() : Array
      {
         return this.mMissionsByPositionList[LIST_POSITION_UP];
      }
      
      public function build() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:MissionDefinition = null;
         var _loc5_:XML = null;
         var _loc6_:MissionObject = null;
         var _loc7_:String = null;
         var _loc8_:MissionDefinitionManager = null;
         var _loc9_:Dictionary = null;
         var _loc10_:Boolean = false;
         var _loc11_:Array = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Array = null;
         var _loc15_:int = 0;
         if(this.mPersistence != null)
         {
            this.mNotifyChangeEnabled = false;
            this.mNeedsToCalculateMissionsLocked = true;
            _loc8_ = MissionDefinitionManager.getInstance();
            _loc9_ = new Dictionary();
            _loc10_ = DollarsGame.getProfile().altMissionsGet();
            for each(_loc5_ in this.mPersistence.Reached)
            {
               this.buildMission(_loc9_,_loc5_,LIST_POSITION_REACHED,MissionObject.STATE_REACHED,_loc10_);
            }
            for each(_loc5_ in this.mPersistence.Given)
            {
               this.buildMission(_loc9_,_loc5_,LIST_POSITION_GIVEN,MissionObject.STATE_GIVEN,_loc10_);
            }
            for each(_loc5_ in this.mPersistence.Up)
            {
               this.buildMission(_loc9_,_loc5_,LIST_POSITION_UP,MissionObject.STATE_UNLOCKED,_loc10_);
            }
            _loc11_ = _loc8_.getDefinitions();
            _loc12_ = int(_loc11_.length);
            _loc13_ = 0;
            for(; _loc13_ < _loc12_; _loc13_++)
            {
               _loc4_ = _loc11_[_loc13_] as MissionDefinition;
               if(_loc10_)
               {
                  if(_loc4_.getShowInABTest() == null)
                  {
                     continue;
                  }
               }
               else if(_loc4_.getShowInABTest() != null)
               {
                  continue;
               }
               if(_loc9_[_loc4_.sku] == null)
               {
                  _loc6_ = new MissionObject(_loc4_);
                  this.mMissionsByPositionList[this.getListPosition(_loc6_.state)].push(_loc6_);
                  this.addMissionToDictionary(_loc6_);
               }
            }
            _loc14_ = this.mMissionsByPositionList[LIST_POSITION_UP];
            _loc14_.sort(this.sortMissionsBySku);
            _loc9_ = null;
            this.mNotifyChangeEnabled = true;
            _loc15_ = 0;
            while(_loc15_ < LIST_UP_ENTRIES_COUNT)
            {
               _loc6_ = this.mMissionsByPositionList[LIST_POSITION_UP][_loc15_];
               if(_loc6_ != null && _loc6_.missionDefinition.needsToBeInitialized())
               {
                  this.initMissionsAddMission(_loc6_);
               }
               _loc15_++;
            }
         }
      }
      
      private function changeStateMissionsLoad() : void
      {
         this.mChangeStateMissionsList = new Array();
      }
      
      public function setPersistence(param1:XML) : void
      {
         this.mPersistence = param1;
      }
      
      public function destroy() : void
      {
         var _loc2_:MissionObject = null;
         this.mMissionsLocked = null;
         var _loc1_:int = 0;
         while(_loc1_ < LIST_POSITION_COUNT)
         {
            for each(_loc2_ in this.mMissionsByPositionList[_loc1_])
            {
               _loc2_.destroy();
            }
            this.mMissionsByPositionList[_loc1_] = null;
            _loc1_++;
         }
         this.mMissionsByPositionList = null;
         this.mMissionsDictionary = null;
         this.initMissionsDestroy();
         this.changeStateMissionsDestroy();
         MessageManager.getInstance().removeMessage(this.mMessageMissionReached);
         this.mMessageMissionReached.destroy();
         this.mMessageMissionReached = null;
      }
      
      public function closeDescription(param1:Event) : void
      {
         this.mDescriptionPopup.removeEventListener(Popup.EVENT_CLOSE,this.closeDescription);
         if(this.mDescriptionPopup.hasEventListener(Popup.EVENT_ACCEPT))
         {
            this.mDescriptionPopup.removeEventListener(Popup.EVENT_ACCEPT,this.closeDescription);
         }
         this.mDescriptionPopup.onClose();
         this.mDescriptionPopup = null;
      }
   }
}

