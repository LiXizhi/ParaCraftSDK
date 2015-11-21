--[[
Title: RibbonControl
Author(s): LiXizhi
Date: 2008/10/28
Desc: It displays RibbonTabs. It will cache previous displayed ribbon tabs, so that the next time the UI are drawn, it will show up very fast
It will automatically resize itself to best contain the current selected mcml ribbon tab page. 
References: 
- http://www.devcomponents.com/dotnetbar/ribbon-control.aspx
- http://msdn.microsoft.com/en-us/library/aa338202.aspx/
- http://office.microsoft.com/en-us/products/HA101679411033.aspx
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/RibbonControl.lua");
local ctl = CommonCtrl.RibbonControl:new({
	name = "RibbonControl1",
	alignment = "_lb",
	left = 410,
	top = -70,
	width = 500,
	height = 40,
	parent = nil,
	tabs = {
		["Avatar"] = {file="script/apps/HelloChat/Ribbons/AvatarTab.html", bSkipCache=nil, onshow = function(bShow)   end, },
		["Media"] = {file="script/apps/HelloChat/Ribbons/MediaTab.html", bSkipCache=nil}, onshow = "MyCompany.HelloChat.RibbonControl.OnShowCreation()",
		["Creation"] = {file="script/apps/HelloChat/Ribbons/CreationTab.html", bSkipCache=nil},
		["Tools"] = {file="script/apps/HelloChat/Ribbons/ToolsTab.html", bSkipCache=nil},
		["WorldBuilder"] = {file="script/apps/HelloChat/Ribbons/WorldBuilderTab.html", bSkipCache=nil},
	}
});
ctl:ShowTab("Avatar");
-------------------------------------------------------
]]

local RibbonControl = {
	-- name 
	name = "RibbonControl1",
	-- layout
	alignment = "_lb",
	left = 410,
	top = -70,
	width = 500,
	height = 40,
	parent = nil,
	-- properties
	isChecked = false,
	text = "check box",
	-- mapping from tabname to a table of tab properties.
	-- the tab properties include, {file, onshow, bSkipCache}, where file is an xml file to shown. onshow is a function or function name string to be called when the tab is shown or hidden. 
	tabs = {},
};
CommonCtrl.RibbonControl = RibbonControl;

-----------------------------
-- for radiobox group
-----------------------------
function RibbonControl:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function RibbonControl:Destroy ()
	ParaUI.Destroy(self.name);
end

-- show a given tab, it will 
-- @param tabName: name of the tabs, such as Avatar, Media, Creations, Tools, etc, if nil, it will hide all
-- @param bToggle: if true, the second call with the same tabName will hide the control
-- @param bSkipCache: if bSkipCache is true, it will not save the tabFile UI controls. Otherwise, we will cache all UI controls 
-- so that the next time the UI are drawn, it will show up very fast
-- @return: true if visible, false if hidden.
function RibbonControl:ShowTab(tabName, bToggle, bSkipCache)
	local _this, _parent;
	if(not tabName) then
		-- hide all tabs
		_parent = ParaUI.GetUIObject(self.name);
		if(_parent:IsValid())then
			local name, tab
			for name, tab in pairs(self.tabs) do
				if(tab.parent_id) then
					local _tmp = ParaUI.GetUIObject(tab.parent_id);
					if(_tmp:IsValid()) then
						if(_tmp.visible) then
							self:ShowTab_(tab, false);
						end	
					else
						tab.parent_id = nil;
					end
				end
			end
			_parent.visible = false;
		end
		return;
	end
	
	local curTab = self.tabs[tabName];
	if(not curTab) then
		log(tabName.." is not found in RibbonControl\n");
		return 
	end
	curTab.bSkipCache = bSkipCache;
	
	if(bSkipCache and curTab.parent_id) then
		ParaUI.Destroy(curTab.parent_id);
		curTab.parent_id = nil;
	end
	
	_parent = ParaUI.GetUIObject(self.name);
	if(_parent:IsValid() == false)then
		_parent = ParaUI.CreateUIObject("container", self.name, self.alignment,self.left,self.top,self.width,self.height);
		_parent.background = "";
		
		if(self.parent == nil)then
			_parent:AttachToRoot();
		else
			self.parent:AddChild(_parent);
		end
	end
	
	if(bToggle and curTab.parent_id)then
		_this = ParaUI.GetUIObject(curTab.parent_id);
		if(_this:IsValid()) then
			if(_this.visible) then
				self:ShowTab_(curTab, false);
				_parent.visible= false;
				return false;
			end	
		end
	end
	_parent.visible= true;
	
	local name, tab;
	for name, tab in pairs(self.tabs) do
		if(name~=tabName) then
			-- hide other tabs
			if(tab.parent_id) then
				local _tmp = ParaUI.GetUIObject(tab.parent_id);
				if(_tmp:IsValid()) then
					if(_tmp.visible) then
						self:ShowTab_(tab, false);
					end	
				else
					tab.parent_id = nil;
				end
			end
		end	
	end
	if(curTab) then
		-- show current tab
		tab = curTab;
		if(tab.parent_id) then
			local _tmp = ParaUI.GetUIObject(tab.parent_id);
			if(_tmp:IsValid()) then
				_tmp.visible = true;
				_parent.width = _tmp.width;
			else
				tab.parent_id = nil;
			end
		end	
		if(not tab.parent_id) then
			-- create the tab here
			_this = ParaUI.CreateUIObject("container", self.name..tabName, "_lt", 0, 0, 2000, 2000)
			_this.background = "";
			_parent:AddChild(_this);
			tab.parent_id = _this.id;
			local page = Map3DSystem.mcml.PageCtrl:new({url=tab.file})
			page:Create(self.name..tabName..".page", _this, "_fi", 0, 0, 0, 0);
			
			tab.width, tab.height = page:GetUsedSize();
			_this.width = tab.width;
			_this.height = tab.height;
			_parent.width = tab.width;
			
			-- log(tab.file .." ribbon tab loaded\n");
		end
		self:ShowTab_(tab, true);
	end
	return true;
end

-- private: make the tab bShow, and call the onshow event
function RibbonControl:ShowTab_(tab, bShow)
	if(tab.parent_id) then
		local _tmp = ParaUI.GetUIObject(tab.parent_id);
		if(_tmp:IsValid()) then
			_tmp.visible = bShow;
			if(tab.onshow) then
				if(type(tab.onshow) =="function") then
					tab.onshow(bShow);
				elseif(type(tab.onshow) =="string") then
					local onshow = commonlib.getfield(tab.onshow)
					if(type(onshow) =="function") then
						onshow(bShow);
					else
						tab.onshow = nil;
						log("warning: invalid onshow function for RibbonControl %s\n", tab.onshow)
					end	
				end
			end
		end
	end	
end
