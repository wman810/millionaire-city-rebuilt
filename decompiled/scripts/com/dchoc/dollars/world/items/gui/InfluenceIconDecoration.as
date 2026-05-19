package com.dchoc.dollars.world.items.gui
{
   import com.dchoc.dollars.flow.DollarsGame;
   import com.dchoc.dollars.utils.text.TextManager;
   import com.dchoc.dollars.world.companies.Company;
   import com.dchoc.dollars.world.items.ItemDefinition;
   import com.dchoc.framework.utils.AssetManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class InfluenceIconDecoration extends InfluenceIcon
   {
      
      private var mTextPositive:TextField;
      
      private var mIconPositive:Sprite;
      
      public function InfluenceIconDecoration()
      {
         super();
         visible = false;
      }
      
      override protected function getIconDO() : Sprite
      {
         this.mIconPositive = new AssetManager.InfluenceIconPositiveDecoration();
         var _loc1_:Sprite = new Sprite();
         this.mIconPositive.visible = false;
         _loc1_.addChild(this.mIconPositive);
         return _loc1_;
      }
      
      override public function setInfluenceAreaAffectedVisibility(param1:Boolean, param2:ItemDefinition, param3:Boolean = false) : void
      {
         var _loc4_:int = 0;
         if(param3)
         {
            param3 = !param2.isACommerce();
         }
         if(param3 && isVisible(param2))
         {
            _loc4_ = 0;
            if(param1)
            {
               _loc4_ = param2.getInfluenceValue();
               _loc4_ = _loc4_ + DollarsGame.getCurrentWorld().getCompanyMine().attributesGetValue(Company.ATTRIBUTES_KEY_INFLUENCE,param2);
            }
            this.update(_loc4_);
            visible = param1;
         }
      }
      
      override public function setEnabled(param1:Boolean) : void
      {
      }
      
      override protected function textDraw() : void
      {
         if(this.mTextPositive == null)
         {
            this.mTextPositive = this.mIconPositive.getChildByName("TextInfo") as TextField;
            this.mIconPositive.addChild(this.mTextPositive);
         }
      }
      
      override public function update(param1:int = 0) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         if(mItemObject.company != null && mItemObject.company.isInfluencePercentageEnabled())
         {
            _loc2_ = mItemObject.influenceValue + param1;
            _loc3_ = TextManager.getPercentageText(_loc2_);
            if(_loc2_ == 0)
            {
               visible = false;
            }
            else if(this.mIconPositive != null)
            {
               if(_loc2_ > 0)
               {
                  this.mIconPositive.visible = true;
                  mDOText = this.mTextPositive;
               }
               else
               {
                  this.mIconPositive.visible = false;
               }
               mDOText.text = _loc3_;
            }
         }
      }
      
      override public function destroy() : void
      {
         if(this.mTextPositive != null)
         {
            this.mIconPositive.removeChild(this.mTextPositive);
            this.mTextPositive = null;
         }
         if(mDOSprite != null)
         {
            mDOSprite.removeChild(this.mIconPositive);
            this.mIconPositive = null;
         }
         super.destroy();
      }
      
      override protected function doIsVisible(param1:ItemDefinition = null) : Boolean
      {
         var _loc2_:Boolean = mItemObject.company != null && mItemObject.company.isInfluencePercentageEnabled();
         this.update(0);
         return _loc2_;
      }
   }
}

