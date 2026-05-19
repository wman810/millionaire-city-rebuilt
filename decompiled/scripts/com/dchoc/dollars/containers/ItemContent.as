package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.DynamicButton;
   import com.dchoc.dollars.model.userdata.UserDataFacade;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.utils.timer.TimerUtil;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class ItemContent extends Sprite
   {
      
      public static const BUY_ITEM:String = "BuyItem";
      
      public static const EVENT_UNLOCK_ITEM:String = "EventUnlockItem";
      
      protected static const TOOLTIP_DELAY:Number = 200;
      
      protected var mLoading:MovieClip;
      
      public var mDef:ItemDefinition;
      
      protected var mBox:Sprite;
      
      protected var mContainer:ItemContainer;
      
      protected var mState:int;
      
      protected var mIconContainer:Object;
      
      protected var mImage:Sprite;
      
      public var mId:int;
      
      protected var mButton:DynamicButton;
      
      public function ItemContent(param1:ItemContainer, param2:int, param3:ItemDefinition)
      {
         if(param3 != null)
         {
            super();
            this.mDef = param3;
            this.mId = param2;
            this.mContainer = param1;
            this.setupBox();
         }
         else
         {
            new Sprite();
         }
      }
      
      protected function setupBox() : void
      {
         var _loc5_:TextField = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:TextField = null;
         var _loc1_:int = 25;
         this.mBox = this.getBox();
         addChild(this.mBox);
         this.mLoading = this.mBox.getChildByName("loading") as MovieClip;
         this.mImage = this.mBox.getChildByName("image") as Sprite;
         this.mImage.mouseChildren = false;
         this.setupIcon();
         var _loc2_:TextField = this.mBox.getChildByName("mTitle") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[this.mDef.textID]);
         TextManager.setTextScaled(_loc2_);
         this.mDef.addIcons(this.mBox);
         var _loc3_:MovieClip = this.mBox.getChildByName("counter") as MovieClip;
         if(_loc3_ != null)
         {
            _loc3_.stop();
            if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
            {
               _loc3_.gotoAndStop(2);
            }
            if(this.mDef.getSaleMode() == ItemDefinition.SALE_MODE_LIM_ED)
            {
               _loc5_ = _loc3_.getChildByName("Items_left") as TextField;
               TextManager.reformatTextField(_loc5_);
               if(this.mDef.getUnitsAmount() > 0)
               {
                  _loc5_.text = TextManager.replaceParameters(TextIDs.TID_ITEMS_LEFT,new Array("" + this.mDef.getUnitsAmount()));
                  TextManager.setTextScaled(_loc5_);
               }
            }
            else
            {
               _loc3_.visible = false;
            }
         }
         var _loc4_:MovieClip = this.mBox.getChildByName("timeLeft") as MovieClip;
         if(_loc4_ != null)
         {
            _loc4_.stop();
            if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
            {
               _loc4_.gotoAndStop(2);
            }
            if(this.mDef.needsToShowExpireTime())
            {
               _loc6_ = this.mDef.getExpireTime() - UserDataFacade.getInstance().getServerTimeEmulated();
               if(_loc6_ > 0)
               {
                  _loc7_ = TimerUtil.msToDays(_loc6_);
                  _loc8_ = TimerUtil.msToHour(_loc6_);
                  _loc9_ = _loc4_.getChildByName("Time_left") as TextField;
                  if(TextManager.smAlign == TextManager.ALIGN_RIGHT)
                  {
                     _loc9_.x -= 33;
                  }
                  TextManager.reformatTextField(_loc9_);
                  if(_loc7_ == 0)
                  {
                     if(_loc6_ % TimerUtil.HOUR_TO_MS > 0)
                     {
                        _loc8_++;
                     }
                     _loc9_.text = _loc8_ + " " + TextManager.getText(TextIDs.TID_INVEST_HOURS_LEFT);
                  }
                  else
                  {
                     if(_loc6_ % TimerUtil.DAY_TO_MS > 0)
                     {
                        _loc7_++;
                     }
                     _loc9_.text = _loc7_ + " " + TextManager.getText(TextIDs.TID_INVEST_DAYS_LEFT);
                  }
                  TextManager.setTextScaled(_loc9_);
               }
            }
            else
            {
               _loc4_.visible = false;
            }
         }
      }
      
      public function get state() : uint
      {
         return this.mState;
      }
      
      public function hideButton() : void
      {
         if(this.mButton != null)
         {
            this.mButton.visible = false;
         }
      }
      
      protected function getBox() : Sprite
      {
         return null;
      }
      
      public function setupIcon() : void
      {
         if(this.mIconContainer == null && PriorityLoader.getInstance().isLoaded(this.mDef.getSkuToLoad()))
         {
            this.mIconContainer = this.mDef.getIcon(this.mImage,true);
            if(this.mIconContainer.hasOwnProperty("grid") && this.mIconContainer.grid != null)
            {
               this.mImage.addChild(this.mIconContainer.grid);
            }
            if(this.mIconContainer.hasOwnProperty("icon") && this.mIconContainer.icon != null)
            {
               this.mImage.addChild(this.mIconContainer.icon);
            }
            this.mLoading.visible = false;
            this.mLoading.stop();
         }
      }
      
      public function end() : void
      {
      }
      
      public function start() : void
      {
      }
      
      public function set state(param1:uint) : void
      {
         this.mState = param1;
      }
      
      public function destroy() : void
      {
      }
   }
}

