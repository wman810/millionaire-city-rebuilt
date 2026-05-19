package com.demonsters.debugger
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.Socket;
   import flash.system.Security;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   internal class MonsterDebuggerConnectionDefault implements IMonsterDebuggerConnection
   {
      
      private var _length:uint;
      
      private var _package:ByteArray;
      
      private var _onConnect:Function;
      
      private const MAX_QUEUE_LENGTH:int = 500;
      
      private var _queue:Array = [];
      
      private var _connecting:Boolean;
      
      private var _socket:Socket;
      
      private var _timeout:Timer;
      
      private var _port:int;
      
      private var _retry:Timer;
      
      private var _bytes:ByteArray;
      
      private var _process:Boolean;
      
      private var _address:String;
      
      public function MonsterDebuggerConnectionDefault()
      {
         super();
         _socket = new Socket();
         _socket.addEventListener(Event.CONNECT,connectHandler,false,0,false);
         _socket.addEventListener(Event.CLOSE,closeHandler,false,0,false);
         _socket.addEventListener(IOErrorEvent.IO_ERROR,closeHandler,false,0,false);
         _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,closeHandler,false,0,false);
         _socket.addEventListener(ProgressEvent.SOCKET_DATA,dataHandler,false,0,false);
         _connecting = false;
         _process = false;
         _address = "127.0.0.1";
         _port = 5800;
         _timeout = new Timer(2000,1);
         _timeout.addEventListener(TimerEvent.TIMER,closeHandler,false,0,false);
         _retry = new Timer(1000,1);
         _retry.addEventListener(TimerEvent.TIMER,retryHandler,false,0,false);
      }
      
      private function dataHandler(param1:ProgressEvent) : void
      {
         _bytes = new ByteArray();
         _socket.readBytes(_bytes,0,_socket.bytesAvailable);
         _bytes.position = 0;
         processPackage();
      }
      
      public function send(param1:String, param2:Object, param3:Boolean = false) : void
      {
         var _loc4_:ByteArray = null;
         if(param3 && param1 == MonsterDebuggerCore.ID && _socket.connected)
         {
            _loc4_ = new MonsterDebuggerData(param1,param2).bytes;
            _socket.writeUnsignedInt(_loc4_.length);
            _socket.writeBytes(_loc4_);
            _socket.flush();
            return;
         }
         _queue.push(new MonsterDebuggerData(param1,param2));
         if(_queue.length > MAX_QUEUE_LENGTH)
         {
            _queue.shift();
         }
         if(_queue.length > 0)
         {
            next();
         }
      }
      
      public function get connected() : Boolean
      {
         if(_socket == null)
         {
            return false;
         }
         return _socket.connected;
      }
      
      private function next() : void
      {
         if(!MonsterDebugger.enabled)
         {
            return;
         }
         if(!_process)
         {
            return;
         }
         if(!_socket.connected)
         {
            connect();
            return;
         }
         var _loc1_:ByteArray = MonsterDebuggerData(_queue.shift()).bytes;
         _socket.writeUnsignedInt(_loc1_.length);
         _socket.writeBytes(_loc1_);
         _socket.flush();
         _loc1_ = null;
         if(_queue.length > 0)
         {
            next();
         }
      }
      
      private function retryHandler(param1:TimerEvent) : void
      {
         _retry.stop();
         connect();
      }
      
      public function set onConnect(param1:Function) : void
      {
         _onConnect = param1;
      }
      
      private function processPackage() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:MonsterDebuggerData = null;
         if(_bytes.bytesAvailable == 0)
         {
            return;
         }
         if(_length == 0)
         {
            _length = _bytes.readUnsignedInt();
            _package = new ByteArray();
         }
         if(_package.length < _length && _bytes.bytesAvailable > 0)
         {
            _loc1_ = _bytes.bytesAvailable;
            if(_loc1_ > _length - _package.length)
            {
               _loc1_ = _length - _package.length;
            }
            _bytes.readBytes(_package,_package.length,_loc1_);
         }
         if(_length != 0 && _package.length == _length)
         {
            _loc2_ = MonsterDebuggerData.read(_package);
            if(_loc2_.id != null)
            {
               MonsterDebuggerCore.handle(_loc2_);
            }
            _length = 0;
            _package = null;
         }
         if(_length == 0 && _bytes.bytesAvailable > 0)
         {
            processPackage();
         }
      }
      
      public function set address(param1:String) : void
      {
         _address = param1;
      }
      
      private function connectHandler(param1:Event) : void
      {
         _timeout.stop();
         _retry.stop();
         if(_onConnect != null)
         {
            _onConnect();
         }
         _connecting = false;
         _bytes = new ByteArray();
         _package = new ByteArray();
         _length = 0;
         _socket.writeUTFBytes("<hello/>" + "\n");
         _socket.writeByte(0);
         _socket.flush();
      }
      
      public function processQueue() : void
      {
         if(!_process)
         {
            _process = true;
            if(_queue.length > 0)
            {
               next();
            }
         }
      }
      
      private function closeHandler(param1:Event = null) : void
      {
         MonsterDebuggerUtils.resume();
         if(!_retry.running)
         {
            _connecting = false;
            _process = false;
            _timeout.stop();
            _retry.reset();
            _retry.start();
         }
      }
      
      public function connect() : void
      {
         if(!_connecting && MonsterDebugger.enabled)
         {
            try
            {
               Security.loadPolicyFile("xmlsocket://" + _address + ":" + _port);
               _connecting = true;
               _socket.connect(_address,_port);
               _retry.stop();
               _timeout.reset();
               _timeout.start();
            }
            catch(e:Error)
            {
               closeHandler();
            }
         }
      }
   }
}

