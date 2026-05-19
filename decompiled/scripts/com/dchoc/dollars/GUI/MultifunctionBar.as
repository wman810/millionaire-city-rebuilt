package com.dchoc.dollars.GUI
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.map.Map;
   import com.dchoc.dollars.utils.effects.FiltersManager;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class MultifunctionBar extends Sprite
   {
      
      public static const BUTTON_MOVE:int = 0;
      
      public static const BUTTON_COLLECT:int = 1;
      
      public static const BUTTON_CONTRACT:int = 2;
      
      private var mBar:Sprite;
      
      private var mTools:Array;
      
      private var mMap:Map;
      
      private var mMoveButton:DynamicButton;
      
      private var mContractButton:DynamicButton;
      
      private var mCollectButton:DynamicButton;
      
      public function MultifunctionBar()
      {
         super();
         this.mBar = new (DCResourceManager.getInstance().getSWFClass(DollarsGame.HUD_SKU,"button_multifuncion"))();
         addChild(this.mBar);
         this.mMoveButton = new DynamicButton(this.mBar.getChildByName("move") as MovieClip);
         this.mMoveButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_MOVE));
         this.mCollectButton = new DynamicButton(this.mBar.getChildByName("collector") as MovieClip);
         this.mCollectButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_COLLECT));
         this.mContractButton = new DynamicButton(this.mBar.getChildByName("contract") as MovieClip);
         this.mContractButton.setTip(TextManager.getText(TextIDs.TID_HINT_BUTTON_MULTICONTRACT));
      }
      
      public function start(param1:int = -1) : void
      {
         this.mMoveButton.start();
         this.mMoveButton.addEventListener(MouseEvent.CLICK,this.setTool);
         this.mMoveButton.setUnselected();
         this.mCollectButton.start();
         this.mCollectButton.setUnselected();
         this.mCollectButton.addEventListener(MouseEvent.CLICK,this.setTool);
         this.mContractButton.start();
         this.mContractButton.addEventListener(MouseEvent.CLICK,this.setTool);
         if(Config.USE_TOOL_CONTRACT_SIGNATOR)
         {
            this.mContractButton.setUnselected();
         }
         else
         {
            this.mContractButton.disable();
            this.mContractButton.getButtonMc().filters = FiltersManager.getSaturationFilter(0);
         }
         this.visible = true;
         this.selectTool(param1);
      }
      
      public function selectTool(param1:int) : void
      {
         switch(param1)
         {
            case BUTTON_MOVE:
               this.mMoveButton.getButtonMc().dispatchEvent(new MouseEvent(MouseEvent.CLICK));
               break;
            case BUTTON_COLLECT:
               this.mCollectButton.getButtonMc().dispatchEvent(new MouseEvent(MouseEvent.CLICK));
               break;
            case BUTTON_CONTRACT:
               this.mContractButton.getButtonMc().dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         }
      }
      
      public function set map(param1:Map) : void
      {
         this.mMap = param1;
      }
      
      private function setTool(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         this.mMoveButton.setUnselected();
         this.mContractButton.setUnselected();
         this.mCollectButton.setUnselected();
         switch(_loc2_)
         {
            case this.mMoveButton.getButtonMc():
               DollarsGame.getCurrentRole().toolsBar.setToolMove();
               this.mMoveButton.setSelected();
               break;
            case this.mCollectButton.getButtonMc():
               DollarsGame.getCurrentRole().toolsBar.setToolMoneyCollector();
               this.mCollectButton.setSelected();
               break;
            case this.mContractButton.getButtonMc():
               DollarsGame.getCurrentRole().toolsBar.setToolContractSignator();
               this.mContractButton.setSelected();
         }
      }
      
      public function end() : void
      {
         this.mMoveButton.end();
         this.mMoveButton.removeEventListener(MouseEvent.CLICK,this.setTool);
         this.mCollectButton.end();
         this.mCollectButton.removeEventListener(MouseEvent.CLICK,this.setTool);
         this.mContractButton.end();
         this.mContractButton.removeEventListener(MouseEvent.CLICK,this.setTool);
         this.visible = false;
      }
      
      public function set tools(param1:Array) : void
      {
         this.mTools = param1;
      }
   }
}

