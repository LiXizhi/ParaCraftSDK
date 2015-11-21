--[[
Title: a control that displaying folder/files in grid style with icon and text.
Author(s): LiXizhi
Date: 2008/4/24
Note: a control that displaying folder/files in grid style with icon and text. It can navigate among folders and parent folders. 
It supports lazy rendering for file icons. Please see OnPreRenderNode call back for more infor.
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/FileViewCtrl.lua");
local ctl = CommonCtrl.FileViewCtrl:new{
	name = "FileViewCtrl1",
	alignment = "_lt",left=100, top=50,width = 256,height = 300, 
	parent = _parent,
	rootfolder = "temp",
	filter = "*.png;*.jpg",
	AllowFolderSelection = true,
	--OnSelect = function(filepath) _guihelper.MessageBox(filepath);	end,
	--OnPreRenderNode = function(treeNode, filepath) treeNode.Icon = treeNode.Icon or filepath..".png" end
	OnDoubleClick = nil,
	DefaultNodeHeight = 58,
	DefaultNodeWidth = 64,
	DefaultNodePadding = 1,
	ItemsPerRow = 4,
};
ctl:Show(true);

-- alternatively one can open multiple folders by setting rootfolder to nil and add child nodes as below.
local ctl = CommonCtrl.FileViewCtrl:new{
	name = "FileViewCtrl1",
	alignment = "_lt",left=100, top=50,width = 256,height = 300, 
	parent = _parent,
	rootfolder = nil,
	filter = "*.*",
	--OnSelect = function(filepath) _guihelper.MessageBox(filepath);	end,
	DefaultNodeHeight = 58,
	DefaultNodeWidth = 64,
	DefaultNodePadding = 1,
	ItemsPerRow = 4,
};
-- node.rootfolder property should contain the rootfolder path, you can even add owner draw to these nodes
ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "My documents", rootfolder = "temp"})); 
ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "My worlds", rootfolder = "worlds/", Expanded = false,}));
ctl:Show(true);

ctl:ChangeFolder("model/test")
ctl:ToParentFolder()
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/Encoding.lua");
NPL.load("(gl)script/ide/TreeView.lua");

local FileViewCtrl = commonlib.inherit(CommonCtrl.TreeView, {
	name = "FileViewCtrl1",
	-- appearance
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 500,
	height = 500, 
	parent = nil,
	container_bg = nil,
	-- default item height
	FolderOpenIcon = nil,
	FolderIcon = "Texture/3DMapSystem/Creator/Objects/folder_big.png",
	FolderBackward = "Texture/3DMapSystem/Creator/Objects/rotateL.png",
	DefaultFileIcon = "Texture/3DMapSystem/Creator/Objects/Properties.png",
	-- background image to display when an item is selected
	SelectedBG = "Texture/alphadot.png",
	
	DefaultNodeHeight = 58,
	DefaultNodeWidth = 64,
	DefaultNodePadding = 1,
	DefaultIconSize = 32,
	ItemsPerRow = 4,
	
	-- default is FileViewCtrl.DrawNormalNodeHandler
	DrawNodeHandler = nil,
	
	-- parameters --
	
	-- initial root folder name, such as "temp", "script/test",
	-- if this is nil, the first level children of rootNode will be expanded as child node. 
	-- The childNode.Name should contain the rootfolder instead. One can also implement owner draw function 
	-- for the first level root, such as in the open file dialog.
	rootfolder = nil,
	
	-- the files to be displayed, such as ".*", ".jpg;*.x". if nil, only folder will be displayed.
	filter = nil,
	-- boolean: whether allow folder selection. if true, a folder node can be selected and select event is fired
	AllowFolderSelection = true,
	-- boolean: if true, folder can not be expanded, otherwise it can. 
	DisableFolderExpand = nil,
	-- boolean: if true, folder will be hidden. However if self.filter contains folder, they will be displayed anyway.
	HideFolder = nil,
	-- whether to show file name in additional to icon. 
	ShowFileName = true,
	-- whether to display file extension
	ShowFileExtension = false,
	-- if true, the first folder item will be "../". when it is clicked. only used when HideFolder is false. 
	ShowUpFolder = true,
	-- max number of items per folder
	MaxItemPerFolder = 3000,
	-- currently selected folder path
	SelectedPath = nil,
	
	-- event --
	-- called when user click on a folder or file item. it is a string or a function(filepath) end
	OnSelect = nil,
	-- called when user double clicked on an file item. it is a string or a function(filepath) end
	OnDoubleClick = nil,
	-- called when user checks or unchecks a folder or file item. it is a function(treeNode, filepath, Checked) end
	OnCheck = nil,
	-- called when a new folder or file node is added. it is a function(treeNode, filepath) end
	-- usually one can alter the Text, Icon, TextColor property of the created treeNode according to treeNode.Name
	OnCreateNode = nil,
	-- called whenever a new node is about to be rendered. it is a function(treeNode, filepath) end
	-- usually lazy load(specify) its Icon property the treeNode according to treeNode.Name
	OnPreRenderNode = nil,
	
	-- private
	selectedNodePath = nil,
	treeViewName = nil,
	folderlevel = 0,
	-- max number of sub folders to search if rootfolder is in "folder/*" format
	maxDepthSearch = 5,
})
CommonCtrl.FileViewCtrl = FileViewCtrl;

