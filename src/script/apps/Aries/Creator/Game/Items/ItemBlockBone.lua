--[[
Title: ItemBlockBone
Author(s): LiXizhi
Date: 2015/9/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemBlockBone.lua");
local ItemBlockBone = commonlib.gettable("MyCompany.Aries.Game.Items.ItemBlockBone");
local item_ = ItemBlockBone:new({icon,});
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local ItemBlockBone = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Items.Item"), commonlib.gettable("MyCompany.Aries.Game.Items.ItemBlockBone"));

block_types.RegisterItemClass("ItemBlockBone", ItemBlockBone);

-- @param template: icon
-- @param radius: the half radius of the object. 
function ItemBlockBone:ctor()
end

-- Called whenever this item is equipped and the right mouse button is pressed.
-- @return the new item stack to put in the position.
function ItemBlockBone:OnItemRightClick(itemStack, entityPlayer)
	
end

-- virtual function: when selected in right hand
function ItemBlockBone:OnSelect()
	GameLogic.SetStatus(L"箭头方向为父骨骼, 与其他方向连接的同色方块为皮肤");
end

function ItemBlockBone:OnDeSelect()
	GameLogic.SetStatus(nil);
end
