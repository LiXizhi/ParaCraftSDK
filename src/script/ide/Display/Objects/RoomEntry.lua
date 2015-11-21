--[[
Title: RoomEntry
Author(s): Leio
Date: 2009/5/6
Desc: 可种植的植物
RoomEntry --> Building3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
RoomEntry can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/RoomEntry.lua");
local pet = CommonCtrl.Display.Objects.RoomEntry:new()
pet:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local RoomEntry = commonlib.inherit(CommonCtrl.Display.Objects.Building3D,{
	CLASSTYPE = "RoomEntry"
});  
commonlib.setfield("CommonCtrl.Display.Objects.RoomEntry",RoomEntry);
function RoomEntry:Init()
	self:ClearEventPools();
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------

function RoomEntry:__Clone()
	return CommonCtrl.Display.Objects.RoomEntry:new();
end
