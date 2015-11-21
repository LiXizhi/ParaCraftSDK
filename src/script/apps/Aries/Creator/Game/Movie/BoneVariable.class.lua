--[[
Title: Bone variable
Author(s): LiXizhi
Date: 2015/9/8
Desc: a single bone variable, it is a multi variable containing rotation, translation and scaling attribute variable. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/BoneVariable.lua");
local BoneVariable = commonlib.gettable("MyCompany.Aries.Game.Movie.BoneVariable");
-------------------------------------------------------
]]
-- @param attr: parax bone attribute model
-- @param animInstance: the animation instance 
-- @param parent: get the parent BonesVariable.
function BoneVariable:init(attr, animInstance, parent)
end

-- save from C++'s current anim instance to actor's timeseries
function BoneVariable:SaveToTimeVar()
end

-- Load from actor's timeseries to C++'s current anim instance. 
function BoneVariable:LoadFromTimeVar()
end
