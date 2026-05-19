package com.dchoc.dollars.missions.iconLayer
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.missions.MissionObject;
   import com.dchoc.dollars.missions.MissionObjectManager;
   import com.dchoc.dollars.model.ModelConfig;
   import com.dchoc.dollars.utils.Cursor;
   import com.dchoc.dollars.utils.loader.PriorityLoader;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class MissionsIconLayerDisplay
   {
      
      private static var smAllowed:Boolean;
      
      private static var smInstance:MissionsIconLayerDisplay;
      
      private static const ANIMATION_LENGTH:Number = 0.8;
      
      private static const LABEL_NEW:String = "new";
      
      private static const LABEL_PROGRESS:String = "progress";
      
      private static const LABEL_CLICK_ME:String = "clickme";
      
      private static const LABEL_COMPLETED:String = "completed";
      
      private static const ICON_SIZE:int = 64;
      
      private var mFactoryIconData:Array;
      
      private var mLoader:PriorityLoader;
      
      private var mLayer:MovieClip;
      
      private var mFactoryIconContainers:Array;
      
      private var mList:Array;
      
      private var mShowClickme:Boolean;
      
      public function MissionsIconLayerDisplay()
      {
         super();
         if(!smAllowed)
         {
            throw new Error("ERROR: MissionsIconLayerDisplay Error: Instantiation failed: Use MissionsIconLayerDisplay.getInstance() instead of new.");
         }
         this.mList = new Array();
         this.mShowClickme = false;
         this.factoryInit();
      }
      
      public static function getInstance() : MissionsIconLayerDisplay
      {
         if(!smInstance)
         {
            smAllowed = true;
            smInstance = new MissionsIconLayerDisplay();
            smAllowed = false;
         }
         return smInstance;
      }
      
      private function factoryInit() : void
      {
         this.mFactoryIconData = new Array();
         this.mFactoryIconContainers = new Array();
         this.mLoader = PriorityLoader.getInstance();
      }
      
      private function factoryUpdate() : void
      {
         var _loc1_:String = null;
         var _loc2_:BitmapData = null;
         var _loc3_:Object = null;
         var _loc4_:Bitmap = null;
         for(_loc1_ in this.mFactoryIconContainers)
         {
            _loc2_ = this.factoryGetIconData(_loc1_);
            for each(_loc3_ in this.mFactoryIconContainers[_loc1_])
            {
               if(Boolean(_loc3_ != null) && Boolean(_loc3_.loading) && _loc2_ != null)
               {
                  _loc4_ = new Bitmap(_loc2_);
                  _loc4_.smoothing = true;
                  _loc3_.container.removeChildAt(0);
                  _loc3_.container.addChildAt(_loc4_,0);
                  _loc3_.loading = false;
               }
            }
         }
      }
      
      private function findIconByMission(param1:MissionObject) : MissionIcon
      {
         var _loc3_:MissionIcon = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.mList.length)
         {
            _loc3_ = this.mList[_loc2_];
            if(_loc3_.mMission == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function finishAnim(param1:GTween) : void
      {
         var _loc2_:MissionIcon = this.findIconByContainer(param1.target as DisplayObjectContainer);
         if(_loc2_ != null)
         {
            _loc2_.mIsAnimated = false;
            if(_loc2_.mMission != null && _loc2_.mMission.missionDefinition.showArrow())
            {
               _loc2_.addArrow();
            }
         }
      }
      
      private function factoryGetIcon(param1:String) : DisplayObjectContainer
      {
         var _loc6_:Bitmap = null;
         var _loc7_:MovieClip = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc2_:int = 0;
         if(this.mFactoryIconContainers[param1] == null)
         {
            this.mFactoryIconContainers[param1] = new Array();
         }
         _loc2_ = int(this.mFactoryIconContainers[param1].length);
         var _loc3_:Boolean = true;
         var _loc4_:BitmapData = this.factoryGetIconData(param1);
         var _loc5_:Sprite = new Sprite();
         if(_loc4_ != null)
         {
            _loc6_ = new Bitmap(_loc4_);
            _loc6_.smoothing = true;
            _loc5_.addChild(_loc6_);
            _loc3_ = false;
         }
         else
         {
            _loc7_ = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"lightgrey_loading_alone"))();
            _loc8_ = MissionsIconLayerDisplay.ICON_SIZE / _loc7_.width;
            _loc9_ = MissionsIconLayerDisplay.ICON_SIZE / _loc7_.height;
            _loc10_ = _loc8_ > _loc9_ ? _loc8_ : _loc9_;
            if(_loc10_ > 1)
            {
               _loc10_ = 1;
            }
            _loc7_.scaleX = _loc10_;
            _loc7_.scaleY = _loc10_;
            _loc5_.addChild(_loc7_);
         }
         this.mFactoryIconContainers[param1][_loc2_] = {
            "container":_loc5_,
            "loading":_loc3_
         };
         return this.mFactoryIconContainers[param1][_loc2_].container;
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:MissionIcon = null;
         var _loc3_:int = 0;
         this.factoryUpdate();
         for each(_loc2_ in this.mList)
         {
            if(_loc2_.mContainer != null && !_loc2_.mIsAnimated)
            {
               if(_loc2_.mMission != null)
               {
                  if(_loc2_.mMission.isNew() && _loc2_.mProgress == 0)
                  {
                     _loc2_.mMission.removeFlagNew();
                     _loc2_.setLabel(this.getLabel(MissionsIconLayerDisplay.LABEL_NEW,TextManager.getText(TextIDs.TID_GEN_NEW)),6000,5000);
                  }
                  else if(_loc2_.mProgress != _loc2_.mMission.getProgressAsPercentage())
                  {
                     _loc3_ = _loc2_.mMission.getProgressAsPercentage();
                     if(_loc2_.mProgress == 0 && _loc3_ > 0 || _loc2_.mProgress <= 50 && _loc3_ >= 50 || _loc2_.mProgress <= 85 && _loc3_ >= 85 || _loc2_.mProgress <= 95 && _loc3_ >= 95)
                     {
                        _loc2_.setLabel(this.getLabel(MissionsIconLayerDisplay.LABEL_PROGRESS,TextManager.getText(TextIDs.TID_GEN_PROGRESS)),7000);
                     }
                     _loc2_.mProgress = _loc2_.mMission.getProgressAsPercentage();
                  }
               }
               else if(this.mShowClickme)
               {
                  this.mShowClickme = false;
                  if(_loc2_.mLabel == null)
                  {
                     _loc2_.setLabel(this.getLabel(MissionsIconLayerDisplay.LABEL_CLICK_ME,TextManager.getText(TextIDs.TID_GEN_CLICKME)),4000);
                  }
               }
            }
         }
      }
      
      private function onMouseIn(param1:MouseEvent) : void
      {
         Dollars.getCurrentCursor().changeCursor(Cursor.CURSOR_HAND);
         var _loc2_:MissionIcon = this.findIconByContainer(param1.target as DisplayObjectContainer);
         if(_loc2_ != null && _loc2_.mContainer != null)
         {
            _loc2_.showTooltip();
            _loc2_.showLabel(false);
            new GTween(_loc2_.mContainer.getChildAt(0),0.1,{
               "scaleX":1.05,
               "scaleY":1.05,
               "tint":540226355
            },{"ease":Linear.easeNone});
         }
      }
      
      private function getTooltip() : MovieClip
      {
         return new (DCResourceManager.getInstance().getSWFClass("missions_layout","tooltip"))();
      }
      
      private function factoryFreeIcon(param1:String, param2:DisplayObjectContainer) : void
      {
         var _loc3_:int = 0;
         if(this.mFactoryIconContainers[param1] != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.mFactoryIconContainers[param1].length)
            {
               if(this.mFactoryIconContainers[param1][_loc3_] != null)
               {
                  if(this.mFactoryIconContainers[param1][_loc3_].container == param2)
                  {
                     this.mFactoryIconContainers[param1][_loc3_] = null;
                     break;
                  }
               }
               _loc3_++;
            }
         }
      }
      
      private function factoryDestroy() : void
      {
         var _loc2_:Object = null;
         var _loc1_:String = null;
         for(_loc1_ in this.mFactoryIconData)
         {
            this.mFactoryIconData[_loc1_] = null;
         }
         this.mFactoryIconData.length = 0;
         this.mFactoryIconData = null;
         for(_loc1_ in this.mFactoryIconContainers)
         {
            for each(_loc2_ in this.mFactoryIconContainers[_loc1_])
            {
               if(_loc2_ != null)
               {
                  _loc2_.container.removeChildAt(0);
               }
            }
            this.mFactoryIconContainers[_loc1_].length = null;
            this.mFactoryIconContainers[_loc1_] = null;
         }
         this.mFactoryIconContainers.length = 0;
         this.mFactoryIconContainers = null;
      }
      
      public function removeIcon(param1:MissionObject) : void
      {
         var _loc2_:MissionIcon = this.findIconByMission(param1);
         if(_loc2_ != null)
         {
            _loc2_.mIsAnimated = true;
            _loc2_.removeLabel();
            new GTween(_loc2_.mContainer,MissionsIconLayerDisplay.ANIMATION_LENGTH,{
               "scaleX":0,
               "scaleY":0
            },{
               "ease":Linear.easeNone,
               "onComplete":this.finishRemoveAnim
            });
         }
      }
      
      private function factoryGetIconData(param1:String) : BitmapData
      {
         if(this.mFactoryIconData[param1] == null)
         {
            if(this.mLoader.isLoaded(param1))
            {
               this.mFactoryIconData[param1] = DCResourceManager.getInstance().get(param1);
            }
            else
            {
               this.mLoader.queueLoad(PriorityLoader.QUEUE_ASYNC,Config.getRoot() + ModelConfig.DIR_MISSIONS_ICONS + param1 + ".png",param1,".png");
            }
         }
         return this.mFactoryIconData[param1];
      }
      
      private function onMouseClick(param1:Event) : void
      {
         var _loc3_:MissionIcon = null;
         var _loc2_:MissionIcon = this.findIconByContainer(param1.target as DisplayObjectContainer);
         if(_loc2_ != null)
         {
            if(_loc2_.mMission == null)
            {
               for each(_loc3_ in this.mList)
               {
                  if(_loc3_ != null)
                  {
                     _loc3_.removeLabel();
                  }
               }
               DollarsGame.getCurrentRole().toolsBar.setToolMissions(null);
            }
            else
            {
               _loc2_.removeArrow();
               if(DollarsGame.getProfile().firstMission && _loc2_.mMission.missionDefinition.eventType == "nameCity")
               {
                  DollarsGame.getProfile().firstMission = false;
                  DollarsGame.getProfile().firstMissionDone();
               }
               _loc2_.removeLabel();
               MissionObjectManager.getInstance().openDescription(_loc2_.mMission);
            }
         }
      }
      
      public function moveIcon(param1:MissionObject, param2:int) : void
      {
         var _loc3_:MissionIcon = this.findIconByMission(param1);
         if(_loc3_ != null)
         {
            _loc3_.mIsAnimated = true;
            new GTween(_loc3_.mContainer,MissionsIconLayerDisplay.ANIMATION_LENGTH,{"y":70 + param2 * 64},{
               "ease":Linear.easeNone,
               "onComplete":this.finishAnim
            });
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         Dollars.getCurrentCursor().changeCursor(Dollars.getCurrentCursor().mCurrentCursorID);
         var _loc2_:MissionIcon = this.findIconByContainer(param1.target as DisplayObjectContainer);
         if(_loc2_ != null && _loc2_.mContainer != null)
         {
            _loc2_.hideTooltip();
            _loc2_.showLabel(true);
            new GTween(_loc2_.mContainer.getChildAt(0),0.1,{
               "scaleX":1,
               "scaleY":1,
               "tint":0
            },{"ease":Linear.easeNone});
         }
      }
      
      public function showClickMeLabel() : void
      {
         this.mShowClickme = true;
      }
      
      private function finishRemoveAnim(param1:GTween) : void
      {
         var _loc2_:MissionIcon = this.findIconByContainer(param1.target as DisplayObjectContainer);
         if(_loc2_ != null)
         {
            _loc2_.mMission.icon = null;
            _loc2_.mContainer.removeEventListener(MouseEvent.CLICK,this.onMouseClick);
            _loc2_.mContainer.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseIn);
            _loc2_.mContainer.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            DollarsGame.getCurrentRole().hud.removeChild(_loc2_.mContainer);
            this.factoryFreeIcon(_loc2_.mMission.missionDefinition.eventType,_loc2_.mContainer);
            _loc2_.removeTooltip();
            _loc2_.mContainer = null;
            _loc2_.mMission = null;
            _loc2_.end();
         }
      }
      
      private function findIconByContainer(param1:DisplayObjectContainer) : MissionIcon
      {
         var _loc3_:MissionIcon = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.mList.length)
         {
            _loc3_ = this.mList[_loc2_];
            if(_loc3_.mContainer == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function addIcon(param1:MissionObject, param2:int) : void
      {
         var _loc3_:MissionIcon = null;
         var _loc4_:MissionIcon = null;
         var _loc5_:String = null;
         _loc3_ = null;
         for each(_loc4_ in this.mList)
         {
            if(_loc4_.mContainer == null)
            {
               _loc3_ = _loc4_;
            }
         }
         if(_loc3_ == null)
         {
            _loc3_ = new MissionIcon();
            this.mList.push(_loc3_);
         }
         if(param1 == null)
         {
            _loc5_ = DollarsGame.getProfile().bossName.toLowerCase();
         }
         else
         {
            param1.icon = _loc3_;
            _loc5_ = param1.missionDefinition.eventType;
         }
         _loc3_.mContainer = this.factoryGetIcon(_loc5_) as Sprite;
         _loc3_.mContainer.buttonMode = true;
         _loc3_.mContainer.useHandCursor = true;
         _loc3_.mContainer.alpha = 0;
         _loc3_.mContainer.x = 100;
         _loc3_.mContainer.y = 70 + param2 * 64;
         _loc3_.mContainer.addEventListener(MouseEvent.CLICK,this.onMouseClick);
         _loc3_.mContainer.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseIn);
         _loc3_.mContainer.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         _loc3_.mMission = param1;
         if(param1 != null)
         {
            _loc3_.mProgress = _loc3_.mMission.getProgressAsPercentage();
         }
         _loc3_.setTooltip(this.getTooltip());
         DollarsGame.getCurrentRole().hud.addChild(_loc3_.mContainer);
         new GTween(_loc3_.mContainer,MissionsIconLayerDisplay.ANIMATION_LENGTH,{
            "x":5,
            "alpha":1
         },{
            "ease":Linear.easeNone,
            "onComplete":this.finishAnim
         });
      }
      
      private function getLabel(param1:String, param2:String) : MovieClip
      {
         var _loc3_:MovieClip = new (DCResourceManager.getInstance().getSWFClass("missions_layout",param1))();
         var _loc4_:MovieClip = _loc3_["base"];
         var _loc5_:TextField = _loc3_["caption"];
         var _loc6_:int = 0;
         switch(param1)
         {
            case MissionsIconLayerDisplay.LABEL_CLICK_ME:
               _loc6_ = TextIDs.TID_GEN_CLICKME;
               break;
            case MissionsIconLayerDisplay.LABEL_NEW:
               _loc6_ = TextIDs.TID_GEN_NEW;
               break;
            case MissionsIconLayerDisplay.LABEL_PROGRESS:
               _loc6_ = TextIDs.TID_GEN_PROGRESS;
         }
         _loc5_.text = TextManager.getText(_loc6_);
         _loc5_.autoSize = TextFieldAutoSize.LEFT;
         _loc5_.wordWrap = false;
         _loc5_.width = _loc5_.textWidth;
         _loc4_.width = _loc5_.width + 30;
         return _loc3_;
      }
   }
}

