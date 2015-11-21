--[[
Title: ItemDialog
Author(s): LiXizhi
Date: 2014/1/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemDialog.lua");
local ItemDialog = commonlib.gettable("MyCompany.Aries.Game.Items.ItemDialog");
local item_ = ItemDialog:new({icon,});
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local TaskManager = commonlib.gettable("MyCompany.Aries.Game.TaskManager")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local ItemDialog = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Items.Item"), commonlib.gettable("MyCompany.Aries.Game.Items.ItemDialog"));

block_types.RegisterItemClass("ItemDialog", ItemDialog);


-- @param template: icon
-- @param radius: the half radius of the object. 
function ItemDialog:ctor()
end

-- not stackable
function ItemDialog:GetMaxCount()
	return 1;
end

-- Called whenever this item is equipped and the right mouse button is pressed.
-- @return the new item stack to put in the position.
function ItemDialog:OnItemRightClick(itemStack, entityPlayer)
	NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EditBookPage.lua");
	local EditBookPage = commonlib.gettable("MyCompany.Aries.Game.GUI.EditBookPage");
	EditBookPage.ShowPage(itemStack);
    return itemStack, true;
end