package com.dchoc.dollars.utils.metrics
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.server.Server;
   import com.dchoc.dollars.utils.debug.Debug;
   import flash.events.Event;
   import flash.net.URLLoader;
   
   public class CheckConfirmEmail extends CheckCRMURL
   {
      
      private static var smInstance:CheckConfirmEmail;
      
      private static var smAllowInstantiation:Boolean;
      
      public static const MISSION_SKU:String = "64";
      
      public static const MAIL_CHECKED:String = "2";
      
      public static const MAIL_CHECKING:String = "1";
      
      public static const MAIL_UNCHECKED:String = "0";
      
      private static const URL_CHECK:String = Config.getRoot() + ModelConfig.DIR_FRIENDS + "checkMail.html";
      
      public function CheckConfirmEmail()
      {
         super();
         if(!smAllowInstantiation)
         {
            throw new Error("ERROR: CrossPromotion Error: Instantiation failed: Use CrossPromotion.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : CheckConfirmEmail
      {
         if(smInstance == null)
         {
            smAllowInstantiation = true;
            smInstance = new CheckConfirmEmail();
            smAllowInstantiation = false;
         }
         return smInstance;
      }
      
      override protected function checkStatus(param1:Event) : void
      {
         var _loc3_:MissionObject = null;
         var _loc2_:URLLoader = URLLoader(param1.target);
         if(Config.DEBUG_MODE)
         {
            Debug.trace("email: " + _loc2_.data);
         }
         if(_loc2_.data == "1")
         {
            _loc3_ = MissionObjectManager.getInstance().getMissionBySku(MISSION_SKU);
            _loc3_.changeState(MissionObject.STATE_REACHED);
            DollarsGame.getProfile().checkmail = MAIL_CHECKED;
         }
      }
      
      public function load() : void
      {
         var _loc2_:String = null;
         var _loc1_:String = DollarsGame.smCRMhash;
         if(Config.OFFLINE_GAMEPLAY_MODE)
         {
            _loc2_ = URL_CHECK;
         }
         else
         {
            _loc2_ = Server.wcrmServerURL + "/registration/isconfirmed/?fb_user_id=" + UserDataFacade.getInstance().mUserExtId + "&project_id=" + MyMetrics.getProjectId() + "&sig=" + _loc1_;
         }
         readUrl(_loc2_);
      }
   }
}

