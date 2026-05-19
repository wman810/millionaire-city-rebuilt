package com.dchoc.dollars.server
{
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class UserListQuery extends Sprite
   {
      
      public static var smResetGame:Boolean = false;
      
      private var mServer:Server;
      
      private var textOnOff:TextField;
      
      public function UserListQuery(param1:Server)
      {
         var _loc5_:String = null;
         var _loc6_:TextField = null;
         this.textOnOff = new TextField();
         super();
         this.mServer = param1;
         Debug.trace("...SELECT USER to LOGIN...");
         this.textOnOff = new TextField();
         this.textOnOff.text = "RESET: OFF";
         this.textOnOff.x = 5;
         this.textOnOff.y = 5;
         this.textOnOff.textColor = 16711935;
         this.textOnOff.mouseEnabled = true;
         this.textOnOff.width += 60;
         this.textOnOff.addEventListener(MouseEvent.CLICK,this.onGameResetSelected);
         addChild(this.textOnOff);
         var _loc2_:Array = new Array();
         _loc2_ = ["Juan","Juha"];
         var _loc3_:int = 80;
         var _loc4_:int = 10;
         for each(_loc5_ in _loc2_)
         {
            _loc6_ = new TextField();
            _loc6_.text = _loc5_;
            _loc6_.x = _loc3_;
            _loc6_.y = _loc4_;
            _loc6_.textColor = 16711935;
            _loc6_.scaleY = 2;
            _loc6_.mouseEnabled = true;
            _loc6_.width += 60;
            _loc6_.addEventListener(MouseEvent.MOUSE_DOWN,this.onUserListSelected);
            addChild(_loc6_);
            _loc4_ += 40;
            if(_loc4_ > 400)
            {
               _loc4_ = 10;
               _loc3_ += 200;
            }
         }
         Dollars.smStage.addChild(this);
      }
      
      private function onUserListSelected(param1:Event) : void
      {
         var _loc2_:String = null;
         Dollars.smStage.removeChild(this);
         if(param1.target.text == "> Guest <")
         {
            UserDataFacade.setInstanceOffline();
         }
         else
         {
            switch(param1.target.text)
            {
               case "Juan":
                  _loc2_ = "1132943641";
                  break;
               case "Juha":
                  _loc2_ = "734267601";
            }
            this.mServer.login(_loc2_,"pass");
         }
      }
      
      private function onGameResetSelected(param1:Event) : void
      {
         smResetGame = !smResetGame;
         if(smResetGame)
         {
            this.textOnOff.text = "RESET: ON";
         }
         else
         {
            this.textOnOff.text = "RESET: OFF";
         }
      }
   }
}