-- Destroy the UI control
function FileViewCtrl:Destroy ()
	ParaUI.Destroy(self.name);
end

---------------------------
-- public functions: 
---------------------------

-- display control.
function FileViewCtrl:Show(bShow)
	CommonCtrl.TreeView.Show(self, bShow)
	self:ChangeFolder(self.rootfolder, true)
end

-- navigate to the parent folder
function FileViewCtrl:ToParentFolder()
	if(self.rootfolder and self.folderlevel>0 and string.find(self.rootfolder, "/.+$")) then
		self.rootfolder = string.gsub(self.rootfolder, "/[^/]+$", "");
		self.folderlevel = self.folderlevel - 1;
		self:ResetTreeView();
	end	
end

-- navigate to a given root folder. 
-- @param rootfolder: it can be "/"(root directory), "model", "model/test", or "model/test/*" (search recursively for all sub folders) or multiple folders "model/test/*;character/test/*"
-- @param bForceRefresh: if true, it will refresh, even rootfolder is not changed. 
function FileViewCtrl:ChangeFolder(rootfolder,bForceRefresh)
	if(bForceRefresh or self.rootfolder ~= rootfolder or self.folderlevel~=0) then
		if(string.find(rootfolder, "[%*;]")) then
			self.RootNode:ClearAllChildren();
			self.rootfolder = nil;
			local folder;
			for folder in string.gfind(rootfolder, "[^;]+") do
				self.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = commonlib.Encoding.DefaultToUtf8(folder), rootfolder = folder, IsCategory = true, NodeHeight=20})); 
			end
		else
			self.rootfolder = rootfolder;	
		end
		self.folderlevel = 0;
		self:ResetTreeView();
	end
end

-- return the current folder
function FileViewCtrl:GetCurrentFolder()
	return self.rootfolder;
end

---------------------------
-- private functions: 
---------------------------

-- get node file path. 
function  FileViewCtrl:GetNodeNamePath(node)
	if(node==nil)then return; end
	local path = tostring(node.Name);
	while (node.parent ~=nil and node.rootfolder==nil) do
		if(node.parent.Name~=nil and  node.parent.Name~= "") then
			path = tostring(node.parent.Name).."/"..path;
		end	
		node = node.parent;
	end
	return path;
end

