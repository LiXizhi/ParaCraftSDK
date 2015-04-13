--[[
Title: Dock page for Taurus App
Author(s): WangTian
Date: 2009/4/29
use the lib:
------------------------------------------------------------
script/apps/Taurus/Desktop/DockPage.html
------------------------------------------------------------
]]

-- create class
local libName = "TaurusDockPage";
local TaurusDockPage = {};
commonlib.setfield("MyCompany.Taurus.Desktop.TaurusDockPage", TaurusDockPage);

local page;

-- invoked at Desktop.InitDesktop()
function TaurusDockPage.Init()
	page = document:GetPageCtrl();
end

function TaurusDockPage.OnClickArtToolPage(bChecked)
	if(mouse_button == "left") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemApp/Developers/ArtToolsPage.html", {}), 
			name="Taurus.ArtTools", 
			app_key = MyCompany.Taurus.app.app_key, 
			text = "美术工具",
			directPosition = true,
				align = "_ct",
				x = -600/2,
				y = -510/2,
				width = 600,
				height = 510,
		});
	elseif(mouse_button == "right") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemApp/Developers/ProToolsPage.html", {}), 
			name="Taurus.DevTools", 
			app_key = MyCompany.Taurus.app.app_key, 
			text = "美术工具",
			directPosition = true,
				align = "_ct",
				x = -600/2,
				y = -510/2,
				width = 600,
				height = 510,
		});
	end
end

function TaurusDockPage.OnClickSpellCastPlayer()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Aries/Pipeline/SpellCastViewer/SpellCastViewerPage.html", {}), 
		name="Taurus.SpellCastPlayer", 
		app_key = MyCompany.Taurus.app.app_key, 
		isFastRender = false,
		text = "Spell技能编辑器",
		directPosition = true,
			align = "_ct",
			x = -850/2,
			y = -700/2,
			width = 850,
			height = 650,
	});
end

function TaurusDockPage.OnClickTeleport()
	--System.App.Commands.Call("File.MapPosLogPage");
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandMouse.lua");
	--System.App.HomeLand.ThrowBallLibs.Show();
	
	--NPL.load("(gl)script/apps/Aries/Inventory/Throwable.lua");
	--MyCompany.Aries.Inventory.ThrowablePage.Show();
	
	NPL.load("(gl)script/apps/Taurus/Desktop/InternalThrowBallPage.lua");
	MyCompany.Taurus.Desktop.InternalThrowBallPage.Show()
end

function TaurusDockPage.OnClickGenMinimap()
	System.App.Commands.Call("Profile.GenerateMiniMap");
end

--function TaurusDockPage.OnClickShowReport(bChecked)
	--System.App.Commands.Call("Creation.ShowReport", bChecked);
--end
--
--function TaurusDockPage.OnClickShowWireFrame(bChecked)
	--ParaScene.GetAttributeObject():SetField("UseWireFrame", bChecked);
--end

function TaurusDockPage.OnClickShowOBB(bChecked)
	System.App.Commands.Call("Creation.ShowOBB", bChecked);
end

function TaurusDockPage.OnClickOpenAsset()
	System.App.Commands.Call("File.Open.Asset");
	--page:CloseWindow();
end	

function TaurusDockPage.OnClickCreatorAssets()
	System.App.Commands.Call("Profile.Assets");
	--page:CloseWindow();
end	

function TaurusDockPage.OnClickAnimationPage()
	System.App.Commands.Call("Profile.CCS.AnimationPage");
	--page:CloseWindow();
end	

function TaurusDockPage.OnClickEnvPage()
	System.App.Commands.Call("Env.sky");
	System.App.Commands.Call("Env.ocean");
	
	--page:CloseWindow();
	
	-- enable/disable fog
	--ParaScene.GetAttributeObject():SetField("EnableFog", false)
end	

function TaurusDockPage.OnPlayAnimID()
	local animID = document:GetPageCtrl():GetUIValue("animID", "0");
	animID = tonumber(string.match(animID, "%d+"));
	if(animID~=nil) then
		ParaScene.GetPlayer():ToCharacter():PlayAnimation(animID);
	end
end

function TaurusDockPage.OnClickCCSItemEditor()
	System.App.Commands.Call("Profile.CCS.AdvCCSModify");
	--page:CloseWindow();
end

function TaurusDockPage.OnClickCCSItemEditorTeen()
	System.App.Commands.Call("Profile.CCS.AdvCCSModifyTeen");
	--page:CloseWindow();
end

function TaurusDockPage.OnClickWorldPage()
	System.App.Commands.Call("Profile.Taurus.WorldPage");
	--page:CloseWindow();
end

function TaurusDockPage.OnClickPortalEditor()
	System.App.Commands.Call("Creation.PortalSystem");
	--page:CloseWindow();
end

function TaurusDockPage.OnClickTerrainEditor()
	System.App.Commands.Call("Env.terrain");
	--page:CloseWindow();
end

function TaurusDockPage.OnClickObjectEditor()
	System.App.Commands.Call("Creation.ObjectEditor");
	--page:CloseWindow();
end

function TaurusDockPage.OnClickSetting()
	--page:CloseWindow();
		
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Taurus/Desktop/SettingsPage.html", {}), 
		name="Taurus.Settings", 
		app_key = MyCompany.Taurus.app.app_key, 
		text = "社区设置",
		directPosition = true,
			align = "_ct",
			x = -600/2,
			y = -510/2,
			width = 600,
			height = 510,
	});
end