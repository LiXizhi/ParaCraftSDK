--[[
Title: Object
Author(s): Leio
Date: 2008/12/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Object.lua");
------------------------------------------------------------
]]
local Object = {
	
}
commonlib.setfield("CommonCtrl.Display.Object",Object);
function Object:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:GenUID();
	return o
end
function Object:GenUID()
	local uid = ParaGlobal.GenerateUniqueID();
	self:SetUID(uid);
end
function Object:GetUID()
	local uid = self.uid;
	return tostring(uid);
end
function Object:SetUID(v)
	v = tostring(v);
	self.uid = v;
end