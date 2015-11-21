--[[
Title: a sequence of one or more remote movie blocks
Author(s): LiXizhi
Date: 2014/10/13
Desc: we can put movie blocks on the timeline of a single parent movie block. 
Thus allowing precise editing of movie block playing time (without using wires and repeaters)
One cool feature is that we can preview and edit on a single time line for many movie blocks. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorMovieSequence.lua");
local ActorMovieSequence = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorMovieSequence");
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

-- virtual function: display a UI to let the user to edit this keyframe's data. 
-- @param default_value: if nil, it will be the one already on the timeline. 
function Actor:EditKeyFrame(keyname, time, default_value, callbackFunc)
end
