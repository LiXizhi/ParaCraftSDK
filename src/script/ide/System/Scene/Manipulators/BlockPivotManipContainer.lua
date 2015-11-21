--[[
Title: Block Pivot Point Manipulator
Author(s): LiXizhi@yeah.net
Date: 2015/8/24
Desc: This is an example of writing custom manipulators that support manipulator to dependent node conversion. 
To write a custom manipulator, one needs to implement at least two virtual functions from ManipContainer
	createChildren()
	connectToDependNode()

In this example, the node's PivotPoint property is bound to translate manipuator's position property
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/BlockPivotManipContainer.lua");
local BlockPivotManipContainer = commonlib.gettable("System.Scene.Manipulators.BlockPivotManipContainer");
	
function XXXSceneContext:UpdateManipulators()
	self:DeleteManipulators();
	local manipCont = BlockPivotManipContainer:new():init();
	self:AddManipulator(manipCont);
	manipCont:connectToDependNode(self:GetSelectedObject());
end
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/ManipContainer.lua");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine");
local BlockPivotManipContainer = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.ManipContainer"), commonlib.gettable("System.Scene.Manipulators.BlockPivotManipContainer"));
BlockPivotManipContainer:Property({"Name", "BlockPivotManipContainer", auto=true});
BlockPivotManipContainer:Property({"radius", 1,});
BlockPivotManipContainer:Property({"showArrowHead", true});
BlockPivotManipContainer:Property({"PivotPointPlugName", "PivotPoint", auto=true});

function BlockPivotManipContainer:createChildren()
	self.translateManip = self:AddTranslateManip();
	self.translateManip.radius = self.radius;
	self.translateManip.xColor = self.xColor;
	self.translateManip.yColor = self.yColor;
	self.translateManip.zColor = self.zColor;
	self.translateManip.showArrowHead = self.showArrowHead;
	self.translateManip:SetShowGrid(true);
	self.translateManip:SetSnapToGrid(true);
	self.translateManip:SetGridSize(BlockEngine.blocksize);
	self.translateManip:SetGridOffset({BlockEngine.blocksize/2, BlockEngine.blocksize/2, BlockEngine.blocksize/2});
end

function BlockPivotManipContainer:connectToDependNode(node)
	local plug = node:findPlug(self:GetPivotPointPlugName());
	local manipPlug = self.translateManip:findPlug("position");
	self:addManipToPlugConversionCallback(plug, function(self, plug)
		local pos = manipPlug:GetValue();
		local x, y, z = BlockEngine:block(pos[1], pos[2], pos[3]);
		return {x, y, z};
	end);
	self:addPlugToManipConversionCallback(manipPlug, function(self, manipPlug)
		local pos = plug:GetValue();
		local x, y, z = BlockEngine:real(pos[1], pos[2], pos[3]);
		return {x, y, z};
	end);
	-- should be called only once after all conversion callbacks to setup real connections
	self:finishAddingManips();
	BlockPivotManipContainer._super.connectToDependNode(self, node);
end