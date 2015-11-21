--[[
Title: 
Author(s): Leio
Date: 2009/12/25
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/SuperDancerPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.SuperDancerPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.SuperDancerPage.ShowPage);
Map3DSystem.App.MiniGames.SuperDancerPage.ToggleShow(bShow)
--
System.App.Commands.Call("MiniGames.SuperDancer");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local SuperDancerPage = {
	page = nil,
	gamename = "SuperDancer",
	gametitle = "超级舞者",
}
commonlib.setfield("Map3DSystem.App.MiniGames.SuperDancerPage",SuperDancerPage);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function SuperDancerPage.OnInit()
	local self = SuperDancerPage;
	self.page = document:GetPageCtrl();
end
function SuperDancerPage.ShowPage()
	local self = SuperDancerPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function SuperDancerPage.ClosePage()
	local self = SuperDancerPage;
	MiniGameCommon.ClosePage(self.gamename);
end
--score:比分
--skill:熟练度
function SuperDancerPage.CallNPLFromAs(score,skill)
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.log("SuperDancerPage will be closed\n")
	commonlib.echo({score = score,skill = skill});
	local self = SuperDancerPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	
	local bean = 0;
	bean = math.floor(score/4);
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	if(bean > 0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			local bSkipNotification = nil;
			AddMoneyFunc(bean or 0, function(msg) 
				log("======== SuperDancerCanvas.GetGameMsg returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (bean or 0), gamename = "SuperDancer"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end, bSkipNotification);
		end
	end
	if(skill and skill > 0)then
		skill = math.min(skill,5);
		
		
		local bHas_dance, guid = hasGSItem(9005);--是否开启舞蹈课程 滴答舞是第一个舞蹈
		if(bHas_dance)then
			--增加熟练度
			ItemManager.PurchaseItem(50231,skill,function(msg) end,function(msg)
				log("+++++++Purchase item #50231_DancerSkillPoint return: +++++++\n")
				commonlib.echo(msg);
			end);
		else
			skill = 0;--没有开启舞蹈课程的不发放 熟练度
		end
	end
	
	local hook_msg = { aries_type = "OnSuperDancerGameFinish", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local hook_msg = { aries_type = "onSuperDancerGameFinish_MPD", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	self.GameAccount(score,bean,skill);
end
function SuperDancerPage.GameAccount(score,bean,skill)
	local self = SuperDancerPage;
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
	--跳舞熟练度
	if(skill and skill > 0)then
		table.insert(ex_list,{label = "舞蹈熟练度", num = skill,});
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
--获取爱心值 返回 exID,label,num = 286,"爱心值",1;
function SuperDancerPage.GetLove(score)
	local self = SuperDancerPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 1800)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"爱心值",1;
			end
		end
	end
end
