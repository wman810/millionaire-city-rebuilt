package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.map.TileData;
   import com.dchoc.dollars.model.Tutorial;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.utils.particles.ParticleAnimation;
   import com.dchoc.dollars.utils.particles.ParticlesManager;
   import com.dchoc.dollars.world.items.ItemObject;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class ToolSetTile extends Tool
   {
      
      private var mGrill:Sprite;
      
      private var mGrillBad:Sprite;
      
      public function ToolSetTile(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
         this.load();
      }
      
      override protected function doReportMouseUp(param1:MouseEvent, param2:ItemObject) : void
      {
         var _loc4_:TileData = null;
         var _loc5_:MovieClip = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc3_:int = mMap.getWorldToTileIndex(mMap.mouseX,mMap.mouseY,0);
         if(_loc3_ != -1)
         {
            _loc4_ = mMap.tilesData[_loc3_] as TileData;
            if(this.isSetTileAllowed(_loc3_))
            {
               if(!Tutorial.smTutorialEnd && Tutorial.smTutorialStep == 4)
               {
                  if(Tutorial.smAddRoadTiles.indexOf(_loc3_) == -1)
                  {
                     return;
                  }
               }
               _loc5_ = this.getParticleAfterSettingTile();
               if(_loc5_ != null)
               {
                  _loc6_ = mMap.getTileXToWorld(mMap.getTileIndexToTileX(_loc3_)) + mMap.tileWidth / 2;
                  _loc7_ = mMap.getTileYToWorld(mMap.getTileIndexToTileY(_loc3_)) + mMap.tileHeight / 2;
                  ParticlesManager.addParticle(new ParticleAnimation(_loc6_,_loc7_,_loc5_),false);
               }
               this.setTile(_loc3_);
               reportMouseMove(null);
            }
         }
      }
      
      override protected function cursorEnd() : void
      {
         super.cursorEnd();
         this.mGrill.visible = false;
         this.mGrillBad.visible = false;
      }
      
      override public function load() : void
      {
         super.load();
         this.mGrill = new AssetManager.Grill();
         this.mGrillBad = new AssetManager.GrillBad();
         this.mGrill.visible = false;
         this.mGrillBad.visible = false;
      }
      
      protected function isSetTileAllowed(param1:int) : Boolean
      {
         return false;
      }
      
      override protected function doCursorIsApplicable(param1:TileData) : Boolean
      {
         return param1.baseItem == null;
      }
      
      protected function setTile(param1:int) : void
      {
      }
      
      override public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return false;
      }
      
      override protected function cursorIsEnabled() : Boolean
      {
         return true;
      }
      
      override protected function doReportMouseOver(param1:MouseEvent, param2:ItemObject) : void
      {
      }
      
      override protected function cursorDraw(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:TileData = null;
         var _loc6_:Boolean = false;
         if(mRole.cursor != null && mMap != null)
         {
            if(!mMap.contains(this.mGrill))
            {
               mMap.addChild(this.mGrill);
               mMap.addChild(this.mGrillBad);
            }
            _loc2_ = mMap.getWorldToTileIndex(mMap.mouseX,mMap.mouseY,0);
            if(_loc2_ != -1)
            {
               _loc3_ = mMap.getTileXToWorld(mMap.getTileIndexToTileX(_loc2_)) + mMap.tileWidth / 2;
               _loc4_ = mMap.getTileYToWorld(mMap.getTileIndexToTileY(_loc2_)) + mMap.tileHeight / 2;
               _loc5_ = mMap.tilesData[_loc2_] as TileData;
               _loc6_ = mMap.isTileInAreaMine(_loc2_);
               if(this.isSetTileAllowed(_loc2_))
               {
                  if(!this.mGrill.visible)
                  {
                     this.mGrill.visible = true;
                  }
                  this.mGrillBad.visible = false;
                  this.mGrill.x = _loc3_;
                  this.mGrill.y = _loc4_;
                  super.cursorDraw(true);
               }
               else if(cursorIsVisible(_loc2_))
               {
                  this.mGrillBad.visible = false;
                  this.mGrill.visible = false;
               }
               else
               {
                  this.mGrill.visible = false;
                  if(!this.mGrillBad.visible)
                  {
                     this.mGrillBad.visible = true;
                  }
                  this.mGrillBad.x = _loc3_;
                  this.mGrillBad.y = _loc4_;
                  super.cursorDraw(false);
               }
            }
         }
      }
      
      protected function getParticleAfterSettingTile() : MovieClip
      {
         return null;
      }
   }
}

