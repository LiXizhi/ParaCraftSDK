--[[
Title: StringAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/22
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/StringAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/KeyFrame.lua");

local StringAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.AnimationUsingKeyFrames, {
	property = "StringAnimationUsingKeyFrames",
	name = "StringAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:stringAnimationUsingKeyFrames",
	-- text: text property with 2d object
	-- visible: visible property with 2d or 3d object
	-- curtain: it is a curtain which enabled between a clip show end and next clip show start
	-- sound: 
	-- headon_speech: text property with 3d object
	-- movieCaption: caption property with clip
	SurpportProperty = {"text","visible","curtain","sound","headon_speech","movieCaption"},
});
commonlib.setfield("CommonCtrl.Animation.StringAnimationUsingKeyFrames",StringAnimationUsingKeyFrames);
-- override parent InsertFirstKeyFrame
function StringAnimationUsingKeyFrames:InsertFirstKeyFrame()
	--local Value =CommonCtrl.Animation.Util.GetDisplayObjProperty(self) ;
	local keyframe = CommonCtrl.Animation.DiscreteStringKeyFrame:new{
		KeyTime = "00:00:00",
		Value = nil,
	}
	commonlib.insertArrayItem(self.keyframes, 1, keyframe);
end

function StringAnimationUsingKeyFrames:getValue(time)
	local curKeyframe = self:getCurrentKeyframe(time);
	if(not curKeyframe)then return; end
	local begin = curKeyframe:GetValue();
	if(not begin)then return; end
	local nextKeyframe = self:getNextKeyframe(time);
	if (not nextKeyframe or nextKeyframe.parentProperty =="DiscreteKeyFrame") then	
			
		return begin,curKeyframe,time;
	end
end

--------------------------------------------------------------------------
-- DiscreteStringKeyFrame
--------------------------------------------------------------------------
local DiscreteStringKeyFrame  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscreteStringKeyFrame",
	name = "DiscreteStringKeyFrame_instance",
	mcmlTitle = "pe:discreteStringKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.DiscreteStringKeyFrame",DiscreteStringKeyFrame );

--------------------------------------------------------------------------
-- StringAnimationUsingKeyFrames_Value
--------------------------------------------------------------------------
local StringAnimationUsingKeyFrames_Value  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "StringAnimationUsingKeyFrames_Value",
	property = "StringAnimationUsingKeyFrames_Value",
	name = "StringAnimationUsingKeyFrames_Value_instance",
	mcmlTitle = "pe:stringAnimationUsingKeyFrames_Value",
});
commonlib.setfield("CommonCtrl.Animation.StringAnimationUsingKeyFrames_Value",StringAnimationUsingKeyFrames_Value );
