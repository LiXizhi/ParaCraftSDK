--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ChuanYunPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.ChuanYunPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.ChuanYunPage.ShowPage);

--
System.App.Commands.Call("MiniGames.ChuanYun");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local ChuanYunPage = {
	page = nil,
	gamename = "ChuanYun",
	gametitle = "沙滩摘椰子",
}
commonlib.setfield("Map3DSystem.App.MiniGames.ChuanYunPage",ChuanYunPage);
function ChuanYunPage.OnInit()
	local self = ChuanYunPage;
	self.page = document:GetPageCtrl();
end
function ChuanYunPage.ShowPage()
	local self = ChuanYunPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function ChuanYunPage.ClosePage()
	local self = ChuanYunPage;
	MiniGameCommon.ClosePage(self.gamename);
end
function ChuanYunPage.CallNPLFromAs(score,bean)
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	local self = ChuanYunPage;
	self.ClosePage();
	if(not bean or bean <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	
	bean = math.min(bean,650);
	if(bean and bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			AddMoneyFunc(bean, function(msg) 
				log("======== ChuanYun_AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = bean, gamename = "ChuanYun"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end);
		end
	end
	
	if(score and score > 0) then
		local hook_msg = { aries_type = "OnChuanYunGameFinish", score = score, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

		local hook_msg = { aries_type = "onChuanYunGameFinish_MPD", score = score, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
	
	self.GameAccount(score,bean)
end
function ChuanYunPage.GameAccount(score,bean)
	local self = ChuanYunPage;
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
function ChuanYunPage.GetAgility(score)
	local self = ChuanYunPage;
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
function ChuanYunPage.GetOthers(score)
	if(not score)then return end
	if(score >= 100)then
		local r = math.random(2);
		if(r == 1 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17057}))then return end
			return 17057,"蓝色颜料",1;
		elseif( r == 2)then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17058}))then return end
			return 17058,"白色颜料",1
		end
	end
end