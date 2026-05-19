package com.luaye.console.view
{
   import com.luaye.console.Console;
   import flash.events.Event;
   
   public class FPSPanel extends GraphingPanel
   {
      
      private var _cachedCurrent:Number;
      
      public function FPSPanel(param1:Console)
      {
         super(param1,80,40);
         name = Console.PANEL_FPS;
         lowest = 0;
         minimumWidth = 32;
         add(this,"current",16724787,"FPS");
      }
      
      override public function stop() : void
      {
         super.stop();
         reset();
      }
      
      public function addCurrent(param1:Number) : void
      {
         this._cachedCurrent = param1;
         updateData();
      }
      
      public function get current() : Number
      {
         if(isNaN(this._cachedCurrent))
         {
            return master.fps;
         }
         var _loc1_:Number = this._cachedCurrent;
         this._cachedCurrent = NaN;
         return _loc1_;
      }
      
      override public function updateKeyText() : void
      {
         if(_history.length > 0)
         {
            keyTxt.htmlText = "<r><s>" + master.fps.toFixed(1) + " | " + getAverageOf(0).toFixed(1) + " <menu><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
         }
         else
         {
            keyTxt.htmlText = "<r><s><y>no fps input</y> <menu><a href=\"event:close\">X</a></menu></s></r>";
         }
      }
      
      override protected function onFrame(param1:Event) : Boolean
      {
         var _loc3_:* = 0;
         if(master.remote)
         {
            return false;
         }
         var _loc2_:Number = master.mspf;
         if(!isNaN(_loc2_))
         {
            if(super.onFrame(param1))
            {
               this.updateKeyText();
               if(stage)
               {
                  fixed = true;
                  averaging = stage.frameRate;
                  highest = averaging;
                  _loc3_ = int(Math.floor(_loc2_ / (1000 / highest)));
                  if(_loc3_ > Console.FPS_MAX_LAG_FRAMES)
                  {
                     _loc3_ = int(Console.FPS_MAX_LAG_FRAMES);
                  }
                  while(_loc3_ > 1)
                  {
                     updateData();
                     _loc3_--;
                  }
               }
               return true;
            }
         }
         return false;
      }
      
      override public function close() : void
      {
         super.close();
         master.panels.updateMenu();
      }
   }
}

