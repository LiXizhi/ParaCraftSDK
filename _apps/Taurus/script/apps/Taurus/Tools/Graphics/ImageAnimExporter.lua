--[[
Title: Code behind page
Author(s): LiXizhi
Date: 2011/2/7
Desc: export a ParaX animation to a sequence of image files with alpha channels. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/Tools/Graphics/ImageAnimExporter.lua");
-------------------------------------------------------
]]
local ImageAnimExporter = commonlib.gettable("MyCompany.Taurus.Tools.graphics.ImageAnimExporter")

---------------------------------
-- page event handlers
---------------------------------
local page;

function ImageAnimExporter.Init()
	page = document:GetPageCtrl();
	local self = page;

	local assets = Map3DSystem.App.Assets.app:ReadConfig("RecentlyOpenedAssets", {})
	local index, value
	for index, value in ipairs(assets) do
		self:SetNodeValue("filepath", commonlib.Encoding.DefaultToUtf8(value));
	end
	self:SetNodeValue("filepath", "");
end

-- User clicks a file
function ImageAnimExporter.OnSelectFile(name, filepath)
	local old_path = commonlib.Encoding.Utf8ToDefault(page:GetUIValue("filepath"));
	if(old_path ~= filepath) then
		page:SetUIValue("filepath", commonlib.Encoding.DefaultToUtf8(filepath));
		ImageAnimExporter.OnClickRefreshPreview_Internal(true);
	end	
end

-- user doublle clicks a file, it will select it and add it to scene. 
function ImageAnimExporter.OnDoubleClickFile(name, filepath)
	
end

-- refresh the current page. 
function ImageAnimExporter.OnClickRefreshPreview()
	ImageAnimExporter.OnClickRefreshPreview_Internal();
end

-- private function
-- @param silentMode : if true no UI alert is displayed. 
function ImageAnimExporter.OnClickRefreshPreview_Internal(silentMode, bBookmark)
	local filepath = commonlib.Encoding.Utf8ToDefault(page:GetUIValue("filepath") or "");
	local _,_, ext = string.find(filepath, "%.(%w+)$");
	if(ext ~= nil) then
		ext = string.lower(ext);
	end
	local IsUnknown;
	if(ext==nil or filepath == nil or filepath =="") then
		if(not silentMode) then
			_guihelper.MessageBox("请先选择一个X文件");
		end	
		IsUnknown = true;
	elseif(not ParaIO.DoesFileExist(filepath)) then
		if(not silentMode) then
			_guihelper.MessageBox(string.format("X文件 %s 不存在.", filepath));
		end
		IsUnknown = true;
	elseif(ext == "x" or ext == "xml") then
		-- refresh the file. 
		local asset = Map3DSystem.App.Assets.asset:new({filename = filepath})
		ImageAnimExporter.cur_filename = filepath;
		-- refresh the model in modelCanvas control. 
		local objParams = asset:getModelParams()
		if(objParams~=nil) then
			local canvasCtl = page:FindControl("modelCanvas");
			if(canvasCtl) then
				canvasCtl:ShowModel(objParams);
				
				local icon = asset:getIcon();
				if(ParaIO.DoesFileExist(icon)) then
					page:SetUIValue("ThumbnailImg", icon);
				end
			end
		else
			IsUnknown = true;	
		end

		-- save to recently opened assets
		if(bBookmark) then
			local assets = Map3DSystem.App.Assets.app:ReadConfig("RecentlyOpenedAssets", {})
			local bNeedSave;
			-- sort by order
			local index, value, found
			for index, value in ipairs(assets) do
				if(value == filepath) then
					if(index>1) then
						commonlib.moveArrayItem(assets, index, 1)
						bNeedSave = true;
					end	
					found = true;
					break;
				end
			end
			if(not found) then
				commonlib.insertArrayItem(assets, 1, filepath)
				bNeedSave = true;
			end
			if(bNeedSave) then
				if(#assets>50) then
					commonlib.resize(assets, 50)
				end
				local canvasCtl = page:FindControl("filepath");
				if(canvasCtl) then
					canvasCtl:InsertItem(filepath);
				end
				
				Map3DSystem.App.Assets.app:WriteConfig("RecentlyOpenedAssets", assets)
				Map3DSystem.App.Assets.app:SaveConfig();
				LOG.std(nil, "system", "ImageAnimExporter", "book mark saved");
			end
		end
	else
		IsUnknown = true;
		if(not silentMode) then
			_guihelper.MessageBox("请先选择一个X文件");
		end	
	end
	
	-- unknown file format
	if(IsUnknown) then
		local canvasCtl = page:FindControl("modelCanvas");
		if(canvasCtl) then
			canvasCtl:ShowImage("");
			page:SetUIValue("ThumbnailImg", "");
		end	
	end	
end

-- take snapshot
function ImageAnimExporter.OnClickTakeSnapShot()
	local filepath = commonlib.Encoding.Utf8ToDefault(page:GetUIValue("filepath"));
	local _,_, ext = string.find(filepath, "%.(%w+)$");
	if(ext ~= nil) then
		ext = string.lower(ext);
	end
	
	if(not ParaIO.DoesFileExist(filepath)) then
		_guihelper.MessageBox(string.format("X文件 %s 不存在.", filepath));
	elseif(ext == "x" or ext == "xml") then
		-- refresh the file. 
		local asset = Map3DSystem.App.Assets.asset:new({filename = filepath})
		
		local icon = asset:getIcon();
		-- only save for Non-http icon to disk. 
		if(icon and string.find(icon,"^http")==nil) then
			icon = string.gsub(icon, ":.*$", "")
			local ctl = page:FindControl("modelCanvas");
			if(ctl) then
				local dlgText;
				if(ParaIO.DoesFileExist(icon, true)) then	
					dlgText = string.format("文件: %s 已经存在, 您确定要覆盖它么?", icon);
				else
					dlgText = string.format("您确定要保存到文件: %s 么?", icon);
				end
				local pageCtrl = page;
				_guihelper.MessageBox(dlgText, function ()
					ImageAnimExporter.SaveCurrentFrameToFile(icon, 64);
					-- refresh all control to reflect the changes. 
					pageCtrl:SetUIValue("ThumbnailImg", icon);
				end)
			end
		end	
	else
		_guihelper.MessageBox("请选择ParaX模型文件");	
	end
end

-- save the current frame to file
-- @param filename: the file name to save to
-- @param resolution: if nil, it defaults to 64 pixels
function ImageAnimExporter.SaveCurrentFrameToFile(filename, resolution)
	local ctl = page:FindControl("modelCanvas");
	if(ctl and filename) then
		resolution = resolution or 64;
		ctl:SaveToFile(filename, resolution);
		-- reload asset.
		CommonCtrl.OneTimeAsset.Unload(filename);
		LOG.std(nil, "user", "ImageAnimExporter",  "%s is saved",  filename);
	end
end