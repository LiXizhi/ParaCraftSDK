--[[
Title: vector-editor control
Author(s): Liuweili
Date: 2006/6/8
Desc: CommonCtrl.CCtrlVectorEditor displays a vector edit control with 2 to 4 editboxes to adjust x, y, z and w component of a vector
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/vectoreditor_control.lua");
local ctl= CommonCtrl.CCtrlVectorEditor:new ();
ctl.x = 1.0;
ctl.y = 1.0;
ctl.z = 1.0;
ctl.w = 1.0;
ctl.left = 0;
ctl.top = 0;
ctl.width = 182;
ctl.height = 72;
ctl.parent = nil;
ctl.name = "vectoredit";
ctl.onchange = nil;
ctl:Show(3);
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlVectorEditor = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 25,
	x = 1.0,
	y = 1.0,
	z = 1.0,
	w = 1.0,
	dimension = 3,
	isvertical = true,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "defaultvectoredit",
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName)
	onchange= nil
}
CommonCtrl.CCtrlVectorEditor = CCtrlVectorEditor;

-- constructor
function CCtrlVectorEditor:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlVectorEditor:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param sCtrlName: the vector-editor's name 
function CCtrlVectorEditor.Update(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local xname=self.name.."_x_edit";
	local yname=self.name.."_y_edit";
	local zname=self.name.."_z_edit";
	local wname=self.name.."_w_edit";
	local _this;
	_this=ParaUI.GetUIObject(xname);
	if(_this:IsValid())then 
		self.x=tonumber(_this.text);
		_this.text=tostring(self.x);
	end	
	_this=ParaUI.GetUIObject(yname);
	if(_this:IsValid())then 
		self.y=tonumber(_this.text);
		_this.text=tostring(self.y);
	end	
	_this=ParaUI.GetUIObject(zname);
	if(_this:IsValid())then 
		self.z=tonumber(_this.text);
		_this.text=tostring(self.z);
	end	
	_this=ParaUI.GetUIObject(wname);
	if(_this:IsValid())then 
		self.w=tonumber(_this.text);
		_this.text=tostring(self.w);
	end;
	if(self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(sCtrlName);
		end
	end
end
--@param sCtrlName: the vector-editor's name 
function CCtrlVectorEditor.InternalUpdate(sCtrlName,x,y,z,w)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local xname=self.name.."_x_edit";
	local yname=self.name.."_y_edit";
	local zname=self.name.."_z_edit";
	local wname=self.name.."_w_edit";
	local _this;
	_this=ParaUI.GetUIObject(xname);
	if(_this:IsValid() and x)then 
		self.x=x;
		_this.text=tostring(self.x);
	end	
	_this=ParaUI.GetUIObject(yname);
	if(_this:IsValid() and y)then 
		self.y=y;
		_this.text=tostring(self.y);
	end	
	_this=ParaUI.GetUIObject(zname);
	if(_this:IsValid() and z)then 
		self.z=z;
		_this.text=tostring(self.z);
	end	
	_this=ParaUI.GetUIObject(wname);
	if(_this:IsValid() and w)then 
		self.w=w;
		_this.text=tostring(self.w);
	end;
	return true;
end
function CCtrlVectorEditor:getVector(dimension)
	if(dimension==1)then
		return self.x;
	end
	if(dimension==2)then
		return self.x, self.y;
	end
	if(dimension==3)then
		return self.x, self.y, self.z;
	end
	if(dimension==4)then
		return self.x, self.y, self.z, self.w;
	end
end

--@param Dimension: default value is 3, if dimension = 1, x will be shown. if dimension = 2, x and y will be shown. so do z and w
--@param isvertical: whether to arrange the inputs in vertical
function CCtrlVectorEditor:Show(Dimension,isvertical)
	local _this,_parent;

	if(self.name==nil)then
		log("error creating CCtrlVectorEditor \r\n");	
	end
	if(Dimension~=nil)then
		self.dimension=tonumber(Dimension);
	end
	
	local xname=self.name.."_x_edit";
	local yname=self.name.."_y_edit";
	local zname=self.name.."_z_edit";
	local wname=self.name.."_w_edit";
		
	local width;
	local itemheight=25;
	local height=27;
	local xdelta,ydelta;
	if(isvertical~=nil)then
		self.isvertical=isvertical;
	end
	if(self.isvertical)then
		ydelta=27;
		xdelta=0;
		width=self.width;
		height=self.dimension*ydelta;
	else
		xdelta=70;
		ydelta=0;
		width=xdelta*self.dimension;
		height=27;
	end
	self.width = width;
	self.height = height;
	_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,width,height);
	
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
	local editorwidth = width - 20;
	if(self.dimension>0)then
		_this=ParaUI.CreateUIObject("text","static","_lt",left,top,20,itemheight);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.text="x:";
		_this=ParaUI.CreateUIObject("editbox",xname,"_lt",left+20,top,editorwidth,itemheight);
		_parent:AddChild(_this);
		_this.text=tostring(self.x);
		_this.background="Texture/box.png;";
		_this.onchange=string.format([[;CommonCtrl.CCtrlVectorEditor.Update("%s");]], self.name);
		left=left+xdelta;
		top=top+ydelta;
	end
	if(self.dimension>1)then
		_this=ParaUI.CreateUIObject("text","static","_lt",left,top,20,itemheight);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.text="y:";
		_this=ParaUI.CreateUIObject("editbox",yname,"_lt",left+20,top,editorwidth,itemheight);
		_parent:AddChild(_this);
		_this.text=tostring(self.y);
		_this.background="Texture/box.png;";
		_this.onchange=string.format([[;CommonCtrl.CCtrlVectorEditor.Update("%s");]], self.name);
		left=left+xdelta;
		top=top+ydelta;
	end
	if(self.dimension>2)then
		_this=ParaUI.CreateUIObject("text","static","_lt",left,top,20,itemheight);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.text="z:";
		_this=ParaUI.CreateUIObject("editbox",zname,"_lt",left+20,top,editorwidth,itemheight);
		_parent:AddChild(_this);
		_this.text=tostring(self.z);
		_this.background="Texture/box.png;";
		_this.onchange=string.format([[;CommonCtrl.CCtrlVectorEditor.Update("%s");]], self.name);
		left=left+xdelta;
		top=top+ydelta;
	end
	if(self.dimension>3)then
		_this=ParaUI.CreateUIObject("text","static","_lt",left,top,20,itemheight);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.text="w:";
		_this=ParaUI.CreateUIObject("editbox",wname,"_lt",left+20,top,editorwidth,itemheight);
		_parent:AddChild(_this);
		_this.text=tostring(self.w);
		_this.background="Texture/box.png;";
		_this.onchange=string.format([[;CommonCtrl.CCtrlVectorEditor.Update("%s");]], self.name);
		left=left+xdelta;
		top=top+ydelta;
	end
end