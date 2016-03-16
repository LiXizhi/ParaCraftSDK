--[[
Title: Context menu, using a tree view internally for sub level menus. It has a modern appearance. 
Author(s): LiXizhi
Date: 2007/9/24
Rewritten by WangTian 
Date: 2008/12/8

NOTE: context menu with treeview implementation is completely depracated
the contextmenu is rewritten in traditional menu form,
Changed from onclick-inner-expand context menu into onmouseover-external-expand menu

Macintosh style menu is used, with shadow background and mouse over menuitem background & textcolor change

The current implementation still uses the old treenode form of data keeping and organization
And only support two level menu

menu item Node may have following properties
{
	Icon = string, icon file
	Type = "Separator", "Menuitem", "Title", "Group". Default to "menuitem"
		-- "Title": Show bold text
		-- "Separator": show separator across the menu width
		-- "Group": group the menuitems to show or hide 
		-- "Menuitem": show icon+text or text only, and if with child show extend icon
	Enabled = whether menu item is enabled. 
}
------------------------------------------------------------
NPL.load("(gl)script/ide/ContextMenu.lua");
local ctl = CommonCtrl.GetControl("ContextMenu1");
if(ctl==nil)then
	ctl = CommonCtrl.ContextMenu:new{
		name = "ContextMenu1",
		width = 300,
		height = 100,
		onclick = function (node, param1) _guihelper.MessageBox(node.Text) end
		--container_bg = "Texture/tooltip_text.PNG",
	};
	
	local parentnode = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Type = "Group", NodeHeight = 0, Text = "group", Name = "mygroup", });
		parentnode:AddChild(CommonCtrl.TreeNode:new{Type = "Menuitem",  Text = "menuitem1", Icon = "Texture/3DMapSystem/common/monitor.png", Name = "1", onclick = function ()  end});
		parentnode:AddChild(CommonCtrl.TreeNode:new{Type = "Menuitem", Text = "menuitem2", Icon = "Texture/3DMapSystem/common/monitor.png", Name = "2", onclick = function ()  end});
		parentnode:AddChild(CommonCtrl.TreeNode:new{Type = "Menuitem", Text = "menuitem3", Icon = "Texture/3DMapSystem/common/monitor.png", Name = "3", onclick = function ()  end});
end	

ctl:Show(nil, nil, nil);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/TreeView.lua");
NPL.load("(gl)script/ide/WindowFrame.lua");

-- define a new control in the common control libary

-- default member attributes
local ContextMenu = {
	-- the top level control name
	name = "ContextMenu1",
	-- normal window size
	width = 400,
	height = 290, 
	-- this is the maximum height, a scroll bar will be used if there are too many menu items. 
	MaxHeight = 500, 
	-- this is the minimum height of the content menu, unless there are so few items to display
	MinHeight = 40, 
	-- auto positioning method: it can be 
	-- "_lt": left top, where the mouse x, y will be the left top point of the menu container. This is the default mode.
	-- "_lb": left bottom, where the mouse x, y will be the left bottom point of the menu container. 
	AutoPositionMode = "_lt", 
	-- the background of container
	container_bg = nil, 
	-- The root tree node. containing all tree node data
	RootNode = nil, 
	-- Default height of Tree Node
	DefaultNodeHeight = 22,
	-- default icon size
	DefaultIconSize = 16,
	-- default indentation
	DefaultIndentation = 16,
	-- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- if DrawNode is nil, the default ContextMenu.DrawMenuItemHandler function will be used. 
	DrawNodeHandler = nil,
	-- Force no clipping or always using fast render. Unless you know that the unit scroll step is interger times of all TreeNode height. You can disable clipping at your own risk. 
	-- Software clipping is always used to clip all invisible TreeNodes. However, this option allows you to specify whether to use clipping for partially visible TreeNode. 
	NoClipping = nil,
	-- a function of type function (MenuItem, param1) or nil. this function will be called for each menuitem onclick except the group node.
	onclick = nil,
	
	-- NOTE by Andy 2008/12/7: add a style to allow customized menu apperance
	-- define menu apperance style
	style = nil,
	
	-------------------------------------------
	-- private functions
	-------------------------------------------
	IsModified = true,
	
}
CommonCtrl.ContextMenu = ContextMenu;

