--[[
Title: StringAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/22
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/StringAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeyFrame.lua");

local StringAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.Motion.AnimationUsingKeyFrames, {
	property = "StringAnimationUsingKeyFrames",
	name = "StringAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:stringAnimationUsingKeyFrames",
});
commonlib.setfield("CommonCtrl.Animation.Motion.StringAnimationUsingKeyFrames",StringAnimationUsingKeyFrames);
function StringAnimationUsingKeyFrames:UpdateTime(frame)
	if(not frame)then return; end
end
--------------------------------------------------------------------------
-- DiscreteStringKeyFrame
--------------------------------------------------------------------------
local DiscreteStringKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscreteStringKeyFrame",
	name = "DiscreteStringKeyFrame_instance",
	mcmlTitle = "pe:discreteStringKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.Motion.DiscreteStringKeyFrame",DiscreteStringKeyFrame );

--------------------------------------------------------------------------
-- StringAnimationUsingKeyFrames_Value
--------------------------------------------------------------------------
local StringAnimationUsingKeyFrames_Value  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "StringAnimationUsingKeyFrames_Value",
	property = "StringAnimationUsingKeyFrames_Value",
	name = "StringAnimationUsingKeyFrames_Value_instance",
	mcmlTitle = "pe:stringAnimationUsingKeyFrames_Value",
});
commonlib.setfield("CommonCtrl.Animation.Motion.StringAnimationUsingKeyFrames_Value",StringAnimationUsingKeyFrames_Value );
