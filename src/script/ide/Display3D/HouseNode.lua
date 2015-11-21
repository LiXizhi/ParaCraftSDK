--[[
Title: 
Author(s): Leio
Date: 2009/11/5
use the lib:
每个房屋都有两个插件点 入口cometo_point_position 和 返回后的位置 comeback_point_position
房屋模型分两种：
室外模型type = "OutdoorHouse"
室内模型type = "IndoorHouse"

每一个室外模型绑定一个室内模型
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/HouseNode.lua");

NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");

local sceneManager = CommonCtrl.Display3D.SceneManager:new{
		--type = "miniscene" --"scene" or "miniscene"
	};
local rootNode = CommonCtrl.Display3D.SceneNode:new{
	root_scene = sceneManager,
}

function gotoFunc(node)
	commonlib.echo("on hit!");
	if(not node or not node.linked_node)then return end
	local x,y,z = node.linked_node:GetAbsComeBackPosition();
	commonlib.echo({x,y,z});
	if(x and y and z)then
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= x, y = y, z = z});
	end
end
local x,y,z = ParaScene.GetPlayer():GetPosition();
local outdoor_node = CommonCtrl.Display3D.HouseNode:new{
	x = x,
	y = y,
	z = z,
	--assetfile = "model/01building/v5/01house/PoliceStation/Indoor.x",
	assetfile = "model/01building/v5/01house/PoliceStation/PoliceStation.x",
	type = "OutdoorHouse",
	ReadyGoFunc = gotoFunc,
};
rootNode:AddChild(outdoor_node);
local indoor_node = CommonCtrl.Display3D.HouseNode:new{
	x = x,
	y = y + 10,
	z = z,
	assetfile = "model/01building/v5/01house/PoliceStation/Indoor.x",
	type = "IndoorHouse",
	ReadyGoFunc = gotoFunc,
};
rootNode:AddChild(indoor_node);
--关联node
outdoor_node:SetLinkedHouse(indoor_node);
indoor_node:SetLinkedHouse(outdoor_node);

-------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local HouseNode = commonlib.inherit(CommonCtrl.Display3D.HomeLandCommonNode, {
	type = "OutdoorHouse",--默认为室外模型 --OutdoorHouse or IndoorHouse
	loaded = false,--插件点是否被loaded
	cometo_point_position = nil,--将要传送的插件点的位置
	comeback_point_position = nil,--返回后的位置
	linked_node = nil,--关联模型 室外<---->室内
	miniRootNode = nil,
	default_openstate = true,--在插件点加载完后，默认是否打开传送点监听
	
	--事件
	ReadyGoFunc = nil,--准备传送
	--global
	--记录监听的房屋 
	registerNodes = {
	
	},
	global_timer = nil,
	--defaultArrow = "model/06props/v3/headarrow.x",
	defaultArrow = "model/07effect/v5/ChuanSongDoor/ChuanSongDoor.x",
	
}, function(o)
	local sceneManager = CommonCtrl.Display3D.SceneManager:new{
		--type = "miniscene" --"scene" or "miniscene"
	};
	local rootNode = CommonCtrl.Display3D.SceneNode:new{
		root_scene = sceneManager,
	}
	o.miniRootNode = rootNode;
end)

commonlib.setfield("CommonCtrl.Display3D.HouseNode",HouseNode);
function HouseNode:EnabledAssetLoaded()
	CommonCtrl.AddControl(self.uid, self);
	local entity = self:GetEntity();
	commonlib.echo("==============AfterAttach");
	commonlib.echo(self.type);
	commonlib.echo(self:GetParams());
	if(entity)then
		entity:GetAttributeObject():SetField("On_AssetLoaded", string.format(";CommonCtrl.Display3D.HouseNode.WaitForAssetLoaded('%s');",self.uid))
	end
	
	if(not CommonCtrl.Display3D.HouseNode.global_timer)then
		local global_timer = commonlib.Timer:new{
			callbackFunc = HouseNode.TimerUpdate,
		}
		global_timer:Change(0, 1000)
		CommonCtrl.Display3D.HouseNode.global_timer = global_timer;
	end
end
--在创建实体之前
function HouseNode:BeforeAttach()

end
--在创建实体之后
function HouseNode:AfterAttach()
	local entity = self:GetEntity();
	if(entity)then
		entity:SetPhysicsGroup(1);
	end
end
--在销毁实体之前
function HouseNode:BeforeDetach()

end
--在销毁实体之后
function HouseNode:AfterDetach()

end
--重新加载插件点的坐标
function HouseNode:ReloadLoadPoint()
	local entity = self:GetEntity();
	if(entity)then
		local pos_x,pos_y,pos_z = self:GetPosition();
		local _x,_y,_z = entity:GetXRefScriptPosition(0);
		local node = self.miniRootNode:GetChild(1);
		local x = _x - pos_x;--记录相对坐标
		local y = _y - pos_y;
		local z = _z - pos_z;
		if(x and y and z and node)then
			node:SetPosition(_x,_y,_z);
			
			--将要传送的插件点的位置
			self.cometo_point_position = {
				x = x,
				y = y,
				z = z,
			}
			
		end
		local _x,_y,_z = entity:GetXRefScriptPosition(1);
		local x = _x - pos_x;--记录相对坐标
		local y = _y - pos_y;
		local z = _z - pos_z;
		if(x and y and z and node)then
			--返回后的位置
			self.comeback_point_position = {
				x = x,
				y = y,
				z = z,
			}
		end
	end
