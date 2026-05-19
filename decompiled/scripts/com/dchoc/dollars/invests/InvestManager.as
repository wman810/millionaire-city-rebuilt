package com.dchoc.dollars.invests
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendObject;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   
   public class InvestManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:InvestManager;
      
      private var mInvestObjectsUINeedsToBeUpdated:Boolean;
      
      private var mInvestObjectsUI:Array;
      
      private var mReminder:Boolean;
      
      private var mLoadDone:Boolean;
      
      private var mStatsInvestmentsRewarded:int;
      
      private var mInvestObjectsHelpUI:Array;
      
      private var mInversorUserId:int;
      
      private var mStatsInvestmentsStarted:int;
      
      private var mFriendsToInvest:Array;
      
      private var mSortList:Boolean;
      
      private var mInvestObjects:Array;
      
      public function InvestManager()
      {
         super();
         this.mLoadDone = false;
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: InvestManager Error: Instantiation failed: Use InvestManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : InvestManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new InvestManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function applyInvestmentDone(param1:InvestObject) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:int = this.mInvestObjects.indexOf(param1);
         var _loc3_:Object = new Object();
         _loc3_.p1 = param1.getExtId();
         if(_loc2_ > -1 && param1.isDoable())
         {
            _loc4_ = param1.isSuccesfully();
            if(_loc4_)
            {
               ++this.mStatsInvestmentsRewarded;
               MyMetrics.sendMetric(MetricConstants.EVENT_INVESTMENTS,MetricConstants.LABEL_INVEST_GOOD,_loc3_);
            }
            else
            {
               MyMetrics.sendMetric(MetricConstants.EVENT_INVESTMENTS,MetricConstants.LABEL_INVEST_BAD,_loc3_);
            }
            param1.setClaimed(true);
            Debug.trace("############# INVESTMENTS: add RESULTS investment server call in InvestManager.applyInvestmentDone() method");
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
               "type":UserDataFacade.INVEST_TYPE_RESULTS,
               "fExtId":param1.getExtId(),
               "success":_loc4_
            });
         }
         this.mInvestObjectsUINeedsToBeUpdated = true;
      }
      
      private function investmentsPopulate(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:InvestObject = null;
         this.mInvestObjects.splice(0,this.mInvestObjects.length);
         if("@inversor_user_id" in param1)
         {
            this.mInversorUserId = parseInt(param1.@inversor_user_id);
         }
         else
         {
            this.mInversorUserId = -1;
         }
         if("@investmentsStarted" in param1)
         {
            this.mStatsInvestmentsStarted = param1.@investmentsStarted;
         }
         if("@investmentsRewarded" in param1)
         {
            this.mStatsInvestmentsRewarded = param1.@investmentsRewarded;
         }
         for each(_loc2_ in param1.investment)
         {
            _loc3_ = new InvestObject();
            _loc3_.setExtId(_loc2_.@extId);
            _loc3_.setUserId(int(_loc2_.@userId));
            _loc3_.setCompanyValue(int(_loc2_.@value));
            _loc3_.setTimeLeft(int(_loc2_.@time));
            _loc3_.setRemindTimeLeft(int(_loc2_.@remindTime));
            _loc3_.setStatePersistence(int(_loc2_.@state));
            this.mInvestObjects.push(_loc3_);
         }
         this.mInvestObjectsUINeedsToBeUpdated = true;
         this.friendsToInvestPopulate();
      }
      
      private function friendsToInvestLoad() : void
      {
         this.mFriendsToInvest = new Array();
      }
      
      private function friendsToInvestPopulate() : void
      {
         var _loc2_:FriendObject = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:* = 0;
         var _loc6_:InvestObject = null;
         this.mFriendsToInvest.splice(0,this.mFriendsToInvest.length);
         var _loc1_:Vector.<FriendObject> = FriendsManager.getFriendsNoNeighbors();
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = _loc2_.extId;
            _loc4_ = false;
            _loc5_ = int(this.mInvestObjects.length - 1);
            while(_loc5_ > -1 && !_loc4_)
            {
               _loc6_ = this.mInvestObjects[_loc5_];
               if(_loc3_ == _loc6_.getExtId())
               {
                  _loc4_ = true;
               }
               _loc5_--;
            }
            if(!_loc4_)
            {
               this.mFriendsToInvest.push(_loc2_);
            }
         }
         this.mSortList = true;
      }
      
      private function sortCompareFunctionName(param1:FriendObject, param2:FriendObject) : Number
      {
         var _loc3_:String = param1.nameFriend;
         var _loc4_:String = param2.nameFriend;
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
      
      private function sortInvestmentsUI(param1:InvestObject, param2:InvestObject) : Number
      {
         var _loc3_:int = 0;
         var _loc4_:int = param1.getState();
         var _loc5_:int = param2.getState();
         if(_loc4_ == InvestObject.STATE_DONE && _loc5_ != InvestObject.STATE_DONE)
         {
            _loc3_ = -1;
         }
         else if(_loc5_ == InvestObject.STATE_DONE && _loc4_ != InvestObject.STATE_DONE)
         {
            _loc3_ = 1;
         }
         else if(_loc4_ == InvestObject.STATE_RUNNING && _loc5_ != InvestObject.STATE_RUNNING)
         {
            _loc3_ = -1;
         }
         else if(_loc5_ == InvestObject.STATE_RUNNING && _loc4_ != InvestObject.STATE_RUNNING)
         {
            _loc3_ = 1;
         }
         else if(_loc4_ == InvestObject.STATE_EXPIRED && _loc5_ != InvestObject.STATE_EXPIRED)
         {
            _loc3_ = -1;
         }
         else if(_loc5_ == InvestObject.STATE_EXPIRED && _loc4_ != InvestObject.STATE_EXPIRED)
         {
            _loc3_ = 1;
         }
         else if(_loc4_ == InvestObject.STATE_DONE_CLAIMED && _loc5_ != InvestObject.STATE_DONE_CLAIMED)
         {
            _loc3_ = 1;
         }
         else if(_loc5_ == InvestObject.STATE_DONE_CLAIMED && _loc4_ != InvestObject.STATE_DONE_CLAIMED)
         {
            _loc3_ = -1;
         }
         return _loc3_;
      }
      
      public function areInvestmentsEnabled() : Boolean
      {
         return DollarsGame.getProfile().level >= RulesFacade.getInstance().settingsGetInvestmentsUnlockLevel();
      }
      
      private function investmentsLoad() : void
      {
         this.mInvestObjects = new Array();
         this.mInvestObjectsUI = new Array();
      }
      
      public function setReminder(param1:Boolean) : void
      {
         this.mReminder = param1;
      }
      
      private function statsLoad() : void
      {
      }
      
      public function isAnInversorValid(param1:int) : Boolean
      {
         return param1 > 0;
      }
      
      public function areInvestmentsLoaded() : Boolean
      {
         return this.mLoadDone && Tutorial.smTutorialEnd;
      }
      
      private function friendsToInvestDestroy() : void
      {
         this.mFriendsToInvest.splice(0,this.mFriendsToInvest.length);
         this.mFriendsToInvest = null;
      }
      
      public function statsGetInvestmentSuccessPercentage() : int
      {
         var _loc1_:int = this.statsGetInvestmentsStartedCount();
         if(_loc1_ > 0)
         {
            _loc1_ = 100 * this.statsGetInvestmentsSuccesfullyCount() / _loc1_;
         }
         return _loc1_;
      }
      
      public function statsGetInvestmentsSuccesfullyCount() : int
      {
         return this.mStatsInvestmentsRewarded;
      }
      
      public function investInFriend(param1:FriendObject) : void
      {
         var _loc4_:InvestObject = null;
         var _loc5_:Object = null;
         var _loc2_:InvestDefinition = InvestDefinitionManager.getInstance().getInvestDefinition();
         var _loc3_:int = this.mFriendsToInvest.indexOf(param1);
         if(_loc2_ != null && _loc3_ > -1)
         {
            this.mFriendsToInvest.splice(_loc3_,1);
            _loc4_ = new InvestObject();
            _loc4_.setExtId(param1.extId);
            _loc4_.setUserId(param1.userId);
            this.mInvestObjects.push(_loc4_);
            this.mInvestObjectsUINeedsToBeUpdated = true;
            if(!Config.INVESTMENT_REQUEST_ENABLED)
            {
               Debug.trace("############# INVESTMENTS: add NEW investment server call in InvestManager.investInFriend() method");
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
                  "type":UserDataFacade.INVEST_TYPE_ON_FRIEND,
                  "fExtId":param1.extId
               });
            }
            _loc5_ = new Object();
            _loc5_.p1 = _loc4_.getExtId();
            MyMetrics.sendMetric(MetricConstants.EVENT_INVESTMENTS,MetricConstants.LABEL_INVEST_START,_loc5_);
            this.mSortList = true;
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:InvestObject = null;
         for each(_loc2_ in this.mInvestObjects)
         {
            _loc2_.logicUpdate(param1);
         }
         if(this.mReminder && this.areInvestmentsEnabled() && Tutorial.smTutorialEnd && this.statsGetInvestmentsStartedCount() < 1)
         {
            DollarsGame.getCurrentRole().toolsBar.startJumpInvestmentButton();
            this.mReminder = false;
         }
      }
      
      public function getFriendsToInvest() : Array
      {
         if(this.mSortList)
         {
            this.mSortList = false;
            this.mFriendsToInvest.sort(this.sortCompareFunctionName);
         }
         return this.mFriendsToInvest;
      }
      
      public function getInversorUserId() : int
      {
         return this.mInversorUserId;
      }
      
      private function investmentsDestroy() : void
      {
         var _loc1_:InvestObject = null;
         for each(_loc1_ in this.mInvestObjects)
         {
            _loc1_.destroy();
         }
         this.mInvestObjects.splice(0,this.mInvestObjects.length);
         this.mInvestObjects = null;
         this.mInvestObjectsUI.splice(0,this.mInvestObjectsUI.length);
         this.mInvestObjectsUI = null;
         if(this.mInvestObjectsHelpUI != null)
         {
            for each(_loc1_ in this.mInvestObjectsHelpUI)
            {
               _loc1_.destroy();
            }
            this.mInvestObjectsHelpUI.splice(0,this.mInvestObjectsHelpUI.length);
            this.mInvestObjectsHelpUI = null;
         }
      }
      
      private function statsDestroy() : void
      {
      }
      
      public function getInvestmentsUI() : Array
      {
         var _loc1_:InvestObject = null;
         if(this.mInvestObjectsUINeedsToBeUpdated)
         {
            this.mInvestObjectsUI.splice(0,this.mInvestObjectsUI.length);
            for each(_loc1_ in this.mInvestObjects)
            {
               this.mInvestObjectsUI.push(_loc1_);
            }
            this.mInvestObjectsUI.sort(this.sortInvestmentsUI);
            this.mInvestObjectsUINeedsToBeUpdated = false;
         }
         return this.mInvestObjectsUI;
      }
      
      public function getReminder() : Boolean
      {
         return this.mReminder;
      }
      
      public function load() : void
      {
         var _loc1_:XML = null;
         if(this.mInvestObjects == null)
         {
            this.investmentsLoad();
            this.friendsToInvestLoad();
            _loc1_ = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_INVESTMENTS_LIST);
            this.investmentsPopulate(_loc1_);
            this.statsLoad();
            this.mLoadDone = true;
         }
      }
      
      public function cancelInvestment(param1:InvestObject) : void
      {
         var _loc3_:InvestDefinition = null;
         var _loc4_:Object = null;
         var _loc2_:int = this.mInvestObjects.indexOf(param1);
         if(_loc2_ > -1 && param1.isCancellable())
         {
            _loc3_ = InvestDefinitionManager.getInstance().getInvestDefinition();
            if(_loc3_ != null)
            {
               param1.destroy();
               this.mInvestObjects.splice(_loc2_,1);
               this.friendsToInvestPopulate();
               Debug.trace("############# INVESTMENTS: add CANCEL investment server call in InvestManager.cancelInvestment() method");
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_INVEST,{
                  "type":UserDataFacade.INVEST_TYPE_CANCEL,
                  "fExtId":param1.getExtId()
               });
               _loc4_ = new Object();
               _loc4_.p1 = param1.getExtId();
               MyMetrics.sendMetric(MetricConstants.EVENT_INVESTMENTS,MetricConstants.LABEL_INVEST_CANCEL,_loc4_);
               this.mSortList = true;
            }
         }
         this.mInvestObjectsUINeedsToBeUpdated = true;
      }
      
      public function statsGetInvestmentsStartedCount() : int
      {
         return this.mStatsInvestmentsStarted;
      }
      
      public function destroy() : void
      {
      }
      
      public function traceContent() : void
      {
         var _loc1_:InvestObject = null;
         var _loc2_:Array = null;
         var _loc3_:FriendObject = null;
         trace("------------------------------------------------");
         trace("\t\t\t\t  INVESTMENTS                      ");
         trace("------------------------------------------------");
         for each(_loc1_ in this.mInvestObjects)
         {
            _loc1_.traceContent();
         }
         trace();
         trace("------------------------------------------------");
         trace("\t\tINVESTMENTS UI (" + this.mInvestObjectsUINeedsToBeUpdated + ")              ");
         trace("------------------------------------------------");
         _loc2_ = this.getInvestmentsUI();
         for each(_loc1_ in _loc2_)
         {
            _loc1_.traceContent();
         }
         trace();
         trace("------------------------------------------------");
         trace("\t\t        FRIENDS TO INVEST                  ");
         trace("------------------------------------------------");
         for each(_loc3_ in this.mFriendsToInvest)
         {
            trace("extId = " + _loc3_.extId + " userId = " + _loc3_.userId);
         }
         trace();
      }
      
      public function getInvestmentsHelpUI() : Array
      {
         var _loc1_:* = 0;
         var _loc2_:InvestObject = null;
         if(this.mInvestObjectsHelpUI == null)
         {
            this.mInvestObjectsHelpUI = new Array(InvestObject.STATE_COUNT);
            _loc1_ = int(InvestObject.STATE_COUNT - 1);
            while(_loc1_ > -1)
            {
               _loc2_ = new InvestObject(_loc1_);
               this.mInvestObjectsHelpUI[_loc1_] = _loc2_;
               _loc1_--;
            }
         }
         return this.mInvestObjectsHelpUI;
      }
   }
}

