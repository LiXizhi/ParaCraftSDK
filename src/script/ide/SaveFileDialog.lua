--[[
Title: Save File Dialog
Author(s): LiXizhi
Date: 2009/1/30
Desc: it inherits from OpenFileDialog, except that it does not check for file existence. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/SaveFileDialog.lua");
local ctl = CommonCtrl.SaveFileDialog:new{
	name = "SaveFileDialog1",
	alignment = "_ct",
	left=-256, top=-150,
	width = 512,
	height = 380,
	parent = nil,
	-- initial file name to be displayed, usually "" 
	FileName = "",
	fileextensions = {"all files(*.*)", "images(*.jpg; *.png; *.dds)", "animations(*.swf; *.wmv; *.avi)", "web pages(*.htm; *.html)", },
	folderlinks = {
		{path = "model/", text = "model"},
		{path = "Texture/", text = "Texture"},
		{path = "character/", text = "character"},
		{path = "script/", text = "script"},
	},
	onopen = function(ctrlName, filename)
	end
};
ctl:Show(true);
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/OpenFileDialog.lua");
local L = CommonCtrl.Locale("IDE");

local SaveFileDialog =  commonlib.inherit(CommonCtrl.OpenFileDialog, {
	CheckFileExists=false,
	OpenButtonName = L"save",
})

CommonCtrl.SaveFileDialog = SaveFileDialog;