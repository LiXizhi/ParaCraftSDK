--[[
Title: File System Watcher
Author(s):  LiXizhi
Date: 2010/3/29
Desc: Monitoring file changes in a given directory recursively. It uses IO completion port under windows and inotify under linux. 
This is useful for monitoring asset or script file changes and reload them automatically at development time. 
KNOW LIMITATIONS:
	- only a single low level watcher object can be available per thread. Hence self.name must be unique. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/FileSystemWatcher.lua");
-- watch files under model/ and character/ directory and Refresh it in case they are changed
local watcher = commonlib.FileSystemWatcher:new()
watcher.filter = function(filename)
	return string.find(filename, ".*") and not string.find(filename, "%.svn")
end
watcher:AddDirectory("model/")
watcher:AddDirectory("character/")
watcher:SetMonitorAll(true);
watcher.OnFileChanged = function (msg)
	if(msg.type == "modified" or msg.type == "added" or msg.type=="renamed_new_name") then
		commonlib.log("File %s is %s in dir %s\n", msg.fullname, msg.type, msg.dirname)
		ParaAsset.Refresh(msg.fullname);
	end
end

-- this is a handy function that does above things
commonlib.FileSystemWatcher.EnableAssetFileWatcher()
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");

local FileSystemWatcher = {
	-- multiple watcher with the same name will share the same low level watcher object. 
	-- KNOWN ISSUES: only a single low level watcher object can be available per thread. Hence self.name must be unique. 
	name = "default",
	-- regular expression to filter file name. or it can also be a function(filename) ... end that returns true if the input file is accepted. 
	filter = ".*",
	-- how many milliseconds to delay before we fire an event. in case some program is writing to the file very frequently, we may receive many messages
	-- by using delay time, we will delete duplicated messages for the same file during the delay interval. 
	DelayInterval = 3000,
}
commonlib.FileSystemWatcher = FileSystemWatcher

local watcher_dirs = {}


-- mapping from watcher name to a list of instances. 
local call_backs = {}

local function registerCallback(o)
	local instances = call_backs[o.name];
	if(not instances) then
		instances = {};
		call_backs[o.name] = instances;
		local watcher = ParaIO.GetFileSystemWatcher(o.name);
		watcher:AddCallback(string.format("commonlib.FileSystemWatcher.OnFileCallback(%q);", o.name));
	end
	instances[#instances + 1] = o;
end

-- a new watcher class, do not create too many of this class, since they are never deleted. 
function FileSystemWatcher:new(o)
	o = o or {};
	setmetatable(o, self)
	self.__index = self
	o.msgs = {};
	o.timer = commonlib.Timer:new({callbackFunc = function(timer)
		FileSystemWatcher.DispatchEvent(o);
	end});
	
	-- add to call back instances
	registerCallback(o);
	return o
end

local type_to_name = {
	[0] = "null", 
    [1] = "added",
    [2] = "removed",
    [3] = "modified",
    [4] = "renamed_old_name",
    [5] = "renamed_new_name",
}

-- on file callback
function FileSystemWatcher.OnFileCallback(name)
	if(msg and msg.filename) then
		msg.type = type_to_name[msg.type] or msg.type;
		msg.fullname = msg.dirname..msg.filename;
		msg.fullname = string.gsub(msg.fullname, "\\", "/");
		-- debugging purposes
		LOG.std(nil, "debug", "FileSystemWatcher", "File %s is %s in dir %s", msg.fullname, msg.type, msg.dirname)
		local instances = call_backs[name];
		if(instances) then
			for i, instance in pairs(instances) do
				instance:AddMessage(msg);
			end
		end
	end	
end

-- whether to monitor all registered system file changes. 
function FileSystemWatcher:IsMonitorAll()
	return self.bMonitorAll;
end

function FileSystemWatcher:SetMonitorAll(bMonitorAll)
	self.bMonitorAll = bMonitorAll;
end

-- add message 
function FileSystemWatcher:AddMessage(msg)
	local bAcceptFile;
	if(self.dirs[msg.dirname] or self:IsMonitorAll()) then
		-- filter the message.
		if(type(self.filter) == "function") then
			bAcceptFile = self.filter(msg.filename);
		elseif(type(self.filter) == "string") then
			bAcceptFile = string.find(msg.filename, self.filter);
		end
		if(bAcceptFile) then
			self.msg = self.msg or {};
			self.msg[msg.fullname] = msg;
			if(not self.timer:IsEnabled()) then
				self.timer:Change(self.DelayInterval, nil);
			end
		end	
	end	
end

-- DispatchEvent all queued events in the last interval. 
function FileSystemWatcher:DispatchEvent()
	if(self.msg) then
		for filename, msg in pairs(self.msg) do
			-- modified
			if(self.OnFileChanged) then
				self.OnFileChanged(msg)
			end
		end
		self.msg = nil;
	end
end

-- add a dir to monitor
-- @param dir: such as "script/", "model/", "character"
function FileSystemWatcher:AddDirectory(dir)
	self.dirs = self.dirs or {};
	if(not self.dirs[dir]) then
		self.dirs[dir] = true;
		
		watcher_dirs[self.name] = watcher_dirs[self.name] or {};
		if(not watcher_dirs[self.name][dir]) then
			watcher_dirs[self.name][dir] = 1;
			local watcher = ParaIO.GetFileSystemWatcher(self.name);
			watcher:AddDirectory(dir);
		else
			watcher_dirs[self.name][dir] = watcher_dirs[self.name][dir]+ 1;	
		end	
	end
end

-- remove this file watcher. 
function FileSystemWatcher:Destroy()
	watcher_dirs[self.name] = nil;
	ParaIO.DeleteFileSystemWatcher(self.name);
end

-- remove a dir to watch 
function FileSystemWatcher:RemoveDirectory(dir)
	self.dirs = self.dirs or {};
	if(self.dirs[dir]) then
		self.dirs[dir] = nil;
		
		watcher_dirs[self.name] = watcher_dirs[self.name] or {};
		
		if(watcher_dirs[self.name][dir]>=1) then
			if(watcher_dirs[self.name][dir] == 1) then
				local watcher = ParaIO.GetFileSystemWatcher(self.name);
				watcher:RemoveDirectory(dir);
			else
				watcher_dirs[self.name][dir] = watcher_dirs[self.name][dir] -1;
			end	
		end	
	end
end

-- because it is so common to watch for asset file changes, we added the following function
-- call this at any time to start watching for files
function FileSystemWatcher.EnableAssetFileWatcher()
	if(not FileSystemWatcher.AssetFileWatcher) then
		-- watch files under model/ and character/ directory and Refresh it in case they are changed
		local watcher = commonlib.FileSystemWatcher:new()
		watcher.filter = function(filename)
			return string.find(filename, ".*") and not string.find(filename, "%.svn")
		end
		watcher:AddDirectory("model/")
		watcher:AddDirectory("character/")
		watcher:AddDirectory("Texture/")
		watcher.OnFileChanged = function (msg)
			if(msg.type == "modified" or msg.type == "added" or msg.type=="renamed_new_name") then
				if(ParaAsset.Refresh(msg.fullname)) then
					commonlib.log("AssetMonitor: File %s is refreshed in dir %s\n", msg.fullname, msg.dirname)
				end
			end
		end

		FileSystemWatcher.AssetFileWatcher = watcher;
	end
end

