package com.dchoc.dollars.missions.iconLayer
{
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   
   public class MissionsIconLayerManager
   {
      
      private static var smAllowed:Boolean;
      
      private static var smInstance:MissionsIconLayerManager;
      
      private static const ICON_LIST_SIZE:int = 4;
      
      private static const ICON_LIST_MAX_SIZE:int = 8;
      
      private var mIsBuilt:Boolean;
      
      private var mCurrentList:Array;
      
      private var mList:Array;
      
      private var mListSize:int;
      
      public function MissionsIconLayerManager()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: MissionsIconLayerManager Error: Instantiation failed: Use MissionsIconLayerManager.getInstance() instead of new.");
         }
         this.mListSize = MissionsIconLayerManager.ICON_LIST_SIZE;
         this.mCurrentList = new Array(MissionsIconLayerManager.ICON_LIST_MAX_SIZE);
      }
      
      public static function getInstance() : MissionsIconLayerManager
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new MissionsIconLayerManager();
            smAllowed = false;
         }
         return smInstance;
      }
      
      private function updateIconList() : void
      {
         var _loc3_:MissionObject = null;
         var _loc4_:MissionObject = null;
         var _loc5_:MissionObject = null;
         var _loc6_:int = 0;
         var _loc1_:* = 0;
         var _loc2_:int = 0;
         this.mList.sortOn("heuristic",Array.NUMERIC);
         _loc1_ = 0;
         while(_loc1_ < this.mList.length)
         {
            _loc3_ = this.mList[_loc1_];
            if(_loc3_.state > MissionObject.STATE_UNLOCKED)
            {
               this.mList.splice(_loc1_,1);
               _loc1_--;
            }
            else if(_loc3_.state == MissionObject.STATE_UNLOCKED)
            {
               _loc2_++;
            }
            _loc1_++;
         }
         if(this.mListSize != _loc2_ && _loc2_ <= MissionsIconLayerManager.ICON_LIST_SIZE)
         {
            this.mListSize = _loc2_;
            if(this.mListSize > this.mList.length)
            {
               this.mListSize = this.mList.length;
            }
            MissionsIconLayerDisplay.getInstance().moveIcon(null,this.mListSize);
         }
         _loc1_ = 0;
         while(_loc1_ < this.mListSize)
         {
            _loc4_ = this.mList[_loc1_];
            _loc5_ = this.mCurrentList[_loc1_];
            _loc6_ = this.mCurrentList.indexOf(_loc4_);
            if(_loc6_ >= 0)
            {
               if(_loc6_ != _loc1_)
               {
                  MissionsIconLayerDisplay.getInstance().moveIcon(_loc4_,_loc1_);
               }
            }
            else
            {
               MissionsIconLayerDisplay.getInstance().addIcon(_loc4_,_loc1_);
            }
            if(_loc5_ != null)
            {
               _loc6_ = this.mList.indexOf(_loc5_);
               if(_loc6_ >= MissionsIconLayerManager.ICON_LIST_SIZE || _loc6_ == -1)
               {
                  MissionsIconLayerDisplay.getInstance().removeIcon(_loc5_);
               }
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.mListSize)
         {
            this.mCurrentList[_loc1_] = this.mList[_loc1_];
            _loc1_++;
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         if(!this.mIsBuilt)
         {
            this.build();
         }
         else
         {
            _loc2_ = false;
            _loc3_ = false;
            _loc4_ = 0;
            while(_loc4_ < this.mList.length)
            {
               _loc3_ ||= Boolean(this.mList[_loc4_].heuristicChanged());
               if(_loc4_ >= this.mListSize)
               {
                  _loc2_ ||= Boolean(this.mList[_loc4_].hasChanged());
               }
               _loc4_++;
            }
            if(_loc2_)
            {
               MissionsIconLayerDisplay.getInstance().showClickMeLabel();
            }
            if(_loc3_)
            {
               this.updateIconList();
               this.print();
            }
            MissionsIconLayerDisplay.getInstance().update(param1);
         }
      }
      
      private function print() : void
      {
         var _loc2_:MissionObject = null;
         var _loc1_:int = 0;
         while(_loc1_ < MissionsIconLayerManager.ICON_LIST_SIZE)
         {
            _loc2_ = this.mList[_loc1_];
            if(_loc2_ != null)
            {
            }
            _loc1_++;
         }
      }
      
      private function build() : void
      {
         this.mList = MissionObjectManager.getInstance().getMissionsAll();
         if(this.mList != null)
         {
            this.mList.sortOn("heuristic",Array.NUMERIC);
            this.mIsBuilt = true;
         }
         MissionsIconLayerDisplay.getInstance().addIcon(null,this.mListSize);
      }
   }
}

