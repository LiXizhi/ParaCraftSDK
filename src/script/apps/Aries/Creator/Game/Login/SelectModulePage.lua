--[[
Title: SelectModulePage.html code-behind script
Author(s): LiPeng
Date: 2014/4/1
Desc: select the default global module for the game, and the module for every world.
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/SelectModulePage.lua");
local SelectModulePage = commonlib.gettable("MyCompany.Aries.Game.MainLogin.SelectModulePage")
SelectModulePage.ShowPage()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Mod/ModManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua");
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")

local SelectModulePage = commonlib.gettable("MyCompany.Aries.Game.MainLogin.SelectModulePage")

-- the rage value can be 0(for global game) or 1(for one world).
SelectModulePage.range = 0;
-- the module files' directory
SelectModulePage.dir = "Mod/";
SelectModulePage.modNameSpace = "Mod.";
SelectModulePage.page = nil;

--local isDevEnv = false;
local isDevEnv = System.options.isDevEnv;
SelectModulePage.mod_info= {
	--scriptList = {},
	--cur_script_name = nil;
	-- saved the gridview datasource which named "gvwModTable"
	modList = {},
	-- the table loaded from the local config file,decided the module whether be used;
	modTable = {},
	-- the world which the modules are used in. if "nil" ,the modules are used in global range;
	curWorld = nil,
	---- the selected mod list
	--selectedModList = {},
}

-- init function. page script fresh is set to false.
function SelectModulePage.OnInit()
	
	if(not SelectModulePage.inited) then
		SelectModulePage.inited = true;
		ParaIO.CreateDirectory(SelectModulePage.dir);
		SelectModulePage.GetModTableFromFile();
		--SelectModulePage.page = document:GetPageCtrl();
	end	
end

function SelectModulePage.GetCurrentWorld()
	return SelectModulePage.curWorld or "global";
end

function SelectModulePage.GetModTableFromFile()
	local curModTable = {};

	local filename = SelectModulePage.dir.."ModsConfig.xml";
	if(not ParaIO.DoesAssetFileExist(filename, true))then
		return;
	end
	local modXML = ParaXML.LuaXML_ParseFile(filename);

	local modnode;
	for modnode in commonlib.XPath.eachNode(modXML,"/mods/mod") do
		local modname = modnode.attr.name;
		curModTable[modname] = {};
		local worldnode;
		for worldnode in commonlib.XPath.eachNode(modnode,"/world") do
			local worldname = worldnode.attr.name;
			curModTable[modname][worldname] = {};
			local checked = worldnode.attr.checked;
			if(checked and checked == "true") then
				curModTable[modname][worldname]["checked"] = true;
			else
				curModTable[modname][worldname]["checked"] = false;
			end
		end
	end
	SelectModulePage.mod_info.modTable = curModTable;
end

function SelectModulePage.SaveModTableToFile()
	local curModTable = SelectModulePage.mod_info.modTable;
	local filename = SelectModulePage.dir.."ModsConfig.xml";
	local file = ParaIO.open(filename, "w");

	if(file:IsValid()) then
		local root = {name='mods',}
		--local node;
		local modname,mod;
		for modname,mod in pairs(curModTable) do 
			local modnode = {name='mod', attr={name = modname}};
			
			for worldname,world in pairs(mod) do 
				local worldnode = {name='world', attr={name = worldname}};
				if(world["checked"]) then
					worldnode.attr.checked = world["checked"];
				else
					worldnode.attr.checked = false;
				end
				if(worldnode) then
					modnode[#modnode+1] = worldnode;
				end
			end
			if(modnode) then
				root[#root+1] = modnode;
			end
		end
		if(root) then
			file:WriteString(commonlib.Lua2XmlString(root,true) or "");
		end
		file:close();
	end
end

-- get the modlist from the directory "Mod/"
function SelectModulePage.GetModuleList()
	local modList = {};
	local curModTable = SelectModulePage.mod_info.modTable;
	local curWorld = SelectModulePage.GetCurrentWorld();
	local folders = {};
	local dir = SelectModulePage.dir;
	if(isDevEnv) then
		commonlib.Files.SearchFiles(folders, dir, "*.*", 0, 100000, nil, true)
	else
		commonlib.Files.SearchFiles(folders, dir, "*.zip", 0, 100000, true, nil)
	end
	for _,folder in ipairs(folders) do
		local modname = folder;
		local checked = false;
		local mod = curModTable[modname];

		if(mod) then
			if(mod[curWorld] and mod[curWorld]["checked"] == true) then
				checked = true;
			end
		else			
			if(not mod) then
				curModTable[modname] = {};
				mod = curModTable[modname];
			end
			if(not mod[curWorld]) then
				if(curWorld ~= "global") then
					if(mod["global"]) then
						mod[curWorld] = mod["global"];
					else
						mod[curWorld] = {};
					end
				else
					mod[curWorld] = {};
				end
			end
			--curModTable[modName] = {};
		end
		local text;
		if(isDevEnv) then
			text = modname;
		else
			text = string.match(modname,"(.*)%.zip$");
		end
		local item = {text = text, name = modname, checked = checked};
		table.insert(modList,item);	
	end
	SelectModulePage.mod_info.modList = modList;
end

-- get the datasource of the module;
function SelectModulePage.DS_Items(index)
	local ds = SelectModulePage.mod_info.modList;
	if(ds) then
		if(index == nil) then
			return #ds;
		else
			return ds[index];
		end
	end
end

local temporary_modtable = {};

-- select the module to decide the module whether loaded
function SelectModulePage.OnSwitchModStatus(bChecked,modName,index)
	local curWorld = SelectModulePage.GetCurrentWorld();
	local mod = temporary_modtable[modName];
	if(not mod) then
		temporary_modtable[modName] = {};
		mod = temporary_modtable[modName];
	end

	if(not mod[curWorld]) then
		if(curWorld ~= "global") then
			if(mod["global"]) then
				mod[curWorld] = mod["global"];
			else
				mod[curWorld] = {};
			end
		else
			mod[curWorld] = {};
		end
	end
	mod[curWorld]["checked"] = bChecked;
	if(index and System.options.IsMobilePlatform) then
		local item = SelectModulePage.mod_info.modList[index];
		item.checked = not item.checked;
	end
end

-- reset the "SelectModulePage.mod_info.modTable"
function SelectModulePage.ResetLoadedMods()
	SelectModulePage.mod_info.modTable = nil;
	SelectModulePage.mod_info.modTable = temporary_modtable;
	SelectModulePage.SaveModTableToFile();
end

-- show page
function SelectModulePage.ShowPage()
	SelectModulePage.OnInit();
	SelectModulePage.GetModuleList();

	if(System.options.IsMobilePlatform) then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Login/SelectModulePage.mobile.html", 
			name = "SelectModulePage.ShowMobilePage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			bShow = bShow,
			zorder = 5,
			click_through = true, 
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
		});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Login/SelectModulePage.html", 
			name = "SelectModulePage", 
			isShowTitleBar = false,
			enable_esc_key = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 0,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -300,
				y = -250,
				width = 600,
				height = 500,
			cancelShowAnimation = true,
		});
	end
	
	commonlib.mincopy(temporary_modtable,SelectModulePage.mod_info.modTable);
