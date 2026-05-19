package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionsEventIDs;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class PopupMissionUpgrades extends PopupMission
   {
      
      private var mHelpButton:DynamicButton;
      
      public function PopupMissionUpgrades(param1:MissionObject)
      {
         super(param1);
         this.mHelpButton = new DynamicButton(mBox.getChildByName("HelpButton") as MovieClip);
         if(param1.missionDefinition.eventType == MissionsEventIDs.MISSION_EVENT_INSTALL_TOOLBAR)
         {
            this.mHelpButton.setLabel("Install ToolBar");
         }
         else
         {
            this.mHelpButton.setLabel(TextManager.getText(TextIDs.TID_BUTTON_ASK_HELP));
         }
      }
      
      override public function showPopupParams(param1:String, param2:String) : void
      {
         super.showPopupParams(param1,param2);
         this.mHelpButton.start();
         this.mHelpButton.addEventListener(MouseEvent.CLICK,this.onHelpClick);
      }
      
      override protected function close() : void
      {
         this.mHelpButton.end();
         this.mHelpButton.removeEventListener(MouseEvent.CLICK,this.onHelpClick);
         super.close();
      }
      
      override protected function doGetBoxName() : String
      {
         return "upgrades";
      }
      
      private function onHelpClick(param1:MouseEvent) : void
      {
         var _loc2_:URLRequest = null;
         if(mMission.missionDefinition.eventType == MissionsEventIDs.MISSION_EVENT_INSTALL_TOOLBAR)
         {
            _loc2_ = new URLRequest("http://gamebar.digitalchocolate.com/install.html");
            navigateToURL(_loc2_);
         }
         else
         {
            UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_POST_TO_FEED,{
               "postId":UserDataFacade.POST_UPGRADE_ME,
               "fExtId":UserDataFacade.getInstance().mUserExtId,
               "feedImg":""
            });
         }
      }
   }
}

