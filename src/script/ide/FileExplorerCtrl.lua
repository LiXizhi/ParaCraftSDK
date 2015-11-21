--[[
Title: a control that displaying folder/files using a treeview control
Author(s): LiXizhi
Date: 2008/4/24
Note: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/FileExplorerCtrl.lua");
local ctl = CommonCtrl.FileExplorerCtrl:new{
	name = "FileExplorerCtrl1",
	alignment = "_lt",left=0, top=0,width = 256,height = 300, 
	parent = _parent,
	rootfolder = "temp",
	filter = "*.png;*.jpg",
	AllowFolderSelection = true,
	OnSelect = function(filepath) _guihelper.MessageBox(filepath);	end,
	OnDoubleClick = nil,
};
ctl:Show(true);

-- alternatively one can open multiple folders by setting rootfolder to nil and add child nodes as below.
local ctl = CommonCtrl.FileExplorerCtrl:new{
	name = "FileExplorerCtrl1",
	alignment = "_lt",left=0, top=0,width = 256,height = 300, 
	parent = _parent,
	rootfolder = nil,
	filter = "*.*",
	OnSelect = function(filepath) _guihelper.MessageBox(filepath);	end,
};
-- node.rootfolder property should contain the rootfolder path, you can even add owner draw to these nodes
ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "My documents", rootfolder = "temp"})); 
ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "My worlds", rootfolder = "worlds/", Expanded = false,}));
ctl:Show(true);

ctl:ChangeFolder("model/test")
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/Encoding.lua");
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/TreeView.lua");

local FileExplorerCtrl = commonlib.inherit(CommonCtrl.TreeView, {
	name = "FileExplorerCtrl1",
	-- appearance
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 500,
	height = 500, 
	parent = nil,
	container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
	-- default item height
	DefaultNodeHeight = 22,
	DefaultIndentation = 16,
	FolderOpenIcon = "Texture/3DMapSystem/common/Folder_open.png",
	FolderIcon = "Texture/3DMapSystem/common/Folder.png",
	-- Icon for display file extensions
	Icons = {
		-- file without extension
		["none"]="Texture/3DMapSystem/common/Folder.png", 
		-- unknown file without extension
		["unknown"]="Texture/3DMapSystem/common/page_white.png", 
		-- media files
		["wav"]="Texture/3DMapSystem/common/music.png", 
		["dds"]="Texture/3DMapSystem/common/image.png", 
		["jpg"]="Texture/3DMapSystem/common/image.png", 
		["bmp"]="Texture/3DMapSystem/common/image.png", 
		["png"]="Texture/3DMapSystem/common/image.png", 
		["tga"]="Texture/3DMapSystem/common/image.png",
		["avi"]="Texture/3DMapSystem/common/film.png",
		["flv"]="Texture/3DMapSystem/common/film.png",
		["swf"]="Texture/3DMapSystem/common/film.png",
		["x"]="Texture/3DMapSystem/common/file_parax.png",
		-- modules
		["db"]="Texture/3DMapSystem/common/page_white_database.png",
		["config"]="Texture/3DMapSystem/common/page_white_gear.png",
		["max"]="Texture/3DMapSystem/common/plugin.png",
		["dll"]="Texture/3DMapSystem/common/script_gear.png",
		["exe"]="Texture/3DMapSystem/common/application_xp.png", 
		["zip"]="Texture/3DMapSystem/common/page_white_zip.png", 
		["pkg"]="Texture/3DMapSystem/common/page_white_zip.png", 
		-- script files
		["lua"]="Texture/3DMapSystem/common/script_code_red.png",
		["txt"]="Texture/3DMapSystem/common/page_white_text.png", 
		["xml"]="Texture/3DMapSystem/common/page_code.png", 
		["html"]="Texture/3DMapSystem/common/page_code.png", 
		["c"]="Texture/3DMapSystem/common/page_white_c.png",
		["cpp"]="Texture/3DMapSystem/common/page_white_c.png",
		["h"]="Texture/3DMapSystem/common/page_white_h.png",
		-- open world file
		["worldconfig.txt"]="Texture/3DMapSystem/common/page_world.png",
		["world.zip"]="Texture/3DMapSystem/common/page_world.png",
		["world.pkg"]="Texture/3DMapSystem/common/page_world.png",
	},
	-- only used when CheckBoxes is true, 
	checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/checkbox.png",
	-- only used when CheckBoxes is true, 
	unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/uncheckbox.png",
	-- only used when CheckBoxes is true, 
	checkmixed_bg = "Texture/3DMapSystem/common/ThemeLightBlue/checkbox_mixed.png",
	-- default is FileExplorerCtrl.DrawNormalNodeHandler
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
	AllowFolderSelection = nil,
	-- boolean: if true, folder can not be expanded, otherwise it can. 
	DisableFolderExpand = nil,
	-- boolean: if true, folder will be hidden. However if self.filter contains folder, they will be displayed anyway.
	HideFolder = nil,
	-- max number of items per folder
	MaxItemPerFolder = 300,
	-- currently selected folder path
	SelectedPath = nil,
	-- boolean: Gets or sets a value indicating whether check boxes are displayed next to the tree nodes in the tree view control
	-- A check box is displayed to the left of both the tree node label and tree node Icon, if any. Check boxes allow the user to select more than one tree node at a time
	CheckBoxes=nil,
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
	
	-- private
	selectedNodePath = nil,
	treeViewName = nil,
	
	--记录所有被选中的目录
	CheckedPathList = {},
	
	--已经存在的一个路径列表
	fromTxtPathList = {},
	
	filterList = {"*.x","*.png","*.dds","*.lua","*.htm","*.html","*.xml","*.jpg","*.jpeg","*.gif","*.swf","*.avi","*.mp3"}
	
})
CommonCtrl.FileExplorerCtrl = FileExplorerCtrl;


