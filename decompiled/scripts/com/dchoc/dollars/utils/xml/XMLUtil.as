package com.dchoc.dollars.utils.xml
{
   public class XMLUtil
   {
      
      public static const CHUNK_SIZE:int = 64;
      
      private var mChunkSize:int;
      
      private var mIndex:int;
      
      private var mXML:XML;
      
      private var mValues:Array;
      
      private var mPersistence:XML;
      
      private var mDataStr:String;
      
      public function XMLUtil(param1:XML, param2:Array, param3:int = 64)
      {
         super();
         this.mXML = param1;
         this.mValues = param2;
         this.mChunkSize = param3;
      }
      
      public static function readBoolean(param1:XML, param2:String) : Boolean
      {
         var _loc5_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:XMLList = param1.attribute(param2);
         if(_loc4_.length() > 0)
         {
            _loc5_ = _loc4_[0];
            _loc3_ = _loc5_ == "1";
         }
         return _loc3_;
      }
      
      public static function XMLListToXML(param1:XMLList) : XML
      {
         var _loc2_:String = param1.toXMLString();
         return new XML(_loc2_);
      }
      
      private function writeChunk() : void
      {
         var _loc1_:XML = this.mXML.copy();
         this.mIndex = 0;
         _loc1_.@chunk = this.mDataStr;
         this.mPersistence.appendChild(_loc1_);
         this.mDataStr = "";
      }
      
      private function doChunks() : void
      {
         var _loc2_:int = 0;
         this.mDataStr = "";
         this.mIndex = 0;
         var _loc1_:int = int(this.mValues.length);
         while(_loc2_ < _loc1_)
         {
            this.mDataStr += this.mValues[_loc2_] + ",";
            ++this.mIndex;
            if(this.mIndex == this.mChunkSize)
            {
               this.writeChunk();
            }
            _loc2_++;
         }
         this.writeChunk();
      }
      
      public function addToXML(param1:XML) : void
      {
         this.mPersistence = param1;
         this.doChunks();
      }
      
      public function get persistence() : XML
      {
         return this.mPersistence;
      }
   }
}

