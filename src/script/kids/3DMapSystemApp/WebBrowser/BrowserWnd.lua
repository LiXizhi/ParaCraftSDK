--[[
Title: a simple web browser
Author(s): LiXizhi
Date: 2007/10/29

TODO: figure out a way to disable either mozilla mouse cursor or paraengine mouse cursor. Currently these two conflicts with each other
mozilla will internally set the mouse cursor on mouse move and click events. This conflicts with the use of d3d hardware cursor. However, currently there is no workaround. I have tried to hook all WM_SETCURSOR events, but it does not work. 
Current key events are sent to mozilla through the HWND and windows message pipeline, which is why I do not need to send key event to it.

TODO: Address bar history

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/BrowserWnd.lua");
Map3DSystem.App.WebBrowser.BrowserWnd.BrowserName = "<html>";
Map3DSystem.App.WebBrowser.BrowserWnd.DisplayNavBar = true;
Map3DSystem.App.WebBrowser.BrowserWnd.Show(bShow,_parent,parentWindow)
Map3DSystem.App.WebBrowser.BrowserWnd.ShowWnd(_app)
Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo("http://www.paraengine.com");
Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo("local://readme.txt");
------------------------------------------------------------
]]
-- requires:
NPL.load("(gl)script/ide/event_mapping.lua");
-- create
commonlib.setfield("Map3DSystem.App.WebBrowser.BrowserWnd", {});

-- whether to display the nav bar
Map3DSystem.App.WebBrowser.BrowserWnd.DisplayNavBar = true;
-- default browser window name. it should always begin with "<html>", texture file with the same name will be bind to the web browser window. 
Map3DSystem.App.WebBrowser.BrowserWnd.BrowserName = "<html>";
-- home page url
Map3DSystem.App.WebBrowser.BrowserWnd.HomePageURL = "www.paraengine.com";
-- a file containing url addresses
Map3DSystem.App.WebBrowser.BrowserWnd.UrlAddressesFile = "config/webbrowser_urls.txt";

-- private: internal use
Map3DSystem.App.WebBrowser.BrowserWnd.LastStatusText = {}


-- display the main inventory window for the current user.
function Map3DSystem.App.WebBrowser.BrowserWnd.ShowWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("BrowserWnd") or _app:RegisterWindow("BrowserWnd", nil, Map3DSystem.App.WebBrowser.BrowserWnd.MSGProc);
	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/page_world.png",
			text = "Web浏览器(Beta)",
			initialPosX = 55,
			initialPosY = 60,
			initialWidth = 900,
			initialHeight = 512,
			allowDrag = true,
			zorder = Map3DSystem.App.WebBrowser.BrowserWnd.zorder, -- z order
			ShowUICallback =Map3DSystem.App.WebBrowser.BrowserWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end

