--[[
Title: single thread memory cache
Author: LiXizhi
Date: 2015/6/14
Desc: this is the default memory cache class used by the admin site. 
One may replace it with other more advanced cache API, such as "memcached".
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/mem_cache.lua");
local mem_cache = commonlib.gettable("WebServer.mem_cache");
local obj_cache = mem_cache:GetInstance();
obj_cache:add("name", "value")
obj_cache:replace("name", "value1")
assert(obj_cache:get("name") == "value1");
assert(obj_cache:get("name", "group1") == nil);
obj_cache:add("name", "value", "group1")
assert(obj_cache:get("name", "group1") == "value");
-----------------------------------------------
]]

local mem_cache = commonlib.inherit(nil, commonlib.gettable("WebServer.mem_cache"));

-- single threaded global instance
local s_singleton;

function mem_cache:ctor()
	self.groups = {};
end

-- Retrieves the cache contents from the cache by key and group.
-- @param key: What the contents in the cache are called
-- @param group: Where the cache contents are grouped
-- @param force: boolean Whether to force an update of the local cache from the persistent cache -- (default is false)
-- @return value: value stored in cache. nil if not found;
function mem_cache:get(name, group, force)
	local store = self.groups[group or ""];
	if(store) then
		if(store[name] ~= nil) then
			return store[name];
		end
	end
end

-- Saves the data to the cache.
-- @return true on success
function mem_cache:set( key, data, group, expire)
	local store = self:getgroup(group);
	store[key] = data;
	return true;
end

-- Adds data to the cache, if the cache key doesn't already exist.
-- @param key: The cache key to use for retrieval later
-- @param data:  The data to add to the cache store
-- @param group: The group to add the cache to. default to ""
-- @param expire: When the cache data should be expired
-- @return bool False if cache key and group already exist, true on success
function mem_cache:add( key, data, group, expire)
	local store = self:getgroup(group);
	if(store[key] == data) then
		return false;
	else
		store[key] = data;
		return true;
	end
end

-- Replaces the contents of the cache with new data.
-- @return bool False if not exists, true if contents were replaced
function mem_cache:replace( key, data, group, expire)
	local store = self:getgroup(group);
	if(store[key] ~= nil) then
		store[key] = data;
		return true;
	else
		return;
	end
end


-- static public function. 
-- get global singleton
function mem_cache:GetInstance()
	if(s_singleton) then
		return s_singleton;
	else
		s_singleton = mem_cache:new();
		return s_singleton;
	end
end

function mem_cache:getgroup(group)
	local store = self.groups[group or ""];
	if(not store) then
		store = {};
		self.groups[group or ""] = store;
	end
	return store;
end