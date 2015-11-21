--[[
Title: GridView is a container showing 2 dimensional array of data in matrix display form.
Author(s): WangTian
Date: 2007/11/19
Note: This control is solely for all the matrix alike controls including BCS, CCS, Creation panel, CartoonFace .etc
		Unlike Treeview, GridView will not have horizontal and vertical sliders. Only with external pagers up/down or left/right
		
		Current version only supports the same width and height gridcell defined in the GridView
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/GridView.lua");
local ctl = CommonCtrl.GridView:new{

-- more comments for gridview


	name = "TreeView1",
	alignment = "_lt",
	left=0, top=0,
	width = 200,
	height = 200,
	parent = nil,
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	DrawNodeHandler = nil,
};
local node = ctl.RootNode;
node:AddChild("Node1");
node:AddChild(CommonCtrl.TreeNode:new({Text = "Node2", Name = "sample"}));
node = node:AddChild("Node3");
node = node:AddChild("Node3_1");
node = node:AddChild("Node3_1_1");
ctl.RootNode:AddChild("Node4");
ctl.RootNode:AddChild("Node5");

ctl:Show();
-- One needs to call Update() if made any modifications to the TreeView after the Show() method, such as adding or removing new nodes, or changing text of a given node. 
-- ctl:Update();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");


------------------------------------------------------------
-- Grid Cell
------------------------------------------------------------

-- Represents a cell of a GridView. 
local GridCell = {
	---- Gets the parent tree node of the current tree node. 
	--parent = nil, 
	-- Gets the ancister grid view that the grid cell is assigned to. 
	GridView = nil,
	-- Gets or sets the name of the grid cell.
	name = nil,
	-- Gets or sets the text displayed in the label of the grid cell. 
	text = nil,
	-- column index of this cell in the gridview, from 1
	column = nil,
	-- row index of this cell in the gridview, from 1
	row = nil,
	
	-- Appearances : Added by LiXizhi 2008.4.19
	font = nil,
	font_color = nil,
	
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
	------ Width of this grid cell, if this is nil, GridView.DefaultCellWidth will be used
	----CellWidth = nil,
	------ Height of this grid cell, if this is nil, GridView.DefaultCellHeight will be used
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
CommonCtrl.GridCell = GridCell;

-- constructor
function GridCell:new (o)
	o = o or {};  -- create object if user does not provide one
	--o.Nodes = {};
	setmetatable(o, self);
	self.__index = self;
	return o
end

function GridCell:GetWidth()
	return self.GridView.cellWidth;
end

function GridCell:GetHeight()
	return self.GridView.cellHeight;
end


----TODO: implement this funciton in the grid view
----
---- after the content of a grid cell is changed, one may need to call this function at the GridView
---- @param x,y: logical position 
---- @return: logical position for the sibling node 
--function GridCell:Update(x, y)
	--
	---- TODO: move this function to GridView?
	--self.LogicalX = x;
	--self.LogicalY = y;
	--if(not self.Invisible) then
		----log(self:GetNodePath()..", "..y.."\n")
		--x,y = x, y + self:GetHeight();
		--
		--if(self.Expanded) then
			--local nSize = table.getn(self.Nodes);
			--local i, node;
			--for i=1, nSize do
				--node = self.Nodes[i];
				--if(node ~=nil) then
					--x,y = node:Update(x, y);
				--end
			--end
		--end	
	--end	
	--self.LogicalBottom = y;
	--return x,y;
--end

-- get a string containing the cell coordinate
-- as long as the GridView does not change, the cell coordinate uniquely identifies a GridCell.
-- @return: row, column
function GridCell:GetCellCoord()
	if(self.row ~= nil and self.column ~= nil) then
		return self.row, self.column;
	end
end

-- get the sibling Up/Down/Left/Right cell 
function GridCell:GetSiblingCellUp()
	local row = self.row;
	local column = self.column;
	if(row >= 1) then
		return self.GridView:GetCellByRowAndColumn(row - 1, column);
	end
end

function GridCell:GetSiblingCellDown()
	local row = self.row;
	local column = self.column;
	if(row <= self.GridView.rows) then
		return self.GridView:GetCellByRowAndColumn(row + 1, column);
	end
end

function GridCell:GetSiblingCellLeft()
	local row = self.row;
	local column = self.column;
	if(column >= 1) then
		return self.GridView:GetCellByRowAndColumn(row, column - 1);
	end
end

function GridCell:GetSiblingCellRight()
	local row = self.row;
	local column = self.column;
	if(column <= self.GridView.columns) then
		return self.GridView:GetCellByRowAndColumn(row, column + 1);
	end
end



------------------------------------------------------------
-- GridView
------------------------------------------------------------

-- GridView is a container showing 2 dimensional array of data in matrix display form.
local GridView = {
	-- the top level control name
	name = "GridView1",
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
	
	
	-- row data containing all the gridcells organized in rows
	-- table indexed by rows
	-- each row table contains a subtable indexed by columns, each entry is a grid cell
	-- both index from 1
	cells = {};
	
	-- number of columns in the gridview
	columns = nil,
	-- number of rows in the gridview
	rows = nil,
	
	
	-- cell width and cell height
	-- NOTE: Current version only supports the same width and height gridcell defined in the GridView
	cellWidth = 36,
	cellHeight = 36,
	
	-- different with the tree view
	defaultCellWidth = 24,
	defaultCellHeight = 24,
	
	-- Gets or sets a function by which the individual GridCell control is drawn. The function should be of the format:
	-- function DrawCellEventHandler(parent,gridcell) end, where parent is the parent container in side which contents should be drawn.
	--		And gridcell is the GridCell object to be drawn
	-- if DrawCellHandler is nil, the default GridView.DrawNormalCellHandler function will be used.
	DrawCellHandler = nil,
	-- Force no clipping or always using fast render. Unless you know that the unit scroll step is interger times of all TreeNode height. You can disable clipping at your own risk. 
	-- Software clipping is always used to clip all invisible TreeNodes. However, this option allows you to specify whether to use clipping for partially visible TreeNode. 
	fastrender = nil,
	
	----------------------------------
	---- internal parameters, do not use externally
	----------------------------------
	
	-- number of columns in the gridview client area
	clientColumns = nil,
	-- number of rows in the gridview client area
	clientRows = nil,
	
	-- row ID of the left top cell in the gridview client area
	clientLeftTopCellRow = nil,
	-- column ID of the left top cell in the gridview client area
	clientLeftTopCellColumn = nil,
	
	-- this is automatically set according to whether a scroll bar is available.
	clientWidth = 10;
	clientHeight = 10;
	
	
	---- default icon size
	--defaultIconSize = 16,
	---- whether to show icon on the left of each line. 
	--showIcon = true,
	---- default indentation
	--DefaultIndentation = 5,
	---- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	---- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	---- if DrawNode is nil, the default GridView.DrawNormalNodeHandler function will be used. 
	--DrawNodeHandler = nil,
	---- Cache size: The number of TreeNode controls to be cached. [N/A]
	--CacheSize = 30,
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
	clientWidth = 10;
	clientHeight = 10;
	---- a mapping from node path to existing line control container index, the total number of mapping here does not exceed CacheSize
	--NodeUIContainers = {},
}
CommonCtrl.GridView = GridView;


-- constructor
function GridView:new (o)
	o = o or {}   -- create object if user does not provide one
	
	-- create the cells table for holding gridcells
	if(not o.cells) then
		o.cells = {};
	end
	
	---- width and height of each grid cell, if this is nil, 
	-- GridView.defaultCellWidth and GridView.defaultCellHeight will be used
	if(o.cellWidth == nil) then
		o.cellWidth = GridView.defaultCellWidth;
	end
	if(o.cellHeight == nil) then
		o.cellHeight = GridView.defaultCellHeight;
	end
	if(o.clientLeftTopCellRow == nil 
		or o.clientLeftTopCellColumn == nil) then
		self.clientLeftTopCellRow = 1;
		self.clientLeftTopCellColumn = 1;
	end
	
	setmetatable(o, self)
	self.__index = self
	
	CommonCtrl.AddControl(o.name, o);
	
	return o;
end

function GridView:Destroy()
	self.cells = {};
	--CommonCtrl.DeleteControl(self.name);
	ParaUI.Destroy(self.name.."_GridView");
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function GridView:Show(bShow)
	local _this, _parent;
	if(self.name == nil)then
		log("GridView instance name can not be nil\r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name.."_GridView");
	if(_this:IsValid() == false) then
	
		_this = ParaUI.CreateUIObject("container", self.name.."_GridView", self.alignment, self.left, self.top, self.width, self.height);
		if(self.container_bg ~= nil) then
			_this.background = self.container_bg;
		else
			_this.background = "";
		end
		
		if(not self.fastrender) then
			_this.fastrender = false;
			self.fastrender = false;
		end
		
		_parent = _this;
		
		if(self.parent == nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		-- update the gridview on creation
		self:Update();
		_this = _parent;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	
end

-- this function should be called whenever the layout of the grid view changed. 
-- internally, it will recalculate all cell logical positions.
-- TODO: @param ShowCell: nil or a gridCell. It will automaticly scroll for the best show of the cell element.
function GridView:Update()
	-- update all cell logical positions
	--self.RootNode:Update(0,0);
	
	local _parent = ParaUI.GetUIObject(self:GetMainContainerName());
	if(not _parent:IsValid()) then
		log("error: getting Grid View parent\n");
		return
	end
	_parent:RemoveAll(); -- simply remove all.
	
	-- calculate client area and client rows/columns
	local _, _, GridViewWidth, GridViewHeight = _parent:GetAbsPosition();
	self.clientWidth = GridViewWidth;
	self.clientHeight = GridViewHeight;
	
	if(self.fastrender == false) then
		self.clientColumns = math.floor(GridViewWidth/self.cellWidth);
		self.clientRows = math.floor(GridViewHeight/self.cellHeight);
	else
		self.clientColumns = math.ceil(GridViewWidth/self.cellWidth);
		self.clientRows = math.ceil(GridViewHeight/self.cellHeight);
	end
	
	-- calculate the logical position of every gridcell
	self:UpdateLogicalPosition(self.clientLeftTopCellRow, self.clientLeftTopCellColumn);
	
	-- create a container for each gridcell
	local i, j;
	for i = 1, self.rows do
		-- each row
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					local cell = self.cells[i][j];
					-- create a container for gridcell owner draw
					local emptyUI = ParaUI.CreateUIObject("container", cell.row.."-"..cell.column.."_cell", "_lt", 
							cell.logicalX, cell.logicalY, self.cellWidth, self.cellHeight);
					emptyUI.background = "";
					_parent:AddChild(emptyUI);
					-- call the draw method to create the UI for the given GridCell
					
					if(not self.DrawCellHandler) then
						GridView.DrawNormalCellHandler(emptyUI, cell);
					else
						self.DrawCellHandler(emptyUI, cell);
					end
				end
			end
		end
	end
	
	-- refresh the UI automatically here
	self:RefreshUI();
end

-- refresh the UI
function GridView:RefreshUI()
	local _parent = ParaUI.GetUIObject(self:GetMainContainerName());
	-- create a container for each gridcell
	local i, j;
	for i = 1, self.rows do
		-- each row
		if(not self.cells[i]) then
			
		else
			for j = 1, self.columns do
				if(self.cells[i][j] ~= nil) then
					local cell = self.cells[i][j];
					-- get the container for gridcell owner draw
					local emptyUI = _parent:GetChild(cell.row.."-"..cell.column.."_cell");
					local _fileName = "script/UIAnimation/DesktopStartupGridView.lua.table";
					if(cell.logicalX - emptyUI.x) == 100 then
						UIAnimManager.PlayUIAnimationSequence(emptyUI, _fileName, "ShiftRight", false);
					elseif(cell.logicalX - emptyUI.x) == -100 then
						UIAnimManager.PlayUIAnimationSequence(emptyUI, _fileName, "ShiftLeft", false);
					elseif(cell.logicalY - emptyUI.y) == 100 then
						UIAnimManager.PlayUIAnimationSequence(emptyUI, _fileName, "ShiftDown", false);
					elseif(cell.logicalY - emptyUI.y) == -100 then
						UIAnimManager.PlayUIAnimationSequence(emptyUI, _fileName, "ShiftUp", false);
					end
					emptyUI.x = cell.logicalX;
					emptyUI.y = cell.logicalY;
				end
			end
		end
	end
end

function GridView:GetMainContainerName()
	return self.name.."_GridView";
end

-- test callback on cell drag and drop
function GridView.DefaultCellDrag(fromgridview, draggridcell, fromRow, fromColumn, toRow, toColumn)
	_guihelper.MessageBox(string.format("fromgridview.name:%s draggridcell.name:%s fromRow:%s fromColumn:%s toRow:%s toColumn:%s\n", 
		fromgridview.name, draggridcell.name, fromRow, fromColumn, toRow, toColumn));
end

function GridView:OnShiftUpByCell(nCount)
	nCount = nCount or 1;
	self:UpdateLogicalPosition(self.clientLeftTopCellRow - nCount, self.clientLeftTopCellColumn);
	self:RefreshUI();
end

function GridView:OnShiftDownByCell(nCount)
	nCount = nCount or 1;
	self:UpdateLogicalPosition(self.clientLeftTopCellRow + nCount, self.clientLeftTopCellColumn);
	self:RefreshUI();
end

function GridView:OnShiftLeftByCell(nCount)
	nCount = nCount or 1;
	self:UpdateLogicalPosition(self.clientLeftTopCellRow, self.clientLeftTopCellColumn - nCount);
	self:RefreshUI();
end

function GridView:OnShiftRightByCell(nCount)
	nCount = nCount or 1;
	self:UpdateLogicalPosition(self.clientLeftTopCellRow, self.clientLeftTopCellColumn + nCount);
	self:RefreshUI();
end

function GridView.DrawNormalCellHandler(_parent, cell)
	-- create full size container to display the cell text
	local btn = ParaUI.CreateUIObject("button", "default_cont", "_fi", 0,0,0,0);
	btn.text = cell.text;
	if(cell.GridView.font) then
		btn.font = cell.GridView.font;
	end
	if(cell.GridView.font_color) then
		_guihelper.SetFontColor(btn, cell.GridView.font_color)
	end
	_parent:AddChild(btn);
end

-- append the GridCell object into the grid view
-- @param cell: GridCell object
-- @param mode: where to place the newly added cell when cell on target position already exists
--		according to Numpad, if the cell inserted at 5, and 5 already has a cell, then try to 
--			insert cell according to the sequence:
--				"Up": 8 1 4 7
--				"Down": 2 9 6 3
--				"Left": 4 9 8 7
--				"Right": 6 1 2 3
--		if the sequence hit the topleft or rightbottom corner of a gridview, drop cell.
function GridView:AppendCell(cell, mode)
	self:InsertCell(cell, mode, true);
end

-- insert the GridCell object into the grid view
-- @param cell: GridCell object
-- @param mode: where to place the newly added cell when cell on target position already exists
--		according to Numpad, if the cell inserted at 5, and 5 already has a cell, then try to 
--			insert cell according to the sequence:
--				"Up": 8 1 4 7
--				"Down": 2 9 6 3
--				"Left": 4 9 8 7
--				"Right": 6 1 2 3
--		if the sequence hit the topleft or rightbottom corner of a gridview, drop cell.
-- @param bAppend: whether to append the cell into the target position
function GridView:InsertCell(cell, mode, bAppend)
	if(mode == nil) then
		-- if no mode specified, set default "Right" mode
		mode = "Right";
	end
	
	if(cell.GridView ~= nil) then
		log("warning: insert cell fail. Gridcell("..cell.name..") have already assigned to a gridview.\n");
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
		cell.GridView = self;
		return;
	else
		-- cell already exist
		-- TODO: currently only support "Right" mode insert sequence
		if(bAppend == true) then
			-- find next nil cell mode
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
						cell.GridView = self;
						return;
					end
				end
			end
		else
			-- insert mode
			local sourceCell = self.cells[row][column];
			sourceCell.GridView = nil;
			
			-- find the next cell
			if(sourceCell.column == self.columns) then
				if(sourceCell.row == self.rows) then
					self.cells[row][column] = cell;
					cell.row = row;
					cell.column = column;
					cell.GridView = self;
					return;
				end
				sourceCell.row = row + 1;
				sourceCell.column = 1;
			else
				sourceCell.row = row;
				sourceCell.column = column + 1;
			end
			
			-- insert current cell
			self.cells[row][column] = cell;
			cell.row = row;
			cell.column = column;
			cell.GridView = self;
			
			-- recursively insert the next cell
			self:InsertCell(sourceCell, mode, false);
		end
	end
end

-- DEBUG PURPOSE: print the cell data into a file
function GridView:PrintMe(filename)
	
	local file = ParaIO.open("TestTable/"..filename, "w");
	if(file:IsValid()) then
		
		-- find next nil cell mode
		local i, j;
		for i = 1, self.rows do
			-- each row from target position
			if(self.cells[i] ~= nil) then
				for j = 1, self.columns do
					-- each column form target position
					if(self.cells[i][j] ~= nil) then
						-- insert cell
						local cell = self.cells[i][j];
						-- TODO: continue saving
						local k, v;
						file:writeline(string.format([[
[%d, %d]: ]], cell.row, cell.column));
						for k, v in pairs(cell) do
							if(type(v) == "string") then
								file:writeline(string.format([[	%s: %s]], k, v));
							elseif(type(v) == "number") then
								file:writeline(string.format([[	%s: %d]], k, v));
							end
						end
						--file:writeline(string.format([[
--[%d, %d]: 
	--text: %s
	--name: %s
	--column: %d
	--row: %d
	--logicalX: %d
	--logicalY: %d
	--]], 
						--cell.row, 
						--cell.column, 
						--cell.text, 
						--cell.name, 
						--cell.row, 
						--cell.column, 
						--cell.logicalX, 
						--cell.logicalY));
					end
				end
			end
		end
	end
	file:close();
	
end

-- get a GridCell object from the grid view by row and column index
-- @param row: GridCell row index
-- @param column: GridCell column index
function GridView:GetCellByRowAndColumn(row, column)
	if(row == nil or column == nil) then
		log("error: get cell from gridview must provide row and column index\n");
		return;
	end
	
	if(not self.cells[row]) then
		--log(self.name.." "..row.." "..column.."\n");
		log("error: get cell from gridview fail, row not found\n");
		return;
	end
	--log(row.." "..column.."\n");
	
	return self.cells[row][column];
end

-- remove a GridCell object from the grid view by row and column index
-- @param row: GridCell row index
-- @param column: GridCell column index
function GridView:RemoveCellByRowAndColumn(row, column)
	if(row == nil or column == nil) then
		log("error: remove cell from gridview must provide row and column index\n");
		return;
	end
	
	if(not self.cells[row]) then
		log("error: remove cell from gridview, row not found\n");
		return;
	end
	if(self.cells[row][column] ~= nil) then
		-- remove cell
		self.cells[row][column] = nil;
	end
end

-- get the first occurance of gridcell object whose name is name
function GridView:GetCellByName(name)
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
function GridView:RemoveCellByName(name)
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

-- get the first occurance of gridcell object whose text is text
function GridView:GetCellByText(text)
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
function GridView:GetCellByPoint(x, y)
	-- TODO:
end


-- get the gridcell object according to the index
-- NOTE: index is defined according to the sequence:
--		 1  2  3  4  5  6  7
--		 8  9 10 11 12 13 14
--		15 16 ...
-- NOTE: also the index sequence is calculated by rows and columns of the grid view object, 
--		NOT the logical client area width and height
function GridView:GetCellByIndex(index)
	local row, column = self:IndexToRowAndColumn(index);
	return self:GetCellByRowAndColumn(row, column);
end

function GridView:GetCellUIParentByIndex(index)
	local row, column = self:IndexToRowAndColumn(index);
	local gridViewParent = ParaUI.GetUIObject(self.name.."_GridView");
	if(gridViewParent:IsValid() == true) then
		return gridViewParent:GetChild(row.."-"..column.."_cell");
	end
end

function GridView:GetCellUIParentByRowAndColumn(row, column)
	local gridViewParent = ParaUI.GetUIObject(self.name.."_GridView");
	if(gridViewParent:IsValid() == true) then
		return gridViewParent:GetChild(row.."-"..column.."_cell");
	end
end

function GridView:RemoveCellByIndex(index)
	local row, column = self:IndexToRowAndColumn(index);
	self:RemoveCellByRowAndColumn(row, column);
end

-- index and row+column transform
-- NOTE: index is defined according to the sequence:
--		 1  2  3  4  5  6  7
--		 8  9 10 11 12 13 14
--		15 16 ...
-- NOTE: also the index sequence is calculated by rows and columns of the grid view object, 
--		NOT the logical client area width and height
function GridView:IndexToRowAndColumn(index)
	local row = math.ceil(index / self.columns);
	local column = index - (row - 1) * self.columns;
	return row, column;
end

function GridView:RowAndColumnToIndex(row, column)
	return column + (row - 1) * self.columns;
end

--
-- get the best matched cell that on the current cursor position
-- if position is beyond the gridview client area, return nil
function GridView:GetCellByCursor()
	local mouseX, mouseY = ParaUI.GetMousePosition();
	local gridCont = ParaUI.GetUIObject(self:GetMainContainerName());
	local x, y, width, height = gridCont:GetAbsPosition();
	if(mouseX > x + width
		or mouseY > y + height
		or mouseX < x 
		or mouseY < y) then
		-- out of container boundary
		return;
	end
	
	-- get row and column according to the client left top cell
	local column = math.ceil((mouseX - x) / self.cellWidth);
	local row = math.ceil((mouseY - y) / self.cellHeight);
	row = row + self.clientLeftTopCellRow - 1;
	column = column + self.clientLeftTopCellColumn - 1;
	
	return self:GetCellByRowAndColumn(row, column);
end

-- Get cell count
function GridView:GetCellCount()
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

-- clear all gridcells
function GridView:ClearAllCells()
	self.cells = {};
end

-- update the logical positions of grid cells
function GridView:UpdateLogicalPosition(row, column)
	-- update each X and Y position to each grid cell
	
	local clientColumns = self.clientColumns;
	local clientRows = self.clientRows;
	-- row or column is out of client container boundary
	if(row > self.rows) then
		row = self.rows;
	end
	if(column > self.columns) then
		column = self.columns;
	end
	if(row < 1) then
		row = 1;
	end
	if(column < 1) then
		column = 1;
	end
	self.clientLeftTopCellRow = row;
	self.clientLeftTopCellColumn = column;
	
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
					cell.logicalX = self.cellWidth * (j - column);
					cell.logicalY = self.cellHeight * (i - row);
					
					if(i >= row 
						and i <= (row + clientColumns - 1)
						and j >= column 
						and j <= (row + clientRows - 1)) then
						cell.visible = true;
					else
						cell.visible = false;
					end
				end
			end
		end
	end
end