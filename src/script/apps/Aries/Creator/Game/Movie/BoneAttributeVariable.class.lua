--[[
Title: Bone attribute variable
Author(s): LiXizhi
Date: 2015/9/15
Desc: a single attribute like rotation, trans or scaling on a bone. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/BoneAttributeVariable.lua");
local BoneAttributeVariable = commonlib.gettable("MyCompany.Aries.Game.Movie.BoneAttributeVariable");
-------------------------------------------------------
]]
-- @param attrName: 
-- @param attrType: "rot", "scale", "trans": this will affect default value and type
-- @param attr: parax bone attribute model
-- @param animInstance: the animation instance 
-- @param parent: get the parent BonesVariable.
function BoneAttributeVariable:init(attrName, attrType, attr, animInstance, parent)
end

-- save from C++'s current anim instance to actor's timeseries
function BoneAttributeVariable:SaveToTimeVar()
end

-- Load from actor's timeseries to C++'s current anim instance. 
function BoneAttributeVariable:LoadFromTimeVar()
end

-- variable is returned as an array of individual variable value at the given time. 
function BoneAttributeVariable:getValue(anim, time)
end

-- only support modifying existing key at time
-- TODO: support add key
function BoneAttributeVariable:AddKey(time, data)
end

-- iterator that returns, all (time, value) pairs between (TimeFrom, TimeTo].  
-- the iterator works fine when there are identical time keys in the animation, like times={0,1,1,2,2,2,3,4}.  for time keys in range (0,2], 1,1,2,2,2, are returned. 
function BoneAttributeVariable:GetKeys_Iter(anim, TimeFrom, TimeTo)
end
