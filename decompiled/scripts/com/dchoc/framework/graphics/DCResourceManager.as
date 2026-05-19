package com.dchoc.framework.graphics
{
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.metrics.MetricConstants;
   import com.dchoc.dollars.utils.metrics.MyMetrics;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class DCResourceManager extends EventDispatcher
   {
      
      private static var mAllowInstantiation:Boolean;
      
      private static var mInstance:DCResourceManager;
      
      public static const DEBUG:Boolean = Config.DEBUG_MODE;
      
      public static const USE_CONTEXT:Boolean = true;
      
      private var mType:Object = new Object();
      
      private var mLoaded:Object = new Object();
      
      private var mResolver:Dictionary = new Dictionary(true);
      
      private var mList:Object = new Object();
      
      private var mDebugTotalFilesNames:Array;
      
      private var mPath:Object = new Object();
      
      private var mDebugCurrentFilesNames:Array;
      
      private var mErrorsCount:Dictionary = new Dictionary(true);
      
      private var mUnloader:Object = new Object();
      
      public function DCResourceManager()
      {
         super();
         if(Config.DEBUG_MODE)
         {
            this.mDebugTotalFilesNames = new Array();
            this.mDebugCurrentFilesNames = new Array();
         }
         if(!mAllowInstantiation)
         {
            throw new Error("ERROR: DCResourceManager Error: Instantiation failed: Use DCResourceManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : DCResourceManager
      {
         if(mInstance == null)
         {
            mAllowInstantiation = true;
            mInstance = new DCResourceManager();
            mAllowInstantiation = false;
         }
         return mInstance;
      }
      
      public function showFilesDueToLoad() : Array
      {
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.mDebugTotalFilesNames.length)
         {
            if(this.mDebugCurrentFilesNames.indexOf(this.mDebugTotalFilesNames[_loc2_]) <= -1)
            {
               _loc1_.push(this.mDebugTotalFilesNames[_loc2_]);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function isAllLoaded() : Boolean
      {
         var _loc1_:String = null;
         for(_loc1_ in this.mList)
         {
            if(!this.mLoaded[_loc1_])
            {
               return false;
            }
         }
         return true;
      }
      
      private function completeLoad(param1:Event) : void
      {
         var _loc3_:ByteArray = null;
         var _loc2_:String = this.mResolver[param1.target];
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("ResourceManager::completeLoad() " + _loc2_);
         }
         this.loadRemoveListeners(param1.target);
         if(this.mType[_loc2_] == "ByteArray")
         {
            if(Config.DEBUG_ASSERTS)
            {
               Debug.trace("mList = " + _loc2_ + " event.target = " + param1.target);
            }
            _loc3_ = param1.target.data as ByteArray;
            this.mList[_loc2_] = param1.target.data;
            this.mUnloader[_loc2_] = param1.target;
         }
         else
         {
            this.mList[_loc2_] = param1.target.content;
            this.mUnloader[_loc2_] = param1.target.loader;
         }
         this.mLoaded[_loc2_] = true;
         delete this.mResolver[param1.target];
         if(Config.DEBUG_MODE)
         {
            this.mDebugCurrentFilesNames.push(_loc2_);
         }
      }
      
      private function loadFromFile(param1:String, param2:String, param3:String = "") : void
      {
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:URLLoader = null;
         var _loc8_:Loader = null;
         var _loc9_:LoaderContext = null;
         if(param3 == "")
         {
            _loc6_ = param1.lastIndexOf(".");
            if(_loc6_ != -1)
            {
               param3 = param1.substring(_loc6_);
            }
         }
         this.mLoaded[param2] = false;
         this.mType[param2] = param3;
         this.mPath[param2] = param1;
         switch(param3)
         {
            case ".csv":
            case ".txt":
               this.loadTextFile(param1,param2,param3);
               return;
            default:
               var _loc5_:URLRequest = new URLRequest(param1);
               if(param3 == "ByteArray")
               {
                  _loc7_ = new URLLoader();
                  if(Config.DEBUG_ASSERTS)
                  {
                     Debug.trace("resName ByteArray = " + param2);
                  }
                  this.mResolver[_loc7_] = param2;
                  this.mList[param2] = _loc7_;
                  this.mLoaded[param2] = false;
                  this.mUnloader[param2] = _loc7_;
                  this.mType[param2] = param3;
                  _loc7_.dataFormat = URLLoaderDataFormat.BINARY;
                  _loc7_.load(_loc5_);
                  _loc4_ = _loc7_;
               }
               else
               {
                  _loc8_ = new Loader();
                  this.mResolver[_loc8_.contentLoaderInfo] = param2;
                  this.mList[param2] = _loc8_;
                  this.mUnloader[param2] = _loc8_;
                  _loc9_ = null;
                  if(USE_CONTEXT)
                  {
                     _loc9_ = new LoaderContext();
                     _loc9_.applicationDomain = new ApplicationDomain();
                  }
                  _loc4_ = _loc8_.contentLoaderInfo;
                  _loc8_.load(_loc5_,_loc9_);
               }
               this.loadAddListeners(_loc4_);
               if(this.mErrorsCount[param2] == null)
               {
                  this.mErrorsCount[param2] = 0;
               }
               else
               {
                  ++this.mErrorsCount[param2];
               }
               return;
         }
      }
      
      private function loadTextFile(param1:String, param2:String, param3:String = "") : void
      {
         var _loc4_:URLRequest = new URLRequest(param1);
         var _loc5_:URLLoaderWithName = new URLLoaderWithName();
         _loc5_.dataFormat = URLLoaderDataFormat.TEXT;
         _loc5_.load(_loc4_);
         this.mResolver[_loc5_.name] = param2;
         this.mList[param2] = _loc5_;
         this.mUnloader[param2] = _loc5_;
         this.loadAddListeners(_loc5_);
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         var _loc2_:String = null;
         if(param1.status != 200 && param1.status != 0)
         {
            this.loadRemoveListeners(param1.target,false);
            _loc2_ = this.mResolver[param1.target];
            if(Config.DEBUG_ASSERTS)
            {
               Debug.trace("ERROR: ResourceManager: HTTP loading error: " + _loc2_ + " event = " + param1);
            }
            MyMetrics.send_GA_metric(MetricConstants.EVENT_LOADING,MetricConstants.LABEL_LOADING_RESOURCE_FAIL,MetricConstants.LABEL_SERVER_RESPONSE_CODE + ": " + param1.status + " / " + _loc2_);
         }
      }
      
      private function loadAddListeners(param1:Object) : void
      {
         param1.addEventListener(Event.COMPLETE,this.completeLoad,false,0,true);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.errorLoad,false,0,true);
         param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler,false,0,true);
      }
      
      private function loadRemoveListeners(param1:Object, param2:Boolean = true) : void
      {
         param1.removeEventListener(Event.COMPLETE,this.completeLoad);
         if(param2)
         {
            param1.removeEventListener(IOErrorEvent.IO_ERROR,this.errorLoad);
            param1.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
         }
      }
      
      public function getSWFClass(param1:String, param2:String) : Class
      {
         var _loc3_:ApplicationDomain = this.getLoadedSWFAppDomain(param1);
         if(_loc3_ != null && _loc3_.hasDefinition(param2))
         {
            return Class(_loc3_.getDefinition(param2));
         }
         return null;
      }
      
      public function get(param1:String) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:Sprite = null;
         if(this.mList[param1] == null)
         {
            if(Config.DEBUG_ASSERTS)
            {
               Debug.trace("Resource " + param1 + " doesn\'t exist");
            }
            return null;
         }
         if(!this.mLoaded[param1])
         {
            throw new Error("ERROR:ResourceManger. " + param1 + " is not mLoaded");
         }
         switch(this.mType[param1])
         {
            case ".swf":
               return this.mList[param1] as MovieClip;
            case ".jpg":
            case "jpeg":
            case ".gif":
            case ".png":
            case "png":
            case "BitmapData":
               return Bitmap(this.mList[param1]).bitmapData;
            case "MovieClip":
               return this.mList[param1] as MovieClip;
            case "Sprite":
               _loc2_ = Bitmap(this.mList[param1]).bitmapData;
               _loc3_ = new Sprite();
               _loc3_.addChild(new Bitmap(_loc2_));
               _loc3_.scaleX = 0.5;
               _loc3_.scaleY = 0.5;
               return _loc3_;
            case "Bitmap":
               _loc2_ = Bitmap(this.mList[param1]).bitmapData;
               return new Bitmap(_loc2_);
            case ".xml":
               return new XML(this.mList[param1]);
            case ".txt":
            case ".csv":
               return this.mList[param1] as String;
            case "ByteArray":
               return this.mList[param1] as ByteArray;
            default:
               return null;
         }
      }
      
      public function unloadAll() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this.mList)
         {
            this.unload(_loc1_);
         }
      }
      
      public function load(param1:String, param2:String = "", param3:String = "") : void
      {
         if(Boolean(this.mLoaded[param2]) || Boolean(this.mType[param2]))
         {
            return;
         }
         this.loadFromFile(param1,param2,param3);
         if(Config.DEBUG_MODE)
         {
            this.mDebugTotalFilesNames.push(param2);
         }
      }
      
      private function errorLoad(param1:IOErrorEvent) : void
      {
         this.loadRemoveListeners(param1.target,false);
         var _loc2_:String = this.mResolver[param1.target];
         MyMetrics.send_GA_metric(MetricConstants.EVENT_LOADING,MetricConstants.LABEL_LOADING_RESOURCE_FAIL,MetricConstants.LABEL_SERVER_RESOURCE_NAME + ": " + _loc2_);
         if(Config.DEBUG_ASSERTS)
         {
            Debug.trace("ERROR: ResourceManager: IOError loading error: " + param1 + " attemp = " + this.mErrorsCount[_loc2_]);
         }
         if(this.mErrorsCount[_loc2_] < Config.LOAD_RESOURCES_ATTEMPTS_COUNT)
         {
            this.loadFromFile(this.mPath[_loc2_],_loc2_,this.mType[_loc2_]);
         }
      }
      
      public function getNumberSWFClass(param1:String, param2:String) : int
      {
         var _loc5_:Class = null;
         var _loc3_:Boolean = true;
         var _loc4_:int = 0;
         while(_loc3_)
         {
            _loc5_ = this.getSWFClass(param1,param2 + "_" + _loc4_);
            _loc3_ = _loc5_ != null;
            _loc4_++;
         }
         return _loc4_ - 1;
      }
      
      public function isResLoaded(param1:String) : Boolean
      {
         return this.mLoaded[param1];
      }
      
      public function getLoadedSWFAppDomain(param1:String) : ApplicationDomain
      {
         var _loc2_:Loader = this.mUnloader[param1];
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.contentLoaderInfo.applicationDomain;
      }
      
      public function unload(param1:String) : void
      {
         if(param1 == "")
         {
            throw new Error("ERROR: DCResourceManager: must specify a resource to unload");
         }
         if(!this.mLoaded[param1])
         {
            throw new Error("ERROR: DCResourceManager resource " + param1 + " not mLoaded.");
         }
         switch(this.mType[param1])
         {
            case ".swf":
               break;
            case "Bitmap":
            case "BitmapData":
            case ".jpg":
            case "jpeg":
            case ".gif":
            case ".png":
               Bitmap(this.mList[param1]).bitmapData.dispose();
               break;
            case "MovieClip":
            case "Sprite":
         }
         if(this.mUnloader[param1].numChildren > 0)
         {
            this.mUnloader[param1].unload();
         }
         this.mLoaded[param1] = false;
         delete this.mUnloader[param1];
         delete this.mResolver[param1];
         delete this.mList[param1];
         delete this.mLoaded[param1];
         delete this.mType[param1];
         delete this.mPath[param1];
         delete this.mErrorsCount[param1];
      }
   }
}

