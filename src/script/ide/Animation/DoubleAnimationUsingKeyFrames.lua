--[[
Title: DoubleAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/DoubleAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/KeyFrame.lua");

local DoubleAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.AnimationUsingKeyFrames, {
	property = "DoubleAnimationUsingKeyFrames",
	name = "DoubleAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:doubleAnimationUsingKeyFrames",
	SurpportProperty = {"x","y","scaleX","scaleY","rotation","alpha"},
});
commonlib.setfield("CommonCtrl.Animation.DoubleAnimationUsingKeyFrames",DoubleAnimationUsingKeyFrames);
-- override parent InsertFirstKeyFrame
function DoubleAnimationUsingKeyFrames:InsertFirstKeyFrame()
	local Value =CommonCtrl.Animation.Util.GetDisplayObjProperty(self) ;
	local keyframe = CommonCtrl.Animation.LinearDoubleKeyFrame:new{
		KeyTime = "00:00:00",
		Value = Value,
	}
	commonlib.insertArrayItem(self.keyframes, 1, keyframe);
end
--------------------------------------------------------------------------
-- LinearDoubleKeyFrame
local LinearDoubleKeyFrame  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "LinearKeyFrame",
	property = "LinearDoubleKeyFrame",
	name = "LinearDoubleKeyFrame_instance",
	mcmlTitle = "pe:linearDoubleKeyFrame",
	SimpleEase = 0,
});
commonlib.setfield("CommonCtrl.Animation.LinearDoubleKeyFrame",LinearDoubleKeyFrame );
-- DiscreteDoubleKeyFrame
local DiscreteDoubleKeyFrame  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscreteDoubleKeyFrame",
	name = "DiscreteDoubleKeyFrame_instance",
	mcmlTitle = "pe:discreteDoubleKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.DiscreteDoubleKeyFrame",DiscreteDoubleKeyFrame );