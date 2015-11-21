--[[
Title: RotateDirection
Author(s): Leio Zhang
Date: 2008/4/14
Desc: Based on Actionscript library 
	The RotateDirection class provides constant values for rotation behavior during a tween. 
	Used by the <code>rotateDirection</code> property of the fl.motion.Keyframe class. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/RotateDirection.lua");
------------------------------------------------------------
--]]
local RotateDirection = {
	--Chooses a direction of rotation that requires the least amount of turning.
	AUTO = "auto",
	--Prevents the object from rotating during a tween until the next keyframe is reached.
	NONE = "none",
	--Ensures that the object rotates clockwise during a tween to match the rotation of the object in the following keyframe. 
	CW = "cw",
	-- Ensures that the object rotates counterclockwise during a tween to match the rotation of the object in the following keyframe.
	CCW = "ccw",
	
	}
commonlib.setfield("CommonCtrl.Motion.RotateDirection",RotateDirection);