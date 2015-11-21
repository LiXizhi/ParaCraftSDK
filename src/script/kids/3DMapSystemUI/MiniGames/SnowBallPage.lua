--[[
Title: 
Author(s): Leio
Date: 2009/11/16
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/SnowBallPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.SnowBallPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.SnowBallPage.ShowPage);

--
System.App.Commands.Call("MiniGames.SnowBall");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local SnowBallPage = {
	page = nil,
	gamename = "SnowBall",
	gametitle = "快乐滚雪球",
}
commonlib.setfield("Map3DSystem.App.MiniGames.SnowBallPage",SnowBallPage);

function SnowBallPage.OnInit()
	local self = SnowBallPage;
	self.page = document:GetPageCtrl();
end
function SnowBallPage.ShowPage()
	local self = SnowBallPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function SnowBallPage.ClosePage()
	local self = SnowBallPage;
	MiniGameCommon.ClosePage(self.gamename);

	if(self.page)then
		local ctl = self.page:FindControl("flashctl");
		if(ctl)then
			local index = ctl.FlashPlayerIndex;
			local flashplayer = ParaUI.GetFlashPlayer(index);
			if(flashplayer)then
				commonlib.applog("============before SnowBallPage FlashPlayerWindow:UnloadMovie");
				flashplayer:UnloadMovie();
				flashplayer:SetWindowMode(false);
				commonlib.applog("============after SnowBallPage FlashPlayerWindow:UnloadMovie");
			end
		end
	end
end
function SnowBallPage.CallNPLFromAs(score,bean,xiang_gu)
	commonlib.applog("============SnowBallPage game:");
	commonlib.echo({score = score, bean = bean, xiang_gu = xiang_gu});
	local self = SnowBallPage;
	self.ClosePage();
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	--if(xiang_gu == 1) then
		---- 17032_WinterMushroom
		--local ItemManager = System.Item.ItemManager;
        --ItemManager.PurchaseItem(17032, 1, function(msg) end, function(msg)
	        --if(msg) then
		        --log("+++++++Purchase 17032_WinterMushroom return: +++++++\n")
		        --commonlib.echo(msg);
	        --end
        --end);
	--end
	
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	
	bean = bean or 0;
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	if(bean and bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			AddMoneyFunc(bean, function(msg) 
				log("======== SnowBall_AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = bean, gamename = "SnowBall"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end);
		end
	end
	
	local hook_msg = { aries_type = "OnSnowBallFinish", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local hook_msg = { aries_type = "onSnowBallFinish_MPD", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	self.GameAccount(score,bean);
end
function SnowBallPage.GameAccount(score,bean)
	local self = SnowBallPage;
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
--获取智慧值
function SnowBallPage.GetIntelligence(score)
	local self = SnowBallPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 800)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"智慧值",1;
			end
		end
	end
end
function SnowBallPage.GetDye(score)
	local self = SnowBallPage;
	if(not score)then return end
	if(score >= 500 and score < 800)then
		local r = math.random(3);
		if(r == 1 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17054}))then return end
			return 17054,"橙色颜料",1;
		elseif( r == 2)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17055}))then return end
			return 17055,"紫色颜料",1;
		elseif( r == 3)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17056}))then return end
			return 17056,"红色颜料",1;
		end
	elseif(score >= 800)then
		local r = math.random(4);
		if(r == 1 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17054}))then return end
			return 17054,"橙色颜料",1;
		elseif( r == 2)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17055}))then return end
			return 17055,"紫色颜料",1;
		elseif( r == 3)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17056}))then return end
			return 17056,"红色颜料",1;
		elseif( r == 4)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17032}))then return end
			return 17032,"冬菇",1;
		end
	end
end