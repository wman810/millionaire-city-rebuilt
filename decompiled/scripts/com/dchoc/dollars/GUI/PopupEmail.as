package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.friends.FriendsManager;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.ShowPopup;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.server.Server;
   import com.dchoc.dollars.utils.metrics.CheckConfirmEmail;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class PopupEmail extends PopupMissionEditText
   {
      
      private static const URL_CHECK:String = Config.getRoot() + ModelConfig.DIR_FRIENDS + "checkSendMail.xml";
      
      private const MAIL_CORRECT:int = 0;
      
      private var mPopupMessage:PopupMessage;
      
      private var mMailUserField:TextField;
      
      private var mCheckBoxObject:MovieClip;
      
      private const RESTRINCTION_CHARS:String = "A-Z a-z 0-9 . ! # $ % & \' * + \\- / = ? \\^ _ ` \\{ \\| \\} ~";
      
      private var mUnderlineField:TextField;
      
      private var mErrorMailY:Number;
      
      private const MAIL_USER_EXIST:int = 1;
      
      private var mSpContent:Sprite;
      
      private var mCheckBox:CheckBox;
      
      private const MAIL_EXIST:int = 2;
      
      private var mMailDomainField:TextField;
      
      private var mTimeoutId:int;
      
      private var mLoader:URLLoader;
      
      private const MAIL_INVALID:int = 3;
      
      private var mMailReady:Boolean;
      
      public function PopupEmail(param1:MissionObject)
      {
         super(param1);
         this.mTimeoutId = 0;
         this.mMailUserField = mBox.getChildByName("NameEmail1") as TextField;
         this.mMailDomainField = mBox.getChildByName("DomainEmail1") as TextField;
         TextManager.reformatTextField(this.mMailUserField);
         TextManager.reformatTextField(this.mMailDomainField);
         this.mMailUserField.text = "example";
         this.mMailDomainField.text = "domain.com";
         this.mMailUserField.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
         this.mMailUserField.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
         this.mMailDomainField.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
         this.mMailDomainField.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
         this.mMailUserField.addEventListener(MouseEvent.CLICK,this.onMailUserClick);
         this.mMailDomainField.addEventListener(MouseEvent.CLICK,this.onMailDomainClick);
         this.mMailUserField.addEventListener(FocusEvent.FOCUS_OUT,this.onCheckMail);
         this.mMailUserField.restrict = this.RESTRINCTION_CHARS;
         this.mMailDomainField.restrict = "A-Z a-z 0-9 . _";
         this.mCheckBoxObject = mBox.getChildByName("CheckBox") as MovieClip;
         this.mCheckBox = new CheckBox(this.mCheckBoxObject);
         this.mCheckBox.addEventListener(MouseEvent.CLICK,this.onCheckPressed);
         this.mSpContent = mBox.getChildByName("checkBoxText") as Sprite;
         this.mSpContent.buttonMode = true;
         this.mSpContent.mouseChildren = false;
         this.mUnderlineField = this.mSpContent.getChildByName("Conditions") as TextField;
         var _loc2_:TextFormat = this.mUnderlineField.defaultTextFormat;
         _loc2_.underline = true;
         this.mUnderlineField.defaultTextFormat = _loc2_;
         this.mUnderlineField.text = TextManager.getText(TextIDs.TID_MISSION64_CHECK_LEGAL_TEXT);
         this.mUnderlineField.selectable = false;
         TextManager.reformatTextField(this.mUnderlineField);
         this.mSpContent.addEventListener(MouseEvent.CLICK,this.onTermsClick);
         this.mMailReady = false;
         var _loc3_:TextField = mBox.getChildByName("TextInfo") as TextField;
         this.mErrorMailY = _loc3_.y;
         _loc3_.y -= (_loc3_.height - _loc3_.textHeight) / 2;
         this.mMailUserField.tabIndex = 0;
         this.mMailDomainField.tabIndex = 1;
      }
      
      override protected function doGetBoxName() : String
      {
         return "Email";
      }
      
      private function resetMailFields() : void
      {
         this.mMailUserField.text = "";
         this.mMailDomainField.text = "";
         this.mCheckBox.resetFrameCheckbox();
         mOkButton.disable();
      }
      
      private function onTermsClick(param1:MouseEvent) : void
      {
         var _loc2_:URLRequest = new URLRequest("http://www.digitalchocolate.com/privacy-security/");
         navigateToURL(_loc2_);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.mMailUserField = null;
         this.mMailDomainField = null;
      }
      
      private function onIOError(param1:IOErrorEvent = null) : void
      {
         clearTimeout(this.mTimeoutId);
         if(this.mLoader != null)
         {
            this.mLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
            this.mLoader.removeEventListener(Event.COMPLETE,this.checkMailSent);
            if(param1 == null)
            {
               this.mLoader.close();
               this.mLoader = null;
            }
         }
         ShowPopup.show(0,TextManager.getText(TextIDs.TID_MISSION64_CANTSENT_ERROR));
         ShowPopup.setActionCancel(onClose,null);
      }
      
      private function onCheckPressed(param1:MouseEvent) : void
      {
         if(mOkButton.Enabled)
         {
            mOkButton.disable();
         }
         else if(this.mMailReady)
         {
            mOkButton.enable();
         }
      }
      
      private function onClosePopup(param1:Event) : void
      {
         ShowPopup.close();
      }
      
      private function onMailUserClick(param1:MouseEvent) : void
      {
         this.mMailUserField.removeEventListener(MouseEvent.CLICK,this.onMailUserClick);
         this.mMailUserField.text = "";
      }
      
      override public function showPopupParams(param1:String, param2:String) : void
      {
         mOkButton.start();
         mOkButton.addEventListener(MouseEvent.CLICK,this.checkMail);
         mOkButton.disable();
         this.mCheckBox.start();
         mBox.addChild(this.mCheckBox);
         super.showPopupParams(param1,param2);
      }
      
      private function onCheckMail(param1:Event) : void
      {
         if(this.mMailUserField.text != "")
         {
            this.mMailReady = true;
            if(this.mCheckBox.Checked)
            {
               mOkButton.enable();
            }
         }
      }
      
      override protected function close() : void
      {
         mOkButton.end();
         mOkButton.removeEventListener(MouseEvent.CLICK,this.checkMail);
         this.mCheckBox.end();
         mBox.removeChild(this.mCheckBox);
         super.close();
      }
      
      private function checkMail(param1:Event) : void
      {
         var _loc2_:TextField = mBox.getChildByName("TextInfo") as TextField;
         TextManager.reformatTextField(_loc2_);
         var _loc3_:String = this.mMailUserField.text + "@" + this.mMailDomainField.text;
         if(!TextManager.isMail(_loc3_))
         {
            _loc2_.text = TextManager.getText(TextIDs.TID_MISSION64_SINTAX_ERROR);
            _loc2_.textColor = 16711680;
            _loc2_.y = this.mErrorMailY + (_loc2_.height - _loc2_.textHeight) / 2;
         }
         else if(this.mMailDomainField.text.indexOf("domain") > -1)
         {
            _loc2_.text = TextManager.getText(TextIDs.TID_MESSION64_POPUPERROR3);
            _loc2_.textColor = 16711680;
            _loc2_.y = this.mErrorMailY + (_loc2_.height - _loc2_.textHeight) / 2;
         }
         else
         {
            mOkButton.disable();
            this.sendMail();
         }
      }
      
      private function sendMail() : void
      {
         var hashencrypted:String = null;
         var fb_user_id:String = null;
         var url:String = null;
         var req:URLRequest = null;
         try
         {
            hashencrypted = DollarsGame.smCRMhash;
            fb_user_id = UserDataFacade.getInstance().mUserExtId;
            if(Config.OFFLINE_GAMEPLAY_MODE)
            {
               url = URL_CHECK;
            }
            else
            {
               url = Server.wcrmServerURL + "/registration/register/?fb_user_id=" + fb_user_id + "&email=" + (this.mMailUserField.text + "@" + this.mMailDomainField.text) + "&project_id=" + MyMetrics.getProjectId() + "&v=1&sig=" + hashencrypted + "&user_name=" + UserDataFacade.getInstance().mUserName + "&user_image=" + FriendsManager.mNeighborMyself.getPictureURL();
            }
            req = new URLRequest(url);
            this.mLoader = new URLLoader();
            this.mLoader.load(req);
            this.mLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
            this.mLoader.addEventListener(Event.COMPLETE,this.checkMailSent);
            this.mTimeoutId = setTimeout(this.onIOError,15000);
         }
         catch(e:Error)
         {
            onIOError(null);
         }
      }
      
      private function onCloseMessage(param1:Event) : void
      {
      }
      
      private function checkMailSent(param1:Event) : void
      {
         var _loc3_:String = null;
         clearTimeout(this.mTimeoutId);
         this.mLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
         this.mLoader.removeEventListener(Event.COMPLETE,this.checkMailSent);
         var _loc2_:XML = new XML(this.mLoader.data);
         switch(int(_loc2_.status))
         {
            case this.MAIL_CORRECT:
            case this.MAIL_USER_EXIST:
            case this.MAIL_EXIST:
               _loc3_ = TextManager.replaceParameters(TextIDs.TID_MISSION64_EMAIL_ADVICE,[this.mMailUserField.text + "@" + this.mMailDomainField.text]);
               ShowPopup.show(ShowPopup.POPUP_MSG,_loc3_);
               ShowPopup.setActionCancel(onClose,null);
               if(DollarsGame.getProfile().checkmail == CheckConfirmEmail.MAIL_UNCHECKED)
               {
                  DollarsGame.getProfile().checkmail = CheckConfirmEmail.MAIL_CHECKING;
               }
               break;
            case this.MAIL_INVALID:
               this.resetMailFields();
               ShowPopup.show(ShowPopup.POPUP_MSG_SMALL,TextManager.getText(TextIDs.TID_MISSION64_SINTAX_ERROR));
         }
         _loc2_ = null;
      }
      
      private function onMailDomainClick(param1:MouseEvent) : void
      {
         this.mMailDomainField.removeEventListener(MouseEvent.CLICK,this.onMailDomainClick);
         this.mMailDomainField.text = "";
      }
   }
}

