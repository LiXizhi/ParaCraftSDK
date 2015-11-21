--[[
Title: For editing radius like property in 3d scene
Author(s): LiXizhi
Date: 2010/6/10
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityHelperCircleEditor.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/IPCBinding/EntityHelperEditorBase.lua");
local CircleEditor = commonlib.inherit(commonlib.gettable("IPCBinding.Editors.EditorBase"), commonlib.gettable("IPCBinding.Editors.CircleEditor"));

function CircleEditor:ctor()
end