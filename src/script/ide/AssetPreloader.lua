--[[
Title: Preload asset
Author(s): LiXizhi
Date: 2009/9/5
Desc: Preload a group of assets(texture, models, normal file etc), and provide a callback about the progress. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/AssetPreloader.lua");
local loader = commonlib.AssetPreloader:new({
	callbackFunc = function(nItemsLeft, loader)
		log(nItemsLeft.." assets remaining\n")
		if(nItemsLeft <= 0) then
			log("all finished \n")
		end
	end
});
loader:AddAssets(ParaAsset.LoadTexture("","character/v3/PurpleDragonEgg/egg1.dds",1));
loader:AddAssets("audio/test.wav");

-- nested calls with callbacks are supported, see WorldAssetPreloader.AppendBaseWorldAssets for example.
loader:AddFileAsset(base_world.sConfigFile, function(bSucceed)
		if(bSucceed) then
			local config_file = ParaIO.OpenAssetFile(base_world.sConfigFile);
			if(config_file:IsValid()) then
				-- read some other files and then call AddFileAsset as nested call is permitted. 
				-- loader:AddFileAsset(...);
			end
		else
			_guihelper.MessageBox(format("无法下载资源:%s. 请检查你的网络连接，并重新尝试", filename));
		end
	end)

loader:Start();


-------------------------------------------------------
]]

NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/FileLoader.lua");

local AssetPreloader = {
	-- call back function (timer) end
	callbackFunc = nil,
	-- must be unique
	timer = nil,
	-- The time interval between invocations of the callback method in milliseconds. 
	-- Specify nil to disable periodic signaling. 
	period = 300,
	-- number of non-file asset. 
	total_non_file_asset = 0,
	-- assets: a group of assets
	assets = {}
}
commonlib.AssetPreloader = AssetPreloader;

-- a new timer class with infinite time. 
function AssetPreloader:new(o)
	o = o or {};
	o.assets = o.assets or {};

	setmetatable(o, self)
	self.__index = self
	return o
end

-- clear all pending requests and stops the timer. 
function AssetPreloader:clear()
	self.assets = {};
	if(self.timer) then
		self.timer:Change();
	end
end

-- add assets
-- @param assets: array of ParaAssetObject. or just a single ParaAssetObject
-- it can also be a regular asset file string in the asset manifest file. 
-- it can also be a class table containing IsLoaded() and IsValid() method. IsLoaded() is called every frame 
-- in which one can further add new objects, using this function. 
function AssetPreloader:AddAssets(assets)
	if(type(assets) == "table" and not assets.IsValid) then
		local _, asset
		for _,asset in pairs(assets) do
			self:add_asset(asset)
		end
	else
		self:add_asset(assets)
	end
	return true;
end

-- add a single asset 
-- @param asset: a file string or a ParaAssetObject or a table containing IsLoaded() and IsValid() method. IsLoaded() is called every frame 
-- in which one can further add new objects, using this function. 
function AssetPreloader:add_asset(asset)
	local dest_assets = self.assets;
	if(self.locked) then
		self.assets_pending = self.assets_pending or {};
		dest_assets = self.assets_pending;
	end
	if(type(asset) == "string") then
		self:GetFileLoader():AddFile(asset);
	else
		dest_assets[#(dest_assets) + 1] = asset;
		self.total_non_file_asset = self.total_non_file_asset + 1;
	end
end

-- add a file asset with callback when file is downloaded.
-- nested calls with callbacks are supported, such that one can read a downloaded file to add other files to the same loader.
-- @param filename: the filename of the asset
-- @param callbackFunc: a function(bIsSuccess, filename) end, where bIsSuccess is true if file is not asset, or just downloaded. 
-- @return: this function returns true if added to queue. if file does not exist, it simply fails.
function AssetPreloader:AddFileAsset(filename, callbackFunc)
	if(not ParaIO.DoesAssetFileExist(filename, true)) then
		LOG.std(nil, "debug", "AssetPreloader", "ignored adding file %s. since it does not exist", filename)
		return false;
	end
	if(not callbackFunc) then
		return self:add_asset(filename)
	end
	self:GetFileLoader():AddFile(filename, nil, callbackFunc);
end

-- get the file loader
function AssetPreloader:GetFileLoader()
	if(not self.fileloader) then
		self.fileloader = CommonCtrl.FileLoader:new();
	end
	return self.fileloader;
end

-- private: lock add, so that calls made between this and unlock_add will be delayed to assets_pending table
function AssetPreloader:lock_add()
	self.locked = true;
end

-- private: unlock it. 
function AssetPreloader:unlock_add()
	self.locked = nil;
	if(self.assets_pending) then
		local nCount = #self.assets_pending
		self:AddAssets(self.assets_pending);
		self.assets_pending = nil;
		return nCount;
	end
	return 0;
end

-- resume preloader
function AssetPreloader:Resume()
	if(self.fileloader) then
		self.fileloader:Resume();
	end
end

-- return the total number of items, including finished and unfinished. 
function AssetPreloader:GetAssetsCount()
	if(self.fileloader) then
		return self.total_non_file_asset + self.fileloader:GetFileCount();
	else
		return self.total_non_file_asset;
	end
end

-- get only unfinished count. 
function AssetPreloader:GetUnfinishedCount()
	if(self.fileloader) then
		return #(self.assets) + self.fileloader:GetUnfinishedCount();
	else
		return #(self.assets);
	end
end

-- internally it will prevent the last items_left==0 to be sent multiple times. 
-- @param items_left: items left. 
function AssetPreloader:OnProgress(items_left)
	if(items_left <= 0) then
		if(not self.is_finished) then
			self.is_finished = true;
			self:Stop();
		else
			return
		end
	end
	if(self.callbackFunc) then
		self.callbackFunc(items_left, self);
	end
end

-- start the assets loader. It will automatically stop when there are no more unloaded assets remaining. 
-- make sure to AddAssets() before calling this function. 
function AssetPreloader:Start()
	self.is_finished = false;
	local loader = self;
	if(self.fileloader) then
		self.fileloader:AddEventListener("finish",function(self,event)
			local items_left = #(self.assets);
			self:OnProgress(items_left);
		end, self);
		self.fileloader:Start();
	end
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		-- unfinished assets
		local assets = {};
		local _, asset
		loader:lock_add();
		for _,asset in pairs(loader.assets) do
			if(not asset:IsLoaded()) then
				if(asset:IsValid()) then
					assets[#assets + 1] = asset;
				else
					LOG.std(nil, "error", "AssetPreloader", "asset %s is invalid. Either download failed or asset itself is corrupted", asset:GetKeyName());
				end
			end
		end
		loader.assets = assets; -- swap assets

		-- this function may add additional unfinished assets to loader.assets during lock phase
		loader:unlock_add(); 
		
		local items_left = #assets;
		if(self.fileloader) then
			local file_unfinished = self.fileloader:GetUnfinishedFileCount();
			if(file_unfinished > 0) then
				items_left = items_left + file_unfinished;
				self.fileloader:Resume(); -- in case it is stopped we will resume it. 
			end
		end
		loader:OnProgress(items_left);
	end})
	-- start the timer after 0 milliseconds, and signal every 300 millisecond
	self.timer:Change(0, self.period);
end

-- force stop. 
function AssetPreloader:Stop()
	-- now kill the timer.
	if(self.timer) then
		self.timer:Change();
	end
end