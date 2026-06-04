package com.dchoc.dollars.utils.metrics
{
   import com.dchoc.dollars.collectibles.CollectibleDefinition;
   import com.dchoc.dollars.collectibles.CollectibleDefinitionManager;
   import com.dchoc.dollars.crewMechanics.CrewMechanicsManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.invests.InvestManager;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.model.profile.Profile;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.services.ServiceDefinition;
   import com.dchoc.dollars.model.services.ServiceDefinitionManager;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.offers.OfferDefinition;
   import com.dchoc.dollars.offers.OfferDefinitionManager;
   import com.dchoc.dollars.server.Server;
   import com.dchoc.dollars.utils.abtest.ABTestManager;
   import com.dchoc.dollars.utils.actions.ActionsLibrary;
   import com.dchoc.dollars.utils.debug.Debug;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.BundleDefinition;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.purchase.FBCreditsPurchase;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class CustomizerManager
   {
      
      private static var smInstance:CustomizerManager;
      
      public static const CRM_OFFER_NORMAL:int = -1;
      
      public static const CRM_OFFER_ENABLED:int = 1;
      
      public static const CRM_OFFER_EXPIRED:int = 0;
      
      private var mInfoPopupsInit:Array;
      
      private var mVideoFunctionName:String = "";
      
      private var mOfferExpireDate:Date;
      
      private var mLoaderTimer:int;
      
      private var mStatus:int;
      
      private var mOfferIds:Array;
      
      private var mVideoAd:Boolean;
      
      private var mInfoPopupsIdle:Array;
      
      private var mRandomRank:int;
      
      private var mUnlockedCrosspromotions:Array;
      
      private var mOfferState:int;
      
      private var mCRMEvent:int;
      
      private var mUrlLoader:URLLoader;
      
      public function CustomizerManager()
      {
         super();
         this.mUnlockedCrosspromotions = new Array();
         this.mUnlockedCrosspromotions.push(1);
         this.mUnlockedCrosspromotions.push(16);
         this.mUnlockedCrosspromotions.push(20);
         this.mUnlockedCrosspromotions.push(19);
         this.mUnlockedCrosspromotions.push(12);
         this.mUnlockedCrosspromotions.push(21);
         this.mUnlockedCrosspromotions.push(33);
         this.mUnlockedCrosspromotions.push(37);
         this.mStatus = 0;
         this.mVideoAd = false;
         this.mOfferExpireDate = new Date();
      }
      
      public static function getInstance() : CustomizerManager
      {
         if(smInstance == null)
         {
            smInstance = new CustomizerManager();
         }
         return smInstance;
      }
      
      public function getCRMStatus() : int
      {
         if(!Config.USE_CRM_POPUPS)
         {
            this.mStatus = -1;
         }
         return this.mStatus;
      }
      
      private function abTestParserFBCPriceCollectible(param1:XMLList) : void
      {
         var _loc3_:XML = null;
         var _loc4_:CollectibleDefinition = null;
         var _loc2_:CollectibleDefinitionManager = CollectibleDefinitionManager.getInstance();
         for each(_loc3_ in param1)
         {
            _loc4_ = _loc2_.getDefinitionBySku(_loc3_.@sku) as CollectibleDefinition;
            if(_loc4_ != null && _loc3_.@priceFBC > 0)
            {
               _loc4_.setPriceFBCredits(_loc3_.@priceFBC);
            }
         }
      }
      
      private function abTestParserFBCPriceSkipAction(param1:XML) : void
      {
         if(param1 != null && param1.@priceFBC > 0)
         {
            FBCreditsPurchase.SKIP_ACTION_PRICE = int(param1.@priceFBC);
         }
      }
      
      private function abTestParserFBCPriceExpansions(param1:XMLList) : void
      {
         var _loc3_:XML = null;
         var _loc2_:RulesFacade = RulesFacade.getInstance();
         for each(_loc3_ in param1)
         {
            if(_loc3_.@FBC > 0)
            {
               _loc2_.expansionsSetFBCredits(_loc3_.@index,_loc3_.@FBC);
            }
         }
      }
      
      public function getCountInit() : int
      {
         if(this.mInfoPopupsIdle == null)
         {
            return 0;
         }
         return this.mInfoPopupsInit.length;
      }
      
      private function abTestParserFBCPriceEarlyUnlock(param1:XMLList, param2:XML) : void
      {
         var _loc4_:XML = null;
         var _loc3_:RulesFacade = RulesFacade.getInstance();
         if(param2 != null)
         {
            if(param2.@FBC > 0)
            {
               _loc3_.settingsSetUnlockMaxPrice(param2.@FBC,true);
            }
         }
         for each(_loc4_ in param1)
         {
            if(_loc4_.@baseFBC > 0)
            {
               _loc3_.overrideUnlockFBCBasePrice(_loc4_.@index,_loc4_.@baseFBC);
            }
         }
      }
      
      public function get crmOfferState() : int
      {
         return this.mOfferState;
      }
      
      private function ErrorLoader(param1:IOErrorEvent) : void
      {
         this.crmEvent = -1;
         GAMetrics.getInstance().registerEvent(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_CRM_POPUP),MetricConstants.EVENT_CRM_POPUP,MetricConstants.LABEL_CRM_POPUP_ERROR);
      }
      
      public function logicupdate(param1:int) : void
      {
         if(this.mOfferState == CRM_OFFER_ENABLED && this.isOfferExpired())
         {
            this.mOfferState = CRM_OFFER_EXPIRED;
            ItemDefinitionManager.getInstance().disableOffers();
         }
      }
      
      public function rank() : int
      {
         return this.mRandomRank;
      }
      
      public function isVideoAdEnabled() : Boolean
      {
         return this.mVideoAd;
      }
      
      public function get crmOfferIds() : Array
      {
         return this.mOfferIds;
      }
      
      public function set crmEvent(param1:int) : void
      {
         this.mCRMEvent = param1;
      }
      
      private function abTestParserFBCPriceService(param1:XMLList) : void
      {
         var _loc3_:XML = null;
         var _loc4_:ServiceDefinition = null;
         var _loc2_:ServiceDefinitionManager = ServiceDefinitionManager.getInstance();
         for each(_loc3_ in param1)
         {
            _loc4_ = _loc2_.getDefinitionBySku(_loc3_.@sku) as ServiceDefinition;
            if(_loc4_ != null)
            {
               if(_loc3_.@priceFBC > 0)
               {
                  _loc4_.setPriceFBCredits(_loc3_.@priceFBC);
               }
               if(_loc3_.@offerPriceFBC > 0)
               {
                  _loc4_.setOfferPriceFBCredits(_loc3_.@offerPriceFBC);
               }
            }
         }
      }
      
      public function get crmOfferTimer() : int
      {
         return this.mOfferExpireDate.dateUTC;
      }
      
      private function abTestParserFBCPriceItems(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:ItemDefinition = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = ItemDefinitionManager.getInstance().getDefinitionBySku(_loc2_.@sku) as ItemDefinition;
            if(_loc3_ != null)
            {
               if("@constructionFBC" in _loc2_ && int(_loc2_.@constructionFBC) > 0)
               {
                  _loc3_.constructionFBC = int(_loc2_.@constructionFBC);
               }
               if("@constructionFBCnoCash" in _loc2_ && int(_loc2_.@constructionFBCnoCash) > 0)
               {
                  _loc3_.constructionFBCnoCash = int(_loc2_.@constructionFBCnoCash);
               }
               _loc3_.createChecksum();
            }
         }
      }
      
      public function getCountIdle() : int
      {
         if(this.mInfoPopupsIdle == null)
         {
            return 0;
         }
         return this.mInfoPopupsIdle.length;
      }
      
      public function getCrmPopupDefinition(param1:String, param2:int) : CRMCustomizerDefinition
      {
         if(param1 == CRMCustomizerDefinition.TYPE_INIT)
         {
            if(param2 > this.mInfoPopupsInit.length || param2 < 0)
            {
               return null;
            }
            return this.mInfoPopupsInit[param2];
         }
         if(param2 > this.mInfoPopupsIdle.length || param2 < 0)
         {
            return null;
         }
         return this.mInfoPopupsIdle[param2];
      }
      
      public function destroyDefinitionsInit() : void
      {
         var _loc1_:int = 0;
         var _loc2_:CRMCustomizerDefinition = null;
         if(this.mInfoPopupsInit != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mInfoPopupsInit.length)
            {
               _loc2_ = this.mInfoPopupsInit[_loc1_];
               _loc2_.destroy();
               _loc2_ = null;
               this.mInfoPopupsInit[_loc1_] = null;
               _loc1_++;
            }
            this.mInfoPopupsInit = null;
         }
         if(this.getCountIdle() == 0)
         {
            this.crmEvent = -1;
         }
      }
      
      private function setCRMEvent(param1:Event) : void
      {
         var CRMpopups:XML = null;
         var popup:XML = null;
         var crm:CRMCustomizerDefinition = null;
         var offerSku:String = null;
         var itemSku:String = null;
         var offer:OfferDefinition = null;
         var item:ItemDefinition = null;
         var epochDate:Number = NaN;
         var itemOffer:XML = null;
         var bundle:BundleDefinition = null;
         var missionObject:MissionObject = null;
         var index:int = 0;
         var expKey:String = null;
         var profile:Profile = null;
         var i:int = 0;
         var defs:Array = null;
         var itemDef:ItemDefinition = null;
         var e:Event = param1;
         try
         {
            if(Config.CUSTOMIZER_FROM_SERVER)
            {
               CRMpopups = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_CRM_CUSTOMIZER);
            }
            else
            {
               CRMpopups = new XML(URLLoader(e.target).data);
               clearTimeout(this.mLoaderTimer);
            }
            if(Config.DEBUG_MODE)
            {
               Debug.trace("------------ CRMpopups -------------- 2");
               Debug.trace(CRMpopups.toXMLString());
            }
            if(CRMpopups != null)
            {
               this.mInfoPopupsInit = new Array();
               this.mInfoPopupsIdle = new Array();
               this.mRandomRank = 0;
               for each(popup in CRMpopups.content)
               {
                  crm = new CRMCustomizerDefinition(popup);
                  if(crm.customizerType == CRMCustomizerDefinition.CONTENT_TYPE_POPUP)
                  {
                     Debug.trace("CRM Popup detected");
                     if(crm.expCode != null)
                     {
                        Debug.trace("CRM AB Test detected. Code: " + crm.expCode + " Version: " + crm.expVersion);
                        ABTestManager.getInstance().addABTestGroup(crm.expCode + "_" + crm.expVersion,crm.data);
                     }
                     if(crm.popupType == CRMCustomizerDefinition.POPUP_TYPE_OFFER)
                     {
                        if("@expires_on" in crm.itemShop)
                        {
                           this.mOfferExpireDate = new Date(Date.parse(crm.itemShop.@expires_on));
                           epochDate = this.mOfferExpireDate.valueOf() - this.mOfferExpireDate.timezoneOffset * 60 * 1000;
                           this.mOfferExpireDate = new Date(epochDate);
                        }
                        else
                        {
                           this.mOfferExpireDate = null;
                        }
                        if(!this.isOfferExpired())
                        {
                           this.mOfferState = CRM_OFFER_ENABLED;
                           if(crm.itemShop.@offer_type == "item")
                           {
                              for each(itemOffer in crm.itemShop.item)
                              {
                                 itemSku = itemOffer.@sku;
                                 if(itemSku != "")
                                 {
                                    item = ItemDefinitionManager.getInstance().getDefinitionBySku(itemSku) as ItemDefinition;
                                    if(item != null && ItemDefinitionManager.getInstance().isFBCreditsItem(item,0))
                                    {
                                       offerSku = itemOffer.@offer_code;
                                       if(offerSku != "")
                                       {
                                          offer = OfferDefinitionManager.getInstance().getDefinitionBySku(offerSku) as OfferDefinition;
                                          if(offer != null)
                                          {
                                             item.offerDef = offer;
                                          }
                                          else
                                          {
                                             crm = null;
                                          }
                                          ItemDefinitionManager.getInstance().sort();
                                       }
                                       else
                                       {
                                          crm = null;
                                       }
                                    }
                                    else
                                    {
                                       crm = null;
                                    }
                                 }
                                 else
                                 {
                                    crm = null;
                                 }
                              }
                           }
                           else if(crm.itemShop.@offer_type == "shop")
                           {
                              offerSku = crm.itemShop.@offer_code;
                              if(offerSku != "")
                              {
                                 offer = OfferDefinitionManager.getInstance().getDefinitionBySku(offerSku) as OfferDefinition;
                                 if(offer != null)
                                 {
                                    for each(item in ItemDefinitionManager.getInstance().getDefinitionsWithCondition(ItemDefinitionManager.getInstance().isFBCreditsItem,0))
                                    {
                                       item.offerDef = offer;
                                    }
                                 }
                                 else
                                 {
                                    crm = null;
                                 }
                                 ItemDefinitionManager.getInstance().sort();
                              }
                              else
                              {
                                 crm = null;
                              }
                           }
                        }
                        else
                        {
                           crm = null;
                        }
                     }
                     else if(crm.popupType == CRMCustomizerDefinition.POPUP_TYPE_BUNDLE)
                     {
                        if(crm.bundle != null && "@sku" in crm.bundle && "@items" in crm.bundle && "@price" in crm.bundle)
                        {
                           bundle = new BundleDefinition(crm.bundle.@sku,crm.bundle.@items,crm.bundle.@price,crm.bundle.@priceGold);
                           bundle.setCRMDefinition(crm);
                           this.mOfferExpireDate = null;
                           crm.setBundleDefinition(bundle);
                        }
                        else
                        {
                           crm = null;
                        }
                     }
                     if(crm != null)
                     {
                        if(crm.actionButtonAction == ActionsLibrary.GO_TO_MISSIONS)
                        {
                           missionObject = MissionObjectManager.getInstance().getMissionBySku(crm.actionButtonParams[0]);
                           index = MissionObjectManager.getInstance().getMissions().indexOf(missionObject);
                           if(index < 0)
                           {
                              crm = null;
                           }
                        }
                        if(crm.type == CRMCustomizerDefinition.TYPE_INIT)
                        {
                           Debug.trace("CRM Init Popup: " + popup.toXMLString());
                           this.mInfoPopupsInit.push(crm);
                        }
                        else
                        {
                           this.mInfoPopupsIdle.push(crm);
                           this.mRandomRank += crm.weight;
                        }
                     }
                     continue;
                  }
                  if(crm.customizerType != CRMCustomizerDefinition.CONTENT_TYPE_CUSTOM_CONTENT)
                  {
                     continue;
                  }
                  if(crm.expCode == null)
                  {
                     if(crm.crossPromotionParams != null)
                     {
                        this.mUnlockedCrosspromotions.push(int(crm.crossPromotionParams["@pid"]));
                     }
                     continue;
                  }
                  Debug.trace("CRM AB Test detected. Code: " + crm.expCode + " Version: " + crm.expVersion);
                  expKey = crm.expCode + "_" + crm.expVersion;
                  ABTestManager.getInstance().addABTestGroup(expKey,crm.data);
                  profile = DollarsGame.getProfile();
                  if(expKey.indexOf(ABTestManager.CHANGE_FBC_PRICES) >= 0)
                  {
                     this.abTestParserFBCPriceItems(crm.data.item);
                     this.abTestParserFBCPriceEarlyUnlock(crm.data.earlyUnlock,crm.data.earlyUnlockMaxPrice[0]);
                     this.abTestParserFBCPriceCollectible(crm.data.collectible);
                     this.abTestParserFBCPriceExpansions(crm.data.expansion);
                     this.abTestParserFBCPriceService(crm.data.service);
                     this.abTestParserFBCPriceSkipAction(crm.data.skipAction[0]);
                     continue;
                  }
                  i = 0;
                  defs = null;
                  itemDef = null;
                  switch(expKey)
                  {
                     case ABTestManager.MISSION_ALT_REWARDS_1:
                        profile.missionAltRewardSet(1);
                        break;
                     case ABTestManager.MISSION_ALT_REWARDS_2:
                        profile.missionAltRewardSet(2);
                        break;
                     case ABTestManager.ALT_MISSIONS:
                        if(!profile.altMissionsGet())
                        {
                           profile.altMissionsSet(true);
                        }
                        break;
                     case ABTestManager.CREW_INVITES_CHANGE:
                        CrewMechanicsManager.getInstance().setJobsTIDs(crm.data["@sku"],crm.data["@jobs"]);
                        break;
                     case ABTestManager.INVESTMENT_REMINDER:
                        InvestManager.getInstance().setReminder(true);
                        break;
                     case ABTestManager.ENABLE_GOLD_CURRENCY:
                        if(!profile.buyGoldCurrencyGet())
                        {
                           profile.buyGoldCurrencySet(true);
                        }
                  }
               }
               this.crmEvent = 1;
               this.mStatus = 1;
            }
            else
            {
               this.crmEvent = -1;
               this.mStatus = -1;
            }
         }
         catch(error:Error)
         {
            crmEvent = -1;
            mStatus = -1;
         }
      }
      
      private function timeOutDone() : void
      {
         this.mUrlLoader.close();
         clearTimeout(this.mLoaderTimer);
         this.crmEvent = -1;
         this.mStatus = -1;
         GAMetrics.getInstance().registerEvent(MyMetrics.getGroupFromEvent(MetricConstants.EVENT_CRM_POPUP),MetricConstants.EVENT_CRM_POPUP,MetricConstants.LABEL_CRM_POPUP_TIMEOUT);
      }
      
      public function setVideoAdEnabled(param1:Boolean) : void
      {
         this.mVideoAd = param1;
      }
      
      public function getUnlockedCrosspromotions() : Array
      {
         return this.mUnlockedCrosspromotions;
      }
      
      public function getOfferTimeLeft() : String
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         if(this.mOfferExpireDate == null || this.mOfferExpireDate.valueOf() < UserDataFacade.getInstance().getServerTimeEmulated())
         {
            _loc1_ = "";
         }
         else
         {
            _loc2_ = this.mOfferExpireDate.valueOf() - UserDataFacade.getInstance().getServerTimeEmulated();
            _loc1_ = TextManager.getStringTimeOffer(_loc2_);
         }
         return _loc1_;
      }
      
      public function getVideoFunctionName() : String
      {
         return this.mVideoFunctionName;
      }
      
      public function get crmEvent() : int
      {
         if(!Config.USE_CRM_POPUPS)
         {
            return -1;
         }
         return this.mCRMEvent;
      }
      
      public function isOfferExpired() : Boolean
      {
         if(this.mOfferExpireDate == null)
         {
            return false;
         }
         if(this.mOfferExpireDate.valueOf() < UserDataFacade.getInstance().getServerTimeEmulated())
         {
            return true;
         }
         return false;
      }
      
      public function setVideoFunctionName(param1:String) : void
      {
         this.mVideoFunctionName = param1;
      }
      
      public function removePopupDefinition(param1:int) : void
      {
         var _loc2_:CRMCustomizerDefinition = null;
         if(this.mInfoPopupsIdle != null)
         {
            _loc2_ = this.mInfoPopupsIdle[param1];
            this.mRandomRank -= _loc2_.weight;
            this.mInfoPopupsIdle.splice(param1,1);
            if(this.mInfoPopupsIdle.length == 0)
            {
               this.mInfoPopupsIdle = null;
               this.crmEvent = -1;
            }
         }
      }
      
      public function loadCrmPopups() : void
      {
         var _loc1_:String = null;
         var _loc2_:XML = null;
         var _loc3_:URLRequest = null;
         if(this.crmEvent == 0)
         {
            if(Config.CUSTOMIZER_FROM_SERVER)
            {
               this.setCRMEvent(null);
            }
            else
            {
               _loc2_ = UserDataFacade.getInstance().getFileXML(UserDataFacade.TAG_WELCOME_PROGRESS);
               this.crmEvent = -1;
               if("@crmHash" in _loc2_)
               {
                  DollarsGame.smCRMhash = _loc2_.@crmHash;
               }
               if(Config.OFFLINE_GAMEPLAY_MODE)
               {
                  _loc1_ = Config.getRoot() + ModelConfig.CRM_CUSTOMIZER_XML_FILE;
               }
               else
               {
                  _loc1_ = Server.wcrmServerURL + "/customizer/?sn_uid=" + UserDataFacade.getInstance().mUserExtId + "&project_id=" + MyMetrics.getProjectId() + "&locale=" + UserDataFacade.getInstance().mUserLocale + "&sig=" + DollarsGame.smCRMhash;
               }
               this.mUrlLoader = new URLLoader();
               _loc3_ = new URLRequest(_loc1_);
               this.mUrlLoader.addEventListener(Event.COMPLETE,this.setCRMEvent);
               this.mUrlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.ErrorLoader);
               this.mUrlLoader.load(_loc3_);
               Debug.trace("request crm popups: " + _loc1_);
               this.mLoaderTimer = setTimeout(this.timeOutDone,RulesFacade.getInstance().crmPopupTimer);
            }
         }
      }
   }
}

