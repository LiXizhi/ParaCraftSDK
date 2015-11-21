--[[
Title: Pet
Author(s): Leio
Date: 2009/5/6
Desc: µÍ¼¶³èÎï£¨¸úËæ£©
Pet --> Actor3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
Pet can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/Pet.lua");
local pet = CommonCtrl.Display.Objects.Pet:new()
pet:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
local Pet = commonlib.inherit(CommonCtrl.Display.Objects.Actor3D,{
	CLASSTYPE = "Pet"
});  
commonlib.setfield("CommonCtrl.Display.Objects.Pet",Pet);
function Pet:Init()
	self:ClearEventPools();
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------

function Pet:__Clone()
	return CommonCtrl.Display.Objects.Pet:new();
end
