--[[
Title: ObjectAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/24
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/ObjectAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeyFrame.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TimeSpan.lua");
local ObjectAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.Motion.AnimationUsingKeyFrames, {
	property = "ObjectAnimationUsingKeyFrames",
	name = "ObjectAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:objectAnimationUsingKeyFrames",
});  
commonlib.setfield("CommonCtrl.Animation.Motion.ObjectAnimationUsingKeyFrames",ObjectAnimationUsingKeyFrames);
function ObjectAnimationUsingKeyFrames:UpdateTime(frame)
	if(not frame)then return; end
	
end
--------------------------------------------------------------------------
-- DiscreteObjectKeyFrame
local DiscreteObjectKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscreteObjectKeyFrame",
	name = "DiscreteObjectKeyFrame_instance",
	mcmlTitle = "pe:discreteObjectKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.Motion.DiscreteObjectKeyFrame ",DiscreteObjectKeyFrame );
function DiscreteObjectKeyFrame:ReverseToMcml()
	if(not self.Value or not self.KeyTime)then return "\r\n" end
	local node_value = commonlib.serialize(self.Value);
	local node = string.format([[<pe:discreteObjectKeyFrame KeyTime="%s">%s</pe:discreteObjectKeyFrame>]],self.KeyTime,"\r\n"..node_value);
	return node;
end