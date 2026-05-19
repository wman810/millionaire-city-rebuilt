package com.luaye.console.core
{
   import com.luaye.console.Console;
   import flash.events.EventDispatcher;
   import flash.events.SecurityErrorEvent;
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   import flash.system.Security;
   
   public class Remoting extends EventDispatcher
   {
      
      public static const REMOTE_PREFIX:String = "R";
      
      public static const CLIENT_PREFIX:String = "C";
      
      private var _master:Console;
      
      private var _sharedConnection:LocalConnection;
      
      private var _logsend:Function;
      
      private var _remoteLinesQueue:Array;
      
      private var _loggedIn:Boolean;
      
      private var _isRemoting:Boolean;
      
      private var _isRemote:Boolean;
      
      private var _lastLogin:String = "";
      
      public var remoteMem:int;
      
      private var _mspfsForRemote:Array;
      
      private var _remoteDelayed:int;
      
      public function Remoting(param1:Console, param2:Function)
      {
         super();
         this._master = param1;
         this._logsend = param2;
      }
      
      public function get remoting() : Boolean
      {
         return this._isRemoting;
      }
      
      public function set remoting(param1:Boolean) : void
      {
         var newV:Boolean = param1;
         this._remoteLinesQueue = null;
         this._mspfsForRemote = null;
         if(newV)
         {
            this._isRemote = false;
            this._remoteDelayed = 0;
            this._mspfsForRemote = [30];
            this._remoteLinesQueue = new Array();
            this.startSharedConnection();
            this._sharedConnection.addEventListener(StatusEvent.STATUS,this.onRemotingStatus);
            this._sharedConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRemotingSecurityError);
            try
            {
               this._sharedConnection.connect(Console.REMOTING_CONN_NAME + CLIENT_PREFIX);
               this._master.report("<b>Remoting started.</b> " + this.getInfo(),-1);
               this._isRemoting = true;
               this._loggedIn = this._master.checkLogin("");
               if(this._loggedIn)
               {
                  this._remoteLinesQueue = this._master.getLogsAsObjects();
                  this.send("loginSuccess");
               }
               else
               {
                  this.send("requestLogin");
               }
            }
            catch(error:Error)
            {
               _master.report("Could not create client service. You will not be able to control this console with remote.",10);
            }
         }
         else
         {
            this._isRemoting = false;
            this.close();
         }
      }
      
      private function startSharedConnection() : void
      {
         this.close();
         this._sharedConnection = new LocalConnection();
         this._sharedConnection.allowDomain("*");
         this._sharedConnection.allowInsecureDomain("*");
         this._sharedConnection.client = {
            "login":this.login,
            "requestLogin":this.requestLogin,
            "loginFail":this.loginFail,
            "loginSuccess":this.loginSuccess,
            "logSend":this._logsend,
            "gc":this._master.gc,
            "runCommand":this._master.runCommand
         };
      }
      
      public function send(param1:String, ... rest) : void
      {
         var command:String = param1;
         var args:Array = rest;
         var target:String = Console.REMOTING_CONN_NAME + (this._isRemote ? CLIENT_PREFIX : REMOTE_PREFIX);
         args = [target,command].concat(args);
         try
         {
            this._sharedConnection.send.apply(this,args);
         }
         catch(e:Error)
         {
         }
      }
      
      private function printHowToGlobalSetting() : void
      {
         this._master.report("Make sure your flash file is \'trusted\' in Global Security Settings.",-2);
         this._master.report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\' (on left) &gt; add the location of the local flash (swf) file.",-2);
      }
      
      public function update(param1:Number, param2:Number = NaN) : void
      {
         var _loc3_:* = 0;
         var _loc4_:Array = null;
         ++this._remoteDelayed;
         if(!this._loggedIn)
         {
            return;
         }
         this._mspfsForRemote.push(param1);
         if(param2)
         {
            _loc3_ = int(Math.floor(param1 / (1000 / param2)));
            if(_loc3_ > Console.FPS_MAX_LAG_FRAMES)
            {
               _loc3_ = int(Console.FPS_MAX_LAG_FRAMES);
            }
            while(_loc3_ > 1)
            {
               this._mspfsForRemote.push(param1);
               _loc3_--;
            }
         }
         if(this._remoteDelayed >= this._master.remoteDelay)
         {
            this._remoteDelayed = 0;
            _loc4_ = new Array();
            if(this._remoteLinesQueue.length > 20)
            {
               _loc4_ = this._remoteLinesQueue.splice(20);
               this._remoteDelayed = this._master.remoteDelay;
            }
            this.send("logSend",[this._remoteLinesQueue,this._mspfsForRemote,this._master.currentMemory,this._master.cl.scopeString]);
            this._remoteLinesQueue = _loc4_;
            this._mspfsForRemote = [param2 ? param2 : 30];
         }
      }
      
      private function onRemotingStatus(param1:StatusEvent) : void
      {
      }
      
      private function onRemotingSecurityError(param1:SecurityErrorEvent) : void
      {
         this._master.report("Sandbox security error.",10);
         this.printHowToGlobalSetting();
      }
      
      public function addLineQueue(param1:Log) : void
      {
         if(!this._loggedIn)
         {
            return;
         }
         this._remoteLinesQueue.push(param1.toObject());
         var _loc2_:int = this._master.maxLines;
         if(this._remoteLinesQueue.length > _loc2_ && _loc2_ > 0)
         {
            this._remoteLinesQueue.splice(0,1);
         }
      }
      
      public function get isRemote() : Boolean
      {
         return this._isRemote;
      }
      
      public function set isRemote(param1:Boolean) : void
      {
         var sdt:String = null;
         var newV:Boolean = param1;
         this._isRemote = newV;
         if(newV)
         {
            this._isRemoting = false;
            this.startSharedConnection();
            this._sharedConnection.addEventListener(StatusEvent.STATUS,this.onRemoteStatus);
            this._sharedConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRemotingSecurityError);
            try
            {
               this._sharedConnection.connect(Console.REMOTING_CONN_NAME + REMOTE_PREFIX);
               this._master.report("<b>Remote started.</b> " + this.getInfo(),-1);
               sdt = Security.sandboxType;
               if(sdt == Security.LOCAL_WITH_FILE || sdt == Security.LOCAL_WITH_NETWORK)
               {
                  this._master.report("Untrusted local sandbox. You may not be able to listen for logs properly.",10);
                  this.printHowToGlobalSetting();
               }
               this.login(this._lastLogin);
            }
            catch(error:Error)
            {
               _isRemoting = false;
               _master.report("Could not create remote service. You might have a console remote already running.",10);
            }
         }
         else
         {
            this.close();
         }
      }
      
      public function loginSuccess() : void
      {
         this._master.report("Login Successful",-1);
      }
      
      private function getInfo() : String
      {
         return "</p5>channel:<p5>" + Console.REMOTING_CONN_NAME + " (" + Security.sandboxType + ")";
      }
      
      public function loginFail() : void
      {
         this._master.report("Login Failed",10);
         this._master.panels.mainPanel.requestLogin();
      }
      
      public function requestLogin() : void
      {
         if(this._lastLogin)
         {
            this.login(this._lastLogin);
         }
         else
         {
            this._master.panels.mainPanel.requestLogin();
         }
      }
      
      public function login(param1:String = null) : void
      {
         if(this._isRemote)
         {
            this._lastLogin = param1;
            this._master.report("Attempting to login...",-1);
            this.send("login",param1);
         }
         else if(this._loggedIn || this._master.checkLogin(param1))
         {
            this._loggedIn = true;
            this._remoteLinesQueue = this._master.getLogsAsObjects();
            this.send("loginSuccess");
         }
         else
         {
            this.send("loginFail");
         }
      }
      
      public function close() : void
      {
         if(this._sharedConnection)
         {
            try
            {
               this._sharedConnection.close();
            }
            catch(error:Error)
            {
               _master.report("Remote.close: " + error,10);
            }
         }
         this._sharedConnection = null;
      }
      
      private function onRemoteStatus(param1:StatusEvent) : void
      {
         if(this._isRemote && param1.level == "error")
         {
            this._master.report("Problem communicating to client.",10);
         }
      }
   }
}

