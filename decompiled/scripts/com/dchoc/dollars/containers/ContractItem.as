package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.infoBox.InfoBoxContract;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.contracts.ContractDefinition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Linear;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.utils.setTimeout;
   
   public class ContractItem extends Sprite
   {
      
      public static const EVENT_CONTRACT:String = "EventContract";
      
      public static const LAYER_UNLOCKED_ID:int = 0;
      
      public static const LAYER_LOCKED_ID:int = 1;
      
      private static const LAYER_COUNT:int = 2;
      
      protected static const TWEEN_LENGHT:Number = 0.05;
      
      protected static const TWEEN_MIN_SCALE:Number = 1;
      
      protected static const TWEEN_MAX_SCALE:Number = 1.05;
      
      private static const TOOLTIP_DELAY:Number = 200;
      
      private var mItemType:int;
      
      private var mColorTransform:ColorTransform;
      
      private var mLevel:uint;
      
      private var mPopulation:Array;
      
      private var mBox:Sprite;
      
      private var mIncomeCoins:Array;
      
      private var mIsMouseDown:Boolean;
      
      private var mColorUp:ColorTransform;
      
      private var mInfo:InfoBoxContract;
      
      private var mCostCoins:Array;
      
      private var mIndex:int;
      
      public var mContractDef:ContractDefinition;
      
      private var mIsMouseOver:Boolean;
      
      private var mIncomeXP:Array;
      
      private var mParent:DisplayObjectContainer;
      
      private var mTween:GTween;
      
      public function ContractItem()
      {
         super();
         this.mCostCoins = new Array(LAYER_COUNT);
         this.mIncomeXP = new Array(LAYER_COUNT);
         this.mIncomeCoins = new Array(LAYER_COUNT);
         this.mPopulation = new Array(LAYER_COUNT);
         var _loc1_:int = 0;
         while(_loc1_ < LAYER_COUNT)
         {
            this.mCostCoins[_loc1_] = 0;
            this.mIncomeXP[_loc1_] = 0;
            this.mIncomeCoins[_loc1_] = 0;
            this.mPopulation[_loc1_] = 0;
            _loc1_++;
         }
         scaleX = ContractItem.TWEEN_MIN_SCALE;
         scaleY = ContractItem.TWEEN_MIN_SCALE;
      }
      
      public function showInfoBox(param1:int) : void
      {
         if(!this.mIsMouseOver)
         {
            this.mInfo = new InfoBoxContract(this.mParent,this,this.mIndex,this.mItemType);
            setTimeout(this.mInfo.show,ContractItem.TOOLTIP_DELAY,null,param1,this.y - this.height / 2,this.width);
            this.mIsMouseOver = true;
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this.mTween != null)
         {
            this.mTween.end();
         }
         this.mTween = new GTween(this,ContractItem.TWEEN_LENGHT,{
            "scaleX":ContractItem.TWEEN_MAX_SCALE,
            "scaleY":ContractItem.TWEEN_MAX_SCALE
         },{"ease":Linear.easeNone});
         if(this.mIsMouseDown)
         {
            this.onMouseDown(null);
         }
      }
      
      private function accumPopulation(param1:uint, param2:int = 0) : void
      {
         this.mPopulation[param2] += param1;
      }
      
      public function setContractDefinition(param1:ContractDefinition, param2:int, param3:int = 0, param4:int = 1) : void
      {
         this.mItemType = param3;
         if(this.mContractDef == null)
         {
            this.mContractDef = param1;
            this.mLevel = this.mContractDef.level;
         }
         else if(this.mLevel > param1.level)
         {
            this.mLevel = param1.level;
         }
         var _loc5_:int = param1.level <= DollarsGame.getProfile().level ? LAYER_UNLOCKED_ID : LAYER_LOCKED_ID;
         this.accumCostCoins(param1.getCostCoins() * param4,_loc5_);
         this.accumIncomeCoins(param1.getIncomeCoins() * param4,_loc5_);
         this.accumIncomeXP(param1.getIncomeXP() * param4,_loc5_);
         this.accumPopulation(param2 * param4,_loc5_);
      }
      
      public function addInfoShow(param1:DisplayObjectContainer) : void
      {
         this.mParent = param1;
      }
      
      private function onContract(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(EVENT_CONTRACT));
      }
      
      private function getLayerId() : int
      {
         return this.isUnlocked() ? LAYER_UNLOCKED_ID : LAYER_LOCKED_ID;
      }
      
      public function getIncomeCoins(param1:int = 0) : uint
      {
         return this.mIncomeCoins[param1];
      }
      
      public function closeInfoBox() : void
      {
         if(this.mIsMouseOver)
         {
            this.mInfo.close();
            this.mInfo.destroy();
            this.mInfo = null;
            this.mIsMouseOver = false;
         }
      }
      
      public function isUnlocked() : Boolean
      {
         return this.getLevel() <= DollarsGame.getProfile().level;
      }
      
      public function getContractName() : String
      {
         return TextManager.getText(this.mContractDef.tid);
      }
      
      private function accumIncomeCoins(param1:uint, param2:int = 0) : void
      {
         this.mIncomeCoins[param2] += param1;
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         this.mBox.transform.colorTransform = this.mColorTransform;
         this.mIsMouseDown = false;
      }
      
      public function getPopulation(param1:int = 0) : uint
      {
         return this.mPopulation[param1];
      }
      
      public function viewBuild(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:Sprite = null;
         var _loc5_:Sprite = null;
         this.mIndex = param1;
         if(this.mContractDef != null)
         {
            if(this.isUnlocked())
            {
               this.mBox = new (DCResourceManager.getInstance().getSWFClass(ContractBox.SKU,"popup_box_contract"))();
               buttonMode = true;
               mouseChildren = false;
               this.mBox.mouseEnabled = false;
               addEventListener(MouseEvent.CLICK,this.onContract);
               if(!Tutorial.smTutorialEnd)
               {
                  if(param1 > 0)
                  {
                     mouseEnabled = false;
                     filters = FiltersManager.getSaturationFilter(0);
                  }
               }
               addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
               addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
               addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
               Dollars.smStage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
               this.mColorTransform = this.mBox.transform.colorTransform;
               this.mColorUp = FiltersManager.setInk(this.mColorTransform,16777215,0.5);
            }
            else
            {
               this.mBox = new (DCResourceManager.getInstance().getSWFClass(ContractBox.SKU,"popup_box_contract_locked"))();
               TextManager.reformatTextField(TextField(this.mBox.getChildByName("LevelNeeded")));
               TextField(this.mBox.getChildByName("LevelNeeded")).text = TextManager.replaceParameters(TextIDs.TID_DEFINITION_LEVEL,new Array("" + this.mContractDef.level));
               TextManager.reformatTextField(TextField(Sprite(this.mBox.getChildByName("locked")).getChildByName("LockedText")));
               TextField(Sprite(this.mBox.getChildByName("locked")).getChildByName("LockedText")).text = TextManager.getText(TextIDs.TID_GEN_LOCKED);
            }
            if(this.mContractDef.getIconSku() != "contract_01")
            {
               _loc4_ = this.mBox.getChildByName("contract") as Sprite;
               _loc5_ = new (DCResourceManager.getInstance().getSWFClass(ContractBox.SKU,this.mContractDef.getIconSku()))();
               if(_loc5_ != null)
               {
                  _loc4_.addChild(_loc5_);
               }
            }
            _loc2_ = this.getLayerId();
            TextManager.reformatTextField(TextField(this.mBox.getChildByName("ContractPrize")));
            TextField(this.mBox.getChildByName("ContractPrize")).text = TextManager.getText(TextIDs.TID_COIN_SYMBOL) + TextManager.convertNumberToString(this.getCostCoins(_loc2_),TextManager.TRUNCATE_THOUSAND,6);
            addChild(this.mBox);
            _loc3_ = this.mBox.getChildByName("gold") as MovieClip;
            _loc3_.stop();
            TextManager.reformatTextField(TextField(this.mBox.getChildByName("Caption")));
            TextField(this.mBox.getChildByName("Caption")).text = TextManager.getText(this.mContractDef.tid);
            TextManager.setTextScaled(TextField(this.mBox.getChildByName("Caption")));
            TextManager.reformatTextField(TextField(this.mBox.getChildByName("Time_Number")));
            TextField(this.mBox.getChildByName("Time_Number")).text = TextManager.convertTimeToString(this.mContractDef.getIncomeTime(),true);
         }
      }
      
      public function getLevel() : uint
      {
         return this.mLevel;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this.mBox.transform.colorTransform = this.mColorUp;
         this.mIsMouseDown = true;
      }
      
      public function getIncomeXP(param1:int = 0) : uint
      {
         return this.mIncomeXP[param1];
      }
      
      private function accumIncomeXP(param1:uint, param2:int = 0) : void
      {
         this.mIncomeXP[param2] += param1;
      }
      
      private function accumCostCoins(param1:uint, param2:int = 0) : void
      {
         this.mCostCoins[param2] += param1;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.mTween != null)
         {
            this.mTween.end();
         }
         this.mTween = new GTween(this,ContractItem.TWEEN_LENGHT,{
            "scaleX":ContractItem.TWEEN_MIN_SCALE,
            "scaleY":ContractItem.TWEEN_MIN_SCALE
         },{"ease":Linear.easeNone});
         this.mBox.transform.colorTransform = this.mColorTransform;
      }
      
      public function destroy() : void
      {
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Dollars.smStage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this.mContractDef = null;
         this.mCostCoins = null;
         this.mIncomeXP = null;
         this.mIncomeCoins = null;
         this.mPopulation = null;
      }
      
      public function getCostCoins(param1:int = 0) : uint
      {
         return this.mCostCoins[param1];
      }
   }
}

