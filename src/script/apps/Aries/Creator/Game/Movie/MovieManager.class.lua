--[[
Title: Movie Manager
Author(s): LiXizhi
Date: 2014/3/30
Desc: managing current movie clip
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieManager.lua");
local MovieManager = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieManager");
-------------------------------------------------------
]]
-- called when enter block world. 
function MovieManager:Init()
end

-- get the currently active movie clip
function MovieManager:GetActiveMovieClip()
end

-- return true if current actor is playing(not paused), otherwise return nil or false, such as recording or paused. 
-- usually we will disable all player heading when current player is playing back stored sequence. 
function MovieManager:IsCurrentActorPlayingback()
end

-- toggle live video recording. recording is automatically stopped when there is no movie clip to play. 
-- Hot key is R when in movie playing mode. 
function MovieManager:ToggleCapture()
end

-- automatically hide all ui, replay and record from the current movie clip. 
function MovieManager:BeginCapture()
end

-- called when unload world
function MovieManager:Exit()
end

-- set currently activate movie clip. 
function MovieManager:SetActiveMovieClip(movie_clip)
end

-- called every framemove. 
-- @param deltaTime: in millisecond ticks
function MovieManager:FrameMove(deltaTime)
end
