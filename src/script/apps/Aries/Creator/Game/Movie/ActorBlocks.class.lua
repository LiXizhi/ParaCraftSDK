--[[
Title: blocks actor
Author(s): LiXizhi
Date: 2014/3/30
Desc: for recording and playing back of blocks creation and editing. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorBlocks.lua");
local actor = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorBlocks");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/SelectBlocksTask.lua");
local SelectBlocks = commonlib.gettable("MyCompany.Aries.Game.Tasks.SelectBlocks")
-------------------------------------------------------
]]
function Actor:ctor()
end

-- @return true if recording. 
function Actor:SetRecording(isRecording)
end

-- remove all blocks
function Actor:OnRemove()
end

-- update block set in block time series variable as well as the given new_blocks 
function Actor:UpdateBlockSet()
end

-- add movie text at the current time. 
function Actor:AddKeyFrameOfSelectedBlocks()
end

-- @param blocks: update blocks. 
function Actor:UpdateBlocks(blocks, curTime, bIsSelected)
end

-- update selection effect in the scene for editing mode. 
function Actor:UpdateSelection(bIsSelected, bForceUpdate)
end

-- virtual function: display a UI to let the user to edit this keyframe's data. 
function Actor:EditKeyFrame(keyname, time)
end
