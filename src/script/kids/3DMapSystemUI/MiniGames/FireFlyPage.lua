--[[
Title: 
Author(s): Leio
Date: 2009/9/15
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/FireFlyPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.FireFlyPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.FireFlyPage.ShowPage);

--
System.App.Commands.Call("MiniGames.FireFly");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")
-- default member attributes
local FireFlyPage = {
	page = nil,
	gamename = "FireFly",
	gametitle = "萤火虫",
}
commonlib.setfield("Map3DSystem.App.MiniGames.FireFlyPage",FireFlyPage);

function FireFlyPage.OnInit()
	local self = FireFlyPage;
	self.page = document:GetPageCtrl();
end
function FireFlyPage.ShowPage()
	local self = FireFlyPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function FireFlyPage.ClosePage()
	local self = FireFlyPage;
	MiniGameCommon.ClosePage(self.gamename);
end
function FireFlyPage.CallNPLFromAs(score)
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	local self = FireFlyPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	local bean = math.floor(score/6);
	
	bean = bean or 0;
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	if(bean and bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			AddMoneyFunc(bean, function(msg) 
				log("======== FireFly_AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = bean, gamename = "FireFly"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end);
		end
	end
	if(score and score > 0) then
		local hook_msg = { aries_type = "OnFireFlyGameFinish", score = score, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
	
	self.GameAccount(score,bean);
end
function FireFlyPage.GameAccount(score,bean)
	local self = FireFlyPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
		
	score = score or 0;
	bean = bean or 0;
	
	local ex_list = {
		{label = "奇豆", num = bean,},
	};
	
	--敏捷值
	local exID,label,num = self.GetAgility(score);
	if(exID and num and num > 0)then
		table.insert(ex_list,{label = label, num = num,});
		
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			log("+++++++Extended In Flash Game return: +++++++\n")
			commonlib.echo(msg);	
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
--获取敏捷值
function FireFlyPage.GetAgility(score)
	local self = FireFlyPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 600)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"敏捷值",1;
			end
		end
	end
end