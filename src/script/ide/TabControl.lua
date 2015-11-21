--[[
Title: TabControl
Author(s): WangTian
Date: 2008/8/27
Desc: TabControl manages a related set of tab pages. 
Notes:
A TabControl contains tab pages, which are represented by TabPage objects that you add through the TabPages property. 
The order of tab pages in this collection reflects the order the tabs appear in the control. The user can change the current 
TabPage by clicking one of the tabs in the control. You can also programmatically change the current TabPage by using 
one of the following TabControl properties:
	SelectedIndex 
	SelectedTab 
	SelectTab 
	DeselectTab 

	-- NOTE: if TabPage is userdata, it's regarded as UI object
	--		if TabPage is string, it's regarded as MCML url and use PageCtrl to show the MCML page
	--		if TabPage is function, it's regarded as a function(_parent, bShow, wnd) to show the ui object
	--		if TabPage is table, it's regarded as a control that can get through CommonCtrl.GetControl()
	
The tabs in a TabControl are part of the TabControl, but not parts of the individual TabPage controls. Members of the TabPage class, 
such as the ForeColor property, affect only the client rectangle of the tab page, but not the tabs. Additionally, the Hide method 
of the TabPage will not hide the tab. To hide the tab, you must remove the TabPage control from the TabControl.TabPages collection.

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/TabControl.lua");

-------------------------------------------------------
]]


-- create class
local TabControl = {};
commonlib.setfield("CommonCtrl.TabControl", TabControl);


-- default TabControl input template
TabControl.SampleInputTemplate = {
	
	name = "sampleTabControl", -- name of the tabcontrol
	parent = nil, -- parent ui object
	background = nil, -- base background of the tabcontrol
	pagebackground = nil, -- tabpage common background
	wnd = nil, -- os window object that message is sent to
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 300, -- base ui object container, alignment and size
	zorder = 0,
	
	TabAlignment = "Left", -- Left|Right|Top|Bottom, Top if nil
	TabPages = nil, -- CommonCtrl.TreeNode object, collection of tab pages
	TabHeadOwnerDraw = function(_parent, tabControl) end, -- area between top/left border and the first item
	TabTailOwnerDraw = function(_parent, tabControl) end, -- area between the last item and buttom/right border
	TabStartOffset = 16, -- start of the tabs from the border
	TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) end, -- owner draw item
	TabItemWidth = 48, -- width of each tab item
	TabItemHeight = 48, -- height of each tab item
	MaxTabNum = 10, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
	OnSelectedIndexChanged = function(fromIndex, toIndex, tabControl) end, -- onchange index event
};


-- create an instance. 
function TabControl:new(o)
	o = o or {}   -- create object if user does not provide one
	if(type(o.name) ~= "string") then
		log("error: must provide a name for the TabControl object\n");
	end
	
	setmetatable(o, self)
	self.__index = self
	
	CommonCtrl.AddControl(o.name, o);
	return o
end

function TabControl:Destroy()
end

-- show the tabcontrol
function TabControl:Show(bShow)
	local _parent = self.parent;
	
	local _tabControl = ParaUI.GetUIObject(self.name.."_TabControl");
	if(_tabControl:IsValid() == false) then
		if(bShow == false) then	
			return;
		end
		
		-- main container
		_tabControl = ParaUI.CreateUIObject("container", self.name.."_TabControl", self.alignment, self.left, self.top, self.width, self.height);
		_tabControl.background = self.background or "";
		_tabControl.zorder = self.zorder or 0;
		if(self.parent ~= nil and self.parent:IsValid() == true) then
			self.parent:AddChild(_tabControl);
		else
			_tabControl:AttachToRoot();
		end
		
		-- update tabcontrol
		self:Update();
		-- set the selected index to 1 by default
		self:SetSelectedIndex(1);
		
	else
		if(bShow == nil) then
			bShow = not _tabControl.visible;
		end
		_tabControl.visible = bShow;
	end
end

