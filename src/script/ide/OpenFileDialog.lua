--[[
Title: Open File Dialog
Author(s): LiXizhi
Date: 2007/5/15
Parameters:
	OpenFileDialog: it needs to be a valid name, such as MyDialog
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/OpenFileDialog.lua");
local ctl = CommonCtrl.OpenFileDialog:new{
	name = "OpenFileDialog1",
	alignment = "_ct",
	left=-256, top=-150,
	width = 512,
	height = 380,
	parent = nil,
	-- initial file name to be displayed, usually "" 
	FileName = "",
	fileextensions = {"all files(*.*)", "images(*.jpg; *.png; *.dds)", "animations(*.swf; *.wmv; *.avi)", "web pages(*.htm; *.html)", },
	folderlinks = {
		{path = "model/", text = "model"},
		{path = "Texture/", text = "Texture"},
		{path = "character/", text = "character"},
		{path = "script/", text = "script"},
	},
	onopen = function(ctrlName, filename)
	end
};
ctl:Show(true);

-- external open using win32 dialog
NPL.load("(gl)script/ide/OpenFileDialog.lua");
local filename = CommonCtrl.OpenFileDialog.ShowDialog_Win32();
if(filename) then
	commonlib.log(filename);
end
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
local L = CommonCtrl.Locale("IDE");

-- define a new control in the common control libary

-- default member attributes
local OpenFileDialog = {
	-- the top level control name
	name = "OpenFileDialog1",
	-- the title to be displayed. 
	title = nil,
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	-- TODO: how a dialog is poped up. if nil, it is just displayed as a top level window. 
	-- If 1, it will gradually grey out the background and pops up with an animation. 
	-- If 2, it will grey out the background and pops up WITHOUT animations. 
	PopupStyle = 1,
	parent = nil,
	show_file_buttons = true,
	-- what kind of file extensions to load, the first one is always the default one.
	fileextensions = {"all files(*.*)", "images(*.jpg; *.png; *.dds)", "animations(*.swf; *.wmv; *.avi)", "web pages(*.htm; *.html)", },
	-- at most four items
	folderlinks = {
		{folder = "model/", text = "model"},
		{folder = "Texture/", text = "Texture"},
		{folder = "character/", text = "character"},
		{folder = "script/", text = "script"},
	},
	-- [used only internally] current folder, if nil, it will be the folder specifeid by the currentFolderlinkIndex
	currentFolder = nil, 
	-- how many sub directory levels to show for the current folder.
	showSubDirLevels = 0,
	-- whether check the file existance
	CheckFileExists = true,
	-- event if CheckFileExists is true, we can specify a filename pass filter like "http://.*", so that the open file dialog will 
	-- return when the user has specified a filename that contains could pass the specified filter. 
	FileNamePassFilter = nil,
	-- initial file name to be displayed, usually "" 
	FileName = "",
	-- appearance
	openInExplorerBtn_bg = "Texture/3DMapSystem/common/folder_go.png",
	deleteFileBtn_bg = "Texture/3DMapSystem/common/folder_delete.png",
	renameFileBtn_bg = "Texture/3DMapSystem/common/folder_edit.png",
	openAddFolderBtn_bg = "Texture/3DMapSystem/common/folder_add.png",
	-- text to display on the open button, if nil, it is open
	OpenButtonName = nil,
	main_bg = nil, -- use default container bg
	-- oncheck event, it can be nil, a string to be executed or a function of type void ()(sCtrlName, filename)
	onopen = nil,
}
CommonCtrl.OpenFileDialog = OpenFileDialog;

-- constructor
function OpenFileDialog:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function OpenFileDialog:Destroy ()
	ParaUI.Destroy(self.name);
end

-- @param filter: nil or {{"All Files (*.*)", "*.*"}, ...} one or more pairs of display text and filter text
-- return A buffer containing pairs of null-terminated filter strings. The last string in the buffer must be terminated by two NULL characters. 
local function GetFilterString(filters)
	if(filters) then
		local filterText = "";
		for _, filter in ipairs(filters) do
			if(filter[1] and filter[2]) then
				local text = format("%s\0%s\0", commonlib.Encoding.Utf8ToDefault(filter[1]), filter[2]);
				filterText = filterText..text;
			end
		end
		if(filterText~="") then
			return filterText;
		end
	end
end

-- use the external dialog
-- @param filters: nil or {{"All Files (*.*)", "*.*"}, ...} one or more pairs of display text and filter text
-- To specify multiple filter patterns for a single display string, use a semicolon to separate the patterns (for example, "*.TXT;*.DOC;*.BAK")
-- @param title: title string or nil
-- @param initialdir: initial directoy or nil
-- @param isSaveMode: if true, we will use SaveFileDialog instead of OpenFileDialog. default to nil.
-- @return the filename selected or nil if nothing is selected or user clicked cancel.
function OpenFileDialog.ShowDialog_Win32(filters, title, initialdir, isSaveMode)
	if(initialdir) then
		initialdir = initialdir:gsub("/","\\");
	end
	local input = {
			filter = GetFilterString(filters), 
			title = commonlib.Encoding.Utf8ToDefault(title),
			initialdir = initialdir,
			save = isSaveMode,
		};
	if(ParaGlobal.OpenFileDialog(input)) then
		return input.filename;
	end
end

-- open folder dialog
function OpenFileDialog.ShowOpenFolder_Win32()
	local folder = ParaEngine.GetAttributeObject():GetField("OpenFileFolder", "");
	return folder;
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function OpenFileDialog:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("OpenFileDialog instance name can not be nil\r\n");
		return
	end

	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		CommonCtrl.OpenFileDialog.CurrentDialogName = self.name;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		if(self.main_bg~=nil)then
			_this.background=self.main_bg;
		else
			if(_guihelper.DialogBox_BG ~=nil) then
				_this.background = _guihelper.DialogBox_BG;
			end	
		end
		_this:SetTopLevel(true);
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		-- title text
		if(self.title~=nil) then
			_this=ParaUI.CreateUIObject("text","b", "_lt",29, 13,100, 13);
			_parent:AddChild(_this);
			_guihelper.SetUIFontFormat(_this, 32);
			_this.text=self.title;
		end
			
		-- files view
		NPL.load("(gl)script/ide/FileExplorerCtrl.lua");
		local ctl = CommonCtrl.GetControl(self.name.."files");
		if(not ctl) then
			ctl = CommonCtrl.FileExplorerCtrl:new{
				name = self.name.."files",
				alignment = "_fi",left=195, top=42,width = 17,height = 98, 
				parent = _parent,
				AllowFolderSelection = true,
				DisableFolderExpand = true,
				HideFolder = true,
				OnSelect = string.format([[CommonCtrl.OpenFileDialog.OnFileSelected("%s");]],self.name),
				OnDoubleClick = string.format([[CommonCtrl.OpenFileDialog.OnFileSelectedAndOpen("%s");]],self.name),
			};
		else
			ctl.parent = _parent;
		end	
		ctl:Show(true);		
	
		local left, top,width, height = -112, 16, 24, 16;
		if(self.show_file_buttons) then
			_this = ParaUI.CreateUIObject("button", "button16", "_rt", left, top,height, height)
			_this.background = self.openAddFolderBtn_bg;
			_this.animstyle = 12;
			_this.tooltip = "Add Folder";
			_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.OnClickAddFolder("%s");]],self.name);
			_parent:AddChild(_this);
			left = left + width;
		
			_this = ParaUI.CreateUIObject("button", "button14", "_rt", left, top,height, height)
			_this.background = self.deleteFileBtn_bg;
			_this.animstyle = 12;
			_this.tooltip = L"Delete";
			_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.OnClickDeleteSelection("%s");]],self.name);
			_parent:AddChild(_this);
			left = left + width;

			_this = ParaUI.CreateUIObject("button", "button15", "_rt", left, top,height, height)
			_this.background = self.renameFileBtn_bg;
			_this.animstyle = 12;
			_this.tooltip = L"Rename";
			_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.OnClickRename("%s");]],self.name);
			_parent:AddChild(_this);
			left = left + width;

			_this = ParaUI.CreateUIObject("button", "button16", "_rt", left, top,height, height)
			_this.background = self.openInExplorerBtn_bg;
			_this.animstyle = 12;
			_this.tooltip = L"Open folder with window explorer";
			_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.OnClickOpenInExplorer("%s");]],self.name);
			_parent:AddChild(_this);
			left = left + width;
		end

		_this = ParaUI.CreateUIObject("button", "button13", "_rb", -173, -39, 75, 24)
		_this.text = self.OpenButtonName or L"Open";
		_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.OnClickOpen("%s");]],self.name);
		_parent:AddChild(_this);	
		
		_this = ParaUI.CreateUIObject("button", "button12", "_rb", -92, -39, 75, 24)
		_this.text = L"Cancel";
		_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.OnClose("%s");]],self.name);
		_parent:AddChild(_this);


		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.GetControl(self.name.."comboBoxFileExtension");
		if(not ctl) then
			ctl = CommonCtrl.dropdownlistbox:new{
				name = self.name.."comboBoxFileExtension",
				alignment = "_mb",
				left = 269,
				top = 45,
				width = 17,
				height = 20,
				dropdownheight = 106,
 				parent = _parent,
				AllowUserEdit = false,
				onselect = string.format([[CommonCtrl.OpenFileDialog.OnFileExtentionsChanged("%s");]],self.name),
			};
		else
			ctl.parent = _parent;
		end	
		ctl.text = self.fileextensions[1];
		ctl.items = self.fileextensions;
		ctl:Show();

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.GetControl(self.name.."comboBoxFileName");
		if(not ctl) then
			ctl = CommonCtrl.dropdownlistbox:new{
				name = self.name.."comboBoxFileName",
				alignment = "_mb",
				left = 269,
				top = 68,
				width = 17,
				height = 20,
				dropdownheight = 106,
 				parent = _parent,
				items = {},
			};
		else
			ctl.parent = _parent;
		end	
		ctl.text = "";
		ctl:Show();

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.GetControl(self.name.."comboBoxSearchRange");
		if(not ctl) then
			ctl = CommonCtrl.dropdownlistbox:new{
				name = self.name.."comboBoxSearchRange",
				alignment = "_mt",
				left = 99,
				top = 15,
				width = 118,
				height = 20,
				dropdownheight = 106,
 				parent = _parent,
				AllowUserEdit = false,
				items = {},
				onselect = string.format([[CommonCtrl.OpenFileDialog.OnSearchRangeChanged("%s");]],self.name),
			};
		else
			ctl.parent = _parent;
		end	
		ctl.text = "";
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label2",  "_lb", 204, -62, 59, 12)
		_this.text = L"File Type:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4",  "_lb", 204, -85, 59, 12)
		_this.text = L"File Name:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 22, 18, 71, 12)
		_this.text = L"Look in:";
		_parent:AddChild(_this);
		
		-- folders panel
		NPL.load("(gl)script/ide/FileExplorerCtrl.lua");
		local ctl = CommonCtrl.GetControl(self.name.."folder");
		if(not ctl) then
			ctl = CommonCtrl.FileExplorerCtrl:new{
				name = self.name.."folder",
				alignment = "_ml",left=14, top=41,width = 175,height = 45, 
				parent = _parent,
				AllowFolderSelection = true,
			};
		else
			ctl.parent = _parent;
		end	
		ctl.OnSelect = function(filepath) OpenFileDialog.OnClickFolder(self, filepath); end
		ctl.RootNode:ClearAllChildren();
		local i, folder
		for i, folder in ipairs(self.folderlinks) do
			if(folder.path) then
				ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = folder.text, rootfolder = folder.path, Expanded = false,})); 
			end
		end
		ctl:Show(true);
		
		if(self.currentFolder==nil and ctl.RootNode.Nodes[1]) then
			ctl.RootNode.Nodes[1].Expanded = true;
			ctl:ClickNode(ctl.RootNode.Nodes[1]);
		else
			self.currentFolder = ""
			self:Update();
		end
		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;

		if(bShow) then
			_this:SetTopLevel(true);
		end
	end	
	if(KidsUI~=nil) then
		if(bShow) then
			KidsUI.PushState({name = self.name, OnEscKey = string.format([[CommonCtrl.OpenFileDialog.OnClose("%s");]], self.name)});
		else
			KidsUI.PopState(self.name);
		end
	end	
