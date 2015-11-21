--[[
Title: WebBrowser app for Paraworld
Author(s): LiXizhi
Date: 2008/1/28
Desc: 
---++ File.WebBrowser
other app can open an browser using this command with this app. 
<verbatim>
	Map3DSystem.App.Commands.Call("File.WebBrowser", url);
</verbatim>
---++ File.MCMLBrowser
the second param can be a table of {name, title, url, DisplayNavBar, x,y, width, height, icon, iconsize}
<verbatim>
	Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="", name="MyBrowser", title="My browser", DisplayNavBar = true, DestroyOnClose=nil});
</verbatim>

| *name* | *desc* |
| url | mcml url |
| name | unique string of window name.  |
| title | string of window title |
| DisplayNavBar | true to display navigation bar|
| DestroyOnClose | default to nil. if true, it will destroy the window if user clicks close window button |

---++ File.MCMLWindowFrame
create and show a window frame using pure mcml. app_key is for which application the winframe is created if nil WebBrowserApp key is used. name is the window name. 
<verbatim>
	-- show create
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {url="", name="MyBrowser", app_key, bToggleShowHide=true, DestroyOnClose=nil, [win frame parameters]});
	-- hide a window frame 
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MyBrowser", app_key, bShow=false});
	-- refresh page
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MyBrowser", app_key, bRefresh=true});
	-- show page with advanced parameters
	local params = {
		url = "script/apps/Aries/Desktop/AriesMinRequirementPage.html", 
		name = "AriesMinRequirementWnd", 
		isShowTitleBar = false,
		--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -550/2,
			y = -380/2,
			width = 550,
			height = 380,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = function()
	end
</verbatim>
the second param can be a table with following field
| *name* | *desc* |
| url | mcml url |
| refresh | if true, it will refresh url even it is the same as last. |
| bShow | boolean: show or hide the window |
| bAutoSize, bAutoWidth, bAutoHeight | if true, the window size is based on the inner mcml page. Please note that one can still specify width and height of the window params. they are similar to the max size allowed. Page must be local in order for this to behave correctly. this may be improved in future. |
| bDestroy | if true, it will destroy the window |
| bRefresh | if true to refresh the page. only name and app_key input are required. |
| bToggleShowHide | if true, it will toggle show hide |
| DestroyOnClose | default to nil. if true, it will destroy the window if user clicks close window button |
| enable_esc_key | enable esc key. if true, the esc key will hide or close the window. |
| SelfPaint | use a render texture to paint on  |
| [win frame parameters] | all windowsframe property are support. |

Return values are via input params table.
| _page | the page control object. One may overwrite the OnClose Method |

---++ File.WinExplorer
Open a file or directory using default windows explorer. 
<verbatim>
	Map3DSystem.App.Commands.Call("File.WinExplorer", "readme.txt");
	-- silent mode. 
	Map3DSystem.App.Commands.Call("File.WinExplorer", {filepath="readme.txt", silentmode=true});
</verbatim>

the second param can be a table with following field
| *name* | *desc* |
| filepath | it can be relative or absolute file path |
| silentmode | boolean: if true, no dialog is displayed for confirmation. otherwise a dialog is displayed for confirmation. defrault to false. |

db registration insert script
INSERT INTO apps VALUES (NULL, 'WebBrowser_GUID', 'WebBrowser', '1.0.0', 'http://www.paraengine.com/apps/WebBrowser_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/WebBrowser/IP.xml', '', 'script/kids/3DMapSystemApp/WebBrowser/app_main.lua', 'Map3DSystem.App.WebBrowser.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/app_main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local WebBrowser = commonlib.gettable("Map3DSystem.App.WebBrowser");

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.WebBrowser.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a WebBrowser command link in the main menu 
		local commandName = "File.WebBrowser";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command ~= nil) then
			local pos_category = commandName;
			-- insert before File.GroupLast.
			local index = Map3DSystem.UI.MainMenu.GetItemIndex("File.GroupLast");
			-- add to front.
			command:AddControl("mainmenu", pos_category, index);
		end
	else
		-- place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about =  "Embedded web browser."
		Map3DSystem.App.WebBrowser.app = app; 
		app.HideHomeButton = true;
		
		local commandName = "File.WinExplorer";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"外部浏览器", icon = app.icon, });
		end
		
		local commandName = "File.WebBrowser";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"Web浏览器", icon = app.icon, });
		end
		
		local commandName = "File.MCMLBrowser";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"MCML浏览器", icon="Texture/3DMapSystem/AppIcons/FrontPage_64.dds", });
		end
		
		local commandName = "File.MCMLWindowFrame";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "MCML Window Frame", icon = app.icon, });
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.WebBrowser.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("File.WebBrowser");
		if(command == nil) then
			command:Delete();
		end
	end
	-- TODO: just release any resources at shutting down. 
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Map3DSystem.App.WebBrowser.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- return enabled and supported 
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- message proc for File.MCMLWindowFrame
local function MCMLWinFrameMSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		local preVisibility = nil;
		if(window and window:IsVisible() == true) then
			preVisibility = true;
		end
		
		if(window.MyPage and window.MyPage.OnClose) then
			window.MyPage:OnClose(window.DestroyOnClose or msg.bDestroy);
		end
		if(window.DestroyOnClose or msg.bDestroy) then
			window:DestroyWindowFrame();
		else
			window:ShowWindowFrame(false);
		end	
		
		-- NOTE 2009/11/10: if the hook is called before the close process, another File.MCMLWindowFrame bShow = false call will
		--					find the window frame not destoryed or closed then it will also call the OnMCMLWindowFrameInvisible hook
		-- call hook OnMCMLWindowFrameInvisible
		if(preVisibility == true) then
			local msg = { aries_type = "OnMCMLWindowFrameInvisible", name = window.name, wndName = "main"};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
		end
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		if(window.enable_esc_key) then --  and System.options.isAB_SDK
			-- esc key logics here
			if(msg.param1) then
				window.esc_state = window.esc_state or {name = "McmlEscKey", OnEscKey = function()  
					window:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE});
				end}
				System.PushState(window.esc_state);
			elseif(window.esc_state) then
				System.PopState(window.esc_state)
			end
		end
		-- commonlib.echo({"WM_SHOW", window.name, msg.param1})
	end
