--[[
Title: wmKeyMapItem, wmKeyMap, wmKeyConfig
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/Taurus/WindowManager/wm_keymap.lua");
------------------------------------------------------------
]]
local wmKeyMapItem = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmKeyMapItem"));

-- partial copy of the event, for matching by eventhandler
function wmKeyMapItem:ctor()
	-- ==operator==
	-- used to retrieve operator type pointer
	self.idname = nil;	
	-- operator properties, can be written to a file 
	self.properties = nil;
	
	-- ==modal==
	-- if used, the item is from modal map
	self.propvalue = nil;

	-- ==event==
	-- event code itself
	self.type = nil;
	self.val = nil;
	self.shift, self.ctrl, self.alt = nil, nil, nil;
	-- rawkey modifier
	self.keymodifier = nil;
	
	-- flag: inactive, expanded: KMI_INACTIVE=1,  KMI_EXPANDED=2
	self.flag = nil;

	-- ==runtime==
	-- keymap editor
	self.maptype = nil;
	-- unique identifier 
	self.id = nil;
end

local wmKeyMap = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmKeyMap"));

-- stored in window manager, the actively used keymaps 
function wmKeyMap:ctor()
	-- list of wmKeyMapItem
	self.items = {};
	-- global editor keymaps, or for more per space/region
	self.idname = nil;
	--  spacetype id
	self.spaceid = nil; 
	self.regionid = nil;
	
	-- general flags
	-- KEYMAP_MODAL				1	modal map, not using operatornames 
	-- KEYMAP_USER				2	user created keymap
	-- KEYMAP_EXPANDED			4
	-- KEYMAP_CHILDREN_EXPANDED	8
	self.flag = nil;
	-- last key map item id 
	self.kmi_id = nil;
	
	-- ==runtime== 
	-- function callback of function(conten) end;	verify if enabled in the current context 
	self.poll = nil;

	-- for modal, EnumPropertyItem for now
	self.modal_items = {};
end

local wmKeyConfig = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmKeyConfig"));

function wmKeyConfig:ctor()
	-- unique name
	self.idname = nil;
	-- idname of configuration this is derives from, "" if none
	self.basename = "";
	-- search term for filtering in the UI
	self.filter = nil;
	
	-- list of key maps
	self.keymaps = {};
	self.actkeymap, self.flag = nil, nil;
end