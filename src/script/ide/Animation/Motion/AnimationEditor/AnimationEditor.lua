--[[
Title: AnimationEditor
Author(s): Leio Zhang
Date: 2008/10/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/AnimationEditor/AnimationEditor.lua");
------------------------------------------------------------
--]]
local AnimationEditor_Config = {
	FrameWidth = 10,
	FrameHeight = 20,
	TimeLineDefaultFrame = 19800, -- 10 minutes
	TimeRank = {1/16,1/8,1/4,1/2,1,2,4,8},
	TimeRankStartIndex = 4;
	framerate = 33,
}
commonlib.setfield("CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config",AnimationEditor_Config);
