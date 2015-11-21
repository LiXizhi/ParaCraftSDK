--[[
Title: 
Author(s): Leio
Date: 2009/10/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/RecycleBinPage.lua");
local s = string.format('你要开始“%s”吗？',Map3DSystem.App.MiniGames.RecycleBinPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.RecycleBinPage.ShowPage);
Map3DSystem.App.MiniGames.RecycleBinPage.ToggleShow(bShow)
--
System.App.Commands.Call("MiniGames.RecycleBin");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local RecycleBinPage = {
	page = nil,
	gamename = "RecycleBin",
	gametitle = "回收整理站",
}
commonlib.setfield("Map3DSystem.App.MiniGames.RecycleBinPage",RecycleBinPage);

function RecycleBinPage.OnInit()
	local self = RecycleBinPage;
	self.page = document:GetPageCtrl();
end
function RecycleBinPage.ShowPage()
	local self = RecycleBinPage;
	MiniGameCommon.ShowPage(self.gamename);
end
function RecycleBinPage.ClosePage()
	local self = RecycleBinPage;
	MiniGameCommon.ClosePage(self.gamename);
end

function RecycleBinPage.CallNPLFromAs(score)
	---- resume game music
	MyCompany.Aries.Scene.StopGameBGMusic();
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.log("RecycleBinPage will be closed\n")
	local self = RecycleBinPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	local bean = math.floor(score/10);
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
				log("======== RecycleBinCanvas.GetGameMsg returns: ========\n")
				commonlib.echo(msg);
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (bean or 0), gamename = "RecycleBin"}, 
						"joybean_obtain_from_minigame_log", function(msg)
					end);
				end
			end, bSkipNotification);
		end
	end
	
	local hook_msg = { aries_type = "OnRecycleBinGameFinish", score = score, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	self.GameAccount(score,bean);
end
function RecycleBinPage.GameAccount(score,bean)
	local self = RecycleBinPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
		
	score = score or 0;
	bean = bean or 0;
	
	local ex_list = {
			{label = "奇豆", num = bean,},
		};
	
	local msg = {
		gamename = self.gamename,
		gametitle = self.gametitle,
		score = score,
		ex_list = ex_list,
	};
	Map3DSystem.App.MiniGames.GameScorePage.Bind(msg);
	Map3DSystem.App.MiniGames.GameScorePage.ShowPage();
	
end