end
--当插件点加载完成，记录插件点的位置信息
function HouseNode.WaitForAssetLoaded(sName)
	local self = CommonCtrl.GetControl(sName);
	if(self)then
		local pos_x,pos_y,pos_z = self:GetPosition();
		local entity = self:GetEntity();
		if(entity)then
			commonlib.echo("==============AfterAssetLoaded");
			local nXRefCount = entity:GetXRefScriptCount();
			if(nXRefCount < 2)then return end
			local x,y,z = entity:GetXRefScriptPosition(0);
			x = x - pos_x;--记录相对坐标
			y = y - pos_y;
			z = z - pos_z;
			--将要传送的插件点的位置
			self.cometo_point_position = {
				x = x,
				y = y,
				z = z,
			}
			commonlib.echo("====cometo_point_position");
			commonlib.echo(self.cometo_point_position);
			----测试
			--if(self.type == "OutdoorHouse")then
				--self.cometo_point_position = {
					--x = x + 5,
					--y = y,
					--z = z + 5,
				--}
			--end
			local x,y,z = entity:GetXRefScriptPosition(1);
			x = x - pos_x;--记录相对坐标
			y = y - pos_y;
			z = z - pos_z;
			--返回后的位置
			self.comeback_point_position = {
				x = x,
				y = y,
				z = z,
			}
			commonlib.echo("====comeback_point_position");
			commonlib.echo(self.comeback_point_position);
			--插件点加载成功
			self.loaded = true;
			
			--增加箭头提示
			if(self.miniRootNode)then
				local x,y,z = self:GetAbsCometoPosition();
				local node = CommonCtrl.Display3D.SceneNode:new{
					x = x,
					y = y,
					z = z,
					assetfile = self.defaultArrow,
				};
				commonlib.echo("=======house arrow");
				commonlib.echo(node:GetEntityParams());
				self.miniRootNode:AddChild(node);
			end
			--打开监听
			if(self.default_openstate)then
				self:OpenDoor();
			else
				self:CloseDoor();
			end
			commonlib.echo("==============loaded");
			commonlib.echo(self.type);
		end
	end
end
--设置箭头是否显示
function HouseNode:ShowArrowTip(bShow)
	if(self.miniRootNode)then
		self.miniRootNode:SetVisible(bShow);
		
		local node = self.miniRootNode:GetChild(1);
		if(node)then
			local x,y,z = self:GetAbsCometoPosition();
			node:SetPosition(x,y,z);
			local facing = self:GetFacing();
			node:SetFacing(facing);
		end
	end
end
--关联 室外--室内 模型
function HouseNode:GetLinkedHouse()
	return self.linked_node;
end
function HouseNode:SetLinkedHouse(node)
	self.linked_node = node;
end
--打开传送门
function HouseNode:OpenDoor()
	local uid = self:GetUID();
	self.registerNodes[uid] = self;
	self:ShowArrowTip(true)
	self:ReloadLoadPoint();
end
--关闭传送门
function HouseNode:CloseDoor()
	local uid = self:GetUID();
	self.registerNodes[uid] = "";
	self:ShowArrowTip(false)
end
--获取传送点的绝对坐标
--node = self or node = self.linked_node
function HouseNode:GetAbsCometoPosition(node)
	if(not node)then 
		node = self;
	end
	local pos_x,pos_y,pos_z = node:GetPosition();
	local point_position = node.cometo_point_position;
	if(point_position)then
		pos_x = pos_x + point_position.x;
		pos_y = pos_y + point_position.y;
		pos_z = pos_z + point_position.z;
	end
	return pos_x,pos_y,pos_z;
end
--获取返回点的绝对坐标
--node = self or node = self.linked_node
function HouseNode:GetAbsComeBackPosition(node)
	if(not node)then 
		node = self;
	end
	local pos_x,pos_y,pos_z = node:GetPosition();
	local point_position = node.comeback_point_position;
	if(point_position)then
		pos_x = pos_x + point_position.x;
		pos_y = pos_y + point_position.y;
		pos_z = pos_z + point_position.z;
	end
	return pos_x,pos_y,pos_z;
end
--timer 的更新
function HouseNode.TimerUpdate()
	local self = HouseNode;
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	local point = {x = x, y = y, z = z};
	if(self.registerNodes)then
		local uid,node;
		for uid,node in pairs(self.registerNodes) do
			if(node and node ~= "" and node.cometo_point_position)then
				local pos_x,pos_y,pos_z = node:GetAbsCometoPosition();
				local box = {
					pos_x = pos_x,
					pos_y = pos_y,
					pos_z = pos_z,
					obb_x = 4,
					obb_y = 4,
					obb_z = 4,
				}
				
				local result = CommonCtrl.Display.Util.ObjectsCreator.Contains(point,box,true);
				if(result)then
					if(node.ReadyGoFunc)then
						node.ReadyGoFunc(node);
					end
					return
				end
			end
		end
	end
end
function HouseNode.ClearAndResetGlobalData()
	--停止房屋入口的监听
	if(HouseNode.global_timer)then
		HouseNode.global_timer:Change();
	end
	--清空上一次的记录
	if(HouseNode.registerNodes)then
		HouseNode.registerNodes = {};
	end
	if(HouseNode.global_timer)then
		HouseNode.global_timer:Change(0, 1000);
	end
end