--[[
Title: FileLoader
Author(s): Leio, LiXizhi
Date: 2010/01/21, 
Desc: A file loader to download one file at a time, which global progress callback and per-file callback. 
refactored by LiXizhi 2011.7.2 (more robust and support dynamically adding files, improved performance)
   * duplicated files are removed.  
   * dynamically adding files
   * pause/resume at any time
   * file downloaded callback added
   * use two queues to accelerate file checking at each step. 
   * makes functio names better to understand
   * total file size and downloaded file size are computed incrementally. RegulateDownloadList function is thus obsoleted. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/FileLoader.lua");
local download_list = {
	{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic00.png", filesize = 100, },
	{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic01.png" },
	{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic02.png" },
	{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic03.png" },
	{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic04.png" },
	{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic05.png" },
}
local fileLoader = CommonCtrl.FileLoader:new{
	download_list = download_list,--下载文件列表
	logname = "log/magazine_loader",--log文件地址
}
fileLoader:AddEventListener("start",function(self,event)
	commonlib.echo("=======test start");
	commonlib.echo(event);
end,{});
fileLoader:AddEventListener("loading",function(self,event)
	commonlib.echo("=======test loading");
	commonlib.echo(event);
	if(event and event.percent)then
		local p = event.percent;
		if(p >=0.5)then
		end
	end
end,{});
fileLoader:AddEventListener("finish",function(self,event)
	commonlib.echo("=======test finish");
	commonlib.echo(event);
end,{});
--fileLoader:SetDownloadList(download_list);
fileLoader:Start();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/timer.lua");
local FileLoader = commonlib.inherit({
	-- size of all files that is added to the downloader
	total_file_size = 0,
	-- total file sizes that are finished or timed out or failed. 
	finished_size = 0, 
	-- if finished
	isFinished = false,
	
	-- if this table exist in constructor, all files in it will be added to the downloader.  
	download_list = nil,

	-- if "", it will not write log
	logname = "log/file_loader",
	-- timer to check for next file
	download_timer = nil,
	-- file download timer duration. 
	file_duration = 100,
	-- max number of current download
	max_concurrent_download = 1,
	-- private: how long the last pending file is being downloaded. 
	cur_file_download_time = 0;
	-- the max time(milli-seconds) a file is permitted to be downloaded. if it exceeds, the file is marked timed out and the loader move on to the next file in the list. 
	max_file_download_time = 1200000,
	
	-- private: to prevent adding duplicated files
	filename_map = nil,
}, commonlib.gettable("CommonCtrl.FileLoader"))

local npl_profiler = commonlib.gettable("commonlib.npl_profiler");

local loaders = {};
-- static global function: create get a loader with a given asset preload filename
-- @param filename: xml preloader file
function FileLoader.CreateGetLoader(filename)
	if(not loaders[filename]) then
		local loader = FileLoader:new();
		loaders[filename] = loader;
		loader:LoadFile(filename);
	end
	return loaders[filename];
end

--constructor
function FileLoader:ctor()
	self.uid = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.uid, self);
	
	self.events = commonlib.EventDispatcher:new();

	self.download_timer = commonlib.Timer:new({callbackFunc = function(timer)
		-- add file_duration
		self:CheckDownloadList(self.file_duration);
	end})

	self.filename_map = {};
	self.pending_files = commonlib.List:new();
	self.finished_files = commonlib.List:new();

	-- add files to download
	self:SetDownloadList(self.download_list);
end

-- clear all files and stop download timer
function FileLoader:Reset()
	self.pending_files:clear();
	self.finished_files:clear();
	self.total_file_size = 0;
	self.finished_size = 0;
	self.isFinished = false;
	self.filename_map = {};
	self.download_timer:Change();
end


-- clear all download files and add a group of files to be downloaded. 
-- @param download_list: an array of table {{filename, filesize, callbackFunc}, ... }
function FileLoader:SetDownloadList(download_list)
	self:Reset();
	if(download_list) then
		-- clear all files
		local _, file_params
		for _, file_params in ipairs(download_list) do
			self:AddFile(file_params.filename, file_params.filesize, file_params.callbackFunc);
		end
	end
end

-- add a given file. this function call be called at any time. 
-- one needs to call Start() in case the timer already finished, however, it will automatically set isFinished to false. 
-- @param filename: filename
-- @param filesize: if nil, it will be 1. 
-- @param callbackFunc: a function(bIsSuccess, filename) end, where bIsSuccess is true if file is not asset, or just downloaded. 
-- @return true if file is added. otherwise it may mean that the file is already in the list.
function FileLoader:AddFile(filename, filesize, callbackFunc)
	if(not filename or self.filename_map[filename]) then
		return
	end
	self.filename_map[filename] = true;
	self.pending_files:add({filename = filename, filesize=filesize, callbackFunc=callbackFunc});
	self.total_file_size = self.total_file_size + (filesize or 1);
	self.isFinished = false;
	return true;
end

-- whether the Start() function has been called at least once. 
function FileLoader:isStarted()
	return self.isStarted;
end

-- start the download timer to begin downloading file one at a time. 
-- return true if finished. 
function FileLoader:Start()
	self.isStarted = true;
	self.isFinished = false;
	self:DispatchEvent({
		type = "start",
	});
	
	if(self.logname and self.logname~="") then
		commonlib.servicelog.GetLogger(self.logname):SetLogFile(self.logname..".log")
		commonlib.servicelog.GetLogger(self.logname):SetAppendMode(false);
		commonlib.servicelog.GetLogger(self.logname):SetForceFlush(true);
		self:log("load file: start");
	end

	self:ResetFileTimer();
	return self:CheckDownloadList();
end

-- print log to file. 
function FileLoader:log(...)
	if(self.logname and self.logname~="") then
		commonlib.servicelog(self.logname, ...);
	end
end

-- pause downloading file
function FileLoader:Stop()
	self.cur_file_download_time = 0;
	self:ResetFileTimer();
end

-- pause downloading file
function FileLoader:Pause()
	self:Stop();
end

function FileLoader:Resume()
	if(not self.isFinished) then
		if(not self.download_timer:IsEnabled()) then
			self.download_timer:Change(self.file_duration,self.file_duration);
		end
	end
end

-- remove finished file from pending list to downloaded list and invoke callback
-- @param r: the value returned from ParaIO.CheckAssetFile(filename)
-- return the next file item to be downloaded
function FileLoader:remove_finished_file(r, file_item)
	local filename = file_item.filename;
	local filesize = file_item.filesize;

	self.finished_size = self.finished_size + (filesize or 1);
	local sMsg = "";
	local bSuccess = true;
	if(r == -4)then
		sMsg = "input file is not an asset file";
	elseif(r ==  -1)then
		sMsg = "we are unable to download the asset file after trying serveral times";
		bSuccess = false;
	elseif(r ==  1)then
		sMsg = "already downloaded";
	end
	self:log("load file: [%s]%s", filename, sMsg);

	-- move file from pending file list to downloaded file list.
	local next_item = self.pending_files:remove(file_item);
	self.finished_files:add(file_item);
	self.cur_file_download_time = 0;
	if(file_item.callbackFunc) then
		file_item.callbackFunc(bSuccess, filename);
	end
	if(not next_item) then
		-- in case the call back added new item. 
		next_item = self.pending_files:first();
	end
	return next_item;
end

-- resumes downloading. 
-- perform a check on all files. it will call onfinished handler if finished. 
-- @param file_duration: nil or the number of milliseconds to add to cur_download_file. 
-- if a file has been downloading longer than max_file_download_time.
-- return true if finished. 
function FileLoader:CheckDownloadList(file_duration)
	local file_item = self.pending_files:first();
	file_duration = file_duration or 0;
	local newly_finished_count = 0;
	while (file_item) do
		local filename = file_item.filename;
		local filesize = file_item.filesize;
		
		local r = ParaIO.CheckAssetFile(filename)
		--[[
		* 1 if already downloaded; 
		* 0 if asset has not been downloaded; 
		* -1 if we are unable to download the asset file after trying serveral times; 
		* -3 if asset is being downloaded but is not completed; 
		* -4 if input file is not an asset file. 
		--]]
		if(r == - 4 or r == -1 or r == 1)then
			-- move on to the next file
			newly_finished_count = newly_finished_count + 1;
			file_duration = 0;
			file_item = self:remove_finished_file(r, file_item);
		else
			-- file is being downloaded
			if(self.cur_file_download_time < self.max_file_download_time)then
				self.cur_file_download_time = self.cur_file_download_time + file_duration;

				-- only set next file if it is not being downloaded. 
				if(r == 0 or r == -3) then
				else
					self:log("unknown file status: %d for file %s", r, filename);
				end	
				-- exit loop
				break;
			else
				-- warning: download timeout
				self:log("warning: file download is timed out: for file %s", filename);

				-- move on to the next file
				newly_finished_count = newly_finished_count + 1;
				file_duration = 0;
				file_item = self:remove_finished_file(r, file_item);
			end
		end
	end
	
	-- inform progress if there is any newly downloaded file.
	if(newly_finished_count>0) then
		local p = self:GetPercent();
		self:DispatchEvent({
			type = "loading",
			percent = p,
		});
	end
	
	-- if finished.
	if(self.pending_files:size() == 0)then
		self:log("load file: finished");
		self:DispatchEvent({
			type = "finish",
		});
		self:DispatchEvent({
			type = "finish_ex",
		});
		self.isFinished = true;
		self:ResetFileTimer();
		return true;
	else
		--if(newly_finished_count>0) then
			self:LoadOneFile();
		--end
	end
end

-- max number of concurrent download allowed. default to 1.
function FileLoader:SetMaxConcurrentDownload(nCount)
	self.max_concurrent_download =  nCount or self.max_concurrent_download;
end

-- load the next file(up to self.max_concurrent_download) in the pending list
function FileLoader:LoadOneFile()
	local file = self.pending_files:first();
	local nCurrentDownload = 1;
	while (file and nCurrentDownload<=self.max_concurrent_download) do
		nCurrentDownload = nCurrentDownload + 1;
		local next_file = file.filename;

		-- local nItemLeft = ParaEngine.GetAsyncLoaderItemsLeft(-2);

		-- download the next_file, if there are no other files being downloaded at the same time. 
		if(next_file and self.filename_map[next_file] ~= "loaded") then
			self.filename_map[next_file] = "loaded"
			local sMsg = string.format(";CommonCtrl.FileLoader.DownloadCallback('%s');", self.uid or "");
			self:log("load file: %s", next_file);
			ParaIO.SyncAssetFile_Async(next_file, sMsg);
			self:ResetFileTimer();
			self.download_timer:Change(self.file_duration,self.file_duration);
		end	

		file = self.pending_files:next(file);
	end
	
end

-- private: callback of ParaIO.SyncAssetFile_Async
function FileLoader.DownloadCallback(name)
	local self = CommonCtrl.GetControl(name);
	if(self)then
		-- self:ResetFileTimer();
		self:CheckDownloadList();
	end
end

-- simply stop the timer.
function FileLoader:ResetFileTimer()
	self.download_timer:Change();
end


-- get percentage of download progress between [0,1]
function FileLoader:GetPercent()
	if(self.pending_files:size() == 0)then 
		return 1;
	end
	local total_size = self:GetAllFileSize();
	if(not total_size or total_size == 0)then
		return 1;
	end
	return self.finished_size / total_size;
end

-- this is not the actual file count, but the file count assuming file size are even. 
function FileLoader:GetUnfinishedFileCount()
	return self.pending_files:size();
end

-- get total file count both finished and unfinished. 
function FileLoader:GetFileCount()
	return self.pending_files:size() + self.finished_files:size();
end

-- get total file sizes including finished and pending ones.
function FileLoader:GetAllFileSize()
	return self.total_file_size;
end

function FileLoader:IsFinished()
	return self.isFinished;
end

-- register glboal progress event
-- @param event_name: "start" "loading" "finish"
function FileLoader:AddEventListener(event_name,func,funcHolder)
	self.events:AddEventListener(event_name, func, funcHolder)
end

function FileLoader:RemoveEventListener(event_name)
	self.events:RemoveEventListener(event_name)
end
function FileLoader:DispatchEvent(event)
	self.events:DispatchEvent(event)
end
function FileLoader:ClearAllEvents()
	self.events:ClearAllEvents();
end

-- load config file from a given filepath
-- @param filepath: the file must be an asset file. 
function FileLoader:LoadFile(filepath)
	if(not filepath)then return end
	local file_list = {};
	local line
	local file = ParaIO.open(filepath, "r");
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			local __,__,filename,filesize = string.find(line,"(.+),(.+)");
			filesize = tonumber(filesize) or 1;
			if(filename and filename ~= "" and filesize and filesize > 0)then
				local item = {
					filename = filename,
					filesize = filesize,
				}
				table.insert(file_list,item);
			end
			line=file:readline();
		end
		file:close();
	end	
	self:SetDownloadList(file_list);
end