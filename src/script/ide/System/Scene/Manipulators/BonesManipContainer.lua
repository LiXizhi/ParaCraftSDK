--[[
Title: Bones Manipulator
Author(s): LiXizhi@yeah.net
Date: 2015/8/25
Desc: This is an example of writing custom manipulators that support manipulator to dependent node conversion. 
To write a custom manipulator, one needs to implement at least two virtual functions from ManipContainer
	createChildren()
	connectToDependNode()

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/BonesManipContainer.lua");
local BonesManipContainer = commonlib.gettable("System.Scene.Manipulators.BonesManipContainer");
	
function XXXSceneContext:UpdateManipulators()
	self:DeleteManipulators();
	local manipCont = BonesManipContainer:new():init();
	self:AddManipulator(manipCont);
	manipCont:connectToDependNode(self:GetSelectedObject());
end
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/ManipContainer.lua");
local BonesManipContainer = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.ManipContainer"), commonlib.gettable("System.Scene.Manipulators.BonesManipContainer"));
BonesManipContainer:Property({"Name", "BonesManipContainer", auto=true});

-- attribute name for position on the depedent node that we will bound to. it should be vector3d type like {0,0,0}
BonesManipContainer:Property({"PositionPlugName", "position", auto=true});
BonesManipContainer:Property({"selectLastSelectedBone", true, });

BonesManipContainer:Signal("valueChanged");
BonesManipContainer:Signal("keyAdded");
-- whether bone variable name is changed
BonesManipContainer:Signal("varNameChanged", function(name) end);
BonesManipContainer:Signal("boneChanged", function(name) end);

function BonesManipContainer:ctor()
	self.PenWidth= 0.01;
	self:SetShowPos(true);
end

function BonesManipContainer:createChildren()
	NPL.load("(gl)script/ide/System/Scene/Manipulators/BonesManip.lua");
	local BonesManip = commonlib.gettable("System.Scene.Manipulators.BonesManip");
	self.BonesManip = BonesManip:new():init(self);
	self.BonesManip:Connect("valueChanged",  self, self.valueChanged);
	self.BonesManip:Connect("keyAdded",  self, self.keyAdded);
	self.BonesManip:Connect("varNameChanged",  self, self.varNameChanged);
	self.BonesManip:Connect("boneChanged",  self, self.boneChanged);
end

function BonesManipContainer:connectToDependNode(node)
	local plugPos = node:findPlug(self.PositionPlugName);
	
	if(plugPos ) then
		local manipPosPlug = self.BonesManip:findPlug("position");	
		
		if(node.GetInnerObject) then
			self.BonesManip:ShowForObject(node:GetInnerObject());
		end

		if(node.BeginModify and node.EndModify) then
			self.BonesManip:Connect("modifyBegun",  node, node.BeginModify);
			self.BonesManip:Connect("modifyEnded",  node, node.EndModify);
		end
		if(node.OnChangeBone) then
			self.BonesManip:Connect("boneChanged",  node, node.OnChangeBone);
		end
		if(node.SetModified) then
			self.BonesManip:Connect("valueChanged",  node, node.SetModified);
		end
		if(node.GetBonesVariable) then
			local var = node:GetBonesVariable();
			if(var) then
				self.BonesManip:Connect("valueChanged",  var, var.SaveToActor);	
				
				if(self.selectLastSelectedBone) then
					local name = var:GetSelectedBoneName();
					if(name) then
						self.BonesManip:SetFieldInternal("SelectedBoneName", name);
						self.BonesManip:RefreshManipulator();
					end
				else
					var:SetSelectedBone(nil);
				end
			end
		end

		self:ShowWithObject(node);

		-- for static position conversion:
		self:connectPlugToManip(plugPos, manipPosPlug, "PlugToManip");
	end
	-- should be called only once after all conversion callbacks to setup real connections
	self:finishAddingManips();
	BonesManipContainer._super.connectToDependNode(self, node);
end