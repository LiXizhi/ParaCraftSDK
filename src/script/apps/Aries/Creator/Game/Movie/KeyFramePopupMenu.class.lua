--[[
Title: popup menu to shown when click on a keyframe
Author(s): LiXizhi
Date: 2014/10/13
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/KeyFramePopupMenu.lua");
local KeyFramePopupMenu = commonlib.gettable("MyCompany.Aries.Game.Movie.KeyFramePopupMenu");
KeyFramePopupMenu.ShowPopupMenu(time, var, actor);
-------------------------------------------------------
]]
function KeyFramePopupMenu.SetCurrentVar(time, var, actor)
end

-- show the popup menu
-- @param var: the parent variable containing the key
-- @param actor: the parent actor containing the actor
function KeyFramePopupMenu.ShowPopupMenu(time, var, actor)
end
