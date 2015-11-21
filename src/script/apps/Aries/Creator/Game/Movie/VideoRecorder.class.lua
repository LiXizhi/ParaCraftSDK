--[[
Title: video recorder
Author(s): LiXizhi
Date: 2014/5/15
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/VideoRecorder.lua");
local VideoRecorder = commonlib.gettable("MyCompany.Aries.Game.Movie.VideoRecorder");
VideoRecorder.ToggleRecording();
-------------------------------------------------------
]]
-- @param callbackFunc: called when started. function(bSucceed) end
function VideoRecorder.BeginCapture(callbackFunc)
end

-- adjust window resolution
-- @param callbackFunc: function is called when window size is adjusted. 
function VideoRecorder.AdjustWindowResolution(callbackFunc)
end
