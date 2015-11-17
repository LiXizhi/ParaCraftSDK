--[[
Title: MCImporterChunkGenerator
Author(s): LiXizhi
Date: 2013/8/27, refactored 2015.11.17
Desc: A flat world generator with multiple layers at custom level.
-----------------------------------------------
NPL.load("(gl)Mod/MCImporterGenerator/MCImporterChunkGenerator.lua");
local MCImporterChunkGenerator = commonlib.gettable("MyCompany.Aries.Game.World.Generators.MCImporterChunkGenerator");
ChunkGenerators:Register("MCImporter", MCImporterChunkGenerator);
-----------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/World/ChunkGenerator.lua");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local names = commonlib.gettable("MyCompany.Aries.Game.block_types.names");

local MCImporterChunkGenerator = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.World.ChunkGenerator"), commonlib.gettable("MyCompany.Aries.Game.World.Generators.MCImporterChunkGenerator"))

function MCImporterChunkGenerator:ctor()
end

-- @param world: WorldManager, if nil, it means a local generator. 
-- @param seed: a number
function MCImporterChunkGenerator:Init(world, seed)
	MCImporterChunkGenerator._super.Init(self, world, seed);
	return self;
end

function MCImporterChunkGenerator:OnExit()
	MCImporterChunkGenerator._super.OnExit(self);
end

-- protected virtual funtion:
-- generate chunk for the entire chunk column at x, z
function MCImporterChunkGenerator:GenerateChunkImp(chunk, x, z, external)
	-- echo({x, z, "1111111111"})
end