ContextMenu.DefaultStyle = {
	borderTop = 4,
	borderBottom = 4,
	borderLeft = 0,
	borderRight = 0,
	
	fillLeft = -20,
	fillTop = -15,
	fillWidth = -19,
	fillHeight = -24,
	
	-- following are also supported
	--titlecolor = "#03f8ff",
	--level1itemcolor = "#03f8ff",
	--level2itemcolor = "#03f8ff",
	-- mouseover_textcolor = "255 255 255", 

	menu_bg = "Texture/Aquarius/Common/ContextMenu_BG_32bits.png: 31 27 31 36",
	shadow_bg = nil,
	separator_bg = "Texture/Aquarius/Common/ContextMenu_Separator.png: 1 1 1 4",
	item_bg = "Texture/Aquarius/Common/ContextMenu_ItemBG_32bits.png: 1 1 1 1",
	expand_bg = "Texture/Aquarius/Common/ContextMenu_Expand.png",
	expand_bg_mouseover = "Texture/Aquarius/Common/ContextMenu_Expand_MouseOver.png",
	
	menuitemHeight = 22,
	separatorHeight = 8,
	titleHeight = 22,
	textFont = nil,
	titleFont = "System;14;bold",
};

-- constructor
function ContextMenu:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- use default draw function if user does not provide one. 
	if(not o.DrawNodeHandler) then
		o.DrawNodeHandler = self.DrawMenuItemHandler
	end
	
	---- create a TreeView control for it. 
	--local ctl = CommonCtrl.TreeView:new{
		--name = o.name.."TreeView",
		--alignment = "_fi",
		--left=0, top=0,
		--width = 0,
		--height = 0,
		---- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
		--DrawNodeHandler = o.DrawNodeHandler,
		--container_bg = o.container_bg,
		--NoClipping = o.NoClipping,
		--DefaultNodeHeight = o.DefaultNodeHeight,
		--DefaultIndentation = o.DefaultIndentation,
		--DefaultIconSize = o.DefaultIconSize,
	--};
	
	o.RootNode = CommonCtrl.TreeNode:new({Name = "RootNode", 
		NodeHeight = 0, -- so that root node is not drawn
	})
	--o.RootNode = ctl.RootNode;
	
	o.style = o.style or ContextMenu.DefaultStyle;
	
	-- default menu width if not provide one
	o.width = o.width or 200;

	CommonCtrl.AddControl(o.name, o);
	
	return o
end

-- Destroy the UI control
function ContextMenu:Destroy ()
	ParaUI.Destroy(self.name);
end

-- show the container with animation
function ContextMenu.ShowContainerWithAnimation(obj)
	obj.color = "255 255 255 255";
	--local block = UIDirectAnimBlock:new();
	--block:SetUIObject(obj);
	--block:SetTime(200);
	--block:SetAlphaRange(0, 1);
	--block:SetApplyAnim(true);
	--UIAnimManager.PlayDirectUIAnimation(block);
end

-- hide the container with animation
function ContextMenu.HideContainerWithAnimation(obj)
	obj.visible = false;
	--obj.visible = true;
	--local block = UIDirectAnimBlock:new();
	--block:SetUIObject(obj);
	--block:SetTime(100);
	--block:SetAlphaRange(1, 0);
	--block:SetApplyAnim(true);
	--block:SetCallback(function ()
		--obj.visible = false;
	--end)
	--UIAnimManager.PlayDirectUIAnimation(block);
end


