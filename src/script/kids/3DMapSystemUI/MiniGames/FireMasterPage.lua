--[[
Title: 
Author(s): Leio
Date: 2009/10/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/FireMasterPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.FireMasterPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.FireMasterPage.ShowPage);
Map3DSystem.App.MiniGames.FireMasterPage.ToggleShow(bShow)
--
System.App.Commands.Call("MiniGames.FireMaster");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local FireMasterPage = {
	page = nil,
	gamename = "FireMaster",
	gametitle = "火毛怪大战",
}
commonlib.setfield("Map3DSystem.App.MiniGames.FireMasterPage",FireMasterPage);

function FireMasterPage.OnInit()
	local self = FireMasterPage;
end
function FireMasterPage.ShowPage()
	local self = FireMasterPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function FireMasterPage.ClosePage()
	local self = FireMasterPage;
	MiniGameCommon.ClosePage(self.gamename);
end
function FireMasterPage.OnOpened()
	local self = FireMasterPage;
	self.IsMadeBead();
end
--是否需要产生火龙珠碎片
function FireMasterPage.IsMadeBead()
	local self = FireMasterPage;
	local page = MiniGameCommon.GetPage();
	if(page)then
		local ctl = page:FindControl("flashctl");
		if(ctl)then
			local index = ctl.FlashPlayerIndex;
			
			--是否产生火龙珠碎片
			local madeBead = false;
			local beadNum = 0;
			-- 50050_WishLevel9_Acquire
			-- 50051_WishLevel9_Complete
			-- 50052_WishLevel9_RewardFriendliness
			-- 50040_WishLevel9_TalkedWithDragonTotem
			-- 50041_WishLevel9_FireBallShard
			-- 15001_SpitFire
			local ItemManager = System.Item.ItemManager;
			local hasGSItem = ItemManager.IfOwnGSItem;
			if(hasGSItem(50050) and not hasGSItem(50051) and hasGSItem(50040)) then
				local bHas, guid, bag, copies = hasGSItem(50041);
				if(bHas == false or (bHas and copies < 20)) then
					madeBead = true;
					beadNum = copies or 0;
					commonlib.echo("===================beadNum");
					commonlib.echo(beadNum);
				end
			end
			local func_args = {
				funcName = "IsMadeBead",
				args = {
					madeBead,
					beadNum
				}
			} 
			commonlib.CallFlashFunction(index, func_args)
		end
	end
end
--score:火毛怪个数
--bean:奇豆个数
--bead:火龙珠碎片个数
function FireMasterPage.CallNPLFromAs(score,bean,bead)
	---- resume game music
	--MyCompany.Aries.Scene.StopGameBGMusic();
	--MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.log("FireMasterPage will be closed\n")
	local self = FireMasterPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	
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
				log("======== FireMasterCanvas.GetGameMsg returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (bean or 0), gamename = "FireMaster"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end, bSkipNotification);
		end
	end
	if(bead and bead > 0) then
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOwnGSItem;
		if(hasGSItem(50050) and not hasGSItem(50051) and hasGSItem(50040)) then
			local bHas, guid, bag, copies = hasGSItem(50041);
			if(bHas == false or (bHas and copies < 20)) then
				-- incase of no item exists
				copies = copies or 0;
				local gainCount = 0;
				if((copies + bead) > 20) then
					gainCount = 20 - copies;
				else
					gainCount = bead;
				end
				ItemManager.PurchaseItem(50041, gainCount, function(msg) end, function(msg)
					if(msg) then
						log("+++++++ Purchase 50041_WishLevel9_FireBallShard return: +++++++\n")
						commonlib.echo(msg);
						if(msg.issuccess == true) then
						end
					end
				end, nil, "none", nil, true); -- true on bForceNotificationOnObtain
			end
		end
	end
	self.GameAccount(score,bean,bead);
end
function FireMasterPage.GameAccount(score,bean,bead)
	local self = FireMasterPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
		
	score = score or 0;
	bean = bean or 0;
	
	local ex_list = {
			{label = "奇豆", num = bean,},
		};
	if(bead and bead > 0)then
		table.insert(ex_list,{label = "火龙珠碎片", num = bead,});
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
	--火苗
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
--获取力量值 返回 exID,label,num = 288,"力量值",1;
function FireMasterPage.GetStrength(score)
	local self = FireMasterPage;
	if(not score)then return end
	if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduce({gamename = self.gamename}))then return end
	if(score >= 100)then
		local r = math.random(100);
		if(r <= 50 )then
			local exid = Map3DSystem.App.MiniGames.MiniGameCommon.GetProduceExid(self.gamename);
			if(exid) then
				return exid,"力量值",1;
			end
		end
	end
end
function FireMasterPage.LittleFlame(score)
	if(not score)then return end
	if(score >= 100)then
		local r = math.random(100);
		if(r <= 50 )then
			if(not Map3DSystem.App.MiniGames.MiniGameCommon.CanProduceOthers({gsid = 17063}))then return end
			return 17063,"火苗",1;
		end
	end
end