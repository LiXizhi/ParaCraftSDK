--[[
Title: All common libraries in IDE
Author:LiXizhi
Date : 2008.10.25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/IDE.lua");
-------------------------------------------------------
]]

--
-- base IDE lib
--
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua"); -- perf
NPL.load("(gl)script/ide/Locale.lua");
NPL.load("(gl)script/lang/lang.lua"); -- default IDE language localizations: this may be removed
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/headon_speech.lua");
NPL.load("(gl)script/ide/event_mapping.lua");
NPL.load("(gl)script/ide/action_table.lua");
NPL.load("(gl)script/ide/os.lua");
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/ide/sandbox.lua");
NPL.load("(gl)script/ide/ParaEngineExtension.lua"); -- NPLExtension also included within
NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
NPL.load("(gl)script/ide/System/Core/Core.lua");
NPL.load("(gl)script/ide/System/Windows/Window.lua");

--
-- mcml related
--
NPL.load("(gl)script/kids/3DMapSystemApp/mcml/mcml.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
