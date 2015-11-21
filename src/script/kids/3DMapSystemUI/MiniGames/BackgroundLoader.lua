--[[
Title: 
Author(s): Leio
Date: 2009/10/28
Desc:
ºóÌ¨ÏÂÔØ
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BackgroundLoader.lua");
Map3DSystem.App.MiniGames.BackgroundLoader.Load();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FileLoader.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.background_loader.lua");
local FileLoader = commonlib.gettable("CommonCtrl.FileLoader")

local BackgroundLoader = {
	loader = nil
}
commonlib.setfield("Map3DSystem.App.MiniGames.BackgroundLoader",BackgroundLoader);

function BackgroundLoader.Load()
	local self = BackgroundLoader;
	commonlib.echo("===========================start get paraworld.background_loader list");
	local msg = {
	
	};
	paraworld.background_loader.GetList(msg,"background_loader",function(msg)	
		commonlib.echo("=========================== after get paraworld.background_loader list");
		--commonlib.echo(msg);
		if(msg and msg.data)then
			local data = msg.data;
			local line;
			local file_list = {};
			local totalDownload = 0;
			for line in string.gfind(data, "[^\n]+") do
				if(line)then
					local __,__,filename,filesize = string.find(line,"(.+),(.+)");
					filesize = tonumber(filesize) or 1;
					if(filename and filename ~= "" and filesize and filesize > 0)then
						local item = {
							filename = filename,
							filesize = filesize,
						}
						table.insert(file_list,item);
						totalDownload = totalDownload +1;
					end
				end
			end
			--commonlib.echo(totalDownload);
			--commonlib.echo(file_list);
			commonlib.echo("warning: Background loader is obsoleted and no longer used")
			
			if(file_list and totalDownload and totalDownload > 10)then
				if(not self.loader)then
					self.loader = FileLoader:new{
						logname = "log/background_loader",
					};
				end
				self.loader:SetDownloadList(file_list);
				
				self.loader:AddEventListener("finish",function(self,event)
					commonlib.echo("paraworld.background_loader is finished.");
				end,{});
				self.loader:Start();
				commonlib.echo("paraworld.background_loader is start now.");
			else
				commonlib.echo("paraworld.background_loader list list is nil");
			end
		end
	end);
end


