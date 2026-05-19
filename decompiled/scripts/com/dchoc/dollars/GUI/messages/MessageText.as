package com.dchoc.dollars.GUI.messages
{
   import com.dchoc.dollars.containers.MissionsBox;
   import com.dchoc.dollars.friends.FriendsBar;
   import com.dchoc.dollars.utils.GUI.messages.Message;
   import com.dchoc.dollars.utils.behaviors.Behavior;
   import com.dchoc.dollars.utils.behaviors.BehaviorAlpha;
   import com.dchoc.dollars.utils.behaviors.BehaviorComposite;
   import com.dchoc.dollars.utils.behaviors.BehaviorScale;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class MessageText extends Message
   {
      
      private var mTextSprite:Sprite;
      
      public function MessageText(param1:String)
      {
         var _loc3_:int = 0;
         super();
         this.mTextSprite = new (DCResourceManager.getInstance().getSWFClass(MissionsBox.SKU,"text_mission_complete"))();
         var _loc2_:TextField = this.mTextSprite.getChildByName("Caption") as TextField;
         TextManager.reformatTextField(_loc2_);
         _loc2_.text = param1;
         TextManager.setTextScaled(_loc2_);
         mDO.addChild(this.mTextSprite);
         mDO.width = this.mTextSprite.width;
         mDO.height = this.mTextSprite.height;
         _loc3_ = Dollars.smStage.stageHeight - FriendsBar.getHeight();
         this.mTextSprite.x = Dollars.smStage.stageWidth - this.mTextSprite.width >> 1;
         this.mTextSprite.y = _loc3_ >> 1;
         this.stageResize();
         mDO.mouseChildren = false;
         mDO.mouseEnabled = false;
      }
      
      override public function stageResize() : void
      {
         var _loc1_:int = Dollars.smStage.stageHeight - FriendsBar.getHeight();
         mDO.setDisplayArea(0,_loc1_,Dollars.smStage.stageWidth,10);
      }
      
      override protected function setBehavior() : void
      {
         var _loc1_:BehaviorComposite = new BehaviorComposite();
         var _loc2_:Behavior = new BehaviorScale(4,0.45,0,1600);
         _loc2_.setAcceleration(0.01);
         _loc1_.addBehavior(_loc2_);
         _loc2_ = new BehaviorAlpha(0,1,0,800);
         _loc2_.setAcceleration(0.005);
         _loc1_.addBehavior(_loc2_);
         _loc2_ = new BehaviorAlpha(1,0,1000,3000);
         _loc2_.setAcceleration(0.01);
         _loc1_.addBehavior(_loc2_);
         mBehavior = _loc1_;
         mBehavior.setDO(mDO);
      }
   }
}

