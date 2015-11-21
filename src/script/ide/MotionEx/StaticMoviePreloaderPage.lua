--[[
Title: StaticMoviePreloaderPage
Author(s): Leio
Date: 2012/01/13
Desc: 电影资源预加载
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local file_path = "config/Aries/StaticMovies/FlamingPhoenixIsland_TheGreatTree_Hero_Login.xml"
MotionXmlToTable.PlayCombatMotion(file_path);
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/FileLoader.lua");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local StaticMoviePreloaderPage = commonlib.gettable("MotionEx.StaticMoviePreloaderPage");
StaticMoviePreloaderPage.file_loader = nil;
StaticMoviePreloaderPage.file_path = nil;
function StaticMoviePreloaderPage.Load(file_path,percent,callbackFunc)
	local self = StaticMoviePreloaderPage;
	if(not file_path)then return end
	percent = percent or 1;
	local asset_list = self.GetAssetList(file_path)
	if(not self.file_loader)then
		self.file_loader = CommonCtrl.FileLoader:new()
		self.file_loader.logname = "log/staticmovie_loader";--log文件地址
	end
	self.file_loader:SetDownloadList(asset_list);--下载文件列表
	self.file_loader:ClearAllEvents();

	self.file_loader:AddEventListener("start",function(self,event)
		StaticMoviePreloaderPage.ShowPage();
	end,{});
	self.file_loader:AddEventListener("loading",function(self,event)
		StaticMoviePreloaderPage.title = "进行";
		if(event and event.percent)then
			local p = event.percent;
			if(p >= percent)then
				StaticMoviePreloaderPage.ClosePage();
				StaticMoviePreloaderPage.file_loader:Stop();
			else
				StaticMoviePreloaderPage.RefreshPage();
			end
		end
	end,{});
	self.file_loader:AddEventListener("finish",function(self,event)
		StaticMoviePreloaderPage.ClosePage();
	end,{});
	self.temp_close = false;
	self.callbackFunc = callbackFunc;
	self.file_loader:Start();
end
function StaticMoviePreloaderPage.OnInit()
	local self = StaticMoviePreloaderPage;
	self.page = document:GetPageCtrl();
end
function StaticMoviePreloaderPage.ShowPage()
	local self = StaticMoviePreloaderPage;
	local params = {
				url = "script/ide/MotionEx/StaticMoviePreloaderPage.html", 
				name = "StaticMoviePreloaderPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -5000/2,
					y = -5000/2,
					width = 5000,
					height = 5000,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);		
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			if(not self.temp_close)then
				self.temp_close = true;
				if(self.callbackFunc)then
					self.callbackFunc();
				end
			end
		end
	end
end
function StaticMoviePreloaderPage.ClosePage()
	local self = StaticMoviePreloaderPage;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function StaticMoviePreloaderPage.RefreshPage()
	local self = StaticMoviePreloaderPage;
	if(self.page)then
		self.page:Refresh(0);
	end
end
function StaticMoviePreloaderPage.GetAssetList(file_path)
	local self = StaticMoviePreloaderPage;
	if(not file_path)then return end
	local xmlRoot = ParaXML.LuaXML_ParseFile(file_path);
	local node;
	local order_map = {
		["ogg"] = 1,["x"] = 2,["png"] = 3,["xml"] = 4,
	}
	local asset_list = {};
	local asset_map = {};

	local function get_list(xpath)
		for node in commonlib.XPath.eachNode(xmlRoot, xpath) do
			local AssetFile = node.attr.AssetFile;
			if(AssetFile and AssetFile ~= "" and not asset_map[AssetFile])then
				local _,_, ext = string.find(AssetFile, "%.(%w+)$");
				local order = order_map[ext] or 1000;
				asset_map[AssetFile] = AssetFile;
				table.insert(asset_list,{filename = AssetFile, order = order});
			end
		end
	end
	get_list("//Frame");
	get_list("//Frame/Arena/Object");
	table.sort(asset_list,function(a,b)
		return a.order < b.order;
	end)
	return asset_list;
end