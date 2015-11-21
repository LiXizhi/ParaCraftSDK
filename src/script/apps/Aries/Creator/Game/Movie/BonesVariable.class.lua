--[[
Title: Bones variable
Author(s): LiXizhi
Date: 2015/9/8
Desc: all explicitly animated bones in actor. 
We can select one or all bones. Select no bones means querying all bones's key, values. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/BonesVariable.lua");
local BonesVariable = commonlib.gettable("MyCompany.Aries.Game.Movie.BonesVariable");
BonesVariables:init(actor)
BonesVariables:SetSelectedBone(name)
-------------------------------------------------------
]]
-- get animation instance attribute model.
function BonesVariable:GetAnimInstance()
end

-- load data from actor's timeseries to animation instance in C++ side if any 
function BonesVariable:LoadFromActor()
end

-- return the time series variable
function BonesVariable:GetTimeVariable(name)
end

-- create get bone variables for advanced editing
-- This function is only called, when wants to edit variables. 
function BonesVariable:GetVariables()
end

-- get selected bone variable. 
function BonesVariable:GetSelectedBone()
end

-- variable is returned as an array of individual variable value at the given time. 
function BonesVariable:getValue(anim, time)
end

-- iterator that returns, all (time, values) pairs between (TimeFrom, TimeTo].  
-- the iterator works fine when there are identical time keys in the animation, like times={0,1,1,2,2,2,3,4}.  for time keys in range (0,2], 1,1,2,2,2, are returned. 
function BonesVariable:GetKeys_Iter(anim, TimeFrom, TimeTo)
end
