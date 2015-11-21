--[[
Title: LocalSingleDocumentFrame
Author(s): Leio
Date: 2009/2/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Document/LocalSingleDocumentFrame.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Document/LocalSingleDocument.lua");
local LocalSingleDocumentFrame = {
	curCommand = "", -- "new" or "save" or "saveas" or "open"
	lite3DCanvas = nil,
	rootPath = "",
	--event
	onNewDocFunc = nil,
	onOpenDocFunc = nil,
	onSaveDocFunc = nil,
	onSaveAsDocFunc = nil,
}
commonlib.setfield("CommonCtrl.LocalSingleDocumentFrame",LocalSingleDocumentFrame);
function LocalSingleDocumentFrame:new(o)
	o = o or {};
	setmetatable(o, self)
	self.__index = self
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end
function LocalSingleDocumentFrame:SetLite3DCanvas(lite3DCanvas)
	self.lite3DCanvas = lite3DCanvas;
end
function LocalSingleDocumentFrame:GetLite3DCanvas()
	return self.lite3DCanvas;
end
function LocalSingleDocumentFrame:SetCurCommand(s)
	self.curCommand = s;
end
function LocalSingleDocumentFrame:GetCurCommand()
	return self.curCommand;
end
function LocalSingleDocumentFrame:GetCurrentDocument()
	return self.doc;
end
function LocalSingleDocumentFrame:SetCurrentDocument(doc)
	self.doc = doc;
end
function LocalSingleDocumentFrame:DoNewDocument()
	local doc = CommonCtrl.LocalSingleDocument:new();
	self:SetCurrentDocument(doc)
	doc:SetCanvas(self:GetLite3DCanvas());
	if(self.onNewDocFunc)then
		self.onNewDocFunc(self);
	end
end
function LocalSingleDocumentFrame:DoOpenDocument(filepath)
	local doc = CommonCtrl.LocalSingleDocument:new();
	doc:SetFilePath(filepath);
	doc:Load();	
	self:SetCurrentDocument(doc)
	--doc:SetCanvas(self:GetLite3DCanvas());
	if(self.onOpenDocFunc)then
		self.onOpenDocFunc(self);
	end
end
function LocalSingleDocumentFrame:DoSaveDocument()
	local doc = self:GetCurrentDocument();
	if(doc)then
		doc:Save();
	end
	local curCommand = self:GetCurCommand();
	if(self.onSaveDocFunc and curCommand == "save")then
		self.onSaveDocFunc(self);
	elseif(self.onSaveAsDocFunc and curCommand == "saveas")then
		self.onSaveAsDocFunc(self);
	end
end
function LocalSingleDocumentFrame:OnClickNew()
	local doc = self:GetCurrentDocument();
	self:SetCurCommand("new")
	if(doc)then
		
		if(doc:IsNew())then
			_guihelper.MessageBox("刚才新建的文件是否保存？",
					function (result)
						if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.OK == result) then
							self:_SaveDialogControl();
						else
							self:DoNewDocument();
						end
					end,_guihelper.MessageBoxButtons.YesNo
					);		
								
		else
			-- inclue two states:"open_noChanged" or "open_changed"
			local filepath = doc:GetFilePath();
			_guihelper.MessageBox(string.format("%s:是否保存？", filepath),
					function (result)
						if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.OK == result) then
							doc:SetFilePath(filepath);
							self:DoSaveDocument();				
						end
						self:DoNewDocument()
					end,_guihelper.MessageBoxButtons.YesNo
					);	
		end
	else
		self:DoNewDocument();
	end
	
end
function LocalSingleDocumentFrame:OnClickSave()
	local doc = self:GetCurrentDocument();
	if(doc)then
		self:SetCurCommand("save")
		if(doc:IsNew())then
			self:_SaveDialogControl();
		else
			-- inclue two states:"open_noChanged" or "open_changed"
			self:DoSaveDocument();	
		end
	end
end
function LocalSingleDocumentFrame:OnClickSaveAs()
	local doc = self:GetCurrentDocument();
	if(doc)then
		self:SetCurCommand("saveas")
		self:_SaveDialogControl();
	end
