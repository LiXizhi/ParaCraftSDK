--[[
Title: Keyboard
Author(s): LiXizhi
Date: 2015/9/3
Desc: Singleton object
The Keyboard class provides Keyboard related events, methods and, properties which provide information regarding the state of the Keyboard.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Keyboard.lua");
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
local Keyboard = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.Keyboard"));
Keyboard:Property("Name", "Keyboard");

function Keyboard:ctor()
end

function Keyboard:IsAltKeyPressed()
	return ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
end

function Keyboard:IsCtrlKeyPressed()
	return ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
end

function Keyboard:IsShiftKeyPressed()
	return ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
end

-- this is a singleton class
Keyboard:InitSingleton();