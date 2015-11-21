--[[
Title: 
Author(s): Leio
Date: 2009/8/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/AvatarQueue.lua");
local avatar_queue = CommonCtrl.Display3D.AvatarQueue:new();

local node_1 = CommonCtrl.Display3D.SceneNode:new{
	x = 255,
	y = 0,
	z = 255,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
avatar_queue:AddChild(node_1);
local node_2 = CommonCtrl.Display3D.SceneNode:new{
	x = 255,
	y = 3,
	z = 255,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
avatar_queue:AddChild(node_2);

avatar_queue:Start();
avatar_queue:ControlByPlayer();
-------------------------------------------------------
node 增加了额外的属性
node.mountState = "mount" -- "mount" or "be_mount" or nil
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local AvatarQueue = {
	uid = nil,
	root_node = nil,
	LayoutChildrenHandler = nil,
	dx = 0,
	dy = 0,
	dz = 0,
	--玩家的node，每个AvatarQueue实例只有一个
	player_node = nil,
	--当前被激活的node，有可能是player_node 或者其他的character
	actived_node = nil,
	--所有被监听的AvatarQueue
	AllPlaying_AvatarQueue = {},
	press = false,
	idle_frame = 0,
	idle_frame_total = 100,
	--是否启动空闲时间的随机移动
	idle_random_enabled = false,
}
commonlib.setfield("CommonCtrl.Display3D.AvatarQueue",AvatarQueue);
function AvatarQueue:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function AvatarQueue:Init()
	self.uid = ParaGlobal.GenerateUniqueID();
	local scene = CommonCtrl.Display3D.SceneManager:new();
	self.root_node = CommonCtrl.Display3D.SceneNode:new{
		root_scene = scene,
	}
	self.dx = 0;
	self.dy = 0;
	self.dz = 0;
	
	local enterFrameBeacon = ParaUI.GetUIObject("AvatarQueue__enterFrameBeacon__");
	if(not enterFrameBeacon:IsValid()) then 
		enterFrameBeacon = ParaUI.CreateUIObject("container","AvatarQueue__enterFrameBeacon__","_lt",0,0,0,0);	
		enterFrameBeacon.background="";
		enterFrameBeacon.enabled = false;
		enterFrameBeacon:AttachToRoot();
		enterFrameBeacon.onframemove = ";CommonCtrl.Display3D.AvatarQueue.EnterFrameHandler();";
	end	

end
function AvatarQueue:SetUID(uid)
	self.uid = uid;
end
function AvatarQueue:GetUID()
	return self.uid;
end
function AvatarQueue.EnterFrameHandler()
	local AllPlaying_AvatarQueue = AvatarQueue.AllPlaying_AvatarQueue;
	local name, anim
	for name,anim in pairs(AllPlaying_AvatarQueue) do
		anim:Update();
	end		
end
function AvatarQueue:Update()
	if(self.actived_node)then
		if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_W))then
			self.press = true;
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_S))then
			self.press = true;
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_A))then
			self.press = true;
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_D))then
			self.press = true;
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_Q))then
			self.press = true;
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_E))then
			self.press = true;
		else
			self.press = false;
		end
		if(self.press)then
			local old_x,old_y,old_z = self.actived_node.old_x,self.actived_node.old_y,self.actived_node.old_z;
			local x,y,z = self.actived_node.x,self.actived_node.y,self.actived_node.z;
			local dx = x - old_x;
			local dy = 0;
			local dz = z - old_z;
			self.actived_node.old_x,self.actived_node.old_y,self.actived_node.old_z = x,y,z;
			local player = ParaScene.GetPlayer();
			self.actived_node.x,self.actived_node.y,self.actived_node.z = player:GetPosition();
			self.actived_node.facing = player:GetFacing();
			--commonlib.echo({dx,dy,dz});
			self:UpdatePosition(dx,dy,dz);
			
			self.idle_frame = 0;
		else
			if(self.idle_random_enabled)then
				self.idle_frame = self.idle_frame + 1;
				if(self.idle_frame > self.idle_frame_total)then
					AvatarQueue.LayoutChildrenHandler_Idle(self)
					self.idle_frame = 0;
				end
				self:Update_Idle();
			end
		end
	end
end
function AvatarQueue:AddChild(child,index)
	self.root_node:AddChild(child,index);
end
function AvatarQueue:RemoveChild(child)
	if(not child or child == self.player_node)then return end
	if(child.mountState ~= nil)then
		self:MountOff()
	end
	child:Detach();
end
function AvatarQueue:ClearAllChildren()
	self:MountOff()
	--取消player的hook
	self.player_node.entityid = nil
	self.root_node:ClearAllChildren()
