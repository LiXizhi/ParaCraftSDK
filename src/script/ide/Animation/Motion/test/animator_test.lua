--[[
Title: test Animator
Author(s): Leio Zhang
Date: 2008/10/15
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/test/animator_test.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClip.lua");

local test_root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
-------------layer_1
local layer_1 = CommonCtrl.Animation.Motion.LayerManager:new();
local doubleKeyFrames = CommonCtrl.Animation.Motion.DoubleAnimationUsingKeyFrames:new();


local d_frame = CommonCtrl.Animation.Motion.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:0.1",
	Value = 0,
}
doubleKeyFrames:addKeyframe(d_frame);
d_frame = CommonCtrl.Animation.Motion.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:0.5",
	Value = 20,
}
doubleKeyFrames:addKeyframe(d_frame);
d_frame = CommonCtrl.Animation.Motion.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:1.0",
	Value = 40,
}

doubleKeyFrames:addKeyframe(d_frame);
layer_1:AddChild(doubleKeyFrames);
-------------layer_2
local layer_2 = CommonCtrl.Animation.Motion.LayerManager:new();
doubleKeyFrames = CommonCtrl.Animation.Motion.DoubleAnimationUsingKeyFrames:new();


d_frame = CommonCtrl.Animation.Motion.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:00.2",
	Value = 0,
}
doubleKeyFrames:addKeyframe(d_frame);
d_frame = CommonCtrl.Animation.Motion.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:00.4",
	Value = 20,
}
doubleKeyFrames:addKeyframe(d_frame);
d_frame = CommonCtrl.Animation.Motion.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:01.5",
	Value = 40,
}
doubleKeyFrames:addKeyframe(d_frame);
layer_2:AddChild(doubleKeyFrames);
-------------------
test_root_mc:AddLayer(layer_1);
test_root_mc:AddLayer(layer_2);
test_root_mc:Draw();
--test_root_mc:Play();
