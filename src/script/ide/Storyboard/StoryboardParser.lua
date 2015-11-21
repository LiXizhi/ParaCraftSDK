--[[
Title: StoryboardParser
Author(s): Leio Zhang
Date: 2009/3/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/StoryboardParser.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Storyboard/Storyboard.lua");
NPL.load("(gl)script/ide/Storyboard/LayerManager.lua");
NPL.load("(gl)script/ide/Storyboard/KeyFrames.lua");
NPL.load("(gl)script/ide/Storyboard/KeyFrame.lua");
NPL.load("(gl)script/ide/Storyboard/Target.lua");

local StoryboardParser={};
commonlib.setfield("CommonCtrl.Storyboard.StoryboardParser",StoryboardParser);
-----------------------------------
-- Storyboard control
-----------------------------------
local Storyboard = {};
StoryboardParser.Storyboard = Storyboard;
function Storyboard.create(mcmlNode)
	if(not mcmlNode)then return end
	local node = CommonCtrl.Storyboard.Storyboard:new();
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Storyboard.StoryboardParser.create(childnode)
		if(type(child) == "table") then
			node:AddChild(child);
		end	
	end
	return node;
end
-----------------------------------
-- LayerManager control
-----------------------------------
local LayerManager = {};
StoryboardParser.LayerManager = LayerManager;
function LayerManager.create(mcmlNode)
	if(not mcmlNode)then return end
	local node = CommonCtrl.Storyboard.LayerManager:new();
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Storyboard.StoryboardParser.create(childnode)
		if(type(child) == "table") then
			node:AddChild(child);
		end	
	end
	return node;
end
-----------------------------------
-- KeyFrames control
-----------------------------------
local KeyFrames = {};
StoryboardParser.KeyFrames = KeyFrames;
function KeyFrames.create(mcmlNode)
	if(not mcmlNode)then return end
	local node = CommonCtrl.Storyboard.KeyFrames:new();
	local TargetName = mcmlNode:GetString("TargetName");
	node:SetTargetName(TargetName);
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Storyboard.StoryboardParser.create(childnode)
		if(type(child) == "table") then
			node:AddChild(child);
		end	
	end
	return node;
end
-----------------------------------
-- KeyFrame control
-----------------------------------
local KeyFrame = {};
StoryboardParser.KeyFrame = KeyFrame;
function KeyFrame.create(mcmlNode)
	if(not mcmlNode)then return end
	local node = CommonCtrl.Storyboard.KeyFrame:new();
	local KeyTime = mcmlNode:GetString("KeyTime");
	local SimpleEase = mcmlNode:GetNumber("SimpleEase") or 0;
	node:SetKeyTime(KeyTime);
	node:SetSimpleEase(SimpleEase);
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Storyboard.StoryboardParser.create(childnode)
		if(type(child) == "table") then
			node:SetTarget(child);
		end	
	end
	return node;
end
-----------------------------------
-- Target control
-----------------------------------
local Target = {};
StoryboardParser.Target = Target;
function Target.create(mcmlNode)
	if(not mcmlNode)then return end	
	local X = mcmlNode:GetNumber("X");
	local Y =mcmlNode:GetNumber("Y");
	local Z =mcmlNode:GetNumber("Z");
	local Alpha =mcmlNode:GetNumber("Alpha");
	local Facing =mcmlNode:GetNumber("Facing");
	local Scaling =mcmlNode:GetNumber("Scaling");
	local Visible = mcmlNode:GetBool("Visible");
	local Animation = mcmlNode:GetString("Animation");
	local Dialog = mcmlNode:GetString("Dialog");
	local node = CommonCtrl.Storyboard.Target:new{
		params = {
			X = X,
			Y = Y,
			Z = Z,
			Facing = Facing,
			Scaling = Scaling,
			Alpha = Alpha,
			Visible = Visible,
			Animation = Animation,
			Dialog = Dialog,
		},
	}
	return node;
end
-------------------------------------
StoryboardParser.control_mapping = {
	["Storyboard"] = StoryboardParser.Storyboard,
	["LayerManager"] = StoryboardParser.LayerManager,
	["KeyFrames"] = StoryboardParser.KeyFrames,
	["KeyFrame"] = StoryboardParser.KeyFrame,
	["Target"] = StoryboardParser.Target,
	}
function StoryboardParser.create(mcmlNode) 
	if(not mcmlNode)then return; end
	local ctl = StoryboardParser.control_mapping[mcmlNode.name];
	if (ctl and ctl.create) then
		-- if there is a known control_mapping, use it and return
		return ctl.create(mcmlNode);
	else
		-- if no control mapping found, create each child node. 
		local childnode;
		for childnode in mcmlNode:next() do
			StoryboardParser.create(childnode);
		end
	end
end


