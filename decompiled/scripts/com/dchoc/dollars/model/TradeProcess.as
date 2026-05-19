package com.dchoc.dollars.model
{
   import com.dchoc.dollars.GUI.Popup;
   import com.dchoc.dollars.GUI.PopupTradeBox;
   import com.dchoc.dollars.world.items.ItemObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class TradeProcess extends EventDispatcher
   {
      
      public static const EVENT_TRADE:String = "EventTrade";
      
      private var mTradeBox:PopupTradeBox;
      
      private var mType:int;
      
      private var mItemObject:ItemObject;
      
      public function TradeProcess(param1:ItemObject, param2:int)
      {
         super();
         this.mType = param2;
         this.mItemObject = param1;
         this.mTradeBox = new PopupTradeBox(this.mType);
      }
      
      private function onCloseSellBox(param1:Event) : void
      {
         this.mTradeBox.removeEventListener(Popup.EVENT_ACCEPT,this.onTrade);
         this.mTradeBox.removeEventListener(Popup.EVENT_CLOSE,this.onCloseSellBox);
         this.mItemObject.undoSelection();
      }
      
      public function startProcess() : void
      {
         this.showSellBox(null);
      }
      
      private function showSellBox(param1:Event) : void
      {
         this.mTradeBox.addEventListener(Popup.EVENT_ACCEPT,this.onTrade);
         this.mTradeBox.addEventListener(Popup.EVENT_CLOSE,this.onCloseSellBox);
         this.mTradeBox.changePrize(this.mItemObject.getSellPrice(),true);
         this.mTradeBox.start();
      }
      
      private function onTrade(param1:Event) : void
      {
         this.mTradeBox.removeEventListener(Popup.EVENT_CLOSE,this.onCloseSellBox);
         this.mTradeBox.removeEventListener(Popup.EVENT_ACCEPT,this.onTrade);
         this.mItemObject.undoSelection();
         dispatchEvent(new Event(EVENT_TRADE));
      }
   }
}

