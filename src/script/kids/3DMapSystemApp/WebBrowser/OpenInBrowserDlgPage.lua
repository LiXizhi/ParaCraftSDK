--[[
Title: world info page
Author(s): LiXizhi
Date: 2008/6/22
Desc: 
display a dialog asking the user whether to open url in external browser or internal browser. 
<verbatim>
	"script/kids/3DMapSystemApp/WebBrowser/OpenInBrowserDlgPage.html?url=your_url_browser"
</verbatim>
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/OpenInBrowserDlgPage.lua");
Map3DSystem.App.WebBrowser.OpenInBrowserDlgPage.Show(url, x, y)
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/WindowFrame.lua");
-- create class
local OpenInBrowserDlgPage = {};
commonlib.setfield("Map3DSystem.App.WebBrowser.OpenInBrowserDlgPage", OpenInBrowserDlgPage)

---------------------------------------------------
-- show a top level popup window for a mouse cursor 3D mesh object
---------------------------------------------------
OpenInBrowserDlgPage.Name = "OpenInBrowserDlg";

-- @param url: url to open. if nil, the window will be destroyed
-- @param x,y: position at which to display the window. If nil, the center of screen is used. 
function OpenInBrowserDlgPage.Show(url, x, y)
	if(not url) then
		OpenInBrowserDlgPage.OnClose()
		return
	end
	
	-- TODO: ensure x,y is inside window area. 
	local _this,_parent;
	_this=ParaUI.GetUIObject(OpenInBrowserDlgPage.Name);
	
	if(_this:IsValid() == false) then
		local width, height = 512, 180;
		if(x==nil and  y==nil) then
			_this = ParaUI.CreateUIObject("container", OpenInBrowserDlgPage.Name, "_ct", -width/2, -height/2, width, height)
			_this:SetTopLevel(true);
		else
			_this = ParaUI.CreateUIObject("container", OpenInBrowserDlgPage.Name, "_lt", x, y, width, height)
		end	
		if(_guihelper.MessageBox_BG ~=nil) then
			_this.background = _guihelper.MessageBox_BG;
		end	
		_this:AttachToRoot();
		_parent = _this;
		
		local openurl = Map3DSystem.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemApp/WebBrowser/OpenInBrowserDlgPage.html", {url=url});
		if(OpenInBrowserDlgPage.MyPage == nil) then
			OpenInBrowserDlgPage.MyPage = Map3DSystem.mcml.PageCtrl:new({url=openurl});
		else
			OpenInBrowserDlgPage.MyPage:Init(openurl);
		end	
		OpenInBrowserDlgPage.MyPage:Create("OpenInBrowserDlgPage", _parent, "_fi", 0, 0, 0, 0)
		_this = _parent;
	else
		if(x and y) then
			_this.x = x;
			_this.y = y;
		end
	end
	
	--OpenInBrowserDlgPage.MyPage:SetUIValue("url", url);
	
	_this.visible = true;
	if(x and y) then
		CommonCtrl.WindowFrame.MoveContainerInScreenArea(_this);
	end	
end

function OpenInBrowserDlgPage.OnInit()
	local page = document:GetPageCtrl();
	local url = page:GetRequestParam("url");
	if(url) then
		local domain = string.match(url, "^http://%w+%.([^/]+)");
		if(domain) then
			if(domain == "paraengine.com" or domain == "pala5.com" or domain == "pala5.cn") then
				page:GetNode("SaftyNotice"):SetAttribute("display", "none")
			end	
		end
		page:SetNodeValue("url", url);
	end	
end

-- open using internal browser
function OpenInBrowserDlgPage.OnOpenInternal()
	OpenInBrowserDlgPage.OnClose()
	NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/BrowserWnd.lua");
	local url = document:GetPageCtrl():GetNodeValue("url");
	-- open with embedded brower
	Map3DSystem.App.WebBrowser.BrowserWnd.DisplayNavBar = true;
	Map3DSystem.App.WebBrowser.BrowserWnd.zorder = 1; -- use a z order of 1.
	Map3DSystem.App.WebBrowser.BrowserWnd.ShowWnd(Map3DSystem.App.WebBrowser.app._app)
	if(url~=nil) then
		Map3DSystem.App.WebBrowser.BrowserWnd.NavigateTo(url);
	end
end

-- open using external system web browser, such as ie
function OpenInBrowserDlgPage.OnOpenExternal()
	OpenInBrowserDlgPage.OnClose()
	-- open with external browser
	local url = document:GetPageCtrl():GetNodeValue("url");
	if(url) then
		ParaGlobal.ShellExecute("open", "iexplore.exe", url, "", 1);
	end	
end


-- open using external system web browser, such as ie
function OpenInBrowserDlgPage.OnClose()
	ParaUI.Destroy(OpenInBrowserDlgPage.Name);
end