end
--把player加入队列当中
function AvatarQueue:ControlByPlayer()
	if(not self.player_node)then
		local player = ParaScene.GetPlayer();
		local x,y,z = player:GetPosition();
		local id = player:GetID();
		local node = CommonCtrl.Display3D.SceneNode:new{
			x = x,
			y = y,
			z = z,
			old_x = x,
			old_y = y,
			old_z = z,
			isattached = true,
			entityid = id,
		};
		-- hold player info
		self.player_node = node;
		self.actived_node = node;
		self:AddChild(node,1)
		--更新布局
		self:ReAlign();
		--AvatarQueue.LayoutChildrenHandler_Idle(self)
	end
end
--设置驾驭 和 被驾驭的物体
--把actived_node的位置更新到child上，设置焦点为child
function AvatarQueue:MountOn(child)
	if(not self.actived_node or not child or self.actived_node == child)then return end
	--如果已经有状态了，即已经驾驭了
	if(self.actived_node.mountState or child.mountState)then return end
	local scene = self.root_node:GetRootScene();
	if(scene)then
		-- 目前被激活的实体
		local entity_actived = scene:GetEntity(self.actived_node:GetEntityID());
		--将要被激活的实体
		local entity_will_active = scene:GetEntity(child:GetEntityID());
		if(entity_actived and entity_will_active)then
			local x,y,z = entity_actived:GetPosition();
			local _x,_y,_z = entity_will_active:GetPosition();
			--把将要驾驭的实体移动到 目前人物的位置
			entity_will_active:SetPosition(x,y,z);
			entity_will_active:ToCharacter():Stop();
			--驾驭
			System.MountPlayerOnChar(entity_actived, entity_will_active, true);
			--entity_actived 为player,它现在已经坐在 坐骑上面
			local x,y,z = entity_actived:GetPosition();
			self:SetNodePos(self.actived_node,x,y,z);
			
			self.actived_node.mountState = "mount"; --驾驭
			child.mountState = "be_mount"; --被驾驭
			
			child:SetScale(1);
			
			--entity_will_active，现在已经是被激活的对象
			local x,y,z = entity_will_active:GetPosition();
			self:SetNodePos(child,x,y,z);
			--设置目前激活的对象
			self.actived_node = child;
			
			--更新布局
			 self:ReAlign();
		end
		
	end
end
--更新player_node的位置信息
--切换焦点到player身上
function AvatarQueue:MountOff()
	local scene = self.root_node:GetRootScene();
	if(scene and self.actived_node and self.player_node)then
		--如果没有状态，即没有驾驭
		if(not self.actived_node.mountState or not self.player_node)then return end
		-- 目前被激活的实体，它是被驾驭的对象
		local entity_actived = scene:GetEntity(self.actived_node:GetEntityID());
		--将要被激活的实体，它是player
		local entity_will_active = scene:GetEntity(self.player_node:GetEntityID());
		if(entity_actived and entity_will_active)then
			--更新node的位置信息
			local x,y,z = entity_actived:GetPosition();
			self:SetNodePos(self.actived_node,x,y,z);
			--更新node的位置信息
			local x,y,z = entity_will_active:GetPosition();
			self:SetNodePos(self.player_node,x,y,z);
			
			--切换焦点到原来的player身上
			Map3DSystem.SwitchToObject(entity_will_active);
			entity_will_active:ToCharacter():AddAction(action_table.ActionSymbols.S_JUMP_START); 
			
			self.actived_node:SetScale(0.8);
			--清空驾驭状态
			self.actived_node.mountState = nil;
			self.player_node.mountState = nil;
			
			--设置目前激活的对象
			self.actived_node = self.player_node;
			--更新布局
			 self:ReAlign();
		end
		
	end
end
function AvatarQueue:SetNodePos(child,x,y,z)
	child.old_x = x;
	child.old_y = y;
	child.old_z = z;
	child.x = x;
	child.y = y;
	child.z = z;
end
function AvatarQueue:UpdatePosition(dx,dy,dz)
	self.dx = dx;
	self.dy = dy;
	self.dz = dz;
	self:UpdateChildren();
end
function AvatarQueue:Update_Idle()
	local scene = self.root_node:GetRootScene();
	local children_result = self.root_node:GetAllChildren();
	if(scene and children_result)then
		local k,child;
		for k,child in ipairs(children_result) do
			if(child)then
				if(child.mountState == nil and child ~= self.actived_node)then
					if(child.ischaracter)then
						local entity = scene:GetEntity(child:GetEntityID());
						if(entity)then
							child.x,child.y,child.z = entity:GetPosition();
						end
					end
				end
			end
		end
	end
end
function AvatarQueue:UpdateChildren()
	if(not self.dx or not self.dy or not self.dz)then return end
	local children_result = self.root_node:GetAllChildren();
	local facing = self.actived_node:GetFacing();
	if(children_result)then
		local k,child;
		for k,child in ipairs(children_result) do
			if(child)then
					local _x,_y,_z = child:GetPosition();
					_x = _x + self.dx;
					_y = _y + self.dy;
					_z = _z + self.dz;
				if(child.mountState == nil and child ~= self.actived_node)then
					if(child.ischaracter)then
						child:SetMoveTo(_x,_y,_z);
						child:SetFacing(facing);
					else
						child:SetPosition(_x,_y,_z);
					end
				end
			end
		end
	end
