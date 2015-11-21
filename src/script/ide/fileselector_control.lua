--[[
Title: file-selector control
Author(s): Liuweili
Date: 2006/6/8
Desc: CommonCtrl.CCtrlFileSelector allows user to select and edit a file name.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/fileselector_control.lua");
local ctl = CommonCtrl.CCtrlFileSelector:new ();
ctl.name = "fileselector";
ctl.left=100;
ctl.top=100;
ctl.width=150;
ctl.isfileexist=nil;
ctl.opendialog=nil;
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlFileSelector = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 180,
	height = 25,
	oldfilename= "",
	filename = "",
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "defaultfileselector",
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName)
	onchange= nil,
	-- opendialog event, it can be nil or a function of type string ()(sFilename)
	-- it returns the selected file, with sFilename as the initial file name.
	opendialog = nil,
	-- isfileexist event, it can be nil or a function of type bool ()(sFilename)
	-- return true if the given file exists
	isfileexist = nil
}
CommonCtrl.CCtrlFileSelector = CCtrlFileSelector;

-- constructor
function CCtrlFileSelector:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlFileSelector:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param sCtrlName: the integer-editor's name 
function CCtrlFileSelector.Update(sCtrlName, sFilename)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	if(CCtrlFileSelector.InternalUpdate(sCtrlName,sFilename) and self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(sCtrlName);
		end
	end
end

--@param sCtrlName: the integer-editor's name 
function CCtrlFileSelector.InternalUpdate(sCtrlName, sFilename)
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
		if(sFilename~=nil)then
			if(self.isfileexist~=nil)then
				if(self.isfileexist(sFilename))then
					self.oldfilename=self.filename;
					self.filename=sFilename;
					
				end
			else
					self.oldfilename=self.filename;
				self.filename=sFilename;
			end
		else
			if(self.isfileexist~=nil)then
				if(self.isfileexist(_this.text))then
					self.oldfilename=self.filename;
					self.filename=_this.text;
				end
			else
				self.oldfilename=self.filename;
				self.filename=_this.text;
			end
		end
		_this.text=self.filename;
	end	
	return true;

end

function CCtrlFileSelector:Show()
	local _this,_parent;

	if(self.name==nil)then
		ParaGlobal.WriteToLogFile("err");	
	end
	
	local name=self.name.."_edit";
	if(self.width<50)then
		self.width=50;
	end
	local xratio=(self.width-25)/100;
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
	_this.text=self.filename;
	_this.background="Texture/box.png;";
	_this.onchange=string.format([[;CommonCtrl.CCtrlFileSelector.Update("%s",nil);]], self.name);
	left=left+100*xratio;
	_this=ParaUI.CreateUIObject("button","static","_lt",left,top,23,self.height-2);
	_parent:AddChild(_this);
	_this.text="...";
	_this.background="Texture/box.png;";
	_this.onclick=string.format([[;local _this=CommonCtrl.GetControl("%s");if(_this~=nil)then local str=_this.filename;if (_this.opendialog~=nil)then str=_this.opendialog(str);end;CommonCtrl.CCtrlFileSelector.Update("%s",str);end;]],self.name,self.name);
end
