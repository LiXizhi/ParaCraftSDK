--[[
Title: Macintosh Style Dock, using ownerdraw container with top level bar items
Author(s): WangTian
Date: 2008/3/27
Desc: Dock is a quick launch toolbar that sits at the bottom or side of the screen.
Dock is organized in groups. Group contains items for quick launch.
Dock control handles the default animation when insert or remove group and item.

Basicly main bar uses this control as the main container. And different groups has a manager to 
organize the items within.

------------------------------------------------------------
NPL.load("(gl)script/ide/Dock.lua");
local _dock = CommonCtrl.GetControl("Dock1");
if(_dock == nil)then
	_dock = CommonCtrl.Dock:new{
		name = "Dock1",
		parent = _parent,
		height = 64,
	};
end


_dock:InsertGroup("apps", 1);
_dock:InsertGroup("stacks", 2);
_dock:InsertGroup("feed", 3);
_dock:InsertItemToGroup("creator", 1, 1);
_dock:InsertItemToGroup("chat", 2, 1);
_dock:InsertItemToGroup("map", 3, 1);
_dock:InsertItemToGroup("more...", 4, 1, 24);
--_dock:InsertItemToGroup("chat1", 1, 2);
--_dock:InsertItemToGroup("chat2", 2, 2);
--_dock:InsertItemToGroup("chat3", 3, 2);
_dock:InsertItemToGroup("message", 1, 3);
_dock:InsertItemToGroup("notification", 2, 3);
_dock:InsertItemToGroup("invitation", 3, 3);

_dock:Show();
_dock:Update();

_dock:InsertItemToGroup("chat1", 1, 2);
_dock:Update();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local Dock = {
	-- the top level control name
	name = "Dock1",
	-- normal window size
	--left = 0,
	--top = 0,
	--width = 400,
	--height = 22, 
	-- popup menu default height
	popmenu_height = 22,
	parent = nil,
	-- this is the maximum height, a scroll bar will be used if there are too many menu items. 
	MaxHeight = 500, 
	-- this is the minimum height of the content menu, unless there are so few items to display
	MinHeight = 40, 
	-- default is nil or 0, make this 1 to stay on top
	zorder = nil,
	PopMenuWidth = 200,
	-- auto positioning method: it can be 
	-- "_lt": left top, where the mouse x, y will be the left top point of the menu container. This is the default mode.
	-- "_lb": left bottom, where the mouse x, y will be the left bottom point of the menu container. 
	AutoPositionMode = "_lt", 
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
	-- default indentation
	DefaultIndentation = 16,
	-- half space between the text of top level menu item
	DefaultMenuTextMargin = 5,
	-- color the main menu text
	TextColor = "24 57 124",
	-- the background image to be displayed when mouse over an top level menu item.
	MouseOverItemBG = "Texture/3DMapSystem/Startup/TabBtnUnpressed.png: 2 2 2 2",
	UnSelectedMenuItemBG = "",
	SelectedMenuItemBG = "Texture/3DMapSystem/Startup/TabBtnUnpressed.png: 2 2 2 2",
	-- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- if DrawNode is nil, the default Dock.DrawMenuItemHandler function will be used. 
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
}
CommonCtrl.Dock = Dock;

-- constructor
function Dock:new(o)
	
	commonlib.echo("Dock:new(o)");
	
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- init the dock groups
	o.groups = o.groups or {};
	
	-- dock height, dock width is dynamicly changed according to groups and group items
	o.height = o.height or 64;
	-- default item area size in width and height
	o.defaultItemAreaWidth = o.defaultItemAreaWidth or 48;
	o.defaultItemAreaHeight = o.defaultItemAreaHeight or 48; -- NOTE: item can't change the area height
	-- default base space height, items stands of base space
	o.baseSpaceHeight = o.baseSpaceHeight or 12;
	-- separator width, separator height is the same as itemAreaHeight
	o.separatorWidth = o.separatorWidth or 16;
	-- side width is the additional left and right width of bar space besides the groups and separators
	o.sideWidth = o.sideWidth or 48;
	-- default UI direct animation time
	o.defaultAnimationTime = o.defaultAnimationTime or 300;
	-- use animation to update the dock groups and items, default using animation
	if(o.bUseAnimation == nil) then
		o.bUseAnimation = true;
	end
	
	---- use default draw function if user does not provide one. 
	--if(not o.DrawNodeHandler) then
		--o.DrawNodeHandler = self.DrawMenuItemHandler
	--end
	
	---- create a TreeView control for it. 
	--local ctl = CommonCtrl.TreeView:new{
		--name = o.name.."TreeView",
		--alignment = "_fi",
		--left=0, top=0,
		--width = 0,
		--height = 0,
		---- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
		--DrawNodeHandler = o.DrawNodeHandler,
		--container_bg = o.popmenu_container_bg,
		--NoClipping = o.NoClipping,
		--DefaultNodeHeight = o.DefaultNodeHeight,
		--DefaultIndentation = o.DefaultIndentation,
		--DefaultIconSize = o.DefaultIconSize,
	--};
	--o.RootNode = ctl.RootNode;
	--o.popmenu = ctl;

	CommonCtrl.AddControl(o.name, o);
	
	return o
end

-- Destroy the UI control
function Dock:Destroy()
	ParaUI.Destroy(self:GetDockContainerName());
end

-- get the dock UI object container
function Dock:GetDockContainerName()
	return "Dock_"..self.name;
end

-- show the dock for the first time
-- NOTE: update the dock after each insert/remove function call
--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Dock:Show(bShow)
	if(self.name == nil) then
		log("Dock instance name can not be nil\r\n");
		return
	end
	
	local _dock = ParaUI.GetUIObject(self:GetDockContainerName());
	
	if(_dock:IsValid() == false) then
		if(bShow == false) then return; end
		
		-- update the dock ui objects without animation
		self:Update(false);
	else
		if(bShow == nil) then
			bShow = not _dock.visible;
		end
		_dock.visible = bShow;
	end
end

-- manually call this function to update the dock ui objects with or without animation
function Dock:Update()
	local _dock = ParaUI.GetUIObject(self:GetDockContainerName());
	if(_dock:IsValid() == false) then
		-- themeable main bar
		_dock = ParaUI.CreateUIObject("container", self:GetDockContainerName(), "_ctb", 0, 0, 0, self.height);
		if(self.zorder) then
			_dock.zorder = self.zorder;
		end
		_dock.background = self.background;
		if(self.parent == nil) then
			_dock:AttachToRoot();
		else
			self.parent:AddChild(_dock);
		end
	end
	
	-- calculate the total width
	local barWidth = 0;
	local separatorWidth = self.separatorWidth;
	
	-- left side width
	barWidth = barWidth + self.sideWidth;
	
	local k, v;
	for k, v in ipairs(self.groups) do
		local groupWidth = 0;
		local offsetY = self.height - self.defaultItemAreaHeight - self.baseSpaceHeight;
		
		local _group = _dock:GetChild(v.name);
		if(_group:IsValid() == false) then
			-- create the group ui if not exist
			_group = ParaUI.CreateUIObject("container", v.name, "_lt", 
					barWidth, offsetY, groupWidth, self.defaultItemAreaHeight);
			_group.background = "";
			_dock:AddChild(_group);
		end
		
		local block; -- direct animation block
		
		local kk, vv;
		for kk, vv in ipairs(v) do
			local _item = _group:GetChild(vv.name);
			if(_item:IsValid() == false) then
				_item = ParaUI.CreateUIObject("container", vv.name, "_lt", 
						groupWidth, 0, vv.itemAreaWidth, self.defaultItemAreaHeight);
				_item.background = "";
				_group:AddChild(_item);
				
				local command = vv.command;
				if(command.ownerDrawHandler == nil) then
					local _icon = ParaUI.CreateUIObject("button", "defaultIcon", "_lt", 0, 0, vv.itemAreaWidth, self.defaultItemAreaHeight);
					_icon.background = command.icon;
					_icon.onclick = command.onclick;
					_icon.onmouseenter = command.onmouseenter;
					_icon.onmouseleave = command.onmouseleave;
					_icon.tooltip = command.tooltip;
					if(type(command.enabled) == "boolean") then
						_icon.enabled = command.enabled;
					end
					_item:AddChild(_icon);
				elseif(type(command.ownerDrawHandler) == "function") then
					-- TODO: owner draw the item
					command.ownerDrawHandler(_item);
				end
				
				if(self.bUseAnimation == true) then
					local y = _item.y;
					block = UIDirectAnimBlock:new();
					block:SetUIObject(_item);
					block:SetTime(self.defaultAnimationTime/4);
					block:SetYRange(y, y-12);
					UIAnimManager.PlayDirectUIAnimation(block);
					block = UIDirectAnimBlock:new();
					block:SetUIObject(_item);
					block:SetTime(self.defaultAnimationTime/4);
					block:SetYRange(y-12, y-16);
					UIAnimManager.PlayDirectUIAnimation(block);
					block = UIDirectAnimBlock:new();
					block:SetUIObject(_item);
					block:SetTime(self.defaultAnimationTime/4);
					block:SetYRange(y-16, y-12);
					UIAnimManager.PlayDirectUIAnimation(block);
					block = UIDirectAnimBlock:new();
					block:SetUIObject(_item);
					block:SetTime(self.defaultAnimationTime/4);
					block:SetYRange(y-12, y);
					UIAnimManager.PlayDirectUIAnimation(block);
				end
			end
			
			-- reset the item x and width
			if(self.bUseAnimation == true) then
				if(_item.x ~= groupWidth or _item.width ~= vv.itemAreaWidth) then
					block = UIDirectAnimBlock:new();
					block:SetUIObject(_item);
					block:SetTime(self.defaultAnimationTime);
					block:SetXRange(_item.x, groupWidth);
					block:SetWidthRange(_item.width, vv.itemAreaWidth);
					UIAnimManager.PlayDirectUIAnimation(block);
				end
			else
				_item.x = groupWidth;
				_item.width = vv.itemAreaWidth;
			end
			
			groupWidth = groupWidth + vv.itemAreaWidth;
			
			--if(_item.lifetime < 0) then
				--groupWidth = groupWidth + vv.itemAreaWidth;
			--else
				---- NOTE: If lifetime is over 0, it is a ready to delete ui object
				----		Update process is just finishing its animation
				--log("lifetime not -1\n");
				--block = UIDirectAnimBlock:new();
				--block:SetUIObject(_item);
				--block:SetTime(self.defaultAnimationTime/2);
				--block:SetYRange(_item.y, _item.y - 8);
				--UIAnimManager.PlayDirectUIAnimation(block);
			--end
		end
		
		---- find ready to delete object, lifetime over 0
		--local nCount = _group:GetChildCount();
		---- pay attention the GetChildAt function indexed in C++ form which begins at index 0
		--local i;
		--for i = 0, nCount - 1 do
			--local _item = _group:GetChildAt(i);
			--if(_item.lifetime > 0 ) then
				--log("lifetime not -1\n");
				--block = UIDirectAnimBlock:new();
				--block:SetUIObject(_item);
				--block:SetTime(self.defaultAnimationTime);
				--block:SetYRange(_item.y, _item.y - 16);
				--UIAnimManager.PlayDirectUIAnimation(block);
			--end
		--end
		
		
		-- reset the group x and width
		if(self.bUseAnimation == true) then
			if(_group.x ~= barWidth or _group.width ~= groupWidth) then
				block = UIDirectAnimBlock:new();
				block:SetUIObject(_group);
				block:SetTime(self.defaultAnimationTime);
				block:SetXRange(_group.x, barWidth);
				block:SetWidthRange(_group.width, groupWidth);
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		else
			_group.x = barWidth;
			_group.width = groupWidth;
			
			--_group.visible = false;
			--if(groupWidth > 0) then
				--_group.visible = true;
			--end
		end
		
		barWidth = barWidth + groupWidth;
		
		local _separator = _dock:GetChild("separator_"..v.name);
		if(_separator:IsValid() == false) then
			-- create the separator ui object if not exist
			_separator = ParaUI.CreateUIObject("container", "separator_"..v.name, "_lt", 
					barWidth, offsetY, separatorWidth, self.defaultItemAreaHeight);
			_separator.background = self.separatorBackground;
			_separator.visible = false;
			_dock:AddChild(_separator);
		end
		
		-- reset the separator x
		if(self.bUseAnimation == true) then
			if(_separator.x ~= barWidth) then
				block = UIDirectAnimBlock:new();
				block:SetUIObject(_separator);
				block:SetTime(self.defaultAnimationTime);
				block:SetXRange(_separator.x, barWidth);
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		else
			_separator.x = barWidth;
		end
		
		if(self.groups[k] ~= nil and self.groups[k + 1] ~= nil) then
			if(self.groups[k][1] ~= nil) then
				-- next group exist and unempty group
				_separator.visible = true;
				barWidth = barWidth + separatorWidth;
			end
		end
	end
	
	-- right side width
	barWidth = barWidth + self.sideWidth;
	
	-- reset the dock width
	if(self.bUseAnimation == true) then
		if(_dock.width ~= barWidth) then
			block = UIDirectAnimBlock:new();
			block:SetUIObject(_dock);
			block:SetTime(self.defaultAnimationTime);
			block:SetWidthRange(_dock.width, barWidth);
			UIAnimManager.PlayDirectUIAnimation(block);
		end
	else
		_dock.width = barWidth;
	end
end

-- get dock item ui container
-- @param: group: group index or group name
-- @param: item: item index or item name
-- @return: ui container object or nil of not found or invalid group or item
function Dock:GetItemUIContainer(group, item)
	local groupIndex;
	local itemIndex;
	
	if(type(group) == "string") then
		groupIndex = self:GetGroupIndexByName(group);
	elseif(type(group) == "number") then
		groupIndex = group;
	end
	
	if(type(item) == "string") then
		itemIndex = self:GetItemIndexFromGroupByName(item, groupIndex);
	elseif(type(item) == "number") then
		itemIndex = item;
	end
	
	local _dock = ParaUI.GetUIObject(self:GetDockContainerName());
	if(_dock:IsValid() == true) then
		if(self.groups[groupIndex] ~= nil) then
			local _group = _dock:GetChild(self.groups[groupIndex].name);
			if(_group:IsValid() == true) then
				if(self.groups[groupIndex][itemIndex] ~= nil) then
					return _group:GetChild(self.groups[groupIndex][itemIndex].name);
				end
			end
		end
	end
end

-- insert a group to the dock
-- @param name: name of the dock group
-- @param index: position of the group, starts from 1
--		if index is -1, insert from left
--		if index is nil, insert from right
function Dock:InsertGroup(name, index)
	local groups = self.groups;
	if(index == -1) then
		-- insert from left
		index = 1;
	elseif(index == nil) then
		-- insert from right
		local nCount = table.getn(groups);
		index = nCount + 1;
	else
		local nCount = table.getn(groups);
		if(index > nCount) then
			index = nCount + 1;
		elseif(index < 1) then
			index = 1;
		end
	end
	
	if(groups[index] ~= nil) then
		local temp = groups[index];
		groups[index] = {name = name,};
		
		self:InsertGroup(temp, index + 1);
		
		---- create the group ui object if the dock object in shown
		--local _dock = ParaUI.GetUIObject(self:GetDockContainerName());
		--if(_dock:IsValid() == true) then
			--if(groups[groupIndex - 1] ~= nil) then
				---- continue with the previous group
			--else
				---- start of dock groups
				--
			--end
			--
			--if(_dock:IsValid() == true and _group:IsValid() == true) then
				--originalX = _dock:GetChild(groups[groupIndex][index].name).x;
			--end
			--
			--local i;
			--for i = index, table.getn(groups[groupIndex]) do
				--groups[groupIndex + 1] = commonlib.deepcopy(groups[groupIndex]);
				--
				--if(self.bUseAnimation == true) then
					---- animate the items behind the index, using shifting direct animation
					--local _item = _group:GetChild(groups[groupIndex][index].name);
					--local block = UIDirectAnimBlock:new();
					--block:SetUIObject(_item);
					--block:SetTime(self.defaultAnimationTime);
					--block:SetXRange(_item.x, _item.x + itemAreaWidth);
					--UIAnimManager.PlayDirectUIAnimation(block);
				--end
			--end
		--end
	else
		groups[index] = {name = name,};
	end
end

-- get group name according to the group index
-- @param index: position of the group, starts from 1
-- @return: name of the group
function Dock:GetGroupNameByIndex(index)
	local groups = self.groups;
	if(groups[index] ~= nil) then
		return groups[index].name;
	end
end

-- get group index according to the group name
-- if two or more groups happen to have the same name, the first occurance index is returned
-- @param name: name of the group
-- @return: index of the group
function Dock:GetGroupIndexByName(name)
	local k, v;
	for k, v in ipairs(self.groups) do
		if(v.name == name) then
			return k;
		end
	end
end

-- remove a group from the dock
-- @param index: position of the group, starts from 1
-- NOTE: if the group is not empty, it will internally remove the items in the group
function Dock:RemoveGroupByIndex(index)
	local groups = self.groups;
	if(groups[index] ~= nil) then
		if(groups[index + 1] ~= nil) then
			groups[index] = groups[index + 1];
			self:RemoveGroupByIndex(index + 1);
		else
			-- remove the internal items
			local i;
			for i = 1, table.getn(groups[index]) do
				self:RemoveItemFromGroupByIndex(i, index);
			end
			
			-- remove the ui object if inited
			local groupName = groups[index].name;
			
			local _dock = ParaUI.GetUIObject(self:GetDockContainerName());
			if(_dock:IsValid() == true) then
				-- TODO: not tested
				commonlib.echo("lifetime used");
				local _group = _dock:GetChild(groupName);
				_group.lifetime = math.ceil((self.defaultAnimationTime + 100)/1000);
				
				local _separator = _dock:GetChild("separator_"..groupName);
				_separator.lifetime = math.ceil((self.defaultAnimationTime + 100)/1000);
			end
			
			groups[index] = nil;
		end
	end
end

-- remove a group from the dock
-- @param name: name of the dock group
-- NOTE: if the group is not empty, it will internally remove the items in the group
function Dock:RemoveGroupByName(name)
	local index = self:GetGroupIndexByName(name);
	self:RemoveGroupByIndex(index);
end

-- insert an item to group
-- @param itemName: item name
-- @param groupIndex: group index
-- @param index: position of the item in the group, starts from 1
--		if index is -1 or 1, insert from left
--		if index is nil, insert from right
-- NOTE: DON'T record or rely on the index to uniquely define an item. The index is ONLY the display index of the 
--		items inside a group. It changes dynamicly as the group grows larger or shrinks smaller.
-- @param command: type of Map3DSystem.App.Command
-- @param itemAreaWidth: item area width, if not specified default item area width is used
-- @param forceUpdate: force the dock to update, specially useful in the UI setup process
-- @param forceDisableAnimation: force the dock to temporarily disable the animation
function Dock:InsertItemToGroup(itemName, index, groupIndex, command, itemAreaWidth, forceUpdate, forceDisableAnimation)
	-- using default item area width
	if(itemAreaWidth == nil) then
		itemAreaWidth = self.defaultItemAreaWidth;
	end
	
	local groups = self.groups;
	if(groups[groupIndex] ~= nil) then
		if(index == -1) then
			-- insert from left
			index = 1;
		elseif(index == nil) then
			-- insert from right
			local nCount = table.getn(groups[groupIndex]);
			index = nCount + 1;
		else
			local nCount = table.getn(groups[groupIndex]);
			if(index > nCount) then
				index = nCount + 1;
			elseif(index < 1) then
				index = 1;
			end
		end
		
		-- shift right the items behind the index item
		if(groups[groupIndex][index] ~= nil) then
			local i;
			for i = index, table.getn(groups[groupIndex]) do
				groups[groupIndex][i + 1] = commonlib.deepcopy(groups[groupIndex][i]);
			end
		end
			
		groups[groupIndex][index] = {
			name = itemName,
			itemAreaWidth = itemAreaWidth,
			command = command,
			};
	else
		log("error: invalid groupIndex. Dock:InsertItemToGroup(itemName, index, groupIndex)\n");
	end
	
	-- force the dock to update, default(nil) lazy update and use animation
	if(forceUpdate == true) then
		-- force the dock to temporarily disable the animation
		if(self.bUseAnimation == true and forceDisableAnimation == true) then
			self.bUseAnimation = false;
			self:Update();
			self.bUseAnimation = true;
		else
			self:Update();
		end
	end
end


-- get item name from group by index
-- @param index: position of the item, starts from 1
-- @return: name of the item
function Dock:GetItemNameFromGroupByIndex(index, groupIndex)
	local groups = self.groups;
	if(groups[groupIndex] ~= nil) then
		if(groups[groupIndex][index] ~= nil) then
			return groups[groupIndex][index].name;
		end
	end
end

-- get item index from group by name
-- if two or more items happen to have the same name, the first occurance index is returned
-- @param name: name of the item
-- @return: index of the item
function Dock:GetItemIndexFromGroupByName(name, groupIndex)
	if(self.groups[groupIndex] ~= nil) then
		local k, v;
		for k, v in ipairs(self.groups[groupIndex]) do
			if(v.name == name) then
				return k;
			end
		end
	end
end

-- remove an item from a group
-- @param itemIndex: item index
-- @param groupIndex: group index
function Dock:RemoveItemFromGroupByIndex(itemIndex, groupIndex)
	local groups = self.groups;
	if(groups[groupIndex] ~= nil) then
		if(groups[groupIndex][itemIndex] ~= nil) then
			
			-- remove the ui object if inited
			local _dock = ParaUI.GetUIObject(self:GetDockContainerName());
			if(_dock:IsValid() == true) then
				local _group = _dock:GetChild(groups[groupIndex].name);
				local _item = _group:GetChild(groups[groupIndex][itemIndex].name);
				-- NOTE: set the UI object lifetime long enough to complete the inside UI animation
				commonlib.echo("lifetime used");
				_item.lifetime = math.ceil((self.defaultAnimationTime + 100)/1000);
				
				local fileName = "script/UIAnimation/CommonIcon.lua.table";
				UIAnimManager.PlayUIAnimationSequence(_item, fileName, "Hide", false);
			end
			
			local i;
			for i = itemIndex, table.getn(groups[groupIndex]) do
				groups[groupIndex][i] = commonlib.deepcopy(groups[groupIndex][i + 1]);
			end
		end
	end
end

-- remove an item from a group
-- @param itemName: item name
-- @param groupIndex: group index
function Dock:RemoveItemFromGroupByName(itemName, groupIndex)
	local index = self:GetItemIndexFromGroupByName(itemName, groupIndex);
	self:RemoveItemFromGroupByIndex(index, groupIndex);
end




---- insert an item to group
---- @param itemName: item name
---- @param groupIndex: group index
---- @param index: position of the item in the group, starts from 1
----		if index is -1, insert from left
----		if index is nil, insert from right
---- NOTE: DON'T record or rely on the index to uniquely define an item. The index is ONLY the display index of the 
----		items inside a group. It changes dynamicly as the group grows larger or shrinks smaller.
---- @param useAnimation: whether to use animation for the item inserting process, if not specified default using animation
---- @param itemAreaWidth: item area width, if not specified default item area width is used
--function Dock:InsertItemToGroup(itemName, index, groupIndex, useAnimation, itemAreaWidth)
	---- default using animation
	--if(useAnimation == nil) then
		--useAnimation = true;
		--useAnimation = false; -- TODO: DEBUG PURPOSE only
	--end
	---- using default item area width
	--if(itemAreaWidth == nil) then
		--itemAreaWidth = self.defaultItemAreaWidth;
	--end
	--
	------ dock ui object container
	----local _dock = ParaUI.GetUIObject(self:GetDockContainerName());
	----if(_dock:IsValid() == false) then
		----if(useAnimation == true) then
			----useAnimation = false;
		----end
		----log("warning: dock UI object is yet inited.\n");
	----end
	--
	--local groups = self.groups;
	--if(groups[groupIndex] ~= nil) then
		--if(index == -1) then
			---- insert from left
			--index = 1;
		--elseif(index == nil) then
			---- insert from right
			--local nCount = table.getn(groups[groupIndex]);
			--index = nCount + 1;
		--else
			--local nCount = table.getn(groups[groupIndex]);
			--if(index > nCount) then
				--index = nCount + 1;
			--elseif(index < 1) then
				--index = 1;
			--end
		--end
		--
		---- animate/set the dock width
		--if(useAnimation == true) then
			---- animate the dock width
			--if(index == 1) then
				---- start of a new group, including the separator
				--local block = UIDirectAnimBlock:new();
				--block:SetUIObject(_dock);
				--block:SetTime(self.defaultAnimationTime);
				--block:SetWidthRange(_dock.width, _dock.width + itemAreaWidth + self.separatorWidth);
				--UIAnimManager.PlayDirectUIAnimation(block);
			--else
				--local block = UIDirectAnimBlock:new();
				--block:SetUIObject(_dock);
				--block:SetTime(self.defaultAnimationTime);
				--block:SetWidthRange(_dock.width, _dock.width + itemAreaWidth);
				--UIAnimManager.PlayDirectUIAnimation(block);
			--end
		--else
			---- set the dock width
			--if(_dock:IsValid() == true) then
				--if(index == 1) then
					---- start of a new group, including the separator
					--_dock.width = _dock.width + itemAreaWidth + self.separatorWidth;
				--else
					--_dock.width = _dock.width + itemAreaWidth;
				--end
			--end
		--end
		--
		---- group ui object container
		--local _group;
		--if(_dock:IsValid() == true) then
			--_group = _dock:GetChild(groups[groupIndex].name);
		--end
		--
		---- animate/set the group width
		--if(useAnimation == true) then
			---- animate the group width
			--if(index == 1) then
				---- this group has just inserted an item, create container for the group
				--local offsetY = self.height - self.defaultItemAreaHeight - self.baseSpaceHeight;
				--local groupX;
				--if(groups[groupIndex - 1] ~= nil) then
					--local _preGroup = _dock:GetChild(groups[groupIndex - 1].name);
					--groupX = _preGroup.x + _preGroup.width + self.separatorWidth;
				--else
					--groupX = self.sideWidth;
				--end
				--_group = ParaUI.CreateUIObject("container", groups[groupIndex].name, "_lt", 
						--groupX, offsetY, 0, self.defaultItemAreaHeight);
				----_group.background = ""; --  TODO: group background
				--_dock:AddChild(_group);
				--
				--local _separator = ParaUI.CreateUIObject("container", "separator_"..k, "_lt", 
						--barWidth, offsetY, separatorWidth, self.defaultItemAreaHeight);
				----_separator.background = ""; --  TODO: separator background
				--_dock:AddChild(_separator);
				--barWidth = barWidth + separatorWidth;
				--
				---- start of a new group, including the separator
				--local block = UIDirectAnimBlock:new();
				--block:SetUIObject(_group);
				--block:SetTime(self.defaultAnimationTime);
				--block:SetWidthRange(_group.width, _group.width + itemAreaWidth + self.separatorWidth);
				--UIAnimManager.PlayDirectUIAnimation(block);
			--else
				--local block = UIDirectAnimBlock:new();
				--block:SetUIObject(_group);
				--block:SetTime(self.defaultAnimationTime);
				--block:SetWidthRange(_group.width, _group.width + itemAreaWidth);
				--UIAnimManager.PlayDirectUIAnimation(block);
			--end
		--else
			---- set the group width
			--if(_dock:IsValid() == true) then
				--if(index == 1) then
					---- start of a new group, including the separator
					--local offsetY = self.height - self.defaultItemAreaHeight - self.baseSpaceHeight;
					--local groupX;
					--if(groups[groupIndex - 1] ~= nil) then
						--local _preGroup = _dock:GetChild(groups[groupIndex - 1].name);
						--groupX = _preGroup.x + _preGroup.width + self.separatorWidth;
					--else
						--groupX = self.sideWidth;
					--end
					--_group = ParaUI.CreateUIObject("container", groups[groupIndex].name, "_lt", 
							--groupX, offsetY, 0, self.defaultItemAreaHeight);
					----_group.background = ""; --  TODO: group background
					--_dock:AddChild(_group);
					--
					--local _separator = ParaUI.CreateUIObject("container", "separator_"..groups[groupIndex].name, "_lt", 
							--groupX + itemAreaWidth, offsetY, self.separatorWidth, self.defaultItemAreaHeight);
					----_separator.background = ""; --  TODO: separator background
					--_dock:AddChild(_separator);
					--barWidth = barWidth + separatorWidth;
					--
					--local i;
					--for i = groupIndex + 1, table.getn(groups) do
						--local _group = _dock:GetChild(groups[i].name);
						---- TODO: separator
						--_group.x = _group.x + itemAreaWidth + self.separatorWidth;
					--end
				--else
					--_dock.width = _dock.width + itemAreaWidth;
				--end
			--end
		--end
		--
		--local originalX; -- record the x position of the original indexed item
		--
		--if(groups[groupIndex][index] ~= nil) then
			--
			--if(_dock:IsValid() == true and _group:IsValid() == true) then
				--originalX = _group:GetChild(groups[groupIndex][index].name).x;
			--end
			--
			--local i;
			--for i = index, table.getn(groups[groupIndex]) do
				--groups[groupIndex + 1] = commonlib.deepcopy(groups[groupIndex]);
				--
				--if(useAnimation == true) then
					---- animate the items behind the index, using shifting direct animation
					--local _item = _group:GetChild(groups[groupIndex][index].name);
					--local block = UIDirectAnimBlock:new();
					--block:SetUIObject(_item);
					--block:SetTime(self.defaultAnimationTime);
					--block:SetXRange(_item.x, _item.x + itemAreaWidth);
					--UIAnimManager.PlayDirectUIAnimation(block);
				--end
			--end
		--end
			--
		--groups[groupIndex][index] = {
			--name = itemName,
			--itemAreaWidth = itemAreaWidth,
			--};
		--
		--local _item;
		--if(originalX == nil) then originalX = 0; end
		--if(_dock:IsValid() == true and _group:IsValid() == true) then
			--_item = ParaUI.CreateUIObject("container", itemName, "_lt", 
					--originalX, 0, itemAreaWidth, self.defaultItemAreaHeight);
			--_group:AddChild(_item);
		--end
		--
		--if(useAnimation == true) then
			---- animate the inserted item, using "Pop out" animation
			--local fileName = "script/UIAnimation/CommonIcon.lua.table";
			--UIAnimManager.PlayUIAnimationSequence(_item, fileName, "Bounce");
		--end
			--
			------ TODO: turn this function into non-recursive
			------local tempName = groups[groupIndex][index].name;
			------local tempItemAreaWidth = groups[groupIndex][index].itemAreaWidth;
			------groups[groupIndex][index] = {
				------name = itemName,
				------itemAreaWidth = itemAreaWidth,
				------};
			------self:InsertItemToGroup(tempName, index + 1, groupIndex, useAnimation, tempItemAreaWidth, true);
		----else
			----groups[groupIndex][index] = {
				----name = itemName,
				----itemAreaWidth = itemAreaWidth,
				----};
		----end
	--else
		--log("error: invalid groupIndex. Dock:InsertItemToGroup(itemName, index, groupIndex)\n");
	--end
--end