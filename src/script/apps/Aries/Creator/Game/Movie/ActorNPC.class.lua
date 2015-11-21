--[[
Title: mob entity actor
Author(s): LiXizhi
Date: 2014/3/30
Desc: for recording and playing back of mob and NPC
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorNPC.lua");
local ActorNPC = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorNPC");
-------------------------------------------------------
]]
function Actor:ctor()
end

-- get position multi variable
function Actor:GetPosVariable()
end

-- get rotate multi variable
function Actor:GetRotateVariable()
end

-- get position multi variable
function Actor:GetHeadVariable()
end

-- load bone animations if not loaded before, this function does nothing if no bones are in the time series. 
function Actor:CheckLoadBonesAnims()
end

-- @return nil or a table of variable list. 
function Actor:GetEditableVariableList()
end

-- @param selected_index: if nil,  default to current index
-- @return var
function Actor:GetEditableVariable(selected_index)
end

-- clear all record to a given time. if curTime is nil, it will use the current time. 
function Actor:ClearRecordToTime(curTime)
end

-- whether the actor can create blocks. The camera actor can not create blocks
function Actor:CanCreateBlocks()
end

-- this function is called whenver the create block task is called. i.e. the user has just created some block
function Actor:OnCreateBlocks(blocks)
end

-- this function is called whenver the destroy block task is called. i.e. the user has just destroyed some blocks
function Actor:OnDestroyBlocks(blocks)
end

-- select me: for further editing. 
function Actor:SelectMe()
end

-- bone selection changed in editor
function Actor:OnChangeBone(bone_name)
end
