package com.dchoc.dollars.utils
{
   import com.dchoc.dollars.utils.animations.SpriteObject;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   
   public class Cursor extends Sprite
   {
      
      public static const CURSOR_HAND:int = -2;
      
      public static const CURSOR_SELECT:int = -1;
      
      public static const CURSOR_DEMOLITION:int = 0;
      
      public static const CURSOR_ROAD:int = 1;
      
      public static const CURSOR_COLLECT:int = 2;
      
      public static const CURSOR_BUY:int = 3;
      
      public static const CURSOR_TERRAIN:int = 4;
      
      public static const CURSOR_BUILD:int = 5;
      
      public static const CURSOR_SCROLL_HAND:int = 6;
      
      public static const CURSOR_SCROLL_FIST:int = 7;
      
      public static const CURSOR_BUY_AREA:int = 8;
      
      public static const CURSOR_INSTANT_BUILD:int = 9;
      
      public static const CURSOR_WONDER:int = 10;
      
      public static const CURSOR_HELP_UPGRADE_ITEM:int = 11;
      
      public static const CURSOR_HELP_SUPER_UPGRADE_ITEM:int = 12;
      
      public static const CURSOR_SIGN_CONTRACT:int = 13;
      
      public static const CURSOR_CANCEL_CONTRACT:int = 14;
      
      public static const CURSOR_ABANDONED:int = 15;
      
      public static const CURSOR_MOVE:int = 16;
      
      public static const CURSOR_MONEY_COLLECTOR:int = 17;
      
      public static const CURSOR_CONTRACT_SIGNATOR:int = 18;
      
      public static const CURSOR_COLLECTIBLE:int = 19;
      
      public static const CURSOR_COLLECTIBLE_COMMERCE:int = 20;
      
      public static const CURSOR_HQ_01:int = 21;
      
      public static const CURSOR_HQ_02:int = 22;
      
      public static const CURSOR_HQ_03:int = 23;
      
      public static const CURSOR_HQ_04:int = 24;
      
      public static const CURSOR_RENT_ACC:int = 25;
      
      public static const CURSOR_RENT_ACC_NO_ACTION:int = 26;
      
      private var mCursor:SpriteObject;
      
      private var mCanvas:Sprite;
      
      private var mCursorsCollection:Dictionary;
      
      public var mApplyOffset:Boolean;
      
      private var mCursorPreviousID:int;
      
      public var mCurrentCursorID:int;
      
      public function Cursor()
      {
         super();
         this.load();
      }
      
      public function destroy() : void
      {
         this.end();
         if(this.mCursor != null)
         {
            this.mCursor.destroy();
            this.mCursor = null;
         }
      }
      
      public function start() : void
      {
         this.mCursor.changeAnim(CURSOR_SELECT);
         Mouse.hide();
         this.mApplyOffset = false;
      }
      
      public function isCursorInCollection(param1:int) : Boolean
      {
         if(this.mCursorsCollection[param1] == null)
         {
            return this.mCurrentCursorID == param1;
         }
         return this.mCurrentCursorID >= param1 && this.mCurrentCursorID < param1 + this.mCursorsCollection[param1];
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         x = param1;
         y = param2;
         if(this.mApplyOffset)
         {
            this.applyOffset();
         }
      }
      
      public function load() : void
      {
         var _loc1_:Sprite = new AssetManager.DemolitionCursor();
         var _loc2_:Sprite = new AssetManager.RoadCursor();
         var _loc3_:Sprite = new AssetManager.IncomeButtonCollect();
         var _loc4_:Sprite = new AssetManager.BuyCursor();
         var _loc5_:Sprite = new AssetManager.TerrainCursor();
         var _loc6_:Sprite = new AssetManager.BuildCursor();
         var _loc7_:Sprite = new AssetManager.ScrollHandCursor();
         var _loc8_:Sprite = new AssetManager.ScrollFistCursor();
         var _loc9_:Sprite = new AssetManager.BuyAreaCursor();
         var _loc10_:Sprite = new AssetManager.InstantBuildCursor();
         var _loc11_:Sprite = new AssetManager.WonderCursor();
         var _loc12_:Sprite = new AssetManager.HelpUpgradeItemCursor();
         var _loc13_:Sprite = new AssetManager.HelpSuperUpgradeItemCursor();
         var _loc14_:Sprite = new AssetManager.SignContractCursor();
         var _loc15_:Sprite = new AssetManager.CancelContractCursor();
         var _loc16_:Sprite = new AssetManager.AbandonedCursor();
         var _loc17_:Sprite = new AssetManager.MoveCursor();
         var _loc18_:Sprite = new AssetManager.CollectorCursor();
         var _loc19_:Sprite = new AssetManager.ContractSignatorCursor();
         var _loc20_:Sprite = new AssetManager.CollectibleCursor();
         var _loc21_:Sprite = new AssetManager.CollectibleCommerceCursor();
         var _loc22_:Sprite = new AssetManager.HQCursor();
         var _loc23_:Sprite = new AssetManager.HQ02Cursor();
         var _loc24_:Sprite = new AssetManager.HQ03Cursor();
         var _loc25_:Sprite = new AssetManager.HQ04Cursor();
         var _loc26_:Sprite = new AssetManager.RentAcceleratorCursor();
         var _loc27_:Sprite = new AssetManager.RentAcceleratorNoActionCursor();
         this.mCursor = new SpriteObject(this,new Array(_loc1_,_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,_loc17_,_loc18_,_loc19_,_loc20_,_loc21_,_loc22_,_loc23_,_loc24_,_loc25_,_loc26_,_loc27_));
         this.mCursorsCollection = new Dictionary();
         this.mCursorsCollection[CURSOR_HQ_01] = 5;
      }
      
      private function unApplyOffset() : void
      {
         x -= 2 * width / 3;
      }
      
      private function applyOffset() : void
      {
         x += 2 * width / 3;
      }
      
      public function setLabel(param1:String) : void
      {
         var _loc2_:DisplayObject = this.mCursor.getCurrentAnim();
         var _loc3_:TextField = _loc2_["label"];
         if(_loc3_ != null)
         {
            _loc3_.text = param1;
         }
      }
      
      public function get currentCursorID() : int
      {
         return this.mCurrentCursorID;
      }
      
      public function end() : void
      {
         Mouse.show();
      }
      
      public function changeCursor(param1:int, param2:int = 0) : void
      {
         if(param1 == CURSOR_HAND)
         {
            Mouse.show();
         }
         else if(param1 == CURSOR_SELECT)
         {
            Mouse.show();
            this.mCurrentCursorID = param1;
         }
         else
         {
            if(param2 > 0 && param2 < this.mCursorsCollection[param1])
            {
               param1 += param2;
            }
            Mouse.hide();
            this.mCurrentCursorID = param1;
         }
         this.mCursor.changeAnim(param1);
         this.mApplyOffset = false;
      }
      
      public function setApplyOffset(param1:Boolean) : void
      {
         this.mApplyOffset = param1;
         if(this.mApplyOffset)
         {
            this.applyOffset();
         }
         else
         {
            this.unApplyOffset();
         }
      }
   }
}

