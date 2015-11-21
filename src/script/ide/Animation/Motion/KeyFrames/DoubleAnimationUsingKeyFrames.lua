--[[
Title: DoubleAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/DoubleAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeyFrame.lua");
local DoubleAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.Motion.AnimationUsingKeyFrames, {
	property = "DoubleAnimationUsingKeyFrames",
	name = "DoubleAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:doubleAnimationUsingKeyFrames",
});
commonlib.setfield("CommonCtrl.Animation.Motion.DoubleAnimationUsingKeyFrames",DoubleAnimationUsingKeyFrames);
function DoubleAnimationUsingKeyFrames:UpdateTime(frame)
	if(not frame)then return; end
end
--------------------------------------------------------------------------
-- LinearDoubleKeyFrame
local LinearDoubleKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "LinearKeyFrame",
	property = "LinearDoubleKeyFrame",
	name = "LinearDoubleKeyFrame_instance",
	mcmlTitle = "pe:linearDoubleKeyFrame",
	SimpleEase = 0,
});
commonlib.setfield("CommonCtrl.Animation.Motion.LinearDoubleKeyFrame",LinearDoubleKeyFrame );
-- DiscreteDoubleKeyFrame
local DiscreteDoubleKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscreteDoubleKeyFrame",
	name = "DiscreteDoubleKeyFrame_instance",
	mcmlTitle = "pe:discreteDoubleKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.Motion.DiscreteDoubleKeyFrame",DiscreteDoubleKeyFrame );

