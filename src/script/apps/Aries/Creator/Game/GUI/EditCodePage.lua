--[[
Title: EditCode Page
Author(s): LiXizhi
Date: 2014/1/21
Desc: # is used as the line seperator \r\n. Space key is replaced by _ character. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EditCodePage.lua");
local EditCodePage = commonlib.gettable("MyCompany.Aries.Game.GUI.EditCodePage");
EditCodePage.ShowPage(itemStack, OnClose);
-------------------------------------------------------
]]
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local NeuronManager = commonlib.gettable("MyCompany.Aries.Game.Neuron.NeuronManager");
local EditCodePage = commonlib.gettable("MyCompany.Aries.Game.GUI.EditCodePage");

local curItemStack;
local page;

function EditCodePage.OnInit()
	page = document:GetPageCtrl();

	local code = EditCodePage.GetCode();			
	page:SetValue("content", code or "空");
end

function EditCodePage.GetItemID()
	return curItemStack.id;
end

function EditCodePage.GetItemStack()
	return curItemStack;
end

function EditCodePage.GetCode()
	local filename = EditCodePage.GetScriptFileName();
	if(filename) then
		local full_path = NeuronManager.GetScriptFullPath(filename);
        local file = ParaIO.open(full_path, "r");
	    if(file:IsValid()) then
		    local text = file:GetText();
		    file:close();
			return text;
        else
			return format("file %s is NOT found", full_path);
	    end	
    end
end

function EditCodePage.SetCode(code)
	-- TODO: 
end

function EditCodePage.OnEditScript()
	-- open the script using a text editor
	local filename = EditCodePage.GetScriptFileName();
	if(filename) then
		local full_path = NeuronManager.GetScriptFullPath(filename);
		-- instead of open file, just open the containing directory. 
		if(mouse_button == "right") then
			-- open containing folder
			Map3DSystem.App.Commands.Call("File.WinExplorer", {filepath = full_path:gsub("[^/\\]+$", ""), silentmode=true});
		else
			-- open file 
			Map3DSystem.App.Commands.Call("File.WinExplorer", {filepath = full_path, silentmode=true});
		end
	end
end

function EditCodePage.GetScriptFileName()
	local content = curItemStack:GetData();
	if(type(content) == "string" and content:match("%.lua$")) then
		return content;
	end
end

function EditCodePage.SetScriptFileName(filename)
	curItemStack:SetScript(filename);
end

function EditCodePage.OnCreateNewFile()
	NPL.load("(gl)script/apps/Aries/Creator/Game/Neuron/CreateNewNeuronScriptFile.lua");
	local CreateNewNeuronScriptFile = commonlib.gettable("MyCompany.Aries.Game.Tasks.CreateNewNeuronScriptFile");
	CreateNewNeuronScriptFile.ShowPage(function(filename)
		if(filename) then
			if(EditCodePage.GetScriptFileName()~=filename) then
				EditCodePage.SetScriptFileName(filename);
				page:Refresh(0.1);
			end
		end
	end)
end

function EditCodePage.ShowPage(itemStack, OnClose)
	if(not itemStack) then
		return;
	end
	curItemStack = itemStack;
	local params = {
			url = "script/apps/Aries/Creator/Game/GUI/EditCodePage.html", 
			name = "EditCodePage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			bToggleShowHide=false, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			click_through = false, 
			enable_esc_key = true,
			bShow = true,
			zorder = -1,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_ct",
				x = -180,
				y = -200,
				width = 360,
				height = 400,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = OnClose;
end
