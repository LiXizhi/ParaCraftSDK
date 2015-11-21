--[[
Title: a single music track on the time line
Author(s): LiXizhi
Date: 2014/10/15
Desc: playing a music file on the time line, dragging the time line will automatically seek to the music file
allowing precise editing between music and 3d scene. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorMusic.lua");
local ActorMusic = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorMusic");
-------------------------------------------------------
]]
-- @return true if recording. 
function Actor:SetRecording(isRecording)
end

-- remove all blocks
function Actor:OnRemove()
end

-- virtual function: display a UI to let the user to edit this keyframe's data. 
-- @param default_value: if nil, it will be the one already on the timeline. {filename, start_time}
function Actor:EditKeyFrame(keyname, time, default_value, callbackFunc)
end