-- update the tabcontrol
function TabControl:Update()
	local _tabControl = ParaUI.GetUIObject(self.name.."_TabControl");
	if(_tabControl:IsValid() == false) then
		log("error TabControl "..self.name..": uiobject invalid\n");
		return;
	end
	_tabControl:RemoveAll();
	
	local _tabs, _head, _tail, _page;
	
	if(self.TabAlignment == "Top" or self.TabAlignment == nil) then
		local tabsWidth = self.TabItemWidth * math.min(self.MaxTabNum, self.TabPages:GetChildCount());
		_head = ParaUI.CreateUIObject("container", "TabHead", "_lt", 0, 0, self.TabStartOffset, self.TabItemHeight);
		_tabs = ParaUI.CreateUIObject("container", "Tabs", "_lt", self.TabStartOffset, 0, tabsWidth, self.TabItemHeight);
		_tail = ParaUI.CreateUIObject("container", "TabTail", "_mt", self.TabStartOffset + tabsWidth, 0, 0, self.TabItemHeight);
		_page = ParaUI.CreateUIObject("container", "TabPage", "_fi", 0, self.TabItemHeight, 0, 0);
	elseif(self.TabAlignment == "Bottom") then
		local tabsWidth = self.TabItemWidth * math.min(self.MaxTabNum, self.TabPages:GetChildCount());
		_head = ParaUI.CreateUIObject("container", "TabHead", "_lb", 0, -self.TabItemHeight, self.TabStartOffset, self.TabItemHeight);
		_tabs = ParaUI.CreateUIObject("container", "Tabs", "_lb", self.TabStartOffset, -self.TabItemHeight, tabsWidth, self.TabItemHeight);
		_tail = ParaUI.CreateUIObject("container", "TabTail", "_mb", self.TabStartOffset + tabsWidth, 0, 0, self.TabItemHeight);
		_page = ParaUI.CreateUIObject("container", "TabPage", "_fi", 0, 0, 0, self.TabItemHeight);
	elseif(self.TabAlignment == "Right") then
		local tabsHeight = self.TabItemHeight * math.min(self.MaxTabNum, self.TabPages:GetChildCount());
		_head = ParaUI.CreateUIObject("container", "TabHead", "_rt", -self.TabItemWidth, 0, self.TabItemWidth, self.TabStartOffset);
		_tabs = ParaUI.CreateUIObject("container", "Tabs", "_rt", -self.TabItemWidth, self.TabStartOffset, self.TabItemWidth, tabsHeight);
		_tail = ParaUI.CreateUIObject("container", "TabTail", "_mr", 0, self.TabStartOffset + tabsHeight, self.TabItemWidth, 0);
		_page = ParaUI.CreateUIObject("container", "TabPage", "_fi", 0, 0, self.TabItemWidth, 0);
	elseif(self.TabAlignment == "Left") then
		local tabsHeight = self.TabItemHeight * math.min(self.MaxTabNum, self.TabPages:GetChildCount());
		_head = ParaUI.CreateUIObject("container", "TabHead", "_lt", 0, 0, self.TabItemWidth, self.TabStartOffset);
		_tabs = ParaUI.CreateUIObject("container", "Tabs", "_lt", 0, self.TabStartOffset, self.TabItemWidth, tabsHeight);
		_tail = ParaUI.CreateUIObject("container", "TabTail", "_ml", 0, self.TabStartOffset + tabsHeight, self.TabItemWidth, 0);
		_page = ParaUI.CreateUIObject("container", "TabPage", "_fi", self.TabItemWidth, 0, 0, 0);
	end
	
	if(type(self.TabHeadOwnerDraw) == "function") then
		-- owner draw tab head
		self.TabHeadOwnerDraw(_head, self)
	else
		--draw default head
		_head.enabled = false;
	end
	
	if(type(self.TabTailOwnerDraw) == "function") then
		-- owner draw tab tail
		self.TabTailOwnerDraw(_tail, self)
	else
		--draw default tail
		_tail.enabled = false;
	end
	
	_head.background = "";
	_tail.background = "";
	_tabs.background = "";
	_tabs.fastrender = false; -- this is not needed, LXZ 2008.12.4? -- sure, it's needed. hide the part outside the tab area, Andy 2008.12.5
	_page.background = self.pagebackground or "";
	_tabControl:AddChild(_head);
	_tabControl:AddChild(_tail);
	_tabControl:AddChild(_tabs);
	_tabControl:AddChild(_page);
	
	local _fullTabs;
	if(self.TabAlignment == "Top" or self.TabAlignment == "Bottom" or self.TabAlignment == nil) then
		local tabsWidth = self.TabItemWidth * self.TabPages:GetChildCount();
		_fullTabs = ParaUI.CreateUIObject("container", "FullTabs", "_lt", 0, 0, tabsWidth, self.TabItemHeight);
		_fullTabs.background = "";
	elseif(self.TabAlignment == "Left" or self.TabAlignment == "Right") then
		local tabsHeight = self.TabItemHeight * self.TabPages:GetChildCount();
		_fullTabs = ParaUI.CreateUIObject("container", "FullTabs", "_lt", 0, 0, self.TabItemWidth, tabsHeight);
		_fullTabs.background = "";
	end
	_tabs:AddChild(_fullTabs);
	
	local rootNode = self.TabPages;
	local nCount = rootNode:GetChildCount();
	if(nCount >= 1) then
		local i;
		for i = 1, nCount do
			local node = rootNode:GetChild(i);
			local _tabPage;
			_tabPage = ParaUI.CreateUIObject("container", "TabPage_"..i, "_fi", 0, 0, 0, 0);
			_tabPage.background = "";
			_page:AddChild(_tabPage);
			
			if(type(node.url) == "string") then
				-- load url string MCML page
				NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
				self["TabPageCtrl_"..i] = Map3DSystem.mcml.PageCtrl:new({url = node.url});
				self["TabPageCtrl_"..i]:Create(tostring(_tabPage.id), _tabPage, "_fi", 0, 0, 0, 0)
			elseif(type(node.ShowUICallback) == "function") then
				-- show NPL ui object page
				node.ShowUICallback(true, _tabPage, nil);
			else
				-- TODO: draw default tabPage
				--_tabPage.background = "";
			end
			
			local _tab;
			if(self.TabAlignment == nil or self.TabAlignment == "Top" or self.TabAlignment == "Bottom") then
				_tab = ParaUI.CreateUIObject("container", "Tab_"..i, "_lt", self.TabItemWidth * (i - 1), 0, self.TabItemWidth, self.TabItemHeight);
				_tab.background = "";
				_fullTabs:AddChild(_tab);
			elseif(self.TabAlignment == "Left" or self.TabAlignment == "Right") then
				_tab = ParaUI.CreateUIObject("container", "Tab_"..i, "_lt", 0, self.TabItemHeight * (i - 1), self.TabItemWidth, self.TabItemHeight);
				_tab.background = "";
				_fullTabs:AddChild(_tab);
			end
		end
	end
