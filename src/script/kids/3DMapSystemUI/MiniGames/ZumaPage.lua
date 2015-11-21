--[[
Title: 
Author(s): Leio
Date: 2009/10/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ZumaPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.ZumaPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.ZumaPage.ShowPage);
Map3DSystem.App.MiniGames.ZumaPage.ToggleShow(bShow)
--
System.App.Commands.Call("MiniGames.Zuma");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local ZumaPage = {
	page = nil,
	gamename = "Zuma",
	gametitle = "趣味表情祖玛",
}
commonlib.setfield("Map3DSystem.App.MiniGames.ZumaPage",ZumaPage);

function ZumaPage.OnInit()
	local self = ZumaPage;
	self.page = document:GetPageCtrl();
end
function ZumaPage.ShowPage()
	local self = ZumaPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function ZumaPage.ClosePage()
	local self = ZumaPage;
	MiniGameCommon.ClosePage(self.gamename);
end

function ZumaPage.CallNPLFromAs(score)
	---- resume game music
	MyCompany.Aries.Scene.StopGameBGMusic();
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.log("ZumaPage will be closed\n")
	local self = ZumaPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	local bean = math.floor(score/30);
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
				log("======== ZumaCanvas.GetGameMsg returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (bean or 0), gamename = "Zuma"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end, bSkipNotification);
		end
	end
	
	local hook_msg = { aries_type = "OnZumaGameFinish", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local hook_msg = { aries_type = "onZumaGameFinish_MPD", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	self.GameAccount(score,bean);
end
function ZumaPage.GameAccount(score,bean)
	local self = ZumaPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
		
	score = score or 0;
	bean = bean or 0;
	
	local ex_list = {
			{label = "奇豆", num = bean,},
		};
	--智慧值
	local exID,label,num = self.GetIntelligence(score);
	if(exID and num and num > 0)then
		table.insert(ex_list,{label = label, num = num,});
		
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			log("+++++++Extended In Flash Game return: +++++++\n")
			commonlib.echo(msg);	
		end);
	end
	--金橘种子
	local gsid,label,num = self.GetOrange(score);
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
--获取智慧值
function ZumaPage.GetIntelligence(score)
	local self = ZumaPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 1500)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"智慧值",1;
			end
		end
	end
end
function ZumaPage.GetOrange(score)
	if(not score)then return end
	if(score >= 1500)then
		local r = math.random(100);
		if(r <= 50 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 30099}))then return end
			return 30099,"金橘种子",1;
		end
	end
end