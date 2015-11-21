--[[
Title: 
Author(s): Leio
Date: 2009/9/15
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/DeliciousCakePage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.DeliciousCakePage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.DeliciousCakePage.ShowPage);

--
System.App.Commands.Call("MiniGames.DeliciousCake");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")
-- default member attributes
local DeliciousCakePage = {
	page = nil,
	gamename = "DeliciousCake",
	gametitle = "美味蛋糕房",
}
commonlib.setfield("Map3DSystem.App.MiniGames.DeliciousCakePage",DeliciousCakePage);

function DeliciousCakePage.OnInit()
	local self = DeliciousCakePage;
	self.page = document:GetPageCtrl();
end
function DeliciousCakePage.ShowPage()
	local self = DeliciousCakePage;
	MiniGameCommon.ShowPage(self.gamename);
end
function DeliciousCakePage.ClosePage()
	local self = DeliciousCakePage;
	MiniGameCommon.ClosePage(self.gamename);
end
function DeliciousCakePage.CallNPLFromAs(score)
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	local self = DeliciousCakePage;
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
				log("======== DeliciousCake_AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = bean, gamename = "DeliciousCake"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end);
		end
	end
	if(score and score > 0) then
		local hook_msg = { aries_type = "OnDeliciousCakeGameFinish", score = score, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
	
	self.GameAccount(score,bean);
end
function DeliciousCakePage.GameAccount(score,bean)
	local self = DeliciousCakePage;
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
--获取爱心值 返回 exID,label,num = 281,"爱心值",1;
function DeliciousCakePage.GetLove(score)
	local self = DeliciousCakePage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 500)then
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
function DeliciousCakePage.GetOthers(score)
	local self = DeliciousCakePage;
	if(not score)then return end
	if(score >= 500)then
		local r = math.random(3);
		if(r == 1 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 30134}))then return end
			return 30134,"糖豆豆种子",1;
		elseif(r == 2 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17094}))then return end
			return 17094,"巧克力豆",1;
		else
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17095}))then return end
			return 17095,"奶酪",1;
		end
	end
end