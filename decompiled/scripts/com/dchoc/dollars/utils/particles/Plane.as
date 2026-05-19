package com.dchoc.dollars.utils.particles
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.utils.animations.ItemSprite;
   import com.dchoc.dollars.utils.effects.Flag;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class Plane extends ItemSprite
   {
      
      public static const PLAIN_SKU:String = "Plain";
      
      public static const EVENT_OPEN_POPUPCOLLECTIBLEGROUP:String = "eventpopupcollectiblegroup";
      
      private const PLANE_SPEED:int = 5;
      
      private var mTailFlag:Flag;
      
      public var isAnimated:Boolean;
      
      private var mPlane:MovieClip;
      
      private var mParent:DisplayObjectContainer;
      
      private var mName:String;
      
      private var mTail:Sprite;
      
      public var isActive:Boolean;
      
      public function Plane(param1:String)
      {
         super();
         this.setPlane(param1);
      }
      
      public function start(param1:String) : void
      {
         var _loc2_:Map = null;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         _loc2_ = DollarsGame.getCurrentWorld().map;
         this.mParent = _loc2_;
         this.isActive = true;
         this.mTail = this.mPlane.getChildByName("Tail") as MovieClip;
         TextManager.reformatTextField(TextField(this.mTail.getChildByName("Caption")));
         TextField(this.mTail.getChildByName("Caption")).text = param1;
         this.addChild(this.mPlane);
         this.mParent.addChild(this);
         this.isActive = true;
         if(this.isAnimated)
         {
            _loc3_ = _loc2_.scaleX;
            x = 1528;
            y = 933;
            this.mPlane.gotoAndPlay(0);
         }
         else
         {
            this.mTailFlag = new Flag(this.mTail);
            this.mTailFlag.x = this.mTail.x - 20;
            this.mTailFlag.y = this.mTail.y;
            this.mTail.visible = false;
            this.mTailFlag.start(20,4,0.01,0.002);
            this.mPlane.addChild(this.mTailFlag);
            _loc4_ = _loc2_.tileWidth * _loc2_.scaleX;
            _loc5_ = -_loc2_.x / _loc4_;
            _loc6_ = _loc5_ * _loc2_.tileWidth;
            _loc7_ = Dollars.smStage.stageWidth;
            _loc5_ = _loc7_ / _loc4_;
            _loc8_ = _loc5_ * _loc2_.tileWidth;
            if(_loc2_.x > 0)
            {
               x = _loc2_.mapTileWidth * _loc2_.tileWidth;
            }
            else
            {
               x = _loc6_ + _loc8_;
            }
            y = _loc2_.getBottomY() / 2;
         }
      }
      
      public function removePlane() : void
      {
         if(this.isActive)
         {
            if(!this.isAnimated)
            {
               this.mPlane.removeChild(this.mTailFlag);
               this.mTailFlag.destroy();
            }
            this.removeChild(this.mPlane);
            if(this.mParent != null)
            {
               this.mParent.removeChild(this);
            }
            if(this.mTailFlag != null)
            {
               this.mTailFlag.destroy();
            }
            this.mTailFlag = null;
            this.mTail = null;
            this.mName = null;
            this.mParent = null;
            this.mPlane = null;
            this.isActive = false;
            dispatchEvent(new Event(EVENT_OPEN_POPUPCOLLECTIBLEGROUP));
         }
      }
      
      public function logicUpdate(param1:int) : void
      {
         var _loc2_:Map = null;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         if(this.isActive)
         {
            _loc2_ = DollarsGame.getCurrentWorld().map;
            _loc3_ = _loc2_.tileWidth * _loc2_.scaleX;
            _loc4_ = -_loc2_.x / _loc3_;
            if(this.isAnimated)
            {
               if(this.mPlane != null && this.mPlane.currentFrame >= this.mPlane.totalFrames)
               {
                  this.removePlane();
               }
            }
            else if(this.mPlane != null)
            {
               this.mTailFlag.updateWaveFlag(param1);
               _loc5_ = _loc4_ * _loc2_.tileWidth - this.mPlane.width;
               x -= this.PLANE_SPEED;
               if(x <= _loc5_)
               {
                  this.removePlane();
               }
            }
         }
      }
      
      public function resume() : void
      {
         if(this.mPlane != null && this.isActive && this.isAnimated)
         {
            Dollars.playChilds(this.mPlane);
         }
      }
      
      public function pause() : void
      {
         if(this.mPlane != null && this.isActive && this.isAnimated)
         {
            Dollars.stopChild(this.mPlane);
         }
      }
      
      public function setPlane(param1:String) : void
      {
         this.mName = param1;
         this.isAnimated = param1 == "plane_04";
         if(this.isAnimated)
         {
            this.mPlane = new (DCResourceManager.getInstance().getSWFClass("plane_show","plane"))();
         }
         else
         {
            this.mPlane = new (DCResourceManager.getInstance().getSWFClass(PLAIN_SKU,this.mName))();
         }
         if(DollarsGame.getCurrentRoleID() == DollarsGame.ROLE_OWNER)
         {
            DollarsGame.getProfile().planeSku = param1;
         }
         else
         {
            DollarsGame.getProfileUniverse().planeSku = param1;
         }
      }
   }
}

