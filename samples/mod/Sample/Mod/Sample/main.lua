--[[
Title: 
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Sample/main.lua");
local Sample = commonlib.gettable("Mod.sample");

------------------------------------------------------------
]]
local Sample = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.Sample"));

function Sample:ctor()
	self.inited = nil;
end

function Sample:init()
	if(not self.inited) then
		self.inited = true;
	end
end

function Sample:OnLogin()
	echo("this is called on login!");
end

function Sample:OnWorldLoad()
	
end
