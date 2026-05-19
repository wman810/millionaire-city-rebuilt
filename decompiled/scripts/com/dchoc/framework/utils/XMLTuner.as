package com.dchoc.framework.utils
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   import flash.xml.XMLNodeType;
   
   public class XMLTuner
   {
      
      private static var mAllowInstantiation:Boolean;
      
      private static var mInstance:XMLTuner;
      
      private var mTuner:Object;
      
      private var mIsLoaded:Boolean = false;
      
      public function XMLTuner()
      {
         super();
         if(!mAllowInstantiation)
         {
            throw new Error("ERROR: XMLTuner Error: Instantiation failed: Use XMLTuner.getInstance() instead of new.");
         }
         this.mIsLoaded = false;
         this.loadXML();
      }
      
      public static function getInstance() : XMLTuner
      {
         if(mInstance == null)
         {
            mAllowInstantiation = true;
            mInstance = new XMLTuner();
            mAllowInstantiation = false;
         }
         return mInstance;
      }
      
      private function completeHandler(param1:Event) : void
      {
         this.mIsLoaded = true;
         var _loc2_:URLLoader = URLLoader(param1.target);
         _loc2_.removeEventListener(Event.COMPLETE,this.completeHandler);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.errorLoad);
         var _loc3_:XML = new XML(_loc2_.data);
         var _loc4_:XMLDocument = new XMLDocument();
         _loc4_.ignoreWhite = true;
         _loc4_.parseXML(_loc3_.toXMLString());
         this.mTuner = this.xmlDecoder(_loc4_);
      }
      
      private function xmlDecoder(param1:XMLDocument) : Object
      {
         var _loc2_:Object = this.decodeXMLNode(param1.firstChild);
         var _loc3_:String = param1.firstChild.attributes.service;
         var _loc4_:String = param1.firstChild.attributes.call_id;
         _loc2_._serviceId = _loc3_;
         _loc2_._callId = _loc4_;
         return _loc2_;
      }
      
      private function decodeXMLNode(param1:XMLNode) : Object
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc2_:Object = {};
         while(param1 != null)
         {
            _loc3_ = param1.toString();
            _loc4_ = null;
            if(param1.hasChildNodes() && param1.firstChild.nodeType == XMLNodeType.ELEMENT_NODE)
            {
               _loc4_ = this.decodeXMLNode(param1.firstChild);
            }
            else if(param1.hasChildNodes())
            {
               _loc4_ = param1.firstChild.nodeValue;
            }
            _loc4_ = this.addAttributes(param1,_loc4_);
            if(_loc2_[param1.nodeName] != null)
            {
               _loc5_ = _loc2_[param1.nodeName];
               if(_loc5_ is Array)
               {
                  _loc5_.push(_loc4_);
                  _loc2_[param1.nodeName] = _loc5_;
               }
               else
               {
                  _loc6_ = new Array();
                  _loc6_.push(_loc5_);
                  _loc6_.push(_loc4_);
                  _loc2_[param1.nodeName] = _loc6_;
               }
            }
            else
            {
               _loc2_[param1.nodeName] = _loc4_;
            }
            param1 = param1.nextSibling;
         }
         return _loc2_;
      }
      
      private function errorLoad(param1:IOErrorEvent) : void
      {
         throw new Error("ERROR: XMLTuner: loading error: " + param1);
      }
      
      public function isLoaded() : Boolean
      {
         return this.mIsLoaded;
      }
      
      private function loadXML() : void
      {
         var request:URLRequest;
         var loaderContext:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain);
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.completeHandler);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.errorLoad,false,0,true);
         request = new URLRequest(Config.getRoot() + Config.TUNER_XML_FILE);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            trace("Unable to load requested document.");
         }
      }
      
      public function getAnimalValues(param1:String) : Object
      {
         var _loc2_:String = null;
         for(_loc2_ in this.mTuner.tuner.animals.animal)
         {
            if(this.mTuner.tuner.animals.animal[_loc2_].sku == param1)
            {
               return this.mTuner.tuner.animals.animal[_loc2_];
            }
         }
         return null;
      }
      
      public function get tuner() : Object
      {
         return this.mTuner;
      }
      
      private function addAttributes(param1:XMLNode, param2:Object) : Object
      {
         var _loc3_:String = null;
         if(param1.attributes == null)
         {
            return param2;
         }
         if(param2 == null)
         {
            param2 = new Object();
         }
         for(_loc3_ in param1.attributes)
         {
            param2[_loc3_] = param1.attributes[_loc3_];
         }
         return param2;
      }
   }
}

