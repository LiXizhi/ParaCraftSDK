--[[
Title: Entity Dialog Page
Author(s): LiXizhi
Date: 2014/1/7
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/NPCDialogPage.lua");
local NPCDialogPage = commonlib.gettable("MyCompany.Aries.Game.GUI.NPCDialogPage");
NPCDialogPage.ShowPage(entity);
-------------------------------------------------------
]]
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local NPCDialogPage = commonlib.gettable("MyCompany.Aries.Game.GUI.NPCDialogPage");

local cur_entity;
local page;

function NPCDialogPage.OnInit()
	page = document:GetPageCtrl();
end

function NPCDialogPage.GetEntity()
	return cur_entity;
end

function NPCDialogPage.GetItemID()
	if(cur_entity) then
		return cur_entity:GetBlockId();
	else
		return 0;
	end
end

function NPCDialogPage.GetItemName()
    local block = block_types.get(NPCDialogPage.GetItemID())
    if(block) then
        return block:GetDisplayName();
    end
end

function NPCDialogPage.GetCommand()
	if(cur_entity) then
		return cur_entity:GetCommand();
	end
end


function NPCDialogPage.ShowPage(entity)
	if(not entity) then
		return;
	end
	cur_entity = entity;
	local params = {
			url = format("script/apps/Aries/Creator/Game/GUI/NPCDialogPage.html"), 
			name = "NPCDialogPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			bToggleShowHide=false, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			enable_esc_key = true,
			bShow = true,
			click_through = false, 
			zorder = -1,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function NPCDialogPage.OnClickOK()
	local entity = NPCDialogPage.GetEntity();
	if(entity) then
		local command = page:GetValue("command", "")
		command = command:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[\r\n]+$", "");
		entity:SetCommand(command);
		entity:Refresh();
	end
	page:CloseWindow();
end