package com.dchoc.dollars.utils.actions
{
   import com.dchoc.dollars.GUI.MultifunctionBar;
   import com.dchoc.dollars.GUI.ToolsBar;
   import com.dchoc.dollars.GUI.VaultBar;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class ActionsLibrary
   {
      
      private static var smInstance:ActionsLibrary;
      
      public static const GO_TO_SHOP:String = "goToShop";
      
      public static const GO_TO_URL:String = "goToUrl";
      
      public static const GO_TO_INVEST:String = "invest";
      
      public static const GO_TO_MISSIONS:String = "goToMissions";
      
      public static const ADD_GOLD:String = "addGold";
      
      public static const INVITE_FRIEND:String = "invite";
      
      public static const PARTNER_FRIENDS:String = "partners";
      
      public static const UPGRADE_FRIENDS:String = "upgrades";
      
      public static const VISIT_FRIEND:String = "visit";
      
      public static const TOOL_MOVE:String = "tool_move";
      
      public static const TOOL_COLLECT:String = "tool_collect";
      
      public static const TOOL_CONTRACT:String = "tool_contract";
      
      public static const GO_TO_GIFT:String = "gift_shop";
      
      public static const SHOW_FACE_BOX:String = "showFacebox";
      
      public static const SEND_GIFT:String = "send_gift";
      
      public static const BUY:String = "buy";
      
      public static const BOOKMARK:String = "bookmark";
      
      public function ActionsLibrary()
      {
         super();
      }
      
      public static function getInstance() : ActionsLibrary
      {
         if(smInstance == null)
         {
            smInstance = new ActionsLibrary();
         }
         return smInstance;
      }
      
      public function launchAction(param1:String, param2:Array = null) : void
      {
         var _loc3_:URLRequest = null;
         switch(param1)
         {
            case GO_TO_SHOP:
               DollarsGame.smInstance.showBuyBox(param2[0]);
               break;
            case GO_TO_URL:
               _loc3_ = new URLRequest(param2[0]);
               navigateToURL(_loc3_,param2[1]);
               break;
            case GO_TO_INVEST:
               DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.INVEST_BUTTON);
               break;
            case GO_TO_MISSIONS:
               DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.BOSS_BUTTON);
               DollarsGame.getCurrentRole().toolsBar.mMissions.searchMission(param2[0],param2[1]);
               break;
            case ADD_GOLD:
               if(!Config.FACEBOOK_CREDITS_AS_CURRENCY)
               {
                  DollarsGame.addGold();
               }
               break;
            case INVITE_FRIEND:
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_HELP_INVITE_FRIEND);
               break;
            case PARTNER_FRIENDS:
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_PARTNER_REQUEST,{"product":MetricConstants.EVENT_FACEBOOK_FEED_BECOME_PARTNER});
               break;
            case UPGRADE_FRIENDS:
            case VISIT_FRIEND:
               if(param2 != null && param2[0] > -1)
               {
                  DollarsGame.visitUniverse(param2[0]);
               }
               break;
            case TOOL_COLLECT:
               DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.MULTI_FUNCTION_BUTTON);
               DollarsGame.getCurrentRole().toolsBar.getMultifunctionBar().selectTool(MultifunctionBar.BUTTON_COLLECT);
               break;
            case TOOL_MOVE:
               DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.MULTI_FUNCTION_BUTTON);
               DollarsGame.getCurrentRole().toolsBar.getMultifunctionBar().selectTool(MultifunctionBar.BUTTON_MOVE);
               break;
            case TOOL_CONTRACT:
               DollarsGame.getCurrentRole().toolsBar.toolBarSetTool(ToolsBar.MULTI_FUNCTION_BUTTON);
               DollarsGame.getCurrentRole().toolsBar.getMultifunctionBar().selectTool(MultifunctionBar.BUTTON_CONTRACT);
               break;
            case GO_TO_GIFT:
               DollarsGame.getCurrentRole().toolsBar.getVaultBar().selectTool(VaultBar.BUTTON_COLLECTIBLE);
               break;
            case SHOW_FACE_BOX:
               UserDataFacade.getInstance().requestTask(SHOW_FACE_BOX,{
                  "url":param2[0],
                  "title":param2[1]
               });
               break;
            case SEND_GIFT:
            case BUY:
               break;
            case BOOKMARK:
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_BOOKMARK,{});
         }
      }
   }
}

