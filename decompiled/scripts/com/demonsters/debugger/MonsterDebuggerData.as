package com.demonsters.debugger
{
   import flash.utils.ByteArray;
   
   public class MonsterDebuggerData
   {
      
      private var _data:Object;
      
      private var _id:String;
      
      public function MonsterDebuggerData(param1:String, param2:Object)
      {
         super();
         _id = param1;
         _data = param2;
      }
      
      public static function read(param1:ByteArray) : MonsterDebuggerData
      {
         var _loc2_:MonsterDebuggerData = new MonsterDebuggerData(null,null);
         _loc2_.bytes = param1;
         return _loc2_;
      }
      
      public function get data() : Object
      {
         return _data;
      }
      
      public function set bytes(param1:ByteArray) : void
      {
         var value:ByteArray = param1;
         var bytesId:ByteArray = new ByteArray();
         var bytesData:ByteArray = new ByteArray();
         try
         {
            value.readBytes(bytesId,0,value.readUnsignedInt());
            value.readBytes(bytesData,0,value.readUnsignedInt());
            _id = bytesId.readObject() as String;
            _data = bytesData.readObject() as Object;
         }
         catch(e:Error)
         {
            _id = null;
            _data = null;
         }
         bytesId = null;
         bytesData = null;
      }
      
      public function get id() : String
      {
         return _id;
      }
      
      public function get bytes() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         var _loc2_:ByteArray = new ByteArray();
         _loc1_.writeObject(_id);
         _loc2_.writeObject(_data);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUnsignedInt(_loc1_.length);
         _loc3_.writeBytes(_loc1_);
         _loc3_.writeUnsignedInt(_loc2_.length);
         _loc3_.writeBytes(_loc2_);
         _loc3_.position = 0;
         _loc1_ = null;
         _loc2_ = null;
         return _loc3_;
      }
   }
}

