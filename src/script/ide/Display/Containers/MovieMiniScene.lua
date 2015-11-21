--[[
Title: MovieMiniScene
Author(s): Leio
Date: 2009/1/17
Desc: 
MovieMiniScene --> MiniScene --> Sprite3D --> DisplayObjectContainer --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
MovieMiniScene can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Containers/MovieMiniScene.lua");
local scene = CommonCtrl.Display.Containers.MovieMiniScene:new()
scene:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Containers/Sprite3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
local MovieMiniScene = commonlib.inherit(CommonCtrl.Display.Containers.MiniScene,{
	CLASSTYPE = "MovieMiniScene",
	
});  
commonlib.setfield("CommonCtrl.Display.Containers.MovieMiniScene",MovieMiniScene);
function MovieMiniScene:Init()
	self:__RegHook();
	
	self:ClearEventPools();
	self:ClearChildren();
	
	self.entityPools = {};
end
------------------------------------------------------------
-- override parent methods:DisplayObjectContainer
------------------------------------------------------------

------------------------------------------------------------
-- override parent methods:DisplayObject
------------------------------------------------------------
-- clone
function MovieMiniScene:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.MovieMiniScene:new();
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
function MovieMiniScene:CloneNoneID()
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.MovieMiniScene:new();
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
function MovieMiniScene:AddObject(obj,child)
	if(not obj or not obj:IsValid())then return end;
	local can = self:CanAttachObject(obj);	

	local id = obj:GetID();
	id = tostring(id);
	child:SetEntityID(id);
		
	local scene = self:GetScene();
	if(can)then
		scene:AddChild(obj)
		child:SetBindEntityID(id);
		
		local temp =  {};
		local index = child:GetIndex();
		self.entityPools[index] = temp;
		
	end
	local timeLine = self:GetTimeLine();
	if(timeLine and child.SetKeyTime)then
		local keyTime = timeLine:GetTime();
		child:SetKeyTime(keyTime);
	end
	local pool = self.entityPools[id];
	if(pool)then
		pool[child:GetUID()] = child;
	end
end
function MovieMiniScene:RemoveObject(child)
	if(not child)then return end;
	local obj = self:GetEntity(child)
	local can = self:CanDetachObject(obj);	

	local id = child:GetUID();
	local scene = self:GetScene();
	if(can)then
		scene:DestroyObject(id)
	end
end

------------------------------------------------------------
-- public methods
------------------------------------------------------------
function MovieMiniScene:GetChildByBindEntityID(id)
	if(not self.Nodes)then return end;
	if(not id)then return end
	id = tostring(id);
	local result;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node) then
			if(node:GetBindEntityID() == id)then
				result = node;
				break;
			else
				if(node.GetChildByBindEntityID)then
					result = node:GetChildByBindEntityID(id)
					if(result)then
						break;
					end
				end			
			end
		end
	end
	return result;
end
function MovieMiniScene:GetTimeLine()
	return self.timeLine;
end
function MovieMiniScene:SetTimeLine(timeLine)
	self.timeLine = timeLine;
end
function MovieMiniScene:CanAttachObject(obj)
	if(not obj or not obj:IsValid())then return end;
	local id = obj:GetID();
	local result = self:GetChildByBindEntityID(id);
	if(result)then
		return false;
	end
	return true;
end
function MovieMiniScene:CanDetachObject(obj)
	local result = self:CanAttachObject(obj)
	if(result == nil)then
		return false;
	end
	return (not result);
end

