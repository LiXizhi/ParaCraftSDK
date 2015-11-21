--[[
Title: GridView3D is a mini scene graph based render target showing 
		3D contents in 2D container UI
Author(s): WangTian
Date: 2009/1/21
Note: This control is solely for all the matrix alike controls including BCS, CCS, Creation panel, CartoonFace .etc
		Unlike Treeview and GridView, GridView3D slider heavily depends on the mini scene camera move.
		
		Current version only supports the same width and height GridCell3D defined in the GridView3D
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/GridView3D.lua");
local ctl = CommonCtrl.GridView3D:new{
	...
-------------------------------------------------------
--]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");


------------------------------------------------------------
-- Grid Cell 3D
------------------------------------------------------------

-- Represents a cell of a GridView3D. 
local GridCell3D = {
	---- Gets the parent tree node of the current tree node. 
	--parent = nil, 
	-- Gets the ancister grid view that the grid cell is assigned to. 
	GridView3D = nil,
	-- Gets or sets the name of the grid cell.
	name = nil,
	-- Gets or sets the text displayed in the label of the grid cell. 
	text = nil,
	-- column index of this cell in the GridView3D, from 1
	column = nil,
	-- row index of this cell in the GridView3D, from 1
	row = nil,
	
	
	------ Gets the zero-based depth of the tree node in the TreeView control 
	----Level = 0,  
	------ Gets the array of TreeNode objects assigned to the current tree node.
	----Nodes = nil,
	------ Gets a value indicating whether the tree node is in the expanded state. 
	----Expanded = true,
	---- Gets a value indicating whether the grid cell is in the selected state. 
	--Selected = nil, 
	---- if true, node is invisible.
	--Invisible = nil,
	---- Gets or sets the URL to navigate to when the cell is clicked. 
	--NavigateUrl = nil, 
	---- Gets or sets a non-displayed value used to store any additional data about the cell, such as data used for handling postback events. 
	--Value = nil,
	---- Gets or sets the object that contains data about the grid cell. 
	--Tag = nil,
	---- Gets or sets the text that appears when the mouse pointer hovers over a grid cell. 
	--ToolTipText = nil,
	---- icon texture file
	--Icon = nil,
	------ Gets or sets the key for the image associated with this tree node when the node is in an unselected state. 
	------ this can be a index which index into TreeView.ImageList[ImageKey] or it can be a string of image file path or URL.
	----ImageKey = nil,
	------ Gets or sets the key of the image displayed in the tree node when it is in a selected state.
	------ this can be a index which index into TreeView.ImageList[ImageKey] or it can be a string of image file path or URL.
	----SelectedImageKey = nil,  
	------ Width of this grid cell, if this is nil, GridView3D.DefaultCellWidth will be used
	----CellWidth = nil,
	------ Height of this grid cell, if this is nil, GridView3D.DefaultCellHeight will be used
	----CellHeight = nil,
	---- string to be executed or a function of format function FuncName(gridCell) end
	--onclick = nil,
	
	
	--------------------------------
	-- internal parameters, do not use externally
	--------------------------------
	-- logical position of the node relative to the grid view container. 
	logicalX = 0,
	logicalY = 0,
	
	
	---- logical position for the right bottom corner of this cell
	--logicalRight = 0,
	--logicalBottom = 0,
	---- internal column index of this cell. such that ... 
	--indexColumn = 0,
	---- internal row index of this cell. such that ... 
	--indexRow = 0,
	---- render column index
	--columnindex = 0,
	---- render row index
	--rowindex = 0,
}
CommonCtrl.GridCell3D = GridCell3D;

-- constructor
function GridCell3D:new (o)
	o = o or {};  -- create object if user does not provide one
	--o.Nodes = {};
	
	setmetatable(o, self);
	self.__index = self;
	return o
end

function GridCell3D:GetWidth()
	return self.GridCell3D.cellWidth;
end

function GridCell3D:GetHeight()
	return self.GridCell3D.cellHeight;
end


-- get a string containing the cell coordinate
-- as long as the GridView3D does not change, the cell coordinate uniquely identifies a GridCell.
-- @return: row, column
function GridCell3D:GetCellCoord()
	if(self.row ~= nil and self.column ~= nil) then
		return self.row, self.column;
	end
end

-- get the sibling Up/Down/Left/Right cell 
function GridCell3D:GetSiblingCellUp()
	local row = self.row;
	local column = self.column;
	if(row >= 1) then
		return self.GridView3D:GetCellByRowAndColumn(row - 1, column);
	end
end

function GridCell3D:GetSiblingCellDown()
	local row = self.row;
	local column = self.column;
	if(row <= self.GridView3D.rows) then
		return self.GridView3D:GetCellByRowAndColumn(row + 1, column);
	end
end

function GridCell3D:GetSiblingCellLeft()
	local row = self.row;
	local column = self.column;
	if(column >= 1) then
		return self.GridView3D:GetCellByRowAndColumn(row, column - 1);
	end
end

function GridCell3D:GetSiblingCellRight()
	local row = self.row;
	local column = self.column;
	if(column <= self.GridView3D.columns) then
		return self.GridView3D:GetCellByRowAndColumn(row, column + 1);
	end
end



------------------------------------------------------------
-- GridView3D
------------------------------------------------------------

-- GridView3D is a container showing 2 dimensional array of data in matrix display form.
local sampleGridView3D = {
	-- the top level control name
	name = "GridView3D1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 300, 
	--buttonwidth = 20, -- the drop down button width
	--dropdownheight = 150, -- the drop down list box height.
	parent = nil,
	-- appearance
	container_bg = nil, -- the background of container
	main_bg = "", -- the background of container without scrollbar, default to full transparent
	---- automatically display vertical scroll bar when content is large
	--AutoVerticalScrollBar = true,
	---- automatically display horizontal scroll bar when content is large
	--AutoHorizontalScrollBar = true,
	---- Vertical ScrollBar Width
	--VerticalScrollBarWidth = 15,
	---- Horizontal ScrollBar Width
	--HorizontalScrollBarWidth = 15,
	---- how many pixels to scroll each time
	--VerticalScrollBarStep = 3,
	---- how many pixels to scroll each time
	--HorizontalScrollBarStep = 3,
	---- how many pixels to scroll when user hit the empty space of the scroll bar.
	----		this is usually same as DefaultCellHeight
	--VerticalScrollBarPageSize = 48,
	---- how many pixels to scroll when user hit the empty space of the scroll bar.
	----		this is usually same as DefaultCellWidth
	--HorizontalScrollBarPageSize = 48,
	---- The root tree node. containing all tree node data
	--RootNode = nil, 
	
	
	-- row data containing all the gridcell3ds organized in rows
	-- table indexed by rows
	-- each row table contains a subtable indexed by columns, each entry is a grid cell
	-- both index from 1
	cells = {};
	
	-- number of columns in the GridView3D
	columns = nil,
	-- number of rows in the GridView3D
	rows = nil,
	
	-- cell width and cell height
	-- NOTE: Current version only supports the same width and height GridCell3D defined in the GridView3D
	cellWidth = 36,
	cellHeight = 36,
	
	-- cell padding between neighbor cells
	cellPadding = 4,
	
	-- different with the tree view
	defaultCellWidth = 24,
	defaultCellHeight = 24,
	
	-- render target size specified for mini scene graph
	-- NOTE: some control width and height need to be adjusted on the fly, user can assign 
	--		the render target size to the largest size
	-- must be power of two
	renderTargetSize = 256,
	
	-- Gets or sets a function by which the individual GridCell3D control is drawn. The function should be of the format:
	-- function DrawCellEventHandler(parent,gridcell3d) end, where parent is the parent container in side which contents should be drawn.
	--		And GridCell3D is the GridCell3D object to be drawn
	-- if DrawCellHandler is nil, the default GridView3D.DrawNormalCellHandler function will be used.
	DrawCellHandler = nil, -- function(_parent, cell, filename)
	
	
	
	
	---- default icon size
	--defaultIconSize = 16,
	---- whether to show icon on the left of each line. 
	--showIcon = true,
	---- default indentation
	--DefaultIndentation = 5,
	---- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	---- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	---- if DrawNode is nil, the default GridView3D.DrawNormalNodeHandler function will be used. 
	--DrawNodeHandler = nil,
	---- Cache size: The number of TreeNode controls to be cached. [N/A]
	--CacheSize = 30,
	---- Force no clipping or always using fast render. Unless you know that the unit scroll step is interger times of all TreeNode height. You can disable clipping at your own risk. 
	---- Software clipping is always used to clip all invisible TreeNodes. However, this option allows you to specify whether to use clipping for partially visible TreeNode. 
	--NoClipping = nil,
	---- a function of format function FuncName(treeNode) end or nil
	--onclick = nil,
	----------------------------------
	---- internal parameters, do not use externally
	----------------------------------
	---- top left cell and bottom right cell mainly for the horizontal and vertical scroll bar available
	--TopLeftCell = nil,
	--BottomRightCell = nil,
	---- the client area X, Y position in pixels relative to the logical tree view container. 
	--ClientX = 0,
	--ClientY = 0,
	-- this is automatically set according to whether a scroll bar is available.
	clientWidth = 10,
	clientHeight = 10,
	---- a mapping from node path to existing line control container index, the total number of mapping here does not exceed CacheSize
	--NodeUIContainers = {},
}

local GridView3D = {};
CommonCtrl.GridView3D = GridView3D;


-- constructor
function GridView3D:new (o)
	o = o or {}   -- create object if user does not provide one
	
	-- create the cells table for holding GridCell3Ds
	if(not o.cells) then
		o.cells = {};
	end
	
	---- width and height of each grid cell, if this is nil, 
	-- GridView3D.defaultCellWidth and GridView3D.defaultCellHeight will be used
	if(o.cellWidth == nil) then
		o.cellWidth = GridView3D.defaultCellWidth;
	end
	if(o.cellHeight == nil) then
		o.cellHeight = GridView3D.defaultCellHeight;
	end
	
	setmetatable(o, self);
	self.__index = self;
	
	CommonCtrl.AddControl(o.name, o);
	
	return o;
end


function GridView3D:Destroy()
	--CommonCtrl.DeleteControl(self.name);
	ParaUI.Destroy(self.name.."_GridView3D");
	self:GetMiniSceneGraph():Reset();
	---- kill timer
	--NPL.KillTimer(self.timerID);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function GridView3D:Show(bShow)
	local _this, _parent;
	if(self.name == nil)then
		log("GridView3D instance name can not be nil\r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name.."_GridView3D");
	if(_this:IsValid() == false) then
	
		_this = ParaUI.CreateUIObject("container", self.name.."_GridView3D", self.alignment, self.left, self.top, self.width, self.height);
		if(self.container_bg ~= nil) then
			_this.background = self.container_bg;
		else
			_this.background = "";
		end	
		
		_parent = _this;
		
		if(self.parent == nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		_this = ParaUI.CreateUIObject("container", self.name.."_Canvas", "_fi", 0, 0, 0, 0);
		_this.background = "";
		_parent:AddChild(_this);
		
		-- DEBUG purpose
		--self:InitMiniSceneGraphCanvas();
		
		
		NPL.load("(gl)script/ide/GridView.lua");
		local function OwnerDrawGridCellHandler(_parent, gridcell)
			if(_parent == nil or gridcell == nil) then
				return;
			end
			
			--if(gridcell ~= nil) then
				--local _this = ParaUI.CreateUIObject("button", gridcell.row.."-"..gridcell.column, "_lt", 0, 0, self.cellWidth, self.cellHeight);
				--_this.onclick = string.format([[;GridView3D.Click2DGridView("%s","%s","%s");]], gridcell.GridView.name, gridcell.row, gridcell.column);
				--_parent:AddChild(_this);
			--end
		end
		
		CommonCtrl.DeleteControl(self.name.."_GridView3D_SecretGridView");
		
		local ctl = CommonCtrl.GridView:new{
			name = self.name.."_GridView3D_SecretGridView",
			alignment = self.alignment,
			container_bg = "",
			left = self.left,
			top = self.top,
			width = self.width,
			height = self.height,
			cellWidth = self.cellWidth + self.cellPadding,
			cellHeight = self.cellHeight + self.cellPadding,
			parent = self.parent,
			columns = self.columns,
			rows = self.rows,
			DrawCellHandler = OwnerDrawGridCellHandler,
		};
		
		local i, j;	
		for i = 0, self.rows do
			for j = 0, self.columns do
				local cell = CommonCtrl.GridCell:new{
					GridView = nil,
					name = i.."-"..j,
					text = i.."-"..j,
					column = j+1,
					row = i+1,
					};
				ctl:InsertCell(cell, "Right");
			end
		end
		
		ctl:Show();
		
		
		-- update the GridView3D on creation
		self:Update();
		
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
		-- TODO: turn on and off the force render
	end	
end

--function GridView3D.Click2DGridView(secretName, row, column)
	--local s = string.find(secretName, "_GridView3D_SecretGridView");
	--if(s ~= nil) then
		--local secret = string.sub(secret, 1, s-1);
		--secretName, row, column
	--end
--end

---------------------------------------
-- use precomputer miniscenegraph 
---------------------------------------

--if(not GridView3D.LastTimerID) then GridView3D.LastTimerID = 4521; end
--function GridView3D:SetMiniSceneTimer()
	---- register a timer for GridView3D update
	--NPL.SetTimer(GridView3D.LastTimerID + 1, 0.05, ";CommonCtrl.GridView3D.OnMiniSceneTimer(\""..self.name.."\");");
	--self.timerID = GridView3D.LastTimerID + 1;
	--GridView3D.LastTimerID = GridView3D.LastTimerID + 1;
	----NPL.SetTimer(235, 0.05, ";Map3DSystem.UI.MiniMapWnd.OnMiniMapTimer();");
--end
--
--function GridView3D.OnMiniSceneTimer(name)
	--local ctl = CommonCtrl.GetControl(name);
	--if(ctl ~= nil) then
		--local scene = ctl:GetMiniSceneGraph();
		--scene:Draw(0.05);
	--end
--end

function GridView3D:GetMiniSceneGraph()
	return ParaScene.GetMiniSceneGraph(self.name.."_GridView3D_MiniScene");
end

-- create and initialize the mini map mini scene graph
-- NOTE: one time init
function GridView3D:InitMiniSceneGraphCanvas()
	
	
	--Map3DSystem.UI.MiniMapWnd.SetMiniMapTimer();
	
	-------------------------
	-- a simple 3d scene using mini scene graph
	-------------------------
	local scene = self:GetMiniSceneGraph();
	
	------------------------------------
	-- init render target
	------------------------------------
	-- set size
	-- TODO: set the size according to the absolute size of the gridview3d container
	
	local _parent = ParaUI.GetUIObject(self.name.."_GridView3D");
	if(not _parent:IsValid()) then
		log("error: getting Grid View parent\n");
		return;
	end
	
	local _, _, GridView3DWidth, GridView3DHeight = _parent:GetAbsPosition();
	self.clientWidth = GridView3DWidth;
	self.clientHeight = GridView3DHeight;
	
	-- use cell width and height as the storage unit size
	--local maxSize = math.max(GridView3DHeight, GridView3DWidth);
	local maxSize = math.max(self.cellWidth, self.cellHeight);
	
	if(self.renderTargetSize) then
		-- set the render target to user specified size
		scene:SetRenderTargetSize(self.renderTargetSize, self.renderTargetSize);
		self.miniSceneGraphRenderSize = self.renderTargetSize;
	elseif(maxSize <= 8) then
		log("warning: are you seriously using GridView3D? client size too small.\n");
	elseif(maxSize <= 16) then
		scene:SetRenderTargetSize(16, 16);
		self.miniSceneGraphRenderSize = 16;
	elseif(maxSize <= 32) then
		scene:SetRenderTargetSize(32, 32);
		self.miniSceneGraphRenderSize = 32;
	elseif(maxSize <= 64) then
		scene:SetRenderTargetSize(64, 64);
		self.miniSceneGraphRenderSize = 64;
	elseif(maxSize <= 128) then
		scene:SetRenderTargetSize(128, 128);
		self.miniSceneGraphRenderSize = 128;
	elseif(maxSize <= 256) then
		scene:SetRenderTargetSize(256, 256);
		self.miniSceneGraphRenderSize = 256;
	elseif(maxSize <= 512) then
		scene:SetRenderTargetSize(512, 512);
		self.miniSceneGraphRenderSize = 512;
	elseif(maxSize <= 1024) then
		scene:SetRenderTargetSize(1024, 1024);
		self.miniSceneGraphRenderSize = 1024;
	else
		log("warning: are you seriously using GridView3D? client size too large.\n");
	end
	
	-- reset scene, in case this is called multiple times
	scene:Reset();
	-- enable camera and create render target
	scene:EnableCamera(true);
	-- render it each frame by timer
	-- Note: If content is static, one should disable this, and call scene:Draw() in a script timer.
	scene:EnableActiveRendering(false);
	-- Set minimap mask
	--scene:SetMaskTexture(ParaAsset.LoadTexture("","anything you want.dds",1));
	
	local att = scene:GetAttributeObject();
	--att:SetField("BackgroundColor", {1, 1, 1});  -- use new semitransparent background
	att:SetField("ShowSky", true);
	att:SetField("EnableFog", false);
	att:SetField("FogColor", {1, 1, 1});
	att:SetField("FogStart", 5);
	att:SetField("FogEnd", 25);
	att:SetField("FogDensity", 1);
	att:SetField("EnableLight", true);
	att:SetField("EnableSunLight", true);
	scene:SetTimeOfDaySTD(0);
	
	-- set the mini map scene to semitransparent background color
	--scene:SetBackGroundColor("255 255 255 150");
	scene:SetBackGroundColor("255 255 255 0");
	
	--scene:Draw(0.05);
	------------------------------------
	-- init camera
	------------------------------------
	
	---- 256
	--scene:CameraSetLookAtPos(12.8, -12.8, 0);
	--scene:CameraSetEyePosByAngle(0, 0, 48);
	
	-- current
	scene:CameraSetLookAtPos(self.miniSceneGraphRenderSize / 20, - self.miniSceneGraphRenderSize / 20, 0);
	scene:CameraSetEyePosByAngle(0, 0, self.miniSceneGraphRenderSize * 48 / 256);
	
	
	--------------------------------------
	---- assign the texture to gridview3d canvas UI
	--------------------------------------
	--local _gridview = ParaUI.GetUIObject(self.name.."_GridView3D");
	--local _canvas = _gridview:GetChild(self.name.."_Canvas");
	--
	--if(_canvas:IsValid()) then
		----_canvas:SetBGImage(scene:GetTexture());
		--_canvas:SetBGImageAndRect(scene:GetTexture(), 0, 0, self.clientWidth, self.clientHeight);
		----_canvas:SetBGImageAndRect(scene:GetTexture(), 0, 0, 256, 256);
	--end
	
	
	--
	--local _assetRed = ParaAsset.LoadStaticMesh("", "model/test/ryb/red/red.x");
	--local _assetBlue = ParaAsset.LoadStaticMesh("", "model/test/ryb/blue/blue.x");
	--local _assetYellow = ParaAsset.LoadStaticMesh("", "model/test/ryb/yellow/yellow.x");
	--
	---- create mini scene object
	--local obj;
	--obj = ParaScene.CreateMeshPhysicsObject("x0_y0", _assetBlue, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	--if(obj:IsValid()) then
		--obj:SetPosition(0, 0, 0);
		----obj:SetScale(10);
		--obj:GetAttributeObject():SetField("progress", 1);
		--scene:AddChild(obj);
	--end
	--obj = ParaScene.CreateMeshPhysicsObject("x1_y0", _assetYellow, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	--if(obj:IsValid()) then
		--obj:SetPosition(25.6, 0, 0);
		----obj:SetScale(10);
		--obj:GetAttributeObject():SetField("progress", 1);
		--scene:AddChild(obj);
	--end
	--obj = ParaScene.CreateMeshPhysicsObject("x0_y1", _assetRed, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	--if(obj:IsValid()) then
		--obj:SetPosition(0, -25.6, 0);
		----obj:SetScale(10);
		--obj:GetAttributeObject():SetField("progress", 1);
		--scene:AddChild(obj);
	--end
	--obj = ParaScene.CreateMeshPhysicsObject("x1_y1", _assetRed, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	--if(obj:IsValid()) then
		--obj:SetPosition(25.6, -25.6, 0);
		----obj:SetScale(10);
		--obj:GetAttributeObject():SetField("progress", 1);
		--scene:AddChild(obj);
	--end
	--obj = ParaScene.CreateMeshPhysicsObject("x1_y21", _assetRed, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	--if(obj:IsValid()) then
		--obj:SetPosition(6.4, -6.4, 0);
		----obj:SetScale(10);
		--obj:GetAttributeObject():SetField("progress", 1);
		--scene:AddChild(obj);
	--end
	
	
	
	--scene:Draw(0.05);
	
	
	
	-- NOTE: test CCS preview model with replaceable texture 
	--
	--local _assetName = "model/common/ccs_unisex/shirt06_TU1_TL2_AU3_AL4.x";
	--local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	--obj = ParaScene.CreateMeshPhysicsObject("fddewqsa", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	--if(obj:IsValid()) then
		--obj:SetFacing(1.57);
		--obj:GetAttributeObject():SetField("progress", 1);
		--
		--local aabb = {};
		--_asset:GetBoundingBox(aabb);
		--local dx = math.abs(aabb.max_x - aabb.min_x);
		--local dy = math.abs(aabb.max_y - aabb.min_y);
		--local dz = math.abs(aabb.max_z - aabb.min_z);
		--
		--local max = math.max(dx, dy);
		--max = math.max(max, dz);
		--
		--obj:SetPosition(3.2, -6.4, 0);
		--obj:SetScale(6.4/max);
		--local att = obj:GetAttributeObject();
		--att:SetField("render_tech", 10);
		--
		--scene:AddChild(obj);
	--end
	--
	--local _TL = "character/v3/Item/TextureComponents/TorsoLowerTexture/MomoMale05_he_TL_U.DDS"
	--local _TU = "character/v3/Item/TextureComponents/TorsoUpperTexture/MomoMale05_he_TU_U.DDS"
	--local _AL = "character/v3/Item/TextureComponents/ArmLowerTexture/MomoMale05_he_AL_U.DDS"
	--local _AU = "character/v3/Item/TextureComponents/ArmUpperTexture/MomoMale05_he_AU_U.DDS"
	--
	---- apply the texture
	--local texture_TU = ParaAsset.LoadTexture("", _TU, 1);
	--local texture_TL = ParaAsset.LoadTexture("", _TL, 1);
	--local texture_AU = ParaAsset.LoadTexture("", _AU, 1);
	--local texture_AL = ParaAsset.LoadTexture("", _AL, 1);
	--obj:SetReplaceableTexture(1, texture_TU);
	--obj:SetReplaceableTexture(2, texture_TL);
	--obj:SetReplaceableTexture(3, texture_AU);
	--obj:SetReplaceableTexture(4, texture_AL);
	
	-------------------------
	-- register a timer for GridView3D MiniScene update
	-------------------------
	
	---- TODO: lazy render when the gridview3d control is not visible
	--self:SetMiniSceneTimer();
end

-- this function should be called whenever the layout of the grid view changed. 
-- internally, it will recalculate all cell logical positions.
-- TODO: @param ShowCell: nil or a GridCell3D. It will automaticly scroll for the best show of the cell element.
function GridView3D:Update()
	-- update all cell logical positions
	--self.RootNode:Update(0,0);
	
	local _parent = ParaUI.GetUIObject(self.name.."_GridView3D");
	if(not _parent:IsValid()) then
		log("error: getting Grid View parent\n");
		return
	end
	
	-- generate the precomputed mini scene graph textures during grid cell traversal
	
	---- calculate the logical position of every GridCell3D
	--self:UpdateLogicalPosition();
	
	
	---- NOTE: the client width and height is calculated in function GridView3D:InitMiniSceneGraphCanvas()
	--local _, _, GridView3DWidth, GridView3DHeight = _parent:GetAbsPosition();
	--self.clientWidth = GridView3DWidth;
	--self.clientHeight = GridView3DHeight;
	
	
	-- create an object for each GridCell3D
	local i, j;
	for i = 1, self.rows do
		-- each row
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					---- create an object for GridCell3D owner draw
					--local obj = ParaScene.CreateMeshPhysicsObject(cell.row.."-"..cell.column, "", 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
					--if(obj:IsValid()) then
						--obj:SetFacing(1.57); -- face gridview mini scene camera
						--obj:GetAttributeObject():SetField("progress", 1);
						--
						----local aabb = {};
						----_asset:GetBoundingBox(aabb);
						----local dx = math.abs(aabb.max_x - aabb.min_x);
						----local dy = math.abs(aabb.max_y - aabb.min_y);
						----local dz = math.abs(aabb.max_z - aabb.min_z);
						----
						----local maxBox = math.max(dx, dy);
						----maxBox = math.max(maxBox, dz);
						----
						----local minSize = math.max(self.cellWidth, self.cellHeight);
						--
						--obj:SetPosition(cell.logicalX, cell.logicalY, 0);
						----obj:SetScale(minSize/10/maxBox);
						--local att = obj:GetAttributeObject();
						--att:SetField("render_tech", 10);
						--
						--scene:AddChild(obj);
					--end
					
					local cell = self.cells[i][j];
					
					-- save the texture to the temp directory
					-- generate precomputed texture name
					function GenerateName(gridcell)
						-- gridview name, row and column, model name, texture name
						
						local modelName = string.gsub(gridcell.Model, "/", "+");
						
						-- create the folder in the temp directory if not exists
						ParaIO.CreateDirectory("temp/textures/gridview/");
						
						local name;
						name = string.format("temp/textures/gridview/%s-%s-%s-%s-%s-%s-",
							gridcell.GridView3D.name, 
							gridcell.row, 
							gridcell.column, 
							gridcell.cellWidth, 
							gridcell.cellHeight, 
							modelName --"" --gridcell.Model
						);
						
						local skinNames = "";
						--for k, v in ipairs(gridcell.Skin) do
							--skinNames = skinNames.."#T"..k.."#"..v;
						--end
						
						name = name..skinNames..".dds";
						return name
					end
					
					local filename = GenerateName(cell);
					
					if(filename~=nil and ParaIO.DoesFileExist(filename)==true) then
						-- file exists, use the precomputed texture
					else
						-- file not exists, compute the texture and save the file on disk
						local model, skin;
						model = cell.Model;
						skin = cell.Skin;
						
						local _asset = ParaAsset.LoadStaticMesh("", model);
						local obj = ParaScene.CreateMeshPhysicsObject(cell.column.."-"..cell.row, _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
						if(obj:IsValid()) then
							obj:SetFacing(1.57);
							obj:GetAttributeObject():SetField("progress", 1);
							
							-- the object is fixed into a 1x1x1 bounding volumn with the center at the coordinate origin
							local aabb = {};
							_asset:GetBoundingBox(aabb);
							local dx = math.abs(aabb.max_x - aabb.min_x);
							local dy = math.abs(aabb.max_y - aabb.min_y);
							local dz = math.abs(aabb.max_z - aabb.min_z);
							
							local max = math.max(dx, dy);
							max = math.max(max, dz);
							obj:SetScale(1.0/max);
							--obj:SetScale(6.4/max);
							
							--local offsetX = -(aabb.max_x + aabb.min_x) * 5;
							--local offsetY = -(aabb.max_y + aabb.min_y) * 5;
							local offsetX = -(aabb.max_x + aabb.min_x) * -11;
							local offsetY = -(aabb.max_y + aabb.min_y) * 3;
							
							obj:SetPosition(0, 0, 0);
							--obj:SetPosition(3.2, -6.4, 0);
							local att = obj:GetAttributeObject();
							att:SetField("render_tech", 9);
							
							if(type(skin) == "table") then
								local k, v;
								for k, v in pairs(skin) do
									local _texture = ParaAsset.LoadTexture("", v, 1);
									obj:SetReplaceableTexture(k, _texture);
								end
							end
							
							local scene = self:GetMiniSceneGraph();
							scene:Reset(); -- simply remove all
							self:InitMiniSceneGraphCanvas();
							
							scene:AddChild(obj);
							
							-- set camera position and rotation
							
							scene:CameraSetLookAtPos(0, 0, 0);
							scene:CameraSetEyePosByAngle(0, 0, 2);
							
							scene:Draw(0.05);
							
							scene:SaveToFile(filename, self.miniSceneGraphRenderSize);
							
							--scene:RemoveObject(obj);
							
							--LookAtPosX
							--LookAtPosY
							--LookAtPosZ
							--RotY
							--LiftupAngle
							--CameraObjectDist
							--fRotY  rotation of the camera around the Y axis, in the world coordinate.  
							 --fLiftupAngle  lift up angle of the camera.  
							 --fCameraObjectDist  the distance from the camera eye to the object being followed.  
							
						end
					end
					
					local ctl = CommonCtrl.GetControl(self.name.."_GridView3D_SecretGridView");
					local _parent = ctl:GetCellUIParentByRowAndColumn(i, j);
					--_parent.background = filename;
					
					
					local ctl = CommonCtrl.GetControl(self.name.."_GridView3D_SecretGridView");
					local _parent = ctl:GetCellUIParentByRowAndColumn(i, j);
					
					-- call the draw method to create the UI for the given GridCell3D
					if(not self.DrawCellHandler) then
						GridView3D.DrawNormalCellHandler(_parent, cell, filename);
					else
						self.DrawCellHandler(_parent, cell, filename);
					end
				end
			end
		end
	end
	
	---- refresh objects' size automatically here
	--self:RefreshObjectSize();
end

function GridView3D:RefreshObjectSize()

	local _parent = ParaUI.GetUIObject(self.name.."_GridView3D");
	if(not _parent:IsValid()) then
		log("error: getting Grid View parent\n");
		return
	end
	
	local scene = self:GetMiniSceneGraph();
	
	-- check each object size for each GridCell3D
	local i, j;
	for i = 1, self.rows do
		-- each row
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					local cell = self.cells[i][j];
					-- check each object size for each GridCell3D
					local obj = scene.GetObject(cell.row.."-"..cell.column);
					if(obj:IsValid()) then
						local aabb = {};
						_asset:GetBoundingBox(aabb);
						local dx = math.abs(aabb.max_x - aabb.min_x);
						local dy = math.abs(aabb.max_y - aabb.min_y);
						local dz = math.abs(aabb.max_z - aabb.min_z);
						
						local maxBox = math.max(dx, dy);
						maxBox = math.max(maxBox, dz);
						
						local minSize = math.max(self.cellWidth, self.cellHeight);
						
						obj:SetScale(minSize/10/maxBox);
					end
				end
			end
		end
	end
end

function GridView3D:OnShiftUpByCell(nCount)
	nCount = nCount or 1;
	local ctl = CommonCtrl.GetControl(self.name.."_GridView3D_SecretGridView");
	if(ctl ~= nil) then
		ctl:OnShiftUpByCell(nCount);
	end
	
	local scene = self:GetMiniSceneGraph();
	local at_x, at_y, at_z = scene:CameraGetLookAtPos();
	at_y = at_y + self.cellHeight / 10 * nCount;
	scene:CameraSetLookAtPos(at_x, at_y, at_z);
end

function GridView3D:OnShiftDownByCell(nCount)
	nCount = nCount or 1;
	local ctl = CommonCtrl.GetControl(self.name.."_GridView3D_SecretGridView");
	if(ctl ~= nil) then
		ctl:OnShiftDownByCell(nCount);
	end
	
	local scene = self:GetMiniSceneGraph();
	local at_x, at_y, at_z = scene:CameraGetLookAtPos();
	at_y = at_y - self.cellHeight / 10 * nCount;
	scene:CameraSetLookAtPos(at_x, at_y, at_z);
end

function GridView3D:OnShiftLeftByCell(nCount)
	nCount = nCount or 1;
	local ctl = CommonCtrl.GetControl(self.name.."_GridView3D_SecretGridView");
	if(ctl ~= nil) then
		ctl:OnShiftLeftByCell(nCount);
	end
	
	local scene = self:GetMiniSceneGraph();
	local at_x, at_y, at_z = scene:CameraGetLookAtPos();
	at_x = at_x - self.cellHeight / 10 * nCount;
	scene:CameraSetLookAtPos(at_x, at_y, at_z);
end

function GridView3D:OnShiftRightByCell(nCount)
	nCount = nCount or 1;
	local ctl = CommonCtrl.GetControl(self.name.."_GridView3D_SecretGridView");
	if(ctl ~= nil) then
		ctl:OnShiftRightByCell(nCount);
	end
	
	local scene = self:GetMiniSceneGraph();
	local at_x, at_y, at_z = scene:CameraGetLookAtPos();
	at_x = at_x + self.cellHeight / 10 * nCount;
	scene:CameraSetLookAtPos(at_x, at_y, at_z);
end

function GridView3D.DrawNormalCellHandler(_parent, cell)
	-- simply attach a drawing board on the position	
	local scene = cell.GridView3D:GetMiniSceneGraph();
	--scene:RemoveObject(obj);
	
	--local _assetName = "model/06props/shared/pops/huaban.x";
	--local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	--local obj = ParaScene.CreateMeshPhysicsObject(cell.row.."-"..cell.column, _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	--if(obj:IsValid()) then
		--obj:SetFacing(1.57);
		--obj:GetAttributeObject():SetField("progress", 1);
		--
		--obj:SetPosition(cell.logicalX, cell.logicalY, 0);
		--local att = obj:GetAttributeObject();
		--att:SetField("render_tech", 10);
		--
		--scene:AddChild(obj);
	--end
	
	if(cell ~= nil) then
		local _this = ParaUI.CreateUIObject("button", cell.text, "_fi", 2, 2, 2, 2);
		_this.background = "";
		_this.onclick = string.format([[;_guihelper.MessageBox("GridView3D Click: %s  %s  %s");]], 
				cell.GridView3D.name, cell.row, cell.column);
		--_this.onmouseenter = "";
		--_this.onmouseleave = "";
		_parent:AddChild(_this);
	end
	
	
	local db = sqlite3.open(Map3DSystem.UI.CCS.DB.dbfile);
	local row;
	local index = Map3DSystem.UI.CCS.Inventory.Items[1];
	
	--NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	--Map3DSystem.Misc.SaveTableToFile(Map3DSystem.UI.CCS.Inventory.Items, "TestTable/items.ini");
	
	local model, skin;
	if(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_HEAD) then
		for row in db:rows(string.format("select Model, Skin from ItemDisplayDB where ItemDisplayID = %d", index)) do
			model = row.Model;
			skin = row.Skin;
		end
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_NECK) then
		
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_SHOULDER) then
		return "Shoulder";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_BOOTS) then
		return "Boots";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_BELT) then
		return "Belt";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_SHIRT) then
		return "Shirt";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_PANTS) then
		return "Pants";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_CHEST) then
		return "Chest";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_BRACERS) then
		return "Bracers";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_GLOVES) then
		return "Gloves";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_HAND_RIGHT) then
		return "HandRight";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_HAND_LEFT) then
		return "HandLeft";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_CAPE) then
		return "Cape";
	elseif(Map3DSystem.UI.CCS.InventorySlot.Component == Map3DSystem.UI.CCS.DB.CS_TABARD) then
		return "Tabard";
	end
	
	db:close();
	
	
	--local _assetName = "model/common/ccs_unisex/shirt06_TU1_TL2_AU3_AL4.x";
	
	local _assetName = "character/v3/Item/ObjectComponents/Head/"..model;
	
	if(cell.model ~= nil) then
		_assetName = cell.model;
	else
		return;
	end
	
	local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	local obj = ParaScene.CreateMeshPhysicsObject("fddewqsa", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		obj:SetFacing(1.57);
		obj:GetAttributeObject():SetField("progress", 1);
		
		local aabb = {};
		_asset:GetBoundingBox(aabb);
		local dx = math.abs(aabb.max_x - aabb.min_x);
		local dy = math.abs(aabb.max_y - aabb.min_y);
		local dz = math.abs(aabb.max_z - aabb.min_z);
		
		local max = math.max(dx, dy);
		max = math.max(max, dz);
		
		obj:SetPosition(cell.logicalX, cell.logicalY, 0);
		--obj:SetPosition(3.2, -6.4, 0);
		obj:SetScale(6.4/max);
		local att = obj:GetAttributeObject();
		att:SetField("render_tech", 10);
		
		scene:AddChild(obj);
		
		--local _Head = "character/v3/Item/TextureComponents/TorsoLowerTexture/MomoMale05_he_TL_U.DDS"
		local _Head = "character/v3/Item/ObjectComponents/Head/"..skin;
		local texture_Head = ParaAsset.LoadTexture("", _Head, 1);
		obj:SetReplaceableTexture(0, texture_Head);
		
		--local _TL = "character/v3/Item/TextureComponents/TorsoLowerTexture/MomoMale05_he_TL_U.DDS"
		--local _TU = "character/v3/Item/TextureComponents/TorsoUpperTexture/MomoMale05_he_TU_U.DDS"
		--local _AL = "character/v3/Item/TextureComponents/ArmLowerTexture/MomoMale05_he_AL_U.DDS"
		--local _AU = "character/v3/Item/TextureComponents/ArmUpperTexture/MomoMale05_he_AU_U.DDS"
		--
		---- apply the texture
		--local texture_TU = ParaAsset.LoadTexture("", _TU, 1);
		--local texture_TL = ParaAsset.LoadTexture("", _TL, 1);
		--local texture_AU = ParaAsset.LoadTexture("", _AU, 1);
		--local texture_AL = ParaAsset.LoadTexture("", _AL, 1);
		--obj:SetReplaceableTexture(1, texture_TU);
		--obj:SetReplaceableTexture(2, texture_TL);
		--obj:SetReplaceableTexture(3, texture_AU);
		--obj:SetReplaceableTexture(4, texture_AL);
	end
end

-- insert the GridCell3D object into the grid view
-- @param cell: GridCell3D object
-- @param mode: where to place the newly added cell when cell on target position already exists
--		according to Numpad, if the cell inserted at 5, and 5 already has a cell, then try to 
--			insert cell according to the sequence:
--				"Up": 8 1 4 7
--				"Down": 2 9 6 3
--				"Left": 4 9 8 7
--				"Right": 6 1 2 3
--		if the sequence hit the topleft or rightbottom corner of a GridView3D, drop cell.
function GridView3D:InsertCell(cell, mode)
	if(mode == nil) then
		-- if no mode specified, set default "Right" mode
		mode = "Right";
	end
	
	if(cell.GridView3D ~= nil) then
		log("warning: insert cell fail. GridCell3D("..self.name..") have already assigned to a GridView3D.\n");
		return;
	end
	
	local row = cell.row;
	local column = cell.column;
	if(row == nil) then row = 1; end
	if(column == nil) then column = 1; end
	
	if(not self.cells[row]) then
		self.cells[row] = {};
	end
	if(self.cells[row][column] == nil) then
		-- insert cell
		self.cells[row][column] = cell;
		cell.row = row;
		cell.column = column;
		cell.GridView3D = self;
	else
		-- cell already exist
		-- TODO: currently only support "Right" mode insert sequence
		local i, j;
		for i = row, self.rows do
			-- each row from target position
			if(not self.cells[i]) then
				self.cells[i] = {};
			end
			for j = column, self.columns do
				-- each column form target position
				if(self.cells[i][j] == nil) then
					-- insert cell
					self.cells[i][j] = cell;
					cell.row = i;
					cell.column = j;
					cell.GridView3D = self;
					return;
				end
			end
		end
	end
end

-- get a GridCell3D object from the grid view by row and column index
-- @param row: GridCell3D row index
-- @param column: GridCell3D column index
function GridView3D:GetCellByRowAndColumn(row, column)
	if(row == nil or column == nil) then
		log("error: get cell from GridView3D must provide row and column index\n");
		return;
	end
	
	if(not self.cells[row]) then
		log("error: get cell from GridView3D fail, row not found\n");
		return;
	end
	
	return self.cells[row][column];
end

-- remove a GridCell3D object from the grid view by row and column index
-- @param row: GridCell3D row index
-- @param column: GridCell3D column index
function GridView3D:RemoveCellByPosition(row, column)
	if(row == nil or column == nil) then
		log("error: remove cell from GridView3D must provide row and column index\n");
		return;
	end
	
	if(not self.cells[row]) then
		log("error: remove cell from GridView3D, row not found\n");
		return;
	end
	if(self.cells[row][column] ~= nil) then
		-- remove cell
		self.cells[row][column] = nil;
	end
end

-- get the first occurance of GridCell3D object whose name is name
function GridView3D:GetCellByName(name)
	local i, j;
	for i = 1, self.rows do
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					if(self.cells[i][j].name == name) then
						return self.cells[i][j];
					end
				end
			end
		end
	end
end

-- remove all occurance of grid cell whose name is name
function GridView3D:RemoveCellByName(name)
	local i, j;
	for i = 1, self.rows do
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					if(self.cells[i][j].name == name) then
						self.cells[i][j] = nil;
					end
				end
			end
		end
	end
end

-- get the first occurance of GridCell3D object whose text is text
function GridView3D:GetCellByText(text)
	local i, j;
	for i = 1, self.rows do
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					if(self.cells[i][j].text == text) then
						return self.cells[i][j];
					end
				end
			end
		end
	end
end

--TODO: implement this funciton in the grid view
--
-- get the best matched cell that contains the logical point x, y
function GridView3D:GetCellByPoint(x, y)
	-- TODO:
end

-- Get cell count
function GridView3D:GetCellCount()
	local i, j;
	local nCount = 0;
	for i = 1, self.rows do
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					nCount = nCount + 1;
				end
			end
		end
	end
	
	return nCount;
end

-- clear all GridCell3Ds
function GridView3D:ClearAllCells()
	self.cells = {}
end

-- update the logical positions of grid cells
function GridView3D:UpdateLogicalPosition()
	-- update each X and Y position to each grid cell
	local i, j;
	for i = 1, self.rows do
		-- each row
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				-- each column
				if(self.cells[i][j] ~= nil) then
					-- cell logical position against grid view lefttop corner
					local cell = self.cells[i][j];
					
					cell.logicalX = self.cellWidth / 10 * (j - 1) + self.cellWidth / 20;
					cell.logicalY = - (self.cellHeight / 10 * (i - 1) + self.cellWidth / 20); -- NOTE: the -Y axis
					
				end
			end
		end
	end
end