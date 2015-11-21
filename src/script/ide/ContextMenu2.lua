
-- NOTE by Andy: this is the original implementation of context menu with treeview implementation
-- the contextmenu is rewritten in traditional menu form,
-- Changed from onclick-inner-expand context menu into onmouseover-external-expand menu

--[[
Title: Context menu, using a tree view internally for sub level menus. It has a modern appearance. 
Author(s): LiXizhi
Date: 2007/9/24
menu item Node may have following properties
{
	Icon = string, icon file
	Type = "separater", "menuitem", "title". Default to "menuitem"
	Enabled = whether menu item is enabled. 
}
------------------------------------------------------------
NPL.load("(gl)script/ide/ContextMenu2.lua");
local ctl = CommonCtrl.GetControl("ContextMenu1");
if(ctl==nil)then
	ctl = CommonCtrl.ContextMenu2:new{
		name = "ContextMenu1",
		width = 300,
		height = 100,
		onclick = function (node, param1) _guihelper.MessageBox(node.Text) end
		--container_bg = "Texture/tooltip_text.PNG",
	};
	local node = ctl.RootNode;
	node:AddChild("Node1");
	node:AddChild(CommonCtrl.TreeNode:new({Text = "Node2", Name = "sample", Icon="texture.png", onclick=function}));
	node = node:AddChild("Node3");
	node = node:AddChild("Node3_1");
	node = node:AddChild("Node3_1_1");
	ctl.RootNode:AddChild("Node4");
	ctl.RootNode:AddChild("Node5");
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
local ContextMenu2 = {
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
	-- if DrawNode is nil, the default ContextMenu2.DrawMenuItemHandler function will be used. 
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
CommonCtrl.ContextMenu2 = ContextMenu2;

-- constructor
function ContextMenu2:new (o)
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
		container_bg = o.container_bg,
		NoClipping = o.NoClipping,
		DefaultNodeHeight = o.DefaultNodeHeight,
		DefaultIndentation = o.DefaultIndentation,
		DefaultIconSize = o.DefaultIconSize,
	};
	o.RootNode = ctl.RootNode;

	CommonCtrl.AddControl(o.name, o);
	
	return o
end

-- Destroy the UI control
function ContextMenu2:Destroy ()
	ParaUI.Destroy(self.name);
end


--@param x: where to display. if nil, mouse_x is used
--@param y: where to display. if nil, mouse_y is used
--@param param1: a optional parameter object to be passed to onclick event
function ContextMenu2:Show(x, y, param1)
	local _this,_parent;
	if(self.name==nil)then
		log("ContextMenu2 instance name can not be nil\r\n");
		return
	end
	
	self.param1 = param1;
	x = x or mouse_x or 10;
	y = y or mouse_y or 10;
	
	local ctl = CommonCtrl.GetControl(self.name.."TreeView");
	if(ctl==nil)then
		log("ContextMenu2 instance's treeview is nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		-- create the container if it has never been created before.
		_this=ParaUI.CreateUIObject("container",self.name,"_lt", x, y, self.width, self.height);
		_this.background="";
		_this:AttachToRoot();
		_parent = _this;
		
		_this.onmouseup=string.format([[;CommonCtrl.ContextMenu2.OnMouseUpCont("%s");]], self.name);
		
		_this = _parent;
		
		ctl.parent = _parent;
		ctl:Show(true);
	end
	
	
	
	-- recalculate menu height each time the menu is shown
	local MenuHeight = self.MaxHeight;
	ctl.RootNode:Update(0,0);
	if(ctl.RootNode.LogicalBottom < self.MaxHeight) then
		if(ctl.RootNode.LogicalBottom > self.MinHeight) then
			MenuHeight = ctl.RootNode.LogicalBottom
		else
			MenuHeight = self.MinHeight
		end	
	end	
	if(self.AutoPositionMode == "_lt") then
		_this.x = x;
		_this.y = y;	
	elseif(self.AutoPositionMode == "_lb") then
		_this.x = x;
		_this.y = y - MenuHeight;	
	end
	if(_this.height ~= MenuHeight) then
		self.height = MenuHeight;
		_this.height = MenuHeight;
		_this:InvalidateRect(); -- this ensures that the next get absolution position call is valid. 
		self.IsModified = true;
	end
	
	
	-- update the inner treeview control if it has been modified. 
	if(self.IsModified) then
		ctl:Update();
		self.IsModified = false;
		--log("treeview control modified\n");
	end
	
	-- show up the menu 
	_this.visible = true;
	_this:SetTopLevel(true);
	
	CommonCtrl.WindowFrame.MoveContainerInScreenArea(_this);
end

-- hide the context menu
function ContextMenu2:Hide()
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		_this.visible = false;
	end
end

-- close the given control
function ContextMenu2.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ContextMenu2 instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- this is a click outside the menu container, we will therefore close the container. 
function ContextMenu2.OnMouseUpCont(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ContextMenu2 instance "..sCtrlName.."\r\n");
		return;
	end
	self:Hide();
end

-- set modified, always call this function after you have changed the menu items. 
-- this will cause the content menu to redraw next time it shows up. 
function ContextMenu2:SetModified(bModified)
	self.IsModified = bModified;
end


-- private function: called by default TreeNode UI
function ContextMenu2.OnToggleNode(sCtrlName, nodePath)
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
function ContextMenu2.OnClickNode(sCtrlName, nodePath)
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
			log("error getting ContextMenu2 instance from "..sCtrlName.."\r\n");
			return;
		end
		self:Hide();
		if(self.onclick~=nil)then
			self.onclick(node, self.param1);
		end
	end
end

-- default node renderer: it display a clickable check box for expandable node, followed by node text
function ContextMenu2.DrawMenuItemHandler(_parent,treeNode)
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
	
	left = left + IconSize + treeNode:GetIndentation() + 2;
	
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
			_this.onclick = string.format(";CommonCtrl.ContextMenu2.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
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
			_this.onclick = string.format(";CommonCtrl.ContextMenu2.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.ContextMenu2.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
		end
	end	
end
