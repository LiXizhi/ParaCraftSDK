--[[
Title: Enumerations
Author(s): LiXizhi, 
Date: 2015/5/27
Desc: 

references: qnamespace in QT. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/Namespace.lua");
local FocusPolicy = commonlib.gettable("System.Core.Namespace.FocusPolicy");
------------------------------------------------------------
]]

local FocusPolicy = commonlib.createtable("System.Core.Namespace.FocusPolicy", {
    NoFocus = 0,
    TabFocus = 1,
    ClickFocus = 2,
    StrongFocus = 3,
    WheelFocus = 4,
});