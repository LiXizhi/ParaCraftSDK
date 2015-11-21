--[[
Title: Displays hierarchical data, such as a table of contents, in a tree structure. It can handle tons of data
Author(s): LiXizhi
Date: 2007/9/19
Note: I made this control mainly for displaying IM contact list and read-only chat history
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/TreeView.lua");
local ctl = CommonCtrl.TreeView:new{
	name = "TreeView1",
	alignment = "_lt",
	left=0, top=0,
	width = 200,
	height = 200,
	parent = nil,
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- the function return nil or the new height if current node height is not suitable, it will cause the node to be redrawn.
	-- predefined handlers: 
	--  CommonCtrl.TreeView.DrawPropertyNodeHandler  if one uses data binding controls. 
	--  CommonCtrl.TreeView.DrawSingleSelectionNodeHandler  if one wants to high light the current selection. 
	DrawNodeHandler = nil,
};
local node = ctl.RootNode;
node:AddChild("Node1");
node:AddChild(CommonCtrl.TreeNode:new({Text = "Node2", Name = "sample"}));
node = node:AddChild("Node3");
node = node:AddChild("Node3_1");
node = node:AddChild("Node3_1_1");
ctl.RootNode:AddChild("Node4");
ctl.RootNode:AddChild("Node5");

-- automatically bind to an attribute object or NPL table: use DrawPropertyNodeHandler handler. 
-- node:BindParaAttributeObject(nil, ParaScene.GetAttributeObject(), true)
-- node:BindNPLTable(bindingContext, o, bReadOnly, fieldNames, fieldTextReplaceables)

ctl:Show();
-- One needs to call Update() if made any modifications to the TreeView after the Show() method, such as adding or removing new nodes, or changing text of a given node. 
-- ctl:Update();
-- node:SortChildren(CommonCtrl.TreeNode.GenerateGreaterCFByField("Text")); -- sort children by field
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/TreeNode.lua");

local TreeNode = CommonCtrl.TreeNode;

-- Displays hierarchical data, such as a table of contents, in a tree structure.
local TreeView = commonlib.inherit(nil, commonlib.createtable("CommonCtrl.TreeView", {
	-- the top level control name
	name = "TreeView1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
	parent = nil,
	-- appearance
	container_bg = nil, -- the background of container
	main_bg = "", -- the background of container without scrollbar, default to full transparent
	-- automatically display vertical scroll bar when content is large
	AutoVerticalScrollBar = true,
	-- if true, the ClientWidth is not changed when content is too long. 
	IsExternalScrollBar = nil,
	-- true to disable mouse wheel to scroll content. call EnableMouseWheel to alter setting at runtime. 
	disablemousewheel = nil,
	-- if true, vertical scroll bar is created but is invisible
	HideVerticalScrollBar = nil,
	-- offset ScrollBar postion in horizontal
	VerticalScrollBarOffsetX = 0,
	-- Vertical ScrollBar Width
	VerticalScrollBarWidth = 15,
	-- only used for rendering. similar to VerticalScrollBarWidth
	ScrollBarTrackWidth = nil,
	-- how many pixels to scroll each time
	VerticalScrollBarStep = 24,
	-- how many pixels to scroll when user hit the empty space of the scroll bar. this is usually same as DefaultNodeHeight
	VerticalScrollBarPageSize = 24,
	-- The root tree node. containing all tree node data
	RootNode = nil, 
	-- Default height of Tree Node
	DefaultNodeHeight = 24,
	-- Default width of Tree Node, this is not used unless we are displaying the treenode in a grid view style. 
	DefaultNodeWidth = nil,
	-- Default padding of tree nodes. this is not used unless we are displaying the treenode in a grid view style. 
	DefaultNodePadding = 0,
	-- how many items to display per row for the root node.
	ItemsPerRow = nil,
	-- default icon size
	DefaultIconSize = 16,
	-- whether to show icon on the left of each line. 
	ShowIcon = true,
	-- default indentation
	DefaultIndentation = 5,
	-- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- if DrawNodeHandler is nil, and the treenode's DrawNodeHandler is also nil, the default TreeView.DrawNormalNodeHandler function will be used. 
	DrawNodeHandler = nil,
	-- Cache size: The number of TreeNode controls to be cached. [N/A]
	CacheSize = 30,
	-- Force no clipping or always using fast render. Unless you know that the unit scroll step is interger times of all TreeNode height. You can disable clipping at your own risk. 
	-- Software clipping is always used to clip all invisible TreeNodes. However, this option allows you to specify whether to use clipping for partially visible TreeNode. 
	NoClipping = nil,
	-- a function of format function FuncName(treeNode) end or nil
	onclick = nil,
	-- function (self) end called, when click the parent container. parent container can only be clicked when there is not enough line taking the full treeview space. 
	onmouseup_parent = nil,
	-- only used in property view: the percentage of width used to display the name text. 
	PropertyNameWidthPercentage = 0.4,
	-- the initial self.ClientY when control is first created. 
	InitialClientY = nil,
	-- if true, the parent container can be click through. 
	ClickThrough = nil,
	--------------------------------
	-- internal parameters, do not use externally
	--------------------------------
	-- the client area X, Y position in pixels relative to the logical tree view container. 
	ClientX = 0,
	ClientY = 0,
	-- this is automatically set according to whether a scroll bar is available.
	ClientWidth = 10,
	ClientHeight = 10,
	-- a mapping from node path to existing line control container index, the total number of mapping here does not exceed CacheSize
	NodeUIContainers = {},
}));

-- constructor
function TreeView:ctor()
	-- create the root node
	self.RootNode = CommonCtrl.TreeNode:new({TreeView = self, Name = "RootNode", 
		NodeHeight = 0, -- so that root node is not drawn
		ItemsPerRow = self.ItemsPerRow,
	})
	CommonCtrl.AddControl(self.name, self);
end


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
--@param bDoNotUpdate: Most the time, this is nil. If true, it will not update the treeview; this usually happens when people wants to perform some sort and then call Update manually. 
--@return: true if control is updated. 
function TreeView:Show(bShow, bDoNotUpdate, bShowLastElement)
	local _this,_parent;
	if(self.name==nil)then
		log("TreeView instance name can not be nil\r\n");
		return
	end
	--+++++++++++++++++++++++++++++++++++
	--self.ClientWidth=self.width;
	--self.ClientHeight=self.height;
	--+++++++++++++++++++++++++++++++++++
	local bUpdated;
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		if(self.container_bg~=nil) then
			_this.background=self.container_bg;
		else
			_this.background="";
		end	
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		if (self.ClickThrough) then
			_this:GetAttributeObject():SetField("ClickThrough", true);
		end
		
		self.ClientX = 0;
		self.ClientY = self.InitialClientY or 0;
		self.ClientWidth = 10;
		self.ClientHeight = 10;
		
		-- update the treeview on creation
		if(not bDoNotUpdate) then
			self:Update(bShowLastElement);
		end
		bUpdated = true;
		_this = _parent;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	
	return bUpdated;
end

-- this function should be called whenever the layout of the tree view changed. 
-- internally, it will recalculate all node logical positions and redraw(recreate) all nodes.
--@param bShowLastElement: true to show the last element, otherwise ShowNode or show position is not changed. 
--@param ShowNode: nil or a treeNode. It will scroll for the best show of the node element. This is usually used when expanding a tree node. 
--@param DisableRecursive: internally used: disable recursive call of this function. 
function TreeView:Update(bShowLastElement, ShowNode, DisableRecursive)
	-- update the logical positions
	self.RootNode:Update(0,0);
	
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		commonlib.applog("error getting Tree View parent");
		return
	end
	-- simply remove all sub UI and IDE controls 
	local main = _parent:GetChild("main");
	local VScrollBar = _parent:GetChild("VScrollBar");
	
	CommonCtrl.DeleteAllSubControls(self);
	
	-- recreate all tree node UI
	local _,_, TreeViewWidth,TreeViewHeight = _parent:GetAbsPosition();
	self.ClientHeight = TreeViewHeight;
	if(self.RootNode.LogicalBottom<=TreeViewHeight) then
		-- disable scroll bar
		if(not main:IsValid()) then
			main = ParaUI.CreateUIObject("container","main","_fi",0,0,0,0);
			main.background = self.main_bg;
			if (self.ClickThrough) then
				main:GetAttributeObject():SetField("ClickThrough", true);
			end
			if(self.onmouseup_parent) then
				main.onmouseup = string.format(";CommonCtrl.TreeView.OnMouseUpContainer(%q)", self.name);
			end
			_parent:AddChild(main);
		else
			main:RemoveAll();
			if(VScrollBar:IsValid()) then
				ParaUI.DestroyUIObject(VScrollBar);
				main:Reposition("_fi",0,0,0,0);
				main.onmousewheel="";
				main.fastrender = true;
			end
			main.background = self.main_bg;
		end
		
		self.ClientY = 0;
		self.ClientWidth = TreeViewWidth;
	else
		-- auto enable scroll bar
		if((self.ClientY+self.ClientHeight)>self.RootNode.LogicalBottom) then
			self.ClientY = self.RootNode.LogicalBottom - self.ClientHeight;
		end
		
		if(bShowLastElement) then
			self:ScrollToEnd();
		elseif(ShowNode~=nil) then
			-- auto scroll min distance from the current location to best show the node. If entire node can not be in client area, the beginning is shown. 
			if(self.ClientY>=ShowNode.LogicalY) then
				self.ClientY = ShowNode.LogicalY;
			else
				if((self.ClientY+self.ClientHeight)<ShowNode.LogicalBottom ) then
					local tryY = ShowNode.LogicalBottom - self.ClientHeight;
					if(tryY>=ShowNode.LogicalY) then
						self.ClientY = ShowNode.LogicalY;
					elseif(tryY<0)	then
						self.ClientY = 0;
					else
						self.ClientY = tryY;
					end	
				end
			end
		end
	
		if(self.AutoVerticalScrollBar) then
			-- enable scroll bar
			if(not main:IsValid()) then
				main=ParaUI.CreateUIObject("container","main","_fi",0,0,if_else(self.IsExternalScrollBar, 0, self.VerticalScrollBarWidth),0);
				main.background = self.main_bg;
				if(not self.NoClipping) then
					main.fastrender = false;
				end	
				if(not self.disablemousewheel) then
					main.onmousewheel = string.format(";CommonCtrl.TreeView.OnTreeViewMouseWheel(%q)", self.name);
				end	
				if (self.ClickThrough) then
					main:GetAttributeObject():SetField("ClickThrough", true);
				end
				if(self.onmouseup_parent) then
					main.onmouseup = string.format(";CommonCtrl.TreeView.OnMouseUpContainer(%q)", self.name);
				end
				_parent:AddChild(main);
			else
				-- reuse main container
				main:RemoveAll();
				if(not VScrollBar:IsValid()) then
					main:Reposition("_fi",0,0, if_else(self.IsExternalScrollBar, 0, self.VerticalScrollBarWidth),0);
					if(not self.NoClipping) then
						main.fastrender = false;
					end	
					if(not self.disablemousewheel and main.onmousewheel == "" ) then
						main.onmousewheel = string.format(";CommonCtrl.TreeView.OnTreeViewMouseWheel(%q)", self.name);
					end	
				end
				main.background = self.main_bg;
			end

			if(not VScrollBar:IsValid()) then
				VScrollBar=ParaUI.CreateUIObject("scrollbar", "VScrollBar","_mr", self.VerticalScrollBarOffsetX, 0, self.VerticalScrollBarWidth, 0);
				_parent:AddChild(VScrollBar);
			else
				VScrollBar:Reposition("_mr", self.VerticalScrollBarOffsetX, 0, self.VerticalScrollBarWidth, 0);
			end
			if(self.HideVerticalScrollBar) then
				VScrollBar.visible = false;
			end
			
			-- update track range and thumb location.
			VScrollBar:SetTrackRange(0,self.RootNode.LogicalBottom);
			VScrollBar:SetPageSize(TreeViewHeight);
			-- this is tricky, since page size can not be smaller than track range. otherwise there will be display error. 2007.10.3 LXZ
			if(self.VerticalScrollBarStep > (self.RootNode.LogicalBottom-TreeViewHeight)/2) then
				VScrollBar:SetStep((self.RootNode.LogicalBottom-TreeViewHeight)/2);
			else
				VScrollBar:SetStep(self.VerticalScrollBarStep);
			end	
			
			VScrollBar.value = self.ClientY;
			VScrollBar.scrollbarwidth = self.ScrollBarTrackWidth or self.VerticalScrollBarWidth;
			VScrollBar.onchange = string.format(";CommonCtrl.TreeView.OnVScrollBarChanged(%q)", self.name);
			
			if(not self.IsExternalScrollBar) then
				self.ClientWidth = TreeViewWidth - self.VerticalScrollBarWidth;
			else
				self.ClientWidth = TreeViewWidth;
			end
		else
			-- disable scroll bar
			if(not main:IsValid()) then
				main = ParaUI.CreateUIObject("container","main","_fi",0,0,0,0);
				main.background = self.main_bg;
				if(self.onmouseup_parent) then
					main.onmouseup = string.format(";CommonCtrl.TreeView.OnMouseUpContainer(%q)", self.name);
				end
				if (self.ClickThrough) then
					main:GetAttributeObject():SetField("ClickThrough", true);
				end
				_parent:AddChild(main);
			else
				main:RemoveAll();
				if(VScrollBar:IsValid()) then
					ParaUI.DestroyUIObject(VScrollBar);
					main:Reposition("_fi",0,0,0,0);
					main.onmousewheel="";
					main.fastrender = true;
				end
				main.background = self.main_bg;
			end
			self.ClientY = 0;
			self.ClientWidth = TreeViewWidth;
		end
	end
	
	self.NodeUIContainers = {};
	
	-- refresh the UI automatically here
	self:RefreshUI(DisableRecursive, bShowLastElement);
end

-- this function is called whenever the user scrolls the TreeView. 
function TreeView:RefreshUI(DisableRecursive, bShowLastElement)
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		commonlib.applog("error getting Tree View parent");
		return
	end
	
	_parent	= _parent:GetChild("main");
	if(not _parent:IsValid()) then
		return
	end
	local _,_, TreeViewWidth,TreeViewHeight = _parent:GetAbsPosition();
	
	-- the node height may change during refreshing UI, so determines whether we need to refresh again. 
	local bNeedUpdate;
	local x, y = self.ClientX, self.ClientY;
	local node, firstNode;
	firstNode = self.RootNode:GetNodeByPoint(x, y);
	--log("TreeView:RefreshUI: with clientY "..y.."\n");
	--if(firstNode~=nil) then log("first node: "..firstNode:GetNodePath().."\n") end
	node = firstNode;
	
	-- reuse existing UI controls by just changing their positions
	local NodeUICont = {};
	while node~=nil do 
		local nodepath = node:GetNodePath();
		if(not node.Invisible) then
			local uiIndex = self.NodeUIContainers[nodepath];
			if(uiIndex ~=nil) then
				local tmp = _parent:GetChild(tostring(uiIndex));
				if(tmp:IsValid())  then
					tmp.x = node.LogicalX - x;
					tmp.y = node.LogicalY - y;
					tmp.height = node:GetHeight();
					tmp.width = node:GetWidth()  or self.ClientWidth;
					NodeUICont[nodepath] = uiIndex;
					--log(nodepath.."(REUSED)"..uiIndex.."\n");
				end
			end
			node = node:GetNextNode();
		else
			-- skip children
			node = node:GetNextNode(true);	
		end	
	
		if(node~=nil)then
			if(node.LogicalY >= (self.ClientY+self.ClientHeight)) then
				node = nil;
			end
		end
	end
	
	-- clear all other unused UI controls
	local nodepath, uiIndex;
	for nodepath, uiIndex in pairs(self.NodeUIContainers) do
		if(not NodeUICont[nodepath]) then
			local tmp = _parent:GetChild(tostring(uiIndex));
			if(tmp:IsValid())  then
				tmp:RemoveAll();
				tmp.visible = false;
				--log(nodepath.."(REMOVED)"..uiIndex.."\n");
			end
			local node = self:GetNodeByPath(nodepath);
			node:DeleteAllSubControls();
		end	
	end
	
	-- create UI controls if nonexisting 
	node = firstNode;
	local uiIndex = 0; 
	while node~=nil do 
		if(not node.Invisible) then
			local nodepath = node:GetNodePath();
			local nodeheight = node:GetHeight();
			if(nodeheight>0 and NodeUICont[nodepath] == nil) then
				-- create UI cont for this object
				local emptyUI;
				while (not emptyUI) do
					local tmp = _parent:GetChild(tostring(uiIndex));
					if(not tmp:IsValid())  then
						-- create if never created before
						tmp=ParaUI.CreateUIObject("container",tostring(uiIndex),"_lt",0,0,self.ClientWidth,nodeheight);
						tmp.background = "";
						if (self.ClickThrough) then
							tmp:GetAttributeObject():SetField("ClickThrough", true);
						end
						tmp:BringToBack();
						_parent:AddChild(tmp);
						emptyUI = tmp;
						NodeUICont[nodepath] = uiIndex;
					elseif(not tmp.visible) then	
						emptyUI = tmp;
						NodeUICont[nodepath] = uiIndex;
					end
					uiIndex = uiIndex+1;
				end	
				-- make it in position
				emptyUI.x = node.LogicalX - x;
				emptyUI.y = node.LogicalY - y;
				emptyUI.height = nodeheight;
				emptyUI.width = node:GetWidth() or self.ClientWidth;
				--log(nodepath.."(NEW):"..NodeUICont[nodepath].."\n");
				emptyUI.visible = true;
				
				-- call the draw method to create the UI for the given TreeNode. 
				node:DeleteAllSubControls();
				local nodeHeight
				if(node.DrawNodeHandler) then	
					nodeHeight = node.DrawNodeHandler(emptyUI, node);
				elseif(self.DrawNodeHandler) then
					nodeHeight = self.DrawNodeHandler(emptyUI, node);	
				else
					nodeHeight = TreeView.DrawNormalNodeHandler(emptyUI, node);
				end
				
				if(type(nodeHeight) == "number") then
					node.NodeHeight = nodeHeight;
					bNeedUpdate = true;
				end
			end
			node = node:GetNextNode();
		else
			-- skip children
			node = node:GetNextNode(true);
		end	
		if(node~=nil)then
			if(node.LogicalY >= (self.ClientY+self.ClientHeight)) then
				node = nil;
			end
		end
	end
	--++++++++++++++++++++++
	self:CreatHorizontalScrollBar(NodeUICont);
	--++++++++++++++++++++++
	-- set with the new UI container mapping
	self.NodeUIContainers = NodeUICont;
	
	-- in case the node height is changed, we need to update again. 
	if(bNeedUpdate and not DisableRecursive)then
		self:Update(bShowLastElement, nil, true);
	end
end

-- Scroll to show the last element. One need to call RefreshUI for this to take effect on UI.
function TreeView:ScrollToEnd()
	self.ClientY = self.RootNode.LogicalBottom - self.ClientHeight;
	if(self.ClientY<0) then
		self.ClientY = 0;
	end
end

-- get logical height.
function TreeView:GetLogicalHeight()
	if(self.RootNode) then
		return self.RootNode.LogicalBottom or 0;
	end
	return 0;
end

-- scroll by step
function TreeView:ScrollByStep(value)
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		commonlib.applog("error getting Tree View parent");
		return
	end
	local tmp = _parent:GetChild("VScrollBar");
	if(tmp:IsValid()) then
		tmp.value = tmp.value+value;
		
		self.ClientY = tmp.value;
		self:RefreshUI();
	end
end

-- get a string containing the node path. such as "0/1/1/3"
-- as long as the TreeNode does not change, the node path uniquely identifies a TreeNode.
function TreeView:GetNodeByPath(path)
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

-- public: whether to draw the root node. Default to false
function TreeView:ShowRootNode(bShow)
	if(bShow) then
		TreeView.RootNode.NodeHeight = nil;
	else
		TreeView.RootNode.NodeHeight = 0;
	end
end	

-- whether to allow mouse wheel to scroll the content of treeview. default to true. 
function TreeView:EnableMouseWheel(bEnable)
	self.disablemousewheel = not bEnable;
	local _parent = ParaUI.GetUIObject(self.name);
	if(_parent:IsValid()) then
		if(not self.disablemousewheel) then
			_parent:GetChild("main").onmousewheel = string.format(";CommonCtrl.TreeView.OnTreeViewMouseWheel(%q)", self.name);
		else
			_parent:GetChild("main").onmousewheel = "";
		end
	end	
end

-- private: called whenever the mouse wheel is detected in each TreeNode container
function TreeView.OnTreeViewMouseWheel(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		commonlib.applog("error getting Tree View parent");
		return
	end
	
	local tmp = _parent:GetChild("VScrollBar");
	if(tmp:IsValid()) then
		tmp.value = tmp.value-mouse_wheel*self.VerticalScrollBarStep;
		
		self.ClientY = tmp.value;
		self:RefreshUI();
	end
end

-- private: called whenever the vScroll bar is changed
function TreeView.OnVScrollBarChanged(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		commonlib.applog("error getting Tree View parent");
		return
	end
	
	local tmp = _parent:GetChild("VScrollBar");
	if(tmp:IsValid()) then
		--log("TreeView vscroll bar onchanged at "..tmp.value.."\n");
		self.ClientY = tmp.value;
		self:RefreshUI();
	end
end

function TreeView.OnMouseUpContainer(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	if(type(self.onmouseup_parent) == "function") then
		self.onmouseup_parent(self);
	end
end

-- private function: called by default TreeNode UI
-- @param bForceSelect: if true, node will be selected. and onclick event will be fired. 
function TreeView.OnToggleNode(sCtrlName, nodePath, bForceSelect)
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
		if(bForceSelect) then
			node:SelectMe()
			node:OnClickNode();
		end
		node.TreeView:Update(nil, node);
	end
end


-- private function: called by default TreeNode UI
function TreeView.OnClickNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		-- call the event handler if any
		node:OnClickNode();
	end
end
-- default node renderer: it display a clickable check box for expandable node, followed by node text
function TreeView.DrawNormalNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode:GetWidth() or treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		if(not treeNode.bSkipIconSpace) then
			left = left + IconSize;
		end
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.Type=="Title") then
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.text = treeNode.Text;
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
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
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
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
		end
	end	
end

-- private function: same as TreeView.OnClickNode except that it remembers a single selection. 
function TreeView.OnSelectNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		node:SelectMe(true)
		
		-- click the node. 
		TreeView.OnClickNode(sCtrlName, nodePath);
	end
end

-- single selection node renderer: it only differs from DrawNormalNodeHandler that the currently selected leaf node is high lighted. 
function TreeView.DrawSingleSelectionNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode:GetWidth() or treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		if(not treeNode.bSkipIconSpace) then
			left = left + IconSize;
		end	
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.Type=="Title") then
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.text = treeNode.Text;
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
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
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
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			if(treeNode.Selected) then
				_this.background = "Texture/alphadot.png";
			else
				_this.background = "";
				_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			end
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
		end
	end	
end

--[[ generate all sub nodes according to a given ParaAttributeObject. 
Each propery field in the attribute object are binded to a sub tree node of the current node. 
In order to render the treeNode properly, one needs to use the TreeView.DrawPropertyNodeHandler handler in the treeview. 
note: there is no need to call bindingContext:UpdateDataToControls() after calling this. 
@param bindingContext: the binding context with which the bindings are associated. if nil, a new binding context will be created. 
@param o: the NPL table
@param bReadOnly: true if the binding is readonly. Please note if some property is read only, it will be readonly even if this value is nil.
@param fieldNames: if nil, all known propery fields in the attributes objects are binded. 
	otherwise: it is an array of attribute names that will be binded. such as {"ClassName", "ClassID",}. They will appear in the given order. 
@param fieldTextReplaceables: it a table mapping field names to field text. If this is nil or the mapping is not found, the field name will be used as the tree node text. such as {["ClassName"] = "Name of the class", ["ClassID"] = "unique identifier"}
]]
function TreeNode:BindNPLTable(bindingContext, o, bReadOnly, fieldNames, fieldTextReplaceables)
	if(type(o)~="table") then return end
	-- the binding context with which the bindings are associated. if nil, a new binding context will be created. 
	bindingContext = bindingContext or commonlib.BindingContext:new();
	
	-- the binding function requried by ide/DataBinding.lua. 
	local function PropertyBindingFunction(dataMember, bIsWriting, value)
		if(not bIsWriting) then
			-- reading from data source
			return commonlib.getfield(dataMember, o) or (value or "");
		else
			-- writing to data source
			if(value ~= nil) then
				commonlib.setfield(dataMember, value, o);
			end	
		end	
	end
	-- clear all sub nodes
	self:ClearAllChildren();
	
	--------------------------------------------
	-- add the property node according to property type
	--------------------------------------------
	local function AddPropertyNode(sName)
		local sText;
		if(fieldTextReplaceables~=nil) then
			sText = fieldTextReplaceables[sName];
		end
		if(not sText) then sText = sName end

		local propertyValue = commonlib.getfield(sName, o);
		local type = type(propertyValue);
		local nodeType = nil;
		local NodeHeight = nil;
		
		-- if some property is read only, it will be readonly even if overall binding is editable.
		local IsBindingReadOnly = bReadOnly;
		local UpdateMode;
		if(IsBindingReadOnly) then
			UpdateMode = commonlib.Binding.DataSourceUpdateMode.ReadOnly;
		end
		
		if(type == "string") then
			nodeType = "string";
		elseif(type == "number") then
			nodeType = "float";
		elseif(type == "boolean") then
			nodeType = "bool";
		end
		if(nodeType~=nil) then
			-- create node
			local node = self:AddChild(CommonCtrl.TreeNode:new({Text = sText, Name = sName, Type = nodeType, NodeHeight = NodeHeight,}));
			-- create binding and assign it to tree node. 
			node.databinding = bindingContext:AddBinding(PropertyBindingFunction, sName, self.TreeView.name, commonlib.Binding.ControlTypes.IDE_treeview, node:GetNodeNamePath().."<propertyValue>", UpdateMode)
		end	
	end
	
	-- for each field, create a sub tree node.
	if(type(fieldNames) == "table") then
		-- only add fields that appears in the fieldsName parameter
		local i, name;
		for i, name in ipairs(fieldNames) do
			AddPropertyNode(name);
		end
	else
		-- add all fields in NPL table 
		-- currently, it will only add level 1, 2, 3 fields. (this will prevent recursive tables)
		local max_levels = 3;
		local function AddFields(t, parentName, level)
			if(level > max_levels) then
				return
			end
			local name, v;
			for name, v in pairs(t) do 
				if(type(v) == "table") then
					AddFields(v, parentName..name..".", level+1);
				elseif(type(v) ~= "function") then
					AddPropertyNode(parentName..name);
				end
			end	
			-- TODO: figure out a way to bind array as well?
		end
		AddFields(o, "", 1);
	end
end

--[[ generate all sub nodes according to a given ParaAttributeObject. 
Each propery field in the attribute object are binded to a sub tree node of the current node. 
In order to render the treeNode properly, one needs to use the TreeView.DrawPropertyNodeHandler handler in the treeview. 
note: there is no need to call bindingContext:UpdateDataToControls() after calling this. 
@param bindingContext: the binding context with which the bindings are associated. if nil, a new binding context will be created. 
@param att: the ParaAttributeObject itself or a function () end that returns the att object. 
@param bReadOnly: true if the binding is readonly. Please note if some property is read only, it will be readonly even if this value is nil.
@param fieldNames: if nil, all known propery fields in the attributes objects are binded. 
	otherwise: it is an array of attribute names that will be binded. such as {"ClassName", "ClassID",}. They will appear in the given order. 
@param fieldTextReplaceables: it a table mapping field names to field text. If this is nil or the mapping is not found, the field name will be used as the tree node text. such as {["ClassName"] = "Name of the class", ["ClassID"] = "unique identifier"}
]]
function TreeNode:BindParaAttributeObject(bindingContext, att, bReadOnly, fieldNames,fieldTextReplaceables)
	-- the binding context with which the bindings are associated. if nil, a new binding context will be created. 
	bindingContext = bindingContext or commonlib.BindingContext:new();
	
	-- the binding function requried by ide/DataBinding.lua. 
	local function PropertyBindingFunction(dataMember, bIsWriting, value)
		local _att;
		if(type(att) == "function") then
			-- get the binding object. 
			_att = att();
		else
			_att = att;	
		end
		if(_att~=nil) then
			if(not bIsWriting) then
				-- reading from data source
				return _att:GetField(dataMember, value or "");
			else
				-- writing to data source
				if(value~=nil) then
					_att:SetField(dataMember, value);
				end	
			end	
		end	
	end
	
	-- clear all sub nodes
	self:ClearAllChildren();
	
	local _att;
	if(type(att) == "function") then
		-- get the binding object. 
		_att = att();
	else
		_att = att;	
	end
	if(_att~=nil) then
		--------------------------------------------
		-- add the property node according to property type
		--------------------------------------------
		local function AddPropertyNode(nIndex)
			local sName = _att:GetFieldName(nIndex);
			local sText;
			if(fieldTextReplaceables~=nil) then
				sText = fieldTextReplaceables[sName];
			end
			if(not sText) then sText = sName end
			
			local type = _att:GetFieldType(nIndex);
			local nodeType = nil;
			local NodeHeight = nil;
			local sSchematics = _att:GetSchematicsType(nIndex);
			
			-- if some property is read only, it will be readonly even if overall binding is editable.
			local IsBindingReadOnly = _att:IsFieldReadOnly(nIndex) or bReadOnly;
			local UpdateMode;
			if(IsBindingReadOnly) then
				UpdateMode = commonlib.Binding.DataSourceUpdateMode.ReadOnly;
			end
			
			if(type == "string") then
				if(sSchematics == ":file") then
					nodeType = "file";
				elseif(sSchematics == ":script") then
					nodeType = "script";
				else
					nodeType = "string";
				end
			elseif(type == "float") then
				nodeType = "float";
			elseif(type == "int") then
				nodeType = "int";
			elseif(type == "bool") then
				nodeType = "bool";
			elseif(type == "vector3") then
				if(sSchematics == ":rgb") then
					nodeType = "color";
				else
					nodeType = "vector3";
				end
			elseif(type == "vector2") then	
				nodeType = "vector2";
			elseif(type == "void") then
				nodeType = "void";
			end
			
			if(nodeType~=nil) then
				-- create node
				local node = self:AddChild(CommonCtrl.TreeNode:new({Text = sText, Name = sName, Type = nodeType, NodeHeight = NodeHeight, DrawNodeHandler = self.DrawNodeHandler}));
				-- create binding and assign it to tree node. 
				node.databinding = bindingContext:AddBinding(PropertyBindingFunction, sName, self.TreeView.name, commonlib.Binding.ControlTypes.IDE_treeview, node:GetNodeNamePath().."<propertyValue>", UpdateMode)
			end	
		end
		
		-- for each field in att, create a sub tree node.
		if(type(fieldNames) == "table") then
			-- only add fields that appears in the fieldsName parameter
			local i, name;
			for i, name in ipairs(fieldNames) do
				local nIndex = _att:GetFieldIndex(name);
				if(nIndex>=0) then
					AddPropertyNode(nIndex);
				end
			end
		else
			-- add all fields in attribute object. 
			local nCount = _att:GetFieldNum();
			local nIndex;
			for nIndex = 1, nCount do 
				AddPropertyNode(nIndex);
			end	
		end
	end
	
end

-- only used by property node handler. whenever a string typed property changes, 
-- it will update the treeNode.propertyValue field with the new value. 
function TreeView.OnPropertyValueChanged_String(sCtrlName,nodePath, ctrlname)
	local treeView, treeNode = TreeView.GetCtl(sCtrlName,nodePath)
	if(treeNode) then
		local tmp = ParaUI.GetUIObject(ctrlname);
		if(tmp:IsValid()) then
			treeNode.propertyValue = tmp.text;
		end
	end
end
-- only used by property node handler. whenever a string typed property changes, 
-- it will update the treeNode.propertyValue field with the new value. 
function TreeView.OnPropertyValueChanged_Float(sCtrlName,nodePath, ctrlname)
	local treeView, treeNode = TreeView.GetCtl(sCtrlName,nodePath)
	if(treeNode) then
		local tmp = ParaUI.GetUIObject(ctrlname);
		if(tmp:IsValid()) then
			local v = tonumber(tmp.text);
			if(not v) then
				_guihelper.MessageBox("Please enter a valid number")
			else
				treeNode.propertyValue = v;
			end
		end
	end
end

--[[ draw property node: each node may be a readonly or editable text, boolean, int, float, color, radiobox, dropdownlistbox, etc field. 
]]
function TreeView.DrawPropertyNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.Type=="Title") then
		-- 
		-- a title text
		--
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.text = treeNode.Text;
		_guihelper.SetFontColor(_this, treeNode.TextColor);
	elseif(treeNode.Type=="separator") then
		-- 
		-- a horizontal line separator
		--
		_this=ParaUI.CreateUIObject("button","b","_mt", left, 2, 1, 1);
		_this.background = "Texture/whitedot.png";
		_this.enabled = false;
		_guihelper.SetUIColor(_this, "150 150 150 255");
		_parent:AddChild(_this);
	elseif(treeNode.databinding~=nil) then
		-------------------------------------------
		-- data binding properties
		-------------------------------------------
		-- what percentage(30%) of node width is used to display the property width
		local name_width = math.floor(nodeWidth*treeNode.TreeView.PropertyNameWidthPercentage); 
		-- the property name UI
		_this=ParaUI.CreateUIObject("text","name","_lt", left, 2, name_width, 13);
		_this.text = treeNode.Text;
		_parent:AddChild(_this);
		left = left + name_width;
		
		
				
		-- the property value UI for each known type: we render readonly and editable field differently. 
		if(treeNode.Type=="string") then
			-- 
			-- a simple string property
			--
			if(treeNode.databinding.UpdateMode == commonlib.Binding.DataSourceUpdateMode.ReadOnly) then
				_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, 15);
				_this.text = tostring(treeNode.databinding:GetValue());
				_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
				_parent:AddChild(_this);
			else
				local ctrlName = treeNode:NewSubControlName();
				_this=ParaUI.CreateUIObject("imeeditbox",ctrlName,"_mt", left, 2, 5, 20);
				_this.text = tostring(treeNode.databinding:GetValue());
				_this.onchange = string.format(";CommonCtrl.TreeView.OnPropertyValueChanged_String(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), ctrlName);
				_parent:AddChild(_this);
			end
		elseif(treeNode.Type=="file") then	
			_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, 15);
			_this.text = tostring(treeNode.databinding:GetValue());
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_parent:AddChild(_this);
		elseif(treeNode.Type=="script") then	
			_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, 15);
			_this.text = tostring(treeNode.databinding:GetValue());
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_parent:AddChild(_this);
		elseif(treeNode.Type=="float") then
			-- 
			-- a simple float property
			--
			if(treeNode.databinding.UpdateMode == commonlib.Binding.DataSourceUpdateMode.ReadOnly) then
				_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, 15);
				_this.text = tostring(treeNode.databinding:GetValue());
				_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
				_parent:AddChild(_this);
			else
				local ctrlName = treeNode:NewSubControlName();
				_this=ParaUI.CreateUIObject("editbox",ctrlName, "_mt", left, 2, 5, 20);
				_this.text = tostring(treeNode.databinding:GetValue());
				_this.onchange = string.format(";CommonCtrl.TreeView.OnPropertyValueChanged_Float(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), ctrlName);
				_parent:AddChild(_this);
			end	
		elseif(treeNode.Type=="int") then	
			_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, 15);
			_this.text = tostring(treeNode.databinding:GetValue());
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_parent:AddChild(_this);
		elseif(treeNode.Type=="bool") then	
			_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, 15);
			_this.text = tostring(treeNode.databinding:GetValue());
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_parent:AddChild(_this);
		elseif(treeNode.Type=="void") then	
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 2, 80, 20);
			_this.text = "运行";
			_parent:AddChild(_this);
		elseif(treeNode.Type=="vector3") then	
		elseif(treeNode.Type=="vector2") then
		elseif(treeNode.Type=="color") then
			-- TODO: used this: treeNode:NewSubControlName() for control name
		end	
	else
		--
		-- for group nodes and unknown nodes
		--
		if(treeNode:GetChildCount() > 0) then
			-- node that contains children. We shall display some
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top+6, 10, 10);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
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
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			-- node with text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_mt", left, 1 , 2, height - 1);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
		end
	end	
