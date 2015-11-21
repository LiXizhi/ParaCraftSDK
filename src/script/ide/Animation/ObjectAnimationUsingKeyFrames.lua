--[[
Title: ObjectAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/24
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/ObjectAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/KeyFrame.lua");
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
local ObjectAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.AnimationUsingKeyFrames, {
	property = "ObjectAnimationUsingKeyFrames",
	name = "ObjectAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:objectAnimationUsingKeyFrames",
	-- CreateMeshPhysicsObject
	--Value = {
	--	["MeshPhysicsObjectParameters"] =[[ 1.000000,1.000000,1.000000, false, "1.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000"]]
	--	["SetPosition"] = [[1, 0, 1]],
	--	["SetFacing"] = [[0.000000]],
	--	["SetScale"] = [[10.000000]],
	--	["SetRotation"] = [[255.251480, 0.000000, 254.844879]],	
	--	["Asset"] = [[model/05plants/02tree/06椰子树/椰树_new1_v.x]]
	--}
	-- "Create2DContainer","Create2DButton","Create2DText"
	--Value = {
	--	["postion"] = "1,1,1,1" -- left,right,width,height
	--	["text"] = "test" -- it is available when  SurpportProperty is Create2DButton or Create2DText
	-- }
	SurpportProperty = {"CreateMeshPhysicsObject","ModifyMeshPhysicsObject","DeleteMeshPhysicsObject","Create2DContainer","Create2DButton","Create2DText"},
});  
commonlib.setfield("CommonCtrl.Animation.ObjectAnimationUsingKeyFrames",ObjectAnimationUsingKeyFrames);
-- override parent InsertFirstKeyFrame
function ObjectAnimationUsingKeyFrames:InsertFirstKeyFrame()
	--local Value =CommonCtrl.Animation.Util.GetDisplayObjProperty(self) ;
	local keyframe = CommonCtrl.Animation.DiscreteObjectKeyFrame:new{
		KeyTime = "00:00:00",
		Value = nil,
	}
	commonlib.insertArrayItem(self.keyframes, 1, keyframe);
end

function ObjectAnimationUsingKeyFrames:getValue(time)
	-- hide all had been created object 
	CommonCtrl.Animation.KeyFramesPool.WhoIsShowed(self,time)		
	local curKeyframe = self:getCurrentKeyframe(time);
	if(not curKeyframe)then 
		return nil,nil,time; 
	end
	local begin = curKeyframe:GetValue();
	if(not begin)then
		return nil,curKeyframe,time; 
	end
	local nextKeyframe = self:getNextKeyframe(time);
	if (not nextKeyframe or nextKeyframe.parentProperty =="DiscreteKeyFrame") then	
			
		return begin,curKeyframe,time;
	end
	return nil,curKeyframe,time; 
end
function ObjectAnimationUsingKeyFrames:ReverseToMcml()
	if(not self.TargetName or not self.TargetProperty)then return "\r\n" end
	local node_value = "";
	local k,frame;
	for k,frame in ipairs(self.keyframes) do
		node_value = node_value..frame:ReverseToMcml().."\r\n";
	end
	local str = string.format([[<pe:objectAnimationUsingKeyFrames TargetName="%s" TargetProperty="%s">%s</pe:objectAnimationUsingKeyFrames>]],self.TargetName,self.TargetProperty,node_value.."\r\n");
	return str;
end
--------------------------------------------------------------------------
-- DiscreteObjectKeyFrame
local DiscreteObjectKeyFrame  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscreteObjectKeyFrame",
	name = "DiscreteObjectKeyFrame_instance",
	mcmlTitle = "pe:discreteObjectKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.DiscreteObjectKeyFrame ",DiscreteObjectKeyFrame );
function DiscreteObjectKeyFrame:ReverseToMcml()
	if(not self.Value or not self.KeyTime)then return "\r\n" end
	local node_value = commonlib.serialize(self.Value);
	local node = string.format([[<pe:discreteObjectKeyFrame KeyTime="%s">%s</pe:discreteObjectKeyFrame>]],self.KeyTime,"\r\n"..node_value);
	return node;
end