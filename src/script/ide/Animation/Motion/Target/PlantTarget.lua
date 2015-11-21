--[[
Title: PlantTarget
Author(s): Leio Zhang
Date: 2008/10/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/PlantTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BuildingTarget.lua");
NPL.load("(gl)script/ide/commonlib.lua");
local PlantTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BuildingTarget, {
	Property = "PlantTarget",
});
commonlib.setfield("CommonCtrl.Animation.Motion.PlantTarget",PlantTarget);
