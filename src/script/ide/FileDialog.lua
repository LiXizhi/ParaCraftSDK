--[[
Title: File and directory listing common control (dialog)
Author(s): LiXizhi
Date: 2006/3/6
Revised: 2007/9/24
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/FileDialog.lua");
local ctl = CommonCtrl.GetControl("FileTreeView1");
if(ctl==nil)then
	local ctl = CommonCtrl.FileTreeView:new{
		name = "FileTreeView1",
		alignment = "_lt",
		left=0, top=0,
		width = 200,
		height = 200,
		parent = nil,
		-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
		DrawNodeHandler = nil,
		sInitDir = "temp/",
		sFilePattern = "*.*",
		nMaxFileLevels = 0,
		nMaxNumFiles = 300,
	};
else
	ctl.sInitDir = "temp/";
	ctl.sFilePattern = "*.*";
	ctl:SetModified(true);	
end	
ctl:Refresh();
ctl.RootNode:CollapseAll();
ctl.RootNode:Expand(); -- only show first level
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/TreeView.lua");

-- default member attributes
local FileTreeView = {
	-- the top level control name
	name = "FileTreeView1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 400, 
	-- the background of container
	container_bg = nil, 
	-- The root tree node. containing all tree node data
	RootNode = nil, 
	-- Default height of Tree Node
	DefaultNodeHeight = 24,
	-- default indentation
	DefaultIndentation = 10,
	-- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- if DrawNode is nil, the default FileTreeView.DrawFileItemHandler function will be used. 
	DrawNodeHandler = nil,
	-- Force no clipping or always using fast render. Unless you know that the unit scroll step is interger times of all TreeNode height. You can disable clipping at your own risk. 
	-- Software clipping is always used to clip all invisible TreeNodes. However, this option allows you to specify whether to use clipping for partially visible TreeNode. 
	NoClipping = nil,
	-- a function of type function (MenuItem, nodepathString) or nil. this function will be called for each menuitem onclick except the group node.
	onclick = nil,
	
	-- the initial directory. 
	sInitDir = "",
	-- e.g."*.", "*.x" or it could be table like {"*.lua", "*.raw"}
	sFilePattern = "*.*",
	-- max file levels. 0 shows files in the current directory.
	nMaxFileLevels = 3,
	-- max number of files in file listbox. e.g. 150
	nMaxNumFiles = 300,
	-- currently selected file path. 
	SelectedFilePath = "",
	-------------------------------------------
	-- private functions
	-------------------------------------------
	IsModified = true,
}
CommonCtrl.FileTreeView = FileTreeView;

-- constructor
function FileTreeView:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- use default draw function if user does not provide one. 
	if(not o.DrawNodeHandler) then
		o.DrawNodeHandler = self.DrawFileItemHandler
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
	};
	o.RootNode = ctl.RootNode;

	CommonCtrl.AddControl(o.name, o);
	
	return o
end

-- Destroy the UI control
function FileTreeView:Destroy ()
	ParaUI.Destroy(self.name);
end

-- return the node path of the input node. directory is separated by '/'
function FileTreeView.GetNodePath(node)
	local path;
	while(node~= nil) do
		if(node.parent~=nil and node.Text~=nil) then
			if(path == nil) then
				path = node.Text;
			else
				path = node.Text.."/"..path;
			end	
		end	
		node = node.parent;
	end
	return path;
end

-- @param node: to which node the filepath is attached. It will create child node if necessary. this function is recursive.
-- @param filepath: file name to add.
function FileTreeView.AddNewFile(node, filepath)
	local _from, _to, name, next = string.find(filepath, "([^/]+)/(.*)$");
	if(_from == nil) then
		name = filepath;
	end
	local NewNode;
	if(name~=nil) then
		NewNode = node:GetChildByText(name);
		if(not NewNode )then
			NewNode = node:AddChild(name);
		end
	end	
	if(NewNode~=nil and next~=nil and next~="") then
		CommonCtrl.FileTreeView.AddNewFile(NewNode, next);
	end
end

function FileTreeView.RefreshNode(Node, sInitDir, sFilePattern, nMaxFileLevels, nMaxNumFiles)
	-- list all files in the initial directory.
	local search_result = ParaIO.SearchFiles(sInitDir,sFilePattern, "", nMaxFileLevels, nMaxNumFiles, 0);
	local nCount = search_result:GetNumOfResult();
	local i;
	for i = 0, nCount-1 do 
		CommonCtrl.FileTreeView.AddNewFile(Node, search_result:GetItem(i))
	end
	search_result:Release();
end
	
-- refresh the directory data, but does not update UI.
function FileTreeView:Refresh()
	self.RootNode:ClearAllChildren();
	if(type(self.sFilePattern) == "table")then
		local i, sValue;
		for i, sValue in ipairs(self.sFilePattern) do
			CommonCtrl.FileTreeView.RefreshNode(self.RootNode, self.sInitDir, sValue, self.nMaxFileLevels, self.nMaxNumFiles);
		end
	else
		CommonCtrl.FileTreeView.RefreshNode(self.RootNode, self.sInitDir, self.sFilePattern, self.nMaxFileLevels, self.nMaxNumFiles);
	end

	self:SetModified(true);
end

-- set modified, always call this function after you have changed the menu items. 
-- this will cause the content menu to redraw next time it shows up. 
function FileTreeView:SetModified(bModified)
	self.IsModified = bModified;
end

-- set modified, always call this function after you have changed the menu items. 
-- this will cause the content menu to redraw next time it shows up. 
function FileTreeView:GetSelectedFilePath()
	return self.SelectedFilePath;
end

--[[ display the file treeview control ]]
function FileTreeView:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("FileTreeView instance name can not be nil\r\n");
		return
	end
	
	local ctl = CommonCtrl.GetControl(self.name.."TreeView");
	if(ctl==nil)then
		log("FileTreeView instance's treeview is nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		-- create the container if it has never been created before.
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png";
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		ctl.parent = _parent;
		ctl:Show(true);
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
	
	-- update the inner treeview control if it has been modified. 
	if(self.IsModified) then
		ctl:Update();
		self.IsModified = false;
	end
end

-- private function: called by default TreeNode UI
function FileTreeView.OnToggleNode(sCtrlName, nodePath)
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
		node.TreeView:Update();
	end
end

-- private function: called by default TreeNode UI
function FileTreeView.OnClickNode(sCtrlName, nodePath)
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
				node.onclick(node, CommonCtrl.FileTreeView.GetNodePath(node));
			end
		end
		self = CommonCtrl.GetControl(string.gsub(sCtrlName, "TreeView$", ""));
		if(self==nil)then
			log("error getting contextMenu instance from "..sCtrlName.."\r\n");
			return;
		end
		if(self.onclick~=nil)then
			self.onclick(node, CommonCtrl.FileTreeView.GetNodePath(node));
		end
	end
end

-- default node renderer: it display a clickable check box for expandable node, followed by node text
function FileTreeView.DrawFileItemHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation*treeNode.Level; -- indentation of this node. 
	local top = 2;
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	-- Test code: just for testing. remove this line
	--_parent.background = "Texture/whitedot.png"; _guihelper.SetUIColor(_parent, "0 0 100 60");
	
	if(treeNode:GetChildCount() > 0) then
		-- node that contains children. We shall display some
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , 20, 20);
		_this.onclick = string.format(";CommonCtrl.FileTreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + 22;
		
		if(treeNode.Expanded) then
			_this.text = "-";
		else
			_this.text = "+";
		end
		
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , nodeWidth - left-1, 18);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.FileTreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.text = treeNode.Text;
		
	elseif(treeNode.Text ~= nil) then
		-- node that text. We shall display text
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , nodeWidth - left-1, 18);
		_parent:AddChild(_this);
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.FileTreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.text = treeNode.Text;
	end
