package com.dchoc.dollars.missions.iconLayer
{
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.utils.AssetManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Circular;
   import com.gskinner.motion.easing.Linear;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class MissionIcon
   {
      
      private static const ICON_SIZE:int = 64;
      
      private static const LABEL_OFFSET:int = 15;
      
      private static const TWEEN_REPEAT_TIME:Number = 0.5;
      
      public var mProgress:int;
      
      public var mLabel:Sprite;
      
      public var mContainer:Sprite;
      
      public var mTooltip:MovieClip;
      
      private var mLabelAlpha:Number;
      
      private var mArrow:MovieClip;
      
      public var mMission:MissionObject;
      
      private var mLabelTime:int;
      
      public var mIsAnimated:Boolean;
      
      private var mTween:GTween;
      
      public function MissionIcon()
      {
         super();
      }
      
      public function showLabel(param1:Boolean) : void
      {
         if(this.mLabel != null)
         {
            this.mLabel.visible = param1;
         }
      }
      
      public function setTooltip(param1:MovieClip) : void
      {
         this.mTooltip = param1;
         this.mContainer.addChildAt(this.mTooltip,1);
         this.mTooltip.visible = false;
      }
      
      private function endTween(param1:GTween) : void
      {
         this.mTooltip.visible = false;
      }
      
      public function showTooltip() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(this.mMission != null)
         {
            _loc1_ = this.mMission.missionDefinition.getTextTitle();
            _loc2_ = this.mMission.getProgressAsString();
         }
         else
         {
            _loc1_ = TextManager.getText(TextIDs.TID_HINT_MENU_BUTTON_MISSIONS);
            _loc2_ = "";
         }
         var _loc3_:MovieClip = this.mTooltip["base"];
         var _loc4_:TextField = this.mTooltip["caption"];
         var _loc5_:TextField = this.mTooltip["caption2"];
         _loc4_.text = _loc1_;
         _loc4_.autoSize = TextFieldAutoSize.LEFT;
         _loc4_.wordWrap = false;
         _loc4_.width = _loc4_.textWidth;
         _loc5_.text = _loc2_;
         _loc5_.autoSize = TextFieldAutoSize.LEFT;
         _loc5_.wordWrap = false;
         _loc5_.width = _loc5_.textWidth;
         _loc3_.width = _loc4_.width + 14;
         if(_loc2_ != "")
         {
            _loc5_.x = _loc4_.x + _loc4_.width + 5;
            _loc3_.width += _loc5_.width + 5;
         }
         this.mTooltip.x = MissionIcon.ICON_SIZE + 10;
         this.mTooltip.y = MissionIcon.ICON_SIZE / 2;
         this.mTooltip.visible = true;
         this.mTooltip.alpha = 0;
         new GTween(this.mTooltip,0.3,{"alpha":1},{"ease":Linear.easeNone});
      }
      
      public function removeLabel(param1:GTween = null) : void
      {
         this.mLabelTime = 0;
         if(this.mLabel != null)
         {
            new GTween(this.mLabel,0.2,{"alpha":0},{
               "ease":Linear.easeNone,
               "onComplete":this.finishRemoveLabel
            });
            this.mLabel = null;
         }
      }
      
      public function end() : void
      {
         if(this.mTween != null)
         {
            this.mTween.repeatCount = 1;
            this.mTween.end();
            this.mTween = null;
         }
      }
      
      public function hideTooltip() : void
      {
         new GTween(this.mTooltip,0.1,{"alpha":0},{
            "ease":Linear.easeNone,
            "onComplete":this.endTween
         });
      }
      
      public function blink() : void
      {
         this.mTween = new GTween(this.mContainer,0.3,{"alpha":0},{
            "ease":Linear.easeNone,
            "repeatCount":0,
            "reflect":true
         });
      }
      
      public function removeArrow() : void
      {
         if(this.mArrow != null)
         {
            if(this.mContainer.contains(this.mArrow))
            {
               this.mContainer.removeChild(this.mArrow);
            }
            this.mArrow = null;
         }
      }
      
      public function removeTooltip() : void
      {
         this.mContainer.removeChild(this.mTooltip);
         this.mTooltip = null;
      }
      
      public function addArrow() : void
      {
         if(this.mArrow == null)
         {
            this.mArrow = new AssetManager.TutorialArrow();
            this.mArrow.x = MissionIcon.ICON_SIZE / 2;
            this.mArrow.y = MissionIcon.ICON_SIZE / 2;
            this.mContainer.addChild(this.mArrow);
         }
      }
      
      public function setLabel(param1:Sprite, param2:int = 0, param3:int = 0) : void
      {
         var _loc7_:GTween = null;
         var _loc8_:GTween = null;
         if(this.mLabel != null)
         {
            this.removeLabel();
         }
         this.mLabelTime = param2;
         this.mLabel = param1;
         this.mContainer.addChildAt(this.mLabel,2);
         this.mLabel.alpha = 0;
         this.mLabel.x = (MissionIcon.ICON_SIZE + MissionIcon.LABEL_OFFSET) * 2;
         this.mLabel.y = MissionIcon.ICON_SIZE / 2;
         var _loc4_:GTween = new GTween(this.mLabel,0.3,{
            "x":MissionIcon.ICON_SIZE + MissionIcon.LABEL_OFFSET,
            "alpha":1
         },{"ease":Linear.easeNone});
         var _loc5_:int = this.mLabelTime / 1000 / MissionIcon.TWEEN_REPEAT_TIME;
         var _loc6_:GTween = new GTween(this.mLabel,MissionIcon.TWEEN_REPEAT_TIME,{"x":MissionIcon.ICON_SIZE - 5},{
            "autoPlay":false,
            "ease":Circular.easeIn,
            "repeatCount":_loc5_,
            "reflect":true
         });
         _loc4_.nextTween = _loc6_;
         if(param3 > 0)
         {
            _loc7_ = new GTween(this.mLabel,0.2,{"alpha":0},{
               "autoPlay":false,
               "ease":Linear.easeNone
            });
            _loc8_ = new GTween(this.mLabel,param3 / 1000,{},{
               "autoPlay":false,
               "ease":Linear.easeNone
            });
            _loc6_.nextTween = _loc7_;
            _loc7_.nextTween = _loc8_;
            _loc8_.nextTween = _loc4_;
         }
         else
         {
            _loc6_.onComplete = this.removeLabel;
         }
      }
      
      private function finishRemoveLabel(param1:GTween) : void
      {
         if(this.mContainer.contains(param1.target as Sprite))
         {
            this.mContainer.removeChild(param1.target as Sprite);
         }
      }
   }
}

