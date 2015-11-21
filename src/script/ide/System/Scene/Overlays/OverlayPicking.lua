--[[
Title: OverlayPicking
Author(s): LiXizhi@yeah.net
Date: 2015/8/15
Desc: picking all overlays from overlay backbuffer

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Overlays/OverlayPicking.lua");
local OverlayPicking = commonlib.gettable("System.Scene.Overlays.OverlayPicking");
local result = OverlayPicking:Pick(nil, nil, 2, 2);
echo(result);
echo({System.Core.Color.DWORD_TO_RGBA(result[1] or 0)});
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/BufferPicking.lua");
local BufferPicking = commonlib.gettable("System.Scene.BufferPicking");
local OverlayPicking = commonlib.inherit(commonlib.gettable("System.Scene.BufferPicking"), commonlib.gettable("System.Scene.Overlays.OverlayPicking"));

OverlayPicking:Property("Name", "OverlayPicking");
OverlayPicking:Property({"m_pickingName", 0, "GetActivePickingName"});

local first_picking_name = 1;

function OverlayPicking:ctor()
	self.next_picking_id = first_picking_name;
end

function OverlayPicking:CreatePickingBuffer_sys()
	self.engine = ParaEngine.GetAttributeObject():GetChild("OverlayPicking");
end

function OverlayPicking:ResetPickingName()
	self.next_picking_id = first_picking_name;
end

function OverlayPicking:GetPickingCount()
	-- reset picking name, when we are fetching the result.
	self:ResetPickingName();
	return OverlayPicking._super.GetPickingCount(self);
end

function OverlayPicking:GetPickingResult()
	local nPickedId = 0; 
	local result = OverlayPicking._super.GetPickingResult(self);
	if(result) then
		for i =1, #result do
			if(result[i] ~= 0) then
				nPickedId = result[i];
				break;
			end
		end
	end
	self:SetActivePickingName(nPickedId);
	return result;
end

-- find next color int value that should be used for the picking color for next unique pickable item.
function OverlayPicking:GetNextPickingName()
	self.next_picking_id = self.next_picking_id + 1;
	return self.next_picking_id;
end

-- picking name from the last picking result.
function OverlayPicking:GetActivePickingName()
	return self.m_pickingName;
end

-- usually called automatically. remove the alpha channel.
-- set the name of last picking result.
function OverlayPicking:SetActivePickingName(name)
	name = name or 0;
	if(name>0xff000000) then
		self.m_pickingName = name - 0xff000000;
	else
		self.m_pickingName = name;
	end
end


OverlayPicking:InitSingleton();