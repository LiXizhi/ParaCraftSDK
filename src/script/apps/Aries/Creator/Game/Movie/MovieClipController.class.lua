--[[
Title: MovieClipController Page
Author(s): LiXizhi
Date: 2014/4/5
Desc: # is used as the line seperator \r\n. Space key is replaced by _ character. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieClipController.lua");
local MovieClipController = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieClipController");
MovieClipController.ShowPage(bShow);
MovieClipController.SetFocusToItemStack(itemStack);
-------------------------------------------------------
]]
function MovieClipController.OnInit()
end

-- @param bShow:true to refresh or show
function MovieClipController.ShowPage(bShow, OnClose)
end

-- get the movie actor associated with the current itemStack
function MovieClipController.GetMovieActor()
end

-- if not active actor, we will set focus backto current player
function MovieClipController.SetFocusToActor()
end

-- update button pressed and unpressed state. 
function MovieClipController.UpdateUI()
end

-- record and pause, thus clearing all animations from current frame to end. 
function MovieClipController.ClearAllAnimationFromCurrentFrame()
end

-- @param bLock: if nil, means toggle
function MovieClipController.ToggleLockAllActors(bLock)
end
