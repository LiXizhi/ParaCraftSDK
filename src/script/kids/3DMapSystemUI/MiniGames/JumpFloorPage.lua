--[[
Title: 
Author(s): Leio
Date: 2009/10/15
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/JumpFloorPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.JumpFloorPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.JumpFloorPage.ShowPage);

--
System.App.Commands.Call("MiniGames.JumpFloor");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local JumpFloorPage = {
	page = nil,
	gamename = "JumpFloor",
	gametitle = "雪山大挑战",
}
commonlib.setfield("Map3DSystem.App.MiniGames.JumpFloorPage",JumpFloorPage);

function JumpFloorPage.OnInit()
	local self = JumpFloorPage;
	self.page = document:GetPageCtrl();
end
function JumpFloorPage.ShowPage()
	local self = JumpFloorPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function JumpFloorPage.ClosePage()
	local self = JumpFloorPage;
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
					commonlib.applog("============before JumpFloorPage FlashPlayerWindow:UnloadMovie");
					flashplayer:UnloadMovie();
					flashplayer:SetWindowMode(false);
					commonlib.applog("============after JumpFloorPage FlashPlayerWindow:UnloadMovie");
				end
			end
		end
	end	
	--unhook this flash window
	Map3DSystem.App.MiniGames.SetCurWindow(nil);
end
function JumpFloorPage.CallNPLFromAs(score)
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	local self = JumpFloorPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	
	local bean = math.floor(score/20);
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	--获得奇豆奖励
	if(bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			AddMoneyFunc(bean or 0, function(msg) 
				log("======== JumpFloorPage.AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (bean or 0), gamename = "JumpFloor"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
				if(msg.issuccess) then
				end
			end);
		end
	end
	local hook_msg = { aries_type = "OnJumpFloorGameFinish", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local hook_msg = { aries_type = "onJumpFloorGameFinish_MPD", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	self.GameAccount(score,bean)
end
function JumpFloorPage.GameAccount(score,bean)
	local self = JumpFloorPage;
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
	--其他
	local gsid,label,num = self.GetOthers(score);
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
--获取敏捷值
function JumpFloorPage.GetAgility(score)
	local self = JumpFloorPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 2000)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"敏捷值",1;
			end
		end
	end
end
function JumpFloorPage.GetOthers(score)
	local self = JumpFloorPage;
	if(not score)then return end
	if(score >= 500 and score < 1000)then
		if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17061}))then return end
		return 17061,"气球泡泡",1
	elseif(score >= 1000 and score < 3000)then
		local r = math.random(2);
		if(r == 1 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17064}))then return end
			return 17064,"稻草",1;
		elseif( r == 2)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17061}))then return end
			return 17061,"气球泡泡",1
		end
	elseif(score >= 3000)then
		local r = math.random(3);
		if(r == 1 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17064}))then return end
			return 17064,"稻草",1;
		elseif( r == 2)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17061}))then return end
			return 17061,"气球泡泡",1
		elseif( r == 3)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17047}))then return end
			return 17047,"松子",1
		end
	end
end