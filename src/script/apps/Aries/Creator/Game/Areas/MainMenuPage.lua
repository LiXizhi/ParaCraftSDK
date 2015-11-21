--[[
Title: MainMenu
Author(s): LiXizhi
Date: 2013/10/15
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/MainMenuPage.lua");
local MainMenuPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.MainMenuPage");
MainMenuPage.ShowPage(true)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/BlockTemplatePage.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/CreatorDesktop.lua");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local BlockTemplatePage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.BlockTemplatePage");
local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local CreatorDesktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.CreatorDesktop");
local MainMenuPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.MainMenuPage");

local page;

function MainMenuPage.OnInit()
	page = document:GetPageCtrl();
	MainMenuPage.UpdateModeUI();

	GameLogic.events:AddEventListener("game_mode_change", MainMenuPage.OnGameModeChanged, MainMenuPage, "MainMenuPage");
	GameLogic.events:AddEventListener("view_change", MainMenuPage.OnViewChanged, MainMenuPage, "CreatorDesktop");

	page:SetValue("toolbar_view", CreatorDesktop.GetCurrentView().name);
end

function MainMenuPage.OnClickChangeGameMode(gamemode)
	Desktop.OnActivateDesktop(gamemode);
end

-- callback function
function MainMenuPage:OnGameModeChanged()
	MainMenuPage.UpdateModeUI();
end

function MainMenuPage:OnViewChanged(event)
	if(page) then
		if(page:GetValue("toolbar_view") ~= CreatorDesktop.GetCurrentView().name) then
			page:SetValue("toolbar_view", CreatorDesktop.GetCurrentView().name);
		end
	end
end

function MainMenuPage.UpdateModeUI()
	if(page) then
		local mode = GameLogic.GetMode();
		page:SetValue("gamemode", mode);
	end
end

function MainMenuPage.OnClick(name)
	if(name == "toggle_sky") then
		NPL.load("(gl)script/apps/Aries/Creator/Env/SkyPage.lua");
		local SkyPage = commonlib.gettable("MyCompany.Aries.Creator.SkyPage");

		local att = ParaScene.GetAttributeObjectSky();
		if(att:GetField("SimulatedSky", false)) then
			SkyPage.OnChangeSkybox(2);
		else
			SkyPage.OnChangeSkybox(1);
		end

	elseif(name:match("^time_")) then
		if(name == "time_morning") then
			CommandManager:RunCommand("time", "-0.5");
		elseif(name == "time_noon") then
			CommandManager:RunCommand("time", "0");
		elseif(name == "time_evening") then
			CommandManager:RunCommand("time", "0.8");
		elseif(name == "time_night") then
			CommandManager:RunCommand("time", "1");
		end
	end
end

-- from night to noo by sliderbar
function MainMenuPage.OnTimeSliderChanged(value)
	if (value) then
		local time=(value/100-0.5)*2;
		time = tostring(time);
		CommandManager:RunCommand("time", time);
	end	
end

-- change view
function MainMenuPage.OnChangeView(value)
	CreatorDesktop.OnChangeView(value);
end