-- Destroy the UI control
function FileExplorerCtrl:Destroy ()
	ParaUI.Destroy(self.name);
end

-- display control.
function FileExplorerCtrl:Show(bShow)
	CommonCtrl.TreeView.Show(self, bShow)
	self:ResetTreeView();
end

-- navigate to a given root folder. 
function FileExplorerCtrl:ChangeFolder(rootfolder)
	if(self.rootfolder ~= rootfolder) then
		self.rootfolder = rootfolder;
		self:ResetTreeView();
	end	
end


---------------------------
-- private functions: 
---------------------------

-- get node file path. 
function  FileExplorerCtrl:GetNodeNamePath(node)
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
function FileExplorerCtrl.ValidateFolderRootNode(node)
	if(node.rootfolder) then
		node.rootfolder = string.gsub(node.rootfolder, "\\", "/")
		node.rootfolder = string.gsub(node.rootfolder, "^/", "")
		node.rootfolder = string.gsub(node.rootfolder, "/$", "")
		node.Name = node.rootfolder;
		node.IsFolder = true;
	end	
end

-- rebuild tree view for the current root directory.
function FileExplorerCtrl:ResetTreeView()
	local node=self.RootNode;
	if(self.rootfolder ~= nil) then
		node:ClearAllChildren();
		node.rootfolder = self.rootfolder;
		-- cononicalize root folder;
		FileExplorerCtrl.ValidateFolderRootNode(node)
		node.Expanded = true;
		self:RefreshNode(node);
		self:Update();
	else	
		local nSize = #(node.Nodes);
		local i, childNode;
		for i=1, nSize do
			childNode = node.Nodes[i];
			if(childNode and childNode.rootfolder) then
				if(childNode.IsFolder == nil) then
					childNode.IsFolder = true;
				end	
				if(childNode.IsFolder) then
					FileExplorerCtrl.ValidateFolderRootNode(childNode)
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
function FileExplorerCtrl:RefreshNode(node)
	if(node.IsFolder) then
		-- clear this node
		node:ClearAllChildren();
		
		-- add folders
		local folderPath = self:GetNodeNamePath(node)
		if(not self.HideFolder) then
			local output = FileExplorerCtrl.SearchFiles(nil, folderPath,self.MaxItemPerFolder);
			if(output and #output>0) then
				local _, path;
				for _, path in ipairs(output) do
				
					local childNode = node:AddChild( CommonCtrl.TreeNode:new({IsFolder = true, Text=commonlib.Encoding.DefaultToUtf8(path),Name = path, Expanded = false }));
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
				FileExplorerCtrl.SearchFiles(output, folderPath,self.MaxItemPerFolder, filter);
			end
			if(#output>0) then
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
function FileExplorerCtrl:GetIcon(filename)
	if(filename) then
		local _, _, fileExtension = string.find(filename, "%.(.+)$");
		return self.Icons[string.lower(fileExtension or "none")] or self.Icons["unknown"];
	end	
end

-- only return the sub folders of the current folder
-- @param rootfolder: the folder which will be searched.
-- @param nMaxFilesNum: one can limit the total number of files in the search result. Default value is 50. the search will stop at this value even there are more matching files.
-- @param filter: if nil, it defaults to "*."
-- @return a table array containing relative to rootfolder file name.
function FileExplorerCtrl.SearchFiles(output, rootfolder,nMaxFilesNum, filter)
	if(rootfolder == nil) then return; end
	if(filter == nil) then filter = "*." end
	
	output = output or {};
	local sInitDir = ParaIO.GetCurDirectory(0)..rootfolder.."/";
	local search_result = ParaIO.SearchFiles(sInitDir,filter, "", 0, nMaxFilesNum or 50, 0);
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
function FileExplorerCtrl.DrawNormalNodeHandler(_parent,treeNode)
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
	
	if(treeNode.IsFolder) then
		--
		-- folder node
		--
		
		-- cross expand icon
		if(not treeNode.TreeView.DisableFolderExpand) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, height/2-5, 10, 10);
			_this.onclick = string.format(";CommonCtrl.FileExplorerCtrl.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/common/itemopen.png";
			else
				_this.background = "Texture/3DMapSystem/common/itemclosed.png";
			end
			_guihelper.SetUIColor(_this, "255 255 255");
			left = left + 16;
		end	
		
		-- display the checkboxes: it needs to have three states: checked, unchecked, child checked.
		if(treeNode.TreeView.CheckBoxes) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, height/2-7, 14, 14);
			_this.onclick = string.format(";CommonCtrl.FileExplorerCtrl.OnToggleNodeChecked(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			if(treeNode.Checked) then
				_this.background = treeNode.TreeView.checked_bg;
			else
				_this.background = treeNode.TreeView.unchecked_bg;
			end
			_parent:AddChild(_this);
			left = left + 16;
		end
		
		-- file icon
		if(treeNode.TreeView.ShowIcon) then
			local IconSize = treeNode.TreeView.DefaultIconSize;
			local Icon;
			if(treeNode.Icon) then
				Icon = treeNode.Icon
			else 
				if(treeNode.Expanded) then
					Icon = treeNode.TreeView.FolderOpenIcon;
				else
					Icon = treeNode.TreeView.FolderIcon;
				end
			end
			
			if(Icon~=nil and IconSize>0) then
				_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
				_this.background = Icon;
				_guihelper.SetUIColor(_this, "255 255 255");
				_parent:AddChild(_this);
			end	
			left = left + IconSize + 3;
		end	
		
		_this=ParaUI.CreateUIObject("button","b","_mt", left, 1, 2, height - 1);
		_parent:AddChild(_this);
		
		if(treeNode.Selected)then
			_this.background = "Texture/alphadot.png"; -- highlight the selected line. 
		else
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		end
		
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.FileExplorerCtrl.OnClick(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.text = treeNode.Text;
	else
		--
		-- file node
		--
		if(not treeNode.TreeView.DisableFolderExpand) then
			left = left + 16;
		end
		
		-- display the checkboxes
		if(treeNode.TreeView.CheckBoxes) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, height/2-7, 14, 14);
			_this.onclick = string.format(";CommonCtrl.FileExplorerCtrl.OnToggleNodeChecked(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			if(treeNode.Checked) then
				_this.background = treeNode.TreeView.checked_bg;
			else
				_this.background = treeNode.TreeView.unchecked_bg;
			end
			_parent:AddChild(_this);
			left = left + 16;
		end
	
		-- file icon
		if(treeNode.TreeView.ShowIcon) then
			local IconSize = treeNode.TreeView.DefaultIconSize;
			local Icon = treeNode.Icon or treeNode.TreeView:GetIcon(treeNode.Name)
			if(Icon~=nil and IconSize>0) then
				_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
				_this.background = Icon;
				_guihelper.SetUIColor(_this, "255 255 255");
				_parent:AddChild(_this);
			end	
			left = left + IconSize + 3;
		end	
		
		-- file text
		_this=ParaUI.CreateUIObject("button","b", "_mt", left, 1 , 2, height - 1);
		_parent:AddChild(_this);
		
		if(treeNode.Selected)then
			_this.background = "Texture/alphadot.png"; -- high the selected line. 
		else
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		end
		if(treeNode.TextColor) then
			_guihelper.SetFontColor(_this, treeNode.TextColor)
		end
		
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.FileExplorerCtrl.OnClick(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.text = treeNode.Text;
	end
end
FileExplorerCtrl.DrawNodeHandler = FileExplorerCtrl.DrawNormalNodeHandler;

----------------------------------------
-- event handlers: 
----------------------------------------

-- event handler: user clicks a node
function FileExplorerCtrl.OnClick(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(self) then
		self:ClickNode(node);
	end	
end

-- this function can be called from outside
function FileExplorerCtrl:ClickNode(node)
	if(node) then
		
		local bIsDoubleClick
		if(FileExplorerCtrl.LastClickTime == nil) then FileExplorerCtrl.LastClickTime = ParaGlobal.timeGetTime() end
		-- note: this timer is not very accurate, since onclick event is not fired immediately when user clicks.
		-- but anyway, we will set the double click interval to be 1/4 second. 
		if((ParaGlobal.timeGetTime()-FileExplorerCtrl.LastClickTime)<250) then
			if(node == self.LastClickedNode) then
				bIsDoubleClick = true
			end	
		end	
		FileExplorerCtrl.LastClickTime = ParaGlobal.timeGetTime();
		self.LastClickedNode = node;
		
		local CanSelect;
		if(node.IsFolder) then
			if(self.AllowFolderSelection) then
				CanSelect = true
			end
			-- toggle node
			if(not bIsDoubleClick) then
				FileExplorerCtrl.OnToggleNode(self.name, node:GetNodePath());
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

-- toggle folder node, it will cause node to be rebuilt. 
function FileExplorerCtrl.OnToggleNode(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	
	if(node and node.IsFolder and not self.DisableFolderExpand) then	
		if(not node.Expanded) then
			-- always do a file refresh each time a folder is manually expanded. 
			self:RefreshNode(node);	
		end	
		
		CommonCtrl.TreeView.OnToggleNode(sCtrlName, nodePath)
		
		if(self.CheckBoxes) then
			local filepath = self:GetAbsoluteNodeTxt(nodePath)
			--在展开时就把 通配符路径 转换为具体路径
			--a/*.png ==> a/folder/*.png .... a/image1.png, a/image2.png ...
			if( self:HasFilter(filepath) and node.Expanded )then	
					self:ClearFolderFilter(node,nodePath);	
			end	
			
			--如果fromTxtPathList有记录，更新记录映射的节点
			self:UpdateByPathList(nodePath,self.fromTxtPathList);
			
			--在选中而且展开的情况下，如果是总路径的情况，把总路径转换为子目录列表的路径
			--folder/folder_1 =====>> folder/folder_1/1 , folder/folder_1/2, folder/folder_1/3 ......
			
			if(self.CheckedPathList[nodePath] and node.Expanded )then	
					self:BeepChildrenNode(sCtrlName, nodePath);
			end
			--从self.CheckedPathList 中获取所有被选中的目录，并把已经存在的node.Checked = true;
			self:GetOnceChecked(sCtrlName, nodePath)
			
			--校验某个目录，假如它的子目录全部没有被选中，通知它和它的父节点
			--在使用同配符的时候，有可能出现这种情况 父目录是选中状态，但是打开子目录后发现没有一个是匹配的
			self:OurChildenIsAllUnChecked(sCtrlName, nodePath)			
		end	
		
	end
	self:Update();
end

-- toggle folder node, it will cause node to be rebuilt. 
function FileExplorerCtrl.OnToggleNodeChecked(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)

	if(node) then
		node.Checked = not node.Checked
			
		if(type(self.OnCheck) == "function") then
			self.OnCheck(node, self:GetNodeNamePath(node), node.Checked);
		end
		
		if(self.CheckBoxes) then
			--记录被点击节点的路径
			self:SetCheckedPath(nodePath,node.Checked)		
			self:BeepParentNode(sCtrlName, nodePath);	
			self:BeepChildrenNode(sCtrlName, nodePath);	
			
			if(node.Checked==false)then
				-- 取消当前目录的时候，可能self.CheckedPathList里面还存在它的子目录，这时需要清空它
				self:ClearAllChilderOfFolder(nodePath);
				--清空self.fromTxtPathList里面所关联的节点
				self:ClearFromTxtPathList(nodePath);
			end
			
		end	
		
		self:Update();
	end
end
-------------------------------------------------------------------------------------------------
-- 通知父节点
function FileExplorerCtrl:BeepParentNode(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local rootNodeChecked = node.Checked
	if(node) then
		while (node.parent ~=nil) do
			
			if(not rootNodeChecked)then
				local hasChecked = self:HasChecked(node.parent)
				node.parent.Checked = hasChecked; -- 如果 和node并列的其他节点有被选中的返回true，否则返回false
			else
				node.parent.Checked = rootNodeChecked;	--true	
			end
			if(type(self.OnCheck) == "function") then
				self.OnCheck(node.parent, self:GetNodeNamePath(node.parent), node.parent.Checked);
			end
			node = node.parent;
		end
	end
end
--获取曾经选中的节点
function FileExplorerCtrl:GetOnceChecked(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(node.Checked and  node.Expanded)then
		local nSize = table.getn(node.Nodes);
		
		local path ,i, childnode;
		--当前节点的 子结点全部被选中
		for path , __ in pairs(self.CheckedPathList) do
			--all children of node is checked
			
			if(node:GetNodePath()==path)then
				for i=1, nSize do
					childnode = node.Nodes[i];
					childnode.Checked = true;	
					if(type(self.OnCheck) == "function") then
						self.OnCheck(childnode, self:GetNodeNamePath(childnode), childnode.Checked);
					end			
				end
				return;
			end
		end
		----部分被选中
		local findpath = nodePath.."/";
			for path , __ in pairs(self.CheckedPathList) do
				local __,__,nextpath =  string.find(path,"^("..findpath.."%d+)")
				--当前目录的子目录
					if(nextpath)then
						local nextnode = self:GetNodeByPath(nextpath);
							if(nextnode) then
									nextnode.Checked = true;
									if(type(self.OnCheck) == "function") then
										self.OnCheck(nextnode, self:GetNodeNamePath(nextnode), nextnode.Checked);
									end		
							end
					end
			end
	end
	
end
--判断node的子节点时候有已经被选中的，如果有已经被选中的返回true
function FileExplorerCtrl:HasChecked(node)
	if(not node) then return false; end
	local nSize = table.getn(node.Nodes);
	local i, childnode;
		for i=1, nSize do
			childnode = node.Nodes[i];
			if(childnode~=nil) then
				if(childnode.Checked)then
						return true;
				end					
			end
		end
	return false;
end
-- 通知全部子节点
function FileExplorerCtrl:BeepChildrenNode(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)	
	if(node) then
		local checked = node.Checked;
		-- 如果它的父节点还有子节点的时候	
		local nSize = table.getn(node.parent.Nodes)
		if( nSize >0) then
			--清空node的父节点的记录
			local parent_nodePath = node.parent:GetNodePath();
			self:SetCheckedPath(parent_nodePath,false)	
		
		end
				
		--处理它所有的子节点
		self:CheckedAll(sCtrlName, nodePath , checked)
		
	end
end
function FileExplorerCtrl:CheckedAll(sCtrlName, nodePath , checked)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(node) then
		local nSize = table.getn(node.Nodes);		
		local i, childnode;
		for i=1, nSize do
			childnode = node.Nodes[i];
			if(childnode~=nil) then
				childnode.Checked = checked;
				local chile_nodePath = childnode:GetNodePath(); 			
				--记录被点击节点的路径
				self:SetCheckedPath(chile_nodePath,checked)			
				if(type(self.OnCheck) == "function") then
					self.OnCheck(childnode, self:GetNodeNamePath(childnode), childnode.Checked);
				end	
				self:BeepChildrenNode(sCtrlName, chile_nodePath ,checked )
			end
		end
	end
end

--记录被点击节点的路径
function FileExplorerCtrl:SetCheckedPath(nodePath,checked)
	local txt = self:GetAbsoluteNodeTxt(nodePath);
		
		if(checked)then			
			
			self.CheckedPathList[nodePath] = txt or nodePath;
		else
			self.CheckedPathList[nodePath] = nil;		
		end
		
		--清空已经存在的文本列表中的记录
		if(txt)then
			
			self.fromTxtPathList[txt] = nil;
		end
		
end
-- 当取消当前目录的时候，可能self.CheckedPathList里面还存在 它的子目录，这时需要清空它
function FileExplorerCtrl:ClearAllChilderOfFolder(nodePath)
	if(not nodePath)then return; end
	local path;
	for path , __ in pairs(self.CheckedPathList) do
		local temp_path = path .."/";
		local temp_nodePath = nodePath.."/";
		if(string.find(temp_path,"^"..temp_nodePath))then
			self.CheckedPathList[path] = nil;
		end
	end
end
--获取 全名称
function FileExplorerCtrl:GetAbsoluteNodeTxt(nodePath)
	local node = self:GetNodeByPath(nodePath);	
	if(node) then
			local txt = node.Text;
			while (node.parent ~=nil) do
				local parent_node = node.parent;
				if(parent_node.Text)then
					txt = parent_node.Text.."/"..txt;
				end
				node = node.parent;
			end
			return txt;
		end
end
-- 设置 CheckedPathList
function FileExplorerCtrl:SetCheckedPathList(list)
	if(not list or type(list)~="table" ) then return end;
	self.CheckedPathList = list;
	
	local nodePath = self.RootNode:GetNodePath();
	
	self:UpdateByPathList(nodePath,self.CheckedPathList);
	self:Update();
end
-- 设置 fromTxtPathList
function FileExplorerCtrl:SetFromTxtPathList(list)
	if(not list or type(list)~="table" ) then return end;
	self.fromTxtPathList = list;
	
	--如果fromTxtPathList有记录，更新记录映射的节点
	local nodePath = self.RootNode:GetNodePath();
	
	self:UpdateByPathList(nodePath,self.fromTxtPathList);
	self:Update();
end

--更新FileExplorerCtrl
function FileExplorerCtrl:UpdateByPathList(nodePath,pathList)
	if(not pathList or not nodePath )then return ; end
		local node = self:GetNodeByPath(nodePath)
		--update from self.fromTxtPathList
		local k , child;
		for k,child in ipairs(node.Nodes) do
			local child_path = child:GetNodePath();
			local nodeTxt = self:GetAbsoluteNodeTxt(child_path)
			local find = self:FindTxtPath(pathList,nodeTxt);

			if(find=="0" and child.Checked~=true)then
				child.Checked =true;
				self:SetCheckedPath(child_path,true)
				if(type(self.OnCheck) == "function") then
					self.OnCheck(child, self:GetNodeNamePath(child), child.Checked);
				end
			end	
			if(find=="1" and child.Checked~=true)then
				child.Checked =true;
				if(type(self.OnCheck) == "function") then
					self.OnCheck(child, self:GetNodeNamePath(child), child.Checked);
				end
			end	
			
			self:UpdateByPathList(child_path,pathList)		
		end
	
end

--从已经存在的列表(self.fromTxtPathList)中找 某个节点，如果找到，返回true
function FileExplorerCtrl:FindTxtPath(list,nodeTxt)
 if(not nodeTxt) then return nil; end
 local txt;
 for __,txt in pairs(list) do
	
	local __,__,result = string.find(txt,"^("..nodeTxt..").-")
	
	if(result)then	
		local __,__,result_full = string.find(txt,"^("..nodeTxt..")$")
		if(result_full)then
			--完全匹配
			return "0";
		end
		--父节点匹配
			return "1";
		
	end
 end
end
--清空self.fromTxtPathList里面所关联的节点
function FileExplorerCtrl:ClearFromTxtPathList(nodePath)
				for __,txt in pairs(self.fromTxtPathList) do
					local nodeTxt = self:GetAbsoluteNodeTxt(nodePath);
					local temp_txt = txt .."/";
					local temp_nodeTxt = nodeTxt.."/";
					if(string.find(temp_txt,"^"..temp_nodeTxt))then
						self.fromTxtPathList[txt]=nil;
					end
				end
end

--转换某个目录下面的通配符为具体文件路径
-- 通配符只可能出现在self.fromTxtPathList里面
--a/*.jpg ==> a/1.jpg,a/2.jpg ......
function FileExplorerCtrl:ClearFolderFilter(parentNode,parentNodePath)
	--commonlib.echo({"parentNodePath:",parentNodePath,"nodePath:",nodePath});
	if(not parentNode or not parentNodePath) then return ; end;
	local parent_nodeTxt = self:GetAbsoluteNodeTxt(parentNodePath);
	local k,filter,filter_path;
	
	for k,filter in ipairs(self.filterList) do
		filter_path = parent_nodeTxt.."/"..filter;
		--找到匹配的通配符
		if(self.fromTxtPathList[filter_path])then		
			local len = table.getn(parentNode.Nodes);
			if(len>0)then
				--如果它含有子节点
				self.fromTxtPathList[filter_path] = nil;
			end			
			local j,v ;
			for j,v in ipairs(parentNode.Nodes) do
				local bool_findoneFilter = false;
				local childNode = parentNode.Nodes[j];
				local child_path = childNode:GetNodePath();				
				local child_nodeTxt = self:GetAbsoluteNodeTxt(child_path);
				local isFolder = self:IsFolder(child_nodeTxt);
				--commonlib.echo({isFolder,child_nodeTxt});
				if(isFolder==false)then
					--如果是一个文件
					local filter_temp = filter.gsub(filter,"*","");
					local bool_find = string.find(child_nodeTxt,parent_nodeTxt.."/(.+)"..filter_temp.."$");
					if(bool_find)then						
						self:SetCheckedPath(child_path,true)
					end
				else
						--如果是一个文件夹
					self.fromTxtPathList[child_nodeTxt.."/"..filter] = child_nodeTxt.."/"..filter;	
				end

				--递归所有的子目录
				self:ClearFolderFilter(childNode,child_path);
			end
		end
	end
end

--校验某个目录，假如它的子目录全部没有被选中，通知它和它的父节点
--在使用同配符的时候，有可能出现这种情况 父目录是选中状态，但是打开子目录后发现没有一个是匹配的
function FileExplorerCtrl:OurChildenIsAllUnChecked(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local reallyUnchecked = true;
	if(node) then
		local nSize = table.getn(node.Nodes);		
		local i, childnode;
		for i=1, nSize do
			childnode = node.Nodes[i];
			if(childnode.Checked == true)then
				reallyUnchecked = false;
			end
		end
		if(reallyUnchecked)then
			node.Checked = false;
			self:BeepParentNode(sCtrlName, nodePath);	
		end
	end
end

--判断一个路径是否为文件夹
function FileExplorerCtrl:IsFolder(filepath)
	local rootPath = ParaIO.GetCurDirectory(0);
	local path = rootPath..filepath;
	local search_result = ParaIO.SearchFiles(path.."/","*", "", 0, 1, 0);
	local nCount = search_result:GetNumOfResult();
	if(nCount>0) then
		return true;
	else 
		return false;
	end
end

--
function FileExplorerCtrl:HasFilter(filepath)
	local k,filter,filter_path;
	for k,filter in ipairs(self.filterList) do
		filter_path = filepath.."/"..filter;
		if(self.fromTxtPathList[filter_path])then
			return true;
		end
	end
end
-------------------------------------------------------------------------------------------------
----------------------------------------
-- public functions: 
----------------------------------------
-- get the current file path
function FileExplorerCtrl:GetValue()
	return self.SelectedPath
end

-- get the current file path
function FileExplorerCtrl:GetText()
	return self:GetValue();
end

-- TODO: 
function FileExplorerCtrl:SetValue(filepath)
end

-- TODO: create a new folder
-- @return true if succeed.
function FileExplorerCtrl:CreateFolder(folderName, rootDir)
	-- validate foldername
	-- add folder
	-- update UI
	-- return true;
	log("warning: FileExplorerCtrl:CreateFolder is not implemented yet.\n");
end

