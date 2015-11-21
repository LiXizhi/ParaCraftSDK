--[[
Title: 
Author(s): Leio
Date: 2009/10/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/LuckyDialPage.lua");
local s = string.format('ÄãÒª¿ªÊ¼¡°%s¡±Âð£¿',Map3DSystem.App.MiniGames.LuckyDialPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.LuckyDialPage.ShowPage);
Map3DSystem.App.MiniGames.LuckyDialPage.ToggleShow(bShow)
--
System.App.Commands.Call("MiniGames.LuckyDial");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local LuckyDialPage = {
	page = nil,
	gamename = "LuckyDial",
	gametitle = "È¤Î¶´ó³é½±",
	gift_map = {
		{ label = "ÍÒÄñ±äÉíÒ©Íè", gsid = 16032,},
		{ label = "°µºÚÒ©Íè", gsid = 16049,},
		{ label = "ÑªºìÒ©Íè", gsid = 16050,},
		{ label = "×ÏÉ«Ò©Íè", gsid = 16046,},
		{ label = "ÂÌÉ«Ò©Íè", gsid = 16045,},
		{ label = "»ÆÉ«Ò©Íè", gsid = 16048,},
		{ label = "³ÈÉ«Ò©Íè", gsid = 16047,},
		{ label = "3¼¶²¶ÊÞÍø", gsid = 17082,},
	}
}
commonlib.setfield("Map3DSystem.App.MiniGames.LuckyDialPage",LuckyDialPage);

function LuckyDialPage.OnInit()
	local self = LuckyDialPage;
	self.page = document:GetPageCtrl();
end
function LuckyDialPage.ShowPage()
	local self = LuckyDialPage;
	MiniGameCommon.ShowPage(self.gamename);
	self.CallFlash();
end

-- 2010/7/10: this function is added by andy
function LuckyDialPage.OnOpened()
	local self = LuckyDialPage;
	self.CallFlash();
end

function LuckyDialPage.CallFlash()
	local self = LuckyDialPage;
	if(self.page)then
		local ctl = self.page:FindControl("flashctl");
		if(ctl)then
			local index = ctl.FlashPlayerIndex;
			
			--»ñµÃÊÇ·ñº¬ÓÐÐÂÄêÀñÈ¯
			local ItemManager = System.Item.ItemManager;
			local __,__,__,certificate = self.HasCertificate();
			certificate = certificate or 0;
			local func_args = {
						funcName = "setCertificate",
						args = {
							certificate,
						}
					} 
			commonlib.CallFlashFunction(index, func_args)
		end
	end
end
function LuckyDialPage.ClosePage()
	local self = LuckyDialPage;
	MiniGameCommon.ClosePage(self.gamename);
end
--if has certificate
function LuckyDialPage.HasCertificate()
	local self = LuckyDialPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	return hasGSItem(17078);
end
function LuckyDialPage.ClosePageFromAs()
	local self = LuckyDialPage;
	---- resume game music
	MyCompany.Aries.Scene.StopGameBGMusic();
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.log("LuckyDialPage will be closed\n")
	self.ClosePage();
end
function LuckyDialPage.CallNPLFromAs(gift_index)
	local self = LuckyDialPage;
	if(not gift_index or not self.HasCertificate())then return end
	local item = self.gift_map[gift_index];
	commonlib.echo(gift_index);
	commonlib.echo(item);
	if(item)then
		local gsid = item.gsid;
		Map3DSystem.Item.ItemManager.PurchaseItem(gsid, 1, function(msg) end,function(msg)
			
		end);
		self.DoDestroyItem();
	end
end
function LuckyDialPage.DoDestroyItem()
	local self = LuckyDialPage;
	local ItemManager = System.Item.ItemManager;
	local hasItem,guid = self.HasCertificate();
	if(hasItem and guid)then
		ItemManager.DestroyItem(guid, 1, function(msg) end,function(msg)
		
		end);
	end
end