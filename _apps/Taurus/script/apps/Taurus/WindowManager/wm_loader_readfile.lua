--[[
Title: loader to read editor file
Author(s): LiXizhi
Date: 2010.10.25
Desc: 

READ
EditorFileData

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_loader_readfile.lua");
local readfile = commonlib.gettable("PETools.Loader.readfile");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Taurus/WindowManager/wm.lua");
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_global.lua");
NPL.load("(gl)script/apps/Taurus/Editors/Screen/screen_ops.lua");
local wmWindowManager = commonlib.gettable("PETools.WindowManager.wmWindowManager");
local wmScreen = commonlib.gettable("PETools.WindowManager.wmScreen");
local wm_main = commonlib.gettable("PETools.WindowManager.wm_main");
local Main = commonlib.gettable("PETools.WindowManager.Main");
local wm_files = commonlib.gettable("PETools.WindowManager.wm_files");
local G = commonlib.gettable("PETools.Global");
local RNA = commonlib.gettable("PETools.RNA");

----------------------------------
-- the global file data structure
----------------------------------
local EditorFileData = commonlib.inherit(nil, commonlib.gettable("PETools.Loader.EditorFileData"));

function EditorFileData:ctor()
	self.main = nil;
	self.user = nil;

	self.winpos = nil;
	self.fileflags = nil;
	self.displaymode = nil;
	self.globalf = nil;
	self.filename = nil;

	-- current screen
	self.curscreen = nil;
	-- current scene
	self.curscene = nil;
	-- file type
	self.type = nil;
end

----------------------
-- file reader
----------------------
local readfile = commonlib.gettable("PETools.Loader.readfile");
-- read from a given file. 
-- @param filename: the string name. 
-- @return EditorFileData (already converted to internal object, and only needs to assign to context and refresh view). 
function readfile.read_from_file(filename)
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		return readfile.read_file_internal(xmlRoot, filename);
	end
end

-- read editor xml file (xml root node)
-- @param xmlRoot: the file data (XML node object). 
-- @return: return the file data
function readfile.read_file_internal(xmlRoot, filename)
	if(not xmlRoot) then return end
	local bfd = EditorFileData:new();
	bfd.main = Main:new();

	local node = commonlib.XPath.selectNode(xmlRoot, "//ParaEngineEditorFileData");
	if(not node) then return end
	local rootNode = node;
	bfd.main.fileversion = rootNode.attr.fileversion;
	bfd.type = "EDITORFILETYPE_XML";

	node = commonlib.XPath.selectNode(rootNode, "/Header");
	-- for header
	if(node) then
		bfd.winpos = tonumber(node.attr.winpos);
		bfd.displaymode = node.attr.displaymode;
		bfd.fileflags = node.attr.fileflags;
	end

	-- read all datablocks. 
	local data_blocks = commonlib.XPath.selectNode(rootNode, "/DataBlocks");
	local node;
	for node in commonlib.XPath.eachNode(data_blocks, "/DataBlock") do
		local attr = node.attr;
		local name = attr.name;

		local listbase = bfd.main:get_listbase(name); 
		if(not listbase) then
			LOG.error("list base %s not found", name);
			return
		end
		
		if(name == "wm") then
			local wm = wmWindowManager:new();
			wm:load(node);
			listbase:addtail(wm);
		elseif(name == "screen") then
			local screen = wmScreen:new();
			screen:load(node);
			-- use the first one as the current screen. 
			if(not bfd.curscreen) then
				bfd.curscreen = screen;
			end
			listbase:addtail(screen);
		elseif(name == "scene") then
			-- TODO: how to create a scene object properly. 
			local scene = {attr=node.attr, };
			listbase:addtail(scene);
			-- use the first one as the current scene. 
			if(not bfd.curscene) then
				bfd.curscene = scene;
			end

		elseif(name == "object") then
		elseif(name == "camera") then
		elseif(name == "screen") then
		elseif(name == "world") then
		end
	end
	return bfd;
end
