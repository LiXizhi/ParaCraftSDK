--[[
Title: DemoSceneContext
Author(s): LiXizhi
Date: 2016.10
Desc: Example of demo scene context
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/DemoSceneContext.lua");
local DemoSceneContext = commonlib.gettable("Mod.Test.DemoSceneContext");
DemoSceneContext:ApplyToDefaultContext();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/SceneContext.lua");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local DemoSceneContext = commonlib.inherit(commonlib.gettable("System.Core.SceneContext"), commonlib.gettable("Mod.Test.DemoSceneContext"));
function DemoSceneContext:ctor()
    self:EnableAutoCamera(true);
end

-- static method: use this demo scene context as default context
function DemoSceneContext:ApplyToDefaultContext()
	DemoSceneContext:ResetDefaultContext();
	GameLogic.GetFilters():add_filter("DefaultContext", function(context)
	   return DemoSceneContext:CreateGetInstance("MyDefaultSceneContext");
	end);
end

-- static method: reset scene context to vanila scene context
function DemoSceneContext:ResetDefaultContext()
	GameLogic.GetFilters():remove_all_filters("DefaultContext");
end

function DemoSceneContext:mouseReleaseEvent(event)
	if(event:button() == "left") then
		_guihelper.MessageBox("You clicked in Demo Scene Context. Switching to default context?", function()
			self:ResetDefaultContext();
			GameLogic.ActivateDefaultContext();
		end)
	end
end
