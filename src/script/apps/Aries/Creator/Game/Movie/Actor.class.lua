--[[
Title: base actor class
Author(s): LiXizhi
Date: 2014/3/30
Desc: for recording and playing back
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/Actor.lua");
local actor = commonlib.gettable("MyCompany.Aries.Game.Movie.Actor");
-------------------------------------------------------
]]
-- virtual function
function Actor:GetChildActor(name)
end

-- get the movie clip that contains this actor. 
function Actor:GetMovieClip()
end

-- it is only in playing mode when activated by a redstone circuit. 
-- any other way of triggering the movieclip is not playing mode(that is edit mode)
function Actor:IsPlayingMode()
end

-- get display name
function Actor:GetDisplayName()
end

-- @return the entity position if any
function Actor:GetPosition()
end

-- virtual:
-- @return nil or a table of variable list. 
function Actor:GetEditableVariableList()
end

-- virtual: 
-- get editable variable by index. only used by editor for recently selected variable. 
-- @param selected_index: nil if it means the current one. 
-- @return var, cur_index
function Actor:GetEditableVariable(selected_index)
end

-- return index by name
-- @return index
function Actor:FindEditVariableByName(name)
end

-- @param bStartFromFirstKeyFrame: whether we will only value after the time of first key frame. default to false.
function Actor:GetValue(keyname, time, bStartFromFirstKeyFrame)
end

-- get last recorded time.
function Actor:GetLastTime(keyname)
end

-- select me: for further editing. 
function Actor:SelectMe()
end

-- a pair of BeginModify and EndModify will allow undo/redo of the actor's timeline. 
function Actor:BeginModify()
end

-- @return true if recording. 
function Actor:SetRecording(isRecording)
end

-- add new key at time, data. if there is already a key at the time, we will replace it. 
function Actor:AddKey(keyname, time, value)
end

-- when a group of changes takes place, such as during recording, 
-- we can put change inside BeginUpdate() and EndUpdate() pairs, so that 
-- only one keyChanged() event will be emitted. 
function Actor:BeginUpdate()
end

-- add new key at time, data. if there is already a key at the time, we will replace it. 
-- it will not add key if previous and next key is same as current. 
-- this function is ideal for recording player actions. 
function Actor:AutoAddKey(keyname, time, value)
end

-- clear all keys after time, and add the new key. 
function Actor:AutoAppendKey(keyname, time, value)
end

-- record and add a key frame at the current position. 
function Actor:AddKeyFrame()
end

-- virtual function: display a UI to let the user to edit this keyframe's data. 
function Actor:EditKeyFrame(keyname, time)
end

-- add a key frame at the specifiedi position. 
-- @param time: if nil, it is current time. 
function Actor:AddKeyFrameByName(name, time, data)
end

-- get current recording end time. 
function Actor:GetCurrentRecordingEndTime()
end

-- shifting keyframes from shift_begin_time to end by the amount of offset_time. 
function Actor:ShiftKeyFrame(shift_begin_time, offset_time)
end

-- remove the key frame at key_time if there is a key frame. 
function Actor:RemoveKeyFrame(keytime)
end

-- copy keyframe from from_keytime to keytime
function Actor:CopyKeyFrame(keytime, from_keytime)
end

-- move keyframe from from_keytime to keytime
function Actor:MoveKeyFrame(keytime, from_keytime)
end

-- clear all record to a given time. if curTime is nil, it will use the current time. 
function Actor:ClearRecordToTime(curTime)
end

-- remove all keys in the [fromTime, toTime]
-- @param fromTime: if fromTime is nil, it will use the current time. 
-- @param toTime: if nil, it will be max length. 
function Actor:RemoveKeysInTimeRange(fromTime, toTime)
end

-- whether the actor can create blocks. The camera actor can not create blocks
function Actor:CanCreateBlocks()
end

-- this function is called whenver the create block task is called. i.e. the user has just created some block
function Actor:OnCreateBlocks(blocks)
end

-- this function is called whenver the destroy block task is called. i.e. the user has just destroyed some blocks
function Actor:OnDestroyBlocks(blocks)
end

-- remove the scene entity that representing this actor. 
function Actor:OnRemove()
end

-- only supporting key frames, not recording. 
function Actor:IsKeyFrameOnly()
end

-- whether the actor is being selected in the editor
function Actor:FrameMove(deltaTime, bIsSelected)
end

-- @param getVar: get variable function. it is function that usually return the multivariable
-- @return attribute plug
function Actor:AddValue(name, getVar)
end

-- return the inner biped object
function Actor:GetInnerObject()
end

-- return the animation instance. 
function Actor:GetAnimInstance()
end

-- if no camera position is found, the current actor's position is used. 
function Actor:RestoreLastFreeCameraPosition()
end

-- @param bForceSave: if nil, we will only save if free camera has focus
function Actor:SaveFreeCameraPosition(bForceSave)
end
