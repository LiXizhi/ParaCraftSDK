--[[
Title: TreeNode objects used in container class like treeview
Author(s): LiXizhi
Date: 2007/9/19
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/TreeNode.lua");
local node = CommonCtrl.TreeNode:new({Text = "Node", Name = "sample"});
local node1 = CommonCtrl.TreeNode:new({Text = "Node1", Name = "sample"});
node:AddChild(node1);
node:SortChildren(CommonCtrl.TreeNode.GenerateGreaterCFByField("Text")); -- sort children by field
-------------------------------------------------------
]]

-- Represents a tree node used in container class like TreeView. 
local TreeNode = {
	-- Gets the parent tree node of the current tree node. 
	parent = nil, 
	-- Gets the parent tree view that the tree node is assigned to. 
	TreeView = nil,
	-- Gets the zero-based depth of the tree node in the TreeView control 
	Level = 0,  
	-- Gets the array of TreeNode objects assigned to the current tree node.
	Nodes = nil,
	-- Gets a value indicating whether the tree node is in the expanded state. 
	Expanded = true,
	-- Gets a value indicating whether the tree node is in the selected state. 
	Selected = nil, 
	-- if true, node is invisible.
	Invisible = nil,
	-- Gets or sets the name of the tree node. 
	Name = nil,
	-- Gets or sets the text displayed in the label of the tree node. 
	Text = nil,
	-- Gets or sets the text color
	TextColor = nil,
	-- Gets or sets the URL to navigate to when the node is clicked. 
	NavigateUrl = nil, 
	-- Gets or sets a non-displayed value used to store any additional data about the node, such as data used for handling postback events. 
	Value  = nil,
	-- some predefined type, it only takes effect if one chooses to use the default draw node handler provided by this class
	-- nil, "Title", "separator"
	Type = nil,
	-- Gets or sets the object that contains data about the tree node. 
	Tag = nil,
	-- Gets or sets the text that appears when the mouse pointer hovers over a TreeNode. 
	ToolTipText = nil,
	-- icon texture file
	Icon = nil,
	-- if false or nil, it will leave a white space for the Icon (even the icon is nil).
	bSkipIconSpace = nil,
	-- Gets or sets the key for the image associated with this tree node when the node is in an unselected state. 
	-- this can be a index which index into TreeView.ImageList[ImageKey] or it can be a string of image file path or URL.
	ImageKey = nil,
	-- Gets or sets the key of the image displayed in the tree node when it is in a selected state.
	-- this can be a index which index into TreeView.ImageList[ImageKey] or it can be a string of image file path or URL.
	SelectedImageKey = nil,  
	-- Height of this tree node, if this is nil, TreeView.DefaultNodeHeight will be used
	NodeHeight = nil,
	-- Width of this tree node, if this is nil, TreeView.DefaultNodeWidth will be used
	NodeWidth = nil,
	-- padding of this tree node. if this is nil, TreeView.DefaultNodePadding will be used
	NodePadding = nil,
	-- how many items to display per row, this is set if one wants to display multiple items on the same row. with a fixed width. Usually the width is specified by NodeWidth,
	ItemsPerRow = nil,
	-- string to be executed or a function of format function FuncName(treeNode) end
	onclick = nil,
	-- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- if DrawNodeHandler is nil, and the treenode's DrawNodeHandler is also nil, the default TreeView.DrawNormalNodeHandler function will be used. 
	DrawNodeHandler = nil,
	--------------------------------
	-- internal parameters, do not use externally
	--------------------------------
	-- logical position of the node relative to the tree view container. 
	LogicalX = 0,
	LogicalY = 0,
	-- logical position for the right bottom corner of this node and all its children
	LogicalRight = nil,
	LogicalBottom = 0,
	-- internal index of this node. such that self.parent[self.index] is self. 
	index = 0,
	-- render line index
	lineindex = 0,
	
}
CommonCtrl.TreeNode = TreeNode;

-- constructor
function TreeNode:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Get child count
function TreeNode:GetChildCount()
	return table.getn(self.Nodes);
end
-- get child by index. index is 1 based. 
function TreeNode:GetChild(index)
	return self.Nodes[index];
end

-- Clear all child nodes
function TreeNode:ClearAllChildren()
	self.Nodes = {}
end

-- resize of the number of first level childs. This function only delete child, but never add child if current child count is smaller than nCount. 
function TreeNode:Resize(nCount)
	if(self:GetChildCount()>nCount) then
		commonlib.resize(self.Nodes, nCount);
	end	
end

