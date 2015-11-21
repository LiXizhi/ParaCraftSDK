--[[
Title: movie clip
Author(s): LiXizhi
Date: 2014/3/30
Desc: a movie clip is a group of actors (time series entities) that are sharing the same time origin. 
multiple connected movie clip makes up a movie. The camera actor is a must have actor in a movie clip.
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieClipTimeLine.lua");
local MovieClipTimeLine = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieClipTimeLine");
-------------------------------------------------------
]]
-- force update all time variables. Only called once during page rebuild
function MovieClipTimeLine:UpdateUI()
end

-- get actor at given channel
function MovieClipTimeLine:GetActorAt(channel_name)
end

-- set actor that is being watched (edited). 
-- @param channel_name: "cur_actor", "sub_actor"
function MovieClipTimeLine:SetActorAt(channel_name, actor)
end

-- show timeline line block at the bottom of the screen with different color. 
-- @param state: "activated", "playing", "recording", "not_recording", nil. nil to cancel timeline
function MovieClipTimeLine:ShowTimeline(state)
end

-- update the time display on the timeline
function MovieClipTimeLine:UpdateTimeSlider(curTime, totalTime)
end

function MovieClipTimeLine.OnClickToggleSubVariable()
end

-- get current variable list.
-- @return variables, actor  
function MovieClipTimeLine:GetVariableList()
end

-- @return var, actor: please note the second actor may not be selected actor, such as camera. 
function MovieClipTimeLine:GetCurrentSubFrameVariable(bCreateIfNotExist)
end

-- automatically add a key frame to the current time line. 
function MovieClipTimeLine.OnClickAddSubFrameKey()
end

-- edit the command key frame : such as subscript, time, music etc. 
function MovieClipTimeLine.OnClickEditSubFrameKey(time)
end

-- shifting keyframes from shift_begin_time to end by the amount of offset_time. 
function MovieClipTimeLine.OnShiftSubFrame(shift_begin_time, offset_time)
end

-- remove keyframes from shift_begin_time to end by the amount of offset_time. 
function MovieClipTimeLine.OnRemoveSubFrame(keytime)
end

-- update the sub keyframe timeline of the current selected actor. 
-- only called privately
function MovieClipTimeLine:UpdateSubKeyFrames(curTime, bForceUpdate)
end

---------------------------------------------------------------
-- ActorCamera|ActorNPC related timeline functions
---------------------------------------------------------------
function MovieClipTimeLine:GetCurrentKeyFrameVariable()
end

-- shifting keyframes from shift_begin_time to end by the amount of offset_time. 
function MovieClipTimeLine.OnShiftKeyFrame(shift_begin_time, offset_time)
end

-- remove keyframes from shift_begin_time to end by the amount of offset_time. 
function MovieClipTimeLine.OnRemoveKeyFrame(keytime)
end

-- remove keyframes from shift_begin_time to end by the amount of offset_time. 
function MovieClipTimeLine.OnCopyKeyFrame(keytime, from_keytime)
end

-- remove keyframes from shift_begin_time to end by the amount of offset_time. 
function MovieClipTimeLine.OnMoveKeyFrame(keytime, from_keytime)
end

-- goto the given frame 
function MovieClipTimeLine.OnClickGotoFrame(time)
end

-- @param lengthMS in ms seconds
function MovieClipTimeLine:UpdateMovieLength()
end

-- update the ActorCamera and ActorCommands's timelines (two timelines are both updated)
-- @param bForceUpdate: true to force update. 
function MovieClipTimeLine:UpdateKeyFrames(curTime, bForceUpdate)
end
