--[[
Title: Point3DAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/23
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/Point3DAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeyFrame.lua");

local Point3DAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.Motion.AnimationUsingKeyFrames, {
	property = "Point3DAnimationUsingKeyFrames",
	name = "Point3DAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:point3DAnimationUsingKeyFrames",
	SurpportProperty = {"SetPosition","ParaCamera_SetLookAtPos","ParaCamera_SetEyePos","SetProtagonistPosition","RunTo"},
});
commonlib.setfield("CommonCtrl.Animation.Motion.Point3DAnimationUsingKeyFrames",Point3DAnimationUsingKeyFrames);
function Point3DAnimationUsingKeyFrames:UpdateTime(frame)
	if(not frame)then return; end
end
--------------------------------------------------------------------------
-- LinearPoint3DKeyFrame
local LinearPoint3DKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "LinearKeyFrame",
	property = "LinearPoint3DKeyFrame",
	name = "LinearPoint3DKeyFrame_instance",
	mcmlTitle = "pe:linearPoint3DKeyFrame",
	SimpleEase = 0,
});
commonlib.setfield("CommonCtrl.Animation.Motion.LinearPoint3DKeyFrame",LinearPoint3DKeyFrame );
function LinearPoint3DKeyFrame:SetValue(v)
	if(not v)then return; end
	local __,__,x,y,z = string.find(v,"(.+),(.+),(.+)");
	x = tonumber(x);
	y = tonumber(y);
	z = tonumber(z);
	v = {[1] = x,[2] = y,[3] = z}
	self.Value = v;
end
function LinearPoint3DKeyFrame:ReverseToMcml()
	if(not self.Value or not self.KeyTime)then return "" end
	local node_value = string.format("%s,%s,%s",self.Value[1],self.Value[2],self.Value[3]);
	local p_node = "\r\n";
	local SimpleEase = "";
	if(self.SimpleEase)then
		SimpleEase = string.format([[SimpleEase="%s"]],self.SimpleEase);
	end
	local node = string.format([[<%s KeyTime="%s" Value="%s" %s />%s]],self.mcmlTitle,self.KeyTime,node_value,SimpleEase,p_node);
	return node;
end
---------------------------------------------------------------------------
-- DiscretePoint3DKeyFrame
local DiscretePoint3DKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscretePoint3DKeyFrame",
	name = "DiscretePoint3DKeyFrame_instance",
	mcmlTitle = "pe:discretePoint3DKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.Motion.DiscretePoint3DKeyFrame",DiscretePoint3DKeyFrame );
function DiscretePoint3DKeyFrame:SetValue(v)
	if(not v)then return; end
	local __,__,x,y,z = string.find(v,"(.+),(.+),(.+)");
	x = tonumber(x);
	y = tonumber(y);
	z = tonumber(z);
	v = {[1] = x,[2] = y,[3] = z}
	self.Value = v;
end
function DiscretePoint3DKeyFrame:ReverseToMcml()
	if(not self.Value or not self.KeyTime)then return "" end
	local node_value = string.format("%s,%s,%s",self.Value[1],self.Value[2],self.Value[3]);
	local p_node = "\r\n";
	local SimpleEase = "";
	if(self.SimpleEase)then
		SimpleEase = string.format([[SimpleEase="%s"]],self.SimpleEase);
	end
	local node = string.format([[<%s KeyTime="%s" Value="%s" %s />%s]],self.mcmlTitle,self.KeyTime,node_value,SimpleEase,p_node);
	return node;
end