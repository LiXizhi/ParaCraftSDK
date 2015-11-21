--[[
Title: IDE framework based on IPC data-binding
Author(s): LiXizhi
Date: 2010/6/1
Desc: include this file to load all IDE and IPC related stuffs
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/Framework.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/ExternalInterface.lua");
NPL.load("(gl)script/ide/IPCBinding/IPCBinding.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityBase.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityView.lua");
NPL.load("(gl)script/ide/IPCBinding/InstanceView.lua");
NPL.load("(gl)script/ide/IPCBinding/IPCBindingContext.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityHelper.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityTemplate.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityHelperEditorBase.lua");

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MapHelper.lua");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
NPL.load("(gl)script/ide/GraphHelp.lua");
NPL.load("(gl)script/ide/Graph.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/DummySatellite.lua");
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererCommon.lua");
local GathererCommon = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererCommon");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
NPL.load("(gl)script/apps/Aries/Pipeline/SpellCastViewer/SpellCastViewerPage.lua");
NPL.load("(gl)script/ide/Director/SpellCameraHelper.lua");
local SpellCameraHelper = commonlib.gettable("Director.SpellCameraHelper");
NPL.load("(gl)script/ide/Director/DirectorToolPage.lua");
local DirectorToolPage = commonlib.gettable("Director.DirectorToolPage");
local Framework = commonlib.gettable("IPCBinding.Framework");