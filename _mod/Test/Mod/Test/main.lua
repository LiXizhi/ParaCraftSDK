--[[
Title: Testing every aspect of Mod interface
Author(s):  LiXizhi
Date: 2015.10
Desc: This is also a greate demo of mod interface. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/main.lua");
local Test = commonlib.gettable("Mod.Test");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/Test/DemoCommand.lua");
NPL.load("(gl)Mod/Test/DemoEntity.lua");
NPL.load("(gl)Mod/Test/DemoGUI.lua");
NPL.load("(gl)Mod/Test/DemoItem.lua");
NPL.load("(gl)Mod/Test/DemoSceneContext.lua");
local DemoSceneContext = commonlib.gettable("Mod.Test.DemoSceneContext");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local DemoItem = commonlib.gettable("Mod.Test.DemoItem");
local DemoGUI = commonlib.gettable("Mod.Test.DemoGUI");
local DemoEntity = commonlib.gettable("Mod.Test.DemoEntity");
local DemoCommand = commonlib.gettable("Mod.Test.DemoCommand");
local Test = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.Test"));

function Test:ctor()
end

-- virtual function get mod name

function Test:GetName()
	return "Test"
end

-- virtual function get mod description 
function Test:GetDesc()
	return "Test is a plugin in paracraft"
end

function Test:init()
	LOG.std(nil, "info", "Test", "plugin initialized");
	DemoItem:init();
	DemoGUI:init();
	DemoEntity:init();
	DemoCommand:init();
	
	-- register default context
	DemoSceneContext:ApplyToDefaultContext();
end

function Test:OnLogin()
end

-- called when a new world is loaded. 
function Test:OnWorldLoad()
	LOG.std(nil, "info", "Test", "Mod test on world loaded");
	DemoGUI:OnWorldLoad();
	DemoItem:OnWorldLoad();
end

-- called when a world is unloaded. 
function Test:OnLeaveWorld()
	LOG.std(nil, "info", "Test", "Mod test on leave world");
	DemoGUI:OnLeaveWorld();
end

function Test:OnDestroy()
end

function Test:handleKeyEvent(event)
	return DemoGUI:handleKeyEvent(event);
end


-- virtual: called when a desktop is inited such as displaying the initial user interface. 
-- return true to prevent further processing.
function Test:OnInitDesktop()
	-- we will show our own UI here
	return true;
end

-- virtual: called when a desktop mode is changed such as from game mode to edit mode. 
-- return true to prevent further processing.
function Test:OnActivateDesktop(mode)
	-- we will toggle our own UI here
	local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
	if(Desktop.mode) then
		GameLogic.AddBBS("test", "Test进入编辑模式", 4000, "0 255 0")
	else
		GameLogic.AddBBS("test", "Test进入游戏模式", 4000, "255 255 0")
	end
	-- return true to suppress default desktop interface.
	return true;
end

function Test:OnClickExitApp()
	_guihelper.MessageBox("wanna exit?" , function()
		ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
		ParaGlobal.ExitApp();
	end)
	return true;
end