package com.luaye.console.view
{
   import com.luaye.console.Console;
   import flash.events.Event;
   import flash.events.TextEvent;
   
   public class MemoryPanel extends GraphingPanel
   {
      
      public function MemoryPanel(param1:Console)
      {
         super(param1,80,40);
         name = Console.PANEL_MEMORY;
         updateEvery = 5;
         drawEvery = 5;
         minimumWidth = 32;
         add(this,"current",5267711,"Memory");
      }
      
      override protected function linkHandler(param1:TextEvent) : void
      {
         if(param1.text == "gc")
         {
            master.gc();
         }
         super.linkHandler(param1);
      }
      
      override public function updateKeyText() : void
      {
         var _loc1_:Number = getCurrentOf(0);
         if(_loc1_ > 0)
         {
            keyTxt.htmlText = "<r><s>" + _loc1_.toFixed(2) + "mb <menu><a href=\"event:gc\">G</a> <a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
         }
         else
         {
            keyTxt.htmlText = "<r><s><y>no mem input</y> <menu><a href=\"event:close\">X</a></menu></s></r>";
         }
      }
      
      override public function close() : void
      {
         super.close();
         master.panels.updateMenu();
      }
      
      public function get current() : Number
      {
         return Math.round(master.currentMemory / 10485.76) / 100;
      }
      
      override protected function onFrame(param1:Event) : Boolean
      {
         if(super.onFrame(param1))
         {
            this.updateKeyText();
            return true;
         }
         return false;
      }
      
      override protected function onMenuRollOver(param1:TextEvent) : void
      {
         var _loc2_:String = param1.text ? param1.text.replace("event:","") : null;
         if(_loc2_ == "gc")
         {
            _loc2_ = "Garbage collect::Requires debugger version of flash player";
         }
         master.panels.tooltip(_loc2_,this);
      }
   }
}

