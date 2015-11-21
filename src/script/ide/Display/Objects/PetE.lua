--[[
Title: PetE
Author(s): Leio
Date: 2009/5/6
Desc: ¸ß¼¶³èÎï£¨×øÆï£©
PetE --> Actor3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
PetE can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/PetE.lua");
local pet = CommonCtrl.Display.Objects.PetE:new()
pet:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
local PetE = commonlib.inherit(CommonCtrl.Display.Objects.Actor3D,{
	CLASSTYPE = "PetE"
});  
commonlib.setfield("CommonCtrl.Display.Objects.PetE",PetE);
function PetE:Init()
	self:ClearEventPools();
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------

function PetE:__Clone()
	return CommonCtrl.Display.Objects.PetE:new();
end
