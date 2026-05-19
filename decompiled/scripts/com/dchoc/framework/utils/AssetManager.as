package com.dchoc.framework.utils
{
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   
   public class AssetManager
   {
      
      private static var instance:AssetManager;
      
      public static var Loading_Background:Class = AssetManager_Loading_Background;
      
      public static var Loading_Simple:Class = AssetManager_Loading_Simple;
      
      public static var HelveticaRounded:Class = AssetManager_HelveticaRounded;
      
      public static var ChallengeFont:Class = AssetManager_ChallengeFont;
      
      public static var SelectionCursor:Class = AssetManager_SelectionCursor;
      
      public static var DemolitionCursor:Class = AssetManager_DemolitionCursor;
      
      public static var RoadCursor:Class = AssetManager_RoadCursor;
      
      public static var IncomeButtonCollect:Class = AssetManager_IncomeButtonCollect;
      
      public static var BuyCursor:Class = AssetManager_BuyCursor;
      
      public static var TerrainCursor:Class = AssetManager_TerrainCursor;
      
      public static var BuildCursor:Class = AssetManager_BuildCursor;
      
      public static var MoveCursor:Class = AssetManager_MoveCursor;
      
      public static var CollectorCursor:Class = AssetManager_CollectorCursor;
      
      public static var ContractSignatorCursor:Class = AssetManager_ContractSignatorCursor;
      
      public static var HQCursor:Class = AssetManager_HQCursor;
      
      public static var HQ02Cursor:Class = AssetManager_HQ02Cursor;
      
      public static var HQ03Cursor:Class = AssetManager_HQ03Cursor;
      
      public static var HQ04Cursor:Class = AssetManager_HQ04Cursor;
      
      public static var ScrollHandCursor:Class = AssetManager_ScrollHandCursor;
      
      public static var ScrollFistCursor:Class = AssetManager_ScrollFistCursor;
      
      public static var BuyAreaCursor:Class = AssetManager_BuyAreaCursor;
      
      public static var InstantBuildCursor:Class = AssetManager_InstantBuildCursor;
      
      public static var HelpUpgradeItemCursor:Class = AssetManager_HelpUpgradeItemCursor;
      
      public static var HelpSuperUpgradeItemCursor:Class = AssetManager_HelpSuperUpgradeItemCursor;
      
      public static var WonderCursor:Class = AssetManager_WonderCursor;
      
      public static var RentAcceleratorCursor:Class = AssetManager_RentAcceleratorCursor;
      
      public static var RentAcceleratorNoActionCursor:Class = AssetManager_RentAcceleratorNoActionCursor;
      
      public static var TutorialArrow:Class = AssetManager_TutorialArrow;
      
      public static var SuperupgradeArrow:Class = AssetManager_SuperupgradeArrow;
      
      public static var Grill:Class = AssetManager_Grill;
      
      public static var GrillBad:Class = AssetManager_GrillBad;
      
      public static var SignContractCursor:Class = AssetManager_SignContractCursor;
      
      public static var AbandonedCursor:Class = AssetManager_AbandonedCursor;
      
      public static var CancelContractCursor:Class = AssetManager_CancelContractCursor;
      
      public static var CollectibleCursor:Class = AssetManager_CollectibleCursor;
      
      public static var CollectibleCommerceCursor:Class = AssetManager_CollectibleCommerceCursor;
      
      public static var Note:Class = AssetManager_Note;
      
      public static var Note1:Class = AssetManager_Note1;
      
      public static var Note2:Class = AssetManager_Note2;
      
      public static var Note3:Class = AssetManager_Note3;
      
      public static var Note4:Class = AssetManager_Note4;
      
      public static var PopupOutOfSync:Class = AssetManager_PopupOutOfSync;
      
      public static var PopupConnection:Class = AssetManager_PopupConnection;
      
      public static var PopupGamePlayConnection:Class = AssetManager_PopupGamePlayConnection;
      
      public static var TerrainParticle:Class = AssetManager_TerrainParticle;
      
      public static var TerrainDestroyParticle:Class = AssetManager_TerrainDestroyParticle;
      
      public static var IncomeButtonCollectEnd:Class = AssetManager_IncomeButtonCollectEnd;
      
      public static var InfluenceIconPositiveDecoration:Class = AssetManager_InfluenceIconPositiveDecoration;
      
      public static var InfluenceIconCommerce:Class = AssetManager_InfluenceIconCommerce;
      
      public static var SellBarOnTheirHouse:Class = AssetManager_SellBarOnTheirHouse;
      
      public static var SellBarOnHouse:Class = AssetManager_SellBarOnHouse;
      
      public static var ItemNoRoadIcon:Class = AssetManager_ItemNoRoadIcon;
      
      public static var PopupForSale:Class = AssetManager_PopupForSale;
      
      public static var PopupDestroy:Class = AssetManager_PopupDestroy;
      
      public static var NextButtonAnim:Class = AssetManager_NextButtonAnim;
      
      public static const SKU_GFX:int = 0;
      
      public static const SKU_GFX_SWF_FILE:int = 1;
      
      public static const SKU_WORLDCLASSNAME:int = 2;
      
      public static const SKU_PROPERTIES:int = 3;
      
      public static const DRAG_AND_DROPPABLE:int = 1;
      
      public static const SKU:Array = new Array();
      
      public function AssetManager()
      {
         super();
      }
      
      public static function getInstance() : AssetManager
      {
         if(instance == null)
         {
            instance = new AssetManager();
         }
         return instance;
      }
      
      public function getDisplayObjectFromSku(param1:String) : DisplayObject
      {
         var _loc2_:String = AssetManager.SKU[param1][AssetManager.SKU_GFX_SWF_FILE];
         var _loc3_:String = AssetManager.SKU[param1][AssetManager.SKU_GFX];
         if(_loc2_ == null)
         {
            return DCResourceManager.getInstance().get(_loc3_) as Sprite;
         }
         if(_loc2_ == "constructor")
         {
            return AssetManager.getInstance().getAssetByName(_loc3_);
         }
         return new (DCResourceManager.getInstance().getSWFClass(_loc2_,_loc3_))();
      }
      
      public function getClassByName(param1:String) : Class
      {
         var _loc2_:String = describeType(this).@name.toXMLString();
         var _loc3_:String = _loc2_ + "_" + param1;
         return getDefinitionByName(_loc3_) as Class;
      }
      
      public function getAssetByName(param1:String) : *
      {
         var _loc2_:String = describeType(this).@name.toXMLString();
         var _loc3_:String = _loc2_ + "_" + param1;
         trace("className = " + _loc2_ + " fullName = " + _loc3_);
         var _loc4_:Object = getDefinitionByName(_loc3_);
         return new _loc4_();
      }
   }
}