end

function TabControl:GetSelectedIndex()
	return self.SelectedIndex;
end

function TabControl:SetSelectedIndex(index)
	if(self.OnSelectedIndexChanged ~= nil) then
		self.OnSelectedIndexChanged(self.SelectedIndex, index,self);
	end
	-- TODO: 
	self.SelectedIndex = index;
	-- update the tabs
	self:UpdateTabs();
end

-- update the tabs, mainly for the tab item click
function TabControl:UpdateTabs()
	local rootNode = self.TabPages;
	local nCount = rootNode:GetChildCount();
	
	local _tabControl = ParaUI.GetUIObject(self.name.."_TabControl");
	if(_tabControl:IsValid() == false) then
		log("error TabControl "..self.name..": uiobject invalid\n");
		return;
	end
	
	_page = _tabControl:GetChild("TabPage");
	_tabs = _tabControl:GetChild("Tabs");
	_tabs = _tabs:GetChild("FullTabs");
	
	if(nCount >= 1) then
		local i;
		for i = 1, nCount do
			local node = rootNode:GetChild(i);
			local _tabPage;
			_tabPage = _page:GetChild("TabPage_"..i);
			--_tabPage.background = "";
			local index = self.SelectedIndex; -- we allow different tabs use the same TabPage
			if(i ~= index) then
				-- hide other tab pages
				_tabPage.visible = false;
			else
				_tabPage.visible = true;
				if(node.RedirectIndex) then
					_tabPage.visible = false;
					local _redirectPage = _page:GetChild("TabPage_"..node.RedirectIndex);
					_redirectPage.visible = true;
				end
			end
			
			local _tab;
			_tab = _tabs:GetChild("Tab_"..i);
			_tab:RemoveAll();
			
			if(type(self.TabItemOwnerDraw) == "function") then
				--TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) end, -- owner draw item
				if(i == self.SelectedIndex) then
					self.TabItemOwnerDraw(_tab, i, true, self);
				else
					self.TabItemOwnerDraw(_tab, i, false, self);
				end
			else
				if(i == self.SelectedIndex) then
					local _item = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
					_item.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png";
					_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", self.name, i);
					_tab:AddChild(_item);
				else
					local _item = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
					_item.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg.png";
					_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", self.name, i);
					_tab:AddChild(_item);
				end
			end
		end
	end