end

-- show File.MCMLWindowFrame in the parent window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param parentWindow: parent os window object, parent window for sending messages
local function MCMLWinFrameShow(bShow, _parent, parentWindow)
	local page_name = tostring(_parent.id); -- use id of parent as the page name. 
	local _this = _parent:GetChild(page_name);
	if(_this:IsValid())then
		if(bShow==nil) then
			bShow = not _this.visible;
		end
		if(_this.visible ~= bShow) then
			_this.visible = bShow;
		end
	else
		if(bShow == false) then return end
		bShow = true;
		parentWindow.MyPage = Map3DSystem.mcml.PageCtrl:new({url=parentWindow.url});
		if(parentWindow.SelfPaint) then
			parentWindow.MyPage.SelfPaint = true;
		end
		if(_parent:GetField("ClickThrough", false)) then
			parentWindow.MyPage.click_through = true;
		end
		parentWindow.MyPage:Create(page_name, _parent, "_fi", 0, 0, 0, 0)
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.WebBrowser.OnExec(app, commandName, params)
	if(commandName == "File.WebBrowser") then
		-- if params is nil, the current url is shown
		-- if params is string, the url is params
		-- if params is table {BrowserName, URL}, it opens a url with a given texture name. 
		-- e.g.
		NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/BrowserWnd.lua");
		local url;
		if(type(params) == "table") then
			if(params.BrowserName~=nil) then
				Map3DSystem.App.WebBrowser.BrowserWnd.BrowserName = params.BrowserName;
			end
			if(params.URL~=nil) then
				url = params.URL;
			end
		elseif(type(params) == "string") then
			url = params;
		end
		if(url~=nil) then
			-- using mcml page instead
			if(url ~= "#") then
				ParaGlobal.ShellExecute("open", url, "", "", 1);
				--NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/OpenInBrowserDlgPage.lua");
				--Map3DSystem.App.WebBrowser.OpenInBrowserDlgPage.Show(url)
			else
				_guihelper.MessageBox("本功能此版本中未开放,敬请期待");
			end	
		else
			Map3DSystem.App.WebBrowser.BrowserWnd.DisplayNavBar = true;
			Map3DSystem.App.WebBrowser.BrowserWnd.ShowWnd(app._app)
		end
	elseif(commandName == "File.MCMLBrowser") then	
		if(type(params) == "string") then
			params = {url = params};
		elseif(type(params) ~= "table") then	
			params = {url="", name="MyMCMLBrowser", title="MCML browser", DisplayNavBar = true, DestroyOnClose=true};
			--log("warning: File.MCMLBrowser command must have input of a table\n")
			--return;
		end
		NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/MCMLBrowserWnd.lua");
		local _wnd = Map3DSystem.App.WebBrowser.MCMLBrowserWnd.ShowWnd(app._app, params)
		
	elseif(commandName == "File.WinExplorer") then		
		if(type(params) == "string") then
			params = {filepath = params};
		elseif(type(params) ~= "table") then	
			log("warning: File.WinExplorer command must have input of a table\n")
			return;
		end
		
		if(params.filepath~=nil) then
			local absPath;
			if(string.match(params.filepath,":")) then
				absPath = params.filepath
			else	
				absPath = string.gsub(ParaIO.GetCurDirectory(0)..params.filepath, "/", "\\");
			end
			
			if(absPath~=nil) then
				if(not params.silentmode) then
					_guihelper.MessageBox(string.format(L"您确定要使用Windows浏览器打开文件 %s?", commonlib.Encoding.DefaultToUtf8(absPath)), function()
						ParaGlobal.ShellExecute("open", "explorer.exe", absPath, "", 1); 
					end);
				else
					ParaGlobal.ShellExecute("open", "explorer.exe", absPath, "", 1); 
				end	
			end
		end
		
	elseif(commandName == "File.MCMLWindowFrame") then		
		if(type(params) ~= "table" or not params.name) then	
			log("warning: File.MCMLWindowFrame command must have input of a table or name field is nonexistent\n")
			return;
		end
		if(params.bAutoSize or params.bAutoWidth or params.bAutoHeight) then
			if(params.cancelShowAnimation== nil) then
				params.cancelShowAnimation = true;
			end
		end
		params.app_key = params.app_key or app.app_key;
		local _app = CommonCtrl.os.GetApp(params.app_key); -- Map3DSystem.App.AppManager.GetApp(params.app_key);
		if(_app) then
			local _wnd = _app:FindWindow(params.name) or _app:RegisterWindow(params.name, nil, MCMLWinFrameMSGProc);
			if(params.bRefresh) then
				if(_wnd.MyPage) then
					_wnd.MyPage:Refresh(0);
				end
			elseif(params.bDestroy) then
				-- hide the window
				_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE, bDestroy=true});
			elseif(params.bShow == false) then
				-- hide the window
				_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE});
			else
				-- show the window frame
				local _wndFrame = _wnd:GetWindowFrame();
				local isFrameExist = true;
				if(not _wndFrame) then
					isFrameExist = false;
					params.wnd = _wnd;
					params.ShowUICallback = MCMLWinFrameShow;
					_wndFrame = _wnd:CreateWindowFrame(params);
				end
				_wnd.url = params.url or _wnd.url;
				_wnd.DestroyOnClose = params.DestroyOnClose;
				_wnd.enable_esc_key = params.enable_esc_key;
				_wnd.SelfPaint = params.SelfPaint;
				_wnd.isPinned = params.isPinned;
				
				if(params.bToggleShowHide and params.bShow==nil) then
					if(_wnd.MyPage and _wnd.MyPage.url~=_wnd.url and _wnd.url and _wnd.MyPage.url) then
						_wnd:ShowWindowFrame(true);
					else
						if(_wnd.DestroyOnClose and _wnd:IsVisible())  then
							_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE, bDestroy=true});
						else
							_wnd:ShowWindowFrame();
						end
					end	
				else
					_wnd:ShowWindowFrame(true);
				end	
				
				if(params.text or params.title or params.icon) then
					_wnd:SetWindowText(params.text or params.title, params.icon)
				end
				
				-- refresh if url has changed. 
				if(_wnd.MyPage) then
					if(not _wnd.MyPage.window) then
						_wnd.MyPage.window = _wnd;
					end	
					if(_wnd.MyPage.url~=_wnd.url or params.refresh or (_wnd.MyPage.url == _wnd.url and params.refreshEvenSameURLIfFrameExist and isFrameExist)) then
						if(params.bAutoSize or params.bAutoWidth or params.bAutoHeight) then
							_wndFrame:MoveWindow(nil, nil, _wndFrame.width, _wndFrame.height);
						end
						_wnd.MyPage:Goto(_wnd.url);
					end
					if(params.bAutoSize or params.bAutoWidth or params.bAutoHeight) then
						-- adjust the size according to inner html page 
						local width, height = _wnd.MyPage:GetUsedSize();
						if(width and height) then
							if(not params.bAutoSize and not params.bAutoWidth) then width=nil end
							if(not params.bAutoSize and not params.bAutoHeight) then height=nil end
							_wndFrame:MoveWindow(nil, nil, width, height);
						end
					end
				end	
			end
			params._page = _wnd.MyPage;
		else
			commonlib.log("warning: app with app_key %s is not found when calling File.MCMLWindowFrame\n", params.app_key);
		end
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.WebBrowser.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.WebBrowser.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.WebBrowser.DoQuickAction();
	end
end


-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.WebBrowser.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.WebBrowser.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.WebBrowser.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.WebBrowser.DoQuickAction()
end

-------------------------------------------
-- client world database function helpers.
-------------------------------------------

------------------------------------------
-- all related messages
------------------------------------------
-----------------------------------------------------
-- APPS can be invoked in many ways: 
--	Through app Manager 
--	mainbar or menu command or buttons
--	Command Line 
--  3D World installed apps
-----------------------------------------------------
function Map3DSystem.App.WebBrowser.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.WebBrowser.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.WebBrowser.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.WebBrowser.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.WebBrowser.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.WebBrowser.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.WebBrowser.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.WebBrowser.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.WebBrowser.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end