--[[
Title: Screen
Author(s): LiXizhi
Date: 2015/8/20
Desc: a singleton class for current screen. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Screen.lua");
local Screen = commonlib.gettable("System.Windows.Screen");
echo({Screen:GetWidth(), Screen:GetHeight()})
------------------------------------------------------------
]]

local Screen = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.Screen"));
Screen:Property({"Name", "Screen"});
Screen:Property({"m_width", nil, "GetWidth"});
Screen:Property({"m_height", nil, "GetHeight"});

function Screen:ctor()
end

function Screen:GetGUIRoot()
	if(not self.root or not self.root:IsValid()) then
		self.root = ParaUI.GetUIObject("root");
	end
	return self.root;
end

function Screen:GetWidth()
	return self:GetGUIRoot().width;
end

function Screen:GetHeight()
	return self:GetGUIRoot().height;
end

Screen:InitSingleton();