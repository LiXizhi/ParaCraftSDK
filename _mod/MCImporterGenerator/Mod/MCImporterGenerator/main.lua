--[[
Title: mc importer
Author(s): lixizhi@yeah.net
Date: 2015.11.17
Desc: a demo of mixed C++/NPL plugin. This plugin will import mc world into paracraft.
Requirements: One needs to have MCImporter.dll copied to [redist]/MCImporter.dll

1. during init, the plugin registered a Chunk generator called "MCImporter" and /mcimport command
2. the /mcimport command will allow user to select a minecraft world directory and create a world with it. 
3. When the player moves around the newly created world, the importer's GenerateChunkImp() method is called 
	which asks the C++ MCimporter dll to load the chunk dynamically. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/MCImporterGenerator/main.lua");
local MCImporterGenerator = commonlib.gettable("Mod.MCImporterGenerator");
------------------------------------------------------------
]]
local MCImporterGenerator = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.MCImporterGenerator"));

-- name of the generator
MCImporterGenerator.generator_name = "MCImporter";

function MCImporterGenerator:ctor()
end

-- virtual function get mod name

function MCImporterGenerator:GetName()
	return "MCImporterGenerator"
end

-- virtual function get mod description 

function MCImporterGenerator:GetDesc()
	return "MCImporterGenerator is a plugin in paracraft"
end

function MCImporterGenerator:init()
	LOG.std(nil, "info", "MCImporterGenerator", "plugin initialized");
	self:RegisterWorldGenerator();
	self:RegisterCommand();
end

function MCImporterGenerator:RegisterWorldGenerator()
	NPL.load("(gl)script/apps/Aries/Creator/Game/World/ChunkGenerators.lua");
	local ChunkGenerators = commonlib.gettable("MyCompany.Aries.Game.World.ChunkGenerators");

	NPL.load("(gl)Mod/MCImporterGenerator/MCImporterChunkGenerator.lua");
	local MCImporterChunkGenerator = commonlib.gettable("Mod.MCImporterGenerator.MCImporterChunkGenerator");
	ChunkGenerators:Register(MCImporterGenerator.generator_name, MCImporterChunkGenerator);
end

function MCImporterGenerator:RegisterCommand()
	local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
	Commands["mcimport"] = {
		name="mcimport", 
		quick_ref="/mcimport", 
		desc="create a new world from a minecraft world directory", 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			self:OnClickImportWorld();
		end,
	};
end

function MCImporterGenerator:OnLogin()
end
-- called when a new world is loaded. 

function MCImporterGenerator:OnWorldLoad()
end
-- called when a world is unloaded. 

function MCImporterGenerator:OnLeaveWorld()
end

function MCImporterGenerator:OnDestroy()
end

-- allow the user to choose which world to import. 
function MCImporterGenerator:OnClickImportWorld()
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	-- local filename = CommonCtrl.OpenFileDialog.ShowDialog_Win32(nil, "minecraft world directory:", ParaIO.GetCurDirectory(0), false);
	local src_dir = CommonCtrl.OpenFileDialog.ShowOpenFolder_Win32();
	if(src_dir and src_dir~="") then
		src_dir = src_dir:gsub("[/\\]$", "");
		local worldname = src_dir:match("[^/\\]+$");
		if(worldname and src_dir) then
			self:CreateWorldFromMCWorld(worldname, src_dir)
		end
	end
end

function MCImporterGenerator:CreateWorldFromMCWorld(worldname, src_dir)
	NPL.load("(gl)script/apps/Aries/Creator/Game/Login/CreateNewWorld.lua");
	local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
	local CreateNewWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.CreateNewWorld")
	local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic");

	local params = {
		worldname = worldname,
		title = worldname,
		creationfolder = CreateNewWorld.GetWorldFolder(),
		parentworld = "worlds/Templates/Empty/flatsandland",
		world_generator = MCImporterGenerator.generator_name,
		seed = src_dir,
	}
	LOG.std(nil, "info", "CreateNewWorld", params);

	local worldpath, error_msg = CreateNewWorld.CreateWorld(params);
	if(not worldpath) then
		if(error_msg) then
			_guihelper.MessageBox(error_msg);
		end
	else
		WorldCommon.OpenWorld(worldpath, true);
	end
end