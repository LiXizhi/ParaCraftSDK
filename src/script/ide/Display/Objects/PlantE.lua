--[[
Title: PlantE
Author(s): Leio
Date: 2009/5/6
Desc: 可种植的植物
PlantE --> Building3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
PlantE can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/PlantE.lua");
local pet = CommonCtrl.Display.Objects.PlantE:new()
pet:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local PlantE = commonlib.inherit(CommonCtrl.Display.Objects.Building3D,{
	CLASSTYPE = "PlantE"
});  
commonlib.setfield("CommonCtrl.Display.Objects.PlantE",PlantE);
function PlantE:Init()
	self:ClearEventPools();
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------

function PlantE:__Clone()
	return CommonCtrl.Display.Objects.PlantE:new();
end
