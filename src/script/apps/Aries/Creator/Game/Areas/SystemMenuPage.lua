--[[
Title: The dock page
Author(s): LiXizhi
Date: 2012/12/28
Desc:  
There dock has 2 mode: one for editor and one for creator
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/SystemMenuPage.lua");
local SystemMenuPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SystemMenuPage");
SystemMenuPage.ShowPage(true)
-------------------------------------------------------
]]
local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
local SystemMenuPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SystemMenuPage");

function SystemMenuPage.OnInit()
end

function SystemMenuPage.ShowPage(bShow)
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Areas/SystemMenuPage.html", 
			name = "SystemMenuPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = false,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			bShow = bShow,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_rb",
				x = -260,
				y = -400,
				width = 250,
				height = 300,
		});
end