function Map3DSystem.App.WebBrowser.BrowserWnd.Show(bShow,_parent,parentWindow)
	local _this;
	Map3DSystem.App.WebBrowser.BrowserWnd.parentWindow = parentWindow;

	-- display a dialog asking for options
	local temp = ParaUI.GetUIObject("Map3DSystem.App.WebBrowser.BrowserWnd");
	_this=ParaUI.GetUIObject("Map3DSystem.App.WebBrowser.BrowserWnd");
	if(_this:IsValid()) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		if(bShow == false) then
			Map3DSystem.App.WebBrowser.BrowserWnd.OnDestory();
		end
	else
		if(bShow == false) then return end
		local width, height = 461, 240

		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","Map3DSystem.App.WebBrowser.BrowserWnd", "_ct",-width/2,-height/2-50,width, height);
			_this:AttachToRoot();
		else
			_this=ParaUI.CreateUIObject("container","Map3DSystem.App.WebBrowser.BrowserWnd", "_fi",0,0,0,0);
			_this.background = "";
			_parent:AddChild(_this);
		end
		_parent = _this;
		
		local wndName = Map3DSystem.App.WebBrowser.BrowserWnd.BrowserName;
		local top = 0;
		
		-------------------------
		-- navbar
		if(Map3DSystem.App.WebBrowser.BrowserWnd.DisplayNavBar) then
			local oldparent = _parent;
			_this = ParaUI.CreateUIObject("container", "navBar", "_mt", 0, top, 0, 32)
			_parent:AddChild(_this);
			_parent = _this;
			
			top = top+32;

			NPL.load("(gl)script/ide/dropdownlistbox.lua");
			local ctl = CommonCtrl.dropdownlistbox:new{
				name = "Map3DSystem.App.WebBrowser.BrowserWnd".."comboBoxAddress",
				alignment = "_mt",
				left = 91,
				top = 3,
				width = 200,
				height = 24,
				dropdownheight = 106,
 				parent = _parent,
				text = "",
				items = Map3DSystem.App.WebBrowser.BrowserWnd.LoadURLListFromFile(Map3DSystem.App.WebBrowser.BrowserWnd.UrlAddressesFile),
				onselect = string.format("Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavTo(%q);", wndName),
			};
			ctl:Show();

			_this = ParaUI.CreateUIObject("text", "label1", "_lt", 13, 8, 72, 16)
			_this.text = "地址:";
			_this:GetFont("text").color = "128 128 128";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "navTo", "_rt", -194, 3, 24, 24)
			_this.background = "Texture/3DMapSystem/webbrowser/goto.png"
			_this.onclick = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavTo(%q);", wndName);
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "navBack", "_rt", -154, 3, 24, 24)
			_this.background = "Texture/3DMapSystem/webbrowser/lastpage.png"
			_this.onclick = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavBack(%q);", wndName);
			_this.animstyle = 12;
			_parent:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "navForward", "_rt", -124, 3, 24, 24)
			_this.background = "Texture/3DMapSystem/webbrowser/nextpage.png"
			_this.onclick = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavForward(%q);", wndName);
			_this.animstyle = 12;
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "Stop", "_rt", -94, 3, 24, 24)
			_this.background = "Texture/3DMapSystem/webbrowser/stop.png"
			_this.onclick = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavStop(%q);", wndName);
			_this.animstyle = 12;
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "RefreshBtn", "_rt", -64, 3, 24, 24)
			_this.background = "Texture/3DMapSystem/webbrowser/refresh.png"
			_this.onclick = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavRefresh(%q);", wndName);
			_this.animstyle = 12;
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "homeBtn", "_rt", -34, 3, 24, 24)
			_this.background = "Texture/3DMapSystem/webbrowser/homepage.png"
			_this.onclick = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnClickHomePage(%q);", wndName);
			_this.animstyle = 12;
			_parent:AddChild(_this);
			
			_parent = oldparent;
		end	

		-------------------------
		-- htmlWnd
		_this=ParaUI.CreateUIObject("container","htmlWnd", "_fi",0,top,0,20);
		_this.onmousedown = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseDown(%q);", wndName);
		_this.onmouseup = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseUp(%q);", wndName);
		_this.onmousemove = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseMove(%q);", wndName);
		_this.onmousewheel = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseWheel(%q);", wndName);
		--_this.onkeydown = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnKeyDown(%q);", wndName);
		_this.onmouseenter = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseEnter(%q);", wndName); 
		_this.onmouseleave = string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseLeave(%q);", wndName);
		_parent:AddChild(_this);
		
		-------------------------
		-- status bar
		_this=ParaUI.CreateUIObject("container","status_bar", "_mb",0,0,0,19);
		_parent:AddChild(_this);
		
		_parent = _this;
		_this=ParaUI.CreateUIObject("text","text", "_lt",10,3,300,16);
		_guihelper.SetUIFontFormat(_this, 36+256); -- single lined and no clip.
		_parent:AddChild(_this);
	
		------------------------------------
		-- just testing to display a page
		Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo("http://www.google.com");	
		--Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo("http://www.yahoo.com");	
		--Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo("http://www.paraengine.com");	
		
		------------------------------------
		-- init browser event handler
		ParaBrowserManager.onStatusTextChange(";Map3DSystem.App.WebBrowser.BrowserWnd.onStatusTextChange()");
		--ParaBrowserManager.onPageChanged(string.format(";Map3DSystem.App.WebBrowser.BrowserWnd.onPageChanged(%q)", wndName));
		
	end	
	
