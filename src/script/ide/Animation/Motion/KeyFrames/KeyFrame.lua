--[[
Title: KeyFrame
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeyFrame.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TimeSpan.lua");
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
	ToFrame = nil,
	-- it is activated at first frame
	Activate = nil,
	-- used by AnimationUsingKeyFrames
	IsSelected = false,
}
commonlib.setfield("CommonCtrl.Animation.Motion.KeyFrame",KeyFrame);
function KeyFrame:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Initialization();
	return o
end
function KeyFrame:Initialization()
	self.name = ParaGlobal.GenerateUniqueID();
	if(self.KeyTime)then
		self:SetKeyTime(self.KeyTime)
	end
end
function KeyFrame:SetParent(v)
	self.ParentKeyFrames = v;
end
function KeyFrame:GetParent()
	return self.ParentKeyFrames;
end
function KeyFrame:SetActivate(v)
	self.Activate = v;
end
function KeyFrame:GetActivate(v)
	return self.Activate;
end
function KeyFrame:SetValue(v)
	self.Value = v;
end
function KeyFrame:GetValue()
	return self.Value;
end
function KeyFrame:SetKeyTime(v)
	if(not v)then return; end
	self.KeyTime = v;
	self.ToFrame = self:GetFrames();
end
function KeyFrame:SetKeyFrame(v)
	if(not v)then return; end	
	self.ToFrame = v;
	self.KeyTime = CommonCtrl.Animation.Motion.TimeSpan.GetTime(v);
end
function KeyFrame:GetKeyFrame()
	return self:GetFrames();
end
function KeyFrame:GetKeyTime()
	return self.KeyTime;
end
function KeyFrame:GetFrames()
	return CommonCtrl.Animation.Motion.TimeSpan.GetFrames(self.KeyTime);
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
function KeyFrame:Clone()
	local new_keyFrame = commonlib.deepcopy(self);
	return new_keyFrame;
end