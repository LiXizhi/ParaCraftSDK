--[[
Title: 
Author(s): Leio
Date: 2010/01/27
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ChuanYunPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/CrazySpotsPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/CropDefendPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/DeliciousCakePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/FarmClipPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/FireFlyPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/FireMasterPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/HitShrewPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/JumpFloorPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/LuckyDialPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MelonSeedTestPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PaoPaoLongPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/RecycleBinPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/SnowBallPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/SuperDancerPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/WateringPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ZumaPage.lua");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")
MiniGameCommon.align = "_ct";

MiniGameCommon.max_width = 960; 
MiniGameCommon.max_height = 560; 
MiniGameCommon.left = -MiniGameCommon.max_width / 2;
MiniGameCommon.top = -MiniGameCommon.max_height / 2;
MiniGameCommon.flash_width = 960;
MiniGameCommon.flash_height = 560; 

MiniGameCommon.games = {
		["ChuanYun"] = {
			gamename = "ChuanYun",
			gametitle = "沙滩摘椰子",
			gamepage = "Map3DSystem.App.MiniGames.ChuanYunPage",
			url = "script/kids/3DMapSystemUI/MiniGames/ChuanYunPage.html", 
			swffile = "Games/ChuanYun/ChuanYun.swf", 
			exID = 283, 
			gsid = 50267,--gisd 为限制每天数值产出的数量 一天最多10次
			game_gsid = 78001,
			},
		["CrazySpots"] = {
			gamename = "CrazySpots",
			gametitle = "眼力大比拼",
			gamepage = "Map3DSystem.App.MiniGames.CrazySpotsPage",
			url = "script/kids/3DMapSystemUI/MiniGames/CrazySpotsPage.html", 
			swffile = "Games/CrazySpots/CrazySpots.swf", 
			exID = 322, 
			gsid = 50276,
			game_gsid = 78002,
			},
		["CropDefend"] = {
			gamename = "CropDefend",
			gametitle = "庄稼保卫战",
			gamepage = "Map3DSystem.App.MiniGames.CropDefendPage",
			url = "script/kids/3DMapSystemUI/MiniGames/CropDefendPage.html", 
			swffile = "Games/CropDefend/CropDefend.swf", 
			exID = 394, 
			gsid = 50301,
			game_gsid = 78003,
			},
		["DeliciousCake"] = {
			gamename = "DeliciousCake",
			gametitle = "美味蛋糕房",
			gamepage = "Map3DSystem.App.MiniGames.DeliciousCakePage",
			url = "script/kids/3DMapSystemUI/MiniGames/DeliciousCakePage.html", 
			swffile = "Games/DeliciousCake/DeliciousCake.swf", 
			exID = 393, 
			gsid = 50300,
			game_gsid = 78004,
			},
		["FarmClip"] = {
			gamename = "FarmClip",
			gametitle = "农场整理大挑战",
			gamepage = "Map3DSystem.App.MiniGames.FarmClipPage",
			url = "script/kids/3DMapSystemUI/MiniGames/FarmClipPage.html", 
			swffile = "Games/FarmClip/FarmClip.swf", 
			exID = 281, 
			gsid = 50265,
			game_gsid = 78005,
			},
		["FireFly"] = {
			gamename = "FireFly",
			gametitle = "萤火虫",
			gamepage = "Map3DSystem.App.MiniGames.FireFlyPage",
			url = "script/kids/3DMapSystemUI/MiniGames/FireFlyPage.html", 
			swffile = "Games/FireFly/FireFly.swf", 
			exID = 395, 
			gsid = 50302,
			game_gsid = 78006,
			},
		["FireMaster"] = {
			gamename = "FireMaster",
			gametitle = "火毛怪大战",
			gamepage = "Map3DSystem.App.MiniGames.FireMasterPage",
			url = "script/kids/3DMapSystemUI/MiniGames/FireMasterPage.html", 
			swffile = "Games/FireMaster/FireMaster.swf", 
			exID = 288, 
			gsid = 50272,
			game_gsid = 78007,
			},
		["HitShrew"] = {
			gamename = "HitShrew",
			gametitle = "葱头菜头大战",
			gamepage = "Map3DSystem.App.MiniGames.HitShrewPage",
			url = "script/kids/3DMapSystemUI/MiniGames/HitShrewPage.html", 
			swffile = "Games/HitShrew/HitShrew.swf", 
			exID = 282, 
			gsid = 50266,
			game_gsid = 78008,
			},
		["JumpFloor"] = {
			gamename = "JumpFloor",
			gametitle = "雪山大挑战",
			gamepage = "Map3DSystem.App.MiniGames.JumpFloorPage",
			url = "script/kids/3DMapSystemUI/MiniGames/JumpFloorPage.html", 
			swffile = "Games/JumpFloor/JumpFloor.swf",
			exID = 287, 
			gsid = 50271,
			game_gsid = 78009,
			},
		["LuckyDial"] = {
			gamename = "LuckyDial",
			gametitle = "趣味大抽奖",
			gamepage = "Map3DSystem.App.MiniGames.LuckyDialPage",
			url = "script/kids/3DMapSystemUI/MiniGames/LuckyDialPage.html", 
			swffile = "Games/LuckyDial/LuckyDial.swf",
			game_gsid = nil,
			},
		["MelonSeedTest"] = {
			gamename = "MelonSeedTest",
			gametitle = "西瓜种子鉴定",
			gamepage = "Map3DSystem.App.MiniGames.MelonSeedTestPage",
			url = "script/kids/3DMapSystemUI/MiniGames/MelonSeedTestPage.html", 
			swffile = "Games/MelonSeedTest/MelonSeedTest.swf",
			game_gsid = nil,
			},
		["PaoPaoLong"] = {
			gamename = "PaoPaoLong",
			gametitle = "鬼脸泡泡机",
			gamepage = "Map3DSystem.App.MiniGames.PaoPaoLongPage",
			url = "script/kids/3DMapSystemUI/MiniGames/PaoPaoLongPage.html", 
			swffile = "Games/PaoPaoLong/PaoPaoLong.swf",
			exID = 284, 
			gsid = 50268,
			game_gsid = 78010,
			},
		["RecycleBin"] = {
			gamename = "RecycleBin",
			gametitle = "回收整理站",
			gamepage = "Map3DSystem.App.MiniGames.RecycleBinPage",
			url = "script/kids/3DMapSystemUI/MiniGames/RecycleBinPage.html", 
			swffile = "Games/RecycleBin/RecycleBin.swf",
			game_gsid = 78011,
			},
		["SnowBall"] = {
			gamename = "SnowBall",
			gametitle = "快乐滚雪球",
			gamepage = "Map3DSystem.App.MiniGames.SnowBallPage",
			url = "script/kids/3DMapSystemUI/MiniGames/SnowBallPage.html", 
			swffile = "Games/SnowBall/SnowBall.swf",
			exID = 285, 
			gsid = 50269,
			game_gsid = 78012,
			},
		["SuperDancer"] = {
			gamename = "SuperDancer",
			gametitle = "超级舞者",
			gamepage = "Map3DSystem.App.MiniGames.SuperDancerPage",
			url = "script/kids/3DMapSystemUI/MiniGames/SuperDancerPage.html", 
			swffile = "Games/SuperDancer/SuperDancer.swf",
			exID = 286, 
			gsid = 50270,
			game_gsid = 78013,
			},
		["Watering"] = {
			gamename = "Watering",
			gametitle = "灌溉王",
			gamepage = "Map3DSystem.App.MiniGames.WateringPage",
			url = "script/kids/3DMapSystemUI/MiniGames/WateringPage.html", 
			swffile = "Games/Watering/Watering.swf",
			game_gsid = 78014,
			},
		["Zuma"] = {
			gamename = "Zuma",
			gametitle = "趣味表情祖玛",
			gamepage = "Map3DSystem.App.MiniGames.ZumaPage",
			url = "script/kids/3DMapSystemUI/MiniGames/ZumaPage.html", 
			swffile = "Games/Zuma/Zuma.swf",
			exID = 296, 
			gsid = 50273,
			game_gsid = 78015,
			},
	}
--今天是否可以 数值产出
--[[
	args = {
		gamename = gamename,
	}
--]]
function MiniGameCommon.CanProduce(args)
	local self = MiniGameCommon;
	if(not args)then return end
	local gamename = args.gamename;
	local item = self.games[gamename];
	commonlib.echo("==========MiniGameCommon.CanProduce");
	commonlib.echo(args);
	commonlib.echo(item);
	if(item)then
		local exID = item.exID;
		local gsid = item.gsid;
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid);
		commonlib.echo(gsObtain);
		if(gsObtain and gsObtain.inday < 10)then
			return true;
		end
	end
