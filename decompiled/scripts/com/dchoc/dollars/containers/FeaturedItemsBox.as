package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.model.rules.RulesFacade;
   import com.dchoc.dollars.utils.math.DChocMath;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import flash.display.Sprite;
   
   public class FeaturedItemsBox extends Sprite
   {
      
      public static var scrollingEnabled:Boolean = true;
      
      private var mItemCreationTime:Number;
      
      private var mScrollOffset:int = 5;
      
      private var mPrevFeatured:DynamicItem;
      
      private var mMaxScrolls:int;
      
      private var mCurrentFeatured:DynamicItem;
      
      private var mMaxItemCreationTime:Number = RulesFacade.getInstance().shopNewItemTimer();
      
      private var mIndexCurrentFeatured:int;
      
      private const XINIT:Number = -190.3;
      
      private const YINIT:Number = -105;
      
      private const XOFFSET:Number = 135;
      
      private const YOFFSET:Number = 190.1;
      
      private var mNumScrolls:int;
      
      private var mDestinyPosition:int = 0;
      
      private var mFirstItem:Boolean = false;
      
      private var mListFeatured:Array;
      
      public function FeaturedItemsBox()
      {
         super();
         this.mListFeatured = ItemDefinitionManager.getInstance().getItemDefinitionsFeatured();
         this.mIndexCurrentFeatured = DChocMath.randomNumber(0,this.mListFeatured.length - 1);
         this.mFirstItem = true;
         this.startFeatured();
      }
      
      public function nextFeatured(param1:int, param2:int) : void
      {
         var _loc3_:DynamicItem = null;
         if(this.mIndexCurrentFeatured == this.mListFeatured.length)
         {
            this.mIndexCurrentFeatured = 0;
         }
         this.mItemCreationTime = this.mMaxItemCreationTime;
         this.mPrevFeatured = this.mCurrentFeatured;
         _loc3_ = new DynamicItem(param1,param2,this.XOFFSET,this.YOFFSET,this.mListFeatured[this.mIndexCurrentFeatured++] as ItemDefinition);
         this.addChild(_loc3_);
         this.mCurrentFeatured = _loc3_;
         if(this.mFirstItem)
         {
            this.mCurrentFeatured.changeState(DynamicItem.STATE_SHOWING);
         }
      }
      
      public function cleanBox() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            (this.getChildAt(_loc1_) as DynamicItem).unLoad();
            this.removeChildAt(_loc1_);
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         if(this.mListFeatured.length > 1)
         {
            this.mCurrentFeatured.logicUpdate(param1);
            if(this.mPrevFeatured != null)
            {
               this.mPrevFeatured.logicUpdate(param1);
            }
            if(this.mCurrentFeatured.isFinishing())
            {
               this.mFirstItem = false;
               this.nextFeatured(this.XOFFSET,0);
            }
            if(this.mPrevFeatured != null)
            {
               if(this.mPrevFeatured.isOutOfBounds())
               {
                  this.mPrevFeatured.unLoad();
                  this.removeChild(this.mPrevFeatured);
                  this.mPrevFeatured = null;
               }
            }
         }
      }
      
      public function load() : void
      {
         this.mListFeatured = ItemDefinitionManager.getInstance().getItemDefinitionsFeatured();
         this.mFirstItem = true;
         this.nextFeatured(0,0);
      }
      
      public function startFeatured() : void
      {
         var _loc1_:DynamicItem = null;
         this.mPrevFeatured = null;
         if(this.mListFeatured.length > 0)
         {
            this.mCurrentFeatured = new DynamicItem(0,0,this.XOFFSET,this.YOFFSET,this.mListFeatured[this.mIndexCurrentFeatured++] as ItemDefinition);
            this.addChild(this.mCurrentFeatured);
            this.mCurrentFeatured.changeState(DynamicItem.STATE_SHOWING);
         }
      }
      
      private function mDebugRectangle(param1:int, param2:int) : void
      {
         this.graphics.beginFill(16711680);
         this.graphics.drawRect(param1,param2,this.XOFFSET,this.YOFFSET);
         this.graphics.endFill();
      }
   }
}

