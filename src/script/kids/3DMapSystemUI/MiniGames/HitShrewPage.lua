--[[
Title: 
Author(s): Leio
Date: 2009/10/15
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/HitShrewPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.HitShrewPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.HitShrewPage.ShowPage);

--
System.App.Commands.Call("MiniGames.HitShrew");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local HitShrewPage = {
	page = nil,
	gamename = "HitShrew",
	gametitle = "葱头菜头大战",
}
commonlib.setfield("Map3DSystem.App.MiniGames.HitShrewPage",HitShrewPage);

function HitShrewPage.OnInit()
	local self = HitShrewPage;
	self.page = document:GetPageCtrl();
end
function HitShrewPage.ShowPage()
	local self = HitShrewPage;
	MiniGameCommon.ShowPage(self.gamename);
	self.CallFlash();
end
function HitShrewPage.OnOpened()
	local self = HitShrewPage;
	self.CallFlash();
end
function HitShrewPage.CallFlash()
	local self = HitShrewPage;	
		if(self.page)then
		local ctl = self.page:FindControl("flashctl");
		if(ctl)then
			local index = ctl.FlashPlayerIndex;
			
			--获得是否含有菜头的信息
			local ItemManager = System.Item.ItemManager;
			ItemManager.GetItemsInBag(10010, "HitShrewPage", function(msg)
				if(msg and msg.items) then
					local has_caitou = 1; -- 0 没有 1 有
					local has_congtou = 1; -- 0 没有 1 有
					local hasGSItem = ItemManager.IfOwnGSItem;
					if(hasGSItem(10101)) then
						has_caitou = 1;
					else
						has_caitou = 0;
					end
					if(hasGSItem(10109)) then
						has_congtou = 1;
					else
						has_congtou = 0;
					end
					local func_args = {
								funcName = "setPetNum",
								args = {
									has_caitou,
									has_congtou,
								}
							} 
					commonlib.CallFlashFunction(index, func_args)
				end
			end);
		end
	end
end
function HitShrewPage.ClosePage()
	local self = HitShrewPage;
	MiniGameCommon.ClosePage(self.gamename);
end
--@param getpet:0 什么也没获得 1 菜头 2 葱头
function HitShrewPage.CallNPLFromAs(getpet,score,bean)
	-- resume game music
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	local self = HitShrewPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	
	bean = bean or 0;
	bean = math.min(bean,Map3DSystem.App.MiniGames.GameScorePage.maxBean);
	--如果已经有宠物可以获得奇豆奖励
	if(getpet == 0 and bean >0)then
		-- hard code the AddMoney here, move to the game server in the next release candidate
		local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
		if(AddMoneyFunc) then
			AddMoneyFunc(bean or 0, function(msg) 
				log("======== HitShrewPage.AddMoney returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (bean or 0), gamename = "HitShrew"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
				if(msg.issuccess) then
				end
			end);
		end
	--TODO:如果getpet = 1 获得菜头
	--getpet = 2 获得葱头
	elseif(getpet == 1) then
		-- 10101_FollowPetCAITOUbb
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOwnGSItem;
		if(not hasGSItem(10101)) then
			ItemManager.PurchaseItem(10101, 1, function(msg)
				if(msg) then
					log("+++++++Purchase 10101_FollowPetCAITOUbb return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess) then
					end
				end
			end);
		end
	elseif(getpet == 2) then
		-- 10109_FollowPetCTBB
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOwnGSItem;
		if(not hasGSItem(10109)) then
			ItemManager.PurchaseItem(10109, 1, function(msg)
				if(msg) then
					log("+++++++Purchase 10109_FollowPetCTBB return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess) then
					end
				end
			end);
		end
	end
	local caitou = false;
	local congtou = false;
	local caitou_or_congtou = nil;
	if(getpet == 1)then
		caitou = true;
		bean = -1;
		caitou_or_congtou = { label = "菜头", num = 1, };
	end
	if(getpet == 2)then
		congtou = true;
		bean = -1;
		caitou_or_congtou = { label = "葱头", num = 1, };
	end
	
	local hasGainCaiTou, hasGainCongTou;
	if(getpet == 1) then
		hasGainCaiTou = true;
	elseif(getpet == 2) then
		hasGainCongTou = true;
	end
	
	local hook_msg = { aries_type = "OnHitShrewGameFinish", score = score, hasGainCaiTou = hasGainCaiTou, hasGainCongTou = hasGainCongTou, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local hook_msg = { aries_type = "onHitShrewGameFinish_MPD", score = score, hasGainCaiTou = hasGainCaiTou, hasGainCongTou = hasGainCongTou, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	self.GameAccount(score,bean,caitou_or_congtou);
end
function HitShrewPage.GameAccount(score,bean,caitou_or_congtou)
	local self = HitShrewPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
		
	score = score or 0;
	bean = bean or 0;
	
	local ex_list;
	if(caitou_or_congtou)then
		ex_list = {
			caitou_or_congtou,
		};
	else
		ex_list = {
			{label = "奇豆", num = bean,},
		};
	end
	--力量值
	local exID,label,num = self.GetStrength(score);
	if(exID and num and num > 0)then
		table.insert(ex_list,{label = label, num = num,});
		
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			log("+++++++Extended In Flash Game return: +++++++\n")
			commonlib.echo(msg);	
		end);
	end
	--颜料/花瓣
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
--获取力量值 返回 exID,label,num = 282,"力量值",1;
function HitShrewPage.GetStrength(score)
	local self = HitShrewPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 1600)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"力量值",1;
			end
		end
	end
end
--获取颜料 返回 gsid,label,num = "颜料",1;
function HitShrewPage.GetDye(score)
	if(not score)then return end
	if(score >= 500 and score < 1000)then
		return 17059,"棕色颜料",1
	elseif(score >= 1000)then
		local r = math.random(100);
		if(r <= 50 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17059}))then return end
			return 17059,"棕色颜料",1
		else
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17060}))then return end
			return 17060,"花瓣",1;
		end
	end
end