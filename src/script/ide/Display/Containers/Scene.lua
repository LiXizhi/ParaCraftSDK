--[[
Title: Scene
Author(s): Leio
Date: 2009/1/17
Desc: 
Scene --> MiniScene --> Sprite3D --> DisplayObjectContainer --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
Scene can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Containers/Scene.lua");
local scene = CommonCtrl.Display.Containers.Scene:new()
scene:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Containers/Sprite3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
local Scene = commonlib.inherit(CommonCtrl.Display.Containers.MiniScene,{
	CLASSTYPE = "Scene",
});  
commonlib.setfield("CommonCtrl.Display.Containers.Scene",Scene);
function Scene:Init()
	--self:__RegHook();
	
	self:ClearEventPools();
	self:ClearChildren();
	self:SetBuilded(true);
end
------------------------------------------------------------
-- override parent methods:DisplayObjectContainer
------------------------------------------------------------

------------------------------------------------------------
-- override parent methods:DisplayObject
------------------------------------------------------------
-- clone
function Scene:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.Scene:new();
	clone_node:Init();
	clone_node:SetUID(uid);
	clone_node:SetEntityID("");
	clone_node:SetParent(nil);
	clone_node:SetEntityParams(params);
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			clone_node:AddChild(node:Clone())
		end
	end
	
	return clone_node;
end
-- clone without id
function Scene:CloneNoneID()
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.Scene:new();
	clone_node:Init();
	clone_node:SetEntityID("");
	clone_node:SetParent(nil);
	clone_node:SetEntityParams(params);
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			clone_node:AddChild(node:CloneNoneID())
		end
	end
	
	return clone_node;
end
------------------------------------------------------------
-- override parent methods:MiniScene
------------------------------------------------------------
function Scene:HitTest(node)
	if(not node)then return end
		local obj = ParaScene.MousePick(40, "4294967295");	
		if(obj:IsValid()) then	
			local id = tostring(obj:GetID());
			local entityID = node:GetEntityID()
			if(id == entityID)then
				return true;		
			end
		end	
end
function Scene:AddObject(obj,child)
	if(not obj or not obj:IsValid())then return end;	
	ParaScene.Attach(obj);
	obj:GetAttributeObject():SetField("progress", child:GetProgress() or 1);
	local id = obj:GetID();
	child:SetEntityID(id);
end
function Scene:RemoveObject(child)
	if(not child)then return end;
	CommonCtrl.Display.Containers.AllSceneChildren[child:GetUID()] = nil;
	local obj = self:GetEntity(child);
	if(obj)then
		ParaScene.Delete(obj);
	end
end
function Scene:MousePick()
	local obj = ParaScene.MousePick(40, "4294967295");		
	if(obj:IsValid()) then		
		local result = self:GetChildByEntityID(obj:GetID());		
		if(result)then
			return result;		
		end
	end	
end
------------------------------------------------------------
-- private methods
------------------------------------------------------------