--[[
Title: Move Manipulator
Author(s): LiXizhi@yeah.net
Date: 2015/8/25
Desc: This is an example of writing custom manipulators that support manipulator to dependent node conversion. 
To write a custom manipulator, one needs to implement at least two virtual functions from ManipContainer
	createChildren()
	connectToDependNode()

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/MoveManipContainer.lua");
local MoveManipContainer = commonlib.gettable("System.Scene.Manipulators.MoveManipContainer");
	
function XXXSceneContext:UpdateManipulators()
	self:DeleteManipulators();
	local manipCont = MoveManipContainer:new():init();
	self:AddManipulator(manipCont);
	manipCont:connectToDependNode(self:GetSelectedObject());
end
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/ManipContainer.lua");
local MoveManipContainer = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.ManipContainer"), commonlib.gettable("System.Scene.Manipulators.MoveManipContainer"));
MoveManipContainer:Property({"Name", "MoveManipContainer", auto=true});

-- attribute name for position on the dependent node that we will bound to. it should be vector3d type like {0,0,0}
MoveManipContainer:Property({"PositionPlugName", "position", auto=true});

MoveManipContainer:Property({"showGrid", false, "IsShowGrid", "SetShowGrid", auto=true});
MoveManipContainer:Property({"snapToGrid", false, "IsSnapToGrid", "SetSnapToGrid", auto=true});
MoveManipContainer:Property({"gridSize", 0.1, "GetGridSize", "SetGridSize", auto=true});
MoveManipContainer:Property({"gridOffset", {0,0,0}, "GetGridOffset", "SetGridOffset", auto=true});

function MoveManipContainer:ctor()
	self.gridOffset = {0,0,0};
end

function MoveManipContainer:createChildren()
	self.translateManip = self:AddTranslateManip();
	self.translateManip:SetShowGrid(self:IsShowGrid());
	self.translateManip:SetSnapToGrid(self:IsSnapToGrid());
	self.translateManip:SetGridSize(self:GetGridSize());
end

function MoveManipContainer:connectToDependNode(node)
	local plugPos = node:findPlug(self.PositionPlugName);
	
	if(plugPos) then
		local manipPosPlug = self.translateManip:findPlug("position");
		
		if(node.BeginModify and node.EndModify) then
			self.translateManip:Connect("modifyBegun",  node, node.BeginModify);
			self.translateManip:Connect("modifyEnded",  node, node.EndModify);
		end

		self:addManipToPlugConversionCallback(plugPos, function(self, plug)
			return manipPosPlug:GetValue();
		end);

		self:addPlugToManipConversionCallback(manipPosPlug, function(self, manipPlug)
			return plugPos:GetValue();
		end);
	end
	-- should be called only once after all conversion callbacks to setup real connections
	self:finishAddingManips();
	MoveManipContainer._super.connectToDependNode(self, node);
end