-- swap two child objects at the given index. this is used when sorting child nodes. 
function TreeNode:SwapChildNodes(index1, index2)
	local node1 = self.Nodes[index1]
	local node2 = self.Nodes[index2]
	if(index1 ~= index2 and node1~=nil and node2~=nil) then
		node1.index, node2.index = index2, index1;
		self.Nodes[index1], self.Nodes[index2] = node2, node1;
	end
end

-- a default compare function. this is equavalaent to TreeNode.GenerateCFByField("Text")
function TreeNode.CompareNodeByText(node1, node2)
	if(node1.Text == nil) then
		return true
	elseif(node2.Text == nil) then
		return false
	else
		return node1.Text < node2.Text;
	end	
end

-- generate a less compare function according to a node field name. 
-- @param fieldName: the name of the field, such as "Text", "Name", etc
function TreeNode.GenerateLessCFByField(fieldName)
	fieldName = fieldName or "Text";
	return function(node1, node2)
		if(node1[fieldName] == nil) then
			return true
		elseif(node2[fieldName] == nil) then
			return false
		else
			return node1[fieldName] < node2[fieldName];
		end	
	end
end

-- generate a greater compare function according to a node field name. 
-- @param fieldName: the name of the field, such as "Text", "Name", etc
function TreeNode.GenerateGreaterCFByField(fieldName)
	fieldName = fieldName or "Text";
	return function(node1, node2)
		if(node2[fieldName] == nil) then
			return true
		elseif(node1[fieldName] == nil) then
			return false
		else
			return node1[fieldName] > node2[fieldName];
		end	
	end
end

-- sorting the children according to a compare function. Internally it uses table.sort().
-- compareFunc: if nil, it will compare by Node.Text. 
--   One can also build a compare function by calling TreeNode.GenerateLessCFByField(fieldName) or TreeNode.GenerateGreaterCFByField(fieldName)
function TreeNode:SortChildren(compareFunc)
	compareFunc = compareFunc or CommonCtrl.TreeNode.GenerateLessCFByField("Text");
	-- quick sort
	table.sort(self.Nodes, compareFunc)
	-- rebuild index. 
	local i, node
	for i,node in ipairs(self.Nodes) do
		node.index = i;
	end
end

-- Add a new child node, the child node is returned
-- @param o: it can be a tree node object such as using CommonCtrl.TreeNode:new() or just a string.
-- @param index: nil or index at which to insert the object. if nil, it will inserted to the last element. if 1, it will inserted to the first element.
function TreeNode:AddChild(o, index)
	if(type(o) == "string") then
		o = CommonCtrl.TreeNode:new({Text = o});
	end
	if(type(o) == "table") then
		local nodes = self.Nodes;
		local nSize = table.getn(nodes);
		if(index == nil or index>nSize or index<=0) then
			-- add to the end
			nodes[nSize+1] = o;
			o.index = nSize+1;
		else
			-- insert to the mid
			local i=nSize+1;
			while (i>index) do 
				nodes[i] = nodes[i-1];
				nodes[i].index = i;
				i = i - 1;
			end
			nodes[index] = o;
			o.index = index;
		end	
		-- for parent
		o.parent = self;
		o.TreeView = self.TreeView;
		o.Level = self.Level+1;
		--log(o.index.." added as "..tostring(o.Text).."\n")
		return o;
	end	
end

-- added by Andy 2008/12/21
-- remove all occurance of first level child node whose index is index
function TreeNode:RemoveChildByIndex(index)
	local nodes = self.Nodes;
	local nSize = table.getn(nodes);
	local i, node;
	
	if(nSize == 1) then
		nodes[1] = nil;
		return;
	end
	
	if(index < nSize) then
		local k;
		for k = index + 1, nSize do
			node = nodes[k];
			nodes[k-1] = node;
			if(node ~= nil) then
				node.index = k - 1;
				nodes[k] = nil;
			end	
		end
	else
		nodes[index] = nil;
	end	
end

-- remove all occurance of first level child node whose name is name
function TreeNode:RemoveChildByName(name)
	local nodes = self.Nodes;
	local nSize = table.getn(nodes);
	local i, node;
	
	if(nSize == 1) then
		nodes[1] = nil;
		return;
	end
	
	for i=1, nSize do
		node = nodes[i];
		if(node~=nil and name == node.Name) then
			if(i<nSize) then
				local k;
				for k=i+1, nSize do
					node = nodes[k];
					nodes[k-1] = node;
					if(node~=nil) then
						node.index = k-1;
						nodes[k] = nil;
					end	
				end
			else
				nodes[i] = nil;
			end	
		end
	end
end

