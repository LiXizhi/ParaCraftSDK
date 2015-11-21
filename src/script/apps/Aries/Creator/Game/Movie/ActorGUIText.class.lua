--[[
Title: actor text
Author(s): LiXizhi
Date: 2014/4/10
Desc: for movie subscript text. This actually a helper class for ActorCommands.
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorGUIText.lua");
local actor = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorGUIText");
-------------------------------------------------------
]]
function Actor:ctor()
end

-- @return true if recording. 
function Actor:SetRecording(isRecording)
end

-- remove GUI text
function Actor:OnRemove()
end

-- add movie text at the current time. 
-- @param values: text or a table of {text, ...}
function Actor:AddKeyFrameOfText(values)
end

-- static function:
-- once locked any calls to update the text will do nothing
function Actor:Lock()
end

-- static function:
function Actor:Unlock()
end

-- return the text gui object. 
function Actor:GetTextObj(bCreateIfNotExist)
end

-- update UI text with given values. 
function Actor:UpdateTextUI(text, fontsize, fontcolor, textpos, bgalpha, textalpha, bgcolor)
end

function Actor:FrameMovePlaying(deltaTime)
end
