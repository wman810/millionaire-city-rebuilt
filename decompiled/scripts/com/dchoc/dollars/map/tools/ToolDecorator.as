package com.dchoc.dollars.map.tools
{
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.model.roles.Role;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.MouseEvent;
   
   public class ToolDecorator extends Tool
   {
      
      public var mTool:Tool;
      
      public function ToolDecorator(param1:Role, param2:Tool = null)
      {
         super(param1,param2);
      }
      
      public function setTool(param1:Tool) : void
      {
         this.mTool = param1;
      }
      
      override public function start(param1:Boolean = false, param2:String = null) : void
      {
         super.start(param1);
         this.mTool.start(false,param2);
      }
      
      override public function enable(param1:Boolean = false) : void
      {
         super.enable(param1);
         if(this.mTool != null)
         {
            this.mTool.enable(param1);
         }
      }
      
      override public function setItemMouseOver(param1:ItemObject) : void
      {
         super.setItemMouseOver(param1);
         if(this.mTool != null)
         {
            this.mTool.setItemMouseOver(param1);
         }
      }
      
      override public function serviceEnd() : void
      {
         if(this.mTool != null)
         {
            this.mTool.serviceEnd();
         }
      }
      
      override public function logicUpdate(param1:int) : void
      {
         super.logicUpdate(param1);
         if(this.mTool != null)
         {
            this.mTool.logicUpdate(param1);
         }
      }
      
      override public function disable(param1:Boolean = false) : void
      {
         if(this.mTool != null)
         {
            this.mTool.disable(param1);
         }
         super.disable(param1);
      }
      
      public function getTool() : Tool
      {
         return this.mTool;
      }
      
      override public function unattachItem(param1:ItemObject) : void
      {
         super.unattachItem(param1);
         this.mTool.unattachItem(param1);
      }
      
      override public function isMouseOverEnabled(param1:ItemObject) : Boolean
      {
         return this.mTool != null && this.mTool.isMouseOverEnabled(param1);
      }
      
      override public function areaSetSize(param1:int, param2:int) : void
      {
         if(this.mTool != null && this.mTool.areaIsEnabled())
         {
            this.mTool.areaSetSize(param1,param2);
         }
      }
      
      override public function getId() : int
      {
         if(this.mTool != null)
         {
            return this.mTool.getId();
         }
         return mId;
      }
      
      override public function isMapCursorEnabled() : Boolean
      {
         return this.mTool != null && this.mTool.isMapCursorEnabled();
      }
      
      override public function setMap(param1:Map) : void
      {
         mMap = param1;
         this.mTool.setMap(param1);
      }
      
      override public function end() : void
      {
         super.end();
         this.mTool.end();
      }
      
      override public function getDefaultCursorID() : int
      {
         var _loc1_:int = super.getDefaultCursorID();
         if(this.mTool != null)
         {
            _loc1_ = this.mTool.getDefaultCursorID();
         }
         return _loc1_;
      }
      
      override public function reportMouseOut(param1:MouseEvent) : void
      {
         super.reportMouseOut(param1);
         if(this.mTool != null)
         {
            this.mTool.reportMouseOut(param1);
         }
      }
   }
}