end

----------------------------------
-- methods
----------------------------------
-- destory the control
function Map3DSystem.App.WebBrowser.BrowserWnd.OnDestory()
	ParaUI.Destroy("Map3DSystem.App.WebBrowser.BrowserWnd");
	ParaBrowserManager.onStatusTextChange(nil);
	local wndName = Map3DSystem.App.WebBrowser.BrowserWnd.BrowserName;
	local wnd = ParaBrowserManager.GetBrowserWindow(wndName);
	if(wnd:IsValid()) then
		wnd:focusBrowser( false ); -- this does not seem to lose focus. 
		wnd:setEnabled(false);
		if(not Map3DSystem.App.WebBrowser.BrowserWnd.UseSystemCursor) then
			ParaUI.SetUseSystemCursor(false);
		end	
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnClose()
	if(Map3DSystem.App.WebBrowser.BrowserWnd.parentWindow~=nil) then
		-- send a message to its parent window to tell it to close. 
		Map3DSystem.App.WebBrowser.BrowserWnd.parentWindow:SendMessage(Map3DSystem.App.WebBrowser.BrowserWnd.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		Map3DSystem.App.WebBrowser.BrowserWnd.OnDestory()
	end
end

-- go to a given url.
-- @param url: such as "www.paraengine.com", "http://www.lixizhi.net", 
-- it can also contain relative path like "local://Texture/3DMapSystem/HTML/Credits.html"
function Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo(url)
	local wndName = Map3DSystem.App.WebBrowser.BrowserWnd.BrowserName;
	local wnd = ParaBrowserManager.GetBrowserWindow(wndName);
	local _this = ParaUI.GetUIObject("Map3DSystem.App.WebBrowser.BrowserWnd"):GetChild("htmlWnd");
	if(not wnd:IsValid()) then
		local _,_, width, height = _this:GetAbsPosition();
		width = width or 512;
		height = height or 512;
		
		-- this ensures that render texture is always smaller than 1024*1024
		if(width>1024) then
			height = 1024/width*height;
			width = 1024;
		end
		if(height>1024) then
			width = 1024/height*width;
			height = 1024;
		end
		--log("creation browser size:"..width..","..height.."\n");
		wnd = ParaBrowserManager.createBrowserWindow(wndName, width, height);
	else
		-- TODO: send window resize message so that the browser window size is same as the HTML renderer browser size
	end
	if(wnd:IsValid()) then
		wnd:setEnabled(true);
		
		local URI;
		if(string.find(url, "local://")~=nil) then
			-- convert "local://.*" to "file:///D:/lxzsrc/ParaEngine/ParaWorld/.*"
			URI = string.gsub(url, "local://(.*)$", "file:///"..ParaIO.GetCurDirectory(0).."%1");
		end
		wnd:navigateTo(URI or url);
	end
	-------------------------
	-- update UI
	if(_this:IsValid()) then
		-- update main render texture url
		_this.background = wndName; -- such as _this.background = "<html>1#http://www.paraengine.com";
	end
	if(Map3DSystem.App.WebBrowser.BrowserWnd.DisplayNavBar) then
		-- update address bar
		local ctl = CommonCtrl.GetControl("Map3DSystem.App.WebBrowser.BrowserWnd".."comboBoxAddress");
		if(ctl~=nil)then
			ctl:SetText(url);
		end
	end
end


-- get the browser mouse cursor position by screen coordinate
-- @param UIObject: UI Window object
-- @param wnd: Browser texture window
-- @param screen_x, screen_y : usually mouse_x, mouse_y from the "onmouseup" event handler
function Map3DSystem.App.WebBrowser.BrowserWnd.windowPosToTexturePos(UICtrl, wndBrowser, screen_x, screen_y)
	if(UICtrl:IsValid() and wndBrowser:IsValid()) then
		-- get relative click position in control
		local x,y, temp_width, temp_height = UICtrl:GetAbsPosition();
		x,y = screen_x - x, screen_y - y;
		local width, height = wndBrowser:getBrowserWidth(),wndBrowser:getBrowserHeight();
		x=x/temp_width*width;
		y=y/temp_height*height;
		return x,y;
	end	
end

-- read URL list from a file and return a table containing those URLs.
function Map3DSystem.App.WebBrowser.BrowserWnd.LoadURLListFromFile(sFileName)
	local urls = {};
	local file = ParaIO.open(sFileName, "r");
	if(file:IsValid()) then
		local url;
		local nIndex = 1;
		while(true) do 
			url = file:readline();
			if(url~=nil) then
				urls[nIndex] = url;
				nIndex = nIndex+1;
			else
				break;
			end	
		end
	end	
	file:close();
	return urls;
end
-- write a table containing URLs to a file
function Map3DSystem.App.WebBrowser.BrowserWnd.SaveURLListToFile(sFileName, items)
	local file = ParaIO.open(sFileName, "w");
	local url;
	for _, url in ipairs(items) do
		file:WriteString(url.."\r\n");
	end
	file:close();
end


----------------------------------------------------
-- window events 
----------------------------------------------------
-- this determines whether we will change the cursor icon when mouse enter and leaves the browser window, since browser window will use its own cursor than the game engine.
Map3DSystem.App.WebBrowser.BrowserWnd.UseSystemCursor = ParaUI.GetUseSystemCursor();

function Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseDown(browserName)
	local UICtrl = ParaUI.GetUIObject("Map3DSystem.App.WebBrowser.BrowserWnd"):GetChild("htmlWnd");
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	local x, y = Map3DSystem.App.WebBrowser.BrowserWnd.windowPosToTexturePos(UICtrl, wndBrowser, mouse_x, mouse_y);
	if(x~=nil and y~=nil) then
		wndBrowser:mouseDown(x,y);
		
		--local width, height = wndBrowser:getBrowserWidth(),wndBrowser:getBrowserHeight();
		--log("browser size:"..width..","..height.."\n");
		--log("Down"..x..", "..y.."\n")
	end
	
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseUp(browserName)
	local UICtrl = ParaUI.GetUIObject("Map3DSystem.App.WebBrowser.BrowserWnd"):GetChild("htmlWnd");
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	local x, y = Map3DSystem.App.WebBrowser.BrowserWnd.windowPosToTexturePos(UICtrl, wndBrowser, mouse_x, mouse_y);
	if(x~=nil and y~=nil) then
		-- send event to mozilla
		wndBrowser:mouseUp(x,y);
		--log("up"..x..", "..y.."\n")
		-- this seems better than sending focus on mouse down (still need to improve this)
		wndBrowser:focusBrowser( true )
		
		if(not Map3DSystem.App.WebBrowser.BrowserWnd.UseSystemCursor) then
			ParaUI.SetUseSystemCursor( true );
		end	
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseMove(browserName)
	local UICtrl = ParaUI.GetUIObject("Map3DSystem.App.WebBrowser.BrowserWnd"):GetChild("htmlWnd");
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	local x, y = Map3DSystem.App.WebBrowser.BrowserWnd.windowPosToTexturePos(UICtrl, wndBrowser, mouse_x, mouse_y);
	if(x~=nil and y~=nil) then
		wndBrowser:mouseMove(x,y);
		--log("move"..x..", "..y.."\n")
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseWheel(browserName)
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(wndBrowser:IsValid()) then
		wndBrowser:scrollByLines(-mouse_wheel);
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseEnter(browserName)
	--ParaUI.ShowCursor(false);
	-- TODO: figure out a way to disable either mozilla mouse cursor or paraengine mouse cursor. Currently these two conflicts with each other
	
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(wndBrowser:IsValid()) then
		wndBrowser:setEnabled( true);
		if(not Map3DSystem.App.WebBrowser.BrowserWnd.UseSystemCursor) then
			ParaUI.SetUseSystemCursor( true );
		end	
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnMouseLeave(browserName)
	--ParaUI.ShowCursor(true);
	
	-- disable window on leave, this will prevent key messages to be sent to mozilla.
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(wndBrowser:IsValid()) then
		-- TODO: not reasonable. it will stop transferring data and send message. However, I found no other way to stop sky message to mozilla.
		wndBrowser:focusBrowser( false ); -- this does not seem to lose focus. 
		if(not Map3DSystem.App.WebBrowser.BrowserWnd.UseSystemCursor) then
			ParaUI.SetUseSystemCursor(false);
		end	
		--wndBrowser:setEnabled( false); 
	end
end

-- this function is not called.Key events is directly sent to the window
function Map3DSystem.App.WebBrowser.BrowserWnd.OnKeyDown(browserName)
	--_guihelper.MessageBox(tostring(virtual_key).." is down.\n");
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(not wndBrowser:IsValid()) then
		return 
	end
	
	if(virtual_key >= Event_Mapping.EM_KEY_A and virtual_key <=Event_Mapping.EM_KEY_Z ) then
		wndBrowser:keyPress(65+virtual_key-Event_Mapping.EM_KEY_A);
	elseif(virtual_key >= Event_Mapping.EM_KEY_0 and virtual_key <=Event_Mapping.EM_KEY_9 ) then
		wndBrowser:keyPress(30+virtual_key-Event_Mapping.EM_KEY_0);
	end
end

----------------------------------
-- control methods
----------------------------------
function Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavForward(browserName)
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(wndBrowser:IsValid()) then
		wndBrowser:navigateForward();
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavBack(browserName)
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(wndBrowser:IsValid()) then
		wndBrowser:navigateBack();
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavStop(browserName)
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(wndBrowser:IsValid()) then
		wndBrowser:navigateStop();
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavRefresh(browserName)
	-- TODO: currently same as go to button.
	Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavTo(browserName);
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnClickNavTo(browserName)
	local wndBrowser = ParaBrowserManager.GetBrowserWindow(browserName);
	if(wndBrowser:IsValid()) then
		-- update address bar
		local ctl = CommonCtrl.GetControl("Map3DSystem.App.WebBrowser.BrowserWnd".."comboBoxAddress");
		if(ctl~=nil)then
			local url = ctl:GetText();
			if(url~=nil) then
				Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo(url);
			end
		end
	end
end

function Map3DSystem.App.WebBrowser.BrowserWnd.OnClickHomePage(browserName)
	Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo(Map3DSystem.App.WebBrowser.BrowserWnd.HomePageURL);
end

----------------------------------------------------
-- browser events 
----------------------------------------------------
-- never called
function Map3DSystem.App.WebBrowser.BrowserWnd.onPageChanged() 
	log("web page changed \n");
end

function Map3DSystem.App.WebBrowser.BrowserWnd.onStatusTextChange()
	if(msg.windowid~=nil and msg.value~=nil) then
		-- update status UI, we will only update if it is different from the last one.
		if(Map3DSystem.App.WebBrowser.BrowserWnd.LastStatusText[msg.windowid] ~= msg.value) then
			Map3DSystem.App.WebBrowser.BrowserWnd.LastStatusText[msg.windowid] = msg.value;
			ParaUI.GetUIObject("Map3DSystem.App.WebBrowser.BrowserWnd"):GetChild("status_bar"):GetChild("text").text = msg.value;
		end	
	end	
end

function Map3DSystem.App.WebBrowser.BrowserWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:ShowWindowFrame(false);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end
