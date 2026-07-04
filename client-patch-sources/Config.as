package
{
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   
   public class Config
   {
      
      public static var OFFLINE_GAMEPLAY_MODE:Boolean = false;
      
      public static var SMART_RESOURCE_LOADING:Boolean = true;
      
      public static var USE_OLD_ICON_SYSTEM:Boolean = false;
      
      public static var USE_BITMAP_DATA_ANIMATIONS:Boolean = USE_OLD_ICON_SYSTEM;
      
      public static var CLIENT_USE_FACEBOOK_API:Boolean = false;
      
      public static var FACEBOOK_CREDITS_AS_CURRENCY:Boolean = true;
      
      public static var FACEBOOK_CREDITS_TO_BUY_GOLD:Boolean = true;
      
      public static var FACEBOOK_CREDITS_OR_OFFERPAL:Boolean = false;
      
      public static var USE_OFFERPAL_IN_POPUP_GOLD:Boolean = false;
      
      public static var USE_OFFERPAL_EXTRA_OPTIONS:Boolean = false;
      
      public static var USE_LOCALE:Boolean = true;
      
      public static var USE_NEIGHBOR_REQUESTS:Boolean = true;
      
      public static var LOAD_RESOURCES_ATTEMPTS_COUNT:int = 2;
      
      public static const AUCTIONS_ENABLED:Boolean = false;
      
      public static const SIG_WHOLE_FILE:Boolean = true;
      
      public static const SIG_ENCRYPT_METHOD:Boolean = true;
      
      public static var OPT_USE_SHORT_FORMAT:Boolean = true;
      
      public static var OPT_USE_BUILD_SHORT_FORMAT:Boolean = false;
      
      public static var DEBUG_MONSTER:Boolean = false;
      
      public static var DEBUG_MODE:Boolean = false;
      
      public static var DEBUG_MISSIONS:Boolean = false;
      
      public static var DEBUG_POLL_MANAGER:Boolean = false;
      
      public static var DEBUG_FACEBOOK:Boolean = false;
      
      public static var DEBUG_SERVER:Boolean = false;
      
      public static var DEBUG_CONSOLE:Boolean = false;
      
      public static var DEBUG_ASSERTS:Boolean = false;
      
      public static const FEATURE_BASE_SMOKE:Boolean = false;
      
      public static const USE_SUPERUPGRADES:Boolean = true;
      
      public static const USE_UPGRADES_VIA_FB_REQUEST:Boolean = false;
      
      public static const USE_ADD_BOOKMARK:Boolean = false;
      
      public static const USE_TOOL_CONTRACT_SIGNATOR:Boolean = true;
      
      public static const USE_CRM_POPUPS:Boolean = true;
      
      public static const USE_NEIGHBOR_LIST:Boolean = true;
      
      public static var USE_CLIMATE:Boolean = false;
      
      public static var USE_OLD_ITEM_DESIGNS:Boolean = false;
      
      public static const COLLECTIBLE_FEATURE_ENABLED:Boolean = true;
      
      public static const COLLECTIBLE_PENDING_LIST_FEATURE_ENABLED:Boolean = false;
      
      public static const COLLECTIBLE_COLLECTION_COMPLETE_FEED:Boolean = false;
      
      public static const COLLECTIBLE_PLACE_REWARD_ENABLED:Boolean = false;
      
      public static const COLLECTIBLE_AUTO_STORAGE_FEATURE:Boolean = true;
      
      public static const COLLECTIBLE_COMMERCES_FEATURE:Boolean = true;
      
      public static const DAILY_BONUS_FEATURE_ENABLED:Boolean = true;
      
      public static const INVESTMENT_REQUEST_ENABLED:Boolean = true;
      
      public static const CROSS_PROMOTION_TIMEOUT_ENABLED:Boolean = true;
      
      public static const CROSS_PROMOTION_TIMEOUT_TIME_MS:int = 2000;
      
      private static const DEFAULT_ROOT:String = "";
      
      public static const DIR_DATA:String = "";
      
      public static const TUNER_XML_FILE:String = DIR_DATA + "tuner.xml";
      
      public static var USE_SOUNDS:Boolean = true;
      
      public static const BUTTON_USE_HAND_CURSOR:Boolean = true;
      
      public static const COOKIE_SETTINGS_NAME:String = "Settings";
      
      public static const COOKIE_SETTINGS_NAME_MUSIC:String = "Music";
      
      public static const COOKIE_SETTINGS_NAME_SFX:String = "Sfx";
      
      public static const COOKIE_SETTINGS_NAME_QUALITY:String = "Quality";
      
      public static const SCREEN_WIDTH:int = 760;
      
      public static const SCREEN_HEIGHT:int = 594;
      
      public static const EDIT_MODE:Boolean = OFFLINE_GAMEPLAY_MODE;
      
      public static const CHEATS_ENABLED:Boolean = false;
      
      public static const CHEATS_VIPS:Boolean = false;
      
      public static const CHEATS_CHECK_ENV:Boolean = true;
      
      public static const CHEAT_VISIT_WORLD:Boolean = CHEATS_ENABLED && false;
      
      public static const CHEAT_TRAFFIC_AGENT:Boolean = CHEATS_ENABLED && false;
      
      public static const CHEAT_TIME_ID:int = 0;
      
      public static const CHEAT_EXP_ID:int = 1;
      
      public static const CHEAT_HARD_RESET_ID:int = 2;
      
      public static const CHEAT_DCCOINS_ID:int = 3;
      
      public static const CHEAT_DCCASH_ID:int = 4;
      
      public static const CHEAT_DEBUG_ID:int = 5;
      
      public static const CHEAT_ANY_ID:int = int.MAX_VALUE;
      
      private static const CHEATS_VIP_ALLOWED_IDS:Array = [CHEAT_DEBUG_ID];
      
      private static const SERVER_BUSY_LIGHT_ENABLED:Boolean = true;
      
      public static const GA_ENABLED:Boolean = true;
      
      public static const GA_GOALS_ENABLED:Boolean = true;
      
      public static const BA_ENABLED:Boolean = false;
      
      public static const CUSTOMIZER_FROM_SERVER:Boolean = true;
      
      public static var SECURE_PROTOCOL:Boolean = false;
      
      private static var mRoot:String = OFFLINE_GAMEPLAY_MODE ? "../Datas/" : DEFAULT_ROOT;
      
      public function Config()
      {
         super();
      }
      
      public static function serverBusyLightIsEnabled() : Boolean
      {
         var _loc1_:Boolean = false;
         if(SERVER_BUSY_LIGHT_ENABLED)
         {
            _loc1_ = !MyMetrics.envIsProduction();
         }
         return _loc1_;
      }
      
      public static function getRoot() : String
      {
         return mRoot;
      }
      
      public static function cheatsAreEnabled(param1:int = 2147483647) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = CHEATS_ENABLED;
         if(CHEATS_VIPS && !CHEATS_ENABLED)
         {
            if(UserDataFacade.getInstance().isUserVIP())
            {
               if(param1 == CHEAT_ANY_ID)
               {
                  _loc2_ = true;
               }
               else
               {
                  _loc3_ = CHEATS_VIP_ALLOWED_IDS.indexOf(param1);
                  _loc2_ = _loc3_ > -1;
               }
            }
         }
         else if(_loc2_ && CHEATS_CHECK_ENV)
         {
            _loc2_ = !MyMetrics.envIsProduction();
         }
         return _loc2_;
      }
      
      public static function setRoot(param1:String) : void
      {
         mRoot = param1;
      }
   }
}
