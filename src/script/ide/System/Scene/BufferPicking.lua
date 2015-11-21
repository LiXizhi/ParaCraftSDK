--[[
Title: BufferPicking
Author(s): LiXizhi@yeah.net
Date: 2015/8/13
Desc: picking from frame buffer (back buffer)
When there is picking query, it will render scene again (if out dated) with a special shader and read pixels from the back buffer. 
We can query a single point or we can query a rectangle region in the current viewport and see if have hit anything. 
Please note: in order for buffer picking to work, each pickable object/component should assign a different picking id in its draw method. 
In other words, picking and drawing are done using the same draw function. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/BufferPicking.lua");
local BufferPicking = commonlib.gettable("System.Scene.BufferPicking");
local result = BufferPicking:Pick(nil, nil, 2, 2);
echo(result);
echo({System.Core.Color.DWORD_TO_RGBA(result[1] or 0)});
------------------------------------------------------------
]]

local BufferPicking = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Scene.BufferPicking"));

BufferPicking:Property("Name", "BufferPicking");

function BufferPicking:ctor()
	self:CreatePickingBuffer_sys();
end

function BufferPicking:CreatePickingBuffer_sys()
	self.engine = ParaEngine.GetAttributeObject():GetChild("BufferPicking");
end

-- pick by a point in the viewport. 
-- Tip: to pick a thin line, one may consider picking by a small rect region. 
-- @param x, y: if nil, it is the current mouse position.
-- @param width, height: if nil, 1,1
-- @param nViewportId: viewport index, if -1 it means the current viewport.
-- @return array of picking result. if nil means nothing is picked.
function BufferPicking:Pick(x, y, width, height, nViewportId)
	width = width or 1;
	height = height or 1;
	if(not x or not y) then
		local mouse_pos = System.Windows.Mouse:pos();
		x, y = mouse_pos[1], mouse_pos[2];
		x = math.floor(x - width/2 + 0.5);
		y = math.floor(y - height/2 + 0.5);
	end
	self:SetPickLeftTop(x, y);
	self:SetPickWidthHeight(width, height);
	self:SetViewport(nViewportId);
	return self:GetPickingResult();
end

-- return an array of unique picking id in the last pick call. it may return nil if nothing is picked
function BufferPicking:GetPickingResult()
	local count = self:GetPickingCount();
	if(count > 0) then
		local result = {};
		for i=0, count-1 do
			result[#result+1] = self:GetPickingID(i);
		end
		return result;
	end
end

-- return the number of objects picked. 
function BufferPicking:GetPickingCount()
	return self.engine:GetField("PickingCount", 0);
end

-- get the picked item id of the given picking item. if no data at the index return 0. 
-- @param nIndex: if -1, it will use m_currentPickIndex;
function BufferPicking:GetPickingID(nIndex)
	if(nIndex and nIndex >= 0) then
		self:SetPickIndex(nIndex);
	end
	return self.engine:GetField("PickingID", 0);
end

-- clear last picking result 
function BufferPicking:ClearPickingResult()
	self.engine:CallField("ClearPickingResult");
end

function BufferPicking:SetPickLeftTop(x, y)
	if(x and y) then
		self.engine:SetField("PickLeftTop", {x,y});
	end
end
function BufferPicking:GetPickLeftTop()
	local res = self.engine:GetField("PickLeftTop", {0,0});
	return res[1], res[2];
end

function BufferPicking:SetPickWidthHeight(w,h)
	if(w and h) then
		self.engine:SetField("PickWidthHeight", {w,h});
	end
end
function BufferPicking:GetPickWidthHeight()
	local res = self.engine:GetField("PickWidthHeight", {0,0});
	return res[1], res[2];
end

function BufferPicking:GetPickIndex()
	return self.engine:GetField("PickIndex", 0);
end
function BufferPicking:SetPickIndex(nIndex)
	if(nIndex and nIndex>=0) then
		self.engine:SetField("PickIndex", nIndex);
	end
end

function BufferPicking:IsResultDirty()
	return self.engine:GetField("ResultDirty", false);
end

function BufferPicking:SetResultDirty(bDirty)
	self.engine:SetField("ResultDirty", bDirty == true);
end

-- in which viewport to pick. default to -1, which is the default one. 
function BufferPicking:GetViewport()
	return self.engine:GetField("Viewport", -1);
end

-- in which viewport to pick. if -1, it is the default one. 
function BufferPicking:SetViewport(nViewportIndex)
	if(nViewportIndex) then
		self.engine:SetField("Viewport", nViewportIndex);
	end
end

BufferPicking:InitSingleton();