package com.dchoc.framework.purchase
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.debug.Debug;
   
   public class FBCreditsPurchase
   {
      
      private static var smInstance:FBCreditsPurchase;
      
      private static var smAllowed:Boolean;
      
      public static const RESPONSE_USER_CANCEL:String = "-3";
      
      public static const RESPONSE_UNKNOWN_ERROR:String = "-2";
      
      public static const RESPONSE_NEED_CREDITS:String = "-1";
      
      public static const RESPONSE_NO_RESPONSE:String = "0";
      
      public static const RESPONSE_OK:String = "1";
      
      public static const TYPE_BUY_ITEM:String = "item";
      
      public static const TYPE_BUY_ITEM_OFFER:String = "itof";
      
      public static const TYPE_INSTANT_BUILD:String = "inst";
      
      public static const TYPE_EARLY_UNLOCK:String = "earl";
      
      public static const TYPE_RENT_TOOL:String = "buytool";
      
      public static const TYPE_RENT_TOOL_OFFER:String = "buytoolof";
      
      public static const TYPE_SKIP_ACTION:String = "skip";
      
      public static const TYPE_BUY_COLLECTIBLE:String = "collectible";
      
      public static const TYPE_UNLOCK_EXPANSION:String = "expansion";
      
      public static const TYPE_EXCHANGE_FOR_COINS:String = "addcoins";
      
      public static const TYPE_BUY_CREW:String = "hire";
      
      public static const TYPE_BUY_BUNDLE:String = "bundle";
      
      public static const TYPE_BUY_GOLD:String = "gold";
      
      public static var SKIP_ACTION_PRICE:int = 1;
      
      private static const MAX_FRICTIONLESS_PURCHASE_PRICE:int = 100;
      
      private var mUserDataFacade:UserDataFacade;
      
      private var mObjectToBuy:FBCreditsPurchaseInterface;
      
      public function FBCreditsPurchase()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: FBCreditsPurchase Error: Instantiation failed: Use FBCreditsPurchase.getInstance() instead of new.");
         }
         this.mUserDataFacade = UserDataFacade.getInstance();
      }
      
      public static function getInstance() : FBCreditsPurchase
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new FBCreditsPurchase();
            smAllowed = false;
         }
         return smInstance;
      }
      
      public function waitingForPurchaseProcess() : Boolean
      {
         return this.mObjectToBuy != null;
      }
      
      public function endPurchaseProcess(param1:String, param2:Boolean = true) : void
      {
         if(this.mObjectToBuy != null)
         {
            if(param1 == FBCreditsPurchase.RESPONSE_NEED_CREDITS && param2)
            {
               this.startPurchaseProcess(this.mObjectToBuy,false);
            }
            else
            {
               Debug.trace("FBCCreditPurchase.endPurchaseProcess: result " + param1);
               this.mObjectToBuy.buyWithCreditsCallback(param1);
               this.mObjectToBuy = null;
               switch(param1)
               {
                  case FBCreditsPurchase.RESPONSE_UNKNOWN_ERROR:
                  case FBCreditsPurchase.RESPONSE_NO_RESPONSE:
                     DollarsGame.externalRequest(DollarsGame.REQ_PAYMENT_FAIL);
               }
            }
         }
         this.mUserDataFacade.requestTask(UserDataFacade.TASK_FACEBOOK_CREDITS_GET_BALANCE);
      }
      
      public function startPurchaseProcess(param1:FBCreditsPurchaseInterface, param2:Boolean = true) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         if(param1 != null)
         {
            Dollars.checkIsFullScreen();
            this.mObjectToBuy = param1;
            _loc3_ = param1.buyWithCredits();
            _loc3_.price -= DollarsGame.getProfile().facebookCreditsNotSpent;
            if(_loc3_.price <= 0)
            {
               this.endPurchaseProcess(FBCreditsPurchase.RESPONSE_OK);
            }
            else
            {
               _loc4_ = UserDataFacade.TASK_FACEBOOK_CREDITS;
               if(param2 && _loc3_.price < FBCreditsPurchase.MAX_FRICTIONLESS_PURCHASE_PRICE && DollarsGame.getProfile().facebookCredits >= _loc3_.price)
               {
                  _loc4_ = UserDataFacade.TASK_FACEBOOK_CREDITS_FRICTIONLESS;
               }
               this.mUserDataFacade.requestTask(_loc4_,_loc3_.orderInfo);
            }
         }
      }
   }
}

