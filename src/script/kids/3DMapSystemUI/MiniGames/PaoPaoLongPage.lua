--[[
Title: 
Author(s): Leio
Date: 2009/11/16
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PaoPaoLongPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.PaoPaoLongPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.PaoPaoLongPage.ShowPage);

--
System.App.Commands.Call("MiniGames.PaoPaoLong");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local PaoPaoLongPage = {
	page = nil,
	gamename = "PaoPaoLong",
	gametitle = "鬼脸泡泡机",
}
commonlib.setfield("Map3DSystem.App.MiniGames.PaoPaoLongPage",PaoPaoLongPage);

function PaoPaoLongPage.OnInit()
	local self = PaoPaoLongPage;
	self.page = document:GetPageCtrl();
end
function PaoPaoLongPage.ShowPage()
	local self = PaoPaoLongPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function PaoPaoLongPage.ClosePage()
	local self = PaoPaoLongPage;
	MiniGameCommon.ClosePage(self.gamename);

	-- TODO: leio: this game is eating nearly 100% CPU, and the next render is rarely called. 
	local early_close = true;
	if(early_close) then	
		if(self.page)then
			local ctl = self.page:FindControl("flashctl");
			if(ctl)then
				local index = ctl.FlashPlayerIndex;
				local flashplayer = ParaUI.GetFlashPlayer(index);
				if(flashplayer)then
					commonlib.applog("============before PaoPaoLongPage FlashPlayerWindow:UnloadMovie");
					flashplayer:UnloadMovie();
					flashplayer:SetWindowMode(false);
					commonlib.applog("============after PaoPaoLongPage FlashPlayerWindow:UnloadMovie");
				end
			end
		end
	end	
end
function PaoPaoLongPage.CallNPLFromAs(score,bean)
	commonlib.applog("============paopaolong game:");
	commonlib.echo({score = score, bean = bean});
	local self = PaoPaoLongPage;
	self.ClosePage();
	commonlib.applog("============closed paopaolong game:");
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.applog("============closed2 paopaolong game:");
	
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	
	bean = bean or 0;
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	if(bean and bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			AddMoneyFunc(bean, function(msg) 
				log("======== PaoPaoLong_AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = bean, gamename = "PaoPaoLong"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end);
		end
	end
	commonlib.applog("============closed3 paopaolong game:");
	
	local hook_msg = { aries_type = "OnPaoPaoLongFinish", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local hook_msg = { aries_type = "onPaoPaoLongFinish_MPD", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	commonlib.applog("============closed4 paopaolong game:");
	
	self.GameAccount(score,bean);
end
function PaoPaoLongPage.GameAccount(score,bean)
	local self = PaoPaoLongPage;
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
	--火苗/水晶泡泡
	local gsid,label,num = self.LittleFlame(score);
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
function PaoPaoLongPage.GetIntelligence(score)
	local self = PaoPaoLongPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 1000)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"智慧值",1;
			end
		end
	end
end
function PaoPaoLongPage.LittleFlame(score)
	local self = PaoPaoLongPage;
	if(not score)then return end
	if(score >= 1000)then
		local r = math.random(100);
		if(r <= 50 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17063}))then return end
			return 17063,"火苗",1;
		else
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17062}))then return end
			return 17062,"水晶泡泡",1;
		end
	end
end