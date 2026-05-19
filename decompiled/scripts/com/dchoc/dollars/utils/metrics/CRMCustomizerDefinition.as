package com.dchoc.dollars.utils.metrics
{
   import com.dchoc.dollars.world.items.BundleDefinition;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class CRMCustomizerDefinition
   {
      
      public static const IMAGE_NULL:int = 0;
      
      public static const IMAGE_LOADED:int = 1;
      
      public static const IMAGE_FAILED:int = 2;
      
      public static const TYPE_INIT:String = "init";
      
      public static const TYPE_IDLE:String = "idle";
      
      public static const CONTENT_TYPE_POPUP:String = "1";
      
      public static const CONTENT_TYPE_CUSTOM_CONTENT:String = "4";
      
      public static const TRACKING_ONDISPLAY:String = "ondisplay";
      
      public static const TRACKING_ONCLICK:String = "onclick";
      
      public static const FORMAT_INIT:int = 0;
      
      public static const FORMAT_IDLE:int = 1;
      
      public static const ITEM_OFFER:String = "item";
      
      public static const SHOP_OFFER:String = "shop";
      
      public static const POPUP_TYPE_OFFER:String = "offer";
      
      public static const POPUP_TYPE_FREE_ITEM:String = "free_item";
      
      public static const POPUP_TYPE_BUNDLE:String = "bundle";
      
      private var mBackground:String;
      
      private var mAdvisor:String;
      
      private var mCRMParams:Array;
      
      private var mPopupType:String;
      
      private var mCrossPromotion:String;
      
      private var mImageUrl:String;
      
      private var mBundleDefiniton:BundleDefinition;
      
      private var mActionButtonAction:String;
      
      private var mHelpImage:String;
      
      private var mCrossPromotionParams:XML;
      
      private var mData:XML;
      
      private var mText:String;
      
      private var mItemShop:XML;
      
      private var mFormat:int;
      
      private var mWeight:int;
      
      private var mType:String;
      
      private var mExpVersion:String;
      
      private var mCustomizerType:String;
      
      private var mBundle:XML;
      
      private var mActionButtonLabel:String;
      
      private var mId:int;
      
      private var mTitle:String;
      
      private var mImage:DisplayObject;
      
      private var mActionButtonParams:Array;
      
      private var mExpCode:String;
      
      public function CRMCustomizerDefinition(param1:XML)
      {
         var _loc3_:XML = null;
         var _loc4_:Loader = null;
         var _loc5_:URLRequest = null;
         var _loc6_:LoaderContext = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         super();
         this.mId = int(param1.@id);
         this.mCustomizerType = param1.@type;
         this.mType = param1.@display_on;
         this.mTitle = param1.@title;
         this.mText = param1.@text;
         this.mFormat = int(param1.@format);
         this.mData = param1.data[0];
         if("@crossPromotion" in param1)
         {
            this.mCrossPromotion = param1.@crossPromotion;
            this.mCrossPromotionParams = param1.data[0];
         }
         if("@exp_code" in param1)
         {
            this.mExpCode = param1.@exp_code;
         }
         if("@exp_version" in param1)
         {
            this.mExpVersion = param1.@exp_version;
         }
         if("@background" in param1)
         {
            this.mBackground = param1.@background;
         }
         if("@advisor" in param1)
         {
            this.mAdvisor = param1.@advisor;
         }
         this.mWeight = int(param1.@weight);
         if("@helpImage" in param1)
         {
            this.mHelpImage = param1.@helpImage;
         }
         if("@popup_type" in param1)
         {
            this.mPopupType = param1.@popup_type;
         }
         if(this.mCustomizerType == CONTENT_TYPE_POPUP && this.mPopupType == POPUP_TYPE_OFFER)
         {
            this.mItemShop = param1.itemshop[0];
         }
         if(this.mCustomizerType == CONTENT_TYPE_POPUP && this.mPopupType == POPUP_TYPE_BUNDLE)
         {
            this.mBundle = param1.bundle[0];
         }
         this.mActionButtonLabel = param1.actionButton.@label;
         this.mActionButtonAction = param1.actionButton.@action;
         this.mImageUrl = param1.@img;
         if(Config.SECURE_PROTOCOL)
         {
            this.mImageUrl = this.mImageUrl.replace("http:","https:");
         }
         if(this.mImageUrl != null)
         {
            _loc4_ = new Loader();
            _loc5_ = new URLRequest(this.mImageUrl);
            _loc6_ = new LoaderContext(true);
            _loc4_.load(_loc5_,_loc6_);
            this.mImage = _loc4_;
         }
         this.mActionButtonParams = new Array();
         this.mCRMParams = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < param1.actionButton.params.attributes().length())
         {
            _loc7_ = param1.actionButton.params.attributes()[_loc2_];
            this.mActionButtonParams.push(_loc7_);
            _loc2_++;
         }
         for each(_loc3_ in param1.actionButton.tracking)
         {
            if("@event" in _loc3_)
            {
               _loc8_ = new Object();
               _loc8_.event = _loc3_.@type;
               _loc8_.group = _loc3_.@group;
               _loc8_.label = _loc3_.@label;
               _loc8_.product = _loc3_.@product;
               this.mCRMParams[_loc3_.@event] = _loc8_;
            }
         }
      }
      
      public function destroy() : void
      {
         this.mImage = null;
      }
      
      public function get popupType() : String
      {
         return this.mPopupType;
      }
      
      public function get bundle() : XML
      {
         return this.mBundle;
      }
      
      public function get crmParams() : Array
      {
         return this.mCRMParams;
      }
      
      public function get imageUrl() : String
      {
         return this.mImageUrl;
      }
      
      public function set expVersion(param1:String) : void
      {
         this.mExpVersion = param1;
      }
      
      public function get helpImage() : String
      {
         return this.mHelpImage;
      }
      
      public function get id() : int
      {
         return this.mId;
      }
      
      public function get expVersion() : String
      {
         return this.mExpVersion;
      }
      
      public function set actionButtonLabel(param1:String) : void
      {
         this.mActionButtonLabel = param1;
      }
      
      public function get crossPromotionParams() : XML
      {
         return this.mCrossPromotionParams;
      }
      
      public function get expCode() : String
      {
         return this.mExpCode;
      }
      
      public function get itemShop() : XML
      {
         return this.mItemShop;
      }
      
      public function get data() : XML
      {
         return this.mData;
      }
      
      public function get text() : String
      {
         return this.mText;
      }
      
      public function get actionButtonParams() : Array
      {
         return this.mActionButtonParams;
      }
      
      public function set actionButtonAction(param1:String) : void
      {
         this.mActionButtonAction = param1;
      }
      
      public function get advisor() : String
      {
         return this.mAdvisor;
      }
      
      public function get type() : String
      {
         return this.mType;
      }
      
      public function get background() : String
      {
         return this.mBackground;
      }
      
      public function get actionButtonLabel() : String
      {
         return this.mActionButtonLabel;
      }
      
      public function set crossPromotionParams(param1:XML) : void
      {
         this.mCrossPromotionParams = param1;
      }
      
      public function set expCode(param1:String) : void
      {
         this.mExpCode = param1;
      }
      
      public function get title() : String
      {
         return this.mTitle;
      }
      
      public function set data(param1:XML) : void
      {
         this.mData = param1;
      }
      
      public function get actionButtonAction() : String
      {
         return this.mActionButtonAction;
      }
      
      public function get image() : DisplayObject
      {
         return this.mImage;
      }
      
      public function get customizerType() : String
      {
         return this.mCustomizerType;
      }
      
      public function getBundleDefinition() : BundleDefinition
      {
         return this.mBundleDefiniton;
      }
      
      public function get format() : int
      {
         return this.mFormat;
      }
      
      public function get weight() : int
      {
         return this.mWeight;
      }
      
      public function setBundleDefinition(param1:BundleDefinition) : void
      {
         this.mBundleDefiniton = param1;
      }
   }
}

