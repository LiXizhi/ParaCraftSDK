--[[
Title: just open one folder and return its path
Author(s): Leio Zhang
Date: 2008/3/28, refactored 2008.5.11 LiXizhi
Note: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/OpenFolderDialog.lua");
local ctl = CommonCtrl.OpenFolderDialog:new{
	rootfolder = "worlds",
	selectedFolderPath = "worlds",
	OnSelected = function(sCtrlName, folderPath) end
};
ctl:Show();
-------------------------------------------------------
--]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
local L = CommonCtrl.Locale("IDE");

local OpenFolderDialog = {
	name = "OpenFolderDialog1",
	alignment = "_ct",
	left = -180,
	top = -200,
	width = 360,
	height = 400, 
	parent = nil,
	main_bg = nil,
	-- initial root folder name, such as "temp", "script/test",
	-- if this is nil, the first level children of rootNode will be expanded as child node. 
	-- The childNode.Name should contain the rootfolder instead. One can also implement owner draw function 
	-- for the first level root, such as in the open file dialog.
	rootfolder = "/",
	-- currently selected folder when user clicks ok. 
	selectedFolderPath = nil,

	--called when user clicked and selected a new folder. format is function(sCtrlName, folderPath) end
	OnSelected = nil,
	--private
	selectedNodePath = nil,
	treeViewName = nil,
}
CommonCtrl.OpenFolderDialog = OpenFolderDialog;
-- constructor
function OpenFolderDialog:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end

-- Destroy the UI control
function OpenFolderDialog:Destroy ()
	ParaUI.Destroy(self.name);
end

-- show window
function OpenFolderDialog:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("OpenFolderDialog instance name can not be nil\r\n");
		return
	end
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
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
		
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 6, 18, 137, 12)
		_this.text = "请选择一个目标作为路径";
		_parent:AddChild(_this);

		
		NPL.load("(gl)script/ide/FileExplorerCtrl.lua");
		local ctl = CommonCtrl.FileExplorerCtrl:new{
			name = self.name.."treeViewFolders",
			alignment = "_fi",
			left = 8,
			top = 42,
			width = 12,
			height = 59,
			parent = _parent,
			filter = "*.",
			rootfolder = self.rootfolder,
			AllowFolderSelection = true,
			--OnSelect = function(filepath) _guihelper.MessageBox(filepath);	end,
			--OnDoubleClick = nil,
		};
		ctl:Show(true);

		_this = ParaUI.CreateUIObject("button", "new_btn", "_lb", 13, -41, 100, 23)
		_this.text = "新建文件夹";
		_this.onclick = string.format(";CommonCtrl.OpenFolderDialog.NewFolder(%q);",self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "ok_btn", "_rb", -169, -41, 74, 23)
		_this.text = "确定";
		_this.onclick = string.format(";CommonCtrl.OpenFolderDialog.OnClickOK(%q);",self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "cancel_btn", "_rb", -86, -41, 74, 23)
		_this.text = "取消";
		_this.onclick = string.format(";CommonCtrl.OpenFolderDialog.OnClickCancel(%q);",self.name);
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;

		if(bShow) then
			_this:SetTopLevel(true);
		end
	end	

end

-- cancel window
function OpenFolderDialog.OnClickCancel(name)
	local self = CommonCtrl.GetControl(name);
	if(self == nil) then
		return;
	end
	self.selectedFolderPath = nil;
	self:Destroy();
end

-- user clicks OK.
function OpenFolderDialog.OnClickOK(name)
	local self = CommonCtrl.GetControl(name);
	if(self == nil) then
		return;
	end
	self.selectedFolderPath = self:GetValue();
	if(self.selectedFolderPath and self.selectedFolderPath~="") then
		if(type(self.OnSelected)=="function") then
			self.OnSelected(self.name, self.selectedFolderPath);
		end
	end
	self:Destroy();
end

-- get the current selected folder name
function OpenFolderDialog:GetValue()
	local folderCtl = CommonCtrl.GetControl(self.name.."treeViewFolders");
	if(folderCtl) then
		return folderCtl:GetValue();
	end
end

--create a new folder
function OpenFolderDialog.NewFolder(name)
	local self = CommonCtrl.GetControl(name);
	if(self == nil) then
		return;
	end
	
	local folderCtl = CommonCtrl.GetControl(self.name.."treeViewFolders");
	
	_guihelper.ShowDialogBox("新建文件夹", nil, nil, 268, 50, OpenFolderDialog.CreateDlg, function (dialogResult)
		if(dialogResult == _guihelper.DialogResult.OK) then
			local textfield = ParaUI.GetUIObject("OpenFolderDialog_name");
			local text = textfield.text;
			local errormsg,text = self:ValidateName(text);
			if(not errormsg)then
				if(folderCtl) then
					return folderCtl:CreateFolder(text);
				end
			else
				_guihelper.MessageBox(errormsg);
			end
		else
			return true;
		end
	end);
end

-- show create dialog
function OpenFolderDialog.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "DlgEditFolder", "_fi", 0,0,0,0)
	_this.background = "";
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 9, 20, 35, 12)
	_this.text = "名称:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("imeeditbox", "OpenFolderDialog_name", "_mt", 76, 17, 11, 21)
	_parent:AddChild(_this);
end

-- check the folder name if is valid
-- @return errorMsg, str:  errorMsg is nil if no error, otherwise the error message. Str is the corrected input
function OpenFolderDialog:ValidateName(str)
	local errormsg;
	-- trim start and end empty spaces
	str = string.gsub(str,"%s*$","");
	str = string.gsub(str,"^%s*","");
		
	if(string.find(str,"[%c~!@#$%%^&*()=+%[\\%]{}''\";:./?,><`|!￥…（）-、；：。，》《]")) then
		errormsg = "不能含有特殊字符\n"
	end
	if(string.len(str)<1) then
		errormsg = "名称太短\n"
	end
	
	return errormsg,str;
end
