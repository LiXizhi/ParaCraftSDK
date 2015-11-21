--[[
Title: camera actor
Author(s): LiXizhi
Date: 2014/3/30
Desc: for recording and playing back of camera creation and editing. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorCamera.lua");
local ActorCamera = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorCamera");
-------------------------------------------------------
]]
-- force return nil. 
function Actor:GetEditableVariable()
end

-- @return true if recording. 
function Actor:SetRecording(isRecording)
end

-- select me: for further editing. 
function Actor:SelectMe()
end

-- get the camera settings before SetFocus is called. this usually stores the current player's camera settings
-- before a movie clip is played. we will usually restore the camera settings when camera is reset. 
function Actor:GetRestoreCamSettings()
end
