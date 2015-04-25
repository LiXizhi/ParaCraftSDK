--[[
Title: DemoGUI
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/DemoGUI.lua");
local DemoGUI = commonlib.gettable("Mod.Test.DemoGUI");
------------------------------------------------------------
]]
local DemoGUI = commonlib.inherit(nil,commonlib.gettable("Mod.Test.DemoGUI"));

function DemoGUI:ctor()
end

function DemoGUI:init()
	LOG.std(nil, "info", "DemoGUI", "init");
end

function DemoGUI:ShowMyGUI()
	if(not self.page) then
		-- create if not created before
		NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
		self.page = Map3DSystem.mcml.PageCtrl:new({url="Mod/Test/DemoGUI.html"});		
		self.page:Create("DemoGUI", nil, "_lt", 10, 10, 200, 64);
	end
end

function DemoGUI:OnWorldLoad()
	self:ShowMyGUI();
end

function DemoGUI:OnLeaveWorld()
end