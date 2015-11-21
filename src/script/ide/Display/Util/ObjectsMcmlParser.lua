--[[
Title: ObjectsMcmlParser
Author(s): Leio
Date: 2009/1/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Util/ObjectsMcmlParser.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvas.lua");
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
NPL.load("(gl)script/ide/Display/Containers/Scene.lua");
NPL.load("(gl)script/ide/Display/Containers/Sprite3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Flower.lua");
NPL.load("(gl)script/ide/Display/Objects/PetE.lua");
NPL.load("(gl)script/ide/Display/Objects/Pet.lua");
NPL.load("(gl)script/ide/Display/Objects/PlantE.lua");
NPL.load("(gl)script/ide/Display/Objects/RoomEntry.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandObj.lua");
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
local ObjectsMcmlParser = {
}
commonlib.setfield("CommonCtrl.Display.Util.ObjectsMcmlParser",ObjectsMcmlParser);
function ObjectsMcmlParser.commonProperty(mcmlNode)
	if(not mcmlNode)then return; end
	local params = {};
	params.x = mcmlNode:GetNumber("x");
	params.y =mcmlNode:GetNumber("y");
	params.z =mcmlNode:GetNumber("z");
	params.facing =mcmlNode:GetNumber("facing");
	params.scaling =mcmlNode:GetNumber("scaling");
	params.visible = mcmlNode:GetBool("visible");
	params.IsCharacter = mcmlNode:GetBool("IsCharacter");
	params.homezone = mcmlNode:GetString("homezone");
	params.AssetFile = mcmlNode:GetString("AssetFile");
	
	return params;
end
-----------------------------------
-- LiteCanvas control
-----------------------------------
local LiteCanvas = {};
ObjectsMcmlParser.LiteCanvas = LiteCanvas;
function LiteCanvas.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = Map3DSystem.App.Inventor.LiteCanvas:new()
	if(node)then
		local px = mcmlNode:GetNumber("x") or 255;
		local py = mcmlNode:GetNumber("y") or 0;
		local pz = mcmlNode:GetNumber("z") or 255;
		node:SetPlayerPos(px,py,pz);
	end
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Display.Util.ObjectsMcmlParser.create(childnode)
		if(type(child) == "table") then
			node:SetMiniScene(child);
			break;
		end	
	end
	return node;
end
-----------------------------------
-- Scene control
-----------------------------------
local Scene = {};
ObjectsMcmlParser.Scene = Scene;
function Scene.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Containers.Scene:new()
	node:Init();
	node:SetEntityParams(params);
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Display.Util.ObjectsMcmlParser.create(childnode)
		if(type(child) == "table") then
			node:AddChild(child);
		end	
	end
	node:UpdateEntity();
	return node;
end
-----------------------------------
-- MiniScene control
-----------------------------------
local MiniScene = {};
ObjectsMcmlParser.MiniScene = MiniScene;
function MiniScene.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Containers.MiniScene:new()
	node:Init();
	node:SetEntityParams(params);
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Display.Util.ObjectsMcmlParser.create(childnode)
		if(type(child) == "table") then
			node:AddChild(child);
		end	
	end
	node:UpdateEntity();
	return node;
end
-----------------------------------
-- Flower control
-----------------------------------
local Flower = {};
ObjectsMcmlParser.Flower = Flower;
function Flower.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Objects.Flower:new()
	node:Init();
	node:SetEntityParams(params);
	return node;
end
-----------------------------------
-- RoomEntry control
-----------------------------------
local RoomEntry = {};
ObjectsMcmlParser.RoomEntry = RoomEntry;
function RoomEntry.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Objects.RoomEntry:new()
	node:Init();
	node:SetEntityParams(params);
	return node;
end
-----------------------------------
-- PlantE control
-----------------------------------
local PlantE = {};
ObjectsMcmlParser.PlantE = PlantE;
function PlantE.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Objects.PlantE:new()
	node:Init();
	node:SetEntityParams(params);
	return node;
end
-----------------------------------
-- PetE control
-----------------------------------
local PetE = {};
ObjectsMcmlParser.PetE = PetE;
function PetE.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Objects.PetE:new()
	node:Init();
	node:SetEntityParams(params);
	return node;
end
-----------------------------------
-- Pet control
-----------------------------------
local Pet = {};
ObjectsMcmlParser.Pet = Pet;
function Pet.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Objects.Pet:new()
	node:Init();
	node:SetEntityParams(params);
	return node;
end
-----------------------------------
-- HomeLandObj_A
-----------------------------------
local HomeLandObj_A = {};
ObjectsMcmlParser.HomeLandObj_A = HomeLandObj_A;
function HomeLandObj_A.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	local HomeLandObj = mcmlNode:GetString("HomeLandObj");
	if(not params)then return end
	local node = Map3DSystem.App.HomeLand.HomeLandObj_A:new()
	node:Init();
	node.HomeLandObj = HomeLandObj;
	node:SetEntityParams(params);
	local uid =  mcmlNode:GetString("name");
	if(uid)then
		node:SetUID(uid);
	end
	return node;
end
-----------------------------------
-- HomeLandObj_B
-----------------------------------
local HomeLandObj_B = {};
ObjectsMcmlParser.HomeLandObj_B = HomeLandObj_B;
function HomeLandObj_B.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	local HomeLandObj = mcmlNode:GetString("HomeLandObj");
	if(not params)then return end
	local node = Map3DSystem.App.HomeLand.HomeLandObj_B:new()
	node:Init();
	node.HomeLandObj = HomeLandObj;
	node:SetEntityParams(params);
	local uid =  mcmlNode:GetString("name");
	if(uid)then
		node:SetUID(uid);
	end
	local gridInfo = mcmlNode:GetString("GridInfo");
	if(gridInfo and node.SetGrid)then
		node:SetGrid(gridInfo);
	end
	local roomUID =  mcmlNode:GetString("DoorPlate");
	if(roomUID)then
		node:SetDoorPlate(roomUID);
	end
	local guid =  mcmlNode:GetString("guid");
	if(guid)then
		node:SetGUID(guid);
	end
	return node;
end
-----------------------------------
-- Sprite3D control
-----------------------------------
local Sprite3D = {};
ObjectsMcmlParser.Sprite3D = Sprite3D;
function Sprite3D.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Containers.Sprite3D:new()
	node:Init();
	local name = mcmlNode:GetString("name");
	if(name)then
		node:SetUID(name);
	end
	--node:SetEntityParams(params);
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = CommonCtrl.Display.Util.ObjectsMcmlParser.create(childnode)
		if(type(child) == "table") then
			node:AddChild(child);
		end	
	end
	node:UpdateEntity();
	return node;
end
-----------------------------------
-- Actor3D control
-----------------------------------
local Actor3D = {};
ObjectsMcmlParser.Actor3D = Actor3D;
function Actor3D.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Objects.Actor3D:new()
	node:Init();
	local name = mcmlNode:GetString("name");
	if(name)then
		node:SetUID(name);
	end
	node:SetEntityParams(params);
	return node;
end
-----------------------------------
-- Building3D control
-----------------------------------
local Building3D = {};
ObjectsMcmlParser.Building3D = Building3D;
function Building3D.create(mcmlNode)
	local params = ObjectsMcmlParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display.Objects.Building3D:new()
	node:Init();
	local name = mcmlNode:GetString("name");
	if(name)then
		node:SetUID(name);
	end
	node:SetEntityParams(params);
	return node;
end
------------------------------------------------------------
-- CommonCtrl.Display.Util.ObjectsMcmlParser.control_mapping
------------------------------------------------------------
ObjectsMcmlParser.control_mapping = {
	["LiteCanvas"] = ObjectsMcmlParser.LiteCanvas,
	["MiniScene"] = ObjectsMcmlParser.MiniScene,
	["Scene"] = ObjectsMcmlParser.Scene,
	["Sprite3D"] = ObjectsMcmlParser.Sprite3D,
	["Flower"] = ObjectsMcmlParser.Flower,
	["Building3D"] = ObjectsMcmlParser.Building3D,
	["Actor3D"] = ObjectsMcmlParser.Actor3D,
	["PetE"] = ObjectsMcmlParser.PetE,
	["Pet"] = ObjectsMcmlParser.Pet,
	["PlantE"] = ObjectsMcmlParser.PlantE,
	["HomeLandObj_A"] = ObjectsMcmlParser.HomeLandObj_A,
	["HomeLandObj_B"] = ObjectsMcmlParser.HomeLandObj_B,
	}
function ObjectsMcmlParser.create(mcmlNode) 
	if(not mcmlNode)then return; end
	local ctl = ObjectsMcmlParser.control_mapping[mcmlNode.name];
	if (ctl and ctl.create) then
		-- if there is a known control_mapping, use it and return
		return ctl.create(mcmlNode);
	else
		-- if no control mapping found, create each child node. 
		local childnode;
		if(mcmlNode.next)then
			for childnode in mcmlNode:next() do
				ObjectsMcmlParser.create(childnode);
			end
		end
	end
end