end

-- get attribute produce extendedcost id
function MiniGameCommon.GetProduceExid(gamename)
	local item = MiniGameCommon.games[gamename];
	if(item) then
		return item.exID;
	end
end

--产生的物品是否 超过数量100
--[[
	args = {
		gsid = gsid,
		num = num,
	}
--]]
function MiniGameCommon.CanProduceOthers(args)
	local self = MiniGameCommon;
	if(not args)then return end
	local gsid = args.gsid;
	local num = args.num or 1;
	local maxItems = 100;
	local __,__,__,copies = hasGSItem(gsid);
	copies = copies or 0
	commonlib.echo("=======check produce item in flash game");
	commonlib.echo(gsid);
	commonlib.echo(copies);
	local n = maxItems - ( copies + num );
	if(n >= 0)then
		return true;
	end
end
function MiniGameCommon.ShowPageDialog(gamename)
	local self = MiniGameCommon;
	local loot_scale = AntiIndulgenceArea.GetLootScale();
	if(loot_scale < 1)then
		_guihelper.MessageBox("你玩游戏的时间太长了，先休息一下吧！");
		return;
	end
	if(not gamename)then return end
	local args = self.games[gamename];
	if(not args)then return end
	local gametitle = args.gametitle or "";
	local s = string.format([[<div style='margin-left:15px;margin-top:35px;text-align:center'>你要开始“%s”游戏吗？</div>]],gametitle);
	_guihelper.MessageBox(s, function(result) 
			if(_guihelper.DialogResult.Yes == result) then
				MiniGameCommon.ShowPage(gamename)
			elseif(_guihelper.DialogResult.No == result) then
			end
		end, _guihelper.MessageBoxButtons.YesNo);
