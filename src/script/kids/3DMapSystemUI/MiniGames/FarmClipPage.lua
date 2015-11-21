--[[
Title: 
Author(s): Leio
Date: 2009/9/15
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/FarmClipPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.FarmClipPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.FarmClipPage.ShowPage);

--
System.App.Commands.Call("MiniGames.FarmClip");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")
-- default member attributes
local FarmClipPage = {
	page = nil,
	coin_list = {
		{799,0},
		{999,10},
		{1499,40},
		{1999,80},
		{2499,120},
		{2999,150},
		{3499,200},
		{3999,250},
		{4399,320},
		{4699,350},
		{4999,400},
		{5599,450},
		{5600,500},
	},
	gamename = "FarmClip",
	gametitle = "农场整理大挑战",
}
commonlib.setfield("Map3DSystem.App.MiniGames.FarmClipPage",FarmClipPage);

function FarmClipPage.OnInit()
	local self = FarmClipPage;
	self.page = document:GetPageCtrl();
end
function FarmClipPage.ShowPage()
	local self = FarmClipPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function FarmClipPage.ClosePage()
	local self = FarmClipPage;
	MiniGameCommon.ClosePage(self.gamename);
end
function FarmClipPage.GetCoin(score)
	if(score < 0)then score = 0; end
	local self = FarmClipPage;
	local k,v;
	for k,v in ipairs(self.coin_list) do
		local _score = v[1];
		local _coin = v[2];
		if(_score > score)then
			return _coin
		end
	end
	local len = table.getn(self.coin_list);
	return self.coin_list[len][2];
end
function FarmClipPage.CallNPLFromAs(score)
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	local self = FarmClipPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	local bean = self.GetCoin(score);
	
	bean = bean or 0;
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	if(bean and bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			AddMoneyFunc(bean, function(msg) 
				log("======== FarmClip_AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = bean, gamename = "FarmClip"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end);
		end
	end
	if(score and score > 0) then
		local hook_msg = { aries_type = "OnFarmClipGameFinish", score = score, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

		local hook_msg = { aries_type = "onFarmClipGameFinish_MPD", score = score, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
	
	self.GameAccount(score,bean);
end
function FarmClipPage.GameAccount(score,bean)
	local self = FarmClipPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
		
	score = score or 0;
	bean = bean or 0;
	
	local ex_list = {
		{label = "奇豆", num = bean,},
	};

	--爱心值
	local exID,label,num = self.GetLove(score);
	if(exID and num and num > 0)then
		table.insert(ex_list,{label = label, num = num,});
		
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			log("+++++++Extended In Flash Game return: +++++++\n")
			commonlib.echo(msg);	
		end);
	end
	--颜料
	local gsid,label,num = self.GetDye(score);
	if(gsid and num and num > 0)then
		table.insert(ex_list,{label = label, num = num,});
		
		ItemManager.PurchaseItem(gsid, 1, function(msg)
			if(msg) then
				log("+++++++Purchase In Flash Game return: +++++++\n")
				commonlib.echo(msg);
			end
		end);
	end
	
	local msg = {
		gamename = self.gamename,
		gametitle = self.gametitle,
		score = score,
		ex_list = ex_list,
	};
	Map3DSystem.App.MiniGames.GameScorePage.Bind(msg);
	Map3DSystem.App.MiniGames.GameScorePage.ShowPage();
	
end
--获取爱心值 返回 exID,label,num = 281,"爱心值",1;
function FarmClipPage.GetLove(score)
	local self = FarmClipPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 3000)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"爱心值",1;
			end
		end
	end
end
--获取颜料 返回 gsid,label,num = "绿色颜料",1;
function FarmClipPage.GetDye(score)
	local self = FarmClipPage;
	if(not score)then return end
	if(score >= 500)then
		local r = math.random(100);
		if(r <= 50 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17053}))then return end
			return 17053,"绿色颜料",1;
		else
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17052}))then return end
			return 17052,"黄色颜料",1;
		end
	end
end