end


--[[ Initializes a set UI objects for directory and file listing.
Users can override the default behaviors of the UI controls. the Default behavior is this:
	listbox_dir shows directories, and is initialized to display sub directories of sInitDir.
	single click an item will display files in that directory in listbox_file.
	double click an item will display sub directories in listbox_dir.
@param sInitDir: the initial directory. 
@param sFilePattern: e.g."*.", "*.x" or it could be table like {"*.lua", "*.raw"}
@param nMaxFileLevels: max file levels. 0 shows files in the current directory.
@param nMaxNumFiles: max number of files in file listbox. e.g. 150
@param listbox_file: a valid ParaUIObject of type listbox for file listing. This can be nil. 
@param listbox_dir: a valid ParaUIObject of type listbox for directory listing. This can be nil. 
@param btn_dir_uplevel: a valid ParaUIObject of type button for displaying the last directory. 
]]
function CommonCtrl.InitFileDialog(sInitDir, sFilePattern, nMaxFileLevels, nMaxNumFiles, listbox_file, listbox_dir, btn_dir_uplevel)
	if(type(sFilePattern) == "table")then
		local i, sValue;
		for i, sValue in ipairs(sFilePattern) do
			CommonCtrl.InitFileDialog(sInitDir, sValue, nMaxFileLevels, nMaxNumFiles, listbox_file, listbox_dir, btn_dir_uplevel);
		end
		return;
	end
	
	if(listbox_file ~=nil) then
		-- list all files in the initial directory.
		local search_result = ParaIO.SearchFiles(sInitDir,sFilePattern, "", nMaxFileLevels, nMaxNumFiles, 0);
		local nCount = search_result:GetNumOfResult();
		local i;
		for i = 0, nCount-1 do 
			listbox_file : AddTextItem(search_result:GetItem(i));
		end
		search_result:Release();
	end
	
	if(listbox_dir ~=nil) then
		-- list all files in the initial directory.
		local search_result = ParaIO.SearchFiles(sInitDir,"*.", "", 0, 300, 0);
		local nCount = search_result:GetNumOfResult();
		local i;
		for i = 0, nCount-1 do 
			listbox_dir:AddTextItem(search_result:GetItem(i));
		end
		search_result:Release();
	end

	if(btn_dir_uplevel ~=nil) then
		
	end
end