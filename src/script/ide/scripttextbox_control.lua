--[[
Title: script textbox control
Author(s): LiXizhi
Date: 2006/6/8
Desc: CommonCtrl.CCtrlScriptTextBox allows user to select and edit a file name.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/scripttextbox_control.lua");
local ctl = CommonCtrl.CCtrlScriptTextBox:new {
	name = "fileselector";
	left=100, top=100, width=150;
	parent = nil,
	text = "",
	IsReadOnly=true,
	AutoReset=true,
}
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlScriptTextBox = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 180,
	height = 25,
	text = "",
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "defaultfileselector",
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName)
	-- when called text will be filled with the changed text
	onchange= nil,
	-- event called when the edit button is clicked.
	OnClickEdit= nil,
	-- event called when the user reset the text field. see AutoReset property
	OnReset = nil,
	-- whether it is read only
	IsReadOnly = false,
	-- when we invoke its editor, if the field is empty then the ResetField() will be automatically called, replace the empty string to its default value, and then open with the editor.
	AutoReset = true,
}
CommonCtrl.CCtrlScriptTextBox = CCtrlScriptTextBox;

-- constructor
function CCtrlScriptTextBox:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlScriptTextBox:Destroy ()
	ParaUI.Destroy(self.UIObject.name);
end

-- [static method]: event handler
--@param sCtrlName: the current control name 
function CCtrlScriptTextBox.On_TextChange(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local name=self.name.."_edit";
	local _this;
	_this=ParaUI.GetUIObject(name);
	if(_this:IsValid())then 
		if(self.onchange~=nil)then
			self.text=_this.text;
			if(type(self.onchange) == "string") then
				NPL.DoString(self.onchange);
			else
				self.onchange(sCtrlName);
			end
		end
	end
end

--by liuweili
-- [static method]: event handler
--@param sCtrlName: the current control name 
function CCtrlScriptTextBox.InternalUpdate(sCtrlName, text)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local name=self.name.."_edit";
	local _this;
	_this=ParaUI.GetUIObject(name);
	if(_this:IsValid() and text~=nil)then 
		self.text=text;
		_this.text=text;
		return true;
	end	
	
end
-- [static method]: event handler
--@param sCtrlName: the current control name 
function CCtrlScriptTextBox.On_EditBtnClick(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	local name=self.name.."_edit";
	local _this;
	_this=ParaUI.GetUIObject(name);
	if(_this:IsValid())then 
		if(self.AutoReset == true and self.OnReset~=nil and not self.IsReadOnly and  _this.text == "") then
			if(type(self.OnReset) == "string") then
				NPL.DoString(self.OnReset);
			else
				self.OnReset(sCtrlName);
			end
			-- since text may be reset, we will update it again.
			if(self.IsReadOnly ==false) then
				_this.text = self.text;
			end
		end
		if(self.OnClickEdit~=nil)then
			if(type(self.OnClickEdit) == "string") then
				NPL.DoString(self.OnClickEdit);
			else
				self.OnClickEdit(sCtrlName);
			end
		end
	end	
end

-- display the control
function CCtrlScriptTextBox:Show()
	local _this,_parent;

	if(self.name==nil)then
		log("CCtrlScriptTextBox control name not specified\r\n");	
	end
	
	local name=self.name.."_edit";
	if(self.width<50)then
		self.width=50;
	end
	local xratio=(self.width-40)/100;
	_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
	_this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
	
	if(self.parent==nil) then
		_this:AttachToRoot();
	else
		self.parent:AddChild(_this);
	end
	CommonCtrl.AddControl(self.name, self);
	local left,top;
	left=1;top=1;
	_parent=_this;
	_this=ParaUI.CreateUIObject("editbox",name,"_lt",left,top,100*xratio,self.height-2);
	_parent:AddChild(_this);
	_this.text=tostring(self.text);
	_this.background="Texture/box.png;";
	_this.readonly= self.IsReadOnly;
	_this.onchange=string.format([[;CommonCtrl.CCtrlScriptTextBox.On_TextChange("%s")]], self.name);
	left=left+100*xratio;
	_this=ParaUI.CreateUIObject("button","static","_lt",left,top,40,self.height-2);
	_parent:AddChild(_this);
	_this.text="open";
	_this.background="Texture/box.png;";
	_this.onclick=string.format([[;CommonCtrl.CCtrlScriptTextBox.On_EditBtnClick("%s")]],self.name);
end