-- cononicalize root folder
function FileViewCtrl.ValidateFolderRootNode(node)
	if(node.rootfolder) then
		node.rootfolder = string.gsub(node.rootfolder, "\\", "/")
		node.rootfolder = string.gsub(node.rootfolder, "^/", "")
		node.rootfolder = string.gsub(node.rootfolder, "/$", "")
		node.Name = string.gsub(node.rootfolder, "/?%*?$", "");
		node.IsFolder = true;
	end	
end

-- rebuild tree view for the current root directory.
function FileViewCtrl:ResetTreeView()
	local node = self.RootNode;
	
	if(self.rootfolder ~= nil) then
		node:ClearAllChildren();
		node.rootfolder = self.rootfolder;
		node.ItemsPerRow = self.ItemsPerRow;
		-- cononicalize root folder;
		FileViewCtrl.ValidateFolderRootNode(node)
		node.Expanded = true;
		self:RefreshNode(node);
		
		self:Update();
	else
		node.ItemsPerRow = 1;
		local nSize = #(node.Nodes);
		local i, childNode;
		for i=1, nSize do
			childNode = node.Nodes[i];
			if(childNode and childNode.rootfolder) then
				if(childNode.IsFolder == nil) then
					childNode.IsFolder = true;
				end	
				if(childNode.IsFolder) then
					childNode.ItemsPerRow = self.ItemsPerRow;
					FileViewCtrl.ValidateFolderRootNode(childNode)
					childNode:ClearAllChildren();
					if(childNode.Expanded) then
						self:RefreshNode(childNode);
					end	
				end	
			end
		end
		self:Update();
	end	
end

