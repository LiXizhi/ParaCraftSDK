--[[
Title: actor commands
Author(s): LiXizhi
Date: 2014/4/9
Desc: a number of command that is executed on the time line. 
Please note, only movie related command is recommended to use, such that dragging timeline will match the actual output
current supported addkey command is:
	/addkey text [any text]
	/addkey tip [any text]
	/addkey fadein [seconds or 0.5]
	/addkey fadeout [seconds or 0.5]
	/addkey time [number:-1,1]
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorCommands.lua");
local actor = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorCommands");
-------------------------------------------------------
]]
-- get child actor
-- @param name: "actor_text", "actor_blocks", etc
function Actor:GetChildActor(name)
end

-- get display name
function Actor:GetDisplayName()
end

-- @return nil or a table of variable list. 
function Actor:GetEditableVariableList()
end

-- @param selected_index: if nil,  default to current index
-- @return var
function Actor:GetEditableVariable(selected_index)
end

-- @return true if recording. 
function Actor:SetRecording(isRecording)
end

-- the same command can only be played once. 
function Actor:PlayCmd(curTime)
end

-- day time. 
function Actor:PlayTime(curTime)
end

-- add movie text at the current time. 
function Actor:AddKeyFrameOfText(text)
end

-- add movie text at the current time. 
function Actor:AddKeyFrameOfTime(time)
end

-- let the user to create a key and add to current timeline 
function Actor:CreateKeyFromUI(keyname, callbackFunc)
end

-- virtual function: display a UI to let the user to edit this keyframe's data. 
function Actor:EditKeyFrame(keyname, time)
end

-- remove GUI text
function Actor:OnRemove()
end