end


-- load selected modules file
-- @beScriptSource : decide whether load the "script" floder from the "script.zip" in the "Mod" folder
function SelectModulePage.LoadMods()
	if(SelectModulePage.isLoaded or not System.options.mc) then
		return;
	end
	SelectModulePage.isLoaded = true;

	NPL.load("(gl)script/apps/Aries/Creator/Game/Mod/ModManager.lua");
	local ModManager = commonlib.gettable("Mod.ModManager");

	local skip_modname;
	if(isDevEnv) then
		local modname = ParaEngine.GetAppCommandLineByParam("mod","");
		if(modname and modname ~= "") then
			local filepath = "(gl)"..SelectModulePage.dir..modname.."/main.lua";
			NPL.load(filepath);
			local mod = commonlib.gettable(SelectModulePage.modNameSpace..modname);
			ModManager:AddMod(modname, mod);
			skip_modname = modname;
		end
	end

	SelectModulePage.OnInit();

	local modTable = SelectModulePage.mod_info.modTable;
	local curWorld = SelectModulePage.GetCurrentWorld();		
	
	for modname, modinfo in pairs(modTable) do
		if(modinfo[curWorld] and modinfo[curWorld]["checked"]) then
			if(skip_modname ~= modname) then
				local zipfilename = SelectModulePage.dir..modname;
				if(not ParaIO.DoesAssetFileExist(zipfilename, true))then
					modTable[modname] = nil;
					SelectModulePage.SaveModTableToFile();
				else
					ParaAsset.OpenArchive(zipfilename,false);	
				end
				local filename = string.match(modname,"(.*)%.zip$") or modname;
				local filepath = "(gl)"..SelectModulePage.dir..filename.."/main.lua";
				NPL.load(filepath);
				local mod = commonlib.gettable(SelectModulePage.modNameSpace..filename);
				ModManager:AddMod(modname, mod);
			end
		end
	end	
end
