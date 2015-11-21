--[[
Title: vector3d pool
Author(s): LiXizhi
Date: 2014/6/14
Desc: useful when creating lots of pool objects in a single frame. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/VectorPool.lua");
local VectorPool = commonlib.gettable("mathlib.VectorPool");
local vec3d_pool = VectorPool.GetSingleton();
-- create from pool. 
local vecPool = vec3d_pool:GetVector(x,y,z)
-- called between tick(not necessary if maxPoolSize is used)
vecPool:CleanPool();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local VectorPool = commonlib.gettable("mathlib.VectorPool");
VectorPool.__index = VectorPool;

 -- Maximum number of times the pool can be "cleaned" before the pool is shrunk
 -- in most cases, we clear pool every frame move. so 900 is like 30 seconds. 
VectorPool.maxNumCleansToShrink = 30*30;
-- max number of entry to remove every Shrink function. 
VectorPool.numEntriesToRemove = 500;
-- we will automatically reuse from beginning when reaching this value. 
-- such that CleanPool() is not a must-call function. Depending on usage pattern.
VectorPool.maxPoolSize = 1000;

function VectorPool:new()
	local o = {};
	-- Number of times this Pool has been cleaned
	o.numCleans = 0;
	-- List of vector stored in this Pool
	o.listVector3D = commonlib.vector:new();
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
function VectorPool.GetSingleton()
	if(default_pool) then
		return default_pool;
	else
		default_pool = VectorPool:new();
		return default_pool;
	end
end

function VectorPool:init(maxNumCleansToShrink, numEntriesToRemove, maxPoolSize)
	self.maxNumCleansToShrink = maxNumCleansToShrink;
	self.numEntriesToRemove = numEntriesToRemove;
	self.maxPoolSize = maxPoolSize;
	return self;
end

-- Creates a new Vector, or reuses one that's no longer in use. 
-- @param x,y,z:
-- returns from this function should only be used for one frame or tick, as after that they will be reused.
function VectorPool:GetVector(x,y,z)
    local vec3d;

    if (self.nextPoolIndex > self.listVector3D:size()) then
		vec3d = vector3d:new(x,y,z);
        self.listVector3D:add(vec3d);
    else
        vec3d = self.listVector3D:get(self.nextPoolIndex);
		vec3d:set(x,y,z);
    end

    self.nextPoolIndex = self.nextPoolIndex + 1;
	if(self.nextPoolIndex > self.maxPoolSize) then
		LOG.std(nil, "debug", "VectorPool", "maxPoolSize reached %d", self.maxPoolSize);
		self.maxPoolIndex = self.maxPoolSize;
		self.nextPoolIndex = 1;
	end
    return vec3d;
end

-- Marks the pool as "empty", starting over when adding new entries. If this is called maxNumCleansToShrink times, the list
-- size is reduced
function VectorPool:CleanPool()
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
function VectorPool:Shrink()
	local maxHistorySize = math.max(self.maxPoolIndexFromLastShrink, self.maxPoolIndex)
	local newSize = math.max(maxHistorySize, self.listVector3D:size() - self.numEntriesToRemove);
	self.listVector3D:resize(newSize);
    self.maxPoolIndex = 0;
    self.numCleans = 0;
	self.nextPoolIndex = 1;
end

-- Clears the VectorPool
function VectorPool:clearPool()
    self.nextPoolIndex = 1;
    self.listVector3D:clear();
end

function VectorPool:GetListVector3Dsize()
    return self.listVector3D:size();
end

function VectorPool:GetNextPoolIndex()
    return self.nextPoolIndex;
end