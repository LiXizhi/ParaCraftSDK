--[[
Title: 
Author(s): Leio
Date: 2009/10/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/CrazySpotsPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.CrazySpotsPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.CrazySpotsPage.ShowPage);
Map3DSystem.App.MiniGames.CrazySpotsPage.ToggleShow(bShow)
--
System.App.Commands.Call("MiniGames.CrazySpots");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local CrazySpotsPage = {
	page = nil,
	gamename = "CrazySpots",
	gametitle = "眼力大比拼",
}
commonlib.setfield("Map3DSystem.App.MiniGames.CrazySpotsPage",CrazySpotsPage);

function CrazySpotsPage.OnInit()
	local self = CrazySpotsPage;
	self.page = document:GetPageCtrl();
end
function CrazySpotsPage.ShowPage()
	local self = CrazySpotsPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function CrazySpotsPage.ClosePage()
	local self = CrazySpotsPage;
	MiniGameCommon.ClosePage(self.gamename);
end

function CrazySpotsPage.CallNPLFromAs(score)
	---- resume game music
	MyCompany.Aries.Scene.StopGameBGMusic();
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.log("CrazySpotsPage will be closed\n")
	local self = CrazySpotsPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	local bean = math.floor(score/25);
	bean = bean or 0;
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	if(bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			local bSkipNotification = nil;
			if(bead and bead > 0) then
				bSkipNotification = true;
			end
			AddMoneyFunc(bean or 0, function(msg) 
				log("======== CrazySpotsCanvas.GetGameMsg returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (bean or 0), gamename = "CrazySpots"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end, bSkipNotification);
		end
	end
	
	local hook_msg = { aries_type = "OnCrazySpotsGameFinish", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local hook_msg = { aries_type = "onCrazySpotsGameFinish_MPD", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	self.GameAccount(score,bean);
end
function CrazySpotsPage.GameAccount(score,bean)
	local self = CrazySpotsPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
		
	score = score or 0;
	bean = bean or 0;
	
	local ex_list = {
			{label = "奇豆", num = bean,},
		};
	--智慧值
	local exID,label,num = self.GetProperty(score);
	if(exID and num and num > 0)then
		table.insert(ex_list,{label = label, num = num,});
		
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			log("+++++++Extended In Flash Game return: +++++++\n")
			commonlib.echo(msg);	
		end);
	end
	--玲珑彩纸
	local gsid,label,num = self.GetColorPaper(score);
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
--获取力量值
function CrazySpotsPage.GetProperty(score)
	local self = CrazySpotsPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 4000)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"力量值",1;
			end
		end
	end
end
--获取玲珑彩纸
function CrazySpotsPage.GetColorPaper(score)
	if(not score)then return end
	if(score >= 4000 )then
		return 17083,"玲珑彩纸",1
	end
end