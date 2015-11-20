--[[
Title: MCImporterChunkGenerator
Author(s): LiXizhi for lipeng's mcimporter dll
Date: 2015.11.17
Desc: it uses the ChunkGenerator interface to load the world dynamically from a mc world directory, 
according to current player position. 
-----------------------------------------------
NPL.load("(gl)Mod/MCImporterGenerator/MCImporterChunkGenerator.lua");
local MCImporterChunkGenerator = commonlib.gettable("Mod.MCImporterGenerator.MCImporterChunkGenerator");
ChunkGenerators:Register("MCImporter", MCImporterChunkGenerator);
-----------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/World/ChunkGenerator.lua");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local names = commonlib.gettable("MyCompany.Aries.Game.block_types.names");

local MCImporterChunkGenerator = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.World.ChunkGenerator"), commonlib.gettable("Mod.MCImporterGenerator.MCImporterChunkGenerator"))

-- singleton instance
local cur_generator;
local cur_chunk;

function MCImporterChunkGenerator:ctor()
	-- use correct dll for different version. 
	if(ParaEngine.IsDebugging()) then
		self.dll_path = "MCImporter_d.dll";
	else
		if(ParaEngine.GetAttributeObject():GetField("Is64BitsSystem", false)) then
			self.dll_path = "MCImporter_64bits.dll";
		else
			self.dll_path = "MCImporter.dll";
		end
	end
end

-- @param world: WorldManager, if nil, it means a local generator. 
-- @param seed: a number
function MCImporterChunkGenerator:Init(world, seed)
	MCImporterChunkGenerator._super.Init(self, world, seed);

	cur_generator = self;
	self:LoadMCWorld();
	return self;
end

function MCImporterChunkGenerator:OnExit()
	MCImporterChunkGenerator._super.OnExit(self);
end


function MCImporterChunkGenerator:LoadMCWorld()
	local src_path = self:GetWorld():GetSeedString();
	NPL.call(self.dll_path, {cmd="loadmcworld", path = src_path});
	if(not self.isworldloaded) then
		LOG.std(nil, "info", "MCImporterChunkGenerator", "failed to load world at path %s", src_path);
	else
		LOG.std(nil, "info", "MCImporterChunkGenerator", "successfully load world at path %s", src_path);
	end

	local spawn_x, spawn_y, spawn_z = self:GetSpawnPosition();
	
	local x, y, z = BlockEngine:real(spawn_x, spawn_y, spawn_z);
	
	NPL.load("(gl)script/ide/timer.lua");
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		-- teleport player to this position.
		_guihelper.MessageBox("Do you want to teleport to spawn position in mc world?", function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				-- EntityManager.GetPlayer():SetPosition(x,y,z);
				EntityManager.GetPlayer():SetBlockPos(spawn_x, spawn_y, spawn_z);
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end})
	mytimer:Change(2000);
	
	LOG.std(nil, "info", "MCImporterChunkGenerator", "src_path: %s spawn block pos(%d %d %d)", src_path, spawn_x, spawn_y, spawn_z);
end

-- protected virtual funtion:
-- generate chunk for the entire chunk column at x, z
function MCImporterChunkGenerator:GenerateChunkImp(chunk, x, z, external)
	cur_generator = self;
	cur_chunk = chunk;
	-- make synchronous call to C++ dll to get all block in this chunk column. 
	NPL.call(self.dll_path, {cmd="GetChunkBlocks", callback="Mod/MCImporterGenerator/MCImporterChunkGenerator.lua", x = x, z = z});
end

-- get the player spawn position in the current world
-- @return: x,y,z in block world coordinate
function MCImporterChunkGenerator:GetSpawnPosition()
	NPL.call(self.dll_path, {cmd="GetSpawnPosition", callback="Mod/MCImporterGenerator/MCImporterChunkGenerator.lua"});
	return self.spawn_x, self.spawn_y, self.spawn_z;
end

function MCImporterChunkGenerator:LoadBlocksFromTable(chunk, x, z, blocks)
	if(blocks.count and blocks.count>0) then
		LOG.std(nil, "debug", "MCImporterChunkGenerator", "%d blocks in chunk: %d %d", blocks.count, x, z);
		local blocks_x, blocks_y, blocks_z, blocks_tempId, blocks_data = blocks.x, blocks.y, blocks.z, blocks.tempId, blocks.data;
		local i;
		for i = 1, blocks.count do
			local bx,by,bz,block_id, block_data = blocks_x[i], blocks_y[i], blocks_z[i], blocks_tempId[i], blocks_data[i];
			if(bx and block_id) then
				-- echo(format("x:%d,y:%d,z:%d,id:%d,data:%d",bx + x*16, by, bz + z*16, block_id, block_data));
				chunk:SetType(bx, by, bz, block_id, false);
				if(block_data and block_data~=0) then
					chunk:SetData(bx, by, bz, block_data);
				end
			end
		end
	end
end

local function activate()
	if(not msg) then
		return;
	end
	local cmd = msg.cmd;
	
	if(cmd == "loadmcworld") then
		if(cur_generator) then
			cur_generator.isworldloaded = msg.succeed;
		end
	elseif(cmd == "GetChunkBlocks") then
		local blocks = msg;
		if(blocks and blocks.count and cur_generator) then
			cur_generator:LoadBlocksFromTable(cur_chunk, blocks.chunk_x, blocks.chunk_z, blocks);
		end
	elseif(cmd == "GetSpawnPosition") then
		if(msg.x and msg.y and msg.z) then
			cur_generator.spawn_x, cur_generator.spawn_y, cur_generator.spawn_z = msg.x, msg.y, msg.z;
		end
		LOG.std(nil, "debug", "MCImporter", {"GetSpawnPosition", msg});
	end
end

NPL.this(activate);

