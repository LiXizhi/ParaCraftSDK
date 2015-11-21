--[[
Title: show command
Author(s): LiXizhi
Date: 2014/7/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandShow.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Files.lua");
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");

local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");

-- show the current player 
Commands["show"] = {
	name="show", 
	quick_ref="/show [desktop|player|boundingbox|perf|info|touch|terrain] [on|off]", 
	desc="show different type of things" , 
	handler = function(cmd_name, cmd_text, cmd_params)
		local name, bIsShow;
		name, cmd_text = CmdParser.ParseString(cmd_text);
		bIsShow, cmd_text = CmdParser.ParseBool(cmd_text);

		if(name == "desktop") then
			local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
			Desktop.ShowAllAreas();
		elseif(name == "boundingbox") then
			GameLogic.options:ShowBoundingBox(true);
		elseif(name == "perf") then
			NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
			local npl_profiler = commonlib.gettable("commonlib.npl_profiler");
			npl_profiler.perf_show();
		elseif(name == "info") then
			if(bIsShow == nil) then
				bIsShow = not GameLogic.options:IsShowInfoWindow();
			end
			GameLogic.options:SetShowInfoWindow(bIsShow);
		elseif(name == "touch") then
			GameLogic.options:ShowTouchPad(true);
		elseif(name == "terrain") then
			ParaTerrain.GetAttributeObject():SetField("RenderTerrain", if_else(bIsShow==nil, true, bIsShow));
		elseif(name == "player") then
			EntityManager.GetPlayer():SetVisible(true);
		else
			ParaScene.GetAttributeObject():SetField("ShowMainPlayer", true);
		end
	end,
};


-- hide the current player, desktop, etc. 
Commands["hide"] = {
	name="hide", 
	quick_ref="/hide [desktop|player|boundingbox|touch]", 
	desc="hide different type of things" , 
	handler = function(cmd_name, cmd_text, cmd_params)
		local name;
		name, cmd_text = CmdParser.ParseString(cmd_text);
		if(name == "desktop") then
			local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
			Desktop.HideAllAreas();
		elseif(name == "boundingbox") then
			GameLogic.options:ShowBoundingBox(false);
		elseif(name == "touch") then
			GameLogic.options:ShowTouchPad(false);
		elseif(name == "player") then
			EntityManager.GetPlayer():SetVisible(false);
		else
			ParaScene.GetAttributeObject():SetField("ShowMainPlayer", false);
		end
	end,
};