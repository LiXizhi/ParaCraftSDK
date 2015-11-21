--[[
Title: The dock page
Author(s): LiXizhi
Date: 2012/12/28
Desc:  
There dock has 2 mode: one for editor and one for creator
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/MyselfPlayerArea.lua");
local MyselfPlayerArea = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.MyselfPlayerArea");
MyselfPlayerArea.ShowPage(true)
-------------------------------------------------------
]]
local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
local MyselfPlayerArea = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.MyselfPlayerArea");

function MyselfPlayerArea.OnInit()
end

function MyselfPlayerArea.ShowPage(bShow)
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Areas/MyselfPlayerArea.html", 
			name = "MyselfPlayerArea.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = false,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			bShow = bShow,
			directPosition = true,
				align = "_rb",
				x = -600,
				y = -64,
				width = 600,
				height = 64,
		});
end
