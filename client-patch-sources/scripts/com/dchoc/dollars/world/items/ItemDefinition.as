package com.dchoc.dollars.world.items
{
   import com.dchoc.dollars.GUI.crosspromotion.CrosspromotionDefinition;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxCommerce;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxDecoration;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxHouse;
   import com.dchoc.dollars.GUI.infoBox.InfoBoxWonder;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinition;
   import com.dchoc.dollars.GUI.shop.ShopTabDefinitionManager;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.MapDefinition;
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.offers.OfferDefinition;
   import com.dchoc.dollars.offers.OfferManager;
   import com.dchoc.dollars.utils.abtest.ABTestManager;
   import com.dchoc.dollars.utils.crypto.EncryptionUtils;
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.world.World;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.commerces.CommerceTypeDefinition;
   import com.dchoc.dollars.world.items.commerces.CommerceTypeDefinitionManager;
   import com.dchoc.dollars.world.items.decorations.ItemDecorationDefinitionManager;
   import com.dchoc.dollars.world.items.gui.InfluenceIcon;
   import com.dchoc.dollars.world.items.gui.InfluenceIconCommerce;
   import com.dchoc.dollars.world.items.gui.InfluenceIconDecoration;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinition;
   import com.dchoc.dollars.world.items.wonders.WonderTypeDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.utils.getDefinitionByName;
   
   public class ItemDefinition extends Definition
   {
      
      public static const MAGIC_PRIME_ENCRYPTION_NUMBER:Number = Dollars.getMagicEncryptionNumber();
      
      public static const MAGIC_PRIME_ENCRYPTION_KEY:Number = 12479897;
      
      public static const BUILD_FORMAT_LONG_ID:int = 0;
      
      public static const BUILD_FORMAT_SHORT_ID:int = 1;
      
      public static const BUILD_FORMAT_COUNT:int = 2;
      
      private static const BUILD_FORMAT_DEFAULT_ID:int = BUILD_FORMAT_LONG_ID;
      
      public static const TYPE_HOUSES_ID:uint = 0;
      
      public static const TYPE_COMMERCES_ID:uint = 1;
      
      public static const TYPE_DECORATIONS_ID:uint = 2;
      
      public static const TYPE_WONDERS_ID:uint = 3;
      
      public static const TYPE_CLUBS_ID:uint = 4;
      
      public static const TYPE_BUNDLE_ID:uint = 5;
      
      public static const TYPE_COUNT:uint = 6;
      
      public static const EXTRA_TYPE_LINK:String = "link";
      
      public static const EXTRA_TYPE_BRIDGE:String = "bridge";
      
      public static const SALE_MODE_NORMAL:int = 0;
      
      public static const SALE_MODE_LIM_ED:int = 1;
      
      public static const SALE_MODE_AUCTION:int = 2;
      
      public static const NAME_TYPES:Array = ["Houses","Commerces","Decorations","Wonders","Clubs"];
      
      public static const TYPE_INFO_BOX:Array = [InfoBoxHouse,InfoBoxCommerce,InfoBoxDecoration,InfoBoxWonder,InfoBoxCommerce];
      
      private static const INFLUENCE_ICON_CLASS:Array = [InfluenceIconDecoration,InfluenceIconCommerce,null,null,InfluenceIconCommerce];
      
      public static const SKU_HEADQUARTERS:String = "HeadQuarter";
      
      public static const UNLOCK_CONDITION_LEVEL_ID:int = 0;
      
      public static const UNLOCK_CONDITION_FAN_ID:int = 1;
      
      public static const UNLOCK_CONDITION_CROSS_ID:int = 2;
      
      public static const UNLOCK_CONDITION_COUNT:int = 3;
      
      public static const UNLOCK_CONDITION_LABELS:Array = ["level","fan","cross"];
      
      private static const UNLOCK_CONDITION_ID_ID:int = 0;
      
      private static const UNLOCK_CONDITION_CROSS_GAME_ID:int = 1;
      
      private static const UNLOCK_TEXT_IDS:Array = [TextIDs.TID_HINT_BUTTON_BUY,TextIDs.TID_BUTTON_FAN,TextIDs.TID_PLAY_MMA];
      
      public static const WONDER_NPC_PREFIX_SKU:String = "wonder_npc_";
      
      public static const EFFECTS_NAME_PREFIX:String = "Effect_";
      
      public static const EFFECT_NAME_LAYOUT:String = "_top";
      
      public static const EFFECT_NAME_PEOPLE_LAYOUT:String = "_people";
      
      public static const CREW_INVITED:int = 0;
      
      public static const CREW_PAID:int = 1;
      
      public static const INSTANT_BUILD_A4H:String = "A4H";
      
      public static const INSTANT_BUILD_CASH:String = "CASH";
      
      public static const INSTANT_BUILD_FBC_A4H:String = "FBC:A4H";
      
      public static const INSTANT_BUILD_CASH_FBC_A4H:String = "CASH:FBC:A4H";
      
      private static const WHERE_SHOP:String = "shop";
      
      private static const WHERE_COLLECTIONS:String = "collections";
      
      protected var mCompanyValue:int;
      
      protected var mInstantBuildFactor:Number;
      
      protected var mUnlockCondition:Array;
      
      protected var mOptCurrentId:int = 1;
      
      protected var mSaleMode:int;
      
      protected var mShopIcon:String;
      
      protected var mInstantBuildFBC_ABTest:int;
      
      protected var mMoveCash:int;
      
      protected var mConstructionCash:int;
      
      protected var mConstructionFBCnoCash:int;
      
      protected var mConstructionCrewSku:String;
      
      protected var mSubtype:Array;
      
      protected var mIsFeaturedABTest:Boolean;
      
      protected var mTarget:String;
      
      protected var mIncomeTime:int;
      
      protected var mNeedsToCheckLocked:Boolean;
      
      protected var mConstructionFBC:int;
      
      protected var mInstantBuildType:String;
      
      protected var mOptMax:int = -1;
      
      protected var mWhere:Array;
      
      protected var mInstantBuildType_ABTest:String;
      
      protected var mUseAdvisor:Boolean;
      
      protected var mIncomeValue:int;
      
      protected var mInstantBuildFBC:int;
      
      protected var mConstructionCoins:int;
      
      protected var mReleaseTime:Number = 0;
      
      protected var mMoveCoins:int;
      
      protected var mExpireTime:Number = 0;
      
      protected var mUnlockCash:int;
      
      protected var mBaseCols:int;
      
      protected var mDecorations:Array;
      
      protected var mContractsTypeSku:String;
      
      protected var mAmountOfHelp:int;
      
      protected var mIsAnimated:Boolean;
      
      protected var mFreeGift:Boolean;
      
      protected var mInfluenceValue:Number;
      
      protected var mHasExpireTime:Boolean;
      
      protected var mShadowRows:int;
      
      protected var mExtraType:String;
      
      protected var mShowsInABTest:String;
      
      protected var mBaseWidth:Number;
      
      protected var mShopTab:String;
      
      protected var mPopulation:int;
      
      protected var mIncomeLevelFactor:Number;
      
      protected var mBaseHeight:Number;
      
      protected var mSubsku:String;
      
      protected var mExperience:int;
      
      protected var mOfferDef:OfferDefinition;
      
      protected var mIsFeatured:Boolean;
      
      protected var mItemName:String;
      
      protected var mConstructionTime:Number;
      
      protected var mTextID:String;
      
      protected var mBaseRows:int;
      
      protected var mEventOnTime:int;
      
      protected var mInfluenceRatio:int;
      
      protected var mTenants:int;
      
      protected var mIncomeXP:int;
      
      protected var mUnitsAmount:int;
      
      public function ItemDefinition(param1:uint = 0)
      {
         super(param1);
         this.mUnlockCondition = new Array();
         this.mDecorations = new Array();
         this.mNeedsToCheckLocked = true;
         this.mSaleMode = SALE_MODE_NORMAL;
      }
      
      public static function getItemDesignClass(param1:String, param2:String) : Class
      {
         var _loc3_:Class = null;
         if(Config.USE_OLD_ITEM_DESIGNS)
         {
            _loc3_ = DCResourceManager.getInstance().getSWFClass(param1,param2);
            if(_loc3_ == null)
            {
               _loc3_ = DCResourceManager.getInstance().getSWFClass(param1,param2 + "_new");
            }
         }
         else
         {
            _loc3_ = DCResourceManager.getInstance().getSWFClass(param1,param2 + "_new");
            if(_loc3_ == null)
            {
               _loc3_ = DCResourceManager.getInstance().getSWFClass(param1,param2);
            }
         }
         return _loc3_;
      }
      
      public static function isAllowedToBeInShop(param1:ItemDefinition) : Boolean
      {
         return param1.isAllowedToBeInShop();
      }
      
      public static function getTypeIDFromName(param1:String) : int
      {
         var _loc2_:int = NAME_TYPES.indexOf(param1);
         if(_loc2_ == -1)
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      public static function isAllowedToBeInLevelUp(param1:ItemDefinition) : Boolean
      {
         return param1.isAllowedToBeInLevelUp();
      }
      
      public function getSaleMode() : int
      {
         return this.mSaleMode;
      }
      
      public function getShopIcon() : String
      {
         return this.mShopIcon;
      }
      
      public function getIncomeTime() : int
      {
         checkChecksum();
         return this.mIncomeTime;
      }
      
      public function get offerDef() : OfferDefinition
      {
         return this.mOfferDef;
      }
      
      public function setUnlockConditionCrossAppId(param1:int) : void
      {
         this.mUnlockCondition[UNLOCK_CONDITION_CROSS_GAME_ID] = param1;
      }
      
      public function getContractsTypeSku() : String
      {
         return this.mContractsTypeSku;
      }
      
      public function set offerDef(param1:OfferDefinition) : void
      {
         this.mOfferDef = param1;
         if(this.mOfferDef == null)
         {
            this.setIsFeatured(false);
            ItemDefinitionManager.getInstance().removeItemDefinitionFeatured(this);
         }
         else
         {
            this.setIsFeatured(true);
            ItemDefinitionManager.getInstance().addItemDefinitionFeatured(this);
         }
      }
      
      public function getMoveCash() : int
      {
         checkChecksum();
         return this.mMoveCash;
      }
      
      public function needsToLoadResourceBase() : Boolean
      {
         return this.requiresTerrainMine();
      }
      
      public function getBuildObject(param1:String) : Sprite
      {
         var _loc2_:Sprite = null;
         var _loc3_:Class = null;
         if(this.mOptMax == -1)
         {
            this.loadDisplayOptionalParameters();
         }
         if(this.mOptMax > 0)
         {
            _loc2_ = new (DCResourceManager.getInstance().getSWFClass(this.getSkuToLoad(),"opt_" + this.mOptCurrentId))();
         }
         else
         {
            _loc3_ = getItemDesignClass(this.getSkuToLoad(),param1);
            _loc2_ = new _loc3_() as MovieClip;
         }
         return _loc2_;
      }
      
      public function setInstantBuildFBC(param1:int) : void
      {
         this.mInstantBuildFBC = param1;
      }
      
      public function getIncomeValue() : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mIncomeValue,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function isAffectedByWonderInfluence() : Boolean
      {
         return mType == TYPE_COMMERCES_ID || this.isAffectedByInfluence();
      }
      
      public function set textID(param1:String) : void
      {
         this.mTextID = param1;
      }
      
      public function set shadowRows(param1:int) : void
      {
         this.mShadowRows = param1;
      }
      
      public function get useAdvisor() : Boolean
      {
         return this.mUseAdvisor;
      }
      
      public function get baseTilesCount() : int
      {
         return this.baseRows * this.baseCols;
      }
      
      public function needsToRegisterNumberOfConstructionsFinished() : Boolean
      {
         return mType == TYPE_COMMERCES_ID;
      }
      
      public function set incomeTime(param1:Number) : void
      {
         var _loc2_:Number = mType == TYPE_COMMERCES_ID ? TimerUtil.minToMs(param1) : TimerUtil.hourToMs(param1);
         this.mIncomeTime = _loc2_;
      }
      
      public function get itemName() : String
      {
         return this.mItemName;
      }
      
      public function setTenants(param1:int) : void
      {
         this.mTenants = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function set influenceRatio(param1:int) : void
      {
         this.mInfluenceRatio = param1;
         if(Config.SIG_ENCRYPT_METHOD)
         {
            this.mInfluenceRatio = EncryptionUtils.encrypt(0,this.mInfluenceRatio,this.mShadowRows,Dollars.getMagicEncryptionNumber());
         }
      }
      
      public function get baseRows() : int
      {
         checkChecksum();
         return this.mBaseRows;
      }
      
      public function isACommerce() : Boolean
      {
         return mType == TYPE_COMMERCES_ID;
      }
      
      public function setIsFeaturedABTest(param1:Boolean) : void
      {
         this.mIsFeaturedABTest = param1;
      }
      
      public function getReleaseTime() : Number
      {
         return this.mReleaseTime;
      }
      
      public function getBuildFormatId() : int
      {
         var _loc1_:int = BUILD_FORMAT_DEFAULT_ID;
         if(Config.OPT_USE_BUILD_SHORT_FORMAT)
         {
            _loc1_ = this.getFormatId();
         }
         return _loc1_;
      }
      
      public function getCommerceIcon() : String
      {
         if(Config.USE_BITMAP_DATA_ANIMATIONS && Config.USE_OLD_ICON_SYSTEM)
         {
            return mSku + "_icon.png";
         }
         return mSku + ".png";
      }
      
      public function setInstantBuildFBCABTest(param1:int) : void
      {
         this.mInstantBuildFBC_ABTest = param1;
      }
      
      public function get nameType() : String
      {
         return NAME_TYPES[mType];
      }
      
      override public function build() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         this.mBaseWidth = this.mBaseCols * MapDefinition.getInstance().getTileWidth();
         this.mBaseHeight = this.mBaseRows * MapDefinition.getInstance().getTileHeight();
         var _loc1_:Number = RulesFacade.getTimePrice() * TimerUtil.msToMin(this.mConstructionTime) * this.mInstantBuildFactor;
         if(_loc1_ > int.MAX_VALUE)
         {
            _loc2_ = int.MAX_VALUE / (RulesFacade.getTimePrice() * TimerUtil.msToMin(this.mConstructionTime));
            trace("****** instant build error : " + mSku + " max = " + int.MAX_VALUE + " factor = " + _loc2_);
         }
         if(this.shopTab != "")
         {
            _loc3_ = this.shopTab.split(",");
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_ != "")
               {
                  if(_loc4_ == "limEd")
                  {
                     this.mSaleMode = SALE_MODE_LIM_ED;
                     if(!Config.OFFLINE_GAMEPLAY_MODE)
                     {
                        this.mUnitsAmount = 0;
                     }
                  }
                  else
                  {
                     ItemDefinitionManager.getInstance().addDefinitionType(this,ShopTabDefinitionManager.getInstance().getShopTabAsIndex(_loc4_));
                  }
               }
            }
         }
         this.mSubsku = "";
         if(mType == TYPE_HOUSES_ID && !this.isHeadQuarters())
         {
            _loc5_ = sku.split("_");
            this.mSubsku = _loc5_[0] + "_" + _loc5_[1];
         }
      }
      
      public function setMoveCoins(param1:int) : void
      {
         this.mMoveCoins = param1;
      }
      
      public function setInstantBuildType(param1:String) : void
      {
         this.mInstantBuildType = param1;
      }
      
      public function set useAdvisor(param1:Boolean) : void
      {
         this.mUseAdvisor = param1;
      }
      
      public function toString() : String
      {
         return "";
      }
      
      public function setCompanyValue(param1:int) : void
      {
         this.mCompanyValue = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getInfluenceValue() : Number
      {
         checkChecksum();
         var _loc1_:Number = this.mInfluenceValue;
         if(Config.SIG_ENCRYPT_METHOD)
         {
            _loc1_ = EncryptionUtils.decrypt(0,this.mInfluenceValue,this.mShadowRows,Dollars.getMagicEncryptionNumber());
         }
         return _loc1_;
      }
      
      public function getMoveFactor() : Number
      {
         var _loc1_:Number = this.mInstantBuildFactor;
         if(_loc1_ > 1)
         {
            _loc1_ = 1;
         }
         return _loc1_;
      }
      
      public function getExpireTime() : Number
      {
         return this.mExpireTime;
      }
      
      public function set itemName(param1:String) : void
      {
         this.mItemName = param1;
      }
      
      public function getUnlockText() : String
      {
         return TextManager.getText(UNLOCK_TEXT_IDS[this.mUnlockCondition[UNLOCK_CONDITION_ID_ID]]);
      }
      
      public function set constructionTime(param1:Number) : void
      {
         this.mConstructionTime = TimerUtil.minToMs(param1);
      }
      
      public function getUnlockCash() : int
      {
         return this.mUnlockCash;
      }
      
      public function setExpireTime(param1:Number) : void
      {
         this.mExpireTime = param1;
         this.mHasExpireTime = true;
      }
      
      public function set incomeValue(param1:Number) : void
      {
         this.mIncomeValue = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function set baseRows(param1:int) : void
      {
         this.mBaseRows = param1;
      }
      
      public function setUnlockCash(param1:int) : void
      {
         this.mUnlockCash = param1;
      }
      
      public function set population(param1:int) : void
      {
         this.mPopulation = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getInstantBuildFBC() : int
      {
         return this.mInstantBuildFBC;
      }
      
      public function getAmountOfHelp() : int
      {
         if(this.mAmountOfHelp == 0)
         {
            this.mAmountOfHelp = 100 / RulesFacade.getInstance().askForHelpAccelerateItemPercent();
         }
         return this.mAmountOfHelp;
      }
      
      public function needsToRegisterNumberOfConstructions() : Boolean
      {
         return mType == TYPE_WONDERS_ID || mType == TYPE_CLUBS_ID;
      }
      
      public function hasCommerceBehaviour() : Boolean
      {
         return this.isACommerce() || this.isAClub();
      }
      
      public function requiresTerrainMine() : Boolean
      {
         return mType != TYPE_DECORATIONS_ID;
      }
      
      override public function needsToLoadSWF() : Boolean
      {
         return !this.isHeadQuarters();
      }
      
      public function showsBarDemolition() : Boolean
      {
         return mType == TYPE_HOUSES_ID || mType == TYPE_COMMERCES_ID || mType == TYPE_WONDERS_ID || mType == TYPE_CLUBS_ID;
      }
      
      public function getConstructionTime() : Number
      {
         return this.mConstructionTime;
      }
      
      public function getInstantBuildFactor() : Number
      {
         return this.mInstantBuildFactor;
      }
      
      public function setInstantBuildFactor(param1:Number) : void
      {
         this.mInstantBuildFactor = param1;
      }
      
      public function get shopTab() : String
      {
         return this.mShopTab;
      }
      
      public function set incomeXP(param1:int) : void
      {
         this.mIncomeXP = param1;
      }
      
      public function set baseCols(param1:int) : void
      {
         this.mBaseCols = param1;
      }
      
      public function getInfluenceRatioX() : int
      {
         var _loc1_:int = this.getInfluenceRatio();
         var _loc2_:int = this.baseCols >> 1;
         return _loc1_ + _loc2_;
      }
      
      public function getInfluenceRatioY() : int
      {
         var _loc1_:int = this.getInfluenceRatio();
         var _loc2_:int = this.baseRows >> 1;
         return _loc1_ + _loc2_;
      }
      
      override public function getSkuToLoad() : String
      {
         var _loc1_:String = sku;
         if(this.mUseAdvisor)
         {
            _loc1_ = _loc1_ + "_" + DollarsGame.getProfile().bossName;
         }
         return _loc1_;
      }
      
      public function isLocked() : Boolean
      {
         var _loc2_:Array = null;
         var _loc1_:Boolean = false;
         if(this.mNeedsToCheckLocked)
         {
            switch(this.getUnlockConditionID())
            {
               case UNLOCK_CONDITION_LEVEL_ID:
                  _loc1_ = DollarsGame.getProfile().level < level;
                  break;
               case UNLOCK_CONDITION_FAN_ID:
                  _loc1_ = !DollarsGame.getProfile().isFan;
                  break;
               case UNLOCK_CONDITION_CROSS_ID:
                  _loc2_ = CustomizerManager.getInstance().getUnlockedCrosspromotions();
                  _loc1_ = _loc2_.indexOf(this.getUnlockConditionCrossAppID()) == -1;
            }
         }
         if(!_loc1_ && this.mSaleMode == SALE_MODE_LIM_ED)
         {
            if(this.isAllowedToBeInShop())
            {
               _loc1_ = this.getUnitsAmount() == 0;
            }
         }
         return _loc1_;
      }
      
      public function getConstructionFBCredits(param1:Boolean = true) : int
      {
         checkChecksum();
         var _loc2_:int = this.mConstructionFBC;
         if(param1 && this.mOfferDef != null)
         {
            if(this.mOfferDef.offerType == OfferManager.TYPE_DISCOUNT)
            {
               _loc2_ = int(_loc2_ - _loc2_ * this.mOfferDef.amount);
            }
         }
         return _loc2_;
      }
      
      public function getTenants() : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mTenants,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function set experience(param1:int) : void
      {
         this.mExperience = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getUnlockCoindition() : Array
      {
         return this.mUnlockCondition;
      }
      
      public function get subsku() : String
      {
         return this.mSubsku;
      }
      
      public function getInfluenceSideX() : int
      {
         var _loc1_:int = this.getInfluenceRatio() * 2;
         return _loc1_ + this.baseCols;
      }
      
      public function getInfluenceSideY() : int
      {
         var _loc1_:int = this.getInfluenceRatio() * 2;
         return _loc1_ + this.baseRows;
      }
      
      public function setUnitsAmount(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this.mUnitsAmount = param1;
      }
      
      public function isSubtypeOf(param1:String) : Boolean
      {
         if(this.mSubtype.indexOf(param1) != -1)
         {
            return true;
         }
         return false;
      }
      
      public function getTidDescription() : String
      {
         return this.textID + "_DESCRIPTION";
      }
      
      public function getUnlockConditionID() : int
      {
         return this.mUnlockCondition[UNLOCK_CONDITION_ID_ID] as int;
      }
      
      public function set extraType(param1:String) : void
      {
         this.mExtraType = param1;
      }
      
      public function get isAnimated() : Boolean
      {
         return this.mIsAnimated;
      }
      
      public function get showsInABTest() : String
      {
         return this.mShowsInABTest;
      }
      
      public function shopClickUnlockButton(param1:CrosspromotionDefinition = null) : void
      {
         switch(this.getUnlockConditionID())
         {
            case UNLOCK_CONDITION_FAN_ID:
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_BECAME_FAN);
               break;
            case UNLOCK_CONDITION_CROSS_ID:
               UserDataFacade.getInstance().requestTask(UserDataFacade.TASK_OPEN_URL,{"url":param1.url});
         }
      }
      
      public function getDisplayObject(param1:String, param2:Boolean = false) : Sprite
      {
         var _loc3_:Sprite = new (DCResourceManager.getInstance().getSWFClass(this.getSkuToLoad(),param1))();
         if(param2)
         {
            this.addIcons(_loc3_ as DisplayObjectContainer);
         }
         return _loc3_;
      }
      
      public function set subtype(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Array = param1.split(",");
         while(_loc3_ < _loc2_.length)
         {
            _loc2_[_loc3_] = TextManager.trim(_loc2_[_loc3_]);
            _loc3_++;
         }
         this.mSubtype = _loc2_;
      }
      
      override public function getTidsCount() : int
      {
         var _loc1_:int = 1;
         if(mType == TYPE_HOUSES_ID)
         {
            _loc1_ += 1;
         }
         return _loc1_;
      }
      
      public function getIcon(param1:Sprite, param2:Boolean = false, param3:Boolean = false) : Object
      {
         var _loc7_:Class = null;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc4_:String = this.getSkuToLoad();
         var _loc5_:Class = getItemDesignClass(_loc4_,"normal");
         var _loc6_:MovieClip = new _loc5_() as MovieClip;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:Array = ["",EFFECT_NAME_LAYOUT];
         var _loc11_:int = 0;
         while(_loc11_ < _loc10_.length)
         {
            _loc9_ = 0;
            do
            {
               _loc8_ = false;
               _loc7_ = null;
               _loc7_ = getItemDesignClass(this.getSkuToLoad(),EFFECTS_NAME_PREFIX + _loc9_ + _loc10_[_loc11_]);
               _loc8_ ||= _loc7_ != null;
               if(_loc7_ != null)
               {
                  _loc6_.addChild(new _loc7_());
               }
               _loc9_++;
            }
            while(_loc8_);
            _loc11_++;
         }
         var _loc12_:Sprite = null;
         var _loc13_:int = this.mBaseWidth / this.mBaseCols;
         var _loc14_:Number = (param1.height - 10) / _loc6_.height;
         var _loc15_:Number = (param1.width - 20) / _loc6_.width;
         var _loc16_:Number = _loc14_ > _loc15_ ? _loc15_ : _loc14_;
         if(_loc16_ >= 1)
         {
            _loc16_ = 1;
         }
         _loc6_.scaleX = _loc16_;
         _loc6_.scaleY = _loc16_;
         var _loc17_:int = (param1.width - this.mBaseWidth * _loc16_) / 2;
         var _loc18_:int = param1.height - (param1.height - _loc6_.height) / 2;
         _loc6_.y = _loc18_;
         _loc6_.x = _loc17_;
         if(param2)
         {
            _loc13_ = this.mBaseWidth * _loc16_ / this.mBaseCols;
            _loc12_ = new Sprite();
            _loc12_.graphics.lineStyle(1,7109665,0.5);
            _loc19_ = (_loc17_ - 4) / _loc13_;
            _loc20_ = _loc17_ -= _loc13_ * _loc19_;
            while(_loc20_ < param1.width - 4)
            {
               _loc12_.graphics.moveTo(_loc20_,4);
               _loc12_.graphics.lineTo(_loc20_,param1.height - 4);
               _loc20_ += _loc13_;
            }
            _loc19_ = (_loc18_ - 4) / _loc13_;
            _loc21_ = _loc18_ -= _loc13_ * _loc19_;
            while(_loc21_ < param1.height - 4)
            {
               _loc12_.graphics.moveTo(4,_loc21_);
               _loc12_.graphics.lineTo(param1.width - 4,_loc21_);
               _loc21_ += _loc13_;
            }
         }
         if(param3)
         {
            Dollars.playChilds(_loc6_);
            _loc6_.cacheAsBitmap = false;
         }
         else
         {
            Dollars.stopChild(_loc6_);
            _loc6_.cacheAsBitmap = true;
         }
         return {
            "icon":_loc6_,
            "grid":_loc12_
         };
      }
      
      public function getFormatId() : int
      {
         var _loc1_:int = BUILD_FORMAT_DEFAULT_ID;
         if(mType == TYPE_DECORATIONS_ID && Config.OPT_USE_SHORT_FORMAT)
         {
            _loc1_ = BUILD_FORMAT_SHORT_ID;
         }
         return _loc1_;
      }
      
      public function set influenceValue(param1:Number) : void
      {
         this.mInfluenceValue = param1;
         if(Config.SIG_ENCRYPT_METHOD)
         {
            this.mInfluenceValue = EncryptionUtils.encrypt(0,this.mInfluenceValue,this.mShadowRows,Dollars.getMagicEncryptionNumber());
         }
      }
      
      public function addIcons(param1:DisplayObjectContainer) : void
      {
         var _loc2_:Array = null;
         var _loc3_:ShopTabDefinition = null;
         var _loc4_:ShopTabDefinition = null;
         if(this.shopTab != null)
         {
            _loc2_ = this.getShopTabDefinitions();
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_.getUsesIconOnItemShop())
               {
                  param1.addChild(_loc3_.getIconOnItemShopDO());
               }
            }
         }
         if(this.mShopIcon != null)
         {
            _loc4_ = ShopTabDefinitionManager.getInstance().getDefinitionBySku(this.mShopIcon) as ShopTabDefinition;
            if(_loc4_ != null && _loc4_.getUsesIconOnItemShop())
            {
               param1.addChild(_loc4_.getIconOnItemShopDO());
            }
         }
      }
      
      public function getConstructionCoins(param1:Boolean = true) : int
      {
         checkChecksum();
         var _loc2_:int = EncryptionUtils.decrypt(0,this.mConstructionCoins,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
         if(param1)
         {
            if(this.mOfferDef != null && this.mOfferDef.offerType == OfferManager.TYPE_DISCOUNT)
            {
               _loc2_ = int(_loc2_ - _loc2_ * this.mOfferDef.amount);
            }
            if(OfferManager.getInstance().isFreeItem(mSku))
            {
               _loc2_ = 0;
            }
         }
         return _loc2_;
      }
      
      public function getConstructionFBCnoCash() : int
      {
         checkChecksum();
         return this.mConstructionFBCnoCash;
      }
      
      public function place() : void
      {
         var _loc1_:Object = null;
         switch(this.mSaleMode)
         {
            case SALE_MODE_LIM_ED:
               --this.mUnitsAmount;
               _loc1_ = new Object();
               _loc1_.sku = mSku;
               _loc1_.itemsLeft = "" + this.mUnitsAmount;
               if(this.mUnitsAmount == 0)
               {
                  _loc1_.lastLegalBuyTime = "" + UserDataFacade.getInstance().getServerTimeEmulated();
               }
               DollarsGame.externalRequest(DollarsGame.REQ_LIM_ED_RESPONSE,_loc1_);
         }
      }
      
      public function get textID() : String
      {
         return this.mTextID;
      }
      
      public function setShopIcon(param1:String) : void
      {
         this.mShopIcon = param1;
      }
      
      public function set eventOnTime(param1:int) : void
      {
         this.mEventOnTime = TimerUtil.minToMs(param1);
      }
      
      public function set incomeLevelFactor(param1:Number) : void
      {
         this.mIncomeLevelFactor = param1;
      }
      
      public function getHasExpireTime() : Boolean
      {
         return this.mHasExpireTime;
      }
      
      public function get shadowRows() : int
      {
         return this.mShadowRows;
      }
      
      public function getConstructionCash(param1:Boolean = true) : int
      {
         checkChecksum();
         var _loc2_:int = this.mConstructionCash;
         if(param1 && this.mOfferDef != null)
         {
            if(this.mOfferDef.offerType == OfferManager.TYPE_DISCOUNT)
            {
               _loc2_ = int(_loc2_ - _loc2_ * this.mOfferDef.amount);
            }
         }
         return _loc2_;
      }
      
      public function getInfluenceRatio() : int
      {
         checkChecksum();
         var _loc1_:int = this.mInfluenceRatio;
         if(Config.SIG_ENCRYPT_METHOD)
         {
            _loc1_ = EncryptionUtils.decrypt(0,this.mInfluenceRatio,this.mShadowRows,Dollars.getMagicEncryptionNumber());
         }
         return _loc1_;
      }
      
      public function setNeedsToCheckLocked(param1:Boolean) : void
      {
         this.mNeedsToCheckLocked = param1;
      }
      
      public function set target(param1:String) : void
      {
         this.mTarget = TextManager.trim(param1);
      }
      
      public function setMoveCash(param1:int) : void
      {
         this.mMoveCash = param1;
      }
      
      public function setContractsTypeSku(param1:String) : void
      {
         this.mContractsTypeSku = TextManager.trim(param1);
      }
      
      public function getWhere() : Array
      {
         return this.mWhere;
      }
      
      public function getCommerceType() : CommerceTypeDefinition
      {
         var _loc1_:Definition = CommerceTypeDefinitionManager.getInstance().getDefinitionBySku(this.mSubtype[0]);
         return _loc1_ as CommerceTypeDefinition;
      }
      
      public function set constructionFBC(param1:int) : void
      {
         this.mConstructionFBC = param1;
      }
      
      public function getShopTabDefinitions() : Array
      {
         var _loc2_:ShopTabDefinitionManager = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:ShopTabDefinition = null;
         var _loc1_:Array = new Array();
         if(this.mShopTab != null)
         {
            _loc2_ = ShopTabDefinitionManager.getInstance();
            _loc3_ = this.mShopTab.split(",");
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = _loc2_.getDefinitionBySku(_loc4_) as ShopTabDefinition;
               if(_loc5_ != null)
               {
                  _loc1_.push(_loc5_);
               }
            }
         }
         return _loc1_;
      }
      
      public function requiresMapGrid() : Boolean
      {
         return this.baseTilesCount > 2;
      }
      
      public function getUnlockPrice(param1:Boolean = true) : int
      {
         var _loc2_:int = 0;
         if(this.getUnlockConditionID() == UNLOCK_CONDITION_LEVEL_ID && level > DollarsGame.getProfile().level)
         {
            _loc2_ = RulesFacade.getInstance().unlockSegmentsGetPrice(DollarsGame.getProfile().level,level,param1);
         }
         var _loc3_:int = RulesFacade.getInstance().settingsGetUnlockMaxPrice(param1);
         if(_loc2_ > _loc3_)
         {
            _loc2_ = _loc3_;
         }
         return _loc2_;
      }
      
      public function getPopulation() : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mPopulation,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getSubtype() : Array
      {
         return this.mSubtype;
      }
      
      public function isAllowedToBeInShop() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:World = null;
         var _loc4_:Company = null;
         var _loc1_:Boolean = true;
         if(this.mShowsInABTest != null)
         {
            if(!ABTestManager.getInstance().isABTest(this.mShowsInABTest))
            {
               return false;
            }
            _loc1_ = true;
         }
         if(this.isHeadQuarters() || !this.isInShop())
         {
            _loc1_ = false;
         }
         if(_loc1_ && this.mFreeGift)
         {
            _loc1_ = false;
         }
         if(_loc1_ && mType == TYPE_WONDERS_ID)
         {
            _loc2_ = mSku.indexOf(WONDER_NPC_PREFIX_SKU);
            if(_loc2_ != -1 && mSku != WONDER_NPC_PREFIX_SKU + RulesFacade.getInstance().npcsGetSku(DollarsGame.getProfile().bossGenre))
            {
               _loc1_ = false;
            }
         }
         if(this.mReleaseTime > 0)
         {
            _loc1_ = UserDataFacade.getInstance().getServerTimeEmulated() >= this.getReleaseTime();
         }
         if(_loc1_ && this.mSaleMode == SALE_MODE_LIM_ED)
         {
            _loc1_ = this.mUnitsAmount > 0 || this.mHasExpireTime;
         }
         if(_loc1_ && this.mHasExpireTime)
         {
            _loc1_ = UserDataFacade.getInstance().getServerTimeEmulated() < this.getExpireTime();
         }
         if(this is BundleDefinition && this.level > DollarsGame.getProfile().level)
         {
            _loc1_ = false;
         }
         if(_loc1_ && mType == TYPE_CLUBS_ID)
         {
            _loc3_ = DollarsGame.getCurrentWorld();
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.getCompanyMine();
               if(_loc4_ != null)
               {
                  _loc1_ = _loc4_.registerOccurrenceGetAmount(mSku) == 0;
               }
            }
         }
         return _loc1_;
      }
      
      public function set constructionCash(param1:int) : void
      {
         this.mConstructionCash = param1;
      }
      
      public function setUnlockConditionID(param1:int) : void
      {
         this.mUnlockCondition[UNLOCK_CONDITION_ID_ID] = param1;
      }
      
      public function getInfluenceIcon() : InfluenceIcon
      {
         var _loc1_:InfluenceIcon = null;
         if(INFLUENCE_ICON_CLASS[mType] != null)
         {
            _loc1_ = new INFLUENCE_ICON_CLASS[mType]();
         }
         return _loc1_;
      }
      
      public function set constructionFBCnoCash(param1:int) : void
      {
         this.mConstructionFBCnoCash = param1;
      }
      
      public function getInstantBuildType() : String
      {
         return this.mInstantBuildType;
      }
      
      public function isAllowedToBeInLevelUp() : Boolean
      {
         var _loc2_:int = 0;
         var _loc1_:Boolean = true;
         if(this.mShowsInABTest != null)
         {
            if(!ABTestManager.getInstance().isABTest(this.mShowsInABTest))
            {
               return false;
            }
            _loc1_ = true;
         }
         if(this.isHeadQuarters() || !this.isInShop())
         {
            _loc1_ = false;
         }
         if(_loc1_ && this.mFreeGift)
         {
            _loc1_ = false;
         }
         if(_loc1_ && mType == TYPE_WONDERS_ID)
         {
            _loc2_ = mSku.indexOf(WONDER_NPC_PREFIX_SKU);
            if(_loc2_ != -1 && mSku != WONDER_NPC_PREFIX_SKU + RulesFacade.getInstance().npcsGetSku(DollarsGame.getProfile().bossGenre))
            {
               _loc1_ = false;
            }
         }
         if(this.mReleaseTime > 0)
         {
            _loc1_ = UserDataFacade.getInstance().getServerTimeEmulated() >= this.getReleaseTime();
         }
         if(_loc1_ && this.mSaleMode == SALE_MODE_LIM_ED)
         {
            _loc1_ = this.mUnitsAmount > 0 || this.mHasExpireTime;
         }
         if(_loc1_ && this.mHasExpireTime)
         {
            _loc1_ = UserDataFacade.getInstance().getServerTimeEmulated() < this.getExpireTime();
         }
         if(type == TYPE_BUNDLE_ID || type == TYPE_CLUBS_ID)
         {
            _loc1_ = false;
         }
         return _loc1_;
      }
      
      public function getEventOnTime() : int
      {
         checkChecksum();
         return this.mEventOnTime;
      }
      
      public function getExperience(param1:uint = 0) : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mExperience,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function set constructionCoins(param1:int) : void
      {
         this.mConstructionCoins = EncryptionUtils.encrypt(0,param1,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function getIsFeaturedABTest() : Boolean
      {
         return this.mIsFeaturedABTest;
      }
      
      public function get baseCols() : int
      {
         checkChecksum();
         return this.mBaseCols;
      }
      
      public function set decoration(param1:String) : void
      {
         param1 = TextManager.trim(param1);
         this.mDecorations.push(ItemDecorationDefinitionManager.getInstance().getItemDecorationByType(param1));
      }
      
      public function hasBarPosition() : Boolean
      {
         return mSku != SKU_HEADQUARTERS;
      }
      
      public function getCompanyValue() : int
      {
         checkChecksum();
         return EncryptionUtils.decrypt(0,this.mCompanyValue,MAGIC_PRIME_ENCRYPTION_KEY,MAGIC_PRIME_ENCRYPTION_NUMBER);
      }
      
      public function get baseHeight() : Number
      {
         return this.mBaseHeight;
      }
      
      public function getUnitsAmount() : int
      {
         return this.mUnitsAmount;
      }
      
      public function setUnlockCondition(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc5_:int = 0;
         param1 = TextManager.trim(param1);
         _loc2_ = param1.split("_");
         var _loc3_:int = UNLOCK_CONDITION_LEVEL_ID;
         var _loc4_:int = UNLOCK_CONDITION_LABELS.indexOf(_loc2_[0]);
         if(_loc4_ > -1)
         {
            _loc3_ = _loc4_;
         }
         this.setUnlockConditionID(_loc3_);
         switch(_loc3_)
         {
            case UNLOCK_CONDITION_FAN_ID:
               ItemDefinitionManager.getInstance().setItemDefinitionFan(this);
               break;
            case UNLOCK_CONDITION_CROSS_ID:
               _loc5_ = int(_loc2_[UNLOCK_CONDITION_CROSS_GAME_ID]);
               this.setUnlockConditionCrossAppId(_loc5_);
         }
      }
      
      public function set freeGift(param1:Boolean) : void
      {
         this.mFreeGift = param1;
      }
      
      public function get extraType() : String
      {
         return this.mExtraType;
      }
      
      public function setIsFeatured(param1:Boolean) : void
      {
         this.mIsFeatured = param1;
      }
      
      public function get baseWidth() : Number
      {
         return this.mBaseWidth;
      }
      
      public function set shopTab(param1:String) : void
      {
         this.mShopTab = param1;
      }
      
      public function hasSubtype() : Boolean
      {
         return this.mSubtype.length > 0;
      }
      
      public function getUnlockConditionCrossAppID() : int
      {
         return this.mUnlockCondition[UNLOCK_CONDITION_CROSS_GAME_ID];
      }
      
      private function isInShop() : Boolean
      {
         return this.mWhere == null || this.mWhere.indexOf(WHERE_SHOP) > -1;
      }
      
      public function getIsFeatured() : Boolean
      {
         return this.mIsFeatured;
      }
      
      public function setExpireTimeFromString(param1:String) : void
      {
         this.setExpireTime(TimerUtil.getDateInMs(param1));
         ItemDefinitionManager.getInstance().limEdRegisterItemDefinition(this);
      }
      
      public function getWonderType() : WonderTypeDefinition
      {
         var _loc1_:Definition = WonderTypeDefinitionManager.getInstance().getDefinitionBySku(this.mSubtype[0]);
         return _loc1_ as WonderTypeDefinition;
      }
      
      public function isResourceLoaded() : Boolean
      {
         return PriorityLoader.getInstance().isLoaded(this.getSkuToLoad());
      }
      
      public function loadDisplayOptionalParameters() : void
      {
         this.mOptMax = DCResourceManager.getInstance().getNumberSWFClass(sku,"opt");
      }
      
      public function needsToShowExpireTime() : Boolean
      {
         return this.mExpireTime > 0;
      }
      
      public function get target() : String
      {
         return this.mTarget;
      }
      
      public function setHasExpireTime(param1:Boolean) : void
      {
         this.mHasExpireTime = param1;
      }
      
      public function isHeadQuarters() : Boolean
      {
         return mSku == SKU_HEADQUARTERS;
      }
      
      public function isAffectedByType(param1:int = 1) : Boolean
      {
         return this.isAffectedByInfluence() && param1 == TYPE_DECORATIONS_ID;
      }
      
      public function isBuildableFromFormat(param1:int) : Boolean
      {
         return param1 == this.getBuildFormatId();
      }
      
      public function setWhere(param1:String) : void
      {
         this.mWhere = param1.split(",");
      }
      
      public function isAClub() : Boolean
      {
         return mType == TYPE_CLUBS_ID;
      }
      
      public function setReleaseTimeFromString(param1:String) : void
      {
         this.setReleaseTime(TimerUtil.getDateInMs(param1));
      }
      
      public function isUpgradeAllowed() : Boolean
      {
         return mType == TYPE_HOUSES_ID && !this.isHeadQuarters();
      }
      
      public function get freeGift() : Boolean
      {
         return this.mFreeGift;
      }
      
      public function isAffectedByInfluence() : Boolean
      {
         return mType == TYPE_HOUSES_ID && !this.isHeadQuarters();
      }
      
      public function setAmountOfHelp(param1:int) : void
      {
         this.mAmountOfHelp = param1;
      }
      
      override protected function calculateChecksum() : int
      {
         return EncryptionUtils.calculateChecksumFrom([this.mBaseCols,this.mBaseRows,this.mIncomeValue,this.mInfluenceRatio,this.mPopulation,this.mInfluenceValue,this.mIncomeTime,this.mConstructionCoins,this.mConstructionCash,this.mConstructionFBC,this.mConstructionFBCnoCash,this.mMoveCoins,this.mMoveCash,this.mExperience,this.mEventOnTime,this.mIncomeXP,this.mCompanyValue,this.mTenants,this.mIncomeLevelFactor]);
      }
      
      public function get decorations() : Array
      {
         return this.mDecorations;
      }
      
      public function isInfluenceIconVisible() : Boolean
      {
         return mType == TYPE_DECORATIONS_ID;
      }
      
      public function getIncomeLevelFactor() : Number
      {
         checkChecksum();
         return this.mIncomeLevelFactor * DollarsGame.getProfile().level;
      }
      
      public function set constructionCrewSku(param1:String) : void
      {
         this.mConstructionCrewSku = param1;
      }
      
      public function set isAnimated(param1:Boolean) : void
      {
         this.mIsAnimated = param1;
      }
      
      public function set showsInABTest(param1:String) : void
      {
         this.mShowsInABTest = param1;
      }
      
      public function getIncomeXP() : int
      {
         checkChecksum();
         return this.mIncomeXP;
      }
      
      public function setReleaseTime(param1:Number) : void
      {
         this.mReleaseTime = param1;
      }
      
      public function needsHQConnection() : Boolean
      {
         return !this.isHeadQuarters() && mType != TYPE_DECORATIONS_ID;
      }
      
      public function getInstantBuildTypeABTest() : String
      {
         return this.mInstantBuildType_ABTest;
      }
      
      public function get constructionCrewSku() : String
      {
         return this.mConstructionCrewSku;
      }
      
      public function getInstantBuildFBCABTest() : int
      {
         return this.mInstantBuildFBC_ABTest;
      }
      
      public function getMoveCoins() : int
      {
         checkChecksum();
         return this.mMoveCoins;
      }
      
      public function setInstantBuildTypeABTest(param1:String) : void
      {
         this.mInstantBuildType_ABTest = param1;
      }
   }
}