end
function MiniGameCommon.ShowPage(gamename)
	local self = MiniGameCommon;
	if(not gamename)then return end
	local args = self.games[gamename];
	if(not args)then return end
	local gamename = string.format("MiniGames.%s",args.gamename or "game");
	local url = string.format("script/kids/3DMapSystemUI/MiniGames/MiniGameCommonPage.html?gamename=%s&gamepage=%s",args.gamename,args.gamepage);
	local swffile = args.swffile;
	local download_list = {
		{filename = swffile,filesize = 10,},
	}
	local _root = ParaUI.GetUIObject("root");
	local _, __, width, height = _root:GetAbsPosition();
	MiniGameCommon.max_width = width; 
	MiniGameCommon.max_height = height; 
	MiniGameCommon.left = -MiniGameCommon.max_width / 2;
	MiniGameCommon.top = -MiniGameCommon.max_height / 2;

	if(width >= 1020 and height >= 680)then
		MiniGameCommon.flash_width = 1020;
		MiniGameCommon.flash_height = 680; 
	end
	Map3DSystem.App.MiniGames.PreLoaderDialog.StartDownload({download_list = download_list,txt = {"正在打开游戏，请稍等......"}},function(msg)
		if(msg and msg.state == "finished")then
			System.App.Commands.Call("File.MCMLWindowFrame", {
					url = url, 
					name = gamename, 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					style = CommonCtrl.WindowFrame.ContainerStyle,
					zorder = 1,
					isTopLevel = true,
					directPosition = true,
						align = self.align,
						x = self.left,
						y = self.top,
						width = self.max_width,
						height = self.max_height,
				});
			commonlib.echo({self.left,self.top,self.max_width,self.max_height});
			--hook this flash window
			Map3DSystem.App.MiniGames.SetCurWindow({name = gamename,left = self.left,top = self.top,width = self.max_width,height = self.max_height});
	
			-- stop game music
			MyCompany.Aries.Scene.StopRegionBGMusic();
			--失去输入法的焦点
			--ParaUI.SetIMEOpenStatus(false)

			local gamepage = commonlib.gettable(args.gamepage)
			if(gamepage and gamepage.OnOpened)then
				gamepage.OnOpened();
			end
		end
	end)

end
function MiniGameCommon.GetPage()
	local self = MiniGameCommon;
	return self.page;
end
function MiniGameCommon.SetPage(page)
	local self = MiniGameCommon;
	self.page = page;
end
function MiniGameCommon.ClosePage(gamename)
	local self = MiniGameCommon;
	if(not gamename)then return end
	local gamename = string.format("MiniGames.%s",gamename or "game");
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name=gamename, 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
	--unhook this flash window
	Map3DSystem.App.MiniGames.SetCurWindow(nil);
	ParaScene.GetAttributeObject():CallField("UnLoadFlashTextures");
end
function MiniGameCommon.DoClick(gamename)
    if(not gamename)then return end
    local s = "MiniGames."..gamename;
    System.App.Commands.Call(s);
end
function MiniGameCommon.QuestDoAddValue(args)
	local self = MiniGameCommon;
	if(not args)then return end
	local gamename = args.gamename;
	local score = args.score;
	local gameinfo = self.games[gamename];
	if(gameinfo and score > 0)then
		local id = gameinfo.game_gsid;
		if(id)then
			local command = System.App.Commands.GetCommand("Aries.Quest.DoAddValue");
			if(command) then
				command:Call({
					increment = { {id = id,value = score}, },
					});
			end
		end
	end
end