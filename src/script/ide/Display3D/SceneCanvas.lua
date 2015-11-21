--[[
Title: A scene manger container with mouse event handlers
Author(s): Leio
Date: 2009/11/4
Desc: Scene canvas is a scene manager container that can process mouse events. 
use the lib:
SceneCanvas 主要封装了鼠标事件，MouseDown MouseUp 只支持左键
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/SceneCanvas.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local sceneManager = CommonCtrl.Display3D.SceneManager:new();
local rootNode = CommonCtrl.Display3D.SceneNode:new{
	root_scene = sceneManager,
}
local canvas = CommonCtrl.Display3D.SceneCanvas:new{
	rootNode = rootNode,
	sceneManager = sceneManager,
}
local node_1 = CommonCtrl.Display3D.SceneNode:new{
	x = 255,
	y = 0,
	z = 255,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
rootNode:AddChild(node_1);
local node_2 = CommonCtrl.Display3D.SceneNode:new{
	x = 255,
	y = 3,
	z = 255,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
rootNode:AddChild(node_2);

function showSelected(event,bShow)
	if(event and event.currentTarget)then
		local currentTarget = event.currentTarget;
		local obj = ParaScene.GetObject(id);
		if(obj and obj:IsValid())then
			if(bShow)then
				ParaSelection.AddObject(obj,1);
			else
				ParaSelection.AddObject(obj,-1);
			end
		end
	end
end
function dragNode(canvas,node,bDrag)
	if(canvas and node)then
		if(bDrag)then
			canvas:StartDrag(node);
		else
			canvas:StopDrag(node);
		end
	end
end
function doMouseOver(self,event)
	--commonlib.echo("==========doMouseOver");
	--showSelected(event,true);
end
function doMouseOut(self,event)
	--commonlib.echo("==========doMouseOut");
	--showSelected(event,false);
end
function doMouseDown(self,event)
	commonlib.echo("==========doMouseDown");
	dragNode(canvas,node_2,true);
end
function doMouseUp(self,event)
	commonlib.echo("==========doMouseUp");
end
function doMouseMove(self,event)
	--commonlib.echo("==========doMouseMove");
end
function doChildSelected(self,event)
	commonlib.echo("==========doChildSelected");
	showSelected(event,true);
end
function doChildUnSelected(self,event)
	commonlib.echo("==========doChildUnSelected");
	showSelected(event,false);
end
function doMouseDown_Stage(self,event)
	commonlib.echo("==========doMouseDown_Stage");
	--dragNode(canvas,node_2,true);
end
function doMouseUp_Stage(self,event)
	commonlib.echo("==========doMouseUp_Stage");
	dragNode(canvas,node_2,false);
end
function doMouseMove_Stage(self,event)
	--commonlib.echo("==========doMouseMove_Stage");
end
canvas:AddEventListener("mouse_over",doMouseOver);
canvas:AddEventListener("mouse_out",doMouseOut);
canvas:AddEventListener("mouse_down",doMouseDown);
canvas:AddEventListener("mouse_up",doMouseUp);
canvas:AddEventListener("mouse_move",doMouseMove);
canvas:AddEventListener("stage_mouse_down",doMouseDown_Stage);
canvas:AddEventListener("stage_mouse_up",doMouseUp_Stage);
canvas:AddEventListener("stage_mouse_move",doMouseMove_Stage);
canvas:AddEventListener("child_selected",doChildSelected);
canvas:AddEventListener("child_unselected",doChildUnSelected);

-- newly added
canvas:AddEventListener("stage_mouse_down_right",doMouseDown_Stage);
canvas:AddEventListener("stage_mouse_up_right",doMouseUp_Stage);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local SceneCanvas = {
	uid = nil,
	rootNode = nil,
	sceneManager = nil,
	event_pools = nil,
	objIDWithMouse = nil,--鼠标检测到的物体的id
	selectedObjID = nil,--选中的物体的id
	dragMirrorNode = true,--拖拽的物体是否是镜像
	mirrorSceneManager = nil,--镜像场景管理
	mirrorRootNode = nil,--镜像node根节点
	bReallyDrag = nil,--是否是真实拖拽
	reallyNode = nil,--记录拖拽的真实node
	picking_filter = nil, -- the picking filter to use
	
	globalHookEnabled = false,
	HookList = {},--全局hook
	
	--事件的发送者currentTarget只是一个single node,它是一个entity的描述
	MOUSE_DOWN = "mouse_down",
	MOUSE_UP = "mouse_up",
	MOUSE_OVER = "mouse_over",
	MOUSE_OUT = "mouse_out",
	MOUSE_MOVE = "mouse_move",
	CHILD_SELECTED = "child_selected",
	CHILD_UNSELECTED = "child_unselected",
	
	STAGE_MOUSE_DOWN = "stage_mouse_down",
	STAGE_MOUSE_UP = "stage_mouse_up",
	--STAGE_MOUSE_OVER = "stage_mouse_over",--TODO:需要知道鼠标是否 超出边界
	--STAGE_MOUSE_OUT = "stage_mouse_out",--TODO:需要知道鼠标是否 超出边界
	STAGE_MOUSE_MOVE = "stage_mouse_move",
}
commonlib.setfield("CommonCtrl.Display3D.SceneCanvas",SceneCanvas);
function SceneCanvas:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function SceneCanvas:Init()
	local uid = ParaGlobal.GenerateUniqueID();
	if(not self.globalHookEnabled)then
		self.globalHookEnabled = true;
		--启动全局hook
		self.GlobalRegHook();
	end
	--使鼠标事件有效
	self:RegHook();
	--镜像node管理，在drag时用到
	self.mirrorSceneManager = CommonCtrl.Display3D.SceneManager:new{
		type = "miniscene" --"scene" or "miniscene"
	};
	self.mirrorRootNode = CommonCtrl.Display3D.SceneNode:new{
		root_scene = self.mirrorSceneManager,
	}
	--事件池子
	self.event_pools = {};
end
function SceneCanvas:ClearAll()
	self:UnHook();
	self.event_pools = {};
	if(self.rootNode)then
		self.rootNode:Detach();
	end
	if(self.mirrorRootNode)then
		self.mirrorRootNode:Detach();
	end
end

-- set the picking filter. only object that pass the filter can be selected. 
-- @param filter: string name of the filter to be used.  if nil, it defaults to pick everything. 
-- "4294967295" means everything. One can also pick by physics group, "p:1" means only pick for physics group 0.
function SceneCanvas:SetPickingFilter(filter)
	self.picking_filter = filter;
end

-------------------------------------
--事件函数
-------------------------------------
--注册一个事件
--@param type:事件类型
--@param func:监听函数
--@param funcHolder:监听函数的拥有者，可以为空
function SceneCanvas:AddEventListener(type,func,funcHolder)
	if(not type or not func)then return end		
	if(self.event_pools)then
		self.event_pools[type] = {func = func,funcHolder = funcHolder};
	end
end
--取消一个事件
function SceneCanvas:RemoveEventListener(type)
	if(not type)then return end
	if(self.event_pools)then
		self.event_pools[type] = nil;
	end
end
--是否已经注册了事件
function SceneCanvas:HasEventListener(type)
	if(not type)then return end
	if(self.event_pools)then
		if(self.event_pools[type])then 
			return true;
		end
	end
end
--触发事件
--@param event:事件参数 event = {type = "mousedown" ,args = ...};
function SceneCanvas:DispatchEvent(event)
	if(not event)then return end
	if(self.event_pools)then
		local type = event.type;
		local listener = self.event_pools[type]
		if(listener)then
			local func = listener.func;
			local funcHolder = listener.funcHolder;
			func(funcHolder,event)
		end
	end
end
--清空所有的事件
function SceneCanvas:ClearEventPools()
	self.event_pools = {};
end

function SceneCanvas:RegHook()
	self.HookList[self] = true;
end	
function SceneCanvas:UnHook()
	self.HookList[self] = nil;
end
--直接发送 node选中事件
function SceneCanvas:DirectDispatchChildSelectedEvent(node)
	if(node)then
		--diapatch event
		self:DispatchEvent({
			type = "child_unselected",
			msg = {
				mouse_button = "left",
			},
			currentTarget = nil,
		});
		--diapatch event
		self:DispatchEvent({
			type = "child_selected",
			msg = {
				mouse_button = "left",
			},
			currentTarget = node,
		});
		local entity = node:GetEntity();
		if(entity)then
			self.selectedObjID = entity:GetID();
		end
	end
end
--处理鼠标事件
function SceneCanvas:OnMouseUp(msg,canReturn)
	--只支持左键, right click is now supported but without object picking. 
	if(not msg)then return end
	if(msg.mouse_button ~= "left") then
		-------------------------------------
		--stage mouse up
		-------------------------------------
		self:DispatchEvent({
			type = "stage_mouse_up_right",
			msg = msg,
			canReturn = canReturn,--canReturn.value = true or false,判断是否通过mouse hook
		});

	elseif(self.sceneManager and self.rootNode)then
		local oldSelectedObjID = self.selectedObjID;
		local newSelectedObjID = self.sceneManager:MousePickID(self.picking_filter);
		-------------------------------------
		--child selected
		-------------------------------------
		--unselected
		if(oldSelectedObjID and oldSelectedObjID ~= newSelectedObjID)then
			local node = self.rootNode:GetChildByEntityID(oldSelectedObjID);
			if(node)then
				--diapatch event
				self:DispatchEvent({
					type = "child_unselected",
					msg = msg,
					currentTarget = node,
				});
			end
		end
		--selected
		if(newSelectedObjID and oldSelectedObjID ~= newSelectedObjID)then
			local node = self.rootNode:GetChildByEntityID(newSelectedObjID);
			if(node)then
				--diapatch event
				self:DispatchEvent({
					type = "child_selected",
					msg = msg,
					currentTarget = node,
				});
			end
		end	
		self.selectedObjID = newSelectedObjID;
		-------------------------------------
		--child mouse up
		-------------------------------------
		local node = self.rootNode:GetChildByEntityID(newSelectedObjID);
		if(node)then
				--diapatch event
				self:DispatchEvent({
					type = "mouse_up",
					msg = msg,
					currentTarget = node,
				});
			--canReturn.value = false;
		end
		self.objIDWithMouse = newSelectedObjID;
		
		-------------------------------------
		--stage mouse up
		-------------------------------------
		self:DispatchEvent({
			type = "stage_mouse_up",
			msg = msg,
			canReturn = canReturn,--canReturn.value = true or false,判断是否通过mouse hook
			currentTarget = node,
		});
	end
	
end
--处理鼠标事件
function SceneCanvas:OnMouseMove(msg)
	if(not msg)then return end
	if(self.sceneManager and self.rootNode)then
		local oldObjID = self.objIDWithMouse;
		local newObjID = self.sceneManager:MousePickID(self.picking_filter);
		--mouse leave
		if(oldObjID and oldObjID ~= newObjID)then
			local node = self.rootNode:GetChildByEntityID(oldObjID);
			if(node)then
				--diapatch event
				self:DispatchEvent({
					type = "mouse_out",
					msg = msg,
					currentTarget = node,
				});
			end
		end
		--mouse over
		if(newObjID and oldObjID ~= newObjID)then
			local node = self.rootNode:GetChildByEntityID(newObjID);
			if(node)then
				--diapatch event
				self:DispatchEvent({
					type = "mouse_over",
					msg = msg,
					currentTarget = node,
				});
			end
		end
		--mouse move
		if(newObjID)then
			local node = self.rootNode:GetChildByEntityID(newObjID);
			if(node)then
				--diapatch event
				self:DispatchEvent({
					type = "mouse_move",
					msg = msg,
					currentTarget = node,
				});
			end
		end
		self.objIDWithMouse = newObjID;
		
		--drag node
		if(self.dragNode)then
			local pt = ParaScene.MousePick(70, "walkpoint");	
			if(pt:IsValid())then
				local x,y,z = pt:GetPosition();
				self.dragNode:SetPosition(x,y,z);	
			end
		end
	end
	-------------------------------------
	--stage mouse move
	-------------------------------------
	self:DispatchEvent({
		type = "stage_mouse_move",
		msg = msg,
	});
end

--处理鼠标事件
function SceneCanvas:OnMouseDown(msg,canReturn)
	--只支持左键, right button is supported via a different event handler "stage_mouse_down_right"
	if(not msg)then return end
	if(self.sceneManager and self.rootNode)then
		local newObjID = self.sceneManager:MousePickID(self.picking_filter);
		local node = self.rootNode:GetChildByEntityID(newObjID);
		if(msg.mouse_button == "left") then
			if(node)then
					--diapatch event
					self:DispatchEvent({
						type = "mouse_down",
						msg = msg,
						currentTarget = node,
					});
				
				canReturn.value = false;
			end
			self.objIDWithMouse = newObjID;
			-------------------------------------
			--stage mouse down
			-------------------------------------
			self:DispatchEvent({
				type = "stage_mouse_down",
				msg = msg,
				canReturn = canReturn,--canReturn.value = true or false,判断是否通过mouse hook
				currentTarget = node,
			});
		else
			self:DispatchEvent({
					type = "stage_mouse_down_right",
					msg = msg,
					canReturn = canReturn,--canReturn.value = true or false,判断是否通过mouse hook
					currentTarget = node,
				});
		end
	end
	
end
-------------------------------------
--拖拽
-------------------------------------
--@param reallyNode: 可以是single or container
--@param bReallyDrag: 默认为nil，即镜像拖拽
function SceneCanvas:StartDrag(reallyNode,bReallyDrag)
	if(not reallyNode)then return end
	--记录被drag的对象
	self.reallyNode = reallyNode;
	--是否是真实拖拽
	self.bReallyDrag = bReallyDrag;
	local dragNode;
	--如果是镜像拖拽
	if(not bReallyDrag)then
		--清空已有的镜像nodes
		self.mirrorRootNode:Detach();
		dragNode = reallyNode:Clone();
		if(self.mirrorRootNode and dragNode)then
			self.mirrorRootNode:AddChild(dragNode);
		end
		--隐藏真实的node
		reallyNode:SetVisible(false);
	else
		dragNode = reallyNode;
	end
	self.dragNode = dragNode;
end
--停止当前的拖拽
function SceneCanvas:StopDrag()
	if(self.dragNode)then
		--如果是镜像拖拽
		if(not self.bReallyDrag)then
			if(self.mirrorRootNode)then
				local x,y,z = self.dragNode:GetPosition();
				self.dragNode:Detach();
				--真实的node
				if(self.reallyNode and x and y and z)then
					--更新postion
					self.reallyNode:SetPosition(x,y,z);
					self.reallyNode:SetVisible(true);
				end
			end
		end
		self.reallyNode = nil;
		self.bReallyDrag = nil;
		self.dragNode = nil;
	end
end
-------------------------------------
--systyem hook
-------------------------------------
--全局hook鼠标事件
function SceneCanvas.GlobalRegHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "SceneCanvas_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = SceneCanvas.GlobalOnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "SceneCanvas_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = SceneCanvas.GlobalOnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "SceneCanvas_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = SceneCanvas.GlobalOnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook(o);
end
--全局unhook鼠标事件
function SceneCanvas.GlobalUnHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "SceneCanvas_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "SceneCanvas_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "SceneCanvas_mouse_up_hook", hookType = hookType});
end
function SceneCanvas.GlobalOnMouseUp(nCode, appName, msg)
	local self = SceneCanvas;
	local canReturn = {
		value = true;
	};
	if(self.HookList)then
		local k,v;
		for k,v in pairs(self.HookList) do
			if(k and k.OnMouseUp and v== true)then
				k:OnMouseUp(msg,canReturn);
			end			
		end
	end
	if(canReturn and canReturn.value)then
		return nCode;
	end
end
function SceneCanvas.GlobalOnMouseMove(nCode, appName, msg)
	local self = SceneCanvas;
	if(self.HookList)then
		local k,v;
		for k,v in pairs(self.HookList) do
			if(k and k.OnMouseMove and v== true)then
				k:OnMouseMove(msg);
			end			
		end
	end	
	return nCode;
end
function SceneCanvas.GlobalOnMouseDown(nCode, appName, msg)
	local self = SceneCanvas;
	local canReturn = {
		value = true;
	};
	if(self.HookList)then
		local k,v;
		for k,v in pairs(self.HookList) do
			if(k and k.OnMouseDown and v== true)then
				k:OnMouseDown(msg,canReturn);
			end			
		end
	end
	if(canReturn and canReturn.value)then
		return nCode;
	end
end