end

-- update the UI according to the current selected folder and text
function OpenFileDialog:Update()
	local filenameCtl = CommonCtrl.GetControl(self.name.."comboBoxFileName");
	if(filenameCtl~=nil)then
		filenameCtl:SetText(commonlib.Encoding.DefaultToUtf8(self.FileName));
	end
	if(self.currentFolder) then
		
		-- get the file extension(s) to search for
		local fileExt = "*.*";
		local FileExtension = CommonCtrl.GetControl(self.name.."comboBoxFileExtension");
		if(FileExtension~=nil)then
			local text = string.gsub(FileExtension:GetText(), ".*%((.*%)).*", "%1");
			if(text~=nil and text~="") then
				fileExt = "";
				local ext;
				for ext in string.gfind(text, "(%S*)[;%)]") do
					fileExt = fileExt..ext..";";
				end
			end
		end
		
		-- fill the files.
		local files = {};
		local FilesCtrl = CommonCtrl.GetControl(self.name.."files");
		if(FilesCtrl~=nil)then
			FilesCtrl.rootfolder = self.currentFolder;
			FilesCtrl.filter = fileExt;
			FilesCtrl:ResetTreeView();
		end
		
		-- fill the directories.
		local SearchRange = CommonCtrl.GetControl(self.name.."comboBoxSearchRange");
		if(SearchRange~=nil)then
			SearchRange:InsertItem(commonlib.Encoding.DefaultToUtf8(self.currentFolder));
			SearchRange:SetText(commonlib.Encoding.DefaultToUtf8(self.currentFolder));
		end
	end
