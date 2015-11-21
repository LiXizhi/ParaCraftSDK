--[[
Title: Building3D
Author(s): Leio
Date: 2009/1/13
Desc: 
Flower --> Building3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
Flower can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/Flower.lua");
local flower = CommonCtrl.Display.Objects.Flower:new()
flower:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local Flower = commonlib.inherit(CommonCtrl.Display.Objects.Building3D,{
	CLASSTYPE = "Flower"
});  
commonlib.setfield("CommonCtrl.Display.Objects.Flower",Flower);
function Flower:Init()
	self:ClearEventPools();
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------

function Flower:__Clone()
	return CommonCtrl.Display.Objects.Flower:new();
end
