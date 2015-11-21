--[[
Title: 
Author(s): Leio
Date: 2009/9/20
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeatsPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
Map3DSystem.App.MiniGames.BeginGamePage.Show('ÄãÒª¿ªÊ¼"ÌøÎè"Âð',Map3DSystem.App.MiniGames.BeatsPage.ShowPage);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
-- default member attributes
local BeatsPage = {
	page = nil,
	align = "_ct",
	left = -480,
	top = -280,
	width = 960,
	height = 560, 
	
	coin_list = {
		{40,0},
		{150,5},
		{300,20},
		{440,40},
		{900,80},
		{1200,100},
		{1600,180},
		{2000,250},
		{2200,300},
		{2500,350},
		{2800,400},
		{3500,450},
		{3501,500},
	},
}
commonlib.setfield("Map3DSystem.App.MiniGames.BeatsPage",BeatsPage);

function BeatsPage.OnInit()
	local self = BeatsPage;
	self.page = document:GetPageCtrl();
end
function BeatsPage.ShowPage()
	local self = BeatsPage;
	local parent = ParaUI.CreateUIObject("container", "BeatsPage_Bg", "_fi", 0,0,0,0);
	parent.background = "Texture/bg_black.png";
	parent:AttachToRoot();
	
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/MiniGames/BeatsPage.html", 
			name = "MiniGames.BeatsPage", 
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
				width = self.width,
				height = self.height,
		});
end
function BeatsPage.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MiniGames.BeatsPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
		
	ParaUI.Destroy("BeatsPage_Bg");
end
function BeatsPage.GetCoin(score)
	if(score < 0)then score = 0; end
	local self = BeatsPage;
	local k,v;
	for k,v in ipairs(self.coin_list) do
		local _score = v[1];
		local _coin = v[2];
		if(_score > score)then
			return _coin
		end
	end
	local len = table.getn(self.coin_list);
	return self.coin_list[len][2];
end
function BeatsPage.CallNPLFromAs(score)
	local self = BeatsPage;
	self.ClosePage();
	if(not score or score <0)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
	local coin = self.GetCoin(score)
	Map3DSystem.App.MiniGames.GameScorePage.Bind("beats",score,coin);
	Map3DSystem.App.MiniGames.GameScorePage.ShowPage();
end
--[[
local command = System.App.Commands.GetCommand("Profile.Aries.DoMountPetAction");
command:Call({anim = "character/Animation/v5/dalong/PurpleDragonMajorFemale_penghuo.x",headonchar = "character/common/tag/tag.x"});

local command = System.App.Commands.GetCommand("Profile.Aries.DoMountPetAction");
command:Call({anim = "character/Animation/v5/dalong/PurpleDragonMajorFemale_penghuo.x",headonmodel = "model/07effect/v5/PitFire/PitFire.x"});
local command = System.App.Commands.GetCommand("Profile.Aries.DoMountPetAction");
command:Call({anim = "character/Animation/v5/dalong/PurpleDragonMajorFemale_penghuo.x",headonchar = "character/v3/GameNpc/EMSS/EMSS.x"});

local anim = "character/Animation/v5/dalong/PurpleDragonMajorFemale_penghuo.x"
local headonchar = "model/07effect/v5/PitFire/PitFire.x"

local player = ParaScene.GetPlayer();
System.Animation.PlayAnimationFile(anim, player);
player:ToCharacter():RemoveAttachment(11);

local asset  = ParaAsset.LoadParaX("",headonchar);
if(asset~=nil and asset:IsValid()) then
	player:ToCharacter():AddAttachment(asset, 11);
end
--]]

