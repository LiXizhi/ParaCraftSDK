--[[
Title: For editing rotation like property in 3d scene
Author(s): LiXizhi
Date: 2010/6/10
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityHelperFacingEditor.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/IPCBinding/EntityHelperEditorBase.lua");
local FacingEditor = commonlib.inherit(commonlib.gettable("IPCBinding.Editors.EditorBase"), commonlib.gettable("IPCBinding.Editors.FacingEditor"));

function FacingEditor:ctor()
end