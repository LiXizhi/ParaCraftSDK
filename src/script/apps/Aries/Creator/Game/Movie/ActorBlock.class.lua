--[[
Title: block actor
Author(s): LiXizhi
Date: 2014/4/17
Desc: for recording and playing back of block creation and deletion. 
This is different from ActorBlocks, in that it will record one creation or deletion action per keyframe. 
This class is thus used by ActorNPC for block creation and deletion playback. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorBlocks.lua");
local actor = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorBlock");
-------------------------------------------------------
]]
-- remove all blocks
function Actor:OnRemove()
end

-- update block set in block time series variable as well as the given new_blocks 
-- precalculate time series
function Actor:InitializeTimeSeries()
end

-- clear all record to a given time. if curTime is nil, it will use the current time. 
function Actor:ClearRecordToTime(curTime)
end

-- add movie blocks at the current time. 
-- @param blocks: {{x,y,z,block_id, block_data, last_block_id = number, last_block_data = number, }, ...}
function Actor:AddKeyFrameOfBlocks(new_blocks)
end

-- @param blocks: update blocks. 
function Actor:UpdateBlocks(blocks, curTime)
end
