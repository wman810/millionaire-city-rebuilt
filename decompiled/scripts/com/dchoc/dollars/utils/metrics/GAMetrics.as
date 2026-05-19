package com.dchoc.dollars.utils.metrics
{
   import com.google.analytics.AnalyticsTracker;
   import com.google.analytics.GATracker;
   
   public class GAMetrics
   {
      
      private static var smAllowInstantiation:Boolean;
      
      private static var smInstance:GAMetrics;
      
      private var mWebId:String;
      
      private var mTracker:AnalyticsTracker;
      
      public function GAMetrics()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: GoogleAnalyticsMetrics Error: Instantiation failed: Use GAMetrics.getInstance() instead of new.");
         }
         this.mWebId = null;
         if(Config.OFFLINE_GAMEPLAY_MODE)
         {
            this.mWebId = null;
         }
         else
         {
            this.mWebId = getWebID();
         }
         if(this.mWebId != null && this.mWebId != "null")
         {
            this.mTracker = new GATracker(Dollars.smStage,this.mWebId,"AS3",Config.DEBUG_MODE);
         }
         else
         {
            this.mTracker = null;
         }
      }
      
      public static function getWebID() : String
      {
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         return _loc1_.analytics_code;
      }
      
      public static function getInstance() : GAMetrics
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new GAMetrics();
            smAllowInstantiation = false;
         }
         return GAMetrics.smInstance;
      }
      
      public function registerEvent(param1:String, param2:String, param3:String = null, param4:Number = NaN) : Boolean
      {
         if(this.mTracker != null)
         {
            if(this.isGoal(param1,param2,param3,param4))
            {
               this.registerGoal(param1,param2,param3,param4);
            }
            return this.mTracker.trackEvent(param1,param2,param3,param4);
         }
         return false;
      }
      
      public function destroy() : void
      {
         this.mTracker = null;
      }
      
      private function isGoal(param1:String, param2:String, param3:String = null, param4:Number = NaN) : Boolean
      {
         if(!Config.GA_GOALS_ENABLED)
         {
            return false;
         }
         if(param1 == "Level" && param2 == MetricConstants.EVENT_PLAY_TUTORIAL)
         {
            return true;
         }
         if(param1 == "Loading" && param2 == MetricConstants.EVENT_LOADING)
         {
            return true;
         }
         return false;
      }
      
      public function registerGoal(param1:String, param2:String, param3:String = null, param4:Number = NaN) : void
      {
         var _loc5_:String = "/" + param1 + "/" + param2 + "/" + param3;
         this.mTracker.trackPageview(_loc5_);
      }
   }
}

