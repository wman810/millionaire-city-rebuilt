package com.dchoc.dollars.utils.metrics
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   
   public class MyMetrics
   {
      
      private static const PROJECT_ID_FACEBOOK:int = 7;
      
      private static const PROJECT_ID_STANDALONE:int = 9;
      
      private static const PARAMS_COUNT:int = 5;
      
      private static const DEBUG_METRICS:Boolean = false;
      
      public static const ENV_DEV:int = 0;
      
      public static const ENV_STAGE:int = 1;
      
      public static const ENV_PRODUCTION:int = 2;
      
      public function MyMetrics()
      {
         super();
      }
      
      public static function send_GA_metric(param1:String, param2:String, param3:String = null, param4:Number = NaN) : void
      {
         var _loc5_:Boolean = false;
         if(Config.GA_ENABLED)
         {
            _loc5_ = UserDataFacade.getInstance().mUserId % 25 == 0;
            if(param1 == "OutOfSync")
            {
               _loc5_ = true;
            }
            if(_loc5_)
            {
               GAMetrics.getInstance().registerEvent(param1,param2,param3,param4);
            }
            if(Config.BA_ENABLED && param1 == "OutOfSync")
            {
               BAMetrics.getInstance().registerEvent("OoS",plainString(param2));
            }
         }
      }
      
      public static function getGroupFromEvent(param1:String) : String
      {
         switch(param1)
         {
            case MetricConstants.EVENT_SESSION_STARTED:
            case MetricConstants.EVENT_PLAY_TUTORIAL:
            case MetricConstants.EVENT_MISSION_DONE:
            case MetricConstants.EVENT_LEVEL_UP:
            case MetricConstants.EVENT_BOOKMARK:
               return "Level";
            case MetricConstants.EVENT_FACEBOOK_FEED_LEVEL_UP:
            case MetricConstants.EVENT_FACEBOOK_FEED_HELP:
            case MetricConstants.EVENT_FACEBOOK_FEED_THANKS_HELP:
            case MetricConstants.EVENT_FACEBOOK_FEED_NOTIFY_HELP:
            case MetricConstants.EVENT_FACEBOOK_FEED_JOURNAL:
            case MetricConstants.EVENT_FACEBOOK_FEED_MILLION:
            case MetricConstants.EVENT_FACEBOOK_FEED_MISSION_DONE:
            case MetricConstants.EVENT_FACEBOOK_FEED_UPGRADES_DONE:
            case MetricConstants.EVENT_FACEBOOK_FEED_SUPERUPGRADES_DONE:
            case MetricConstants.EVENT_FACEBOOK_FEED_BECOME_PARTNER:
            case MetricConstants.EVENT_FACEBOOK_FEED_NOTIFY_NEW_PARTNERS:
            case MetricConstants.EVENT_FACEBOOK_FEED_NEW_EXPANSION:
            case MetricConstants.EVENT_FACEBOOK_FEED_END_TUTORIAL:
            case MetricConstants.EVENT_FACEBOOK_FEED_CONTRATOR_COLLECT:
            case MetricConstants.EVENT_FACEBOOK_FEED_CONTRATOR_CONTRACT:
            case MetricConstants.EVENT_FACEBOOK_FEED_CONTRATOR_MOVE:
            case MetricConstants.EVENT_FACEBOOK_FEED_GEN:
               return "Social";
            case MetricConstants.EVENT_LOADING:
            case MetricConstants.LABEL_LOADING_RESOURCE_FAIL:
               return "Loading";
            case MetricConstants.EVENT_FPS:
            case MetricConstants.EVENT_FPS_COLLECTING_HI:
            case MetricConstants.EVENT_FPS_COLLECTING_LO:
               return "Performance";
            case MetricConstants.EVENT_TUTORIAL_MISSION_TOOLBAR:
            case MetricConstants.EVENT_INVESTMENTS:
            case MetricConstants.EVENT_FIRST_INGAME_ACTION:
            case MetricConstants.EVENT_FULLSCREEN:
               return "Game";
            case MetricConstants.EVENT_CRM_POPUP:
            case MetricConstants.EVENT_POPUP:
               return "Ingame Popup";
            default:
               return "Economy";
         }
      }
      
      public static function envIsProduction() : Boolean
      {
         return envGetEnvironment() == ENV_PRODUCTION;
      }
      
      public static function sendMetricNG(param1:String, param2:String = null, param3:String = null, param4:String = null, param5:Object = null, param6:int = 0, param7:int = 0, param8:String = null) : void
      {
         var _loc23_:int = 0;
         if(param1 == MetricConstants.EVENT_SPEND_GOLD)
         {
            if(!Profile.smCashPaidUsed)
            {
               param1 = MetricConstants.EVENT_SPEND_FREE_GOLD;
            }
         }
         var _loc9_:Wcrm = new Wcrm();
         var _loc10_:Object = Dollars.smStage.root.loaderInfo.parameters;
         var _loc11_:String = _loc10_.wcrm_user;
         var _loc12_:int = int(_loc10_.wcrm_env);
         var _loc13_:String = null;
         var _loc14_:String = _loc10_.wcrm_ref;
         var _loc15_:String = null;
         var _loc16_:Profile = DollarsGame.getProfile();
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         if(_loc16_ != null)
         {
            _loc17_ = int(_loc16_.isFan);
            _loc18_ = int(_loc16_.level);
            _loc19_ = _loc16_.DCCoins;
         }
         if(FriendsManager.getNeightbors() != null)
         {
            _loc20_ = int(FriendsManager.getNeightbors().length);
         }
         var _loc21_:int = 0;
         if(param2 == null)
         {
            param2 = "Confirmed";
         }
         if(param8 == null)
         {
            param8 = getGroupFromEvent(param1);
         }
         if(_loc10_.swf_version != null)
         {
            _loc15_ = _loc10_.swf_version;
         }
         if(DEBUG_METRICS)
         {
            Debug.trace("1.group: " + param8);
            Debug.trace("1.type: " + param1);
            Debug.trace("1.label: " + param2);
            Debug.trace("1.product: " + param3);
            Debug.trace("1.product_detail: " + param4);
         }
         var _loc22_:Array = new Array(PARAMS_COUNT);
         if(param5 != null)
         {
            _loc22_[0] = param5.p1;
            _loc22_[1] = param5.p2;
            _loc22_[2] = param5.p3;
            _loc22_[3] = param5.p4;
            _loc22_[4] = param5.p5;
            _loc23_ = 0;
            while(_loc23_ < PARAMS_COUNT)
            {
               if(_loc22_[_loc23_] == undefined)
               {
                  _loc22_[_loc23_] = null;
               }
               _loc23_++;
            }
         }
         _loc9_.wcrmTrackEventFbUserId(_loc11_,_loc12_,getProjectId(),param1,param8,param2,null,null,0,_loc22_[0],_loc22_[1],_loc22_[2],_loc22_[3],_loc22_[4],_loc13_,_loc14_,_loc18_,param3,param4,null,null,0,0,0,param6,_loc19_,0,param7,0,0,0,0,0,_loc20_,_loc20_,_loc17_,_loc21_,null,0,0,0,0,0,null,_loc15_);
         if(forwardToGA(param1))
         {
            send_GA_metric(param8,param1,param2,param7);
         }
      }
      
      public static function sendMetric(param1:String, param2:String = null, param3:Object = null, param4:String = null, param5:int = 0, param6:int = 0, param7:String = null) : void
      {
         sendMetricNG(param1,param2,param4,null,param3,param5,param6,param7);
      }
      
      public static function envGetEnvironment() : int
      {
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         return _loc1_.wcrm_env;
      }
      
      private static function forwardToGA(param1:String) : Boolean
      {
         if(param1 == MetricConstants.EVENT_PLAY_TUTORIAL)
         {
            return true;
         }
         return false;
      }
      
      private static function plainString(param1:String) : String
      {
         var _loc2_:String = "";
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1.charAt(_loc3_) != " " && param1.charAt(_loc3_) != "." && param1.charAt(_loc3_) != ":")
            {
               _loc2_ += param1.charAt(_loc3_);
            }
            else
            {
               _loc2_ += "_";
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function getProjectId() : int
      {
         var _loc1_:Object = Dollars.smStage.root.loaderInfo.parameters;
         var _loc2_:String = _loc1_.platform;
         if(_loc2_ != null && _loc2_ == "standalone")
         {
            return PROJECT_ID_STANDALONE;
         }
         return PROJECT_ID_FACEBOOK;
      }
   }
}

