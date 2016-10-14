--[[
Title: DemoSceneContext
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/DemoSceneContext.lua");
local DemoSceneContext = commonlib.gettable("Mod.Test.DemoSceneContext");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/SceneContext.lua");
local DemoSceneContext = commonlib.inherit(commonlib.gettable("System.Core.SceneContext"), commonlib.gettable("Mod.Test.DemoSceneContext"));
function DemoSceneContext:ctor()
    self:EnableAutoCamera(true);
end

function DemoSceneContext:mouseReleaseEvent(event)
    _guihelper.MessageBox("clicked")
end
