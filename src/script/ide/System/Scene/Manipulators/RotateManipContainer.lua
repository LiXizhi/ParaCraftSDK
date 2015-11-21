--[[
Title: Rotate Manipulator
Author(s): LiXizhi@yeah.net
Date: 2015/8/25
Desc: This is an example of writing custom manipulators that support manipulator to dependent node conversion. 
To write a custom manipulator, one needs to implement at least two virtual functions from ManipContainer
	createChildren()
	connectToDependNode()

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/RotateManipContainer.lua");
local RotateManipContainer = commonlib.gettable("System.Scene.Manipulators.RotateManipContainer");
	
function XXXSceneContext:UpdateManipulators()
	self:DeleteManipulators();
	local manipCont = RotateManipContainer:new():init();
	self:AddManipulator(manipCont);
	manipCont:connectToDependNode(self:GetSelectedObject());
end
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/ManipContainer.lua");
local RotateManipContainer = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.ManipContainer"), commonlib.gettable("System.Scene.Manipulators.RotateManipContainer"));
RotateManipContainer:Property({"Name", "RotateManipContainer", auto=true});

-- attribute name for position on the depedent node that we will bound to. it should be vector3d type like {0,0,0}
RotateManipContainer:Property({"PositionPlugName", "position", auto=true});
-- attribute name for yaw, float type 
RotateManipContainer:Property({"YawPlugName", "yaw", auto=true});
RotateManipContainer:Property({"YawInverted", false, "IsYawInverted", "SetYawInverted", auto=true});
-- attribute name for pitch, float type 
RotateManipContainer:Property({"PitchPlugName", "pitch", auto=true});
RotateManipContainer:Property({"PitchInverted", false, "IsPitchInverted", "SetPitchInverted", auto=true});
-- attribute name for roll, float type 
RotateManipContainer:Property({"RollPlugName", "roll", auto=true});
RotateManipContainer:Property({"RollInverted", false, "IsRollInverted", "SetRollInverted", auto=true});
-- whether to show last yaw/pitch/roll angles 
RotateManipContainer:Property({"ShowLastAngles", false, "SetShowLastAngles", "SetShowLastAngles"});

function RotateManipContainer:ctor()
end

function RotateManipContainer:createChildren()
	self.RotateManip = self:AddRotateManip();
end

-- only call this after init();
function RotateManipContainer:SetYawEnabled(bEnabled)
	self.RotateManip:SetYawEnabled(bEnabled);
end

-- only call this after init();
function RotateManipContainer:SetPitchEnabled(bEnabled)
	self.RotateManip:SetPitchEnabled(bEnabled);
end

-- only call this after init();
function RotateManipContainer:SetRollEnabled(bEnabled)
	self.RotateManip:SetRollEnabled(bEnabled);
end

-- only call this after init();
function RotateManipContainer:SetShowLastAngles(bEnabled)
	self.RotateManip:SetShowLastAngles(bEnabled);
end

function RotateManipContainer:connectToDependNode(node)
	local plugPos = node:findPlug(self.PositionPlugName);
	local plugYaw = node:findPlug(self.YawPlugName);
	local plugPitch = node:findPlug(self.PitchPlugName);
	local plugRoll = node:findPlug(self.RollPlugName);
	
	if(plugPos and (plugYaw or plugPitch or plugRoll) ) then
		local manipPosPlug = self.RotateManip:findPlug("position");
		local manipYawPlug = self.RotateManip:findPlug("yaw");
		local manipPitchPlug = self.RotateManip:findPlug("pitch");
		local manipRollPlug = self.RotateManip:findPlug("roll");

		if(node.BeginModify and node.EndModify) then
			self.RotateManip:Connect("modifyBegun",  node, node.BeginModify);
			self.RotateManip:Connect("modifyEnded",  node, node.EndModify);
		end
		-- for one way position conversion:
		self:connectPlugToManip(plugPos, manipPosPlug, "PlugToManip");

		-- for yaw conversion:
		if(plugYaw) then
			self:addManipToPlugConversionCallback(plugYaw, function(self, plug)
				local value = manipYawPlug:GetValue();
				return if_else(self:IsYawInverted(), -value, value);
			end);
		
			self:addPlugToManipConversionCallback(manipYawPlug, function(self, manipPlug)
				local value = plugYaw:GetValue() or 0;
				return if_else(self:IsYawInverted(), -value, value);
			end);
		end

		-- for pitch conversion:
		if(plugPitch) then
			self:addManipToPlugConversionCallback(plugPitch, function(self, plug)
				local value = manipPitchPlug:GetValue();
				return if_else(self:IsPitchInverted(), -value, value);
			end);
		
			self:addPlugToManipConversionCallback(manipPitchPlug, function(self, manipPlug)
				local value = plugPitch:GetValue() or 0;
				return if_else(self:IsPitchInverted(), -value, value);
			end);
		end

		-- for roll conversion:
		if(plugRoll) then
			self:addManipToPlugConversionCallback(plugRoll, function(self, plug)
				local value = manipRollPlug:GetValue();
				return if_else(self:IsRollInverted(), -value, value);
			end);
		
			self:addPlugToManipConversionCallback(manipRollPlug, function(self, manipPlug)
				local value = plugRoll:GetValue() or 0;
				return if_else(self:IsRollInverted(), -value, value);
			end);
		end
	end
	-- should be called only once after all conversion callbacks to setup real connections
	self:finishAddingManips();
	RotateManipContainer._super.connectToDependNode(self, node);
end