end
function AvatarQueue:Start()
	AvatarQueue.AllPlaying_AvatarQueue[self:GetUID()] = self;
end
function AvatarQueue:Stop()
	AvatarQueue.AllPlaying_AvatarQueue[self:GetUID()] = nil;
end
function AvatarQueue:ReAlign()
	self.idle_frame = 0;
	local scene = self.root_node:GetRootScene();
	local children_result = self.root_node:GetAllChildren();
	if(scene and children_result)then
		local k,child;
		for k,child in ipairs(children_result) do
			if(child)then
				if(child.mountState == nil and child ~= self.actived_node)then
					if(child.ischaracter)then
						local entity = scene:GetEntity(child:GetEntityID());
						if(entity)then
							entity:ToCharacter():Stop();
						end
					end
				end
			end
		end
	end
	if(self.LayoutChildrenHandler)then
		self.LayoutChildrenHandler(self);
	end
end
function AvatarQueue.LayoutChildrenHandler_Idle(self)
	if(not self.actived_node)then return end
	local scene = self.root_node:GetRootScene();
	local entity_actived = scene:GetEntity(self.actived_node:GetEntityID());
	local ismount = false;
	if(self.actived_node.mountState)then
		--目前为驾驭状态
		ismount = true;
	end
	local radius = 5;
	local origin_x,origin_y,origin_z = self.actived_node:GetPosition();
	local gap = 1;
	local children_result = self.root_node:GetAllChildren();
	if(children_result)then
		local len = #children_result;
		if(ismount)then
			len = len - 2;
		else
			len = len - 1;
		end
		if(len <= 0)then
			return 
		end
		local k,child;
		local i = 1;
		for k,child in ipairs(children_result) do
			if(child)then
				if(child.mountState == nil and child ~= self.actived_node)then
					local entity = scene:GetEntity(child:GetEntityID());
					if(entity_actived and entity and child.ischaracter)then
						local dist = entity:DistanceTo(entity_actived);
						local _x,_y,_z = origin_x,origin_y,origin_z
						local angle = math.random()*6.28;
						_x = origin_x + radius * math.sin(angle);
						_z = origin_z + radius * math.cos(angle);
						child:SetMoveTo(_x,_y,_z);
						i = i + 1;
					end
					
				end
			end
		end
	end
end
--默认布局
function AvatarQueue.LayoutChildrenHandler(self)
	if(not self.actived_node)then return end
	local ismount = false;
	if(self.actived_node.mountState)then
		--目前为驾驭状态
		ismount = true;
	end
	local radius = 5;
	local origin_x,origin_y,origin_z = self.actived_node:GetPosition();
	local gap = 1;
	local children_result = self.root_node:GetAllChildren();
	if(children_result)then
		local len = #children_result;
		if(ismount)then
			len = len - 2;
		else
			len = len - 1;
		end
		if(len <= 0)then
			return 
		end
		local half = math.floor(len / 2);
		local gap = 3;
		local k,child;
		local i = 1;
		for k,child in ipairs(children_result) do
			if(child)then
				if(child.mountState == nil and child ~= self.actived_node)then
					local x,y,z = child:GetPosition();
					local _x;
					if(i > half)then
						_x = origin_x + (i - half) * gap * -1;
					else
						_x = origin_x + i * gap;
					end
					local _y = 0;
					local _z = origin_z;
					child:SetPosition(_x,_y,_z);
					i = i + 1;
				end
			end
		end
	end
end
function AvatarQueue.LayoutChildrenHandler_circle(self)
	if(not self.actived_node)then return end
	local ismount = false;
	if(self.actived_node.mountState)then
		--目前为驾驭状态
		ismount = true;
	end
	local radius = 3;
	local origin_x,origin_y,origin_z = self.actived_node:GetPosition();
	local gap = 1;
	local children_result = self.root_node:GetAllChildren();
	if(children_result)then
		local len = #children_result;
		if(ismount)then
			len = len - 2;
		else
			len = len - 1;
		end
		if(len <= 0)then
			return 
		end
		local angle = 6.28/len;
		local k,child;
		local i = 0;
		for k,child in ipairs(children_result) do
			if(child)then
				if(child.mountState == nil and child ~= self.actived_node)then
					local x,y,z = child:GetPosition();
					local _angle = i * angle
					local _x = origin_x + radius * math.sin(_angle);
					local _y = 0;
					local _z = origin_z + radius * math.cos(_angle);
					child:SetPosition(_x,_y,_z);
					i = i + 1;
				end
			end
		end
	end
end
