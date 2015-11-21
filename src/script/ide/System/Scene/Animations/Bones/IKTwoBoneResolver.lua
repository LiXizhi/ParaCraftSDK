--[[
Title: BonesManip 
Author(s): LiXizhi@yeah.net
Date: 2015/9/11
Desc: Due to their complexity, inverse kinematics (IK) problems are often solved with iterative solutions. 
While iterative solutions can handle different IK poblems with a single algorithm, 
they can also become computationally expensive. If a specific IK problem needs to be computed often, 
it is worth considering an analytic solution.

If we limit the problem to a two bone chain in a two-dimensions, we can derive the anaytic solution 
without much complexity. This will generally be more efficient than its iterative alternatives. 
While this specific case lends itself to a 2D world, it can also be used in 3D as long as the 
kinematic chain's motion is limited to a single plane.

The start joint is the first bone in the chain that rotates, and the end joint is the last. 
The effector or goal is the position of the tip of the end bone (the point the IK chain reaches for). 
The goal's rotation usually has no effect on its IK system. 

IK Solvers: 
   * Rotate Plane IK (RPIK) and History-Independent IK (HIIK) solvers are the most common. The "history-independent" means that the solver does not depend on preceding frames. This is the most common type of IK solver. 
   * Limb IK and 2 Bone IK solvers only solve for a two bone chain (such as the upper and lower arm, hip and calf, etc.). Practically, it is almost identical to the HI IK solver. But because it is set up for two bones always, it is very fast, and commonly used inside game engines (and can be exported directly from 3d apps, often). 
   * Full Body IK (FBIK) is a specialized system where manipulating one IK chain manipulates the entire body. For example, a character may reach his arm forward- when his arm reaches maximum extention, he will begin to turn his shoulders, torso, pelvis, and finally, his legs. 

References:
	Maya SDK's free sample: ik2Bsolver/ik2Bsolver.cpp, and Rotate Plane IK solver
	web article: Analytic Two-Bone IK in 2D

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Animations/Bones/IKTwoBoneResolver.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
local IKTwoBoneResolver = commonlib.gettable("System.Scene.Animations.Bones.IKTwoBoneResolver");

local startJointPos =  vector3d:new(0,0,0);
local midJointPos =  vector3d:new(0,1,0);
local effectorPos =  vector3d:new(0,2,0); 
local handlePos =  vector3d:new(0,1,0);
local poleVector =  vector3d:new(0,0,1);
local twistValue = 0;
local qStart, qMid = IKTwoBoneResolver:solveIK(startJointPos, midJointPos, effectorPos, handlePos, poleVector, twistValue);
echo({{unpack(qStart)}, {unpack(qMid)}});
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Plane = commonlib.gettable("mathlib.Plane");
local vector3d = commonlib.gettable("mathlib.vector3d");
local IKTwoBoneResolver = commonlib.inherit(nil, commonlib.gettable("System.Scene.Animations.Bones.IKTwoBoneResolver"));


function IKTwoBoneResolver:ctor()
end

-- rotate Plane resolver based on Maya SDK's free sample: ik2Bsolver/ik2Bsolver.cpp, and Rotate Plane IK solver
-- Using analitical method to calculate quaternions of two bones for possible configuration. 
-- Algorithm is part of "Rotate Plane IK solver" with only two bones. This is fast and robust alogrithm
-- @param startJointPos: vector3, first bone position (pivot point)
-- @param midJointPos: vector3, second bone position (immediately child of first bone) 
-- @param effectorPos: vector3, third bone position, this is also the place where we start dragging the handle.  
-- @param handlePos: vector3, the desired destination position of the third bone (the editor's handle position). 
-- @param poleVector: vector3, The pole vector is a manipulator that lets you change the orientation of the IK chain. The pole vector also lets you control flipping. 
--  poleVector is defined as the vector orthogonal to the vectorE(= endPos - startJointPos), pointing to the side of midJointPos and in the same plane of (midJointPos, vectorE).
-- @param twistValue: number in radian, how much to twist around the axis (from handlePos to startJointPos). default to 0 twist. 
-- @return qStart, qMid: output quaternion of the start Bone (first bone) and the middle Bone (second bone or child bone).
function IKTwoBoneResolver:solveIK(startJointPos, midJointPos, effectorPos, handlePos, poleVector, twistValue)
	local qStart, qMid;
	-- vector from startJoint to midJoint
	local vector1 = midJointPos - startJointPos;
	-- vector from midJoint to effector
	local vector2 = effectorPos - midJointPos;
	-- vector from startJoint to handle: handle vector
	local vectorH = handlePos - startJointPos;
	-- vector from startJoint to effector
	local vectorE = effectorPos - startJointPos;
	-- lengths of those vectors
	local length1 = vector1:length();
	local length2 = vector2:length();
	local lengthH = vectorH:length();
	-- component of the vector1 orthogonal to the vectorE
	local vectorO = vector1 - vectorE*((vector1:dot(vectorE))/(vectorE:dot(vectorE)));

	---------------------------------------------
	-- calculate q12 which solves for the midJoint rotation
	---------------------------------------------
	-- angle between vector1 and vector2
	local vectorAngle12 = vector1:angle(vector2);
	-- vector orthogonal to vector1 and 2
	local vectorCross12 = (vector1*vector2):normalize();
	if(vectorCross12:length2() < 0.000001) then
		-- Note Xizhi: special case when arm is fully strenched. 
		vectorCross12 = (defaultPoleVector*vector1):normalize();
		vectorO:set(vectorCross12);
	end
	local lengthHsquared = lengthH*lengthH;
	-- angle for arm extension 
	local cos_theta = (lengthHsquared - length1*length1 - length2*length2) / (2*length1*length2);
	if (cos_theta > 1) then
		cos_theta = 1;
	elseif (cos_theta < -1) then
		cos_theta = -1;
	end
	local theta = math.acos(cos_theta);
	-- quaternion for arm extension
	local q12 = Quaternion:new():FromAngleAxis(theta - vectorAngle12, vectorCross12);
	
	---------------------------------------------
	-- calculate qEH which solves for effector rotating onto the handle
	---------------------------------------------
	-- vector2 with quaternion q12 applied
	vector2 = vector2:rotateBy(q12);
	-- vectorE with quaternion q12 applied
	vectorE = vector1 + vector2;
	-- quaternion for rotating the effector onto the handle
	local qEH = Quaternion:new():FromVectorToVector(vectorE, vectorH);

	---------------------------------------------
	-- calculate qNP which solves for the rotate plane
	---------------------------------------------
	-- vector1 with quaternion qEH applied
	vector1 = vector1:rotateBy(qEH);
	if (vector1:isParallel(vectorH)) then
		-- singular case, use orthogonal component instead
		vector1 = vectorO:rotateBy(qEH);
	end
	-- quaternion for rotate plane
	local qNP;
	if (not poleVector:isParallel(vectorH) and (lengthHsquared ~= 0)) then
		-- component of vector1 orthogonal to vectorH
		local vectorN = vector1 - vectorH * ((vector1:dot(vectorH))/lengthHsquared);
		-- component of pole vector orthogonal to vectorH
		local vectorP = poleVector - vectorH*((poleVector:dot(vectorH))/lengthHsquared);
		local dotNP = (vectorN:dot(vectorP))/(vectorN:length()*vectorP:length());
		if (math.abs(dotNP + 1.0) < 0.000001) then
			-- singular case, rotate halfway around vectorH
			local qNP1 = Quaternion:new():FromAngleAxis(math.pi, vectorH);
			qNP = qNP1;
		else
			local qNP2 = Quaternion:new():FromVectorToVector(vectorN, vectorP);
			qNP = qNP2;
		end
	else
		qNP = Quaternion:new();
	end

	---------------------------------------------
	-- calculate qTwist which adds the twist
	---------------------------------------------
	local qTwist = Quaternion:new():FromAngleAxis(twistValue or 0, vectorH);

	-- quaternion for the mid joint
	qMid = q12;	
	-- concatenate the quaternions for the start joint
	qStart = qEH*qNP*qTwist;

	return qStart, qMid;
end

-- this is a simplified version of rotate Plane resolver, which does not take poleVector and twist into consideration. 
-- @param defaultPoleVector: only used in special position, when arm is fully strenched. 
function IKTwoBoneResolver:solveTwoBoneIK(startJointPos, midJointPos, effectorPos, handlePos, defaultPoleVector)
	local qStart, qMid;
	-- vector from startJoint to midJoint
	local vector1 = midJointPos - startJointPos;
	-- vector from midJoint to effector
	local vector2 = effectorPos - midJointPos;
	-- vector from startJoint to handle: handle vector
	local vectorH = handlePos - startJointPos;
	-- vector from startJoint to effector
	local vectorE = effectorPos - startJointPos;
	-- lengths of those vectors
	local length1 = vector1:length();
	local length2 = vector2:length();
	local lengthH = vectorH:length();
	
	---------------------------------------------
	-- calculate q12 which solves for the midJoint rotation
	---------------------------------------------
	-- angle between vector1 and vector2
	local vectorAngle12 = vector1:angle(vector2);
	-- vector orthogonal to vector1 and 2
	local vectorCross12 = (vector1*vector2):normalize();
	if(vectorCross12:length2() < 0.000001) then
		-- Note Xizhi: special case when arm is fully strenched. 
		vectorCross12 = (defaultPoleVector*vector1):normalize();
	end
	local lengthHsquared = lengthH*lengthH;
	-- angle for arm extension 
	local cos_theta = (lengthHsquared - length1*length1 - length2*length2) / (2*length1*length2);
	if (cos_theta > 1) then
		cos_theta = 1;
	elseif (cos_theta < -1) then
		cos_theta = -1;
	end
	local theta = math.acos(cos_theta);
	-- quaternion for arm extension
	local q12 = Quaternion:new():FromAngleAxis(theta - vectorAngle12, vectorCross12);
	
	---------------------------------------------
	-- calculate qEH which solves for effector rotating onto the handle
	---------------------------------------------
	-- vector2 with quaternion q12 applied
	vector2 = vector2:rotateBy(q12);
	-- vectorE with quaternion q12 applied
	vectorE = vector1 + vector2;
	-- quaternion for rotating the effector onto the handle
	local qEH = Quaternion:new():FromVectorToVector(vectorE, vectorH);

	-- quaternion for the mid joint
	qMid = q12;	
	-- concatenate the quaternions for the start joint
	qStart = qEH;
	return qStart, qMid;
end

-- we will simply apply one bone IK, which just convert effectorPos's translation to startJointPos's rotation. 
-- @return qStart: quaternion to rotate the start joint
function IKTwoBoneResolver:solveOneBoneIK(startJointPos, effectorPos, handlePos)
	-- vector from effector to start Joint
	local vectorE = effectorPos - startJointPos;
	-- vector from startJoint to handle: handle vector
	local vectorH = handlePos - startJointPos;

	-- quaternion for rotating the effector onto the handle
	local qEH = Quaternion:new():FromVectorToVector(vectorE, vectorH);
	return qEH;
end