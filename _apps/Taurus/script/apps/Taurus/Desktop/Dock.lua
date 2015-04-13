--[[
Title: Desktop Dock Area for Taurus App
Author(s): WangTian
Date: 2008/12/2
See Also: script/apps/Taurus/Desktop/TaurusDesktop.lua

	4. middle bottom area: always on top first level function list, it further divides into:
		4.1 Menu, "windows start"-like icon to show all the applications in a window
		4.2 Quick Launch, customizable bar that holds user specific organization
		4.3 Current App, shows the current application icon indicating the running application status
		4.4 UtilBar1, utility bar 1, show small icons of utility
		4.5 UtilBar2, utility bar 2, show large icons of utility
		
Area: 
	---------------------------------------------------------
	| Profile										Mini Map|
	|														|
	| 													 C	|
	| 													 h	|
	| 													 a	|
	| 													 t	|
	| 													 T	|
	| 													 a	|
	| 													 b	|
	|													 s	|
	|														|
	|														|
	|														|
	|														|
	| Menu | QuickLaunch | CurrentApp | UtilBar1 | UtilBar2	|
	|©»©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥Dock©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¿ |
	---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/Desktop/Dock.lua");
MyCompany.Taurus.Desktop.Dock.InitDock();
------------------------------------------------------------
]]

-- create class
local libName = "TaurusDesktopDock";
local Dock = {};
commonlib.setfield("MyCompany.Taurus.Desktop.Dock", Dock);

-- data keeping
-- current icons of dock area
Dock.RootNode = CommonCtrl.TreeNode:new({Name = "DockRoot",});

Dock.RootNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "File.ArtTools", params = nil}));

-- invoked at Desktop.InitDesktop(), it assert this function is invoked only once
function Dock.Show()
	local _dock = ParaUI.GetUIObject("Dock");
	if(_dock:IsValid() == true) then
		return;
	end
	local _dock = ParaUI.CreateUIObject("container", "Dock", "_ctb", 0, 0, 808, 80);
	_dock.background = "";
	_dock:GetAttributeObject():SetField("ClickThrough", true);
	_dock:AttachToRoot();
	
	local url
	if(System.options.layout == "iCad") then
		url = "script/apps/Taurus/Desktop/DockPage.iCad.html";
	else
		url = "script/apps/Taurus/Desktop/DockPage.html";
	end

	Dock.page = Dock.page or System.mcml.PageCtrl:new({url=url, click_through=true});
	Dock.page:Create("TaurusDockPage", _dock, "_fi", 0, 0, 0, 0);
end