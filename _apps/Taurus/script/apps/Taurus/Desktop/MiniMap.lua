--[[
Title: Desktop Minimap Area for Taurus App
Author(s): WangTian
Date: 2008/12/2
See Also: script/apps/Taurus/Desktop/TaurusDesktop.lua
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
NPL.load("(gl)script/apps/Taurus/Desktop/MiniMap.lua");
MyCompany.Taurus.Desktop.MiniMap.InitMiniMap()
------------------------------------------------------------
]]

-- create class
local libName = "TaurusDesktopMinimap";
local MiniMap = commonlib.gettable("MyCompany.Taurus.Desktop.MiniMap");

-- invoked at Desktop.InitDesktop()
function MiniMap.InitMiniMap()
	local _minimap = ParaUI.GetUIObject("MinimapArea")
	if(_minimap:IsValid() == true) then
		return;
	end
	-- Minimap area
	local _minimap = ParaUI.CreateUIObject("container", "MinimapArea", "_rt", -136, 0, 136, 136);
	_minimap.background = "";
	_minimap.zorder = -1;
	_minimap:AttachToRoot();
		local _minimapContent = ParaUI.CreateUIObject("container", "MinimapContent", "_fi", 0, 0, 0, 0);
		_minimap:AddChild(_minimapContent);
		-- show the page on the minimap content
		MiniMap.MinimapPage = System.mcml.PageCtrl:new({url="script/apps/Taurus/Desktop/MinimapPage.html"});
		MiniMap.MinimapPage:Create("AquariusMinimapPage", _minimapContent, "_fi", 4, 4, 4, 4);

	if(System.options.layout == "iCad") then
		_minimap.visible = false;
	end
end