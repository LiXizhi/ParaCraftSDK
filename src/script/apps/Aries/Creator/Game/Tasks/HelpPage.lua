--[[
Title: building quest task
Author(s): LiXizhi, LiPeng
Date: 2013/11/13
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/HelpPage.lua");
local HelpPage = commonlib.gettable("MyCompany.Aries.Game.Tasks.HelpPage");
HelpPage.ShowPage();
-------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/BuildQuestTask.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/BuildQuestProvider.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/BuilderFramePage.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandManager.lua");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local BuilderFramePage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.BuilderFramePage");
local BuildQuest = commonlib.gettable("MyCompany.Aries.Game.Tasks.BuildQuest");
local BuildQuestProvider =  commonlib.gettable("MyCompany.Aries.Game.Tasks.BuildQuestProvider");

local HelpPage = commonlib.gettable("MyCompany.Aries.Game.Tasks.HelpPage");

local type_ds = {
	{name = "type",attr = {text=L"新手教程",index = 1,category="tutorial"}},
	{name = "type",attr = {text=L"建筑百科",index = 2,category="blockwiki"}},
	{name = "type",attr = {text=L"命令帮助",index = 3,category="command"}},
	{name = "type",attr = {text=L"快捷操作",index = 4,category="shortcutkey"}},
}
-- default to category="shortcutkey"
HelpPage.select_type_index = nil;

local shortcurkey_ds = {};
local anim_ds = {};

local page;
function HelpPage.ShowPage()

	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Creator/Game/Tasks/HelpPage.html", 
		name = "HelpPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		bShow = bShow,
		zorder = 1,
		directPosition = true,
			align = "_ct",
			x = -650/2,
			y = -450/2,
			width = 650,
			height = 450,
	});
end

function HelpPage.ClosePage()
	if(page) then
		page:CloseWindow();
	end
end

function HelpPage.OnInit()
	page = document:GetPageCtrl();
	BuildQuestProvider.Init();
	--BuildQuest.cur_theme_index = BuildQuest.cur_theme_index or 1;
	HelpPage.cur_theme_index = HelpPage.cur_theme_index or 1;
	HelpPage.cur_category = HelpPage.GetCurrentCategory();
	if(HelpPage.inited) then
		return;
	end
	HelpPage.select_type_index = HelpPage.select_type_index or 1;
	HelpPage.select_item_index = HelpPage.select_item_index or 1;
	HelpPage.OnInitDS();
	HelpPage.select_task_index = HelpPage.select_task_index or 1;
	HelpPage.inited = true;
end

--local blockTypes = {
	--{text="方块", index=1, name="static",     enabled=true},
	--{text="装饰", index=2, name="deco",       enabled=true},
	--{text="人物", index=3, name="character",  enabled=true},
	--{text="机关", index=4, name="gear",	     enabled=true},
--}

