package com.dchoc.dollars.containers
{
   import com.dchoc.dollars.GUI.infoBox.InfoBox;
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.dollars.world.items.ItemDefinitionManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class FeaturedItemContent extends Sprite
   {
      
      public static const STATE_LOCKED:uint = 0;
      
      public static const STATE_DISABLED:uint = 1;
      
      public static const STATE_ENABLED:uint = 2;
      
      private var mInfo:InfoBox;
      
      private var mType:uint;
      
      private var mLoading:MovieClip;
      
      public var mDef:ItemDefinition;
      
      private var mIsMouseOver:Boolean;
      
      private var mState:uint;
      
      private var mBox:Sprite;
      
      public var mId:int;
      
      private var mTutorialArrow:MovieClip;
      
      private var mHouse:MovieClip;
      
      private var mImage:Sprite;
      
      private var mParent:DisplayObjectContainer;
      
      private var mFeatured:Sprite;
      
      public function FeaturedItemContent(param1:int, param2:ItemDefinition)
      {
         super();
         this.mId = param1;
         this.mDef = param2;
      }
      
      public function destroy() : void
      {
         this.mParent = null;
         this.mDef = null;
         if(this.mHouse != null)
         {
            this.mBox.removeChild(this.mHouse);
         }
         this.mBox = null;
      }
      
      public function setUpIcon() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Object = null;
         if(PriorityLoader.getInstance().isLoaded(this.mDef.getSkuToLoad()) && this.mHouse == null)
         {
            _loc1_ = this.mBox.getChildByName("container") as MovieClip;
            _loc2_ = this.mDef.getIcon(_loc1_,true,false);
            this.mHouse = _loc2_.icon as MovieClip;
            _loc1_.addChild(_loc2_.grid);
            _loc1_.addChild(this.mHouse);
            this.mHouse.mouseEnabled = false;
            this.mLoading.visible = false;
            this.mLoading.stop();
         }
         else if(!this.mDef.mResourcesRequested)
         {
            ItemDefinitionManager.getInstance().requestLoadResourcesByDefinition(this.mDef,PriorityLoader.QUEUE_ASYNC);
         }
      }
      
      public function setUpBox(param1:DisplayObjectContainer) : void
      {
         this.mBox = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"featured_box"))();
         this.mBox.x = 6.5;
         this.mBox.y = 54;
         this.mLoading = this.mBox.getChildByName("loading") as MovieClip;
         var _loc2_:TextField = this.mBox.getChildByName("Text_info") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = TextManager.getText(TextIDs[this.mDef.textID]);
         TextManager.setTextScaled(_loc2_);
         this.setUpIcon();
         addChild(this.mBox);
      }
      
      public function update(param1:int) : void
      {
      }
      
      public function get state() : uint
      {
         return this.mState;
      }
      
      public function setState(param1:uint) : void
      {
         this.mState = param1;
      }
   }
}

