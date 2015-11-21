--[[
Title: Bone proxy of C++ bone attribute model 
Author(s): LiXizhi@yeah.net
Date: 2015/9/11
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Animations/Bones/BoneProxy.lua");
local BoneProxy = commonlib.gettable("System.Scene.Animations.Bones.BoneProxy");
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
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Bone = commonlib.inherit(nil, commonlib.gettable("System.Scene.Animations.Bones.BoneProxy"));

function Bone:ctor()
	self.pivot = vector3d:new({0,0,0});
	-- quaternion for bone rotation
	self.rot = Quaternion:new();
	-- translation
	self.trans = vector3d:new({0,0,0});
	-- scaling
	self.scaling = vector3d:new({1,1,1});
	self.parentIndex = -1;
	self.matRot = Matrix4:new():identity();
	self.matPivotRot = Matrix4:new():identity();
end

-- @param attr: the C++ attribute bone model to bind with
function Bone:init(attr, allbones)
	self.attr = attr;	
	self.parentIndex = attr:GetField("ParentIndex", -1);
	self.boneIndex = attr:GetField("BoneIndex", -1);
	self.name = attr:GetField("name", "");
	-- naming convention is internally defined on C++ side
	self.rot_name = attr:GetField("RotName", "");
	self.trans_name = attr:GetField("TransName", "");
	self.scale_name = attr:GetField("ScaleName", "");
	self.display_name = self.name; -- format("%d %s", self.boneIndex, self.name);
	self.bones = allbones;
	return self;
end

-- final rotation
function Bone:GetRotMatrix()
	self.matRot = self.attr:GetField("FinalRotMatrix", self.matRot);
	return self.matRot;
end

function Bone:GetPivotRotMatrix()
	self.matPivotRot = self.attr:GetField("PivotRotMatrix", self.matPivotRot);
	return self.matPivotRot;
end

function Bone:GetName()
	return self.name or "unknown";
end

function Bone:GetRotName()
	return self.rot_name;
end

function Bone:GetScaleName()
	return self.scale_name;
end

function Bone:GetTransName()
	return self.trans_name;
end

function Bone:GetIKHandleName()
	return self:GetName().."_IK";
end

function Bone:GetDisplayName()
	return self.display_name or "unknown";
end

-- get current bone pivot
function Bone:GetPivot(bRefresh)
	if(bRefresh) then
		self.pivot = self.attr:GetField("AnimatedPivotPoint", self.pivot);
	end
	return self.pivot;
end

function Bone:SaveLastPivotRotMatrix()
	self.lastPivotRotMatrix = self:GetPivotRotMatrix():clone();
end
function Bone:SaveLastPivotRotMatrixAndChildren()
	for i, childBone in ipairs(self.bones) do
		if(self:IsAncestorOf(childBone)) then
			childBone:SaveLastPivotRotMatrix();
		end
	end
end

function Bone:GetLastPivotRotMatrix()
	if(not self.lastPivotRotMatrix) then
		self:SaveLastPivotRotMatrix();
	end
	return self.lastPivotRotMatrix;
end

function Bone:SaveLastPivot()
	self.lastPivot = self:GetPivot():clone();
end

function Bone:SaveLastPivotAndChildren()
	for i, childBone in ipairs(self.bones) do
		if(self:IsAncestorOf(childBone)) then
			childBone:SaveLastPivot();
		end
	end
end


function Bone:GetLastPivot()
	if(not self.lastPivot) then
		self:SaveLastPivot();
	end
	return self.lastPivot;
end

function Bone:SaveLastRotation()
	self.lastRotQuat = self:GetRotation():clone();
	self.lastRotMat = self:GetRotMatrix():clone();
end

-- same as SaveLastRotation() and all of its children's rotations. 
function Bone:SaveLastRotationAndChildren()
	for i, childBone in ipairs(self.bones) do
		if(self:IsAncestorOf(childBone)) then
			childBone:SaveLastRotation();
		end
	end
end

function Bone:GetLastRotMatrix()
	if(not self.lastRotMat) then
		self:SaveLastRotation();
	end
	return self.lastRotMat;
end

function Bone:GetLastRotation()
	if(not self.lastRotQuat) then
		self:SaveLastRotation();
	end
	return self.lastRotQuat;
end

-- get current rotation
-- @return the rotation quaternion
function Bone:GetRotation(bRefresh)
	if(bRefresh) then
		self.rot = self.attr:GetField("FinalRot", self.rot);
	end
	return self.rot;
end

function Bone:SaveLastTranslation()
	self.lastTrans = self:GetTranslation():clone();
end

function Bone:GetLastTranslation()
	if(not self.lastTrans) then
		self:SaveLastTranslation();
	end
	return self.lastTrans;
end

function Bone:SaveLastTranslationAndChildren()
	for i, childBone in ipairs(self.bones) do
		if(self:IsAncestorOf(childBone)) then
			childBone:GetLastTranslation();
		end
	end
end

-- get current translation offset
-- @return the rotation quaternion
function Bone:GetTranslation(bRefresh)
	if(bRefresh) then
		self.trans = self.attr:GetField("FinalTrans", self.trans);
	end
	return self.trans;
end

function Bone:SaveLastScaling()
	self.lastScaling = self:GetScaling():clone();
end

function Bone:GetLastScaling()
	if(not self.lastScaling) then
		self:SaveLastScaling();
	end
	return self.lastScaling;
end

-- get current scaling
-- @return the rotation quaternion
function Bone:GetScaling(bRefresh)
	if(bRefresh) then
		self.scaling = self.attr:GetField("FinalScaling", self.scaling);
	end
	return self.scaling;
end

function Bone:GetParent()
	if(self.parentIndex >= 0) then
		return self.bones[self.parentIndex + 1];
	end
end
function Bone:HasParent()
	return (self.parentIndex >= 0);
end

-- update data from C++ model
function Bone:Update()
	self:GetPivot(true);
	self:GetScaling(true);
	self:GetRotation(true);
	self:GetTranslation(true);
end

-- @param nIndex: default to 1
function Bone:GetChildAt(nIndex)
	local curIndex = 0;
	nIndex = nIndex or 1;
	for i, childBone in ipairs(self.bones) do
		if(childBone:GetParent() == self) then
			curIndex = curIndex + 1;
			if(curIndex == nIndex) then
				return childBone;
			end
		end
	end
end

function Bone:GetChildCount()
	local count = 0;
	for i, childBone in ipairs(self.bones) do
		if(childBone:GetParent() == self) then
			count = count + 1;
		end
	end
	return count;
end

-- @param handleMode: 
function Bone:SetPreferredHandleMode(handleMode)
	self.handleMode = handleMode;
end

-- @return handleMode:  if "IK", the IK bone is selected, in which case we should use the IK bone manipulator. 
-- if "trans", bone local translation mode is used, such as for lips and pelvis. 
-- if nil, it means a standard bone is selected, and we use the Rotate manipulator
function Bone:GetPreferredHandleMode()
	return self.handleMode;
end

function Bone:GetDefaultPoleVector()
	if(self.name == "L_Foot" or self.name == "R_Foot" or 
		-- IK with one multi parent bone is considered foot
		(self.name:match("_IK")~=nil and self.name:match("_mp")==nil)) then
		return vector3d:new(1,0,0);
	else -- if(self.name == "L_Hand" or self.name == "R_Hand") then
		return vector3d:new(-1,0,0);
	end
end

-- get pole vector in two bone IK chain, call this on the end bone. 
function Bone:GetPoleVector()
	local endBone = self;
	local endPivot = endBone:GetPivot();
	local midBone = endBone:GetParent();
	if(midBone) then
		local midPivot = midBone:GetPivot();
		local startBone = midBone:GetParent();
		if(startBone) then
			local startPivot = startBone:GetPivot();
			local v1 = midPivot - startPivot;
			local v2 = endPivot - midPivot;
			local vH = endPivot - startPivot;
			if(v1:isParallel(v2)) then
				return self:GetDefaultPoleVector()*self:GetPivotRotMatrix();
			else
				return vH*(v1*v2):normalize();
			end
		end
	end
end

function Bone:GetLastPoleVector()
	local endBone = self;
	local endPivot = endBone:GetLastPivot();
	local midBone = endBone:GetParent();
	if(midBone) then
		local midPivot = midBone:GetLastPivot();
		local startBone = midBone:GetParent();
		if(startBone) then
			local startPivot = startBone:GetLastPivot();
			local v1 = midPivot - startPivot;
			local v2 = endPivot - midPivot;
			local vH = endPivot - startPivot;
			if(v1:isParallel(v2)) then
				return self:GetDefaultPoleVector()*self:GetLastPivotRotMatrix();
			else
				return vH*(v1*v2):normalize();
			end
		end
	end
end

-- save last values for IK chain, usually called before we start IK chain operation. 
-- @param depth: default to 2, which is current, parent, and parent's parent
function Bone:SaveLastValuesForIKChain(depth)
	depth = depth or 2;
	self:SaveLastPivot();
	self:SaveLastPivotRotMatrix();
	self:SaveLastRotation();
	if(depth>0) then
		local parent = self:GetParent();
		if(parent) then
			parent:SaveLastValuesForIKChain(depth-1);
		end
	end
end

-- Returns true if this object is a parent, (or grandparent and so on
-- to any level), of the given child.
function Bone:IsAncestorOf(child)
	while (child) do
        if (child == self) then
            return true;
		elseif(not child:HasParent()) then
			return false;
        end
        child = child:GetParent();
    end
    return false;
end

function Bone:SetSelected(bValue)
	self.isSelected = bValue;
end

function Bone:IsSelected()
	return self.isSelected;
end

-- check if we can use two bone IK handle on this bone node. 
-- all bones with two or more parents can have IK handle
function Bone:CanHasIKHandle()
	local parent = self:GetParent();
	if(parent and parent:GetParent()) then
		return true;
	end
end

-- Rotation Hierarchy
-- The base of the spine, the base of the neck, the upper arms and legs, and the feet inherit their rotation from the center of mass.
local ParentRotationBoneNames = {
	L_Thigh = "mass", R_Thigh="mass", L_UpperArm="mass", R_UpperArm="mass", Head="mass", R_Foot = "mass", L_Foot="mass"
};

-- if nil, it means parent bone, if "mass", it means center of mass. 
function Bone:GetRotationParentName()
	return ParentRotationBoneNames[self.name];
end

-- Position Hierarchy
-- The upper leg link inherits its position from the pelvis.
local ParentPositionBoneNames = {
	L_Thigh = "Pelvis", R_Thigh="Pelvis",
};

-- if nil, it means parent bone, if "mass", it means center of mass. 
function Bone:GetPositionParentName()
	return ParentPositionBoneNames[self.name];
end

-- it will always return 0, if self is not ancestor of child. 
-- @param child: child node of self.
function Bone:GetMassBoneCountToChild(child)
	local count = 0;
	while (child) do
		if(child:GetRotationParentName() == "mass") then
			count = count + 1;
		end
        if (child == self) then
            return count;
		elseif(not child:HasParent()) then
			return 0;
        end
        child = child:GetParent();
    end
    return 0;
end


local Known_IKHandleBones = {L_Hand = true, R_Hand=true, L_Foot=true, R_Foot=true};

-- if the bone is a well known IK handle, such as hand and foot. 
function Bone:HasIKHandle()
	return Known_IKHandleBones[self.name] or self.name:match("_IK")~=nil;
end

-- the start bone in two bone IK chain
function Bone:GetIKStartBone()
	local parent = self:GetParent();
	if(parent) then
		return parent:GetParent();
	end
end

-- the mid bone in two bone IK chain
function Bone:GetIKMidBone()
	return self:GetParent();
end

-- the end bone in two bone IK chain
function Bone:GetIKEffectorBone()
	return self;
end

-- call the IK handle bone (effector or end bone), it will select the parent and parent's parent bone
function Bone:SelectTwoBoneIKChain()
	self:SetSelected(true);
	local parent = self:GetParent();
	if(parent) then
		parent:SetSelected(true);
		parent = parent:GetParent();
		if(parent) then
			parent:SetSelected(true);
			return true;
		end
	end
end