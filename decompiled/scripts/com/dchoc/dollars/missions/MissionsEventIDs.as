package com.dchoc.dollars.missions
{
   public class MissionsEventIDs
   {
      
      public static const MISSION_EVENT_BUILD_ITEM:String = "build";
      
      public static const MISSION_EVENT_BUILD_ROAD:String = "buildRoads";
      
      public static const MISSION_EVENT_SELL_ITEM:String = "sell";
      
      public static const MISSION_EVENT_BUY_ITEM:String = "buy";
      
      public static const MISSION_EVENT_BUY_EXPANSION:String = "buyExpansion";
      
      public static const MISSION_EVENT_COLLECT_INCOME:String = "collect";
      
      public static const MISSION_EVENT_CHECK_INFLUENCE:String = "checkInfluence";
      
      public static const MISSION_EVENT_CHECK_BONUS:String = "bonus";
      
      public static const MISSION_EVENT_INSTANT_BUILD:String = "instantBuild";
      
      public static const MISSION_EVENT_INFORMATIVE:String = "informative";
      
      public static const MISSION_EVENT_ASK_FOR_HELP:String = "askForHelp";
      
      public static const MISSION_EVENT_EARN:String = "earn";
      
      public static const MISSION_EVENT_UPGRADE:String = "upgrade";
      
      public static const MISSION_EVENT_RENOVATE:String = "renovate";
      
      public static const MISSION_EVENT_REPAIR:String = "repair";
      
      public static const MISSION_EVENT_VISIT_RONALD:String = "visitRonald";
      
      public static const MISSION_EVENT_VISIT_FRIEND:String = "visitFriend";
      
      public static const MISSION_EVENT_VISIT_CITY:String = "visitCity";
      
      public static const MISSION_EVENT_VISIT_PARTNER:String = "visitPartner";
      
      public static const MISSION_EVENT_BEAT:String = "beat";
      
      public static const MISSION_EVENT_INVESTMENT:String = "investment";
      
      public static const MISSION_EVENT_INVESTMENT_DONE:String = "investmentDone";
      
      public static const MISSION_EVENT_COLLECT_UPGRADED:String = "collectUpgraded";
      
      public static const MISSION_EVENT_INSTALL_TOOLBAR:String = "checkToolbar";
      
      public static const MISSION_EVENT_GIVE_EMAIL:String = "giveEmail";
      
      public static const MISSION_EVENT_NAME_CITY:String = "nameCity";
      
      public static const MISSION_EVENT_MOVE_HOUSE:String = "moveHouse";
      
      public function MissionsEventIDs()
      {
         super();
      }
      
      public function countsOccurrences(param1:String) : Boolean
      {
         return param1 != MISSION_EVENT_CHECK_INFLUENCE;
      }
   }
}

