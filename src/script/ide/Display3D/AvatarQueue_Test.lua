--[[
Title: 
Author(s): Leio
Date: 2009/8/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/AvatarQueue_Test.lua");
CommonCtrl.Display3D.AvatarQueue_Test.Test1()
--CommonCtrl.Display3D.AvatarQueue_Test.MountOn()
--CommonCtrl.Display3D.AvatarQueue_Test.MountOff()
--CommonCtrl.Display3D.AvatarQueue_Test.DeleteChild()
--CommonCtrl.Display3D.AvatarQueue_Test.DeleteAll()
--CommonCtrl.Display3D.AvatarQueue_Test.ReAlign()
--CommonCtrl.Display3D.AvatarQueue_Test.AddChild_Test()
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local AvatarQueue_Test = {
	
}
commonlib.setfield("CommonCtrl.Display3D.AvatarQueue_Test",AvatarQueue_Test);
function AvatarQueue_Test.Test1()
	NPL.load("(gl)script/ide/Display3D/AvatarQueue.lua");
	local avatar_queue = CommonCtrl.Display3D.AvatarQueue:new();
	AvatarQueue_Test.avatar_queue = avatar_queue;
	AvatarQueue_Test.AddChild_1()
	AvatarQueue_Test.AddChild_1()
	AvatarQueue_Test.AddChild_2()
	AvatarQueue_Test.AddChild_2()
	AvatarQueue_Test.AddChild_2()
	AvatarQueue_Test.node = AvatarQueue_Test.AddChild_2()

	avatar_queue.LayoutChildrenHandler = CommonCtrl.Display3D.AvatarQueue.LayoutChildrenHandler_circle;
	avatar_queue:Start();
	avatar_queue:ControlByPlayer();
	
end
function AvatarQueue_Test.AddChild_1()
	local node = CommonCtrl.Display3D.SceneNode:new{
		x = 255,
		y = 0,
		z = 255,
		assetfile = "model/06props/shared/pops/muzhuang.x",
	};
	AvatarQueue_Test.avatar_queue:AddChild(node);
	return node;
end
function AvatarQueue_Test.AddChild_2()
	local node = CommonCtrl.Display3D.SceneNode:new{
		x = 245,
		y = 0,
		z = 255,
		old_x = 245,
		old_y = 0,
		old_z = 255,
		assetfile = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.x",
		ischaracter = true,
		scaling = 0.8,
		update_with_character = false,
	};
	AvatarQueue_Test.avatar_queue:AddChild(node);
	return node;
end
function AvatarQueue_Test.MountOn()
	AvatarQueue_Test.avatar_queue:MountOn(AvatarQueue_Test.node)
end
function AvatarQueue_Test.MountOff()
	AvatarQueue_Test.avatar_queue:MountOff();
end
function AvatarQueue_Test.DeleteChild()
	AvatarQueue_Test.avatar_queue:RemoveChild(AvatarQueue_Test.node);
	AvatarQueue_Test.node = nil;
end
function AvatarQueue_Test.DeleteAll()
	AvatarQueue_Test.avatar_queue:ClearAllChildren();
	AvatarQueue_Test.avatar_queue:Stop();
end
function AvatarQueue_Test.ReAlign()
	AvatarQueue_Test.avatar_queue:ReAlign();
end
function AvatarQueue_Test.AddChild_Test()
	AvatarQueue_Test.AddChild_2()
	AvatarQueue_Test.ReAlign()
end