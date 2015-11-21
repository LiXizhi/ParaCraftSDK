--[[
Title: KeyFrame
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/KeyFrame.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
local KeyFrame = {
	parentProperty = "KeyFrame",
	property = "KeyFrame",
	name = "KeyFrame_instance",
	mcmlTitle = "pe:keyFrame",
	Value = nil,
	KeyTime = nil,
	index = nil,
	Milliseconds = nil,
	SimpleEase = nil,
}
commonlib.setfield("CommonCtrl.Animation.KeyFrame",KeyFrame);
function KeyFrame:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end
function KeyFrame:SetValue(v)
	if(not v)then return; end
	self.Value = v;
end
function KeyFrame:GetValue()
	return self.Value;
end
function KeyFrame:SetKeyTime(v)
	if(not v)then return; end
	self.KeyTime = v;
end
function KeyFrame:GetKeyTime()
	return self.KeyTime;
end
function KeyFrame:GetFrames()
	return CommonCtrl.Animation.TimeSpan.GetFrames(self.KeyTime);
end
function KeyFrame:ReverseToMcml()
	if(not self.Value or not self.KeyTime)then return "" end
	local node_value = self.Value;
	local p_node = "\r\n";
	local SimpleEase = "";
	if(self.SimpleEase)then
		SimpleEase = "SimpleEase="..self.SimpleEase;
	end
	local node = string.format([[<%s KeyTime="%s" Value="%s" %s />%s]],self.mcmlTitle,self.KeyTime,node_value,SimpleEase,p_node);
	return node;
end