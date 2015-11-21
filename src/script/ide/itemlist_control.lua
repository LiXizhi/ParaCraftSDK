--[[
Title: item-list control
Author(s): Liuweili,LiXizhi
Date: 2006/7/9
Desc: CommonCtrl.CCtrlItemList displays an item-list control that contains some icon items and show them in specific manner.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/itemlist_control.lua");
local ctl = CommonCtrl.CCtrlItemList:new{
	name = "KidUI_t_texture",
	parent = _parterrain,
	left = left, top = top, 
	width= (self.obj_btn_width+2)*4+2;
	height= self.obj_btn_width+4;
	columncount=4,
	items={
		[1] = {filename="A.dds"},
		[2] = {filename="B.dds"},
	},
	btnpool={},
	rowcount=1,
	placeholder="Texture/kidui/common/item_bg.png";
	onclick = CommonCtrl.CKidMiddleContainer.OnTerrainTexturePaint,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlItemList = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 182,
	height = 72,
	--the items to display, each item must contain a field called "filename".
	items={},
	--place holder image for the empty items
	placeholder="Texture/whitedot.png;0 0 0 0";
	btnpool={},
	--size of the items will be adjusted according to the columncount, rowcount, width, height and spacing.
	spacing=2,
	columncount=4,
	rowcount=1,
	curpage=1,
	button_animstyle = 0, -- item button animation style
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- a shared tooltip for all items
	tooltip = nil,
	-- the top level control name
	name = "defaultitemlist",
	-- onclick event, it can be nil or a function of type void ()(nIndex)
	onclick= nil
}
CommonCtrl.CCtrlItemList = CCtrlItemList;

-- constructor
function CCtrlItemList:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlItemList:Destroy()
	ParaUI.Destroy(self.name);
end

function CCtrlItemList:PageDown()
	if(self.curpage*self.columncount*self.rowcount<table.getn(self.items))then
		self.curpage=self.curpage+1;
		self:Update();
	end
end

function CCtrlItemList:PageUp()
	if(self.curpage>1)then 
		self.curpage=self.curpage-1;
		self:Update();
	end
end

function CCtrlItemList:Update()
	local index,_this,count;
	count=1;
	index=(self.curpage-1)*self.columncount*self.rowcount+1;
	while(self.items[index]~=nil and count<=self.columncount*self.rowcount)do
		_this=ParaUI.GetUIObject(self.name..count);
		if(_this:IsValid()) then
			if(self.items[index].filename~=nil) then
				_this.background=self.items[index].filename;
			else
				_this.background=self.placeholder;
			end
			_this.onclick=string.format([[;CommonCtrl.CCtrlItemList.OnItemClick("%s", %d);]],self.name,index);
			_this.enabled=true;
		end	
		count=count+1;
		index=index+1;
	end
	for i=count,self.columncount*self.rowcount do
		_this=ParaUI.GetUIObject(self.name..i);
		if(_this:IsValid()) then
			_this.background=self.placeholder;
			_this.onclick="";
			_this.enabled=false;
		end	
	end
end

function CCtrlItemList:Show()
	if(self.name==nil)then
		log("err showing CCtrlItemList\r\n");
	end
	local _this,_parent
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()==false)then
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		
		_this.background="Texture/whitedot.png;0 0 0 0";
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		_parent=_this;

		local itemwidth=(self.width-(self.columncount+1)*self.spacing)/self.columncount;
		if(itemwidth>(self.height-(self.rowcount+1)*self.spacing)/self.rowcount)then
			itemwidth=(self.height-(self.rowcount+1)*self.spacing)/self.rowcount;
		end
		
		local left,top=self.spacing,self.spacing;
		for i=1,self.rowcount do
			for j=1, self.columncount do
				_this=ParaUI.CreateUIObject("button",self.name..tostring((i-1)*self.columncount+j),self.alignment,left,top,itemwidth,itemwidth);
				_parent:AddChild(_this);
				_this.background=self.placeholder;
				_this.animstyle = self.button_animstyle;
				if(self.tooltip ~=nil)then
					_this.tooltip = self.tooltip;
				end	
				_this.enabled=false;
				left=left+self.spacing+itemwidth;
			end
			left=self.spacing;
			top=top+self.spacing+itemwidth;
		end
	end
	self:Update(self.name);
end

--[[ static method: called when a button is clicked. ]]
function CCtrlItemList.OnItemClick(sCtrlName, nButtonIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting CCtrlItemList instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(self.onclick~=nil)then
		if(type(self.onclick) == "string") then
			NPL.DoString(self.onclick);
		else
			self.onclick(nButtonIndex);
		end
	end
end