local function GetShortCutKeyDS()
	filename = "config/Aries/creator/shortcutkey.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		for node in commonlib.XPath.eachNode(xmlRoot, "/Items/Type") do
			if(node.attr and node.attr.name) then
				local type_ds = {name = L(node.attr.name)};
				shortcurkey_ds[#shortcurkey_ds + 1] = type_ds;
				local content = "";
				for itemnode in commonlib.XPath.eachNode(node, "/Item") do
					if(itemnode.attr and itemnode.attr.value and itemnode.attr.desc) then
						local text = string.format("<font style=';color:#FF0000;'>%s:</font>%s",L(itemnode.attr.value),L(itemnode.attr.desc));
						content = content..text.."<br/>";
					end
				end
				type_ds.content = content;
			end
		end
	end
	return shortcurkey_ds;
end

local function GetAnimDS()
	filename = "config/Aries/creator/modelAnim.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		for node in commonlib.XPath.eachNode(xmlRoot, "/anims/model") do
			if(node.attr and node.attr.text) then
				local type_ds = {name = L(node.attr.text)};
				anim_ds[#anim_ds + 1] = type_ds;
				local content = "";
				for itemnode in commonlib.XPath.eachNode(node, "/anim") do
					if(itemnode.attr and itemnode.attr.id and itemnode.attr.desc) then
						local text = string.format("<font style=';color:#FF0000;'>%s:</font>%s",L(itemnode.attr.id),L(itemnode.attr.desc));
						content = content..text.."<br/>";
					end
				end
				type_ds.content = content;
			end
		end
	end
	return anim_ds;
end

function HelpPage.OnInitDS()
	for i = 1,#type_ds do
		local typ = type_ds[i];
		if(typ["attr"]) then
			typ["attr"]["select_item_index"] = 1;
		end
		if(i == 1 or i == 2) then
			local ds = BuildQuestProvider.GetThemes_DS(typ["attr"].category);
			for j = 1,#ds do
				local theme = ds[j];
				local item = {name="item",attr={text=theme.name,item_index=j,type_index = i,category=typ["attr"]["category"]}}
				typ[#typ + 1] = item;
			end
		elseif(i == 3) then
			local ds = CommandManager:GetCmdTypeDS();
			local j = 1;
			for k,v in pairs(ds) do
				local item = {name="item",attr={text=k,item_index=j,type_index = i,category=typ["attr"]["category"],}}
				typ[#typ + 1] = item;
				j = j + 1;
			end
			-- add the model anim info;
			typ[#typ + 1] = {name="item",attr={text=L"动作编号",item_index=j,type_index = i,category=typ["attr"]["category"],}};
		elseif(i == 4) then
			typ[1] = {name="item",attr={text=L"全部",item_index=1,type_index = i,category=typ["attr"]["category"],}}
		end
	end
end

function HelpPage.GetCurrentCategory(index)
	local ds = HelpPage.GetHelpDS();
	local category = ds[index or HelpPage.select_type_index or 1]["attr"]["category"];
	return category
end

function HelpPage.GetHelpDS()
	return type_ds;
end

function HelpPage.GetCurGridviewDS(name)
	local ds;
	if(HelpPage.select_type_index == 3) then
		if(not name) then
			name = type_ds[3][1]["attr"]["text"];
		end
		local cmd_types = CommandManager:GetCmdTypeDS();
		ds = cmd_types[name] or {};
	else
		ds = {};
	end
	return ds;
end

function HelpPage.IsAnimItem(_index)
	local len = table.getn(type_ds[HelpPage.select_type_index]);
	local index = _index or HelpPage.select_item_index;
	if(len == index) then
		return true;
	end
	return false;
end

function HelpPage.GetGridview_DS(index)
	local ds;
	if(HelpPage.select_type_index == 1 or HelpPage.select_type_index == 2) then
		ds = BuildQuestProvider.GetTasks_DS(HelpPage.select_item_index,HelpPage.cur_category);
	elseif(HelpPage.select_type_index == 3) then
		if(HelpPage.IsAnimItem()) then
			if(not next(anim_ds)) then
				anim_ds = GetAnimDS(); 
			end
			ds = anim_ds;
		else
			if(not HelpPage.cur_gridview_ds) then
				HelpPage.cur_gridview_ds = HelpPage.GetCurGridviewDS();
			end
			ds = HelpPage.cur_gridview_ds;
		end
	elseif(HelpPage.select_type_index == 4) then
		if(not next(shortcurkey_ds)) then
			shortcurkey_ds = GetShortCutKeyDS(); 
		end
		ds = shortcurkey_ds;
	end
	if(not ds) then
		return 0;
	end
	if(not index) then
		return #ds;
	else
		return ds[index];
	end
end

function HelpPage.ClosePage()
	if(page) then
		page:CloseWindow();
	end
end

function HelpPage.ChangeTask(name,mcmlNode)
    local attr = mcmlNode.attr;
    local task_index = tonumber(attr.param1);
    HelpPage.select_task_index = task_index;
	page:Refresh(0.1);
end

function HelpPage.GetShortCutKeyStr()
	local str = shortcurkey_ds[HelpPage.select_task_index or 1]["content"];
	return str;
end

function HelpPage.GetAnimStr()
	local str = anim_ds[HelpPage.select_task_index]["content"];
	return str;
end