-- detach this node from its parent node. 
function TreeNode:Detach()
	local parentNode = self.parent
	if(parentNode == nil) then
		return
	end
	
	local nSize = table.getn(parentNode.Nodes);
	local i, node;
	
	if(nSize == 1) then
		parentNode.Nodes[1] = nil;
		return;
	end
	
	local i = self.index;
	local node;
	if(i<nSize) then
		local k;
		for k=i+1, nSize do
			node = parentNode.Nodes[k];
			parentNode.Nodes[k-1] = node;
			if(node~=nil) then
				node.index = k-1;
				parentNode.Nodes[k] = nil;
			end	
		end
	else
		parentNode.Nodes[i] = nil;
	end	
end

-- get the first occurance of first level child node whose name is name
function TreeNode:GetChildByName(name)
	local nodes = self.Nodes;
	local nSize = table.getn(nodes);
	local i, node;
	for i=1, nSize do
		node = nodes[i];
		if(node~=nil and name == node.Name) then
			return node;
		end
	end
end

-- get the first occurance of the child node whose name is name. It will recursively search child nodes. 
-- Note: we do not guarantee that all child nodes have a unique name
-- @param: a string containing the node name path, separated by #,  such as "RootNode#ChildNode#SubNode".
--	usually a value returned by the node:GetNodeNamePath(). 
function TreeNode:GetChildByNamePath(name)
	if(not name) then return end
	local node = self;
	local childname;
	for childname in string.gfind(name,"[^#]+") do
		node = node:GetChildByName(childname);
		if(node==nil) then
			break;
		end
	end
	return node;
end

-- get the first occurance of first level child node whose text is text
function TreeNode:GetChildByText(Text)
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil and Text == node.Text) then
			return node;
		end
	end
end

-- create a new sub control name: reuse control names as much as possible while ensuring that all visible control names are unique. 
function TreeNode:NewSubControlName()
	local name = CommonCtrl.NewSubControlName(self.TreeView);
	self._subnames = self._subnames or {};
	self._subnames[name] = true;
	return name;
end

-- delete all sub controls, whose name is created by TreeNode.NewSubControlName. 
function TreeNode:DeleteAllSubControls()
	if(self._subnames) then
		local name, v;
		for name, v in pairs(self._subnames) do
			CommonCtrl.ReleaseSubControlName(self.TreeView, name);
		end
		self._subnames = nil;
	end
end


-- Expands the current tree node.  
function TreeNode:Expand()
	self.Expanded = true;
end

-- Expands the current node and all its child nodes.  
function TreeNode:ExpandAll()
	self:Expand();
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:ExpandAll();
		end
	end
end

-- Collapses the current tree node.  
function TreeNode:Collapse()
	self.Expanded = false;
end  

-- Collapses the current node and all its child nodes.
function TreeNode:CollapseAll()
	self:Collapse();
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:CollapseAll();
		end
	end
end  

function TreeNode:GetHeight()
	return self.NodeHeight or self.TreeView.DefaultNodeHeight;
end

-- if return nil, we will use the entire client width
function TreeNode:GetWidth()
	return self.NodeWidth or self.TreeView.DefaultNodeWidth;
end

function TreeNode:GetPadding()
	return self.NodePadding or self.TreeView.DefaultNodePadding;
end

-- private: call the onclick function if any. 
function TreeNode:OnClickNode()
	-- call the event handler if any
	if(self.onclick~=nil)then
		if(type(self.onclick) == "string") then
			NPL.DoString(self.onclick);
		else
			self.onclick(self);
		end
	elseif(self.TreeView.onclick~=nil)then
		self.TreeView.onclick(self);
	end
end

-- select this tree node, but it does not invoke the onclick method on the node. 
-- @param bUpdateUI: if true, the entire treeview is updated. 
function TreeNode:SelectMe(bUpdateUI)
	if(self.TreeView.SelectedNode~=self) then
		if(self.TreeView.SelectedNode~=nil) then
			self.TreeView.SelectedNode.Selected = nil;
			if(self.TreeView.SelectedNode.UnselectedNodeHeight) then
				self.TreeView.SelectedNode.NodeHeight = self.TreeView.SelectedNode.UnselectedNodeHeight;
			end
		end	
	end
	self.Selected = true;
	if(self.SelectedNodeHeight) then
		self.NodeHeight = self.SelectedNodeHeight;
	end
	
	self.TreeView.SelectedNode = self;
	if(bUpdateUI) then
		-- update view
		self.TreeView:Update(nil, self);
	end
end