end

-- render a category node that can expand child nodes. 
function TreeView.RenderCategoryNode(_parent,treeNode, left, top, width, height)
	if(treeNode:GetChildCount() > 0) then
		width = 12 -- check box width
		local _this=ParaUI.CreateUIObject("button","b","_lt", left, top+6 , width, width);
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + width + 2;
		
		if(treeNode.Expanded) then
			_this.background = "Texture/3DMapSystem/common/itemopen.png";
		else
			_this.background = "Texture/3DMapSystem/common/itemclosed.png";
		end
	else
		if(not treeNode.Expanded) then
			treeNode.Expanded = true;
		end	
	end	
	
	_this = ParaUI.CreateUIObject("button", "l", "_mt", left+3, 3, 2, height-2)
	_this.text = treeNode.Text;
	_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
	_this.background = "";
	_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
	if(treeNode:GetChildCount() > 0) then
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
	end	
	_parent:AddChild(_this);
end

-- render a category node that can expand child nodes. 
function TreeView.RenderTextNode(_parent,treeNode, left, top, width, height)
	local _this=ParaUI.CreateUIObject("button","b","_mt", left, 1 , 2, height - 1);
	_parent:AddChild(_this);
	_this.background = "";
	_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
	
	_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
	_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
	_this.text = treeNode.Text;
end

-- Helper function: return treeView, treeNode. 
function TreeView.GetCtl(sCtrlName,nodePath)
	local ctl,node;
	ctl = CommonCtrl.GetControl(sCtrlName);
	if(ctl~=nil)then
		node = ctl:GetNodeByPath(nodePath);
	end
	if(node == nil) then
		log("error getting TreeView:TreeNode instance "..sCtrlName..":"..nodePath.."\r\n");
	end
	return ctl,node;
end
--  ++++++++++++++++++++++
function TreeView:CreatHorizontalScrollBar(NodeUICont)
end
