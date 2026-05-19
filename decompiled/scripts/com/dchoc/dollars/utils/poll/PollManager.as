package com.dchoc.dollars.utils.poll
{
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.xml.XMLUtil;
   import flash.utils.Dictionary;
   
   public class PollManager
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:PollManager;
      
      private var mPersistence:XML;
      
      private var mEventDictionary:Dictionary;
      
      private var mEventList:Array;
      
      private var mEnabled:Boolean;
      
      public function PollManager()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: PollManager Error: Instantiation failed: Use PollManager.getInstance() instead of new.");
         }
         this.load();
      }
      
      public static function getInstance() : PollManager
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new PollManager();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      public function getEvent(param1:String) : PollEvent
      {
         return this.mEventDictionary[param1];
      }
      
      private function load() : void
      {
         this.mEventDictionary = new Dictionary();
         this.mEventList = new Array();
         this.setEnabled(true);
      }
      
      public function getPersistence(param1:Boolean = false) : XML
      {
         var _loc3_:PollEvent = null;
         var _loc4_:XML = null;
         var _loc5_:XMLUtil = null;
         var _loc6_:String = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in this.mEventList)
         {
            if(_loc3_.needsToRegisterPersistence())
            {
               _loc6_ = _loc3_.getPersistenceAsString();
               _loc2_.push(_loc6_);
            }
         }
         _loc4_ = <Count/>;
         _loc5_ = new XMLUtil(_loc4_,_loc2_);
         this.mPersistence = <PollManager/>;
         _loc5_.addToXML(this.mPersistence);
         return this.mPersistence;
      }
      
      public function getEnabled() : Boolean
      {
         return this.mEnabled;
      }
      
      public function build() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:PollEvent = null;
         if(this.mPersistence != null)
         {
            for each(_loc4_ in this.mPersistence.Count)
            {
               _loc1_ = String(_loc4_.@chunk);
               _loc2_ = _loc1_.split(",");
               for each(_loc5_ in _loc2_)
               {
                  if(_loc5_ != "")
                  {
                     _loc3_ = _loc5_.split("/");
                     _loc6_ = this.mEventDictionary[_loc3_[0]] as PollEvent;
                     if(_loc6_ != null)
                     {
                        _loc6_.build(_loc3_[1] as String);
                     }
                  }
               }
            }
         }
      }
      
      public function registerEvent(param1:String, param2:String = "") : void
      {
         var _loc3_:PollEvent = null;
         if(Tutorial.smTutorialEnd)
         {
            param1 += param2;
            _loc3_ = this.mEventDictionary[param1];
            if(_loc3_ != null)
            {
               if(Config.DEBUG_POLL_MANAGER)
               {
                  trace();
                  trace("===========================================");
                  trace("POLL_MANAGER.registerEvent " + param1);
                  trace("===========================================");
               }
               _loc3_.register();
            }
         }
      }
      
      public function addEvent(param1:PollEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:PollEvent = this.mEventDictionary[param1.sku];
         if(_loc2_ != null && _loc2_.getCheckCondition())
         {
            _loc2_.addEvent(param1);
         }
         else
         {
            if(_loc2_ != null)
            {
               _loc3_ = this.mEventList.indexOf(_loc2_);
               if(_loc3_ > -1)
               {
                  this.mEventList.splice(_loc3_,1);
               }
            }
            this.mEventDictionary[param1.sku] = param1;
            this.mEventList.push(param1);
         }
      }
      
      private function destroy() : void
      {
         var _loc1_:PollEvent = null;
         for each(_loc1_ in this.mEventList)
         {
            _loc1_.destroy();
         }
         this.mEventDictionary = null;
         this.mEventList = null;
      }
      
      public function setPersistence(param1:XML) : void
      {
         this.mPersistence = param1;
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         this.mEnabled = param1;
      }
   }
}

