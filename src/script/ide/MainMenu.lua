--[[
Title: Main menu, using buttons with top level menu item, and a tree view internally for child level menus. It has a modern appearance. 
Author(s): LiXizhi
Date: 2007/12/30
menu item Node may have following properties
{
	Icon = string, icon file
	Type = "separater", "menuitem", "title". Default to "menuitem"
	Enabled = whether menu item is enabled. 
}
------------------------------------------------------------
NPL.load("(gl)script/ide/MainMenu.lua");
local ctl = CommonCtrl.GetControl("MainMenu1");
if(ctl==nil)then
	ctl = CommonCtrl.MainMenu:new{
		name = "MainMenu1",
		alignment = "_lt",
		left = 0,
		top = 0,
		width = 300,
		height = 100,
		parent = _parent,
		onclick = function (node, param1) _guihelper.MessageBox(node.Text) end
	};
	local node = ctl.RootNode:AddChild("TopMenu1");
	node:AddChild(CommonCtrl.TreeNode:new({Text = "Node2", Name = "sample", Icon="texture.png", onclick=function}));
	node:AddChild("submenuitem1_1");
	node:AddChild(CommonCtrl.TreeNode:new({Text = "", Type = "separator", NodeHeight=5}));
	node:AddChild("submenuitem1_2");
	node = ctl.RootNode:AddChild("TopMenu2");
	node:AddChild("submenuitem2_1");
	node:AddChild("submenuitem2_2");
	node = ctl.RootNode:AddChild("TopMenu3");
	node:AddChild("submenuitem3_1");
	node:AddChild("submenuitem3_2");
else
	ctl.parent = _parent
end	

ctl:Show(true);
-- call this function when ever the top level menu item is changed. There is no need to call this function, if one only updated sub menu items. 
-- ctl:Update();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/TreeView.lua");

-- define a new control in the common control libary

-- default member attributes
local MainMenu = {
	-- the top level control name
	name = "MainMenu1",
	-- normal window size
	left = 0,
	top = 0,
	width = 400,
	height = 22, 
	-- popup menu default height
	popmenu_height = 22,
	parent = nil,
	-- this is the maximum height, a scroll bar will be used if there are too many menu items. 
	MaxHeight = 500, 
	-- this is the minimum height of the content menu, unless there are so few items to display
	MinHeight = 40, 
	PopMenuWidth = 200,
	-- auto positioning method: it can be 
	-- "_lt": left top, where the mouse x, y will be the left top point of the menu container. This is the default mode.
	-- "_lb": left bottom, where the mouse x, y will be the left bottom point of the menu container. 
	AutoPositionMode = "_lt", 
	-- if true, top level menu item is shown vertically. By default they are shown horizontally. 
	IsVertical = false,
	-- the background of menu container, default to null.
	container_bg = nil, 
	-- popmenu background
	popmenu_container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
	-- The root tree node. containing all tree node data
	RootNode = nil, 
	-- Default height of Tree Node
	DefaultNodeHeight = 22,
	-- default icon size
	DefaultIconSize = 16,
	-- distance from icon to bg tab button border
	DefaultIconPadding = 2,
	-- default indentation
	DefaultIndentation = 16,
	-- half space between the text of top level menu item
	DefaultMenuTextMargin = 5,
	-- color of the main menu item text
	TextColor = "24 57 124",
	-- nil or 4, 8. if not nil, text will be rendered with shadow
	TextShadowQuality = nil,
	-- text shadow color, such as "#2a2a2e27", if specified, it will automatically enable TextShadowQuality
	TextShadowColor = nil,
	-- in some case, one may need to offset the text on background image by -1, or some small value. 
	TextOffsetY = nil,
	-- color of the selected main menu item text
	SelectedTextColor = nil,
	-- default menu item font
	font = nil,
	-- the background image to be displayed when mouse over an top level menu item.
	-- please note that: MouseOverItemBG does not support 9 tile ":" texture name yet.
	-- MouseOverItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/menuitem_over.png: 2 2 2 2",
	UnSelectedMenuItemBG = "",
	SelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/menuitem_selected.png: 2 2 2 2",
	-- nil means text with optional icon, "ButtonOnly" means button only with tooltip.
	ItemStyle = nil, 
	-- top level menu item spacing. 
	ItemSpacing = 0,
	-- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- if DrawNode is nil, the default MainMenu.DrawMenuItemHandler function will be used. 
	DrawNodeHandler = nil,
	-- Force no clipping or always using fast render. Unless you know that the unit scroll step is interger times of all TreeNode height. You can disable clipping at your own risk. 
	-- Software clipping is always used to clip all invisible TreeNodes. However, this option allows you to specify whether to use clipping for partially visible TreeNode. 
	NoClipping = nil,
	-- a function of type function (MenuItem, param1) or nil. this function will be called for each menuitem onclick except the group node.
	onclick = nil,
	-------------------------------------------
	-- private functions
	-------------------------------------------
	IsModified = true,
	-- current selected top level menu item index
	SelectedIndex = nil,
}
CommonCtrl.MainMenu = MainMenu;

-- constructor
function MainMenu:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- use default draw function if user does not provide one. 
	if(not o.DrawNodeHandler) then
		o.DrawNodeHandler = self.DrawMenuItemHandler
	end
	
	-- create a TreeView control for it. 
	local ctl = CommonCtrl.TreeView:new{
		name = o.name.."TreeView",
		alignment = "_fi",
		left=0, top=0,
		width = 0,
		height = 0,
		-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
		DrawNodeHandler = o.DrawNodeHandler,
		container_bg = o.popmenu_container_bg,
		NoClipping = o.NoClipping,
		DefaultNodeHeight = o.DefaultNodeHeight,
		DefaultIndentation = o.DefaultIndentation,
		DefaultIconSize = o.DefaultIconSize,
	};
	ctl._mainmenu = o;
	o.RootNode = ctl.RootNode;
	o.popmenu = ctl;

	CommonCtrl.AddControl(o.name, o);
	
	return o
end

-- Destroy the UI control
function MainMenu:Destroy ()
	ParaUI.Destroy(self.name);
end

-- it will automatically update items if the mainmenu is shown for the first time.
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function MainMenu:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("MainMenu instance name can not be nil\r\n");
		return
	end
	
	local _this;
	if(self.uiobj_id) then
		_this = ParaUI.GetUIObject(self.uiobj_id);
	end
	if(not _this or not _this:IsValid()) then
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background=self.container_bg or "";
		self.uiobj_id = _this.id;
		_parent = _this;
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		-- update the MainMenu on creation
		self:UpdateTopLevelMenu();
		_this = _parent;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	
end

-- call this function when ever the top level menu item is changed. There is no need to call this function, if one only updated sub menu items. 
function MainMenu:Update()
	self:UpdateTopLevelMenu();
end

-- get the selected first level menu item index
function MainMenu:GetSelectedIndex()
	return self.SelectedIndex;
end

-- set the selected first level menu item index. 
-- @param index: index of the item
-- @param bNotRefreshUI true to refresh the UI. 
-- @param bSilentMode: if true, it will not invoke onclick callback.
function MainMenu:SetSelectedIndex(index, bNotRefreshUI, bSilentMode)
	local _parent = ParaUI.GetUIObject(self.uiobj_id);
	if(not _parent:IsValid()) then
		return;
	end
	local nSize = table.getn(self.RootNode.Nodes);
	local i, node;
	local x,y,width, height = 0,0,0,0;
	local bHasChild;
	local topLevelNode;
	for i=1, nSize do
		node = self.RootNode.Nodes[i];
		if(node ~=nil and not node.Hide) then
			if(i == index) then
				topLevelNode = node;
				node.Invisible = nil;
				node.NodeHeight = 0;
				local _item = _parent:GetChild("btn"..i);
				if(_item:IsValid()) then
					x,y, width, height = _item:GetAbsPosition();
					if(self.ItemStyle=="ButtonOnly") then
						_guihelper.SetTabStyleButton(_item, node.SelectedMenuItemBG or self.SelectedMenuItemBG, node.MouseOverItemBG or self.MouseOverItemBG)
					else
						_guihelper.SetTabStyleButton(_item, node.SelectedMenuItemBG or self.SelectedMenuItemBG, node.MouseOverItemBG or self.MouseOverItemBG)
						
						if(node.SelectedTextColor or self.SelectedTextColor) then
							local _text = _parent:GetChild("text"..i);
							if(_text:IsValid() == true) then
								_guihelper.SetButtonFontColor(_text, node.SelectedTextColor or self.SelectedTextColor)
							end
						end	
					end	
				end	
				self.SelectedIndex = i;
				
				if(table.getn(node.Nodes)~=0) then
					bHasChild = true;
				end 
			else	
				node.Invisible = true;
				local _item = _parent:GetChild("btn"..i);
				if(_item:IsValid()) then
					if(self.ItemStyle=="ButtonOnly") then
						_guihelper.SetTabStyleButton(_item, node.UnSelectedMenuItemBG or self.UnSelectedMenuItemBG, node.MouseOverItemBG or self.MouseOverItemBG)
					else
						_guihelper.SetTabStyleButton(_item, node.UnSelectedMenuItemBG or self.UnSelectedMenuItemBG, node.MouseOverItemBG or self.MouseOverItemBG)
						
						if(node.TextColor or  self.TextColor) then
							local _text = _parent:GetChild("text"..i);
							if(_text:IsValid() == true) then
								_guihelper.SetButtonFontColor(_text, node.TextColor or  self.TextColor)
							end
						end	
					end	
				end
			end
		end
	end

	-- call the event handler of the top level node if any. 
	if(not bSilentMode and (topLevelNode~=nil and topLevelNode.onclick~=nil)) then
		if(type(topLevelNode.onclick) == "string") then
			NPL.DoString(topLevelNode.onclick);
		else
			topLevelNode.onclick(topLevelNode);
		end
	end
	
	if(not bHasChild) then	
		--show nothing if menu item has no sub menus. 
		return;
	end
	--------------------------------------
	-- display the pop menu
	--------------------------------------

	local _this;
	if(self.popupmenu_id) then
		_this = ParaUI.GetUIObject(self.popupmenu_id);
	end
	if(not _this or not _this:IsValid()) then
		-- create the container if it has never been created before.
		_this=ParaUI.CreateUIObject("container",self.name.."popmenu","_lt", x, y, self.PopMenuWidth, 20);
		_this.background="";
		self.popupmenu_id = _this.id;
		_this:AttachToRoot();
		_parent = _this;
		
		_this:SetScript("onmouseup", function() MainMenu.OnMouseUpCont(self); end);
		_this:SetScript("onmousemove", function() MainMenu.OnMouseMoveCont(self); end);
		
		_this = _parent;
		
		self.popmenu.parent = _parent;
		self.popmenu:Show(true);
	end
	
	
	-- recalculate menu height each time the pop menu is shown
	local MenuHeight = self.MaxHeight;
	self.RootNode:Update(0,0);
	if(self.RootNode.LogicalBottom < self.MaxHeight) then
		if(self.RootNode.LogicalBottom > self.MinHeight) then
			MenuHeight = self.RootNode.LogicalBottom
		else
			MenuHeight = self.MinHeight
		end	
	end	
	if(self.AutoPositionMode == "_lt") then
		_this.x = x;
		_this.y = y + height;	
	elseif(self.AutoPositionMode == "_lb") then
		_this.x = x;
		_this.y = y - MenuHeight;	
	end
	if(_this.popmenu_height ~= MenuHeight) then
		self.popmenu_height = MenuHeight;
		_this.height = MenuHeight;
		_this:InvalidateRect(); -- this ensures that the next get absolution position call is valid. 
		self.IsModified = true;
	end
	
	-- update the inner treeview control if it has been modified. 
	self.popmenu:Update();
	self.IsModified = false;
	
	-- show up the menu 
	_this.visible = true;
	_this:SetTopLevel(true);
end

-- after the content of a tree node is changed, one may need to call this function at the root node
function MainMenu:UpdateTopLevelMenu()
	local _parent = ParaUI.GetUIObject(self.uiobj_id);
	if(not _parent:IsValid()) then
		return
	end
	
	-- update the parent container as well
	_parent.x = self.left;
	_parent.y = self.top;
	_parent.width = self.width;
	_parent.height = self.height;
	
	_parent:RemoveAll(); -- simply remove all.
	local _,_, MenuWidth,MenuHeight = _parent:GetAbsPosition();
	
	local root = self.RootNode;
	local left, top, width,height= 0,0,0, MenuHeight;
	
	local nSize = table.getn(root.Nodes);
	if(self.IsVertical) then
		height = self.DefaultNodeHeight
	end
	local i, node;
	for i=1, nSize do
		node = root.Nodes[i];
		if(node ~=nil and not node.Hide) then
			
			if(self.ItemStyle=="ButtonOnly") then
				-- only display button 
				node.width = node.width or (self.DefaultIconSize+self.DefaultIconPadding*2);
				node.height = node.height or MenuHeight or (self.DefaultIconSize+self.DefaultIconPadding*2);
				
				_this = ParaUI.CreateUIObject("button", "btn"..i, "_lt", left, top, node.width, node.height);
				_guihelper.SetTabStyleButton(_this, node.UnSelectedMenuItemBG or self.UnSelectedMenuItemBG, node.MouseOverItemBG or self.MouseOverItemBG)
				_this:SetScript("onclick", function()
					MainMenu.OnClickTopLevelMenuItem(self, i);
				end);
				_parent:AddChild(_this);
				
				local _text = ParaUI.CreateUIObject("button", "text"..i, "_lt", left+self.DefaultIconPadding, top+self.DefaultIconPadding, node.width-self.DefaultIconPadding*2, node.height-self.DefaultIconPadding*2)
				if (node.tooltip) then
						local tooltip_page = string.match(node.tooltip or "", "page://(.+)");
						if(tooltip_page) then
							local is_lock_position, use_mouse_offset;
							CommonCtrl.TooltipHelper.BindObjTooltip(_text.id, tooltip_page, 0, 0,
								nil,nil,nil, nil, nil, nil, is_lock_position, use_mouse_offset);
						else
							_text.tooltip = node.tooltip;
						end
				else				
					_text.tooltip = node.Text;
				end
				_text.background = node.Icon;
				_guihelper.SetUIColor(_text, node.TextColor or "255 255 255");

				_text:SetScript("onclick", function()
					MainMenu.OnClickTopLevelMenuItem(self, i);
				end);
				_parent:AddChild(_text);
				
			elseif(node.Icon ~= nil) then
				-- top level menu node provided an icon
				local assetIcon = ParaAsset.LoadTexture("", node.Icon, 1);
				local iconWidth = self.DefaultIconSize;
				local iconHeight = self.DefaultIconSize;
				if(assetIcon:IsLoaded()) then
					iconWidth = assetIcon:GetWidth();
					iconHeight = assetIcon:GetHeight();
				end
				
				if(not node.width) then
					node.width = _guihelper.GetTextWidth(node.Text, self.font);
					if(node.width == 0) then
						-- no text avaiable
						node.width = self.DefaultMenuTextMargin * 2 + iconWidth;
					else
						node.width = node.width + self.DefaultMenuTextMargin * 3 + iconWidth;
					end
				end
				if(node.max_width and node.width>node.max_width) then
					if((node.width - node.max_width)>20) then
						alignFormat = 4;	
					end
					node.width = node.max_width;
				end
				if(node.min_width and node.width<node.min_width) then
					node.width = node.min_width;
				end
				
				_this = ParaUI.CreateUIObject("button", "btn"..i, "_lt", left, top, node.width, height);
				_guihelper.SetTabStyleButton(_this, self.UnSelectedMenuItemBG, self.MouseOverItemBG)
				
				_this:SetScript("onclick", function()
					MainMenu.OnClickTopLevelMenuItem(self, i);
				end);	
				_parent:AddChild(_this);
				
				local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 
						left + self.DefaultMenuTextMargin, top + (height - iconHeight) / 2, iconWidth, iconHeight);
				_icon:SetBGImage(assetIcon);
				_icon.enabled = false;
				_parent:AddChild(_icon);
				
				if(node.Text ~= nil) then
					local offset_y = node.TextOffsetY or self.TextOffsetY or 0;
					
					local _text = ParaUI.CreateUIObject("button", "text"..i, "_lt", 
							left + self.DefaultMenuTextMargin + iconWidth, top+offset_y, node.width - self.DefaultMenuTextMargin - iconWidth, height);
					_text.text = node.Text;
					if(self.font ~= nil) then
						_text.font = self.font;
					end	
					if(self.TextColor~=nil) then
						_guihelper.SetButtonFontColor(_text, self.TextColor)
					end
					if(node.tooltip) then
						local tooltip_page = string.match(node.tooltip or "", "page://(.+)");
						if(tooltip_page) then
							local is_lock_position, use_mouse_offset;
							CommonCtrl.TooltipHelper.BindObjTooltip(_text.id, tooltip_page, 0, 0,
								nil,nil,nil, nil, nil, nil, is_lock_position, use_mouse_offset);
						else
							_text.tooltip = node.tooltip;
						end
					end
					_text.background = "";
					_text.enabled = false;

					local use_shadow;
					if(node.TextShadowQuality or self.TextShadowQuality) then
						_text:GetAttributeObject():SetField("TextShadowQuality", tonumber(node.TextShadowQuality or self.TextShadowQuality) or 0);
						use_shadow = true;
					end
					if(node.TextShadowColor or self.TextShadowColor) then
						_text:GetAttributeObject():SetField("TextShadowColor", _guihelper.ColorStr_TO_DWORD(node.TextShadowColor or self.TextShadowColor));
						use_shadow = true;
					end
					if(use_shadow) then
						_text.shadow = true;
					end
					if(alignFormat) then
						_guihelper.SetUIFontFormat(_text, alignFormat);
					end
					_parent:AddChild(_text);
				end
				
			else
				-- only display text
				if(not node.width) then
					node.width = _guihelper.GetTextWidth(node.Text, self.font);
					node.width = node.width + self.DefaultMenuTextMargin*2;
				end
				local alignFormat;
				if(node.max_width and node.width>node.max_width) then
					if((node.width - node.max_width)>20) then
						alignFormat = 4;	
					end
					node.width = node.max_width;
				end
				if(node.min_width and node.width<node.min_width) then
					node.width = node.min_width;
				end
				
				_this = ParaUI.CreateUIObject("button", "btn"..i, "_lt", left, top, node.width, node.height or height);
				_guihelper.SetTabStyleButton(_this, node.UnSelectedMenuItemBG or self.UnSelectedMenuItemBG, node.MouseOverItemBG or self.MouseOverItemBG)
				
				_this:SetScript("onclick", function()
					MainMenu.OnClickTopLevelMenuItem(self, i);
				end);
				_parent:AddChild(_this);
				
				local offset_y = node.TextOffsetY or self.TextOffsetY or 0;
				local _text = ParaUI.CreateUIObject("button", "text"..i, "_lt", left, top+offset_y, node.width, node.height or height)
				if(node.Text~=nil) then
					_text.text = node.Text;
					if(self.font ~= nil) then
						_text.font = self.font;
					end	
					if(self.TextColor~=nil) then
						_guihelper.SetButtonFontColor(_text, node.TextColor or self.TextColor)
					end	
					local use_shadow;
					if(node.TextShadowQuality or self.TextShadowQuality) then
						_text:GetAttributeObject():SetField("TextShadowQuality", tonumber(node.TextShadowQuality or self.TextShadowQuality) or 0);
						use_shadow = true;
					end
					if(node.TextShadowColor or self.TextShadowColor) then
						_text:GetAttributeObject():SetField("TextShadowColor", _guihelper.ColorStr_TO_DWORD(node.TextShadowColor or self.TextShadowColor));
						use_shadow = true;
					end
					if(use_shadow) then
						_text.shadow = true;
					end
					if(alignFormat) then
						_guihelper.SetUIFontFormat(_text, alignFormat);
					end
				end
				if(node.tooltip) then
					local tooltip_page = string.match(node.tooltip or "", "page://(.+)");
					if(tooltip_page) then
						local is_lock_position, use_mouse_offset;
						CommonCtrl.TooltipHelper.BindObjTooltip(_text.id, tooltip_page, 0, 0,
							nil,nil,nil, nil, nil, nil, is_lock_position, use_mouse_offset);
					else
						_text.tooltip = node.tooltip;
					end				
				end
				_text.background = "";
				--_text.enabled = false;
				_text:SetScript("onclick", function()
					MainMenu.OnClickTopLevelMenuItem(self, i);
				end);
				_parent:AddChild(_text);
			end
			if(self.IsVertical) then
				top = top + (node.height or height) + self.ItemSpacing;
			else
				left = left + node.width + self.ItemSpacing;
			end
		end
	end
	
	width = left;

	-- this will ensure that the main menu container is sized correctly according to top menu item size. 
	if(MenuWidth < width) then
		MenuWidth = width;
		_parent.width = MenuWidth;
	end
end

-- @param sCtrlName: the global unique control name or the control object itself. 
function MainMenu.GetControl(sCtrlNameOrObject)
	if(type(sCtrlNameOrObject) == "string") then
		return CommonCtrl.GetControl(sCtrlNameOrObject);
	elseif(type(sCtrlNameOrObject) == "table") then
		return sCtrlNameOrObject;
	end
end

-- handler to select a top level menu item. 
-- @param sCtrlName: the global unique control name or the control object itself. 
-- @param bSilentMode: if true, it will not invoke onclick callback.
function MainMenu.OnClickTopLevelMenuItem(sCtrlName, index, bSilentMode)
	local self = MainMenu.GetControl(sCtrlName);
	if(self==nil)then
		return;
	end
	self:SetSelectedIndex(index, nil, bSilentMode);
end

-- this is a click outside the pop menu container, we will therefore close the container. 
function MainMenu.OnMouseUpCont(sCtrlName)
	local self = MainMenu.GetControl(sCtrlName);
	if(self==nil)then
		return;
	end
	-- hide the popmenu
	self:Hide();
end

-- automatically switch to another menu item. 
function MainMenu.OnMouseMoveCont(sCtrlName)
	local self = MainMenu.GetControl(sCtrlName);
	if(self==nil)then
		return;
	end
	-- check if the mouse position falls in to the menu container client area.
	local _parent = ParaUI.GetUIObject(self.uiobj_id);
	if(not _parent:IsValid()) then
		return
	end
		
	local left,top = _parent:GetAbsPosition();
	left = mouse_x-left;
	top = mouse_y-top;
	if(mouse_x>=0 and mouse_y>=0 and mouse_x<=self.width and mouse_y<=self.height) then
		-- check which menu item get the mouse container. 
		local nSize = table.getn(self.RootNode.Nodes);
		local i, node;
		local testleft = 0;
		
		for i=1, nSize do
			node = self.RootNode.Nodes[i];
			if(node ~=nil and not node.Hide) then
				testleft = testleft + node.width + self.ItemSpacing;
				if(left<testleft) then
					if(self.SelectedIndex ~= i) then
						-- if the user has moused over a different menu item, just show the other one. 
						self:Hide();
						MainMenu.OnClickTopLevelMenuItem(self, i);
					end
					break;
				end
			end
		end
	
	end
end

function MainMenu:Hide()
	if(not self.popupmenu_id) then
		return
	end
	local _this=ParaUI.GetUIObject(self.popupmenu_id);
	if(_this:IsValid()) then
		_this.visible = false;
	end
	
	-- deselect menu item. 
	if(self.SelectedIndex~=nil) then
		local _parent = ParaUI.GetUIObject(self.uiobj_id);
		if(_parent:IsValid()) then
			local _item = _parent:GetChild("btn"..self.SelectedIndex);
			if(_item:IsValid()) then
				_item.background = self.UnSelectedMenuItemBG;
			end
		end
		self.SelectedIndex = nil;
	end
end

-- close the given control
function MainMenu.OnClose(sCtrlName)
	local self = MainMenu.GetControl(sCtrlName);
	if(self==nil)then
		return;
	end
	ParaUI.Destroy(self.popupmenu_id);
	ParaUI.Destroy(self.uiobj_id);
end

-- private function: called by default TreeNode UI
function MainMenu.OnToggleNode(sCtrlName, node)
	if(node ~= nil) then
		if(node.Expanded) then
			node:Collapse();
		else
			node:Expand();
		end
		node.TreeView:Update(nil, node);
	end
end

-- private function: called by default TreeNode UI
function MainMenu.OnClickNode(sCtrlName, node)
	local self = MainMenu.GetControl(sCtrlName);
	if(self==nil)then
		return;
	end
	if(node ~= nil) then
		-- call the event handler if any
		if(node.onclick~=nil)then
			if(type(node.onclick) == "string") then
				NPL.DoString(node.onclick);
			else
				node.onclick(node);
			end
		end
		self:Hide();
		if(self.onclick~=nil)then
			self.onclick(node, self.param1);
		end
	end
end

-- default node renderer: it display a clickable check box for expandable node, followed by node text
function MainMenu.DrawMenuItemHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 4; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	local IconSize = treeNode.TreeView.DefaultIconSize;
	if(treeNode.Icon~=nil and IconSize>0) then
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , IconSize, IconSize);
		_this.background = treeNode.Icon;
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);
	end	
	left = left + IconSize + treeNode.TreeView.DefaultIndentation*(treeNode.Level-2) + 2;
	
	-- Test code: just for testing. remove this line
	--_parent.background = "Texture/whitedot.png"; _guihelper.SetUIColor(_parent, "0 0 100 60");
	
	if(treeNode.Type=="Title") then
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		_this.background = "";
		
		if(treeNode.Text~=nil) then
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.text = treeNode.Text;
		end	
	elseif(treeNode.Type=="separator") then
		_this=ParaUI.CreateUIObject("button","b","_mt", left, 2, 1, 1);
		_this.background = "Texture/whitedot.png";
		_this.enabled = false;
		_guihelper.SetUIColor(_this, "150 150 150 255");
		_parent:AddChild(_this);	
	else
		if(treeNode:GetChildCount() > 0) then
			-- node that contains children. We shall display some
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top+6, 10, 10);
			_this:SetScript("onclick", function()
				MainMenu.OnToggleNode(treeNode.TreeView._mainmenu, treeNode);
			end);
			_parent:AddChild(_this);
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/common/itemopen.png";
			else
				_this.background = "Texture/3DMapSystem/common/itemclosed.png";
			end
			_guihelper.SetUIColor(_this, "255 255 255");
			left = left + 16;
			
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this:SetScript("onclick", function()
				MainMenu.OnToggleNode(treeNode.TreeView._mainmenu, treeNode);
			end);
			if(treeNode.Text~=nil) then
				_this.text = treeNode.Text;
			end	
			
		elseif(treeNode.Text ~= nil) then
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this:SetScript("onclick", function()
				MainMenu.OnClickNode(treeNode.TreeView._mainmenu, treeNode);
			end);
			_this.text = treeNode.Text;
		end
	end	
end
