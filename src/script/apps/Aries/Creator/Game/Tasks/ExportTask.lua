--[[
Title: Export Task Command
Author(s): LiXizhi
Date: 2015/9/28
Desc: allow the user to select to export as bmax model or block template. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ExportTask.lua");
local Export = commonlib.gettable("MyCompany.Aries.Game.Tasks.Export");
local task = MyCompany.Aries.Game.Tasks.Export:new({})
task:Run();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/SceneContext/SelectionManager.lua");
local SelectionManager = commonlib.gettable("MyCompany.Aries.Game.SelectionManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local TaskManager = commonlib.gettable("MyCompany.Aries.Game.TaskManager")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local Export = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Task"), commonlib.gettable("MyCompany.Aries.Game.Tasks.Export"));

function Export:ctor()
end

function Export:ShowPage()
	local width, height = 512, 350;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Tasks/ExportTask.html", 
			name = "ExportTask.ShowPage", 
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -width/2,
				y = -height/2,
				width = width,
				height = height,
		});
end

-- @param bIsDataPrepared: true if data is prepared. if nil, we will prepare the data from input params.
function Export:Run()
	if(SelectionManager:GetSelectedBlocks()) then
		Export.ShowPage();
	else
		GameLogic.AddBBS(nil, L"请先选择物体, Ctrl+左键多次点击场景可选择");
	end
end

function Export:ExportAsTemplate()
	NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/SelectBlocksTask.lua");
	local SelectBlocks = commonlib.gettable("MyCompany.Aries.Game.Tasks.SelectBlocks");
	SelectBlocks.SaveToTemplate();
end

function Export:ExportAsBMax()
	NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/SaveFileDialog.lua");
	local SaveFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.SaveFileDialog");
	SaveFileDialog.ShowPage(L"请输入bmax文件名称", function(result)
		if(result and result~="") then
			GameLogic.RunCommand("savemodel", result);
		end
	end, nil, nil, "bmax");
end