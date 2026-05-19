package com.demonsters.debugger
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   internal class MonsterDebuggerUtils
   {
      
      private static var _references:Dictionary = new Dictionary(true);
      
      private static var _reference:int = 0;
      
      public function MonsterDebuggerUtils()
      {
         super();
      }
      
      public static function snapshot(param1:DisplayObject, param2:Rectangle = null) : BitmapData
      {
         var bitmapData:BitmapData;
         var rotation:Number;
         var scaleX:Number;
         var scaleY:Number;
         var alpha:Number;
         var bounds:Rectangle;
         var visible:Boolean;
         var m:Matrix = null;
         var scaled:Rectangle = null;
         var s:Number = NaN;
         var b:BitmapData = null;
         var object:DisplayObject = param1;
         var rectangle:Rectangle = param2;
         if(object == null)
         {
            return null;
         }
         visible = object.visible;
         alpha = object.alpha;
         rotation = object.rotation;
         scaleX = object.scaleX;
         scaleY = object.scaleY;
         try
         {
            object.visible = true;
            object.alpha = 1;
            object.rotation = 0;
            object.scaleX = 1;
            object.scaleY = 1;
         }
         catch(e1:Error)
         {
         }
         bounds = object.getBounds(object);
         bounds.x = int(bounds.x + 0.5);
         bounds.y = int(bounds.y + 0.5);
         bounds.width = int(bounds.width + 0.5);
         bounds.height = int(bounds.height + 0.5);
         if(object is Stage)
         {
            bounds.x = 0;
            bounds.y = 0;
            bounds.width = Stage(object).stageWidth;
            bounds.height = Stage(object).stageHeight;
         }
         bitmapData = null;
         if(bounds.width <= 0 || bounds.height <= 0)
         {
            return null;
         }
         bitmapData = new BitmapData(bounds.width,bounds.height,false,16777215);
         m = new Matrix();
         m.tx = -bounds.x;
         m.ty = -bounds.y;
         bitmapData.draw(object,m,null,null,null,false);
         try
         {
            object.visible = visible;
            object.alpha = alpha;
            object.rotation = rotation;
            object.scaleX = scaleX;
            object.scaleY = scaleY;
         }
         catch(e2:Error)
         {
         }
         if(rectangle != null)
         {
            if(bounds.width <= rectangle.width && bounds.height <= rectangle.height)
            {
               return bitmapData;
            }
            scaled = bounds.clone();
            scaled.width = rectangle.width;
            scaled.height = rectangle.width * (bounds.height / bounds.width);
            if(scaled.height > rectangle.height)
            {
               scaled = bounds.clone();
               scaled.width = rectangle.height * (bounds.width / bounds.height);
               scaled.height = rectangle.height;
            }
            s = scaled.width / bounds.width;
            b = new BitmapData(scaled.width,scaled.height,false,0);
            m = new Matrix();
            m.scale(s,s);
            b.draw(bitmapData,m,null,null,null,true);
            return b;
         }
         return bitmapData;
      }
      
      private static function parseClass(param1:*, param2:String, param3:XML, param4:int = 1, param5:int = 5, param6:Boolean = true) : XML
      {
         var key:String = null;
         var itemsArrayLength:int = 0;
         var item:* = undefined;
         var itemXML:XML = null;
         var itemAccess:String = null;
         var itemPermission:String = null;
         var itemIcon:String = null;
         var itemType:String = null;
         var itemName:String = null;
         var itemTarget:String = null;
         var isXMLString:XML = null;
         var i:int = 0;
         var prop:* = undefined;
         var displayObject:DisplayObjectContainer = null;
         var displayObjects:Array = null;
         var child:DisplayObject = null;
         var object:* = param1;
         var target:String = param2;
         var description:XML = param3;
         var currentDepth:int = param4;
         var maxDepth:int = param5;
         var includeDisplayObjects:Boolean = param6;
         var rootXML:XML = <root/>;
         var nodeXML:XML = <node/>;
         var variables:XMLList = description..variable;
         var accessors:XMLList = description..accessor;
         var constants:XMLList = description..constant;
         var isDynamic:Boolean = Boolean(description.@isDynamic);
         var variablesLength:int = variables.length();
         var accessorsLength:int = accessors.length();
         var constantsLength:int = constants.length();
         var childLength:int = 0;
         var keys:Object = {};
         var itemsArray:Array = [];
         var isXML:Boolean = false;
         if(isDynamic)
         {
            for(prop in object)
            {
               key = String(prop);
               if(!keys.hasOwnProperty(key))
               {
                  keys[key] = key;
                  itemName = key;
                  itemType = parseType(getQualifiedClassName(object[key]));
                  itemTarget = target + "." + key;
                  itemAccess = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
                  itemsArray[itemsArray.length] = {
                     "name":itemName,
                     "type":itemType,
                     "target":itemTarget,
                     "access":itemAccess,
                     "permission":itemPermission,
                     "icon":itemIcon
                  };
               }
            }
         }
         i = 0;
         while(i < variablesLength)
         {
            key = variables[i].@name;
            if(!keys.hasOwnProperty(key))
            {
               keys[key] = key;
               itemName = key;
               itemType = parseType(variables[i].@type);
               itemTarget = target + "." + key;
               itemAccess = MonsterDebuggerConstants.ACCESS_VARIABLE;
               itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
               itemsArray[itemsArray.length] = {
                  "name":itemName,
                  "type":itemType,
                  "target":itemTarget,
                  "access":itemAccess,
                  "permission":itemPermission,
                  "icon":itemIcon
               };
            }
            i++;
         }
         i = 0;
         while(i < accessorsLength)
         {
            key = accessors[i].@name;
            if(!keys.hasOwnProperty(key))
            {
               keys[key] = key;
               itemName = key;
               itemType = parseType(accessors[i].@type);
               itemTarget = target + "." + key;
               itemAccess = MonsterDebuggerConstants.ACCESS_ACCESSOR;
               itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
               if(accessors[i].@access == MonsterDebuggerConstants.PERMISSION_READONLY)
               {
                  itemPermission = MonsterDebuggerConstants.PERMISSION_READONLY;
                  itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_READONLY;
               }
               if(accessors[i].@access == MonsterDebuggerConstants.PERMISSION_WRITEONLY)
               {
                  itemPermission = MonsterDebuggerConstants.PERMISSION_WRITEONLY;
                  itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_WRITEONLY;
               }
               itemsArray[itemsArray.length] = {
                  "name":itemName,
                  "type":itemType,
                  "target":itemTarget,
                  "access":itemAccess,
                  "permission":itemPermission,
                  "icon":itemIcon
               };
            }
            i++;
         }
         i = 0;
         while(i < constantsLength)
         {
            key = constants[i].@name;
            if(!keys.hasOwnProperty(key))
            {
               keys[key] = key;
               itemName = key;
               itemType = parseType(constants[i].@type);
               itemTarget = target + "." + key;
               itemAccess = MonsterDebuggerConstants.ACCESS_CONSTANT;
               itemPermission = MonsterDebuggerConstants.PERMISSION_READONLY;
               itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_READONLY;
               itemsArray[itemsArray.length] = {
                  "name":itemName,
                  "type":itemType,
                  "target":itemTarget,
                  "access":itemAccess,
                  "permission":itemPermission,
                  "icon":itemIcon
               };
            }
            i++;
         }
         itemsArray.sortOn("name",Array.CASEINSENSITIVE);
         if(includeDisplayObjects && object is DisplayObjectContainer)
         {
            displayObject = DisplayObjectContainer(object);
            displayObjects = [];
            childLength = displayObject.numChildren;
            i = 0;
            while(i < childLength)
            {
               child = displayObject.getChildAt(i);
               if(child != null)
               {
                  itemXML = MonsterDebuggerDescribeType.get(child);
                  itemType = parseType(itemXML.@name);
                  itemName = "DisplayObject";
                  if(child.name != null)
                  {
                     itemName += " - " + child.name;
                  }
                  itemTarget = target + "." + "getChildAt(" + i + ")";
                  itemAccess = MonsterDebuggerConstants.ACCESS_DISPLAY_OBJECT;
                  itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  itemIcon = child is DisplayObjectContainer ? MonsterDebuggerConstants.ICON_ROOT : MonsterDebuggerConstants.ICON_DISPLAY_OBJECT;
                  displayObjects[displayObjects.length] = {
                     "name":itemName,
                     "type":itemType,
                     "target":itemTarget,
                     "access":itemAccess,
                     "permission":itemPermission,
                     "icon":itemIcon,
                     "index":i
                  };
               }
               i++;
            }
            displayObjects.sortOn("name",Array.CASEINSENSITIVE);
            itemsArray = displayObjects.concat(itemsArray);
         }
         itemsArrayLength = int(itemsArray.length);
         i = 0;
         while(i < itemsArrayLength)
         {
            itemType = itemsArray[i].type;
            itemName = itemsArray[i].name;
            itemTarget = itemsArray[i].target;
            itemPermission = itemsArray[i].permission;
            itemAccess = itemsArray[i].access;
            itemIcon = itemsArray[i].icon;
            try
            {
               if(itemAccess == MonsterDebuggerConstants.ACCESS_DISPLAY_OBJECT)
               {
                  item = DisplayObjectContainer(object).getChildAt(itemsArray[i].index);
               }
               else
               {
                  item = object[itemName];
               }
            }
            catch(e:Error)
            {
               item = null;
            }
            if(item != null && itemPermission != MonsterDebuggerConstants.PERMISSION_WRITEONLY)
            {
               if(itemType == MonsterDebuggerConstants.TYPE_STRING || itemType == MonsterDebuggerConstants.TYPE_BOOLEAN || itemType == MonsterDebuggerConstants.TYPE_NUMBER || itemType == MonsterDebuggerConstants.TYPE_INT || itemType == MonsterDebuggerConstants.TYPE_UINT || itemType == MonsterDebuggerConstants.TYPE_FUNCTION)
               {
                  isXML = false;
                  isXMLString = new XML();
                  if(itemType == MonsterDebuggerConstants.TYPE_STRING)
                  {
                     try
                     {
                        isXMLString = new XML(item);
                        isXML = !isXMLString.hasSimpleContent() && isXMLString.children().length() > 0;
                     }
                     catch(error:TypeError)
                     {
                     }
                  }
                  if(!isXML)
                  {
                     nodeXML = <node/>;
                     nodeXML.@icon = itemIcon;
                     nodeXML.@label = itemName + " (" + itemType + ") = " + printValue(item,itemType);
                     nodeXML.@name = itemName;
                     nodeXML.@type = itemType;
                     nodeXML.@value = printValue(item,itemType);
                     nodeXML.@target = itemTarget;
                     nodeXML.@access = itemAccess;
                     nodeXML.@permission = itemPermission;
                     rootXML.appendChild(nodeXML);
                  }
                  else
                  {
                     nodeXML = <node/>;
                     nodeXML.@icon = itemIcon;
                     nodeXML.@label = itemName + " (" + itemType + ")";
                     nodeXML.@name = itemName;
                     nodeXML.@type = itemType;
                     nodeXML.@value = "";
                     nodeXML.@target = itemTarget;
                     nodeXML.@access = itemAccess;
                     nodeXML.@permission = itemPermission;
                     nodeXML.appendChild(parseXML(isXMLString,itemTarget + "." + "children()",currentDepth,maxDepth).children());
                     rootXML.appendChild(nodeXML);
                  }
               }
               else
               {
                  nodeXML = <node/>;
                  nodeXML.@icon = itemIcon;
                  nodeXML.@label = itemName + " (" + itemType + ")";
                  nodeXML.@name = itemName;
                  nodeXML.@type = itemType;
                  nodeXML.@target = itemTarget;
                  nodeXML.@access = itemAccess;
                  nodeXML.@permission = itemPermission;
                  if(item != null && itemType != MonsterDebuggerConstants.TYPE_BYTEARRAY)
                  {
                     nodeXML.appendChild(parse(item,itemTarget,currentDepth + 1,maxDepth,includeDisplayObjects).children());
                  }
                  rootXML.appendChild(nodeXML);
               }
            }
            i++;
         }
         return rootXML;
      }
      
      private static function parseArray(param1:*, param2:String, param3:int = 1, param4:int = 5, param5:Boolean = true) : XML
      {
         var isNumeric:Boolean;
         var keys:Array;
         var nodeXML:XML = null;
         var childXML:XML = null;
         var key:* = undefined;
         var object:* = param1;
         var target:String = param2;
         var currentDepth:int = param3;
         var maxDepth:int = param4;
         var includeDisplayObjects:Boolean = param5;
         var rootXML:XML = <root/>;
         var childType:String = "";
         var childTarget:String = "";
         var isXML:Boolean = false;
         var isXMLString:XML = new XML();
         var i:int = 0;
         nodeXML = <node/>;
         nodeXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
         nodeXML.@label = "length" + " (" + MonsterDebuggerConstants.TYPE_UINT + ") = " + object["length"];
         nodeXML.@name = "length";
         nodeXML.@type = MonsterDebuggerConstants.TYPE_UINT;
         nodeXML.@value = object["length"];
         nodeXML.@target = target + "." + "length";
         nodeXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
         nodeXML.@permission = MonsterDebuggerConstants.PERMISSION_READONLY;
         keys = [];
         isNumeric = true;
         for(key in object)
         {
            if(!(key is int))
            {
               isNumeric = false;
            }
            keys.push(key);
         }
         if(isNumeric)
         {
            keys.sort(Array.NUMERIC);
         }
         else
         {
            keys.sort(Array.CASEINSENSITIVE);
         }
         i = 0;
         while(i < keys.length)
         {
            childType = parseType(MonsterDebuggerDescribeType.get(object[keys[i]]).@name);
            childTarget = target + "." + String(keys[i]);
            if(childType == MonsterDebuggerConstants.TYPE_STRING || childType == MonsterDebuggerConstants.TYPE_BOOLEAN || childType == MonsterDebuggerConstants.TYPE_NUMBER || childType == MonsterDebuggerConstants.TYPE_INT || childType == MonsterDebuggerConstants.TYPE_UINT || childType == MonsterDebuggerConstants.TYPE_FUNCTION)
            {
               isXML = false;
               isXMLString = new XML();
               if(childType == MonsterDebuggerConstants.TYPE_STRING)
               {
                  try
                  {
                     isXMLString = new XML(object[keys[i]]);
                     if(!isXMLString.hasSimpleContent() && isXMLString.children().length() > 0)
                     {
                        isXML = true;
                     }
                  }
                  catch(error:TypeError)
                  {
                  }
               }
               if(!isXML)
               {
                  childXML = <node/>;
                  childXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  childXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  childXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  childXML.@label = "[" + keys[i] + "] (" + childType + ") = " + printValue(object[keys[i]],childType);
                  childXML.@name = "[" + keys[i] + "]";
                  childXML.@type = childType;
                  childXML.@value = printValue(object[keys[i]],childType);
                  childXML.@target = childTarget;
                  nodeXML.appendChild(childXML);
               }
               else
               {
                  childXML = <node/>;
                  childXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  childXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  childXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  childXML.@label = "[" + keys[i] + "] (" + childType + ")";
                  childXML.@name = "[" + keys[i] + "]";
                  childXML.@type = childType;
                  childXML.@value = "";
                  childXML.@target = childTarget;
                  childXML.appendChild(parseXML(object[keys[i]],childTarget,currentDepth + 1,maxDepth).children());
                  nodeXML.appendChild(childXML);
               }
            }
            else
            {
               childXML = <node/>;
               childXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
               childXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               childXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               childXML.@label = "[" + keys[i] + "] (" + childType + ")";
               childXML.@name = "[" + keys[i] + "]";
               childXML.@type = childType;
               childXML.@value = "";
               childXML.@target = childTarget;
               childXML.appendChild(parse(object[keys[i]],childTarget,currentDepth + 1,maxDepth,includeDisplayObjects).children());
               nodeXML.appendChild(childXML);
            }
            i++;
         }
         rootXML.appendChild(nodeXML);
         return rootXML;
      }
      
      public static function parseFunctions(param1:*, param2:String = "") : XML
      {
         var itemXML:XML = null;
         var key:String = null;
         var returnType:String = null;
         var parameters:XMLList = null;
         var parametersLength:int = 0;
         var args:Array = null;
         var argsString:String = null;
         var methodXML:XML = null;
         var parameterXML:XML = null;
         var object:* = param1;
         var target:String = param2;
         var rootXML:XML = <root/>;
         var description:XML = MonsterDebuggerDescribeType.get(object);
         var type:String = parseType(description.@name);
         var itemType:String = "";
         var itemName:String = "";
         var itemTarget:String = "";
         var keys:Object = {};
         var methods:XMLList = description..method;
         var methodsArr:Array = [];
         var methodsLength:int = methods.length();
         var optional:Boolean = false;
         var i:int = 0;
         var n:int = 0;
         itemXML = <node/>;
         itemXML.@icon = MonsterDebuggerConstants.ICON_DEFAULT;
         itemXML.@label = "(" + type + ")";
         itemXML.@target = target;
         i = 0;
         while(i < methodsLength)
         {
            key = methods[i].@name;
            try
            {
               if(!keys.hasOwnProperty(key))
               {
                  keys[key] = key;
                  methodsArr[methodsArr.length] = {
                     "name":key,
                     "xml":methods[i],
                     "access":MonsterDebuggerConstants.ACCESS_METHOD
                  };
               }
            }
            catch(e:Error)
            {
            }
            i++;
         }
         methodsArr.sortOn("name",Array.CASEINSENSITIVE);
         methodsLength = int(methodsArr.length);
         i = 0;
         while(i < methodsLength)
         {
            itemType = MonsterDebuggerConstants.TYPE_FUNCTION;
            itemName = methodsArr[i].xml.@name;
            itemTarget = target + MonsterDebuggerConstants.DELIMITER + itemName;
            returnType = parseType(methodsArr[i].xml.@returnType);
            parameters = methodsArr[i].xml..parameter;
            parametersLength = parameters.length();
            args = [];
            argsString = "";
            optional = false;
            n = 0;
            while(n < parametersLength)
            {
               if(parameters[n].@optional == "true" && !optional)
               {
                  optional = true;
                  args[args.length] = "[";
               }
               args[args.length] = parseType(parameters[n].@type);
               n++;
            }
            if(optional)
            {
               args[args.length] = "]";
            }
            argsString = args.join(", ");
            argsString = argsString.replace("[, ","[");
            argsString = argsString.replace(", ]","]");
            methodXML = <node/>;
            methodXML.@icon = MonsterDebuggerConstants.ICON_FUNCTION;
            methodXML.@type = MonsterDebuggerConstants.TYPE_FUNCTION;
            methodXML.@access = MonsterDebuggerConstants.ACCESS_METHOD;
            methodXML.@label = itemName + "(" + argsString + "):" + returnType;
            methodXML.@name = itemName;
            methodXML.@target = itemTarget;
            methodXML.@args = argsString;
            methodXML.@returnType = returnType;
            n = 0;
            while(n < parametersLength)
            {
               parameterXML = <node/>;
               parameterXML.@type = parseType(parameters[n].@type);
               parameterXML.@index = parameters[n].@index;
               parameterXML.@optional = parameters[n].@optional;
               methodXML.appendChild(parameterXML);
               n++;
            }
            itemXML.appendChild(methodXML);
            i++;
         }
         rootXML.appendChild(itemXML);
         return rootXML;
      }
      
      public static function parseXML(param1:*, param2:String = "", param3:int = 1, param4:int = -1) : XML
      {
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc9_:String = null;
         var _loc5_:XML = <root/>;
         var _loc8_:int = 0;
         if(param4 != -1 && param3 > param4)
         {
            return _loc5_;
         }
         if(param2.indexOf("@") != -1)
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = param1;
            _loc6_.@name = "";
            _loc6_.@value = param1;
            _loc6_.@target = param2;
            _loc5_.appendChild(_loc6_);
         }
         else if(param1.name() == null)
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLVALUE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLVALUE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = "(" + MonsterDebuggerConstants.TYPE_XMLVALUE + ") = " + printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
            _loc6_.@name = "";
            _loc6_.@value = printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
            _loc6_.@target = param2;
            _loc5_.appendChild(_loc6_);
         }
         else if(param1.hasSimpleContent())
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLNODE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLNODE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = param1.name() + " (" + MonsterDebuggerConstants.TYPE_XMLNODE + ")";
            _loc6_.@name = param1.name();
            _loc6_.@value = "";
            _loc6_.@target = param2;
            if(param1 != "")
            {
               _loc7_ = <node/>;
               _loc7_.@icon = MonsterDebuggerConstants.ICON_XMLVALUE;
               _loc7_.@type = MonsterDebuggerConstants.TYPE_XMLVALUE;
               _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc7_.@label = "(" + MonsterDebuggerConstants.TYPE_XMLVALUE + ") = " + printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
               _loc7_.@name = "";
               _loc7_.@value = printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
               _loc7_.@target = param2;
               _loc6_.appendChild(_loc7_);
            }
            _loc8_ = 0;
            while(_loc8_ < param1.attributes().length())
            {
               _loc7_ = <node/>;
               _loc7_.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
               _loc7_.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
               _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc7_.@label = "@" + param1.attributes()[_loc8_].name() + " (" + MonsterDebuggerConstants.TYPE_XMLATTRIBUTE + ") = " + param1.attributes()[_loc8_];
               _loc7_.@name = "";
               _loc7_.@value = param1.attributes()[_loc8_];
               _loc7_.@target = param2 + "." + "@" + param1.attributes()[_loc8_].name();
               _loc6_.appendChild(_loc7_);
               _loc8_++;
            }
            _loc5_.appendChild(_loc6_);
         }
         else
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLNODE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLNODE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = param1.name() + " (" + MonsterDebuggerConstants.TYPE_XMLNODE + ")";
            _loc6_.@name = param1.name();
            _loc6_.@value = "";
            _loc6_.@target = param2;
            _loc8_ = 0;
            while(_loc8_ < param1.attributes().length())
            {
               _loc7_ = <node/>;
               _loc7_.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
               _loc7_.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
               _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc7_.@label = "@" + param1.attributes()[_loc8_].name() + " (" + MonsterDebuggerConstants.TYPE_XMLATTRIBUTE + ") = " + param1.attributes()[_loc8_];
               _loc7_.@name = "";
               _loc7_.@value = param1.attributes()[_loc8_];
               _loc7_.@target = param2 + "." + "@" + param1.attributes()[_loc8_].name();
               _loc6_.appendChild(_loc7_);
               _loc8_++;
            }
            _loc8_ = 0;
            while(_loc8_ < param1.children().length())
            {
               _loc9_ = param2 + "." + "children()" + "." + _loc8_;
               _loc6_.appendChild(parseXML(param1.children()[_loc8_],_loc9_,param3 + 1,param4).children());
               _loc8_++;
            }
            _loc5_.appendChild(_loc6_);
         }
         return _loc5_;
      }
      
      public static function resume() : Boolean
      {
         try
         {
            System.resume();
            return true;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public static function getObjectUnderPoint(param1:DisplayObjectContainer, param2:Point) : DisplayObject
      {
         var _loc3_:Array = null;
         var _loc4_:DisplayObject = null;
         var _loc6_:DisplayObject = null;
         if(param1.areInaccessibleObjectsUnderPoint(param2))
         {
            return param1;
         }
         _loc3_ = param1.getObjectsUnderPoint(param2);
         _loc3_.reverse();
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return param1;
         }
         _loc4_ = _loc3_[0];
         _loc3_.length = 0;
         while(true)
         {
            _loc3_[_loc3_.length] = _loc4_;
            if(_loc4_.parent == null)
            {
               break;
            }
            _loc4_ = _loc4_.parent;
         }
         _loc3_.reverse();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc5_];
            if(!(_loc6_ is DisplayObjectContainer))
            {
               break;
            }
            _loc4_ = _loc6_;
            if(!DisplayObjectContainer(_loc6_).mouseChildren)
            {
               break;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      public static function getReferenceID(param1:*) : String
      {
         if(param1 in _references)
         {
            return _references[param1];
         }
         var _loc2_:String = "#" + String(_reference);
         _references[param1] = _loc2_;
         ++_reference;
         return _loc2_;
      }
      
      public static function printValue(param1:*, param2:String) : String
      {
         if(param2 == MonsterDebuggerConstants.TYPE_BYTEARRAY)
         {
            return param1["length"] + " bytes";
         }
         if(param1 == null)
         {
            return "null";
         }
         return String(param1);
      }
      
      private static function parseObject(param1:*, param2:String, param3:int = 1, param4:int = 5, param5:Boolean = true) : XML
      {
         var childXML:XML = null;
         var prop:* = undefined;
         var object:* = param1;
         var target:String = param2;
         var currentDepth:int = param3;
         var maxDepth:int = param4;
         var includeDisplayObjects:Boolean = param5;
         var rootXML:XML = <root/>;
         var nodeXML:XML = <node/>;
         var childType:String = "";
         var childTarget:String = "";
         var isXML:Boolean = false;
         var isXMLString:XML = new XML();
         var i:int = 0;
         var properties:Array = [];
         var isNumeric:Boolean = true;
         for(prop in object)
         {
            if(!(prop is int))
            {
               isNumeric = false;
            }
            properties.push(prop);
         }
         if(isNumeric)
         {
            properties.sort(Array.NUMERIC);
         }
         else
         {
            properties.sort(Array.CASEINSENSITIVE);
         }
         i = 0;
         while(i < properties.length)
         {
            childType = parseType(MonsterDebuggerDescribeType.get(object[properties[i]]).@name);
            childTarget = target + "." + properties[i];
            if(childType == MonsterDebuggerConstants.TYPE_STRING || childType == MonsterDebuggerConstants.TYPE_BOOLEAN || childType == MonsterDebuggerConstants.TYPE_NUMBER || childType == MonsterDebuggerConstants.TYPE_INT || childType == MonsterDebuggerConstants.TYPE_UINT || childType == MonsterDebuggerConstants.TYPE_FUNCTION)
            {
               isXML = false;
               isXMLString = new XML();
               if(childType == MonsterDebuggerConstants.TYPE_STRING)
               {
                  try
                  {
                     isXMLString = new XML(object[properties[i]]);
                     if(!isXMLString.hasSimpleContent() && isXMLString.children().length() > 0)
                     {
                        isXML = true;
                     }
                  }
                  catch(error:TypeError)
                  {
                  }
               }
               if(!isXML)
               {
                  childXML = <node/>;
                  childXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  childXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  childXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  childXML.@label = properties[i] + " (" + childType + ") = " + printValue(object[properties[i]],childType);
                  childXML.@name = properties[i];
                  childXML.@type = childType;
                  childXML.@value = printValue(object[properties[i]],childType);
                  childXML.@target = childTarget;
                  nodeXML.appendChild(childXML);
               }
               else
               {
                  childXML = <node/>;
                  childXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  childXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  childXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  childXML.@label = properties[i] + " (" + childType + ")";
                  childXML.@name = properties[i];
                  childXML.@type = childType;
                  childXML.@value = "";
                  childXML.@target = childTarget;
                  childXML.appendChild(parseXML(object[properties[i]],childTarget,currentDepth + 1,maxDepth).children());
                  nodeXML.appendChild(childXML);
               }
            }
            else
            {
               childXML = <node/>;
               childXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
               childXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               childXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               childXML.@label = properties[i] + " (" + childType + ")";
               childXML.@name = properties[i];
               childXML.@type = childType;
               childXML.@value = "";
               childXML.@target = childTarget;
               childXML.appendChild(parse(object[properties[i]],childTarget,currentDepth + 1,maxDepth,includeDisplayObjects).children());
               nodeXML.appendChild(childXML);
            }
            i++;
         }
         rootXML.appendChild(nodeXML.children());
         return rootXML;
      }
      
      public static function parse(param1:*, param2:String = "", param3:int = 1, param4:int = 5, param5:Boolean = true) : XML
      {
         var _loc8_:XML = null;
         var _loc13_:int = 0;
         var _loc14_:XML = null;
         var _loc6_:XML = <root/>;
         var _loc7_:XML = <node/>;
         var _loc9_:XML = new XML();
         var _loc10_:String = "";
         var _loc11_:String = "";
         var _loc12_:Boolean = false;
         if(param4 != -1 && param3 > param4)
         {
            return _loc6_;
         }
         if(param1 == null)
         {
            _loc8_ = <node/>;
            _loc8_.@icon = MonsterDebuggerConstants.ICON_WARNING;
            _loc8_.@label = "Null object";
            _loc8_.@name = "Null object";
            _loc8_.@type = MonsterDebuggerConstants.TYPE_WARNING;
            _loc7_.appendChild(_loc8_);
            _loc10_ = "null";
         }
         else
         {
            _loc9_ = MonsterDebuggerDescribeType.get(param1);
            _loc10_ = parseType(_loc9_.@name);
            _loc11_ = parseType(_loc9_.@base);
            _loc12_ = Boolean(_loc9_.@isDynamic);
            if(param1 is Class)
            {
               _loc7_.appendChild(parseClass(param1,param2,_loc9_,param3,param4,param5).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_XML)
            {
               _loc7_.appendChild(parseXML(param1,param2 + "." + "children()",param3,param4).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_XMLLIST)
            {
               _loc8_ = <node/>;
               _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
               _loc8_.@type = MonsterDebuggerConstants.TYPE_UINT;
               _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READONLY;
               _loc8_.@target = param2 + "." + "length";
               _loc8_.@label = "length" + " (" + MonsterDebuggerConstants.TYPE_UINT + ") = " + param1.length();
               _loc8_.@name = "length";
               _loc8_.@value = param1.length();
               _loc13_ = 0;
               while(_loc13_ < param1.length())
               {
                  _loc8_.appendChild(parseXML(param1[_loc13_],param2 + "." + String(_loc13_) + ".children()",param3,param4).children());
                  _loc13_++;
               }
               _loc7_.appendChild(_loc8_);
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_STRING || _loc10_ == MonsterDebuggerConstants.TYPE_BOOLEAN || _loc10_ == MonsterDebuggerConstants.TYPE_NUMBER || _loc10_ == MonsterDebuggerConstants.TYPE_INT || _loc10_ == MonsterDebuggerConstants.TYPE_UINT)
            {
               _loc7_.appendChild(parseBasics(param1,param2,_loc10_).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_ARRAY || _loc10_.indexOf(MonsterDebuggerConstants.TYPE_VECTOR) == 0)
            {
               _loc7_.appendChild(parseArray(param1,param2,param3,param4).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_OBJECT)
            {
               _loc7_.appendChild(parseObject(param1,param2,param3,param4,param5).children());
            }
            else
            {
               _loc7_.appendChild(parseClass(param1,param2,_loc9_,param3,param4,param5).children());
            }
         }
         if(param3 == 1)
         {
            _loc14_ = <node/>;
            _loc14_.@icon = MonsterDebuggerConstants.ICON_ROOT;
            _loc14_.@label = "(" + _loc10_ + ")";
            _loc14_.@type = _loc10_;
            _loc14_.@target = param2;
            _loc14_.appendChild(_loc7_.children());
            _loc6_.appendChild(_loc14_);
         }
         else
         {
            _loc6_.appendChild(_loc7_.children());
         }
         return _loc6_;
      }
      
      public static function parseType(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1.indexOf("::") != -1)
         {
            param1 = param1.substring(param1.indexOf("::") + 2,param1.length);
         }
         if(param1.indexOf("::") != -1)
         {
            _loc2_ = param1.substring(0,param1.indexOf("<") + 1);
            _loc3_ = param1.substring(param1.indexOf("::") + 2,param1.length);
            param1 = _loc2_ + _loc3_;
         }
         param1 = param1.replace("()","");
         return param1.replace(MonsterDebuggerConstants.TYPE_METHOD,MonsterDebuggerConstants.TYPE_FUNCTION);
      }
      
      public static function getReference(param1:String) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:String = null;
         if(param1.charAt(0) != "#")
         {
            return null;
         }
         for(_loc2_ in _references)
         {
            _loc3_ = _references[_loc2_];
            if(_loc3_ == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function pause() : Boolean
      {
         try
         {
            System.pause();
            return true;
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public static function getMemory() : uint
      {
         return System.totalMemory;
      }
      
      public static function getObject(param1:*, param2:String = "", param3:int = 0) : *
      {
         var i:int;
         var splitted:Array;
         var object:*;
         var index:Number = NaN;
         var base:* = param1;
         var target:String = param2;
         var parent:int = param3;
         if(target == null || target == "")
         {
            return base;
         }
         if(target.charAt(0) == "#")
         {
            return getReference(target);
         }
         object = base;
         splitted = target.split(MonsterDebuggerConstants.DELIMITER);
         i = 0;
         while(i < splitted.length - parent)
         {
            if(splitted[i] != "")
            {
               try
               {
                  if(splitted[i] == "children()")
                  {
                     object = object.children();
                  }
                  else if(object is DisplayObjectContainer && splitted[i].indexOf("getChildAt(") == 0)
                  {
                     index = Number(splitted[i].substring(11,splitted[i].indexOf(")",11)));
                     object = DisplayObjectContainer(object).getChildAt(index);
                  }
                  else
                  {
                     object = object[splitted[i]];
                  }
               }
               catch(e:Error)
               {
                  break;
               }
            }
            i++;
         }
         return object;
      }
      
      public static function stackTrace() : XML
      {
         var childXML:XML = null;
         var stack:String = null;
         var lines:Array = null;
         var i:int = 0;
         var s:String = null;
         var bracketIndex:int = 0;
         var methodIndex:int = 0;
         var classname:String = null;
         var method:String = null;
         var file:String = null;
         var line:String = null;
         var functionXML:XML = null;
         var rootXML:XML = <root/>;
         childXML = <node/>;
         try
         {
            throw new Error();
         }
         catch(e:Error)
         {
            stack = e.getStackTrace();
            if(stack == null || stack == "")
            {
               return <root><error>Stack unavailable</error></root>;
            }
            stack = stack.split("\t").join("");
            lines = stack.split("\n");
            if(lines.length <= 4)
            {
               return <root><error>Stack to short</error></root>;
            }
            lines.shift();
            lines.shift();
            lines.shift();
            lines.shift();
            i = 0;
            while(i < lines.length)
            {
               s = lines[i];
               s = s.substring(3,s.length);
               bracketIndex = s.indexOf("[");
               methodIndex = s.indexOf("/");
               if(bracketIndex == -1)
               {
                  bracketIndex = s.length;
               }
               if(methodIndex == -1)
               {
                  methodIndex = bracketIndex;
               }
               classname = MonsterDebuggerUtils.parseType(s.substring(0,methodIndex));
               method = "";
               file = "";
               line = "";
               if(methodIndex != s.length && methodIndex != bracketIndex)
               {
                  method = s.substring(methodIndex + 1,bracketIndex);
               }
               if(bracketIndex != s.length)
               {
                  file = s.substring(bracketIndex + 1,s.lastIndexOf(":"));
                  line = s.substring(s.lastIndexOf(":") + 1,s.length - 1);
               }
               functionXML = <node/>;
               functionXML.@classname = classname;
               functionXML.@method = method;
               functionXML.@file = file;
               functionXML.@line = line;
               childXML.appendChild(functionXML);
               i++;
            }
         }
         rootXML.appendChild(childXML.children());
         return rootXML;
      }
      
      public static function isDisplayObject(param1:*) : Boolean
      {
         return param1 is DisplayObject || param1 is DisplayObjectContainer;
      }
      
      private static function parseBasics(param1:*, param2:String, param3:String, param4:int = 1, param5:int = 5) : XML
      {
         var object:* = param1;
         var target:String = param2;
         var type:String = param3;
         var currentDepth:int = param4;
         var maxDepth:int = param5;
         var rootXML:XML = <root/>;
         var nodeXML:XML = <node/>;
         var isXML:Boolean = false;
         var isXMLString:XML = new XML();
         if(type == MonsterDebuggerConstants.TYPE_STRING)
         {
            try
            {
               isXMLString = new XML(object);
               isXML = !isXMLString.hasSimpleContent() && isXMLString.children().length() > 0;
            }
            catch(error:TypeError)
            {
            }
         }
         if(!isXML)
         {
            nodeXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
            nodeXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            nodeXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            nodeXML.@label = "(" + type + ") = " + printValue(object,type);
            nodeXML.@name = "";
            nodeXML.@type = type;
            nodeXML.@value = printValue(object,type);
            nodeXML.@target = target;
         }
         else
         {
            nodeXML.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
            nodeXML.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            nodeXML.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            nodeXML.@label = "(" + MonsterDebuggerConstants.TYPE_XML + ")";
            nodeXML.@name = "";
            nodeXML.@type = MonsterDebuggerConstants.TYPE_XML;
            nodeXML.@value = "";
            nodeXML.@target = target;
            nodeXML.appendChild(parseXML(isXMLString,target + "." + "children()",currentDepth,maxDepth).children());
         }
         rootXML.appendChild(nodeXML);
         return rootXML;
      }
   }
}

