package com.luaye.console.core
{
   import com.luaye.console.Console;
   import com.luaye.console.utils.WeakObject;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   public class CommandTools
   {
      
      private var _mapBaseIndex:uint = 1;
      
      private var _mapBases:WeakObject;
      
      private var _report:Function;
      
      public function CommandTools(param1:Function)
      {
         super();
         this._report = param1;
         this._mapBases = new WeakObject();
      }
      
      private function makeInheritLine(param1:Array, param2:Array, param3:Boolean, param4:String, param5:String) : void
      {
         var _loc6_:String = "";
         if(Boolean(param1.length) || Boolean(param2.length))
         {
            _loc6_ += "<p10>" + param4 + ":</p10> " + param1.join(param5);
            if(param3)
            {
               _loc6_ += (param1.length ? param5 : "") + "<p2>" + param2.join(param5) + "</p2>";
            }
            else if(param2.length)
            {
               _loc6_ += (param1.length ? param5 : "") + "<p2>+ " + param2.length + " inherited</p2>";
            }
            this.report(_loc6_ + "<br/>",5);
         }
      }
      
      public function reMap(param1:String, param2:DisplayObjectContainer) : DisplayObject
      {
         var child:DisplayObject;
         var nn:String = null;
         var path:String = param1;
         var mc:DisplayObjectContainer = param2;
         var pathArr:Array = path.split(Console.MAPPING_SPLITTER);
         var first:String = pathArr.shift();
         if(first != "0")
         {
            mc = this._mapBases[first];
         }
         child = mc as DisplayObject;
         try
         {
            for each(nn in pathArr)
            {
               if(!nn)
               {
                  break;
               }
               child = mc.getChildByName(nn);
               if(!(child is DisplayObjectContainer))
               {
                  break;
               }
               mc = child as DisplayObjectContainer;
            }
            return child;
         }
         catch(e:Error)
         {
            report("Problem getting the clip reference. Display list must have changed since last map request",10);
         }
         return null;
      }
      
      public function printHelp() : void
      {
         this.report("____Command Line Help___",10);
         this.report("/filter (text) = filter/search logs for matching text",5);
         this.report("// = return to previous scope",5);
         this.report("/base = return to base scope (same as typing $base)",5);
         this.report("/store (name) = store current scope to that name (default is weak reference). to call back: $(name)",5);
         this.report("/savestrong (name) = store current scope as strong reference",5);
         this.report("/stored = list all stored variables",5);
         this.report("/inspect = get info of your current scope.",5);
         this.report("/inspectfull = get more detailed info of your current scope.",5);
         this.report("/map = get the display list map starting from your current scope",5);
         this.report("/strong true = turn on strong referencing, you need to turn this on if you want to start manipulating with instances that are newly created.",5);
         this.report("/string = return the param of this command as a string. This is useful if you want to paste a block of text to use in commandline.",5);
         this.report("Press up/down arrow keys to recall previous commands",2);
         this.report("__Examples:",10);
         this.report("<b>stage.width</b>",5);
         this.report("<b>stage.scaleMode = flash.display.StageScaleMode.NO_SCALE</b>",5);
         this.report("<b>stage.frameRate = 12</b>",5);
         this.report("__________",10);
      }
      
      public function report(param1:*, param2:Number = 1, param3:Boolean = true) : void
      {
         this._report(param1,param2,param3);
      }
      
      public function inspect(param1:Object, param2:Boolean = true) : void
      {
         var nodes:XMLList = null;
         var extendX:XML = null;
         var implementX:XML = null;
         var constantX:XML = null;
         var methodX:XML = null;
         var arr:Array = null;
         var accessorX:XML = null;
         var variableX:XML = null;
         var X:String = null;
         var metadataX:XML = null;
         var mparamsList:XMLList = null;
         var params:Array = null;
         var paraX:XML = null;
         var mn:XMLList = null;
         var mc:DisplayObjectContainer = null;
         var clen:int = 0;
         var ci:int = 0;
         var theParent:DisplayObjectContainer = null;
         var child:DisplayObject = null;
         var pr:DisplayObjectContainer = null;
         var obj:Object = param1;
         var viewAll:Boolean = param2;
         var V:XML = describeType(obj);
         var cls:Object = obj is Class ? obj : obj.constructor;
         var clsV:XML = describeType(cls);
         var self:String = V.@name;
         var str:String = "<b>" + self + "</b>";
         var props:Array = [];
         var props2:Array = [];
         var staticPrefix:String = "<p1><i>[static]</i></p1>";
         if(V.@isDynamic == "true")
         {
            props.push("dynamic");
         }
         if(V.@isFinal == "true")
         {
            props.push("final");
         }
         if(V.@isStatic == "true")
         {
            props.push("static");
         }
         if(props.length > 0)
         {
            str += " <p-1>" + props.join(" | ") + "</p-1>";
         }
         this.report(str + "<br/>",-2);
         props = [];
         nodes = V.extendsClass;
         for each(extendX in nodes)
         {
            props.push(extendX.@type.toString());
            if(!viewAll)
            {
               break;
            }
         }
         if(props.length)
         {
            this.report("<p10>Extends:</p10> " + props.join("<p-1> &gt; </p-1>") + "<br/>",5);
         }
         props = [];
         nodes = V.implementsInterface;
         for each(implementX in nodes)
         {
            props.push(implementX.@type.toString());
         }
         if(props.length)
         {
            this.report("<p10>Implements:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",5);
         }
         props = [];
         nodes = clsV..constant;
         for each(constantX in nodes)
         {
            props.push(constantX.@name + "<p0>(" + constantX.@type + ")</p0>");
         }
         if(props.length)
         {
            this.report("<p10>Constants:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",5);
         }
         props = [];
         props2 = [];
         nodes = clsV..method;
         for each(methodX in nodes)
         {
            mparamsList = methodX.parameter;
            str = methodX.parent().name() == "factory" ? "" : staticPrefix;
            if(viewAll)
            {
               params = [];
               for each(paraX in mparamsList)
               {
                  params.push(paraX.@optional == "true" ? "<i>" + paraX.@type + "</i>" : paraX.@type);
               }
               str += methodX.@name + "<p0>(<i>" + params.join(",") + "</i>):" + methodX.@returnType + "</p0>";
            }
            else
            {
               str += methodX.@name + "<p0>(<i>" + mparamsList.length() + "</i>):" + methodX.@returnType + "</p0>";
            }
            arr = self == methodX.@declaredBy ? props : props2;
            arr.push(str);
         }
         this.makeInheritLine(props,props2,viewAll,"Methods",viewAll ? "<br/>" : "<p-1>; </p-1>");
         props = [];
         props2 = [];
         nodes = clsV..accessor;
         for each(accessorX in nodes)
         {
            str = accessorX.parent().name() == "factory" ? "" : staticPrefix;
            str += (accessorX.@access == "readonly" ? "<i>" + accessorX.@name + "</i>" : accessorX.@name) + "<p0>(" + accessorX.@type + ")</p0>";
            arr = self == accessorX.@declaredBy ? props : props2;
            arr.push(str);
         }
         this.makeInheritLine(props,props2,viewAll,"Accessors","<p-1>; </p-1>");
         props = [];
         nodes = clsV..variable;
         for each(variableX in nodes)
         {
            str = (variableX.parent().name() == "factory" ? "" : staticPrefix) + variableX.@name + "<p0>(" + variableX.@type + ")</p0>";
            props.push(str);
         }
         if(props.length)
         {
            this.report("<p10>Variables:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",5);
         }
         props = [];
         for(X in obj)
         {
            props.push(X + "<p0>(" + getQualifiedClassName(obj[X]) + ")</p0>");
         }
         if(props.length)
         {
            this.report("<p10>Values:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",5);
         }
         props = [];
         nodes = V.metadata;
         for each(metadataX in nodes)
         {
            if(metadataX.@name == "Event")
            {
               mn = metadataX.arg;
               props.push(mn.(@key == "name").@value + "<p0>(" + mn.(@key == "type").@value + ")</p0>");
            }
         }
         if(props.length)
         {
            this.report("<p10>Events:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",5);
         }
         if(viewAll && obj is DisplayObjectContainer)
         {
            props = [];
            mc = obj as DisplayObjectContainer;
            clen = mc.numChildren;
            ci = 0;
            while(ci < clen)
            {
               child = mc.getChildAt(ci);
               props.push("<b>" + child.name + "</b>:(" + ci + ")" + getQualifiedClassName(child));
               ci++;
            }
            if(props.length)
            {
               this.report("<p10>Children:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",5);
            }
            theParent = mc.parent;
            if(theParent)
            {
               props = ["(" + theParent.getChildIndex(mc) + ")"];
               while(theParent)
               {
                  pr = theParent;
                  theParent = theParent.parent;
                  props.push("<b>" + pr.name + "</b>:(" + (theParent ? theParent.getChildIndex(pr) : "") + ")" + getQualifiedClassName(pr));
               }
               if(props.length)
               {
                  this.report("<p10>Parents:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",5);
               }
            }
         }
         if(!viewAll)
         {
            this.report("Tip: use /inspectfull to see full inspection with inheritance",-1);
         }
      }
      
      public function map(param1:DisplayObjectContainer, param2:uint = 0) : void
      {
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         var _loc11_:DisplayObject = null;
         var _loc12_:DisplayObjectContainer = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:DisplayObject = null;
         var _loc16_:String = null;
         var _loc17_:String = null;
         if(!param1)
         {
            this.report("It is not a DisplayObjectContainer",10);
            return;
         }
         this._mapBases[this._mapBaseIndex] = param1;
         var _loc3_:String = this._mapBaseIndex + Console.MAPPING_SPLITTER;
         var _loc4_:Array = new Array();
         var _loc5_:int = 0;
         _loc4_.push(param1);
         while(_loc5_ < _loc4_.length)
         {
            _loc11_ = _loc4_[_loc5_];
            if(_loc11_ is DisplayObjectContainer)
            {
               _loc12_ = _loc11_ as DisplayObjectContainer;
               _loc13_ = _loc12_.numChildren;
               _loc14_ = 0;
               while(_loc14_ < _loc13_)
               {
                  _loc15_ = _loc12_.getChildAt(_loc14_);
                  _loc4_.splice(_loc5_ + _loc14_ + 1,0,_loc15_);
                  _loc14_++;
               }
            }
            _loc5_++;
         }
         var _loc6_:* = 0;
         var _loc7_:DisplayObject = null;
         var _loc8_:Array = new Array();
         for(_loc10_ in _loc4_)
         {
            _loc11_ = _loc4_[_loc10_];
            if(_loc7_)
            {
               if(_loc7_ is DisplayObjectContainer && (_loc7_ as DisplayObjectContainer).contains(_loc11_))
               {
                  _loc6_++;
                  _loc8_.push(_loc11_.name);
               }
               else
               {
                  while(_loc7_)
                  {
                     _loc7_ = _loc7_.parent;
                     if(_loc7_ is DisplayObjectContainer)
                     {
                        if(_loc6_ > 0)
                        {
                           _loc8_.pop();
                           _loc6_--;
                        }
                        if((_loc7_ as DisplayObjectContainer).contains(_loc11_))
                        {
                           _loc6_++;
                           _loc8_.push(_loc11_.name);
                           break;
                        }
                     }
                  }
               }
            }
            _loc16_ = "";
            _loc14_ = 0;
            while(_loc14_ < _loc6_)
            {
               _loc16_ += _loc14_ == _loc6_ - 1 ? " ∟ " : " - ";
               _loc14_++;
            }
            if(param2 <= 0 || _loc6_ <= param2)
            {
               _loc9_ = false;
               _loc17_ = "<a href=\'event:clip_" + _loc3_ + _loc8_.join(Console.MAPPING_SPLITTER) + "\'>" + _loc11_.name + "</a>";
               if(_loc11_ is DisplayObjectContainer)
               {
                  _loc17_ = "<b>" + _loc17_ + "</b>";
               }
               else
               {
                  _loc17_ = "<i>" + _loc17_ + "</i>";
               }
               _loc16_ += _loc17_ + " (" + getQualifiedClassName(_loc11_) + ")";
               this.report(_loc16_,_loc11_ is DisplayObjectContainer ? 5 : 2);
            }
            else if(!_loc9_)
            {
               _loc9_ = true;
               this.report(_loc16_ + "...",5);
            }
            _loc7_ = _loc11_;
         }
         ++this._mapBaseIndex;
         this.report(param1.name + ":" + getQualifiedClassName(param1) + " has " + _loc4_.length + " children/sub-children.",10);
         this.report("Click on the name to return a reference to the child clip. <br/>Note that clip references will be broken when display list is changed",-2);
      }
   }
}

