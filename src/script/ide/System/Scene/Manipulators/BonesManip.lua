--[[
Title: BonesManip 
Author(s): LiXizhi@yeah.net
Date: 2015/8/31
Desc: BonesManip is manipulator for 3D rotation. 
	Alt key to hide everything while pressed
	ESC key to cancel current selection.
	DIK_3 to toggle to rotation
	DIK_2 to toggle to IK handle, press again to switch to translation. 
	-/+ key to navigate through bone chain. 
	[ and ] key to change manipulator scaling. 
	K key to add new key frame for current selected variable or IK chain. 

Virtual functions:
	mousePressEvent(event)
	mouseMoveEvent
	mouseReleaseEvent
	draw
	connectToDependNode(node);

---++ Automatic Biped Bone System
The following works like the Biped System in 3dsmax:
The biped hierarchy that is used to determine the relationships between the biped parent and child body parts 
is different from the hierarchy presented by the max nodes parent/child relationships. 
The reason for this difference is to make the biped move more naturally when it is being animated. 
For example, the upper arm links inherit their rotation from the center of mass, instead of from the clavicle, 
to which they are connected. This enables you to animate the spine without counter rotating the arms. 

The internal biped body parts might have different parents for both rotation and position. Here is a brief description about the hierarchy. 

Rotation Hierarchy
    The base of the spine, the base of the neck, the upper arms and legs, and the feet inherit their rotation from the center of mass.
    NOT IMPLEMENTED: The clavicle inherits its rotation from the last spine link.
    The other biped body parts inherit their rotation from their parent INode.

Position Hierarchy
    The base of the spine inherits its position from the center of the mass.
    The upper leg link inherits its position from the pelvis.
	NOT IMPLEMENTED: The clavicle inherits its position from the last spine link.
    The other biped body parts inherit their position from the parent INode.


use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/BonesManip.lua");
local BonesManip = commonlib.gettable("System.Scene.Manipulators.BonesManip");
local manip = BonesManip:new():init();
manip:SetPosition(x,y,z);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/Manipulator.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/System/Scene/Animations/Bones/BoneProxy.lua");
NPL.load("(gl)script/ide/System/Scene/Animations/Bones/IKTwoBoneResolver.lua");
local IKTwoBoneResolver = commonlib.gettable("System.Scene.Animations.Bones.IKTwoBoneResolver");
local BoneProxy = commonlib.gettable("System.Scene.Animations.Bones.BoneProxy");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local ATTRIBUTE_FIELDTYPE = commonlib.gettable("System.Core.ATTRIBUTE_FIELDTYPE");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Color = commonlib.gettable("System.Core.Color");
local Plane = commonlib.gettable("mathlib.Plane");
local vector3d = commonlib.gettable("mathlib.vector3d");
local ShapesDrawer = commonlib.gettable("System.Scene.Overlays.ShapesDrawer");
local BonesManip = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.Manipulator"), commonlib.gettable("System.Scene.Manipulators.BonesManip"));

BonesManip:Property({"Name", "BonesManip", auto=true});
BonesManip:Property({"PenWidth", 0.001});
BonesManip:Property({"editColor", "#ff4264"});
BonesManip:Property({"IKHandleColor", "#00ffff"});
BonesManip:Property({"PoleVectorColor", "#ffffff"});
BonesManip:Property({"PivotColor", "#40ff20"});
BonesManip:Property({"PivotRadius", 0.025});
BonesManip:Property({"ShowBoneName", false});
-- whether to update values during dragging
BonesManip:Property({"RealTimeUpdate", true, "IsRealTimeUpdate", "SetRealTimeUpdate", auto=true});
BonesManip:Property({"BoneCount", 0, "GetBoneCount"});
BonesManip:Property({"UIScaling", 1, "GetUIScaling", "SetUIScaling"});
-- each bone has trans, scale, rotate three variables. when bone is changed, varNameChanged is always changed. 
BonesManip:Signal("boneChanged", function(bone_name) end);
-- whether bone variable name is changed
BonesManip:Signal("varNameChanged", function(name) end);
-- called whenever a new key(rot/scale/trans) of a bone is added, instead of modified. 
BonesManip:Signal("keyAdded", function() end);


function BonesManip:ctor()
	self.names = {};
	self:AddValue("position", {0,0,0});
	-- array of bone attribute model
	self:SetZPassOpacity(0.5);
	self.lineColor = "#230042";
	self.selectedColor = "#42FFA3";
	self.hoverColor = "#AAFFCC";
	self.bones = {};
	self:AddValue("SelectedBoneName", nil);
end

function BonesManip:SetUIScaling(scaling)
	if(self.UIScaling~= scaling) then
		self.UIScaling = scaling;
		self:UpdateManipRadius(self.curManip);
	end
end

function BonesManip:GetUIScaling()
	return self.UIScaling or 1;
end

function BonesManip:GetBoneByPickName(pickingName)
	for i, bone in ipairs(self.bones) do
		if(bone.pickName == pickingName) then
			return bone;
		end
	end
end

function BonesManip:GetIKHandleByPickName(pickingName)
	for i, bone in ipairs(self.bones) do
		if(bone.pickIKHandleName == pickingName) then
			return bone;
		end
	end
end

function BonesManip:HasPickingName(pickingName)
	for i, bone in ipairs(self.bones) do
		if(bone.pickIKHandleName == pickingName or bone.pickName == pickingName) then
			return true;
		end
	end
end

function BonesManip:GetBoneByName(name)
	if(name) then
		for i, bone in ipairs(self.bones) do
			if(bone:GetName() == name) then
				return bone;
			end
		end
	end
end

-- get selected IK handle bone if any. 
-- if this one returns a bone, it means that the user has selected the IK handle on the selected bone. 
function BonesManip:GetIKHandleBone()
	return self.boneIKHandle;
end

-- select bones or IK handles by picking name, all affected child bones are selected. 
function BonesManip:SelectBonesByPickName(pickName)
	local selected_bone = self:GetBoneByPickName(pickName)
	local handleMode;
	if(selected_bone) then
		handleMode = selected_bone:GetPreferredHandleMode();

		for i, bone in ipairs(self.bones) do
			bone:SetSelected(selected_bone:IsAncestorOf(bone));
		end
		-- Bones with IK handle such as hand/foot are automatically selected when clicked 
		if(not handleMode and selected_bone:HasIKHandle()) then
			handleMode = "IK";
		end
	else
		selected_bone = self:GetIKHandleByPickName(pickName)
		if(selected_bone) then
			for i, bone in ipairs(self.bones) do
				bone:SetSelected(false);
			end
			selected_bone:SelectTwoBoneIKChain();
			handleMode = "IK";
		end
	end
	if(selected_bone) then
		self:SetField("SelectedBoneName", selected_bone:GetName());
		self:SetSelectedBone(selected_bone, handleMode)
	end
end

-- @return handleMode:  if "IK", the IK bone is selected, in which case we should use the IK bone manipulator. 
-- if "trans", bone local translation mode is used, such as for lips and pelvis. 
-- if nil, it means a standard bone is selected, and we use the Rotate manipulator
function BonesManip:GetHandleMode()
	return self.handleMode;
end

-- select bone and show default manipulator accordingly. 
-- @param handleMode:  if "IK", the IK bone is selected, in which case we should use the IK bone manipulator. 
-- if "trans", bone local translation mode is used, such as for lips and pelvis. 
-- if "scale", bone local scaling mode is used, such as for lips and pelvis. 
-- if nil, it means a standard bone is selected, and we use the Rotate manipulator
function BonesManip:SetSelectedBone(bone, handleMode)
	if( self.selectedBone ~= bone or (handleMode~=self.handleMode) ) then
		self.handleMode = handleMode;
		self.selectedBone = bone;
		if(handleMode == "IK" and bone) then
			self.boneIKHandle = bone;
		else
			self.boneIKHandle = nil;
		end
		if(self.selectedBone) then
			if(handleMode == "IK") then
				-- show IK handle manip
				self:ShowIKManipForBone(self.selectedBone);
			elseif(handleMode == "trans") then
				-- show trans handle manip
				self:ShowTransManipForBone(self.selectedBone);
			elseif(handleMode == "scale") then
				-- show scale handle manip
				self:ShowScaleManipForBone(self.selectedBone);
			else
				self:ShowRotateManipForBone(self.selectedBone);
			end
			self.selectedBone:SetPreferredHandleMode(handleMode);
		else
			self:deleteChildren();
			self.curManip = nil;
		end
	end
end

function BonesManip:UpdateManipRadius(manip)
	local radius = 0.5;
	if(manip and manip:GetName() == "RotateManip") then
		radius = 0.6;
	end
	if(manip) then
		manip.radius = radius * self:GetUIScaling();
	end
end

-- show trans manip 
function BonesManip:ShowTransManipForBone(bone)
	if(bone) then
		self:deleteChildren();
		NPL.load("(gl)script/ide/System/Scene/Manipulators/TranslateManip.lua");
		local TranslateManip = commonlib.gettable("System.Scene.Manipulators.TranslateManip");
		self.curManip = TranslateManip:new():init(self);
		self:UpdateManipRadius(self.curManip);
		self.curManip.PenWidth = 0.01;
		self.curManip:SetUpdatePosition(false);
		self.curManip:Connect("valueChanged", self, self.OnBoneTransHandlePosChanged)
		self.curManip:Connect("modifyBegun", self, self.BeginModify)
		self.curManip:Connect("modifyEnded", self, self.EndModify)
		self:varNameChanged(bone:GetTransName());
	end
end

-- show scaling manip 
function BonesManip:ShowScaleManipForBone(bone)
	if(bone) then
		self:deleteChildren();
		NPL.load("(gl)script/ide/System/Scene/Manipulators/ScaleManip.lua");
		local ScaleManip = commonlib.gettable("System.Scene.Manipulators.ScaleManip");
		self.curManip = ScaleManip:new():init(self);
		self:UpdateManipRadius(self.curManip);
		self.curManip.PenWidth = 0.01;
		self.curManip:Connect("valueChanged", self, self.OnBoneScaleHandlePosChanged)
		self.curManip:Connect("modifyBegun", self, self.BeginModify)
		self.curManip:Connect("modifyEnded", self, self.EndModify)
		self:varNameChanged(bone:GetScaleName());
	end
end

-- show IK manip 
function BonesManip:ShowIKManipForBone(bone)
	if(bone) then
		self:deleteChildren();
		NPL.load("(gl)script/ide/System/Scene/Manipulators/TranslateManip.lua");
		local TranslateManip = commonlib.gettable("System.Scene.Manipulators.TranslateManip");
		self.curManip = TranslateManip:new():init(self);
		self:UpdateManipRadius(self.curManip);
		self.curManip.PenWidth = 0.01;
		self.curManip.xColor = self.IKHandleColor;
		self.curManip.yColor = self.IKHandleColor;
		self.curManip.zColor = self.IKHandleColor;
		self.curManip:SetUpdatePosition(false);
		self.curManip:Connect("valueChanged", self, self.OnBoneIKHandlePosChanged)
		self.curManip:Connect("modifyBegun", self, self.BeginModify)
		self.curManip:Connect("modifyEnded", self, self.EndModify)
		self:varNameChanged(bone:GetIKHandleName());
	end
end

-- show rotate manip 
function BonesManip:ShowRotateManipForBone(bone)
	if(bone) then
		self:deleteChildren();
		NPL.load("(gl)script/ide/System/Scene/Manipulators/RotateManip.lua");
		local RotateManip = commonlib.gettable("System.Scene.Manipulators.RotateManip");
		self.curManip = RotateManip:new():init(self);
		self:UpdateManipRadius(self.curManip);
		self.curManip:Connect("valueChanged", self, self.OnChangeBoneRotation)
		self.curManip:Connect("modifyBegun", self, self.BeginModify)
		self.curManip:Connect("modifyEnded", self, self.EndModify)
		self:varNameChanged(bone:GetRotName());
	end
end

function BonesManip:OnBoneTransHandlePosChanged()
	if(self.selectedBone) then
		local lineScaling = self:GetLineScale();
		local bone = self.selectedBone;
		local newTrans = bone:GetLastTranslation() + vector3d:new(self.curManip:GetField("position"))*lineScaling;
		self:SetNewBoneTranslation(bone, newTrans);
		self:SetModified();
	end
end

function BonesManip:OnBoneScaleHandlePosChanged()
	if(self.selectedBone) then
		local bone = self.selectedBone;
		local newScale = bone:GetLastScaling():MulVector(vector3d:new(self.curManip:GetField("scaling")));
		self:SetNewBoneScaling(bone, newScale);
		self:SetModified();
	end
end

function BonesManip:OnBoneIKHandlePosChanged()
	if(self.selectedBone) then
		if(self.selectedBone:HasIKHandle()) then
			-- using two bone IK resolver
			local lineScaling = self:GetLineScale();
			local endBone = self.selectedBone:GetIKEffectorBone();
			local offset_pos = vector3d:new(self.curManip:GetField("position"));
			local midBone = self.selectedBone:GetIKMidBone();
			if(midBone and offset_pos:length()>=0.000001) then
				local startBone = self.selectedBone:GetIKStartBone();
				if(startBone) then
					local startJointPos = startBone:GetPivot();
					local midJointPos = midBone:GetLastPivot();
					local effectorPos = endBone:GetLastPivot(); 
					local handlePos = endBone:GetLastPivot() + offset_pos*lineScaling;
					-- local poleVector = vector3d:new(1,0,0);
					local poleVector = endBone:GetLastPoleVector();
					local twistValue = 0;
				
					local qStart, qMid = IKTwoBoneResolver:solveTwoBoneIK(startJointPos, midJointPos, effectorPos, handlePos, poleVector, twistValue);
					--echo({"1111",
						--qStart:tostringAngleAxis(),
						--qMid:tostringAngleAxis(),
						--"$",
						--startJointPos:tostring(),
						--midJointPos:tostring(),
						--effectorPos:tostring(),
						--"$",
						--handlePos:tostring(),
					--})

					qStart:TransformAxisByMatrix(startBone:GetLastPivotRotMatrix():inverse());
					qMid:TransformAxisByMatrix(midBone:GetLastPivotRotMatrix():inverse());

					--echo({"2222",
						--qStart:tostringAngleAxis(),
						--qMid:tostringAngleAxis(),
						--startBone:GetLastRotation():tostringAngleAxis(),
						--midBone:GetLastRotation():tostringAngleAxis(),
						--poleVector:tostring(),
					--})

					self:SetNewBoneRotation(startBone, startBone:GetLastRotation() * qStart);
					self:SetNewBoneRotation(midBone, midBone:GetLastRotation() * qMid);
					self:UpdateChildBoneTransforms(midBone);
					self:SetModified();
				end
			end
		else
			-- if not IK handle, we will simply apply one bone IK resolver, which just convert translation to rotation. 
			local lineScaling = self:GetLineScale();
			local endBone = self.selectedBone:GetIKEffectorBone();
			local offset_pos = vector3d:new(self.curManip:GetField("position"));
			local startBone = endBone:GetParent();
			if(startBone and offset_pos:length()>=0.000001) then
				local startJointPos = startBone:GetPivot();
				local effectorPos = endBone:GetLastPivot(); 
				local handlePos = endBone:GetLastPivot() + offset_pos*lineScaling;
				local qStart = IKTwoBoneResolver:solveOneBoneIK(startJointPos, effectorPos, handlePos);
				qStart:TransformAxisByMatrix(startBone:GetLastPivotRotMatrix():inverse());
				self:SetNewBoneRotation(startBone, startBone:GetLastRotation() * qStart);
				self:UpdateChildBoneTransforms(startBone);
				self:SetModified();
			end
		end
	end
end

function BonesManip:RecalculateAnimInstance()
	if(self.animInstance) then
		self.animInstance:CallField("UpdateModel");
	end
end

function BonesManip:OnChangeBoneRotation()
	if(self.selectedBone) then
		local deltaRot = self.curManip:GetRotation();
		local newRot = self.selectedBone:GetLastRotation() * deltaRot;
		self:SetNewBoneRotation(self.selectedBone, newRot)
		self:UpdateChildBoneTransforms(self.selectedBone);
		self:SetModified();
	end
end

function BonesManip:SetHasNewKeyAdded()
	self.hasNewKeyAdded = true;
end

function BonesManip:SetModified()
	BonesManip._super.SetModified(self);
	if(self.hasNewKeyAdded) then
		self.hasNewKeyAdded = false;
		self:keyAdded();
	end
end

-- force making a new key at the current pos. 
function BonesManip:AddKeyWithCurrentValue()
	local bone = self.selectedBone;
	if(bone) then
		local handleMode = self:GetHandleMode();
		if(handleMode == "scale") then
			self:SetNewBoneScaling(bone, bone:GetScaling());
		elseif(handleMode == "trans") then
			self:SetNewBoneTranslation(bone, bone:GetTranslation());
		elseif(handleMode == "IK") then
			if(bone:HasIKHandle()) then
				local startBone = bone:GetIKStartBone();
				local midBone = bone:GetIKMidBone();
				if(startBone and midBone) then
					self:SetNewBoneRotation(startBone, startBone:GetRotation());
					self:SetNewBoneRotation(midBone, midBone:GetRotation());
				end
			else
				local parent = bone:GetParent();
				if(parent) then
					self:SetNewBoneRotation(parent, parent:GetRotation());
				end
			end
		else
			self:SetNewBoneRotation(bone, bone:GetRotation());
		end
		self:SetModified();
	end
end

-- @param bUpdateChild: if true, we will update child rotation
function BonesManip:SetNewBoneRotation(bone, newRot)
	if(self.animInstance and bone) then
		local field_name = bone:GetRotName();
		self.animInstance:AddDynamicField(field_name, ATTRIBUTE_FIELDTYPE.FieldType_AnimatedQuaternion);
		if(self.animInstance:SetDynamicField(field_name, newRot) == 1) then
			self:SetHasNewKeyAdded();
		end
	end
end

-- just in case some child bone's transform does not change with parent
-- for example: The base of the spine, the base of the neck, the upper arms and legs, and the feet inherit their rotation from the center of mass.
-- The upper leg link inherits its position from the pelvis.
-- @return true if any child is modified
function BonesManip:UpdateChildBoneTransforms(curBone)
	if(not curBone) then
		return;
	end
	local bModified;
	local bAnyChildBoneModified;
	-- for rotations whose parent is center of mass (local mesh)
	for _, bone in ipairs(self.bones) do
		if(bone:GetRotationParentName() == "mass" and curBone:GetMassBoneCountToChild(bone)==1 and bone~=curBone) then
			self:SetNewBoneRotation(bone, bone:GetLastRotation());
			bAnyChildBoneModified = true;
		end
	end
	if(bAnyChildBoneModified) then
		self:RecalculateAnimInstance();
		-- update child bone rotations whose parent is center of mass. 
		for _, bone in ipairs(self.bones) do
			if(bone:GetRotationParentName() == "mass" and curBone:GetMassBoneCountToChild(bone)==1 and bone~=curBone) then
				local vector = vector3d:new({0,1,0});
				local quatDelta = Quaternion:new():FromVectorToVector(vector*bone:GetPivotRotMatrix(), vector*bone:GetLastPivotRotMatrix());
				local newRot = bone:GetLastRotation() * quatDelta;
				self:SetNewBoneRotation(bone, newRot);
			end
		end
	end
	bModified = bModified or bAnyChildBoneModified;
	bAnyChildBoneModified = false;

	-- update child bone position whose parent is "Pelvis". 
	for _, bone in ipairs(self.bones) do
		if(bone:GetPositionParentName() == "Pelvis" and curBone:IsAncestorOf(bone) and bone~=curBone) then
			self:SetNewBoneTranslation(bone, bone:GetLastTranslation());
			bAnyChildBoneModified = true;
		end
	end
	if(bAnyChildBoneModified) then
		self:RecalculateAnimInstance();
		for _, bone in ipairs(self.bones) do
			if(bone:GetPositionParentName() == "Pelvis" and curBone:IsAncestorOf(bone) and bone~=curBone) then
				local lastPivot = bone:GetLastPivot();
				local pivot = bone:GetPivot(true);
				local newTrans;
				if(bone:GetParent()) then
					newTrans = bone:GetLastTranslation() + (lastPivot - pivot) * bone:GetParent():GetPivotRotMatrix():inverse();
				else
					newTrans = bone:GetLastTranslation() + (lastPivot - pivot);
				end
				self:SetNewBoneTranslation(bone, newTrans);
			end
		end
	end

	bModified = bModified or bAnyChildBoneModified;
	return bModified;
end

function BonesManip:SetNewBoneTranslation(bone, newTrans)
	if(self.animInstance and bone) then
		local field_name = bone:GetTransName();
		self.animInstance:AddDynamicField(field_name, ATTRIBUTE_FIELDTYPE.FieldType_AnimatedVector3);
		if(self.animInstance:SetDynamicField(field_name, newTrans) == 1) then
			self:SetHasNewKeyAdded();
		end
	end
end

function BonesManip:SetNewBoneScaling(bone, newScale)
	if(self.animInstance and bone) then
		local field_name = bone:GetScaleName();
		self.animInstance:AddDynamicField(field_name, ATTRIBUTE_FIELDTYPE.FieldType_AnimatedVector3);
		if(self.animInstance:SetDynamicField(field_name, newScale) == 1) then
			self:SetHasNewKeyAdded();
		end
	end
end

function BonesManip:UnselectAll()
	for i, bone in ipairs(self.bones) do
		bone:SetSelected(false);
	end
	self:SetSelectedBone(nil, nil);
	self:SetField("SelectedBoneName", nil);
end


function BonesManip:OnValueChange(name, value)
	BonesManip._super.OnValueChange(self);
	if(name == "position") then
		self:SetPosition(unpack(value));
	elseif(name == "SelectedBoneName") then
		local selected_bone = self:GetBoneByName(value)
		if(selected_bone) then
			local name = selected_bone:GetName();
			self:boneChanged(name);
			self:varNameChanged(name);
		else
			self:boneChanged(nil);
			self:varNameChanged(nil);
		end
	end
end

function BonesManip:init(parent)
	BonesManip._super.init(self, parent);
	return self;
end


function BonesManip:RefreshManipulator()
	local boneName = self:GetField("SelectedBoneName", nil);
	
	if(not self.curManip and boneName) then
		local selected_bone = self:GetBoneByName(boneName);
		if(selected_bone) then
			local handleMode = selected_bone:GetPreferredHandleMode();

			for i, bone in ipairs(self.bones) do
				bone:SetSelected(selected_bone:IsAncestorOf(bone));
			end
			-- Bones with IK handle such as hand/foot are automatically selected when clicked 
			if(not handleMode and selected_bone:HasIKHandle()) then
				handleMode = "IK";
			end
			self:SetSelectedBone(selected_bone, handleMode);
		else
			self:SetFieldInternal("SelectedBoneName", nil);
		end
	end
end

-- this is the biped object from which to show the bones.
-- @param obj: this is usually the CBipedObject in C++
function BonesManip:ShowForObject(obj)
	self.obj = obj;
	self.obj_attr = obj:GetAttributeObject();
	local bones = {};
	local animInstance = self.obj_attr:GetChildAt(1,1);
	if(animInstance and animInstance:IsValid()) then
		self.animInstance = animInstance;
		local bone_count = animInstance:GetChildCount(1);
		for i = 0, bone_count do
			bones[#bones+1] = BoneProxy:new():init(animInstance:GetChildAt(i, 1), bones);
		end
	end
	self.bones = bones;
end

function BonesManip:GetBoneCount()
	return #(self.bones);
end

-- virtual: 
function BonesManip:mousePressEvent(event)
	if(event:button() ~= "left") then
		return
	end
	if(event:isAccepted()) then
		self.isChildActive = true;
		if(self.selectedBone) then
			if(self.curManip:GetName() == "RotateManip") then
				self.curManip:SetYawPitchRoll(0,0,0);
				-- save all child rotation.
				self.selectedBone:SaveLastRotationAndChildren();
				self.selectedBone:SaveLastPivotRotMatrixAndChildren();
				self.selectedBone:SaveLastPivotAndChildren();
				self.selectedBone:SaveLastTranslationAndChildren();
			elseif(self.curManip:GetName() == "TranslateManip") then
				self.curManip:SetField("position", {0,0,0});
				-- save last values for two bone IK chains
				self.selectedBone:SaveLastValuesForIKChain(2);
				-- save last translation
				self.selectedBone:SaveLastTranslation();
			elseif(self.curManip:GetName() == "ScaleManip") then
				self.curManip:SetField("scaling", {1,1,1});
				-- save last scaling
				self.selectedBone:SaveLastScaling();
			end
		end
		return
	end
	event:accept();
end

-- virtual: 
function BonesManip:mouseMoveEvent(event)
end

-- virtual: 
function BonesManip:mouseReleaseEvent(event)
	if(event:button() ~= "left") then
		return
	end
	if(event:isAccepted()) then
		self.isChildActive = false;
		if(self.curManip:GetName() == "RotateManip") then
			self.curManip:SetYawPitchRoll(0,0,0);
		elseif(self.curManip:GetName() == "TranslateManip") then
			self.curManip:SetFieldInternal("position", {0,0,0});
		elseif(self.curManip:GetName() == "ScaleManip") then
			self.curManip:SetFieldInternal("scaling", {1,1,1});
		end
		return
	end
	event:accept();

	local name = self:GetActivePickingName();
	self:SelectBonesByPickName(name);
end

function BonesManip:GrabValues()
end

-- virtual: actually means key stroke. 
function BonesManip:keyPressEvent(event)
	local keyname = event.keyname;
	if(self.selectedBone) then
		if(keyname == "DIK_ESCAPE") then
			-- cancel selection on esc key
			event:accept();
			self:UnselectAll();
		elseif(keyname == "DIK_2") then
			-- toggle to IK bone translation, press 2 again to toggle to translation mode. 
			if(self.selectedBone:CanHasIKHandle()) then
				if(self:GetHandleMode() == "IK") then
					self:SetSelectedBone(self.selectedBone, "trans");
				else
					self:SetSelectedBone(self.selectedBone, "IK");
				end
			else
				self:SetSelectedBone(self.selectedBone, "trans");
			end
			event:accept();
		elseif(keyname == "DIK_3") then
			-- toggle to standard bone rotation
			self:SetSelectedBone(self.selectedBone, nil);
			event:accept();
		elseif(keyname == "DIK_4") then
			-- toggle to standard bone scaling
			self:SetSelectedBone(self.selectedBone, "scale");
			event:accept();
		elseif(keyname == "DIK_ADD" or keyname == "DIK_EQUALS") then
			-- select first child bone
			local childBone = self.selectedBone:GetChildAt(1);
			if(childBone) then
				self:SelectBonesByPickName(childBone.pickName);
			end
			event:accept();
		elseif(keyname == "DIK_SUBTRACT" or keyname == "DIK_MINUS") then
			-- select parent bone
			local parentBone = self.selectedBone:GetParent();
			if(parentBone) then
				self:SelectBonesByPickName(parentBone.pickName);
			end
			event:accept();
		elseif(keyname == "DIK_K") then
			-- force making a new key at the current pos. 
			self:AddKeyWithCurrentValue()
			event:accept();
		end
	end
	if(keyname == "DIK_LBRACKET" or keyname == "DIK_RBRACKET") then
		-- [ and ] key to change manipulator scaling. 
		local scaling = 2;
		if(keyname == "DIK_LBRACKET") then
			scaling = 0.5;
		end
		local scaling = (self:GetUIScaling() * scaling);
		if(scaling < 1) then
			scaling = 1;
		end
		self:SetUIScaling(scaling);
		event:accept();
	end
end

-- this ensures that model instance's final matrix is calculated and up to date. 
-- TODO: refactor this to make this automatic update
function BonesManip:UpdateModel()
	if(self.animInstance) then
		self.animInstance:CallField("UpdateModel");
		for i, bone in ipairs(self.bones) do
			bone:Update();
		end
		-- following may not need to be called every frame. 
		local trans = self.obj_attr:GetField("LocalTransform", self.localTransform);
		self:SetLocalTransform(trans);

		-- update selected bone manipulators. 
		if(self.selectedBone and self.curManip) then
			if(not self.curManip:IsDragging()) then
				local trans = self.curManip:GetLocalTransform();
				local lineScale = self:GetLineScale();
				trans:identity();
				trans:setScale(lineScale, lineScale, lineScale);
				trans:setTrans(unpack(self.selectedBone:GetPivot()));
				local name = self.curManip:GetName();
				if(name == "RotateManip" or name=="ScaleManip") then
					-- use current bone's coordinate system to rotate current bone
					local matRot = self.selectedBone:GetPivotRotMatrix();
					local localTrans = matRot*trans;
					self.curManip:SetLocalTransform(localTrans);
				elseif(self.handleMode=="trans" and name=="TranslateManip") then
					local parentBone = self.selectedBone:GetParent();
					if(parentBone) then
						-- use parent bone's coordinate system to translate current bone. 
						-- since translation is always relative to parent or pivot. 
						local matRot = parentBone:GetPivotRotMatrix();
						local localTrans = matRot*trans;
						self.curManip:SetLocalTransform(localTrans);
					else
						-- if no parent, use global world coordinate system 
						self.curManip:SetLocalTransform(trans);
					end
				else
					-- use global world coordinate system for "IK" handle and other manipulators
					self.curManip:SetLocalTransform(trans);
				end
			end
		end
	end
end

function BonesManip:paintEvent(painter)
	local UIScaling = self:GetUIScaling();
	local lineScale = self:GetLineScale(painter) * UIScaling;
	self.pen.width = self.PenWidth * lineScale;
	painter:SetPen(self.pen);
	local bone_radius = math.max(self.PenWidth*5, self.PivotRadius) * lineScale;
	local isDrawingPickable = self:IsPickingPass();

	if(Keyboard:IsAltKeyPressed()) then
		-- hide everything when alt key is pressed. 
		return;
	end

	self:UpdateModel();
	local name = self:GetActivePickingName();
	if(self.isChildActive) then
		name = -1;
	end
	local bones = self.bones;
	for i, bone in ipairs(bones) do
		local pickName, pickIKHandleName;
		if(isDrawingPickable) then
			pickName = self:GetNextPickingName();
			pickIKHandleName = self:GetNextPickingName();
		end
		
		if(name == bone.pickName) then
			-- hover over
			self:SetColorAndName(painter, self.hoverColor, pickName);
		elseif(bone:IsSelected() and not self:GetIKHandleBone()) then
			-- mouse 
			self:SetColorAndName(painter, self.selectedColor, pickName);
		else
			self:SetColorAndName(painter, self.lineColor, pickName);
		end
		
		local pivot = bone:GetPivot();
		-- draw connections from this to all child bones
		local pickWithParent = false; -- picking with parent or children
		if(pickWithParent) then
			local parentBone = bone:GetParent();
			if(parentBone) then
				local parentPivot = parentBone:GetPivot();
				ShapesDrawer.DrawLine(painter, pivot[1],pivot[2],pivot[3], parentPivot[1],parentPivot[2],parentPivot[3]);
			end
		else
			for i, childBone in ipairs(bones) do
				if(childBone:GetParent() == bone) then
					local childPivot = childBone:GetPivot();	
					ShapesDrawer.DrawLine(painter, pivot[1],pivot[2],pivot[3], childPivot[1],childPivot[2],childPivot[3]);
				end
			end
		end

		-- draw this bone and IK handle if any
		painter:PushMatrix();
		painter:TranslateMatrix(pivot[1],pivot[2],pivot[3]);
		if(self.selectedBone == bone or bone:HasIKHandle()) then
			if(bone:CanHasIKHandle() and not (self:GetIKHandleBone() == bone and isDrawingPickable)) then
				if(self:GetIKHandleBone() == bone) then
					self:SetColorAndName(painter, self.editColor, pickIKHandleName);
				elseif(name == bone.pickIKHandleName) then
					self:SetColorAndName(painter, self.hoverColor, pickIKHandleName);
				else
					self:SetColorAndName(painter, self.IKHandleColor, pickIKHandleName);
				end
				-- draw IK handle
				local length = 0.2;
				ShapesDrawer.DrawLine(painter, 0,0,0, length,0,0);
				ShapesDrawer.DrawLine(painter, 0,0,0, 0,length,0);
				ShapesDrawer.DrawLine(painter, 0,0,0, 0,0,length);
			end
			if(self:GetIKHandleBone() == bone) then
				if(name == bone.pickName) then
					-- hover over
					self:SetColorAndName(painter, self.hoverColor, pickName);
				else
					self:SetColorAndName(painter, self.selectedColor, pickName);
				end
			else
				if(bone:HasIKHandle()) then
					self:SetColorAndName(painter, self.IKHandleColor, pickName);
				else
					self:SetColorAndName(painter, self.editColor, pickName);
				end
			end
		else
			self:SetColorAndName(painter, self.PivotColor, pickName);
		end
		-- draw this bone
		ShapesDrawer.DrawCircle(painter, 0,0,0, bone_radius, "x", false);
		ShapesDrawer.DrawCircle(painter, 0,0,0, bone_radius, "y", false);
		ShapesDrawer.DrawCircle(painter, 0,0,0, bone_radius, "z", false);
		painter:PopMatrix();
		 
		if(not isDrawingPickable and 
			(((self.ShowBoneName) and (name == bone.pickName or self.selectedBone == bone))
				or (not self.selectedBone and name == bone.pickName))) then
			-- display bone text for mouse hover bone
			painter:PushMatrix();
			painter:TranslateMatrix(pivot[1]+0.1,pivot[2]+0.3*lineScale,pivot[3]);
			painter:LoadBillboardMatrix();
			painter:DrawTextScaled(0, 0, bone:GetDisplayName(), self.textScale*lineScale);
			painter:PopMatrix();
		end
		if(isDrawingPickable) then
			bone.pickName = pickName;
			bone.pickIKHandleName = pickIKHandleName;
		end
	end

	if(self.selectedBone and self.selectedBone:HasIKHandle() and self:GetIKHandleBone() == self.selectedBone and not isDrawingPickable) then
		-- draw the IK chain and pole vector for two bone IK
		local endBone = self.selectedBone;
		local endPivot = endBone:GetPivot();
		local midBone = endBone:GetParent();
		if(midBone) then
			local midPivot = midBone:GetPivot();
			local startBone = midBone:GetParent();
			if(startBone) then
				local startPivot = startBone:GetPivot();
				self:SetColorAndName(painter, self.IKHandleColor);
				ShapesDrawer.DrawLine(painter, endPivot[1],endPivot[2],endPivot[3], midPivot[1],midPivot[2],midPivot[3]);
				ShapesDrawer.DrawLine(painter, startPivot[1],startPivot[2],startPivot[3], midPivot[1],midPivot[2],midPivot[3]);
				ShapesDrawer.DrawLine(painter, endPivot[1],endPivot[2],endPivot[3], startPivot[1],startPivot[2],startPivot[3]);
				-- draw pole vector
				self:SetColorAndName(painter, self.PoleVectorColor);
				local poleVector = endBone:GetPoleVector()*0.3;
				poleVector:add(startPivot);
				ShapesDrawer.DrawLine(painter, startPivot[1],startPivot[2],startPivot[3], poleVector[1],poleVector[2],poleVector[3]);
			end
		end
	end
end

