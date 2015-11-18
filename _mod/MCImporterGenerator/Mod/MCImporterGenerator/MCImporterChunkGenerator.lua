--[[
Title: MCImporterChunkGenerator
Author(s): LiXizhi
Date: 2013/8/27, refactored 2015.11.17
Desc: A flat world generator with multiple layers at custom level.
-----------------------------------------------
NPL.load("(gl)Mod/MCImporterGenerator/MCImporterChunkGenerator.lua");
local MCImporterChunkGenerator = commonlib.gettable("Mod.MCImporterGenerator.MCImporterChunkGenerator");
ChunkGenerators:Register("MCImporter", MCImporterChunkGenerator);
-----------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/World/ChunkGenerator.lua");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local names = commonlib.gettable("MyCompany.Aries.Game.block_types.names");

local MCImporterChunkGenerator = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.World.ChunkGenerator"), commonlib.gettable("Mod.MCImporterGenerator.MCImporterChunkGenerator"))

function MCImporterChunkGenerator:ctor()
	-- please note this mode only works with 32bits dll.
	if(ParaEngine.GetAttributeObject():GetField("Is64BitsSystem", false)) then
		self.dll_path = "MCImporter_64bits.dll";
	else
		self.dll_path = "MCImporter.dll";
	end
end

-- @param world: WorldManager, if nil, it means a local generator. 
-- @param seed: a number
function MCImporterChunkGenerator:Init(world, seed)
	MCImporterChunkGenerator._super.Init(self, world, seed);

	self:LoadMCWorld();
	return self;
end

function MCImporterChunkGenerator:OnExit()
	MCImporterChunkGenerator._super.OnExit(self);
end

function MCImporterChunkGenerator:LoadMCWorld()
	local src_path = self:GetWorld():GetSeedString();
	LOG.std(nil, "info", "MCImporterChunkGenerator", "src_path: %s", src_path);
	NPL.call(self.dll_path, {cmd="loadmcworld", path = src_path});
end

local cur_generator;
local cur_chunk;

-- protected virtual funtion:
-- generate chunk for the entire chunk column at x, z
function MCImporterChunkGenerator:GenerateChunkImp(chunk, x, z, external)
	cur_generator = self;
	cur_chunk = chunk;
	-- make synchronous call to C++ dll to get all block in this chunk column. 
	NPL.call(self.dll_path, {cmd="GetChunkBlocks", callback="Mod/MCImporterGenerator/MCImporterChunkGenerator.lua", x = x, z = z});
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
	local blocks = msg;
	if(blocks and blocks.count and cur_generator) then
		cur_generator:LoadBlocksFromTable(cur_chunk, blocks.chunk_x, blocks.chunk_z, blocks);
	end
end

NPL.this(activate);

