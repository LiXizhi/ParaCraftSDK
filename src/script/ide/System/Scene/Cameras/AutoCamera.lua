--[[
Title: AutoCamera
Author(s): LiXizhi@yeah.net
Date: 2015/8/19
Desc: a singleton wrapper to the C++ CAutoCamera class. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Cameras/AutoCamera.lua");
local Cameras = commonlib.gettable("System.Scene.Cameras");
echo(Cameras:GetCurrent():GetViewMatrix());
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Cameras/Camera.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local AutoCamera = commonlib.inherit(commonlib.gettable("System.Scene.Cameras.Camera"), commonlib.gettable("System.Scene.Cameras.AutoCamera"));

AutoCamera:Property({"Name", "AutoCamera"});

function AutoCamera:ctor()
end

function AutoCamera:GetViewProjMatrix()
	return ParaCamera.GetAttributeObject():GetField("ViewProjMatrix", self.viewprojMatrix);
end

function AutoCamera:GetViewMatrix()
	return ParaCamera.GetAttributeObject():GetField("ViewMatrix", self.viewMatrix);
end

function AutoCamera:GetProjMatrix()
	return ParaCamera.GetAttributeObject():GetField("ProjMatrix", self.projMatrix);
end

AutoCamera:InitSingleton();
