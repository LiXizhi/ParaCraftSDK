--[[
Title: An area is a non-overlaping space inside a screen
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/Editors/Screen/area.lua");
local wmArea = commonlib.gettable("PETools.WindowManager.wmArea");
------------------------------------------------------------
]]
local wmArea = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmArea"));

-- constructor
function wmArea:ctor()
end
