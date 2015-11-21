--[[
Title: 
Author(s): Leio
Date: 2009/10/27
Desc:
加载flash 或者 电子书的 loading bar
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FileLoader.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/SwfLoadingBarPage.lua");
-- default member attributes
local PreLoaderDialog = {
	loader = nil,
	load_txt = nil,
	callbackFunc = nil,
	custom_percent = 0.4,--下载多少打开杂志
	--default_txt = {
		--"加载当中，请稍等"
	--}
}
commonlib.setfield("Map3DSystem.App.MiniGames.PreLoaderDialog",PreLoaderDialog);
--[[
	msg = {
		download_list = {filename = "",filesize = 1,},
		txt = {
			"加载当中，请稍等",
		}
	}
--]]
function PreLoaderDialog.StartDownload(msg,callbackFunc)
	local self = PreLoaderDialog;
	
	
	local download_list = msg.download_list;
	self.load_txt = msg.txt or self.default_txt;
	self.callbackFunc = callbackFunc;
	local loadingPage = Map3DSystem.App.MiniGames.SwfLoadingBarPage;
	--确信关闭
	loadingPage.ClosePage();
	
	if(not self.loader)then
		self.loader = CommonCtrl.FileLoader:new{
			download_list = download_list,
			logname = "log/magazine_loader",
		}
	end
	local fileLoader = self.loader;
	commonlib.echo("============PreLoaderDialog DownloadList");
	commonlib.echo(download_list);
	
	
	fileLoader:AddEventListener("start",self.Start,self);
	fileLoader:AddEventListener("loading",self.Loading,self);
	fileLoader:AddEventListener("finish",self.Finish,self);
	
	--重置下载列表
	fileLoader:SetDownloadList(download_list)
	fileLoader:Start();
end
function PreLoaderDialog.Start(self,event)
	local self = PreLoaderDialog;
	commonlib.echo("============PreLoaderDialog.Start");
	Map3DSystem.App.MiniGames.SwfLoadingBarPage.ShowPage({
		show_background = false,
		txt = self.load_txt,
		showCloseBtn = true,
		isTopLevel = true,
	});
	
	Map3DSystem.App.MiniGames.SwfLoadingBarPage.loaderCancelFunc = function()
		if(self.loader)then
			self.loader:Stop();
		end
	end
end
function PreLoaderDialog.Loading(self,event)
	local self = PreLoaderDialog;
	commonlib.echo("============PreLoaderDialog.Loading");
	commonlib.echo(event);
	if(event and event.percent)then
		local p = event.percent;
		Map3DSystem.App.MiniGames.SwfLoadingBarPage.Update(p);

		if(p >= self.custom_percent)then
			self.Finish();
		end
	end
end
function PreLoaderDialog.Finish(self,event)
	local self = PreLoaderDialog;
	commonlib.echo("============PreLoaderDialog.Finish");
	Map3DSystem.App.MiniGames.SwfLoadingBarPage.ClosePage();
	
	if(self.callbackFunc)then
		local msg = {
			state = "finished",
		}
		self.callbackFunc(msg);
	end
	--如果是自定义的下载百分比，真正的下载并没有关闭，清空事件，让它在后台下载
	if(self.loader)then
		self.loader:ClearAllEvents();
	end
end
