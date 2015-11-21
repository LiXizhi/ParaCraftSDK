--[[
Title: Point Editor for IDE property
Author(s): LiXizhi
Date: 2010/6/8
Desc: Point editor allows user to visually edit a vector3 property on a databinded entity instance
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityHelperPointEditor.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/IPCBinding/EntityHelperEditorBase.lua");

local PointEditor = commonlib.inherit(IPCBinding.Editors.EditorBase, commonlib.gettable("IPCBinding.Editors.PointEditor"));