-- refresh the node according to its folder path. It will automatically add the first level child if any. 
function FileViewCtrl:RefreshNode(node)
	if(node.IsFolder) then
		-- clear this node
		node:ClearAllChildren();
		
		local folderPath = node.rootfolder or self:GetNodeNamePath(node);
		
		local nMaxSubFolderLevel = 0;
		if(string.find(folderPath, "%*$")) then
			-- we need to search recursively
			nMaxSubFolderLevel = self.maxDepthSearch;
			folderPath = string.gsub(folderPath, "%*$", "");
		end
		
		-- add folders
		if (nMaxSubFolderLevel==0 and not self.HideFolder) then
			if (self.ShowUpFolder and self.folderlevel>0) then
				local path = "../"
				local childNode = node:AddChild( CommonCtrl.TreeNode:new({IsFolder = true, ItemsPerRow=self.ItemsPerRow, Text=path,Name = path, Expanded = false}));
				if(type(self.OnCreateNode)=="function" and childNode) then
					self.OnCreateNode(childNode, self:GetNodeNamePath(childNode))
				end
			end
			
			local output = FileViewCtrl.SearchFiles(nil, folderPath,self.MaxItemPerFolder);
			if(output and #output>0) then
				local _, path;
				for _, path in ipairs(output) do
					local childNode = node:AddChild( CommonCtrl.TreeNode:new({IsFolder = true, ItemsPerRow=self.ItemsPerRow, Text=commonlib.Encoding.DefaultToUtf8(path),Name = path, Expanded = false }));
					if(type(self.OnCreateNode)=="function" and childNode) then
						self.OnCreateNode(childNode, self:GetNodeNamePath(childNode))
					end
				end
			end
		end	
		
		-- add files
		if(self.filter~=nil and self.filter~="")then
			-- add files, but exclude folders. 
			local filter;
			local output = {};
			for filter in string.gfind(self.filter, "([^%s;]+)") do
				FileViewCtrl.SearchFiles(output, folderPath,self.MaxItemPerFolder, filter, nMaxSubFolderLevel);
			end
			if(#output>0) then
				-- sort output by name
				table.sort(output, function(a, b)
					return (a < b)
				end)
				
				local _, path;
				for _, path in ipairs(output) do
					if(string.find(path,"%.") or self.HideFolder) then
						-- we will skip folders since they are already added.
						local childNode = node:AddChild( CommonCtrl.TreeNode:new({Text=commonlib.Encoding.DefaultToUtf8(path),Name = path, }));
						if(type(self.OnCreateNode)=="function" and childNode) then
							self.OnCreateNode(childNode, self:GetNodeNamePath(childNode))
						end
					end	
				end
			end
		end
	else
		node:ClearAllChildren();	
	end	
end

-- get the icon path for a given file name
function FileViewCtrl:GetIcon(filename)
	if(filename) then
		local _, _, fileExtension = string.find(filename, "%.(.+)$");
		return self.Icons[string.lower(fileExtension or "none")] or self.Icons["unknown"];
	end	
end

-- only return the sub folders of the current folder
-- @param rootfolder: the folder which will be searched.
-- @param nMaxFilesNum: one can limit the total number of files in the search result. Default value is 50. the search will stop at this value even there are more matching files.
-- @param filter: if nil, it defaults to "*."
-- @param nMaxSubFolderLevel: max folder level
-- @return a table array containing relative to rootfolder file name.
function FileViewCtrl.SearchFiles(output, rootfolder,nMaxFilesNum, filter, nMaxSubFolderLevel)
	if(rootfolder == nil) then return; end
	if(filter == nil) then filter = "*." end
	
	output = output or {};
	local sInitDir = ParaIO.GetCurDirectory(0)..rootfolder.."/";
	local search_result = ParaIO.SearchFiles(sInitDir,filter, "", nMaxSubFolderLevel or 0, nMaxFilesNum or 50, 0);
		local nCount = search_result:GetNumOfResult();		
		local nextIndex = #output+1;
		local i;
		for i = 0, nCount-1 do 
			output[nextIndex] = search_result:GetItem(i);
			nextIndex = nextIndex + 1;
		end
		search_result:Release();
	return output;	
end

-- owner draw function of treeview
function FileViewCtrl.DrawNormalNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode:GetWidth();
	local nodePadding = treeNode:GetPadding();
	local iconSize = treeNode.TreeView.DefaultIconSize;
	local filepath = treeNode.TreeView:GetNodeNamePath(treeNode);
	local filepathText = commonlib.Encoding.DefaultToUtf8(filepath);
	local filenameText = string.gsub(filepathText, ".*/", "");
	if(not treeNode.TreeView.ShowFileExtension) then
		filenameText = string.gsub(filenameText, "%.%w+$", "");
	end
	
	if(type(treeNode.TreeView.OnPreRenderNode)=="function" and treeNode) then
		treeNode.TreeView.OnPreRenderNode(treeNode, filepath)
	end

	if(treeNode.IsCategory) then
		--
		-- category folder node
		--
		_this=ParaUI.CreateUIObject("text","s","_lt", nodePadding+2, nodePadding, treeNode.TreeView.ClientWidth-nodePadding*2, height-nodePadding*2);
		_this.text = treeNode.Text;
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","s","_lt", nodePadding, height-nodePadding-2, treeNode.TreeView.ClientWidth-nodePadding*2, 2);
		_this.background = "Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "150 150 150 255");
		_parent:AddChild(_this);
	else
		if(treeNode.IsFolder) then
			--
			-- folder node
			--
			-- cross expand icon
			_this=ParaUI.CreateUIObject("button","b","_lt", (nodeWidth-iconSize)/2, nodePadding, iconSize, iconSize);
			_this.tooltip = filepathText;
			_parent:AddChild(_this);
			if(treeNode.Icon) then
				_this.background = treeNode.Icon;
			elseif(treeNode.Name == "../")then
				_this.background = treeNode.TreeView.FolderBackward or treeNode.TreeView.FolderIcon;
			elseif(treeNode.Expanded) then
				_this.background = treeNode.TreeView.FolderIcon;
			else
				_this.background = treeNode.TreeView.FolderOpenIcon or treeNode.TreeView.FolderIcon;
			end
			_this.onclick = string.format(";CommonCtrl.FileViewCtrl.OnClick(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			
		else
			--
			-- file node
			--
			_this=ParaUI.CreateUIObject("button","b","_lt", (nodeWidth-iconSize)/2, nodePadding, iconSize, iconSize);
			_this.tooltip = filepathText;
			_parent:AddChild(_this);
			_this.background =  treeNode.Icon or treeNode.TreeView.DefaultFileIcon;
			_this.onclick = string.format(";CommonCtrl.FileViewCtrl.OnClick(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		end
		
		if(treeNode.TreeView.ShowFileName) then	
			_this=ParaUI.CreateUIObject("button","b","_lt", nodePadding, nodePadding+iconSize, nodeWidth-nodePadding*2, height-iconSize-nodePadding*2);
			_this.background = "";
			local displayText = _guihelper.AutoTrimTextByWidth(filenameText, nodeWidth-nodePadding*2)
			if(displayText == filenameText) then
				_this.text = filenameText
			else
				_this.text = string.sub(displayText, 1, string.len(displayText)-3).."...";
			end	
			_this.tooltip = filepathText;
			_this.onclick = string.format(";CommonCtrl.FileViewCtrl.OnClick(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
		end
	end	
	
	if(treeNode.Selected) then
		_parent.background = treeNode.TreeView.SelectedBG;
	else
		_parent.background = "";
	end
end
FileViewCtrl.DrawNodeHandler = FileViewCtrl.DrawNormalNodeHandler;

----------------------------------------
-- event handlers: 
----------------------------------------

-- event handler: user clicks a node
function FileViewCtrl.OnClick(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(self) then
		self:ClickNode(node);
	end	
end

-- this function can be called from outside
function FileViewCtrl:ClickNode(node)
	if(node) then
		local bIsDoubleClick
		if(FileViewCtrl.LastClickTime == nil) then FileViewCtrl.LastClickTime = ParaGlobal.timeGetTime() end
		-- note: this timer is not very accurate, since onclick event is not fired immediately when user clicks.
		-- but anyway, we will set the double click interval to be 1/4 second. 
		if((ParaGlobal.timeGetTime()-FileViewCtrl.LastClickTime)<250) then
			if(node == self.LastClickedNode) then
				bIsDoubleClick = true
			end	
		end	
		FileViewCtrl.LastClickTime = ParaGlobal.timeGetTime();
		self.LastClickedNode = node;
		
		local CanSelect;
		if(node.IsFolder) then
			if(self.AllowFolderSelection) then
				CanSelect = true
				if(bIsDoubleClick and not self.DisableFolderExpand) then
					local new_folder = self:GetValue();
					if(new_folder) then
						if(node.Name == "../") then
							self:ToParentFolder();
						else
							local count = 1;
							for _ in string.gfind(node.Name, "/\\") do
								count = count+1;
							end
							-- go to the sub folder
							self.folderlevel = self.folderlevel + count;
							self.rootfolder = self:GetNodeNamePath(node);
							self:ResetTreeView();
						end
						return;
					end	
				end
			end	
		else
			CanSelect = true;
		end	
		if(CanSelect) then
			if(not bIsDoubleClick) then
				node:SelectMe(true);
			end	
			self.SelectedPath = self:GetNodeNamePath(node);
			
			-- call the user script. 
			if(not bIsDoubleClick) then
				if(type(self.OnSelect) == "function") then
					self.OnSelect(self:GetValue());
				elseif(type(self.OnSelect) == "string") then
					NPL.DoString(self.OnSelect);
				end
			else
				if(type(self.OnDoubleClick) == "function") then
					self.OnDoubleClick(self:GetValue());
				elseif(type(self.OnDoubleClick) == "string") then
					NPL.DoString(self.OnDoubleClick);
				end
			end	
		end	
	end
end

----------------------------------------
-- public functions: 
----------------------------------------
-- get the current file path
function FileViewCtrl:GetValue()
	return self.SelectedPath
end

-- get the current file path
function FileViewCtrl:GetText()
	return self:GetValue();
end


