--[[
Title: DoubleView has two states,one is list state and another is grid state.
Author(s): Leio Zhang
Date: 2008/3/26
Note: DoubleView based on TreeView and GridView
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/DoubleView.lua");
local data = {
				{name="item1",des="this is a discription",icon = nil},
				{name="item2",des="this is a discription",icon = nil},
				{name="item3",des="this is a discription",icon = nil},
				{name="item4",des="this is a discription",icon = nil},
				{name="item5",des="this is a discription",icon = nil},
				{name="item6",des="this is a discription",icon = nil},
				{name="item7",des="this is a discription",icon = nil},
				{name="item8",des="this is a discription",icon = nil},
				{name="item9",des="this is a discription",icon = nil},
				{name="item10",des="this is a discription",icon = nil}
			}
local doubleView = CommonCtrl.DoubleView:new();	
doubleView.DataContext = data;
doubleView.left = 100;
doubleView.top = 100;
doubleView.columns = 3;
doubleView.container_bg="Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4"
doubleView:Show();
-------------------------------------------------------
--]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

local DoubleView = {
	-- the top level control name
	name = "doubleview",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 400,
	height = 300,
	parent = nil,
	-- the background of container
	container_bg = nil,
	RootNode = nil,
	--default state
	State = "grid",--list or grid
	

	--about TreeView property
	DefaultIndentation = 5,
	DefaultNodeHeight = 40,
	DrawNodeHandler = nil,
	--about GridView property
	cellWidth = 100,
	cellHeight = 100,
	columns = 4,
	DrawCellHandler = nil,
	--about state menu property
	stateMenuHeight = 20,
	stateMenuWidth = 60,
	
	DataContext = nil,
	--event
	SeletedDataCallBack = nil
	}
CommonCtrl.DoubleView = DoubleView;

-- constructor
function DoubleView:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	-- create the root node
	o.RootNode = CommonCtrl.TreeNode:new({DoubleView = o, Name = "RootNode", 
	})
	
	CommonCtrl.AddControl(o.name, o);
	
	return o
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function DoubleView:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("TreeView instance name can not be nil\r\n");
		return
	end
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background=""
		
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		_this = _parent;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	
	
	self:CreateGridView();
	self:CreateTreeView();
	self:CreatStateMenu();
	if(self.State == "list")then
		CommonCtrl.MainMenu.OnClickTopLevelMenuItem(self.name.."statemenu", 1);
	else
		CommonCtrl.MainMenu.OnClickTopLevelMenuItem(self.name.."statemenu", 2);
	end
	self:UpdateState();
end
-- change state
function DoubleView.OnClick_stateMenu(treeNode)
	local self = CommonCtrl.GetControl(treeNode.ID);
	
	if(treeNode.Name=="List")then
		if (self.State == "grid")then			
			self.State = "list";
			self:UpdateState();
		end
	else
		if (self.State == "list")then
			self.State = "grid";
			self:UpdateState();
		end
	end
end
function DoubleView:UpdateState()
	local gridView = CommonCtrl.GetControl(self.name.."gridview");
	local treeView = CommonCtrl.GetControl(self.name.."treeview");
	
	if(self.State == "grid") then
		treeView:Show(false);
		gridView:Show(true);
		self:Update_GridView();
	else
		
		gridView:Show(false);
		treeView:Show(true);
		
		self:Update_TreeView();
	end
end
function DoubleView:CreatStateMenu()
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		log("error getting Double View parent\n");
		return
	end
	NPL.load("(gl)script/ide/MainMenu.lua");
	local ctl = CommonCtrl.GetControl(self.name.."statemenu");
	if(ctl==nil)then 
		ctl = CommonCtrl.MainMenu:new{
			name = self.name.."statemenu",
			alignment = "_rt",
			left = -90,
			top = 0,
			width = self.stateMenuWidth,
			height = self.stateMenuHeight,
			parent = _parent,
		};
		local node = ctl.RootNode;
		node:AddChild(CommonCtrl.TreeNode:new({Text = "List", Name = "List", ID = self.name, onclick = CommonCtrl.DoubleView.OnClick_stateMenu}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Grid", Name = "Grid", ID = self.name, onclick = CommonCtrl.DoubleView.OnClick_stateMenu}));
	else
		ctl.parent = _parent
	end	
	ctl:Show(true);
end

function DoubleView:CreateGridView()
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		log("error getting Double View parent\n");
		return
	end
	NPL.load("(gl)script/ide/GridView.lua");
	local ctl = CommonCtrl.GetControl(self.name.."gridview");
	if(not ctl) then
	local _DrawCellHandler;
	if(self.DrawCellHandler==nil)then
			_DrawCellHandler = CommonCtrl.DoubleView.OwnerDrawGridCellHandler;
			
	else
		_DrawCellHandler = self.DrawCellHandler;	
	end
	 ctl = CommonCtrl.GridView:new{
		name = self.name.."gridview",
		alignment = "_fi",
		container_bg = self.container_bg,
		left = 0, 
		top = 20,
		width = 0,
		height = 0,
		cellWidth = self.cellWidth,
		cellHeight = self.cellHeight,
		parent = _parent,
		columns = self.columns,
		rows = self.columns,
		DrawCellHandler = _DrawCellHandler,
	};
	else
		ctl.parent = _parent;
	end	
	--ctl:Show();
end

function DoubleView:CreateTreeView()
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		log("error getting Double View parent\n");
		return
	end
	NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl(self.name.."treeview");
		if(not ctl) then
			local _DrawNodeHandler;
			if(self.DrawNodeHandler ==nil)then
					
					_DrawNodeHandler = CommonCtrl.DoubleView.DrawNodeHandler ;
			else
					_DrawNodeHandler = self.DrawNodeHandler ;
			end
			ctl = CommonCtrl.TreeView:new{
				name = self.name.."treeview",
				alignment = "_fi",
				left = 0,
				top = 20,
				width = 0,
				height = 0,
				parent = _parent,
				container_bg = self.container_bg,
				DefaultIndentation = self.DefaultIndentation,
				DefaultNodeHeight = self.DefaultNodeHeight,	
				DrawNodeHandler = _DrawNodeHandler,
				
			};
		else
			ctl.parent = _parent;
		end	
		--ctl:Show();
end

-- fill data with treeView
function DoubleView:Update_TreeView()	
	local treeView = CommonCtrl.GetControl(self.name.."treeview");
	
	if(not self.DataContext)then return ; end;
	local node=treeView.RootNode;
	node:ClearAllChildren();
	for k,v in ipairs(self.DataContext) do	
		local name = v.name;
		--local des = v.des;
		--local icon = v.icon;
		local treeNode=node:AddChild( CommonCtrl.TreeNode:new({Text=name,Tag=v , Type="item"}) );
		
	end
	treeView:Update();
end

--fill data with gridView
function DoubleView:Update_GridView()
	local gridView = CommonCtrl.GetControl(self.name.."gridview");
	if(not self.DataContext)then return ; end;
	local len=table.getn(self.DataContext);
	local columns=self.columns;
	local rows=math.ceil(len/columns);
		  gridView.columns = columns;
		  gridView.rows = rows;
	gridView:ClearAllCells();
	for k,v in ipairs(self.DataContext) do	
		local name = v.name;
		--local des = v.des;
		--local icon = v.icon;
		local _column=math.mod(k,columns);
		if(_column==0)then _column=columns; end
		local _row=math.ceil(k/columns);
		local cell = CommonCtrl.GridCell:new{
		GridView = nil,
		name = name,
		text = name,
		column = _column,
		row = _row,
		-- template table
		Tag = v,
		};
		gridView:InsertCell(cell, "Right");
		
	end
	gridView:Update();
end

-- draw treeview node
function DoubleView.DrawNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	local width = nodeWidth;
	
	left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	
	local tag=treeNode.Tag;
	local name =tag.name;
	local des =tag.des;
	local icon = tag.icon;
	if(name==nil)then name=""; end
	if(des==nil)then des=""; end
	if(icon==nil)then icon="Texture/3DMapSystem/AppIcons/Intro_64.dds"; end
	if(treeNode.Type == "item") then
			local _this = ParaUI.CreateUIObject("button", "btn"..name, "_lt", left+3,top,32,32);
			_this.background = icon;
			_this.tooltip=des;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "b", "_lt", left+35, top,width-(left+35), height)
			
			if(treeNode.Selected)then
				_this.background = "Texture/alphadot.png"; -- high the selected line. 
			else
				_this.background = "";
				_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			end
			_this.text = name;
			_this.tooltip=name;
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			_this.onclick=string.format(";CommonCtrl.DoubleView.OnClickTreeNode(%q,%q);",treeNode.TreeView.name, treeNode:GetNodePath())
			_parent:AddChild(_this);
			
			
	end
end

-- draw girdview node
function DoubleView.OwnerDrawGridCellHandler(_parent, gridcell)
	if(_parent == nil or gridcell == nil) then
			return;
	end
		
		if(gridcell ~= nil) then
		
			local tag=gridcell.Tag;
			local name =tag.name;
			local des =tag.des;
			local icon = tag.icon;
			if(name==nil)then name=""; end
			if(des==nil)then des=""; end
			if(icon==nil)then icon="Texture/3DMapSystem/AppIcons/Intro_64.dds"; end
			
			local _this =nil;
					
			_this = ParaUI.CreateUIObject("container", "c", "_fi", 10, 10, 10, 10);
			_this.background = "";
			_parent:AddChild(_this);
			
			_parent=_this;
			_this = ParaUI.CreateUIObject("button", "b", "_lt", 0,0,64,64);
			_this.background = icon;
			_this.tooltip=name;
			_this.onclick = string.format([[;CommonCtrl.DoubleView.OnClickGridCell("%s", %d, %d);]], 
				gridcell.GridView.name, gridcell.row, gridcell.column);
			_parent:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("text", "t", "_lt", 0, 70,100, 40)			
			_this.text = name;			
			_parent:AddChild(_this);
	
		end
end

function DoubleView.OnClickTreeNode(sCtrlName, nodePath)
	local _,_,self_name = string.find(sCtrlName,"^(.+)treeview");
	local self = CommonCtrl.GetControl(self_name);
	if(not self)then return ; end;
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node) then
		node:SelectMe(true);
		local template = node.Tag;
		self.SeletedDataCallBack(template);
	end
end
function DoubleView.OnClickGridCell(gridviewName, row, column, bShow)
	local _,_,self_name = string.find(gridviewName,"^(.+)gridview");
	local self = CommonCtrl.GetControl(self_name);
	if(not self)then return ; end;
	local ctl=CommonCtrl.GetControl(gridviewName);
	if(ctl ~= nil) then
		local gridcell = ctl:GetCellByRowAndColumn(row, column);
		if(gridcell ~= nil) then
			local template = gridcell.Tag;
			self.SeletedDataCallBack(template);
		end
	end
end

function DoubleView:Update()
	local gridView = CommonCtrl.GetControl(self.name.."gridview");
	local treeView = CommonCtrl.GetControl(self.name.."treeview");
	
	if(self.State == "grid") then
		gridView:Update();
	else	
		treeView:Update();		
	end
end

function DoubleView.SeletedDataCallBack(data)
	--_guihelper.MessageBox(commonlib.serialize(data));
end
