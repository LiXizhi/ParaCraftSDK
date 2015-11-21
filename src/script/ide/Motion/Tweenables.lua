--[[
Title: Tweenables
Author(s): Leio Zhang
Date: 2008/4/14
Desc: Based on Actionscript library 
The Tweenables class provides constant values for the names of animation properties used in the Motion and Keyframe classes.  
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/Tweenables.lua");
------------------------------------------------------------
--]]
local Tweenables = {
	--Constant for the x property.
	X = "x",
	--Constant for the y property.
	Y = "y",
	SCALE_X = "scaleX",
	--Constant for the scaleX property.
	SCALE_Y = "scaleY",
	--Constant for the scaleY property.
	SKEW_X = "skewX",
	--Constant for the skewY property.
	SKEW_Y = "skewY",
	--Constant for the rotation property.
	ROTATION = "rotation",
	}
commonlib.setfield("CommonCtrl.Motion.Tweenables",Tweenables);