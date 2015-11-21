--[[
Title: for rendering keyframes in a timeline
Author(s): LiXizhi
Date: 2014/4/6
Desc: rendering keyframes in a timeline
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/KeyFrameCtrl.lua");
local KeyFrameCtrl = commonlib.gettable("MyCompany.Aries.Game.Movie.KeyFrameCtrl");
local ctl = KeyFrameCtrl:new({
	name = "KeyFrameCtrl",
	onclick_frame = function(time)
	end, 
})
-------------------------------------------------------
]]
-- create a new object
-- @param o: {name="my_texture_grid"}
function KeyFrameCtrl:new(o)
end

-- clear all objects
function KeyFrameCtrl:clear()
end

-- clip the texture using a rectangular shape
-- this is the single most important function to clip and draw to the render target
-- @param left, top, right, bottom: or in logics units
function KeyFrameCtrl:clip(left, top, right, bottom)
end

--@param variable: instance of TimeSeries/AnimBlock.lua
function KeyFrameCtrl:SetVariable(variable)
end

-- in ms seconds
function KeyFrameCtrl:SetEndTime(time)
end

-- whether time is inside the view
function KeyFrameCtrl:intersect(time)
end

-- shift all key frames
function KeyFrameCtrl:OnBeginShiftFrame(time, ui_x)
end

-- @param bIsOK:true to perform the final shift operation. otherwise cancel it. 
function KeyFrameCtrl:OnEndShiftFrame(bIsOK)
end

-- @param value: if nil, it will be set value
function KeyFrameCtrl:SetUIObjTooltip(ui_obj, time, value)
end

-- get time and ui_x from relative mouse position. It will automatically snap to closest key time. 
-- @param rx: relative x pixel
-- @return time, ui_x: key time and corrected ui_x position. 
function KeyFrameCtrl:GetKeyTimeByUIPos(rx)
end

-- goto a given frame by clicking on the blanck space. .
-- if we are clicking close to keyframe, we will goto the frame next to the keyframe. 
function KeyFrameCtrl:OnClickTimeLine(uiobj)
end

-- @param ui_x: force using the given x position 
function KeyFrameCtrl:UpdateLastClickFrame(time, ui_x)
end

-- @param bSnapToGrid: [not implemented] whether to snap to closest keyframe grid. 
function KeyFrameCtrl:UpdateCurrentTime(curTime, bSnapToGrid)
end

-- @param parent: if nil, it will use last one. 
-- @param width, height: if nil, it will be self.width, self.height. 
function KeyFrameCtrl:Update(_parent, width, height)
end