end
function LocalSingleDocumentFrame:OnClickOpen()
	local doc = self:GetCurrentDocument();
	self:SetCurCommand("open")
	if(doc)then		
		if(doc:IsNew())then
			_guihelper.MessageBox("刚才新建的文件是否保存？",
					function (result)
						if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.OK == result) then
							self:_SaveDialogControl();
						else
							self:_OpenDialogControl();
						end
					end,_guihelper.MessageBoxButtons.YesNo
					);		
		else
			-- inclue two states:"open_noChanged" or "open_changed"
			local filepath = doc:GetFilePath();
			_guihelper.MessageBox(string.format("%s:是否保存？", filepath),
					function (result)
						if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.OK == result) then
							doc:SetFilePath(filepath);
							self:DoSaveDocument();
						end
						self:_OpenDialogControl();
					end,_guihelper.MessageBoxButtons.YesNo
					);	
		end
	else
		self:_OpenDialogControl();
	end
end

function LocalSingleDocumentFrame:_SaveDialogControl()
	NPL.load("(gl)script/ide/SaveFileDialog.lua");	
	local curDoc = self:GetCurrentDocument();		
	local path = self.rootPath;
	local name = self.name.."save";
	local ctl = CommonCtrl.GetControl(name)
	if(not ctl)then
		ctl = CommonCtrl.SaveFileDialog:new{
		name = name,
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		-- initial file name to be displayed, usually "" 
		FileName = "",
		fileextensions = {"xml(*.xml)", },
		folderlinks = {
			{path = path, text = "Root"},
		},
		onopen = CommonCtrl.LocalSingleDocumentFrame._onsave
	};
	end
	ctl:Show(true);
	ctl.LocalSingleDocumentFrame = self;
	CommonCtrl.AddControl(name,ctl)
end
function LocalSingleDocumentFrame._onsave(ctrlName, filepath)
	local ctl = CommonCtrl.GetControl(ctrlName)
	if(ctl and ctl.LocalSingleDocumentFrame and filepath)then	
		local self = ctl.LocalSingleDocumentFrame;
		local curDoc = self:GetCurrentDocument();	
		if(ParaIO.DoesFileExist(filepath)) then	
			_guihelper.MessageBox(string.format("%s文件已经存在, 确定要覆盖它？", filepath),
					function (result)
						if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.OK == result) then
							curDoc:SetFilePath(filepath);
							self:DoSaveDocument();
							
							local curCommand = self:GetCurCommand();
							if(curCommand == "new")then
								self:DoNewDocument()
							elseif(curCommand == "open")then
								self:DoOpenDocument()
							end
						end
					end,_guihelper.MessageBoxButtons.YesNo
					);		
		else
			curDoc:SetFilePath(filepath);
			self:DoSaveDocument();
			local curCommand = self:GetCurCommand();
			if(curCommand == "new")then
				self:DoNewDocument()
			end
		end
	end
end
function LocalSingleDocumentFrame:_OpenDialogControl()
	NPL.load("(gl)script/ide/OpenFileDialog.lua");	
	local name = self.name.."open";
	local path = self.rootPath;
	local ctl = CommonCtrl.GetControl(name)
	if(not ctl)then
		ctl = CommonCtrl.OpenFileDialog:new{
		name = name,
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		-- initial file name to be displayed, usually "" 
		FileName = "",
		fileextensions = {"xml(*.xml)", },
		folderlinks = {
			{path = path, text = "Root"},
		},
		onopen = CommonCtrl.LocalSingleDocumentFrame._onopen
	};
	end
	ctl:Show(true);
	ctl.LocalSingleDocumentFrame = self;
	CommonCtrl.AddControl(name,ctl)
end
function LocalSingleDocumentFrame._onopen(ctrlName, filepath)
	local ctl = CommonCtrl.GetControl(ctrlName)
	if(ctl and ctl.LocalSingleDocumentFrame and filepath)then	
		local self = ctl.LocalSingleDocumentFrame;
		self:DoOpenDocument(filepath);
	end
end