--@param x: where to display. if nil, mouse_x is used
--@param y: where to display. if nil, mouse_y is used
--@param param1: a optional parameter object to be passed to onclick event
function ContextMenu:Show(x, y, param1)
	if(self.name == nil)then
		log("ContextMenu instance name can not be nil\r\n");
		return
	end
	
	self.param1 = param1;
	x = x or mouse_x or 10;
	y = y or mouse_y or 10;
	
	-- context menu layers
	-- TopLevel container self.name
	--			button OutClickSense
	--			container Menu
	--				container BG
	--				container MenuItem
	--					button .etc
	--			container SubMenu
	--				container BG
	--				container MenuItem
	--					button .etc
	local _menu_cont;
	local _menu;
	_menu_cont = ParaUI.GetUIObject(self.name);
	
	local preContextMenuVisible;
	if(_menu_cont:IsValid() == false) then
		preContextMenuVisible = false;
		
		-- create the menu container if it has never been created before.
		_menu_cont = ParaUI.CreateUIObject("container", self.name, "_fi", 0, 0, 0, 0);
		_menu_cont.background = "";
		-- NOTE by Andy 2008/12/19: set the zorder above all containers, this will prevent other containers over
		--		the context menu, for example when debugging the chat mainwnd
		_menu_cont.zorder = 50;
		-- NOTE by Andy 2008/12/19: Zane reported a bug: context menu is still on top when menuitem is successfully performed
		--		_menu_cont.enabled is then turned true and false when show and hide BEFORE the animation process
		--		and _menu_cont is SetTopLevelled, I can't remember why i use zorder instead of toplevel container
		--		maybe some conflict with containers that already toplevelled
		_menu_cont:SetTopLevel(true);
		_menu_cont:AttachToRoot();
		
		local _btn = ParaUI.CreateUIObject("button", "OutClickSense", "_fi", 0, 0, 0, 0);
		_btn.background = "";
		_btn.onclick = string.format([[;CommonCtrl.ContextMenu.OnMouseEventOutside("%s");]], self.name);
		_btn.onmousedown = string.format([[;CommonCtrl.ContextMenu.OnMouseEventOutside("%s");]], self.name);
		_btn.onmouseup = string.format([[;CommonCtrl.ContextMenu.OnMouseEventOutside("%s");]], self.name);
		_menu_cont:AddChild(_btn);
		
		_menu = ParaUI.CreateUIObject("container", "Menu","_lt", x, y, self.width, 0);
		_menu.background = "";
		_menu_cont:AddChild(_menu);
		
		--_menu.onmouseup = string.format([[;CommonCtrl.ContextMenu.OnMouseEventOutside("%s");]], self.name);
		
		--ctl.parent = _parent;
		--ctl:Show(true);
		
		self.IsModified = false;
	else
		preContextMenuVisible = false;
		if(self.IsModified == true) then
			self.IsModified = true;
			ParaUI.Destroy(self.name);
			self:Show(x, y, param1);
		else
			_menu_cont.visible = true;
			_menu = _menu_cont:GetChild("Menu");
			_menu.x = x;
			_menu.y = y;
			CommonCtrl.WindowFrame.MoveContainerInScreenArea(_menu);
			_menu_cont.enabled = true;
			ContextMenu.ShowContainerWithAnimation(_menu_cont);
		end
		return;
	end
	
	-- make a button inventory slot style
	-- @param uiobject: button UI object
	-- @param backgroundImage: background image always shows on slot
	-- @param highlightImage: highlight image shows only on mouse over indicating available slot for item 
	--			or item outer glow highlight
	local function SetMenuItemStyleButton(uiobject, backgroundImage, highlightImage)
		if(uiobject~=nil and uiobject:IsValid())then
			local texture;
			
			if(backgroundImage ~= nil) then
				uiobject:SetActiveLayer("background");
				uiobject.background = backgroundImage; 
				
				uiobject:SetCurrentState("highlight");
				uiobject.color="255 255 255";
				uiobject:SetCurrentState("pressed");
				uiobject.color="255 255 255";
				uiobject:SetCurrentState("disabled");
				uiobject.color="255 255 255 100";
				uiobject:SetCurrentState("normal");
				uiobject.color="255 255 255";
				
				uiobject:SetActiveLayer("artwork");
			end
			
			if(highlightImage ~= nil) then
				uiobject:SetActiveLayer("artwork");
				uiobject.background = highlightImage; 
				
				uiobject:SetCurrentState("highlight");
				uiobject.color="255 255 255 200";
				uiobject:SetCurrentState("pressed");
				uiobject.color="255 255 255 255";
				uiobject:SetCurrentState("normal");
				uiobject.color="0 0 0 0";
				uiobject:SetCurrentState("disabled");
				uiobject.color="0 0 0 0";
			end
		end
	end
	
	-- currently we assume that the menu is shown without the scroll
	-- so the height and width is always within screen area
	local style = self.style;
	local menuHeight = style.borderTop;
	
	-- combine the shadow with the menu background, we don't provide top menu(submenu) item to show on top
	local _BG = ParaUI.CreateUIObject("container", "BG", "_fi", style.fillLeft, style.fillTop, style.fillWidth, style.fillHeight);
	_BG.background = style.menu_bg;
	_BG.enabled = false;
	_menu:AddChild(_BG);
	
		
	local RootNode = self.RootNode;
	local i;
	for i = 1, RootNode:GetChildCount() do
		-- 1st level child node
		local node = RootNode:GetChild(i);
	
		if((node.Type == "title" or node.Type == "Title") and node.NodeHeight ~= 0) then
			local _item = ParaUI.CreateUIObject("container", "Title", "_lt", 
						style.borderLeft, menuHeight, self.width - style.borderLeft - style.borderRight, style.titleHeight);
			_item.background = "";
			_menu:AddChild(_item);
			menuHeight = menuHeight + style.titleHeight;
				local _text = ParaUI.CreateUIObject("text", "Text", "_lt", 12, 2, self.width, 16);
				_text.text = node.text or node.Text;
				_text.font = style.titleFont;
				if(style.titlecolor) then
					_guihelper.SetFontColor(_text, style.titlecolor);
				end
				_item:AddChild(_text);
		elseif((node.Type == "separator" or node.Type == "Separator") and node.NodeHeight ~= 0) then
			local _item = ParaUI.CreateUIObject("container", "separator", "_lt", 
						style.borderLeft, menuHeight, self.width - style.borderLeft - style.borderRight, style.separatorHeight);
			_item.background = style.separator_bg;
			_menu:AddChild(_item);
			menuHeight = menuHeight + style.separatorHeight;
		elseif( (node.Type == "group" or node.Type == "Group") and not node.Invisible) then
			-- show the menuitem in the group only when the group is not invisible
			local j;
			local nCount = node:GetChildCount();
			for j = 1, nCount do
				local nodeLvl1 = node:GetChild(j);
				if(not nodeLvl1.Invisible and nodeLvl1.NodeHeight ~= 0) then
					-- 1st level node is grouped with separators and menuitems
					if(nodeLvl1.Type == "separator" or nodeLvl1.Type == "Separator") then
						-- separator
						local _item = ParaUI.CreateUIObject("container", "separator", "_lt", 
									style.borderLeft, menuHeight, self.width - style.borderLeft - style.borderRight, style.separatorHeight);
						_item.background = style.separator_bg;
						_menu:AddChild(_item);
						-- accumulate meunHeight
						menuHeight = menuHeight + style.separatorHeight;
					elseif(nodeLvl1.Type == "menuitem" or nodeLvl1.Type == "Menuitem") then
						-- menu item with icon+text or only text
						local _item = ParaUI.CreateUIObject("container", "Menuitem_"..j, "_lt", 
									style.borderLeft, menuHeight, self.width - style.borderLeft - style.borderRight, style.menuitemHeight);
						_item.background = "";
						_menu:AddChild(_item);
					
						local _itemBG = ParaUI.CreateUIObject("button", "BG", "_fi", 0, 0, 0, 0);
						SetMenuItemStyleButton(_itemBG, "", style.item_bg);
						--_itemBG.background = style.item_bg;
						_item:AddChild(_itemBG);
					
						if(nodeLvl1.icon or nodeLvl1.Icon) then
							local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 4, (style.menuitemHeight - (style.iconsize_y or 16)) / 2, style.iconsize_x or 16, style.iconsize_y or 16);
							_icon.background = nodeLvl1.icon or nodeLvl1.Icon;
							_item:AddChild(_icon);
							local _text = ParaUI.CreateUIObject("text", "Text", "_lt", 24, (style.menuitemHeight - 16) / 2, self.width, 16);
							_text.text = nodeLvl1.text or nodeLvl1.Text;
							if(style.level1itemcolor) then
								_guihelper.SetFontColor(_text, style.level1itemcolor);
							end
							if(style.textFont) then
								_text.font = style.textFont;
							end
							_item:AddChild(_text);
						else
							local _text = ParaUI.CreateUIObject("text", "Text", "_lt", 10, (style.menuitemHeight - 16) / 2, self.width, 16);
							_text.text = nodeLvl1.text or nodeLvl1.Text;
							if(style.level1itemcolor) then
								_guihelper.SetFontColor(_text, style.level1itemcolor);
							end
							if(style.textFont) then
								_text.font = style.textFont;
							end
							_item:AddChild(_text);
						end
					
						-- accumulate meunHeight
						menuHeight = menuHeight + style.menuitemHeight;
					
						local childCount = nodeLvl1:GetChildCount();
						if(childCount > 0) then
							-- create expand icon indicating the menu item has submenu
							local _expand = ParaUI.CreateUIObject("container", "Expand", "_rt", -(style.menuitemHeight - 10)-4, 3, (style.menuitemHeight - 10), (style.menuitemHeight - 10));
							_expand.background = style.expand_bg;
							_expand.enabled = false;
							_item:AddChild(_expand);
						
							local x_expand, y_expand, width_expand, height_expand = _expand:GetAbsPosition();
						
							-- create the sub menu
							local _submenu = ParaUI.CreateUIObject("container", "SubMenu_"..j,"_lt", x_expand + width_expand + 4, y_expand + 20 - style.borderTop, (self.subMenuWidth or self.width) or node.childwidth, 0);
							_submenu.background = "";
							_submenu.visible = false;
							_menu_cont:AddChild(_submenu);
						
							-- combine the shadow with the menu background, we don't provide top menu(submenu) item to show on top
							local _BG = ParaUI.CreateUIObject("container", "BG", "_fi", style.fillLeft, style.fillTop, style.fillWidth, style.fillHeight);
							_BG.background = style.menu_lvl2_bg or style.menu_bg;
							_BG.enabled = false;
							_submenu:AddChild(_BG);
						
							-- submenu height accumulator
							local subMenuHeight = style.borderTop;
						
							-- traverse through the submenu to show each separator or menuitems
							-- NOTE: currently we only allow 2 level menu to export the existing implementation, time is tight
							local k;
							for k = 1, childCount do
								local nodeLvl2 = nodeLvl1:GetChild(k);
								if(not nodeLvl2.Invisible and nodeLvl2.NodeHeight ~= 0) then
									if(nodeLvl2.Type == "separator" or nodeLvl2.Type == "Separator") then
										local _item = ParaUI.CreateUIObject("container", "separator", "_lt", 
													style.borderLeft, subMenuHeight, (self.subMenuWidth or self.width) - style.borderLeft - style.borderRight, style.separatorHeight);
										_item.background = style.separator_bg;
										_submenu:AddChild(_item);
								
										-- accumulate subMenuHeight
										subMenuHeight = subMenuHeight + style.separatorHeight;
									elseif(nodeLvl2.Type == "menuitem" or nodeLvl2.Type == "Menuitem") then
										local _item = ParaUI.CreateUIObject("container", "Menuitem_"..j.."_"..k, "_lt", 
													style.borderLeft, subMenuHeight, (self.subMenuWidth or self.width) - style.borderLeft - style.borderRight, style.menuitemHeight);
										_item.background = "";
										_submenu:AddChild(_item);
								
										local _itemBG = ParaUI.CreateUIObject("button", "BG", "_fi", 0, 0, 0, 0);
										SetMenuItemStyleButton(_itemBG, "", style.item_bg);
										--_itemBG.background = "";
										_item:AddChild(_itemBG);
								
										if(nodeLvl2.icon or nodeLvl2.Icon) then
											local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 4, 3, 16, 16);
											_icon.background = nodeLvl2.icon or nodeLvl2.Icon;
											_item:AddChild(_icon);
											local _text = ParaUI.CreateUIObject("text", "Text", "_lt", 24, (style.menuitemHeight - 16) / 2, (self.subMenuWidth or self.width), 16);
											_text.text = nodeLvl2.text or nodeLvl2.Text;
											if(style.level2itemcolor) then
												_guihelper.SetFontColor(_text, style.level2itemcolor);
											end
											if(style.textFont) then
												_text.font = style.textFont;
											end
											_item:AddChild(_text);
										else
											local _text = ParaUI.CreateUIObject("text", "Text", "_lt", 10, (style.menuitemHeight - 16) / 2, (self.subMenuWidth or self.width), 16);
											_text.text = nodeLvl2.text or nodeLvl2.Text;
											if(style.level2itemcolor) then
												_guihelper.SetFontColor(_text, style.level2itemcolor);
											end
											if(style.textFont) then
												_text.font = style.textFont;
											end
											_item:AddChild(_text);
										end
								
										-- accumulate subMenuHeight
										subMenuHeight = subMenuHeight + style.menuitemHeight;
								
										local _itemBtn = ParaUI.CreateUIObject("button", "Btn", "_fi", 0, 0, 0, 0);
										_itemBtn.background = "";
										_itemBtn.onclick = "";
										_itemBtn.onclick = string.format([[;CommonCtrl.ContextMenu.OnClickItem(%q, %q);]], self.name, nodeLvl2:GetNodePath());
										_itemBtn.onmouseenter = string.format([[;CommonCtrl.ContextMenu.OnMouseEnterNormalItem(%q, %d, %d);]], self.name, j, k);
										_itemBtn.onmouseleave = string.format([[;CommonCtrl.ContextMenu.OnMouseLeaveNormalItem(%q, %d, %d);]], self.name, j, k);
										_item:AddChild(_itemBtn);
									end
								
								end
							end
						
							subMenuHeight = subMenuHeight + style.borderBottom;
						
							-- update the submenu height
							_submenu.height = subMenuHeight;
						
							_submenu.onmouseenter = string.format([[;CommonCtrl.ContextMenu.OnMouseEnterItem(%q, %d);]], self.name, j);
							--_submenu.onmouseleave = string.format([[;CommonCtrl.ContextMenu.OnMouseLeaveItem(%q, %d);]], self.name, j);
						
							-- mouse enter and leave event for node with child nodes
							local _itemBtn = ParaUI.CreateUIObject("button", "Btn", "_fi", 0, 0, 0, 0);
							_itemBtn.background = "";
							_itemBtn.onmouseenter = string.format([[;CommonCtrl.ContextMenu.OnMouseEnterItem(%q, %d);]], self.name, j);
							--_itemBtn.onmouseleave = string.format([[;CommonCtrl.ContextMenu.OnMouseLeaveItem(%q, %d);]], self.name, j);
							_item:AddChild(_itemBtn);
						
							-- record all OnMouseLeaveItem
							self.AllMouseLeaveItem = self.AllMouseLeaveItem or {};
							table.insert(self.AllMouseLeaveItem, j);
						else
							-- mouse click event for normal menu nodes
							local _itemBtn = ParaUI.CreateUIObject("button", "Btn", "_fi", 0, 0, 0, 0);
							_itemBtn.background = "";
							_itemBtn.onclick = string.format([[;CommonCtrl.ContextMenu.OnClickItem(%q, %q);]], self.name, nodeLvl1:GetNodePath());
							_itemBtn.onmouseenter = string.format([[;CommonCtrl.ContextMenu.OnMouseEnterNormalItem(%q, %d);]], self.name, j);
							_itemBtn.onmouseleave = string.format([[;CommonCtrl.ContextMenu.OnMouseLeaveNormalItem(%q, %d);]], self.name, j);
							_item:AddChild(_itemBtn);
						end
					end
				end
			end
		end
	end
	
	menuHeight = menuHeight + style.borderBottom;
	
	-- update the menu height
	_menu.height = menuHeight;
	

	if(self.AutoPositionMode == "_lb") then
		_menu.y = _menu.y - menuHeight;	
	end
		
	_menu_cont.enabled = true;
	-- TODO: animation is not support with AutoPositionMode =="_lb"
	ContextMenu.ShowContainerWithAnimation(_menu_cont);
	
	-- ismodify
	-- move within screen area
	
	CommonCtrl.WindowFrame.MoveContainerInScreenArea(_menu);
