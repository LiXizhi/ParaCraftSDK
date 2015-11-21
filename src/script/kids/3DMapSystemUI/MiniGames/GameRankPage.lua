--[[
Title: 
Author(s): Leio
Date: 2009/9/20
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameRankPage.lua");
Map3DSystem.App.MiniGames.GameRankPage.Bind("beats");
Map3DSystem.App.MiniGames.GameRankPage.ShowPage();

local source_list = 
{
	{ label = "test", score = 0, nid = 111,},
	{ label = "test1", score = 10,},
}
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/minigame/paraworld.minigame.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
-- default member attributes
local GameRankPage = {
	page = nil,
	align = "_ct",
	left = -320,
	top = -280,
	width = 640,
	height = 560, 
	
	ranks = nil,
}
commonlib.setfield("Map3DSystem.App.MiniGames.GameRankPage",GameRankPage);

function GameRankPage.OnInit()
	local self = GameRankPage;
	self.page = document:GetPageCtrl();
end
function GameRankPage.DS_Func_Items(index)
	local self = GameRankPage;
	if(not self.ranks)then return 0 end
	if(index == nil) then
		return #(self.ranks);
	else
		return self.ranks[index];
	end
end
function GameRankPage.ShowPage()
	local self = GameRankPage;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/MiniGames/GameRankPage.html", 
			name = "MiniGames.GameRankPage", 
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
	Map3DSystem.App.MiniGames.GameRankPage.GetRank()
end
function GameRankPage.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MiniGames.GameRankPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
end
function GameRankPage.Bind(gamename,gametitle)
	local self = GameRankPage;
	self.gamename = gamename;
	self.gametitle = gametitle;
	self.ranks = nil;
end
--[[
/// <summary>
    /// 取得指定游戏的积分排行榜
    /// 接收参数：
    ///     gameName
    /// 返回值：
    ///     ranks[list]
    ///         nid
    ///         score
    ///     [ errorcode ]
    /// </summary>
--]]
function GameRankPage.GetRank()
	local self = GameRankPage;
	local msg = {
		gamename = self.gamename,
	}
	commonlib.echo("begin get minigame ranks:")
	commonlib.echo(msg);
	paraworld.minigame.GetRank(msg,"minigame",function(msg)	
		commonlib.echo("after get minigame ranks:")
		commonlib.echo(msg);
		if(msg and msg.ranks)then
			
			self.ranks = msg.ranks;
			if(self.page)then
				self.page:Refresh();
			end
			--local map_ranks = {};
			--local nids = "";
			--local k,v;
			--for k,v in ipairs(msg.ranks) do
				--local id = v["nid"]
				--nids = nids .. tostring(id) ..",";
				--map_ranks[id] = v["score"];
			--end
			----user info
			--local msg = {
				--nids = nids,
				----nids = "16344,24216",
				--cache_policy = "access plus 0 day",
			--}
			--commonlib.echo("begin to get user info by gameRankPage:");
			--commonlib.echo(msg);
			--paraworld.users.getInfo(msg, "Game_UserInfo", function(msg)
			--
				--commonlib.echo("after get user info by gameRankPage:");
				--commonlib.echo(msg);
				--if(msg and msg.users) then
					 ----{ emoney=0, nickname="leio3", nid=19484, pmoney=0 }
					 --local k,v;
					 --for k,v in ipairs(msg.users) do
						--local nid = v["nid"]
						--local score = map_ranks[nid];
						--v["game_score"] = score;
					 --end
					 --self.ranks = msg.users;
					 --
					----local k,len = 1,100;
					----local temp = {};
					----for k = 1,len do
						----table.insert(self.ranks,{nickname = "马甲"..k,game_score = 1000 + k});
					----end
					--
					--function CompareNode(node1, node2)
						--if(node1.game_score == nil) then
							--return true
						--elseif(node2.game_score == nil) then
							--return false
						--else
							--return node1.game_score > node2.game_score;
						--end	
					--end
					--table.sort(self.ranks,CompareNode);
					--commonlib.echo("=============self.ranks");
					--commonlib.echo(self.ranks);
					 --if(self.page)then
						--self.page:Refresh();
					--end
				--end
			--end)
		end
	end);
end
function GameRankPage.ShowInfo(nid)
	if(not nid or nid == "")then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end