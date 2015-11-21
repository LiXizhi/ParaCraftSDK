--[[
Title: Scale Manipulator
Author(s): LiXizhi@yeah.net
Date: 2015/8/25
Desc: This is an example of writing custom manipulators that support manipulator to dependent node conversion. 
To write a custom manipulator, one needs to implement at least two virtual functions from ManipContainer
	createChildren()
	connectToDependNode()

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/ScaleManipContainer.lua");
local ScaleManipContainer = commonlib.gettable("System.Scene.Manipulators.ScaleManipContainer");
	
function XXXSceneContext:UpdateManipulators()
	self:DeleteManipulators();
	local manipCont = ScaleManipContainer:new():init();
	self:AddManipulator(manipCont);
	manipCont:connectToDependNode(self:GetSelectedObject());
end
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/ManipContainer.lua");
local ScaleManipContainer = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.ManipContainer"), commonlib.gettable("System.Scene.Manipulators.ScaleManipContainer"));
ScaleManipContainer:Property({"Name", "ScaleManipContainer", auto=true});

-- attribute name for position on the depedent node that we will bound to. it should be vector3d type like {0,0,0}
ScaleManipContainer:Property({"PositionPlugName", "position", auto=true});
-- attribute name for scaling, float type or vector3d. 
ScaleManipContainer:Property({"ScalingPlugName", "scaling", auto=true});

function ScaleManipContainer:ctor()
end

function ScaleManipContainer:createChildren()
	self.scaleManip = self:AddScaleManip();
end

function ScaleManipContainer:connectToDependNode(node)
	local plugPos = node:findPlug(self.PositionPlugName);
	local plugScale = node:findPlug(self.ScalingPlugName);
	
	if(plugPos and plugScale) then
		local manipPosPlug = self.scaleManip:findPlug("position");
		local manipScalePlug = self.scaleManip:findPlug("scaling");
		local scaling = plugScale:GetValue() or 1;
		if(type(scaling) == "number") then
			self.uniform_scaling = true;
		elseif(type(scaling) == "table" and #scaling == 3) then
			self.uniform_scaling = false;
		end
		self.scaleManip:SetUniformScaling(self.uniform_scaling == true);
		
		if(node.BeginModify and node.EndModify) then
			self.scaleManip:Connect("modifyBegun",  node, node.BeginModify);
			self.scaleManip:Connect("modifyEnded",  node, node.EndModify);
		end
		-- for static position conversion:
		self:connectPlugToManip(plugPos, manipPosPlug, "PlugToManip");
		
		-- for scaling conversion:
		self:addManipToPlugConversionCallback(plugScale, function(self, plug)
			local scaling = manipScalePlug:GetValue();
			if(self.uniform_scaling) then
				scaling = scaling[1] or 1;
				return scaling;
			else
				return scaling;
			end
		end);

		self:addPlugToManipConversionCallback(manipScalePlug, function(self, manipPlug)
			local scaling = plugScale:GetValue() or 1;
			if(type(scaling) == "number") then
				scaling = {scaling, scaling, scaling};
			end
			return scaling;
		end);

	end
	-- should be called only once after all conversion callbacks to setup real connections
	self:finishAddingManips();
	ScaleManipContainer._super.connectToDependNode(self, node);
end