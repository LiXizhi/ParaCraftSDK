--[[
Title: 
Author(s): Leio
Date: 2009/8/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/SceneNodeProcessor.lua");
-------------------------------------------------------
]]
local SceneNodeProcessor = {
	canvas = nil,--it is a SceneCanvas instance
}
commonlib.setfield("CommonCtrl.Display3D.SceneNodeProcessor",SceneNodeProcessor);
function SceneNodeProcessor:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function SceneNodeProcessor:Init()
	local uid = ParaGlobal.GenerateUniqueID();
	self.uid = uid;
end
function SceneNodeProcessor:DoMouseDown(event)

end
function SceneNodeProcessor:DoMouseUp(event)

end
function SceneNodeProcessor:DoMouseMove(event)

end
function SceneNodeProcessor:DoMouseOver(event)

end
function SceneNodeProcessor:DoMouseOut(event)

end
function SceneNodeProcessor:DoChildSelected(event)

end
function SceneNodeProcessor:DoChildUnSelected(event)

end
function SceneNodeProcessor:DoMouseDown_Stage(event)

end
function SceneNodeProcessor:DoMouseUp_Stage(event)

end
function SceneNodeProcessor:DoMouseMove_Stage(event)

end