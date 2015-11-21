--[[
Title: 
Author(s): Leio
Date: 2009/9/20
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
local msg = {
	gamename = "", --key
	gametitle = "",
	score = 0,
	ex_list = {
		{ label = "奇豆", num = 0, },
		{ label = "火龙珠", num = 0, },
		{ label = "菜头", num = 0, },
		{ label = "菜头", num = 0, },
	},
}
Map3DSystem.App.MiniGames.GameScorePage.Bind(msg);
Map3DSystem.App.MiniGames.GameScorePage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
-- default member attributes
local GameScorePage = {
	page = nil,
	align = "_ct",
	left = -250,
	top = -200,
	width = 500,
	height = 360, 
	hasSend = false,
	
	gamemsg = nil,
	--获取最大奇豆数量
	maxBean = 650,
}
commonlib.setfield("Map3DSystem.App.MiniGames.GameScorePage",GameScorePage);

function GameScorePage.OnInit()
	local self = GameScorePage;
	self.page = document:GetPageCtrl();
end
function GameScorePage.DS_Func_GameScorePage(index)
	local self = GameScorePage;
	 if(not self.ex_list)then return 0 end
	if(index == nil) then
		return #(self.ex_list);
	else
		return self.ex_list[index];
	end
end
function GameScorePage.ShowPage()
	local self = GameScorePage;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/MiniGames/GameScorePage.html", 
			name = "MiniGames.GameScorePage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = self.align,
				x = self.left,
				y = self.top,
				width = self.width,
				height = self.height,
		});
	self.hasSend = false;
end
function GameScorePage.ClosePage()
	local self = GameScorePage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MiniGames.GameScorePage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
	self.gamemsg = nil;	
	self.hasSend = false;
end
--[[
local msg = {
	gamename = "", --key
	gametitle = "",
	score = 0,
	ex_list = {
		{ label = "奇豆", num = 0, },
		{ label = "奇豆", num = 0, },
		{ label = "奇豆", num = 0, },
	},
}
--]]
function GameScorePage.Bind(msg)
	local self = GameScorePage;
	self.gamemsg = msg;
	self.ex_list = msg.ex_list;
	--通知任务增加数据
	MiniGameCommon.QuestDoAddValue(msg);
end
function GameScorePage.OnClick(btnName, values)
	local self = GameScorePage;
	if(btnName == "ok")then
		self.ClosePage();
	elseif(btnName == "send")then
		if(self.gamemsg)then
			if(not self.gamemsg.gamename or not self.gamemsg.score or self.gamemsg.score < 0 or self.hasSend == true)then 
				_guihelper.MessageBox("你已经上传过分数了！");
				return 
			end
			local msg = {
				gamename = self.gamemsg.gamename,
				score = self.gamemsg.score,
			}
			commonlib.echo("begin send minigame score:");
			commonlib.echo(msg);
			NPL.load("(gl)script/kids/3DMapSystemApp/API/minigame/paraworld.minigame.lua");
			paraworld.minigame.SubmitRank(msg,"minigame",function(msg)	
				commonlib.echo("after send minigame score:");
				commonlib.echo(msg);
				_guihelper.MessageBox("上传成功！");
				self.hasSend = true;
			end);
		end
	elseif(btnName == "view")then
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameRankPage.lua");
		Map3DSystem.App.MiniGames.GameRankPage.Bind(self.gamemsg.gamename,self.gamemsg.gametitle);
		Map3DSystem.App.MiniGames.GameRankPage.ShowPage();
	end
end
