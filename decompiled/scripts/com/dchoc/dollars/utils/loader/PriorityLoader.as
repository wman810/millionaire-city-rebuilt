package com.dchoc.dollars.utils.loader
{
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.utils.Dictionary;
   
   public class PriorityLoader
   {
      
      private static var smInstance:PriorityLoader;
      
      private static var smAllowInstantiation:Boolean;
      
      public static const QUEUE_LOADING:int = 0;
      
      public static const QUEUE_ASYNC:int = 1;
      
      private static const REQUEST_LOAD_ALL:int = 0;
      
      private static const REQUEST_LOAD_BY_STEP:int = 1;
      
      private var mLoader:DCResourceManager;
      
      private var mRequestLoadType:Array;
      
      private var mIndexTable:Dictionary;
      
      private var mRequestedCount:Array;
      
      private var mQueues:Array;
      
      private var mLoadedCount:Array;
      
      public function PriorityLoader()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: PriorityLoader Error: Instantiation failed: Use PriorityLoader.getInstance() instead of new.");
         }
         this.mLoader = DCResourceManager.getInstance();
         this.mIndexTable = new Dictionary(true);
         this.mQueues = new Array();
         this.mRequestedCount = new Array();
         this.mLoadedCount = new Array();
         this.mRequestLoadType = new Array();
         this.mRequestLoadType[QUEUE_LOADING] = REQUEST_LOAD_ALL;
         this.mRequestLoadType[QUEUE_ASYNC] = REQUEST_LOAD_BY_STEP;
      }
      
      public static function getInstance() : PriorityLoader
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new PriorityLoader();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function queueProgress(param1:int) : int
      {
         if(this.mRequestedCount[param1] == 0 || this.mRequestedCount[param1] == null)
         {
            return 100;
         }
         return this.mLoadedCount[param1] * 100 / this.mRequestedCount[param1];
      }
      
      public function getResource(param1:String, param2:String) : *
      {
         if(this.isLoaded(param1))
         {
            return new (this.mLoader.getSWFClass(param1,param2))();
         }
         return null;
      }
      
      public function update() : void
      {
         var _loc2_:* = 0;
         var _loc3_:QueuedItem = null;
         var _loc4_:String = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.mQueues.length)
         {
            if(this.mQueues[_loc1_] != null)
            {
               _loc2_ = 5000;
               while(this.mQueues[_loc1_] != null && this.mQueues[_loc1_].length > 0 && _loc2_ > 0)
               {
                  _loc2_--;
                  _loc3_ = this.mQueues[_loc1_].pop();
                  this.mLoader.load(_loc3_.mPath,_loc3_.mName,_loc3_.mType);
                  _loc3_.release();
                  _loc3_ = null;
                  if(this.mRequestLoadType[_loc1_] == REQUEST_LOAD_BY_STEP)
                  {
                     break;
                  }
               }
               if(this.mLoadedCount[_loc1_] < this.mRequestedCount[_loc1_])
               {
                  for(_loc4_ in this.mIndexTable)
                  {
                     if(this.mIndexTable[_loc4_] == _loc1_ && this.isLoaded(_loc4_))
                     {
                        ++this.mLoadedCount[_loc1_];
                        this.mIndexTable[_loc4_] = "complete";
                     }
                  }
                  break;
               }
            }
            _loc1_++;
         }
      }
      
      public function isLoaded(param1:String) : Boolean
      {
         return this.mLoader.isResLoaded(param1);
      }
      
      public function queueLoad(param1:int, param2:String, param3:String = "", param4:String = "") : void
      {
         if(this.mIndexTable[param3] != null)
         {
            return;
         }
         if(this.mQueues[param1] == null)
         {
            this.mQueues[param1] = new Array();
            this.mRequestedCount[param1] = 0;
            this.mLoadedCount[param1] = 0;
         }
         this.mQueues[param1].push(new QueuedItem(param2,param3,param4));
         ++this.mRequestedCount[param1];
         this.mIndexTable[param3] = param1;
      }
      
      public function getTotalProgress() : int
      {
         if(this.mQueues.length == 0)
         {
            return 100;
         }
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.mQueues.length)
         {
            _loc1_ += this.queueProgress(_loc2_);
            _loc2_++;
         }
         return _loc1_ / this.mQueues.length;
      }
      
      public function unload(param1:String) : void
      {
         if(this.mIndexTable[param1] == "complete")
         {
            delete this.mIndexTable[param1];
            this.mLoader.unload(param1);
         }
      }
   }
}

