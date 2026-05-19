package com.dchoc.dollars.world.items.commerces
{
   import com.dchoc.dollars.utils.definitions.Definition;
   import com.dchoc.framework.graphics.DCResourceManager;
   import flash.display.MovieClip;
   
   public class CommerceTypeDefinition extends Definition
   {
      
      public function CommerceTypeDefinition(param1:uint)
      {
         super(param1);
      }
      
      public function getDOIconOnCommerce() : MovieClip
      {
         return new (DCResourceManager.getInstance().getSWFClass(mSku,"Event"))();
      }
      
      public function getDOIconOnCommerceClick() : MovieClip
      {
         return new (DCResourceManager.getInstance().getSWFClass(mSku,"Event_ok"))();
      }
      
      public function getDOIconOnHouse() : MovieClip
      {
         return new (DCResourceManager.getInstance().getSWFClass("common","Event_common"))();
      }
   }
}