end

-- get the file name
function OpenFileDialog:GetFileName()
	local filenameCtl = CommonCtrl.GetControl(self.name.."comboBoxFileName");
	if(filenameCtl~=nil)then
		local filename = commonlib.Encoding.Utf8ToDefault(filenameCtl:GetText());
		if( not string.find(filename, "[\\/]")) then
			if(self.currentFolder~=nil) then
				filename = self.currentFolder.."/"..filename;
			end
		end
		return filename;
	else	
		return "";
	end
end

function CommonCtrl.OpenFileDialog.OnSearchRangeChanged(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	
	local SearchRange = CommonCtrl.GetControl(self.name.."comboBoxSearchRange");
	if(SearchRange~=nil)then
		self.currentFolder = commonlib.Encoding.Utf8ToDefault(SearchRange:GetText());
	end
	self:Update();
end

function CommonCtrl.OpenFileDialog.OnFileExtentionsChanged(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	self:Update();
end

-- when a folder is clicked.
function CommonCtrl.OpenFileDialog.OnClickFolder(self, filepath)
	if(self==nil or filepath==nil)then
		return;
	end
	
	self.currentFolder = filepath;
	self:Update();
end

function CommonCtrl.OpenFileDialog.OnClickOpen(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.CheckFileExists) then
		local filename = self:GetFileName();
		local forcePass = nil;
		if(self.FileNamePassFilter~=nil) then
			forcePass = (string.find(filename, self.FileNamePassFilter)~=nil)
		end
		if(not forcePass and not ParaIO.DoesFileExist(filename)) then
			_guihelper.MessageBox(string.format(L"The file you specified does not exist:\r\n%s", filename));
			return;
		end
	end
	self.FileName = self:GetFileName();
	-- close the dialog
	OpenFileDialog.OnClose(sCtrlName);
	
	-- call the event handler if any
	if(self.onopen~=nil)then
		if(type(self.onopen) == "string") then
			NPL.DoString(self.onopen);
		else
			self.onopen(self.name, self.FileName);
		end
	end
end

-- select the file to file name box
function CommonCtrl.OpenFileDialog.OnFileSelected(sCtrlName)	
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	local FileCtrl = CommonCtrl.GetControl(self.name.."files");
	if(FileCtrl) then
		local filenameCtl = CommonCtrl.GetControl(self.name.."comboBoxFileName");
		if(filenameCtl~=nil)then
			local filename = FileCtrl:GetValue();
			if(filename) then
				filenameCtl:InsertItem(commonlib.Encoding.DefaultToUtf8(filename));
				filenameCtl:SetText(commonlib.Encoding.DefaultToUtf8(filename));
			end	
		end
	end
end

-- select and open file. called when double click on file.
function CommonCtrl.OpenFileDialog.OnFileSelectedAndOpen(sCtrlName)
	CommonCtrl.OpenFileDialog.OnFileSelected(sCtrlName)
	CommonCtrl.OpenFileDialog.OnClickOpen(sCtrlName);
end

function CommonCtrl.OpenFileDialog.OnClickRename(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	local FileCtrl = CommonCtrl.GetControl(self.name.."files");
	if(FileCtrl) then
		local filename = FileCtrl:GetValue();
		if(filename and filename~="") then
			local srcName = string.gsub(filename, "/", "\\");
			local destName = string.gsub(self:GetFileName(), "/", "\\");
			if(destName~=nil and destName~="" and srcName~=nil and srcName~="") then
				if( destName == srcName) then
					_guihelper.MessageBox(L"Please enter a different name in the file name editbox to rename it.");
				elseif(ParaIO.GetParentDirectoryFromPath(srcName, 0) == ParaIO.GetParentDirectoryFromPath(destName,0)) then
					-- must has the same parent directory.
					if(ParaIO.MoveFile(srcName, destName)) then
						self:Update();
					else
						_guihelper.MessageBox(string.format(L"Unable to rename file %s\n to %s.Maybe due to insufficient access right.", commonlib.Encoding.DefaultToUtf8(srcName), commonlib.Encoding.DefaultToUtf8(destName)));
					end
				else	
					_guihelper.MessageBox(string.format(L"Unable to rename file %s\n to %s.Maybe due to insufficient access right.", commonlib.Encoding.DefaultToUtf8(srcName), commonlib.Encoding.DefaultToUtf8(destName)));
				end
			end
		end
	end
end

CommonCtrl.OpenFileDialog.FileToDeleteTmp = nil;
function CommonCtrl.OpenFileDialog.OnClickDeleteSelection(sCtrlName)	
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	-- delete seleted file
	local FileCtrl = CommonCtrl.GetControl(self.name.."files");
	if(FileCtrl) then
		local filename = FileCtrl:GetValue();
		if(filename and filename~="") then
			local fileName = string.gsub(filename, "/","\\");
			if(fileName ~= nil) then
				CommonCtrl.OpenFileDialog.FileToDeleteTmp = fileName;
				_guihelper.MessageBox(string.format(L"Are you sure you want to delete the file\n %s ?", fileName),  function()
					if(ParaIO.DeleteFile(CommonCtrl.OpenFileDialog.FileToDeleteTmp)>0)then
						local self = CommonCtrl.GetControl(CommonCtrl.OpenFileDialog.CurrentDialogName);
						if(self~=nil)then
							self:Update();
						end
					end
				end);
			end	
		end
	end
end

-- open in external browser
function CommonCtrl.OpenFileDialog.OnClickOpenInExplorer(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.currentFolder~=nil) then
		local absPath = string.gsub(ParaIO.GetCurDirectory(0)..self.currentFolder, "/", "\\");
		if(absPath~=nil) then
			_guihelper.MessageBox(string.format(L"Are you sure that you want to open %s using external browser?", absPath), function()
				ParaGlobal.ShellExecute("open", "explorer.exe", absPath, "", 1); 
			end);	
		end	
	end
end

-- TODO: add folder to current directory
function CommonCtrl.OpenFileDialog.OnClickAddFolder(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.currentFolder~=nil) then
		local absPath = string.gsub(ParaIO.GetCurDirectory(0)..self:GetFileName().."/", "/", "\\");
		if(absPath~=nil) then
			_guihelper.MessageBox(string.format(L"Are you sure that you want to create a folder at %s?", absPath), 
				function () 
					if(ParaIO.CreateDirectory(absPath)) then
						self:Update();
					end
				end)
		end	
	end
end

-- close the given control
function OpenFileDialog.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
	if(KidsUI) then
		KidsUI.PopState(self.name);
	end	
end

function OpenFileDialog:SavToFile(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("OpenFileDialog instance name can not be nil\r\n");
		return
	end

	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		CommonCtrl.OpenFileDialog.CurrentDialogName = self.name;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		if(self.main_bg~=nil)then
			_this.background=self.main_bg;
		else
			if(_guihelper.DialogBox_BG ~=nil) then
				_this.background = _guihelper.DialogBox_BG;
			end	
		end
		_this:SetTopLevel(true);
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		-- title text
		if(self.title~=nil) then
			_this=ParaUI.CreateUIObject("text","b", "_lt",29, 13,100, 13);
			_parent:AddChild(_this);
			_guihelper.SetUIFontFormat(_this, 32);
			_this.text=self.title;
		end
			
		-- files view
		NPL.load("(gl)script/ide/FileExplorerCtrl.lua");
		local ctl = CommonCtrl.GetControl(self.name.."files");
		if(not ctl) then
			ctl = CommonCtrl.FileExplorerCtrl:new{
				name = self.name.."files",
				alignment = "_fi",left=195, top=42,width = 17,height = 98, 
				parent = _parent,
				AllowFolderSelection = true,
				DisableFolderExpand = true,
				HideFolder = true,
			};
		else
			ctl.parent = _parent;
		end	
		ctl:Show(true);
	
		_this = ParaUI.CreateUIObject("button", "button13", "_rb", -173, -39, 75, 24)
		_this.text = self.OpenButtonName or L"保存";
		_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.SavFile("%s");]],self.name);
		_parent:AddChild(_this);	
		
		_this = ParaUI.CreateUIObject("button", "button12", "_rb", -92, -39, 75, 24)
		_this.text = L"取消";
		_this.onclick=string.format([[;CommonCtrl.OpenFileDialog.OnClose("%s");]],self.name);
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.GetControl(self.name.."comboBoxFileName");
		if(not ctl) then
			ctl = CommonCtrl.dropdownlistbox:new{
				name = self.name.."comboBoxFileName",
				alignment = "_mb",
				left = 269,
				top = 68,
				width = 17,
				height = 20,
				dropdownheight = 106,
 				parent = _parent,
				items = {},
			};
		else
			ctl.parent = _parent;
		end	
		ctl.text = "";
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label4",  "_lb", 204, -85, 59, 12)
		_this.text = L"文件名:";
		_parent:AddChild(_this);

		-- folders panel
		NPL.load("(gl)script/ide/FileExplorerCtrl.lua");
		local ctl = CommonCtrl.GetControl(self.name.."folder");
		if(not ctl) then
			ctl = CommonCtrl.FileExplorerCtrl:new{
				name = self.name.."folder",
				alignment = "_ml",left=14, top=41,width = 175,height = 45, 
				parent = _parent,
				AllowFolderSelection = true,
			};
		else
			ctl.parent = _parent;
		end	
		ctl.OnSelect = function(filepath) OpenFileDialog.OnClickFolder(self, filepath); end
		ctl.RootNode:ClearAllChildren();
		local i, folder
		for i, folder in ipairs(self.folderlinks) do
			if(folder.path) then
				ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = folder.text, rootfolder = folder.path, Expanded = false,})); 
			end
		end
		ctl:Show(true);
		
		if(self.currentFolder==nil and ctl.RootNode.Nodes[1]) then
			ctl.RootNode.Nodes[1].Expanded = true;
			ctl:ClickNode(ctl.RootNode.Nodes[1]);
		else
			self.currentFolder = ""
			self:Update();
		end
		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;

		if(bShow) then
			_this:SetTopLevel(true);
		end
	end	
	if(KidsUI~=nil) then
		if(bShow) then
			KidsUI.PushState({name = self.name, OnEscKey = string.format([[CommonCtrl.OpenFileDialog.OnClose("%s");]], self.name)});
		else
			KidsUI.PopState(self.name);
		end
	end	
end

function CommonCtrl.OpenFileDialog.SavFile(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting OpenFileDialog instance "..sCtrlName.."\r\n");
		return;
	end	

	local filenameCtl = CommonCtrl.GetControl(sCtrlName.."comboBoxFileName");
	
	if(filenameCtl~=nil)then
		local filename = commonlib.Encoding.Utf8ToDefault(filenameCtl:GetText());

		if( not string.find(filename, "[\\/]")) then
			if(self.currentFolder~=nil) then
				filename = self.currentFolder.."/"..filename;
			end
		end
		OpenFileDialog.OnClose(sCtrlName);
		-- call the event handler if any
		if(self.onsave~=nil)then
			if(type(self.onsave) == "string") then
				NPL.DoString(self.onsave);
			else
				self.onsave(self.name, filename);
			end
		end
	else	
		OpenFileDialog.OnClose(sCtrlName);
	end
	
end