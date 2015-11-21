--[[
Title: MiniScene
Author(s): Leio
Date: 2009/1/13
Desc: 
MiniScene --> Sprite3D --> DisplayObjectContainer --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
MiniScene can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
local miniScene = CommonCtrl.Display.Containers.MiniScene:new()
miniScene:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Containers/Sprite3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local MiniScene = commonlib.inherit(CommonCtrl.Display.Containers.Sprite3D,{
	CLASSTYPE = "MiniScene",
});  
commonlib.setfield("CommonCtrl.Display.Containers.MiniScene",MiniScene);

CommonCtrl.Display.Containers.AllSceneChildren = {};
function MiniScene:Init()
	local uid = self:GetUID();
	local objGraph = ParaScene.GetMiniSceneGraph("container"..uid);
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
function MiniScene:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.MiniScene:new();
	clone_node:Init();
	clone_node:SetUID(uid);
	clone_node:SetEntityID("");
	clone_node:SetParent(parent);
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
function MiniScene:CloneNoneID()
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.MiniScene:new();
	clone_node:Init();
	clone_node:SetEntityID("");
	clone_node:SetParent(parent);
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
--function MiniScene:SetSelected(v)
	--self.internal_selected = v;
	--local nSize = table.getn(self.Nodes);
	--local i, node;
	--for i=1, nSize do
		--node = self.Nodes[i];
		--if(node~=nil) then
			--node:SetSelected(v);
		--end
	--end
--end
--function MiniScene:GetSelected()
	--return self.internal_selected;
--end
------------------------------------------------------------
-- public methods
------------------------------------------------------------
function MiniScene:HitTest(node)
	if(not node)then return end
	local scene =  self:GetScene();
	if(scene and scene:IsValid())then
		local x, y = ParaUI.GetMousePosition();
		local obj = scene:MousePick(x,y,40, "4294967295");		
		if(obj:IsValid()) then	
			local id = tostring(obj:GetID());
			local entityID = node:GetEntityID()
			if(id == entityID)then
				return true;		
			end
		end	
	end
end

-- id is entityID
function MiniScene:GetEntity(child)
	if(not child)then return end
	local id = child:GetEntityID(); --entityID
	id = tonumber(id);
	if(id)then
		local obj = ParaScene.GetObject(id);
		if(obj and obj:IsValid())then
			return obj;
		end
	end
end
function MiniScene:AddObject(obj,child)
	if(not obj or not obj:IsValid())then return end;
	local scene = self:GetScene();
	scene:AddChild(obj)
	obj:GetAttributeObject():SetField("progress", child:GetProgress() or 1);
	local id = obj:GetID();
	child:SetEntityID(id);
	child:SetBuilded(true);
end
function MiniScene:RemoveObject(child)
	if(not child)then return end;
	CommonCtrl.Display.Containers.AllSceneChildren[child:GetUID()] = nil;
	local id = child:GetUID();
	local scene = self:GetScene();
	scene:DestroyObject(id)
	child:SetBuilded(false);
end
function MiniScene:MousePick()
	local scene =  self:GetScene();
	if(scene and scene:IsValid())then
		local x, y = ParaUI.GetMousePosition();
		local obj = scene:MousePick(x,y,40, "4294967295");		
		if(obj:IsValid()) then		
			local result = self:GetChildByEntityID(obj:GetID());		
			if(result)then
				return result;		
			end
		end	
	end
end

------------------------------------------------------------
-- private methods
------------------------------------------------------------
function MiniScene:GetScene()
	local uid = self:GetUID();
	local objGraph = ParaScene.GetMiniSceneGraph("container"..uid);
	return objGraph;
end
function MiniScene:__RegHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local uid = self:GetUID();
	local o = {hookType = hookType, 		 
		hookName = uid.."MiniScene_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = MiniScene.__DispatchMouseKeyEvent;
			o.MiniScene = self; -- hook himself
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = uid.."MiniScene_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = MiniScene.__DispatchMouseKeyEvent;
			o.MiniScene = self; -- hook himself
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = uid.."MiniScene_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = MiniScene.__DispatchMouseKeyEvent;
			o.MiniScene = self; -- hook himself
	CommonCtrl.os.hook.SetWindowsHook(o);
end
function MiniScene.__DispatchMouseKeyEvent(nCode, appName, msg, o)
	if(not o)then return nCode; end
	local self = o.MiniScene;
	if(self)then
		local type = msg.wndName;
		local mouse_button = msg.mouse_button;
		local findedChild = self:MousePick()
		if(findedChild)then
			MiniScene.__DispatchNode(findedChild,type)
			MiniScene.__Dispatch(findedChild,type)
		end
	end	
	return nCode;
end
function MiniScene.__Dispatch(node,type)
	if(not node)then return end
	local parent = node:GetParent();
	if(parent)then
		MiniScene.__DispatchNode(parent,type)
		MiniScene.__Dispatch(parent,type)
	end
end
function MiniScene.__DispatchNode(findedChild,type)
	if(findedChild)then
			if(type == "mouse_down")then
				if(mouse_button and mouse_button == "left")then
					--commonlib.echo({findedChild:GetUID(),findedChild:GetEntityID()});
					findedChild:DispatchEvent({type = "left_mouse_down" , currentTarget = findedChild});
				elseif(mouse_button and mouse_button == "right")then
					findedChild:DispatchEvent({type = "right_mouse_down" , currentTarget = findedChild});
				end
			elseif(type == "mouse_up")then
				if(mouse_button and mouse_button == "left")then
					findedChild:DispatchEvent({type = "left_mouse_up" , currentTarget = findedChild});
				elseif(mouse_button and mouse_button == "right")then
					findedChild:DispatchEvent({type = "right_mouse_up" , currentTarget = findedChild});
				end
			elseif(type == "mouse_move")then
				if(mouse_button and mouse_button == "left")then
					findedChild:DispatchEvent({type = "left_mouse_move" , currentTarget = findedChild});
				elseif(mouse_button and mouse_button == "right")then
					findedChild:DispatchEvent({type = "right_mouse_move" , currentTarget = findedChild});
				end
			end
	end
end
