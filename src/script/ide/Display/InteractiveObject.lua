--[[
Title: InteractiveObject
Author(s): Leio
Date: 2009/1/13
Desc: 
InteractiveObject --> DisplayObject --> EventDispatcher --> Object
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/DisplayObject.lua");
local InteractiveObject = commonlib.inherit(CommonCtrl.Display.DisplayObject,{
	
});  
commonlib.setfield("CommonCtrl.Display.InteractiveObject",InteractiveObject);