-- after the content of a tree node is changed, one may need to call this function at the root node
-- @param x,y: logical position 
-- @return: logical position for the sibling node 
function TreeNode:Update(x, y)
	self.LogicalX = x;
	self.LogicalY = y;
	if(not self.Invisible) then
		--log(self:GetNodePath()..", "..y.."\n")
		if(not self.ItemsPerRow or self.ItemsPerRow ==1) then
			y = y + self:GetHeight();
			if(self.Expanded) then
				local nSize = table.getn(self.Nodes);
				local i, node;
				for i=1, nSize do
					node = self.Nodes[i];
					if(node ~=nil) then
						x,y = node:Update(self.LogicalX, y);
					end
				end
			end
			x = self.LogicalX;
		else
			y = y + self:GetHeight();
			
			if(self.Expanded) then
				local nSize = table.getn(self.Nodes);
				local i, node, new_x, new_y;
				local max_height = 0;
				for i=1, nSize do
					node = self.Nodes[i];
					if(node ~=nil) then
						new_x,new_y = node:Update(x, y);
						if(node:GetWidth()) then
							node.LogicalRight = x + node:GetWidth();
						end	
						if(not max_height or max_height<(new_y - y)) then
							max_height = (new_y - y)
						end
						if(((i-1)%self.ItemsPerRow) == (self.ItemsPerRow-1) or i==nSize) then
							x = self.LogicalX;
							y = y + max_height;
							max_height = nil;
						else
							x = node.LogicalRight or x; 
						end
					end
				end
			end	
			x = self.LogicalX;
		end	
	end	
	self.LogicalBottom = y;
	return x,y;
end

-- get a string containing the node path. such as "0/1/1/3"
-- as long as the TreeNode does not change, the node path uniquely identifies a TreeNode.
function TreeNode:GetNodePath()
	local path = tostring(self.index);
	while (self.parent ~=nil) do
		path = self.parent.index.."/"..path;
		self = self.parent;
	end
	return path;
end

-- get a string containing the node name path, separated by #,  such as "RootNode#ChildNode#SubNode"
-- Note: we do not guarantee that all child nodes have a unique name
function TreeNode:GetNodeNamePath()
	local path = tostring(self.Name);
	while (self.parent ~=nil) do
		path = tostring(self.parent.Name).."#"..path;
		self = self.parent;
	end
	return path;
end


-- get the best matched node that contains the logical point x,y. This function is usually called on the root node. it calls recursively.
-- @param x,y: logical position 
-- @return: logical position for the sibling node 
function TreeNode:GetNodeByPoint(x, y)
	if(not self.Invisible) then
		if(y>=self.LogicalY and y<self.LogicalBottom and (not self.LogicalRight or (x<self.LogicalRight and x>self.LogicalX))) then
			local nodeheight = self:GetHeight()
			if(self.Expanded and y>=(self.LogicalY+nodeheight)) then
				local nSize = table.getn(self.Nodes);
				local i, node;
				for i=1, nSize do
					node = self.Nodes[i];
					if(node ~=nil) then
						node = node:GetNodeByPoint(x, y);
						if(node ~=nil) then
							return node;
						end
					end
				end
			end	
			if(nodeheight > 0) then
				return self;
			else
				return self:GetNextNode();
			end	
		end	
	end	
end

-- get the next node in render order. it can be first child node or the sibling node or the sibling of its parent node or nil for last node.
-- @param skipchildren: true to skip child nodes. otherwise nil.
function TreeNode:GetNextNode(skipchildren)
	if(not skipchildren) then
		if(self.Expanded and self.Nodes[1]~=nil) then
			-- first child node
			return self.Nodes[1];
		end
	end
	if(self.parent~=nil) then 
		local node = self.parent.Nodes[self.index +1];
		if(node ~=nil) then
			-- sibling node
			return node;
		else
			-- sibling of its parent node.
			return self.parent:GetNextNode(true);
		end	
	end
	-- last node, so return nil.
end

-- same as GetNextNode(), except that it will not skip expanded node. 
function TreeNode:GetNextNode2(skipchildren)
	if(not skipchildren) then
		if(self.Nodes[1]~=nil) then
			-- first child node
			return self.Nodes[1];
		end
	end
	if(self.parent~=nil) then 
		local node = self.parent.Nodes[self.index +1];
		if(node ~=nil) then
			-- sibling node
			return node;
		else
			-- sibling of its parent node.
			return self.parent:GetNextNode(true);
		end	
	end
	-- last node, so return nil.
end

-- get indentation. If the parent height is 0 the current node will not indent from parent. 
function TreeNode:GetIndentation()
	if(self.parent) then
		if(self.parent:GetHeight()>0) then
			return self.TreeView.DefaultIndentation + self.parent:GetIndentation();
		else
			return self.parent:GetIndentation();
		end	
	else
		return 0;
	end
end