--[[
Title: 
Author(s): leio
Date: 2012/06/06
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/CodeExample/HelloWindow.lua");
local HelloWindow = commonlib.gettable("MyCompany.Taurus.CodeExample.HelloWindow");
HelloWindow.ShowPage();
-------------------------------------------------------
]]
local HelloWindow = commonlib.gettable("MyCompany.Taurus.CodeExample.HelloWindow");
HelloWindow.grid_view_datasource = {
	{ label = "标签1", tag = "test_1",},
	{ label = "标签2", tag = "test_2",},
	{ label = "标签3", tag = "test_3",},
	{ label = "标签4", tag = "test_4",},
	{ label = "标签5", tag = "test_5",},
	{ label = "标签6", tag = "test_6",},
	{ label = "标签7", tag = "test_7",},
	{ label = "标签8", tag = "test_8",},
}
function HelloWindow.OnInit()
	HelloWindow.page = document:GetPageCtrl();
end
function HelloWindow.ShowPage()
	local params = {
				url = "script/apps/Taurus/CodeExample/HelloWindow.html", 
				name = "HelloWindow.ShowPage", 
				app_key=MyCompany.Taurus.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_ct",
					x = -760/2,
					y = -470/2,
					width = 760,
					height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end
function HelloWindow.DS_Func_Items(index)
	if(not HelloWindow.grid_view_datasource)then return 0 end
	if(index == nil) then
		return #(HelloWindow.grid_view_datasource);
	else
		return HelloWindow.grid_view_datasource[index];
	end
end
function HelloWindow.DoClick(index)
	if(not index)then return end
	local node = HelloWindow.grid_view_datasource[index];
	if(node)then
		node.label = "已经被点击";
		if(HelloWindow.page)then
			HelloWindow.page:Refresh(0);
		end
	end
end