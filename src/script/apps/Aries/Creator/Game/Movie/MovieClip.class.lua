--[[
Title: movie clip
Author(s): LiXizhi
Date: 2014/3/30
Desc: a movie clip is a group of actors (time series entities) that are sharing the same time origin. 
multiple connected movie clip makes up a movie. The camera actor is a must have actor in a movie clip.
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieClip.lua");
local MovieClip = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieClip");
-------------------------------------------------------
]]
-- @param entity: movie clip entity. 
function MovieClip:Init(entity)
end

-- open the entity editor
function MovieClip:OpenEditor()
end

-- private function: do not call this function. 
-- set one of the actor is recording. 
-- currently only one actor can be made in recording state. 
-- in future or multi-player version, we may allow multiple entity
function MovieClip:SetActorRecording(actor, bIsRecording)
end

-- get the first camera actor
function MovieClip:GetCamera()
end

-- get the first command actor 
function MovieClip:GetCommand(bCreateIfNotExist)
end

-- it is only in playing mode when activated by a redstone circuit. 
-- any other way of triggering the movieclip is not playing mode(that is edit mode)
function MovieClip:IsPlayingMode()
end

-- called when this movie clip is currently playing. 
function MovieClip:OnActivated()
end

-- show/hide timeline and controller according to whether we are in edit mode or recording. 
function MovieClip:RefreshPlayModeUI()
end

-- return the actor that is having the focus
function MovieClip:GetFocus()
end

-- get currently selected actor in the movie clip controller.
function MovieClip:GetSelectedActor()
end

-- called when this movie clip is no longer playing. 
-- @param next_movieclip: the next movie clip to play. will hand over the camera focus to the next clip 
-- instead of handing over to current player. 
function MovieClip:OnDeactivated(next_movieclip)
end

-- get actor from a given entity. 
function MovieClip:GetActorByEntity(entity)
end

-- return millisecond ticks. instead of second. 
function MovieClip:GetTime()
end

-- get movie clip length in ms seconds
function MovieClip:GetLength()
end

-- set movie clip length in ms seconds
function MovieClip:SetLength(time)
end

-- only for editors, during play mode, start time is always 0. 
function MovieClip:GetStartTime()
end

-- time in millisecond ticks
function MovieClip:SetTime(curTimeMS)
end

-- whether is recording actor's action. 
function MovieClip:SetRecording(bIsRecording)
end

-- this is always a valid entity. 
function MovieClip:GetEntity()
end

-- making all actors to play mode, instead of recording mode. 
function MovieClip:SetAllActorsToPlayMode()
end

-- get the actor for a given itemstack. return nil if not exist
function MovieClip:GetActorFromItemStack(itemStack, bCreateIfNotExist)
end

-- usually called when movie finished playing. 
function MovieClip:RemoveAllActors()
end

-- get the movie clip's origin x y z position in block world. 
function MovieClip:GetBlockOrigin()
end

-- get real world origin. 
function MovieClip:GetOrigin()
end

-- private function: do not call this function. 
function MovieClip:AddActor(actor)
end

-- create and refresh all actors with the movie clip entity
function MovieClip:RefreshActors()
end

-- @param deltaTime: default to 0
function MovieClip:UpdateActors(deltaTime)
end

-- called every framemove when activated.  
-- @param deltaTime: in milli seconds. 
function MovieClip:FrameMove(deltaTime)
end