end

-- hide the context menu
-- @return true if object is original shown, and is hidden now. if the control is already hidden prior to this call, the function return nil. 
function ContextMenu:Hide()
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		
		-- NOTE 2010/3/11: quick implementation to fix the submenu bug that the submenu is not hide after the menu is off
		ContextMenu.OnClose(self.name);
		
		do return end
		
		if(_this.visible == true) then
			_this.enabled = false;
			ContextMenu.HideContainerWithAnimation(_this);
			return true;
		end
		-- NOTE: already hide the container in ContextMenu.HideContainerWithAnimation(_this);
		--_this.visible = false;
		
		
		---- onmouseleave event callback is already called when submenuitem click, so don't need to rehide the submenu container
		--local RootNode = self.RootNode;
		--local i;
		--for i = 1, RootNode:GetChildCount() do
			---- 1st level child node
			--local node = RootNode:GetChild(i);
			--if( (node.Type == "group" or node.Type == "Group") and (not node.Invisible) ) then
				---- show the menuitem in the group only when the group is not invisible
				--local j;
				--local nCount = node:GetChildCount();
				--for j = 1, nCount do
					--local nodeLvl1 = node:GetChild(j);
					--if(nodeLvl1.Type == "menuitem" or nodeLvl1.Type == "Menuitem") then
						--local childCount = nodeLvl1:GetChildCount();
						--if(childCount > 0) then
							--local _submenu = _this:GetChild("SubMenu_"..j);
							--_submenu.visible = false;
						--end
					--end
				--end
			--end
		--end
	end