end

-- onclick handler of tabcontrol tabs
function TabControl.OnClickTab(name, index)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl ~= nil) then
		ctl:SetSelectedIndex(index)
	end
end

-- page forward the tabcontrol
--		if the tabcontrol is left or right aligned, shift the tab one node upward
--		if the tabcontrol is top or bottom aligned, shift the tab one node leftward
function TabControl.PageForward(name)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl ~= nil) then
		local _tabControl = ParaUI.GetUIObject(ctl.name.."_TabControl");
		if(_tabControl:IsValid() == false) then
			log("error TabControl "..ctl.name..": uiobject invalid\n");
			return;
		end
		
		local _tabs = _tabControl:GetChild("Tabs");
		local _fullTabs = _tabs:GetChild("FullTabs");
		
		if(ctl.TabAlignment == "Top" or ctl.TabAlignment == "Bottom" or ctl.TabAlignment == nil) then
			if(_tabs.width < _fullTabs.width and _tabs.width < (_fullTabs.x + _fullTabs.width) ) then
				_fullTabs.x = _fullTabs.x - ctl.TabItemWidth;
			end
		elseif(ctl.TabAlignment == "Left" or ctl.TabAlignment == "Right") then
			if(_tabs.height < _fullTabs.height and _tabs.height < (_fullTabs.y + _fullTabs.height) ) then
				--_fullTabs.y = _fullTabs.y - ctl.TabItemHeight;
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_fullTabs);
				block:SetTime(100);
				block:SetYRange(_fullTabs.y, _fullTabs.y - ctl.TabItemHeight);
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		end
	end
end

-- page backward the tabcontrol
--		if the tabcontrol is left or right aligned, shift the tab one node downward
--		if the tabcontrol is top or bottom aligned, shift the tab one node rightward
function TabControl.PageBackward(name)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl ~= nil) then
		local _tabControl = ParaUI.GetUIObject(ctl.name.."_TabControl");
		if(_tabControl:IsValid() == false) then
			log("error TabControl "..ctl.name..": uiobject invalid\n");
			return;
		end
		
		local _tabs = _tabControl:GetChild("Tabs");
		local _fullTabs = _tabs:GetChild("FullTabs");
		
		if(ctl.TabAlignment == "Top" or ctl.TabAlignment == "Bottom" or ctl.TabAlignment == nil) then
			if(_tabs.width < _fullTabs.width and _fullTabs.x < 0 ) then
				_fullTabs.x = _fullTabs.x + ctl.TabItemWidth;
			end
		elseif(ctl.TabAlignment == "Left" or ctl.TabAlignment == "Right") then
			if(_tabs.height < _fullTabs.height and _fullTabs.y < 0 ) then
				--_fullTabs.y = _fullTabs.y + ctl.TabItemHeight;
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_fullTabs);
				block:SetTime(100);
				block:SetYRange(_fullTabs.y, _fullTabs.y + ctl.TabItemHeight);
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		end
	end
end