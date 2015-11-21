--[[
Title: mc items
Author(s):  LiXizhi
Company: ParaEngine
Date: 2013.10.14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/mcml/pe_mc_block.lua");
local pe_mc_block = commonlib.gettable("MyCompany.Aries.Game.mcml.pe_mc_block");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/blocks/block_types.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemStack.lua");
local pe_mc_slot = commonlib.gettable("MyCompany.Aries.Game.mcml.pe_mc_slot");
local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local drag_src_mcml_node = nil;
-- create class
local pe_mc_block = commonlib.gettable("MyCompany.Aries.Game.mcml.pe_mc_block");

pe_mc_block.block_icon_instances = {};


function pe_mc_block.render_callback(mcmlNode, rootName, bindingContext, _parent, left, top, right, bottom, myLayout, css)
	local _this = ParaUI.CreateUIObject("button", "b", "_lt", left, top, right-left, bottom-top);
	_guihelper.SetUIColor(_this, "#ffffffff");
	local animstyle = mcmlNode:GetNumber("animstyle");
	if(animstyle) then
		_this.animstyle = animstyle;
	end
	_this.zorder = mcmlNode:GetNumber("zorder") or 0;
	_this:GetAttributeObject():SetField("TextOffsetY", 8)
	_this:GetAttributeObject():SetField("TextShadowQuality", 8);
	_guihelper.SetFontColor(_this, "#ffffffff");
	_guihelper.SetUIColor(_this, "#ffffffff");
	_this.font = "System;12;bold";
	_guihelper.SetUIFontFormat(_this, 38);
	_this.shadow = true;

	_parent:AddChild(_this);

	mcmlNode.uiobject_id = _this.id;

	local inventory = mcmlNode:GetAttributeWithCode("inventory", nil, true);
	if(not inventory) then
		inventory = EntityManager.GetPlayer().inventory;
	end
	mcmlNode.inventory = inventory;

	local block_id;
	local block_count;
	local bagpos = mcmlNode:GetAttributeWithCode("bagpos", nil, true);
	if(bagpos) then
		bagpos = tonumber(bagpos);
		mcmlNode.bag_pos_ = bagpos;
		pe_mc_block.block_icon_instances[mcmlNode.uiobject_id] = mcmlNode;
		
		block_id, block_count = inventory:GetItemByBagPos(bagpos);
		mcmlNode.item_stack = inventory:GetItem(bagpos);
	else
		block_id = mcmlNode:GetAttributeWithCode("block_id", nil, true);
		mcmlNode.item_stack = ItemStack:new():Init(block_id);
	end
	
	mcmlNode.block_id = block_id;
	mcmlNode.block_count = block_count or 0;

	local background;
	if(block_id) then
		local block_item = ItemClient.GetItem(block_id);
		if(block_item) then
			background = block_item:GetIcon():gsub("#", ";");	
		end
	end
	_this.background = background or "";

	_this:GetAttributeObject():SetField("TextOffsetY", 8)
	_this:GetAttributeObject():SetField("TextShadowQuality", 8);
	_guihelper.SetFontColor(_this, "#ffffffff");
	_guihelper.SetUIColor(_this, "#ffffffff");
	_this.font = "System;12;bold";
	_guihelper.SetUIFontFormat(_this, 38);
	_this.shadow = true;
	if(block_count and block_count>1) then
		_this.text = tostring(block_count);
	end
	

	local _clicktarget = _this;
	
	local isdragable = mcmlNode:GetBool("isdragable", false);

	if(isdragable) then
		local _drag = ParaUI.CreateUIObject("button", "mousedraglayer", "_lt", left, top, right-left, bottom-top);
		_drag.background = "";
		_drag.zorder = mcmlNode:GetNumber("zorder") or 0;
		_drag.candrag = true;
		_parent:AddChild(_drag);

		_drag:SetScript("ondragbegin", function(obj)
			pe_mc_block.OnDragBegin(obj.id, mcmlNode)
		end);
		_drag:SetScript("ondragmove", function(obj)
			pe_mc_block.OnDragMove(obj.id, mcmlNode);
		end);
		_drag:SetScript("ondragend", function(obj)
			pe_mc_block.OnDragEnd(obj.id, mcmlNode);
		end);
		_clicktarget = _drag;
	end


	local isclickable = mcmlNode:GetBool("isclickable",true);
	if(isclickable)then
		_clicktarget:SetScript("onclick", pe_mc_block.OnClick, bagpos, mcmlNode);

		local tooltip = mcmlNode:GetAttributeWithCode("tooltip");

		if(not tooltip and block_id) then
			local block_item = ItemClient.GetItem(block_id);
			if(block_item) then
				tooltip = block_item:GetTooltip();
			end
		end
		-- if tooltip is explicitly provided
		local tooltip_page = string.match(tooltip or "", "page://(.+)");
		if(tooltip_page) then
			local is_lock_position, use_mouse_offset;
			if(mcmlNode:GetAttribute("tooltip_is_lock_position") == "true") then
				is_lock_position, use_mouse_offset = true, false
			end
			CommonCtrl.TooltipHelper.BindObjTooltip(_clicktarget.id, tooltip_page, mcmlNode:GetNumber("tooltip_offset_x"), mcmlNode:GetNumber("tooltip_offset_y"),
				nil,nil,nil, nil, nil, nil, is_lock_position, use_mouse_offset);
		else
			_clicktarget.tooltip = tooltip or "";
		end
	end
	return true, true, true; -- ignore_onclick, ignore_background, ignore_tooltip;
end

-- get block icon
function pe_mc_block.GetIcon(block_id)	
	if(block_id) then
		local block_item = ItemClient.GetItem(block_id);
		if(block_item) then
			return (block_item:GetIcon() or ""):gsub("#", ";");
		end
	end
	return "";
end

-- this is just a temparory tag for offline mode
function pe_mc_block.create(rootName, mcmlNode, bindingContext, _parent, left, top, width, height, style, parentLayout)
	return mcmlNode:DrawDisplayBlock(rootName, bindingContext, _parent, left, top, width, height, parentLayout, style, pe_mc_block.render_callback);
end

-- whether in the dragging state. 
pe_mc_block.is_dragging = false;


-- this simulate the dragging cursor
local function GetGlobalDragContainer()
	local _slaveicon = ParaUI.GetUIObject("_g_drag_cont")
	if(_slaveicon:IsValid() ~= true) then
		_slaveicon = ParaUI.CreateUIObject("button", "_g_drag_cont", "_lt", -1000, -1000, 32, 32);
		_slaveicon.background = "";
		_slaveicon.zorder = 1000;
		_slaveicon:GetAttributeObject():SetField("TextOffsetY", 8)
		_slaveicon:GetAttributeObject():SetField("TextShadowQuality", 8);
		_guihelper.SetFontColor(_slaveicon, "#ffffffff");
		_guihelper.SetUIColor(_slaveicon, "#ffffffff");
		_slaveicon.font = "System;12;bold";
		_guihelper.SetUIFontFormat(_slaveicon, 38);
		_slaveicon.shadow = true;
		_slaveicon:AttachToRoot();
	end
	return _slaveicon;
end

local function GetGlobalDragCanvas()
	local _canvas = ParaUI.GetUIObject("_g_GlobalDragCanvas")
	if(_canvas:IsValid() ~= true) then
		_canvas = ParaUI.CreateUIObject("container", "_g_GlobalDragCanvas", "_fi", 0,0,0,0);
		_canvas.background = "";
		_canvas.zorder = 1001;
		_canvas.visible = false;
		_canvas:SetScript("onmousedown", function()	
			pe_mc_block.OnClickDragCanvas();
		end)
		_canvas:SetScript("onframemove", function()
			pe_mc_block.OnClickDragFrameMove();
		end);
		_canvas:AttachToRoot();
	end
	return _canvas;
end

function pe_mc_block.OnClick(ui_obj, bagpos, mcmlNode)
	local isdragable = mcmlNode:GetBool("isdragable", false);

	local onclick = mcmlNode:GetAttributeWithCode("onclick");
	if(onclick) then
		-- if there is onclick event, use right key to drag
		if(mouse_button=="right") then
			if(not pe_mc_block.is_dragging) then
				pe_mc_block.OnClickDragBegin(mcmlNode);	
			end
		else
			Map3DSystem.mcml_controls.OnPageEvent(mcmlNode, onclick, mcmlNode.bag_pos_ or mcmlNode.block_id, mcmlNode);
		end
	else
		if(mouse_button=="left" and not pe_mc_block.is_dragging) then
			pe_mc_block.OnClickDragBegin(mcmlNode);
		end	
	end
end

-- handle click style dragging operation. 
-- @param is_continued: whether it is continued from another drag operation. 
function pe_mc_block.OnClickDragBegin(mcmlNode, count, is_continued)
	if(not is_continued) then
		-- some temp data keep for dragging operation. 
		mcmlNode.drag_block_id = mcmlNode.block_id;
		mcmlNode.drag_count = count or 1;
		mcmlNode.drag_cancel_on_self = nil;
	end

	local block_id = mcmlNode.drag_block_id or mcmlNode.block_id;
	local block_count = mcmlNode.drag_count or mcmlNode.block_count or 0;

	if(not block_id) then
		pe_mc_block.OnClickDragEnd();
		return;
	end

	local srcObj = mcmlNode:GetControl();
	local _slaveicon = GetGlobalDragContainer();
	if(_slaveicon:IsValid() and srcObj) then
		-- start dragging 
		-- srcObj.background = "";
		pe_mc_block.is_dragging = true;
		local _canvas = GetGlobalDragCanvas();
		_canvas.visible = true;
		_slaveicon.background = pe_mc_block.GetIcon(block_id);
		_slaveicon.width = srcObj.width;
		_slaveicon.height = srcObj.height;
		drag_src_mcml_node = mcmlNode;

		if(block_count <= 1) then
			_slaveicon.text = "";
		else
			_slaveicon.text = tostring(drag_src_mcml_node.drag_count);
		end
	end
end

-- called every frame move. 
function pe_mc_block.OnClickDragFrameMove()
	if(pe_mc_block.is_dragging and drag_src_mcml_node) then
		local ui_obj = drag_src_mcml_node:GetControl();
		if(ui_obj:GetAttributeObject():GetField("VisibleRecursive", false)) then
			local _slaveicon = GetGlobalDragContainer();
			if(_slaveicon:IsValid() == true) then
				local x, y = ParaUI.GetMousePosition();
				_slaveicon.translationx = x + 1000 - _slaveicon.width*0.5 + 1;
				_slaveicon.translationy = y + 1000 - _slaveicon.height + 1;
				_slaveicon.colormask = "255 255 255 200";
				_slaveicon:ApplyAnim();
			end
		else
			pe_mc_block.OnClickDragEnd();
		end
	else
		pe_mc_block.OnClickDragEnd();
	end
end

-- restore dragging ui
function pe_mc_block.OnClickDragEnd()
	pe_mc_block.is_dragging = false;

	local _slaveicon = GetGlobalDragContainer();
	if(_slaveicon:IsValid()) then
		_slaveicon.translationx = 0;
		_slaveicon.translationy = 0;
		_slaveicon:ApplyAnim();
		_slaveicon:SetScript("onframemove", nil);
	end
	GetGlobalDragCanvas().visible = false;

	if(drag_src_mcml_node) then
		drag_src_mcml_node.drag_block_id = nil;
		drag_src_mcml_node.drag_count = nil;
	end
	-- reset drag source
	drag_src_mcml_node = nil;
end

-- increase drag item count
function pe_mc_block.IncreaseDragItemCount(nDelta)
	drag_src_mcml_node.drag_count = (drag_src_mcml_node.drag_count or 0) + (nDelta or 1)

	-- update UI
	local _slaveicon = GetGlobalDragContainer();
	if(_slaveicon:IsValid()) then
		-- start dragging 
		if(drag_src_mcml_node.drag_count <= 1) then
			_slaveicon.text = "";
		else
			_slaveicon.text = tostring(drag_src_mcml_node.drag_count);
		end
	end
end

-- user clicks on the fullscreen click drag canvas, we will find a valid target
function pe_mc_block.OnClickDragCanvas()
	-- dragging end somewhere
	if(not drag_src_mcml_node) then
		pe_mc_block.OnClickDragEnd();
		return;
	end
	if(mouse_button == "right") then
		pe_mc_block.IncreaseDragItemCount(-1);
		if((drag_src_mcml_node.drag_count or 0) <= 0) then
			pe_mc_block.OnClickDragEnd();
		end
		return;
	end

	local m_x, m_y = ParaUI.GetMousePosition();
	local temp_removelist;
	local ui_id, mcmlNode;
	for ui_id, mcmlNode in pairs(pe_mc_block.block_icon_instances) do
		local _dragtarget = ParaUI.GetUIObject(ui_id);
		if(_dragtarget and _dragtarget:IsValid() == true) then
			local border = 6; -- using a border size of 6
			local x, y, width, height = _dragtarget:GetAbsPosition();
			if((m_x >= (x-border)) and (m_x <= (x + width + border)) and (m_y >= (y-border)) and (m_y <= (y + height+border))) then
				-- mark gsid
				if(mcmlNode ~= drag_src_mcml_node) then
					pe_mc_block.ClickDragMoveItem(drag_src_mcml_node, mcmlNode);
				else
					if(drag_src_mcml_node.drag_cancel_on_self) then
						pe_mc_block.OnClickDragEnd();
					else
						pe_mc_block.IncreaseDragItemCount(1);
					end
				end
				return;
			end
		else
			temp_removelist = temp_removelist or {};
			temp_removelist[ui_id] = true;
		end
	end
	if(temp_removelist) then
		for ui_id, mcmlNode in pairs(temp_removelist) do
			pe_mc_block.block_icon_instances[ui_id] = nil;
		end
	end
	pe_mc_block.ClickDragMoveItem(drag_src_mcml_node, nil);
end

function pe_mc_block.DoModify(mcmlNode, block_id, count)
	
	if(count and count <= 0) then
		count = 0;
	end
	if(mcmlNode.inventory) then
		local ui_obj = mcmlNode:GetControl();
		if(ui_obj) then
			mcmlNode.inventory:SetItemByBagPos(mcmlNode.bag_pos_, block_id, count);
		end
	else
		-- do nothing if no bag position. 
		mcmlNode.drag_block_id = block_id;
		mcmlNode.drag_count = count;
	end
end

function pe_mc_block.DropItemTo3DScene(mcmlNode, count)
	if(mcmlNode.inventory) then
		GameLogic.GetPlayerController():DropItemTo3DScene(mcmlNode.inventory, mcmlNode.bag_pos_, count);
	else
		-- do nothing if no bag position. 
		mcmlNode.drag_block_id = nil;
		mcmlNode.drag_count = 0;
	end
end

-- handle the real movement of data between mcml node. 
-- if dest is a bag position that already contains a block, the dragging does not terminate. 
function pe_mc_block.ClickDragMoveItem(src_mcml_node, dest_mcml_node)	
	if(not dest_mcml_node) then
		-- drop to the 3d scene
		if(src_mcml_node) then
			local src_block_count = src_mcml_node.drag_count or src_mcml_node.block_count or 0;
			pe_mc_block.DropItemTo3DScene(src_mcml_node, src_block_count);
			-- end drag operation
			pe_mc_block.OnClickDragEnd();
		end
	elseif(src_mcml_node)then
		local src_block_id = src_mcml_node.drag_block_id or src_mcml_node.block_id;
		local src_block_count = src_mcml_node.drag_count or src_mcml_node.block_count or 0;
		local dest_block_id = dest_mcml_node.block_id;
		local dest_block_count = dest_mcml_node.block_count or 0;

		if(dest_block_id == src_block_id) then
			-- merge
			local remain_count = math.max(src_mcml_node.drag_count or 0, src_mcml_node.block_count or 0) - 1;
			if(remain_count > 0) then
				pe_mc_block.DoModify(src_mcml_node, src_block_id, (src_mcml_node.block_count or 0) - 1);
				pe_mc_block.DoModify(dest_mcml_node, src_block_id, dest_block_count+1);
				src_mcml_node.drag_count = remain_count;
				pe_mc_block.OnClickDragBegin(src_mcml_node, remain_count, true);
			else
				pe_mc_block.DoModify(src_mcml_node, nil, 0);
				pe_mc_block.DoModify(dest_mcml_node, src_block_id, math.max(src_block_count, dest_block_count+1));

				pe_mc_block.OnClickDragEnd();
			end
		else
			if(dest_block_id) then
				pe_mc_block.DoModify(src_mcml_node, dest_block_id, dest_block_count);
				pe_mc_block.DoModify(dest_mcml_node, src_block_id, src_block_count);
				-- continue dragging since dest is not empty
				src_mcml_node.drag_block_id = dest_block_id;
				src_mcml_node.drag_count = dest_block_count;
				pe_mc_block.OnClickDragBegin(src_mcml_node, dest_block_count, true);
				if(drag_src_mcml_node) then
					drag_src_mcml_node.drag_cancel_on_self = true;
				end
			else
				local remain_count = math.max(src_mcml_node.drag_count or 0, src_mcml_node.block_count or 0) - 1;
				if(remain_count > 0) then
					pe_mc_block.DoModify(src_mcml_node, src_block_id, (src_mcml_node.block_count or 0) - 1);
					pe_mc_block.DoModify(dest_mcml_node, src_block_id, 1);
					src_mcml_node.drag_count = remain_count;
					pe_mc_block.OnClickDragBegin(src_mcml_node, remain_count, true);
				else
					pe_mc_block.DoModify(src_mcml_node, nil, 0);
					pe_mc_block.DoModify(dest_mcml_node, src_block_id, 1);
					pe_mc_block.OnClickDragEnd();
				end
			end
		end
	end
end

----------------------------------
-- OnDragXXX is traditional hold mouse button dragging. 
----------------------------------
function pe_mc_block.OnDragBegin(id, mcmlNode)
	local _drag = ParaUI.GetUIObject(id);
	if(_drag and _drag:IsValid() == true) then
		_drag.background = "";
		local _slaveicon = GetGlobalDragContainer();
		if(_slaveicon:IsValid() == true) then
			_slaveicon.background = pe_mc_block.GetIcon(mcmlNode.block_id);
			_slaveicon.width = _drag.width;
			_slaveicon.height = _drag.height;
		end
		drag_src_mcml_node = mcmlNode;
	end
end

function pe_mc_block.OnDragMove(id, mcmlNode)
	local _drag = ParaUI.GetUIObject(id);
	if(_drag and _drag:IsValid() == true) then
		--Cursor.LockCursor("none", true);
		local _slaveicon = GetGlobalDragContainer();
		if(_slaveicon:IsValid() == true) then
			local x, y = ParaUI.GetMousePosition();
			_slaveicon.translationx = x + 1000 - _slaveicon.width*0.5 + 1;
			_slaveicon.translationy = y + 1000 - _slaveicon.height + 1;
			_slaveicon.colormask = "255 255 255 200";
			_slaveicon:ApplyAnim();
		end
	end
end

function pe_mc_block.OnDragEnd(id, mcmlNode)
	local _drag = ParaUI.GetUIObject(id);
	if(_drag and _drag:IsValid() == true) then
		local background = pe_mc_block.GetIcon(mcmlNode.block_id);
		_drag.background = background;
		-- Cursor.UnlockCursor("default", true);
		local _slaveicon = GetGlobalDragContainer();
		if(_slaveicon:IsValid() == true) then
			_slaveicon.translationx = 0;
			_slaveicon.translationy = 0;
			_slaveicon:ApplyAnim();
		end
		
		local m_x, m_y = ParaUI.GetMousePosition();
		local temp_removelist;
		local ui_id, id;
		for ui_id, mcmlNode in pairs(pe_mc_block.block_icon_instances) do
			local _dragtarget = ParaUI.GetUIObject(ui_id);
			if(_dragtarget and _dragtarget:IsValid() == true) then
				local border = 6; -- using a border size of 4
				local x, y, width, height = _dragtarget:GetAbsPosition();
				
				if((m_x >= (x-border)) and (m_x <= (x + width + border)) and (m_y >= (y-border)) and (m_y <= (y + height+border))) then
					-- mark gsid
					if(mcmlNode == drag_src_mcml_node) then
						pe_mc_block.DragMoveItem(drag_src_mcml_node, mcmlNode);
					end
					-- reset drag source
					drag_src_mcml_node = nil;
					return;
				end
			else
				temp_removelist = temp_removelist or {};
				temp_removelist[ui_id] = true;
			end
		end
		if(temp_removelist) then
			for ui_id, id in pairs(temp_removelist) do
				pe_mc_block.block_icon_instances[ui_id] = nil;
			end
		end
		-- reset drag source
		drag_src_mcml_node = nil;
		pe_mc_block.DragMoveItem(drag_src_mcml_node, nil);
	end
end

-- called after drag operation. 
function pe_mc_block.DragMoveItem(src_mcml_node, dest_mcml_node)
	local srcObj = src_mcml_node:GetControl();
	if(dest_mcml_node) then
		-- exchange or add
		local destObj = dest_mcml_node:GetControl();
		local tmp_bg = srcObj.background;
		srcObj.background = destObj.background;
		destObj.background = tmp_bg;
	else
		-- discard
		srcObj.background = "";
	end

	-- TODO: also change internal bag pos data and save to disk
	-- validating for uniqueness
end


-- @param bag_pos: only refresh given bag position. if nil, it will refresh all.
function pe_mc_block.RefreshBlockIcons(bag_pos_, inventory)
	local temp_removelist;
	
	if(not inventory) then
		inventory = EntityManager.GetPlayer().inventory;
	end
	local ui_id, mcmlNode;
	for ui_id, mcmlNode in pairs(pe_mc_block.block_icon_instances) do
		local bag_pos = bag_pos_ or mcmlNode.bag_pos_;
		if(bag_pos and mcmlNode.bag_pos_ == bag_pos and mcmlNode.inventory == inventory) then
			local block_id, block_count = inventory:GetItemByBagPos(bag_pos);
			if(mcmlNode.block_id ~= block_id or mcmlNode.block_count ~= block_count) then
				-- TODO: also verify block_count
				local ui_obj = ParaUI.GetUIObject(ui_id);
				if(ui_obj:IsValid()) then
					mcmlNode.block_id = block_id;
					mcmlNode.block_count = block_count;

					local block_item = ItemClient.GetItem(block_id);
					if(block_item) then
						ui_obj.background = block_item:GetIcon():gsub("#", ";");
						-- what about mcml tooltip? 
						ui_obj.tooltip = block_item:GetTooltip();

						if(block_count and block_count>1) then
							ui_obj.text = tostring(block_count);
						else
							ui_obj.text = "";
						end
					else
						ui_obj.background = "";
						ui_obj.tooltip = "";
						ui_obj.text = "";
					end
				else
					temp_removelist = temp_removelist or {};
					temp_removelist[ui_id] = true;
				end
			end
		end
	end

	if(temp_removelist) then
		for ui_id, mcmlNode in pairs(temp_removelist) do
			pe_mc_block.block_icon_instances[ui_id] = nil;
		end
	end
end