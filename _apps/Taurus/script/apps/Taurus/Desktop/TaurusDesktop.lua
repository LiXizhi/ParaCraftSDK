--[[
Title: Desktop UI for Taurus App
Author(s): WangTian
Date: 2008/12/2
Desc: The desktop UI contains: 
	1. left top area: current user and target profile
	2. right middle area: current chat window tabs
	3. right top area: mini map and status arranged around the minimap
	4. middle bottom area: always on top first level function list, it further divides into:
		4.1 Menu, "windows start"-like icon to show all the applications in a window
		4.2 Quick Launch, customizable bar that holds user specific organization
		4.3 Current App, shows the current application icon indicating the running application status
		4.4 UtilBar1, utility bar 1, show small icons of utility
		4.5 UtilBar2, utility bar 2, show large icons of utility
Note: Each area is further divided into 4 files
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
NPL.load("(gl)script/apps/Taurus/Desktop/TaurusDesktop.lua");
MyCompany.Taurus.Desktop.InitDesktop();
MyCompany.Taurus.Desktop.SendMessage({type = MyCompany.Taurus.Desktop.MSGTYPE.SHOW_DESKTOP, bShow = true});
------------------------------------------------------------
]]

-- create class
local libName = "TaurusDesktop";
local Desktop = {};
commonlib.setfield("MyCompany.Taurus.Desktop", Desktop);

-- individual files of each UI area
--NPL.load("(gl)script/apps/Taurus/Desktop/Profile.lua");
NPL.load("(gl)script/apps/Taurus/Desktop/Minimap.lua");
NPL.load("(gl)script/apps/Taurus/Desktop/Dock.lua");
--NPL.load("(gl)script/apps/Taurus/Desktop/ChatTabs.lua");


-- messge types
Desktop.MSGTYPE = {
	-- show/hide the task bar, 
	-- msg = {bShow = true}
	SHOW_DESKTOP = 1001,
};

-- call this only once at the beginning of Taurus. 
-- init desktop components
function Desktop.InitDesktop()
	if(Desktop.IsInit) then return end
	Desktop.IsInit = true;
	Desktop.name = libName;
	
	-- initialize each desktop area
	Desktop.MiniMap.InitMiniMap();
	Desktop.Dock.InitDock();
end

-- whenever user switched world and desktop is activated. 
-- refresh all user interfaces here. 
function Desktop.OnActivateDesktop()

	-- 0 will use unlit biped selection effect. 1 will use yellow border style. 
	local DefaultTheme = commonlib.gettable("MyCompany.Aries.Theme.Default");
	ParaScene.GetPlayer():SetField("SelectionEffect", DefaultTheme.BipedSelectionEffect or 1);
	
	NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
	local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
	GameLogic.Init();

	-- this ensure that proper ui is displayed
	Desktop.SendMessage({type = MyCompany.Aries.Desktop.MSGTYPE.ON_ACTIVATE_DESKTOP, level = MyCompany.Aries.Player.GetLevel()});
end


-- send a message to Desktop:main window handler
-- Desktop.SendMessage({type = Desktop.MSGTYPE.MENU_SHOW});
function Desktop.SendMessage(msg)
	msg.wndName = "main";
	--Desktop.App:SendMessage(msg);
end


-- Desktop window handler
function Desktop.MSGProc(window, msg)
	if(msg.type == Desktop.MSGTYPE.SHOW_DESKTOP) then
		-- show/hide the task bar, 
		-- msg = {bShow = true}
		Desktop.Show(msg.bShow);
	end
end

-------------------------
-- protected
-------------------------

-- show or hide task bar UI
function Desktop.Show(bShow)
	Desktop.Dock.Show();
end