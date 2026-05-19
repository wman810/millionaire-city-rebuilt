package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.metrics.CustomizerManager;
   import com.dchoc.dollars.utils.metrics.PaymentManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ItemPopupGold extends Sprite
   {
      
      private var mExtraOptionIndex:int;
      
      private var mDollars:TextField;
      
      private var mBox:MovieClip;
      
      private var mDollarsBox:Sprite;
      
      private var mFbObject:Object;
      
      private var mGold:TextField;
      
      private var mIsOfferPal:Boolean;
      
      private var mFree:Sprite;
      
      private var mDollarsOld:TextField;
      
      public function ItemPopupGold(param1:Object, param2:int = 0)
      {
         var _loc4_:TextField = null;
         var _loc5_:TextField = null;
         var _loc6_:TextField = null;
         var _loc7_:TextField = null;
         var _loc8_:Sprite = null;
         super();
         this.mIsOfferPal = param1 == null;
         this.mFbObject = param1;
         var _loc3_:String = this.mIsOfferPal ? "popup_gold_offers" : "popup_gold_value_box";
         this.mBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,_loc3_))();
         addChild(this.mBox);
         this.mBox.stop();
         this.mExtraOptionIndex = param2;
         this.unselect();
         buttonMode = true;
         mouseChildren = false;
         if(param1 != null)
         {
            this.mGold = this.mBox.getChildByName("TextInfo_01") as TextField;
            if(param1.freeGoldOld > 0)
            {
               this.mFree = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"freegold_old"))();
            }
            else
            {
               this.mFree = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"freegold"))();
            }
            this.mBox.addChild(this.mFree);
            if(param1.freeGold == 0)
            {
               this.mFree.visible = false;
            }
            else
            {
               _loc4_ = this.mFree.getChildByName("TextInfo_01_02") as TextField;
               TextManager.reformatTextField(_loc4_);
               _loc4_.text = "+" + param1.freeGold + " " + TextManager.getText(TextIDs.TID_GEN_FREE_SHORT);
               if(param1.freeGoldOld != "")
               {
                  _loc5_ = this.mFree.getChildByName("TextInfo_01_02_old") as TextField;
                  _loc5_.text = "+" + param1.freeGoldOld;
               }
               TextManager.setTextScaled(_loc4_);
            }
            this.mGold.text = param1.gold;
            if(CustomizerManager.getInstance().crmOfferState == CustomizerManager.CRM_OFFER_ENABLED && param1.creditsOld != param1.credits && param1.creditsOld != "")
            {
               if(Config.FACEBOOK_CREDITS_TO_BUY_GOLD)
               {
                  this.mDollarsBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value_offer_text_03_fc"))();
               }
               else
               {
                  this.mDollarsBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value_offer_text_03"))();
               }
               this.mDollarsOld = this.mDollarsBox.getChildByName("TextInfo_01_02_03_old") as TextField;
               this.mDollarsOld.embedFonts = true;
               this.mDollars = this.mDollarsBox.getChildByName("TextInfo_01_02_03_offer") as TextField;
               this.mDollarsOld.text = param1.creditsOld;
            }
            else
            {
               if(Config.FACEBOOK_CREDITS_TO_BUY_GOLD)
               {
                  this.mDollarsBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value_text_03_fc"))();
               }
               else
               {
                  this.mDollarsBox = new (DCResourceManager.getInstance().getSWFClass(Config.getRoot() + ModelConfig.HOUSES_INFO_SWF,"popup_gold_value_text_03"))();
               }
               this.mDollars = this.mDollarsBox.getChildByName("TextInfo_01_02_03") as TextField;
            }
            if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
            {
               _loc6_ = this.mDollarsBox.getChildByName("usd") as TextField;
               if(_loc6_ != null)
               {
                  _loc6_.text = "DSU";
               }
            }
            this.mDollars.text = param1.credits;
            if(TextManager.lang == "HI" && this.mDollars.text.indexOf(TextManager.getText(TextIDs.TID_DECIMAL_DELIMETER)) > -1)
            {
               TextManager.reformatTextField(this.mDollars,false);
            }
            this.mBox.addChild(this.mDollarsBox);
         }
         else
         {
            _loc7_ = this.mBox.getChildByName("TextInfo_01") as TextField;
            TextManager.reformatTextField(_loc7_);
            if(Config.USE_OFFERPAL_EXTRA_OPTIONS)
            {
               _loc7_.text = PaymentManager.getInstance().getOptionText(param2);
            }
            else
            {
               _loc7_.text = TextManager.getText(TextIDs.TID_POPUP_GOLD_OFFERPAL);
            }
            _loc8_ = this.mBox.getChildByName("boxreference") as Sprite;
            if(_loc8_ != null)
            {
               _loc8_.visible = false;
            }
         }
      }
      
      public function unselect() : void
      {
         this.mBox.gotoAndStop(2);
         this.changeLogo();
         var _loc1_:Date = new Date();
         var _loc2_:Date = new Date(2010,11,2);
         var _loc3_:Number = Math.floor(_loc2_.getTime() - _loc1_.getTime());
      }
      
      public function get fbObject() : Object
      {
         return this.mFbObject;
      }
      
      public function isOfferPal() : Boolean
      {
         return this.mIsOfferPal;
      }
      
      public function get extraOptionIndex() : int
      {
         return this.mExtraOptionIndex;
      }
      
      public function destroy() : void
      {
         if(this.mGold != null)
         {
            this.mBox.removeChild(this.mGold);
            this.mGold = null;
         }
         if(this.mFree != null)
         {
            this.mBox.removeChild(this.mFree);
            this.mFree = null;
         }
         if(this.mDollarsBox != null)
         {
            this.mBox.removeChild(this.mDollarsBox);
            this.mDollarsBox = null;
         }
         removeChild(this.mBox);
         this.mBox = null;
      }
      
      private function changeLogo() : void
      {
         var _loc1_:Bitmap = null;
         var _loc2_:Sprite = null;
         if(!Config.FACEBOOK_CREDITS_TO_BUY_GOLD && Config.USE_OFFERPAL_IN_POPUP_GOLD && Config.USE_OFFERPAL_EXTRA_OPTIONS)
         {
            _loc1_ = PaymentManager.getInstance().getOptionImage(this.mExtraOptionIndex);
            if(_loc1_ != null)
            {
               _loc2_ = this.mBox.getChildByName("boxreference") as Sprite;
               if(_loc2_ != null)
               {
                  this.mBox.addChild(_loc1_);
                  _loc1_.x = _loc2_.x - _loc1_.width / 2;
                  _loc1_.y = (this.mBox.height - 5 - _loc1_.height) / 2;
                  this.mBox.removeChild(_loc2_);
               }
            }
         }
      }
      
      public function select() : void
      {
         this.mBox.gotoAndStop(1);
         this.changeLogo();
      }
   }
}

