--[[
Title: Point3DAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/23
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Point3DAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/KeyFrame.lua");

local Point3DAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.AnimationUsingKeyFrames, {
	property = "Point3DAnimationUsingKeyFrames",
	name = "Point3DAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:point3DAnimationUsingKeyFrames",
	SurpportProperty = {"SetPosition","ParaCamera_SetLookAtPos","ParaCamera_SetEyePos","SetProtagonistPosition","RunTo"},
});
commonlib.setfield("CommonCtrl.Animation.Point3DAnimationUsingKeyFrames",Point3DAnimationUsingKeyFrames);
-- override parent InsertFirstKeyFrame
function Point3DAnimationUsingKeyFrames:InsertFirstKeyFrame()
	local Value =CommonCtrl.Animation.Util.GetDisplayObjProperty(self) ;
	local keyframe = CommonCtrl.Animation.LinearPoint3DKeyFrame:new{
		KeyTime = "00:00:00",
		Value = Value,
	}
	commonlib.insertArrayItem(self.keyframes, 1, keyframe);
end
function Point3DAnimationUsingKeyFrames:getValue(time)
	local curKeyframe = self:getCurrentKeyframe(time);
	local index = 1;
	local x = self:getValue_result(time,index)
	index = index + 1;
	local y = self:getValue_result(time,index)
	index = index + 1;
	local z = self:getValue_result(time,index)
	--commonlib.echo({"x",x,"y",y,"z",z});
	return  {[1] = x,[2] = y,[3] = z},curKeyframe,time
end
--------------------------------------------------------------------------
-- LinearPoint3DKeyFrame
local LinearPoint3DKeyFrame  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "LinearKeyFrame",
	property = "LinearPoint3DKeyFrame",
	name = "LinearPoint3DKeyFrame_instance",
	mcmlTitle = "pe:linearPoint3DKeyFrame",
	SimpleEase = 0,
});
commonlib.setfield("CommonCtrl.Animation.LinearPoint3DKeyFrame",LinearPoint3DKeyFrame );
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
local DiscretePoint3DKeyFrame  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscretePoint3DKeyFrame",
	name = "DiscretePoint3DKeyFrame_instance",
	mcmlTitle = "pe:discretePoint3DKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.DiscretePoint3DKeyFrame",DiscretePoint3DKeyFrame );
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