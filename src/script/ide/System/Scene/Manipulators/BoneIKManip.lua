--[[
Title: BoneIKManip 
Author(s): LiXizhi@yeah.net
Date: 2015/9/12
Desc: BoneIKManip is manipulator for two bone IK. 
NOT IMPLEMENTED now, the TranslateManip is used instead in BonesManip.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/BoneIKManip.lua");
local BoneIKManip = commonlib.gettable("System.Scene.Manipulators.BoneIKManip");
local manip = BoneIKManip:new():init();
manip:SetPosition(x,y,z);
------------------------------------------------------------
]]