end

-- close the given control
function ContextMenu.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting ContextMenu instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- this is a click outside the menu container, we will therefore hide the container. 
function ContextMenu.OnMouseEventOutside(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error: getting ContextMenu instance "..sCtrlName.."\r\n");
		return;
	end
	if(self:Hide()) then
		-- TODO: check to see if we clicked parent window buttons. 
	end
end

-- onclick event handler
function ContextMenu.OnClickItem(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting context menu instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		-- call the event handler if any
		if(node.onclick~=nil)then
			if(type(node.onclick) == "string") then
				NPL.DoString(node.onclick);
			else
				node.onclick(node);
			end
		end
		if(self.onclick~=nil)then
			self.onclick(node);
		end
	end
	self:Hide();
end

function ContextMenu:GetNodeByPath(path)
	local index; 
	local node = self.RootNode;
	for index in string.gfind(path, "(%d+)") do
		--log("ByPath:"..index.."\n")
		index = tonumber(index);
		if(index>0) then
			node = node.Nodes[index];
		end
		if(node == nil) then
			return
		end
	end
	return node;
end

-- onmouseenter event handler
function ContextMenu.OnMouseEnterItem(sCtrlName, index)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting context menu instance "..sCtrlName.."\r\n");
		return;
	end
	-- ContextMenu.OnMouseLeaveItem is called for every meun items
	local _, i;
	for _, i in pairs(self.AllMouseLeaveItem or {}) do
		ContextMenu.OnMouseLeaveItem(sCtrlName, i);
	end
	
	local _menu_cont = ParaUI.GetUIObject(self.name);
	local _submenu = _menu_cont:GetChild("SubMenu_"..index);
	
	local _menu = _menu_cont:GetChild("Menu");
	local _item = _menu:GetChild("Menuitem_"..index);
	local _text = _item:GetChild("Text");
	_guihelper.SetFontColor(_text, self.style.mouseover_textcolor or "255 255 255");
	_item.background = self.style.item_bg;
	
	local _expand = _item:GetChild("Expand");
	_expand.background = self.style.expand_bg_mouseover;
	
	local x_expand, y_expand, width_expand, height_expand = _expand:GetAbsPosition();
	
	_submenu.x = x_expand + width_expand + 4;
	_submenu.y = y_expand - 3 - self.style.borderTop;
	
	-- put the submenu in screen area
	local _, _, resWidth, resHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	local x_submenu, y_submenu, width_submenu, height_submenu = _submenu:GetAbsPosition();
	local x_item, y_item, width_item, height_item = _item:GetAbsPosition();
	
	if(x_submenu + width_submenu + 10) >= resWidth then
		_submenu.x = x_item - width_submenu + 2;
	end
	
	CommonCtrl.WindowFrame.MoveContainerInScreenArea(_submenu);
	
	if(_submenu.visible == false) then
		ContextMenu.ShowContainerWithAnimation(_submenu);
	end
	_submenu.visible = true;
end

-- onmouseleave event handler
function ContextMenu.OnMouseLeaveItem(sCtrlName, index)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting context menu instance "..sCtrlName.."\r\n");
		return;
	end
	
	local _menu_cont = ParaUI.GetUIObject(self.name);
	local _submenu = _menu_cont:GetChild("SubMenu_"..index);
	
	local _menu = _menu_cont:GetChild("Menu");
	local _item = _menu:GetChild("Menuitem_"..index);
	local _itemBtn = _item:GetChild("Btn");
	
	local isOverSubmenu = false;
	local isOverItem = false;
	
	local mouseX, mouseY = ParaUI.GetMousePosition();
	local x, y, width, height = _submenu:GetAbsPosition();
	if((mouseX >= x) and (mouseX < (x + width)) and (mouseY >= y) and (mouseY < (y + height))) then
		isOverSubmenu = true;
	end
	local x, y, width, height = _itemBtn:GetAbsPosition();
	if((mouseX >= x) and (mouseX < (x + width)) and (mouseY >= y) and (mouseY < (y + height))) then
		isOverItem = true;
	end
	
	if(isOverItem == false and isOverSubmenu == false) then
		if(_submenu.visible == true) then
			ContextMenu.HideContainerWithAnimation(_submenu);
		end
		-- NOTE already invisible in ContextMenu.HideContainerWithAnimation(_submenu);
		--_submenu.visible = false;
		
		local _menu = _menu_cont:GetChild("Menu");
		local _item = _menu:GetChild("Menuitem_"..index);
		local _text = _item:GetChild("Text");
		_guihelper.SetFontColor(_text, self.style.level1itemcolor or "0 0 0");
		_item.background = "";
		
		local _expand = _item:GetChild("Expand");
		_expand.background = self.style.expand_bg;
	end
end

function ContextMenu.OnMouseEnterNormalItem(sCtrlName, index1, index2)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting context menu instance "..sCtrlName.."\r\n");
		return;
	end
	---- ContextMenu.OnMouseLeaveItem is called for every meun items
	--local _, i;
	--for _, i in pairs(self.AllMouseLeaveItem or {}) do
		--if(index1 ~= i) then
			--ContextMenu.OnMouseLeaveItem(sCtrlName, i);
		--end
	--end
	
	if(index2 == nil) then
		local _menu_cont = ParaUI.GetUIObject(self.name);
		local _menu = _menu_cont:GetChild("Menu");
		local _item = _menu:GetChild("Menuitem_"..index1);
		local _text = _item:GetChild("Text");
		_guihelper.SetFontColor(_text, self.style.mouseover_textcolor or "255 255 255");
		_item.background = self.style.item_bg;
	else
		local _menu_cont = ParaUI.GetUIObject(self.name);
		local _submenu = _menu_cont:GetChild("SubMenu_"..index1);
		local _item = _submenu:GetChild("Menuitem_"..index1.."_"..index2);
		local _text = _item:GetChild("Text");
		_guihelper.SetFontColor(_text, self.style.mouseover_textcolor or "255 255 255");
		_item.background = self.style.item_bg;
	end
end

function ContextMenu.OnMouseLeaveNormalItem(sCtrlName, index1, index2)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting context menu instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(index2 == nil) then
		local _menu_cont = ParaUI.GetUIObject(self.name);
		local _menu = _menu_cont:GetChild("Menu");
		local _item = _menu:GetChild("Menuitem_"..index1);
		local _text = _item:GetChild("Text");
		_guihelper.SetFontColor(_text, self.style.level1itemcolor or "0 0 0");
		_item.background = "";
	else
		local _menu_cont = ParaUI.GetUIObject(self.name);
		local _submenu = _menu_cont:GetChild("SubMenu_"..index1);
		local _item = _submenu:GetChild("Menuitem_"..index1.."_"..index2);
		local _text = _item:GetChild("Text");
		_guihelper.SetFontColor(_text, self.style.level2itemcolor or "0 0 0");
		_item.background = "";
	end
end

-- set modified, always call this function after you have changed the menu items. 
-- this will cause the content menu to redraw next time it shows up. 
function ContextMenu:SetModified(bModified)
	self.IsModified = bModified;
end


-- private function: called by default TreeNode UI
function ContextMenu.OnToggleNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		--log("OnToggleNode:"..node:GetNodePath().."\n");
		if(node.Expanded) then
			node:Collapse();
		else
			node:Expand();
		end
		node.TreeView:Update(nil, node);
	end
end

-- private function: called by default TreeNode UI
function ContextMenu.OnClickNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		-- call the event handler if any
		if(node.onclick~=nil)then
			if(type(node.onclick) == "string") then
				NPL.DoString(node.onclick);
			else
				node.onclick(node);
			end
		end
		self = CommonCtrl.GetControl(string.gsub(sCtrlName, "TreeView$", ""));
		if(self==nil)then
			log("error getting contextMenu instance from "..sCtrlName.."\r\n");
			return;
		end
		self:Hide();
		if(self.onclick~=nil)then
			self.onclick(node, self.param1);
		end
	end
end

-- default node renderer: it display a clickable check box for expandable node, followed by node text
function ContextMenu.DrawMenuItemHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 5; -- margin-left of this menu item. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	local IconSize = treeNode.TreeView.DefaultIconSize;
	if(treeNode.Icon~=nil and IconSize>0) then
		_this=ParaUI.CreateUIObject("button","b","_lt", left, math.floor((height-IconSize)/2) , IconSize, IconSize);
		_this.background = treeNode.Icon;
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);
	end	
	if(not treeNode.bSkipIconSpace) then
		left = left + IconSize;
	end
	left = left + treeNode:GetIndentation() + 2;
	
	-- Test code: just for testing. remove this line
	--_parent.background = "Texture/whitedot.png"; _guihelper.SetUIColor(_parent, "0 0 100 60");
	
	if(treeNode.Type=="Title") then
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.text = treeNode.Text;
	else
		if(treeNode:GetChildCount() > 0) then
			-- node that contains children. We shall display some
			_this=ParaUI.CreateUIObject("button","b","_lt", left+(16-10)/2, height/2-5, 10, 10);
			_this.onclick = string.format(";CommonCtrl.ContextMenu.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
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
			_this.onclick = string.format(";CommonCtrl.ContextMenu.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.ContextMenu.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
		end
	end	
end
