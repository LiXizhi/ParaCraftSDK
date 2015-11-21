--[[
Title: aabb pool
Author(s): LiXizhi
Date: 2014/6/9
Desc: useful when creating lots of pool objects in a single frame. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/AABBPool.lua");
local AABBPool = commonlib.gettable("mathlib.AABBPool");
local aabb_pool = AABBPool.GetSingleton();
-- create from pool. 
local aabb = aabb_pool:GetAABB(minX, minY, minZ, maxX, maxY, maxZ)
-- called between tick(not necessary if maxPoolSize is used)
aabb_pool:CleanPool();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/ShapeAABB.lua");
local ShapeAABB = commonlib.gettable("mathlib.ShapeAABB");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local AABBPool = commonlib.gettable("mathlib.AABBPool");
AABBPool.__index = AABBPool;

 -- Maximum number of times the pool can be "cleaned" before the pool is shrunk
 -- in most cases, we clear pool every frame move. so 900 is like 30 seconds. 
AABBPool.maxNumCleansToShrink = 30*30;
-- max number of entry to remove every Shrink function. 
AABBPool.numEntriesToRemove = 500;
-- we will automatically reuse from beginning when reaching this value. 
-- such that CleanPool() is not a must-call function. Depending on usage pattern.
AABBPool.maxPoolSize = 2000;

function AABBPool:new()
	local o = {};
	-- Number of times this Pool has been cleaned
	o.numCleans = 0;
	-- List of AABB stored in this Pool
	o.listAABB = commonlib.vector:new();
	-- Next index to use when adding a Pool Entry.
	o.nextPoolIndex = 1;
	-- Largest index reached by this Pool since last CleanPool operation. 
	o.maxPoolIndex = 0;
	-- Largest index reached by this Pool since last Shrink operation. 
	o.maxPoolIndexFromLastShrink = 0;

	setmetatable(o, self);
	return o;
end

local default_pool;
function AABBPool.GetSingleton()
	if(default_pool) then
		return default_pool;
	else
		default_pool = AABBPool:new();
		return default_pool;
	end
end

function AABBPool:init(maxNumCleansToShrink, numEntriesToRemove, maxPoolSize)
	self.maxNumCleansToShrink = maxNumCleansToShrink;
	self.numEntriesToRemove = numEntriesToRemove;
	self.maxPoolSize = maxPoolSize;
	return self;
end

-- Creates a new AABB, or reuses one that's no longer in use. 
-- @param minX, minY, minZ, maxX, maxY, maxZ:
-- @param isInputCenterExtent: if true, above params is regarded as center and extent
-- returns from this function should only be used for one frame or tick, as after that they will be reused.
function AABBPool:GetAABB(minX, minY, minZ, maxX, maxY, maxZ, isInputCenterExtent)
    local aabb;

    if (self.nextPoolIndex > self.listAABB:size()) then
		if(not isInputCenterExtent) then
			aabb = ShapeAABB:new():SetMinMaxValues(minX, minY, minZ, maxX, maxY, maxZ);
		else
			aabb = ShapeAABB:new():SetCenterExtentValues(minX, minY, minZ, maxX, maxY, maxZ);
		end
        self.listAABB:add(aabb);
    else
        aabb = self.listAABB:get(self.nextPoolIndex);
		if(not isInputCenterExtent) then
			aabb:SetMinMaxValues(minX, minY, minZ, maxX, maxY, maxZ);
		else
			aabb:SetCenterExtentValues(minX, minY, minZ, maxX, maxY, maxZ);
		end
    end

    self.nextPoolIndex = self.nextPoolIndex + 1;
	if(self.nextPoolIndex > self.maxPoolSize) then
		LOG.std(nil, "debug", "AABBPool", "maxPoolSize reached %d", self.maxPoolSize);
		self.maxPoolIndex = self.maxPoolSize;
		self.nextPoolIndex = 1;
	end
    return aabb;
end

-- Marks the pool as "empty", starting over when adding new entries. If this is called maxNumCleansToShrink times, the list
-- size is reduced
function AABBPool:CleanPool()
    if (self.nextPoolIndex > self.maxPoolIndex) then
        self.maxPoolIndex = self.nextPoolIndex;
    end

	if(self.maxPoolIndexFromLastShrink < self.maxPoolIndex) then
		self.maxPoolIndexFromLastShrink = self.maxPoolIndex;
	end

	self.numCleans = self.numCleans + 1;
    if (self.numCleans >= self.maxNumCleansToShrink) then
		self:Shrink();
    end
    self.nextPoolIndex = 1;
end

-- this function is called automatically inside CleanPool(). 
function AABBPool:Shrink()
	local maxHistorySize = math.max(self.maxPoolIndexFromLastShrink, self.maxPoolIndex)
	local newSize = math.max(maxHistorySize, self.listAABB:size() - self.numEntriesToRemove);
	self.listAABB:resize(newSize);
    self.maxPoolIndex = 0;
    self.numCleans = 0;
	self.nextPoolIndex = 1;
end

-- Clears the AABBPool
function AABBPool:clearPool()
    self.nextPoolIndex = 1;
    self.listAABB:clear();
end

function AABBPool:GetListAABBsize()
    return self.listAABB:size();
end

function AABBPool:GetNextPoolIndex()
    return self.nextPoolIndex;
end