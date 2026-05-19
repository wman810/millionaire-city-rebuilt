package com.dchoc.dollars.utils.metrics
{
   import com.adobe.serialization.json.JSON;
   import com.dchoc.dollars.model.ShowPopup;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.actions.ActionsLibrary;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.system.LoaderContext;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class PaymentManager
   {
      
      public static var smAreFb:Boolean;
      
      public static var smWaitingForOptions:Boolean;
      
      private static var smInstance:PaymentManager;
      
      public static const TYPE_NONE:int = 0;
      
      private var mFedPostPaymentUrl:String;
      
      private var mImages:Array;
      
      private var mImagesCompleted:int = 0;
      
      private var mType:int = -1;
      
      private var mFedCurrency:int;
      
      private var mFlashVars:Object;
      
      private var mTimeOutId:int = -1;
      
      private var mFedPayments:String;
      
      private var mFedGameId:String;
      
      private var JSONObj:Object;
      
      private var mInitIndex:int;
      
      private var mFedUrl:String;
      
      private const TIME_OUT:int = 5000;
      
      public function PaymentManager()
      {
         super();
      }
      
      public static function getInstance() : PaymentManager
      {
         if(smInstance == null)
         {
            smInstance = new PaymentManager();
         }
         return smInstance;
      }
      
      public function onCompleteGetOptions(param1:Event) : void
      {
         clearTimeout(this.mTimeOutId);
         this.mTimeOutId = -1;
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.onCompleteGetOptions);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.onErrorGetOptions);
         var _loc3_:Object = com.adobe.serialization.json.JSON.decode(String(_loc2_.data));
         if(_loc3_.title == null)
         {
            _loc3_.title = "Get More Millionaire Gold";
         }
         if(_loc3_.retc == 0)
         {
            if(_loc3_.url != null)
            {
               UserDataFacade.getInstance().requestTask(ActionsLibrary.SHOW_FACE_BOX,{
                  "url":_loc3_.url,
                  "title":_loc3_.title
               });
            }
            else
            {
               Debug.trace("Payment manager: TASK_FED_PAYMENT");
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_FED_PAYMENT,_loc3_.js);
            }
         }
         smWaitingForOptions = false;
      }
      
      private function messagePopupClose() : void
      {
         smWaitingForOptions = false;
      }
      
      private function loadImage(param1:Event) : void
      {
         var _loc2_:Loader = param1.target.loader as Loader;
         _loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.loadImage);
         _loc2_.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.errorLoadImage);
         var _loc3_:Bitmap = _loc2_.content as Bitmap;
         var _loc4_:Array = _loc2_.name.split(",");
         if(_loc3_ == null)
         {
            this.JSONObj.methods.splice(int(_loc4_[0]),1);
            this.mImages.splice(int(_loc4_[0]),1);
         }
         else
         {
            this.mImages[int(_loc4_[0])] = _loc3_;
            ++this.mImagesCompleted;
         }
      }
      
      private function onErrorLoad(param1:IOErrorEvent) : void
      {
         clearTimeout(this.mTimeOutId);
         Debug.trace("Payment manager: onErrorLoad");
         Debug.trace("Error loading payment type");
         this.mTimeOutId = -1;
      }
      
      public function get initIndex() : int
      {
         return this.mInitIndex;
      }
      
      public function load() : void
      {
         var _loc1_:String = null;
         var _loc2_:URLVariables = null;
         var _loc3_:URLRequest = null;
         var _loc4_:URLLoader = null;
         if(this.mType == -1)
         {
            Debug.trace("Payment manager: load");
            this.mType = 0;
            smAreFb = false;
            _loc1_ = "";
            if(Config.OFFLINE_GAMEPLAY_MODE)
            {
               this.mFlashVars = new Object();
               this.mFlashVars.fed_game_id = 1;
               this.mFlashVars.fed_currency = 1;
               this.mFlashVars.lang = "en_US";
               this.mFlashVars.fed_payments = "1";
               this.mFlashVars.fed_post_payment_url = "";
               _loc1_ = Config.getRoot() + "userData/paymentReq.txt";
            }
            else
            {
               this.mFlashVars = Dollars.smStage.root.loaderInfo.parameters;
               _loc1_ = this.mFlashVars.fed_url + "/payment/get_payment_methods";
            }
            this.mFedGameId = this.mFlashVars.fed_game_id;
            this.mFedCurrency = this.mFlashVars.fed_currency_id;
            this.mFedUrl = this.mFlashVars.fed_url;
            this.mFedPayments = this.mFlashVars.fed_payments;
            this.mFedPostPaymentUrl = this.mFlashVars.fed_post_payment_url;
            if("1" != this.mFedPayments)
            {
               return;
            }
            _loc2_ = new URLVariables();
            _loc2_.game_id = this.mFedGameId;
            _loc2_.fb_id = this.mFlashVars.uid;
            _loc2_.locale = this.mFlashVars.lang;
            Debug.trace("Payment manager: sending to " + _loc1_);
            _loc3_ = new URLRequest(_loc1_);
            _loc3_.data = _loc2_;
            _loc3_.method = URLRequestMethod.POST;
            _loc4_ = new URLLoader();
            _loc4_.addEventListener(Event.COMPLETE,this.onCompleteLoad);
            _loc4_.addEventListener(IOErrorEvent.IO_ERROR,this.onErrorLoad);
            _loc4_.load(_loc3_);
            this.mTimeOutId = setTimeout(this.loadingTimeOut,this.TIME_OUT,_loc4_);
         }
      }
      
      public function getOptions(param1:int) : void
      {
         smWaitingForOptions = true;
         var _loc2_:String = this.mFedUrl + "/payment/purchase_currency_with_method";
         if(Config.OFFLINE_GAMEPLAY_MODE)
         {
            _loc2_ = Config.getRoot() + "userData/paymentGetOptions.txt";
         }
         var _loc3_:URLVariables = new URLVariables();
         _loc3_.game_id = this.mFedGameId;
         _loc3_.fb_id = this.mFlashVars.uid;
         _loc3_.locale = this.mFlashVars.lang;
         _loc3_.payment_type = this.JSONObj.methods[param1].id;
         _loc3_.currency_id = this.mFedCurrency;
         _loc3_.post_payment_url = this.mFedPostPaymentUrl;
         var _loc4_:URLRequest = new URLRequest(_loc2_);
         _loc4_.method = URLRequestMethod.POST;
         _loc4_.data = _loc3_;
         var _loc5_:URLLoader = new URLLoader();
         _loc5_.addEventListener(Event.COMPLETE,this.onCompleteGetOptions);
         _loc5_.addEventListener(IOErrorEvent.IO_ERROR,this.onErrorGetOptions);
         _loc5_.load(_loc4_);
         if(this.mTimeOutId == -1)
         {
            this.mTimeOutId = setTimeout(this.getOptionsTimeOut,10000,_loc5_);
         }
      }
      
      public function get paymentCount() : int
      {
         if(this.JSONObj == null || this.JSONObj.retc != 0)
         {
            return 0;
         }
         return this.mImagesCompleted;
      }
      
      public function getOptionImage(param1:int) : Bitmap
      {
         if(this.JSONObj == null || this.JSONObj.retc != 0)
         {
            return null;
         }
         return this.mImages[param1];
      }
      
      public function onErrorGetOptions(param1:IOErrorEvent) : void
      {
         clearTimeout(this.mTimeOutId);
         this.mTimeOutId = -1;
         smWaitingForOptions = false;
         Debug.trace("Error getting the payment options");
      }
      
      private function errorLoadImage(param1:IOErrorEvent) : void
      {
         var _loc2_:Loader = param1.target.loader as Loader;
         var _loc3_:Array = _loc2_.name.split(",");
         var _loc4_:int = 1;
         while(_loc4_ < this.paymentCount)
         {
            if(this.JSONObj.methods[_loc4_].id == _loc3_[1])
            {
               this.JSONObj.methods.splice(_loc4_,1);
               this.mImages.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
      }
      
      private function getOptionsTimeOut(param1:URLLoader) : void
      {
         param1.removeEventListener(Event.COMPLETE,this.onCompleteGetOptions);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.onErrorGetOptions);
         ShowPopup.show(ShowPopup.POPUP_MSG_SMALL,TextManager.getText(TextIDs.TID_PAYMENT_FAIL));
         ShowPopup.setActionCancel(this.messagePopupClose,null);
         clearTimeout(this.mTimeOutId);
         this.mTimeOutId = -1;
      }
      
      private function loadingTimeOut(param1:URLLoader) : void
      {
         param1.removeEventListener(Event.COMPLETE,this.onCompleteLoad);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.onErrorLoad);
         clearTimeout(this.mTimeOutId);
         Debug.trace("Time out loading the payment request");
         this.mTimeOutId = -1;
      }
      
      private function onCompleteLoad(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         var _loc5_:String = null;
         var _loc6_:Loader = null;
         var _loc7_:URLRequest = null;
         var _loc8_:LoaderContext = null;
         Debug.trace("Payment manager: onCompleteLoad");
         var _loc2_:URLLoader = param1.target as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.onCompleteLoad);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.onErrorLoad);
         clearTimeout(this.mTimeOutId);
         this.JSONObj = com.adobe.serialization.json.JSON.decode(String(_loc2_.data));
         if(this.JSONObj.retc == 0)
         {
            this.mImages = new Array(this.JSONObj.methods.length);
            _loc3_ = 1;
            _loc4_ = 0;
            while(_loc4_ < this.JSONObj.methods.length)
            {
               if(this.JSONObj.methods[_loc4_].id == "64")
               {
                  smAreFb = true;
                  _loc3_ = 2;
                  this.mInitIndex = 1;
                  break;
               }
               _loc4_++;
            }
            if(this.JSONObj.methods.length > _loc3_)
            {
               this.JSONObj.methods.splice(_loc3_,this.JSONObj.methods.length - _loc3_);
            }
            _loc4_ = 0;
            while(_loc4_ < this.JSONObj.methods.length)
            {
               if(this.JSONObj.methods[_loc4_].id != "64")
               {
                  _loc5_ = this.JSONObj.methods[_loc4_].image;
                  if(_loc5_ != null && _loc5_ != "")
                  {
                     _loc6_ = new Loader();
                     _loc7_ = new URLRequest(_loc5_);
                     _loc8_ = new LoaderContext(true);
                     _loc6_.name = "" + _loc4_ + "," + this.JSONObj.methods[_loc4_].id;
                     _loc6_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadImage);
                     _loc6_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorLoadImage);
                     _loc6_.load(_loc7_,_loc8_);
                  }
                  else
                  {
                     this.JSONObj.methods.splice(_loc4_,1);
                     this.mImages.splice(_loc4_,1);
                     _loc4_--;
                  }
               }
               _loc4_++;
            }
            this.mTimeOutId = -1;
         }
      }
      
      public function getOptionText(param1:int) : String
      {
         if(this.JSONObj == null || this.JSONObj.retc != 0)
         {
            return null;
         }
         return this.JSONObj.methods[param1].text;
      }
   }
}

