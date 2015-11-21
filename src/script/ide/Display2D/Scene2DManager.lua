--[[
Title: Scene2DManager
Author(s): Leio
Date: 2009/7/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/Scene2DManager.lua");
local root_sprite = CommonCtrl.Display2D.Scene2DManager.GetSingletonRootSprite();
local canmove = true;
local cursor = CommonCtrl.Display2D.Bitmap2D:new{
	x = 0,
	y = 0,
	width = 50,
	height = 50,
	alpha = 1,
	rotation = 0,
	bg = "Texture/Aries/Inventory/MainPanel.png",
}
root_sprite:AddChild(cursor);

local sprite = CommonCtrl.Display2D.Sprite2D:new();
sprite:OnInit()
local bitmap = CommonCtrl.Display2D.Bitmap2D:new{
	x = 0,
	y = 0,
	width = 50,
	height = 50,
	alpha = 1,
	rotation = 0,
	bg = "Texture/Aries/Inventory/MainPanel.png",
}
sprite:AddChild(bitmap);

local text = CommonCtrl.Display2D.TextField2D:new{
	x = 200,
	y = 200,
	width = 100,
	height = 100,
	text = "aaaaadasdfsadfsdfsd",
}
sprite:AddChild(text);

local btn = CommonCtrl.Display2D.Button2D:new{
	text = "aaaaadasdfsadfsdfsd",
}
btn:OnInit();
sprite:AddChild(btn);
root_sprite:AddChild(sprite);

local bitmap2 = CommonCtrl.Display2D.Bitmap2D:new{
	x = 100,
	y = 100,
	width = 100,
	height = 40,
	alpha = 1,
	rotation = 0,
	bg = "Texture/Aries/Inventory/MountAttr.png;0 0 32 18:12 8 12 8",
}
bitmap2:AddEventListener("MouseOver",nil,function(holder,args)
	--commonlib.echo(args);
	--bitmap2:SetAlpha(0.5);
	bitmap2:SetBG("Texture/Aries/Inventory/MountAttrSlot.png;0 0 32 18:12 8 12 8");
end);
bitmap2:AddEventListener("MouseOut",nil,function(holder,args)
	--commonlib.echo(args);
	--bitmap2:SetAlpha(1);
	bitmap2:SetBG("Texture/Aries/Inventory/MountAttr.png;0 0 32 18:12 8 12 8");
end);
bitmap2:AddEventListener("MouseMove",nil,function(holder,args)
	--commonlib.echo(args);
end);
bitmap2:AddEventListener("MouseDown",nil,function(holder,args)
	--commonlib.echo(args);
	bitmap2:SetBG("Texture/Aries/Inventory/MountAttr.png;0 0 32 18:12 8 12 8");
	--bitmap2:SetAlpha(0.5);
	
end);
bitmap2:AddEventListener("MouseUp",nil,function(holder,args)
	--commonlib.echo(args);
	--bitmap2:SetAlpha(1);
	bitmap2:SetBG("Texture/Aries/Inventory/MountAttrSlot.png;0 0 32 18:12 8 12 8");
	CommonCtrl.Display2D.Scene2DManager.DestroySingletonRootScene();
end);
root_sprite:AddChild(bitmap2);

local stage = CommonCtrl.Display2D.Scene2DManager:GetStage();
if(stage)then
	stage:AddEventListener("MouseOver",nil,function(holder,args)
		canmove = true;
	end);
	stage:AddEventListener("MouseOut",nil,function(holder,args)
		canmove = false;
	end);
	stage:AddEventListener("EnterFrame",nil,function(holder,args)
		if(args and canmove)then
			cursor:SetPosition(args.mouse_x - cursor.width * 0.5,args.mouse_y - cursor.height * 0.5);
		end
	end);
end

------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display2D/DisplayObject2D.lua");
NPL.load("(gl)script/ide/Display2D/Sprite2D.lua");
NPL.load("(gl)script/ide/Display2D/Bitmap2D.lua");
NPL.load("(gl)script/ide/Display2D/TextField2D.lua");
NPL.load("(gl)script/ide/Display2D/Button2D.lua");
local Scene2DManager ={
	nodes = {},
	enableMouseEventNodes = {},
	stage = nil,
	cursor_sprite = nil,
	--每一个sprite可以最大容纳child的数量
	capacity_cell = 1000,
}  
commonlib.setfield("CommonCtrl.Display2D.Scene2DManager",Scene2DManager);
function Scene2DManager.GetSingletonRootSprite()
	local self = Scene2DManager;
	local root_scene = self.GetSingletonRootScene();
	if(root_scene)then
		return root_scene.child_sprite;
	end
end
function Scene2DManager.GetSingletonRootCursor()
	local self = Scene2DManager;
	local root_scene = self.GetSingletonRootScene();
	if(root_scene)then
		return root_scene.cursor_sprite;
	end
end
function Scene2DManager.GetSingletonRootScene()
	local self = Scene2DManager;
	local name = "Scene2DManager.GetSingletonRootScene";
	local root = self.CreateOrGetRootScene(name);
	self.AllMouseEnabled(true);
	return root;
end
function Scene2DManager.DestroySingletonRootScene()
	local self = Scene2DManager;
	local name = "Scene2DManager.GetSingletonRootScene";
	self.DestroyRootScene(name)
	self.AllMouseEnabled(false);
end
--创建一个root
function Scene2DManager.CreateOrGetRootScene(name)
	local self = Scene2DManager;
	if(not self.nodes[name])then
		local sprite = CommonCtrl.Display2D.Sprite2D:new();
		sprite:OnInit()
		sprite:SetUID(name);
		
		local child_sprite = CommonCtrl.Display2D.Sprite2D:new();
		child_sprite:OnInit();
		sprite:AddChild(child_sprite);
		
		local cursor_sprite = CommonCtrl.Display2D.Sprite2D:new();
		cursor_sprite:OnInit();
		sprite:AddChild(cursor_sprite);
		
		local render_container = ParaUI.CreateUIObject("container", name, "_fi", 0,0,0,0);
		render_container.onframemove = string.format(";CommonCtrl.Display2D.Scene2DManager.OnEnterFrame('%s');",name);
		render_container.background = "";
		render_container:AttachToRoot();
		
		self.nodes[name] = {sprite = sprite,child_sprite = child_sprite,cursor_sprite = cursor_sprite, render_container = render_container,capturedByMouse = nil,};
	end
	CommonCtrl.Display2D.Scene2DManager.SetMouseEnabled(name,true);
	--self.ReBuildCursor(name);
	if(not self.stage)then
		self.stage = CommonCtrl.Display2D.Sprite2D:new();
		self.stage:OnInit();
		
		--self.stage:AddEventListener("MouseOver",nil,function(holder,args)
			--if(self.cursor_bitmap)then
				--
			--end
		--end);
		--self.stage:AddEventListener("MouseOut",nil,function(holder,args)
		--end);
		--self.stage:AddEventListener("EnterFrame",nil,function(holder,args)
			--if(self.cursor_bitmap)then
				--self.cursor_bitmap:SetPosition(args.mouse_x - self.cursor_bitmap.width * 0.5,args.mouse_y - self.cursor_bitmap.height * 0.5);
			--end
		--end);
	end
	
	return self.nodes[name];
end
function Scene2DManager.DestroyRootScene(name)
	local self = Scene2DManager;
	if(self.nodes[name])then
		ParaUI.Destroy(name);
		self.nodes[name] = nil;
		self.stage = nil;
		self.cursor_bitmap = nil;
		CommonCtrl.Display2D.Scene2DManager.SetMouseEnabled(name,false);
	end
end
function Scene2DManager.GetStage()
	local self = Scene2DManager;
	return self.stage;
end
--获取child所属的场景
function Scene2DManager.GetRootScene(child)
	local self = Scene2DManager;
	if(not child)then return end
	local root = child:GetRoot();
	if(root)then
		local uid = root:GetUID();
		local root_scene = self.nodes[uid];
		return root_scene;
	end
end
function Scene2DManager.BuildNode(child)
	local self = Scene2DManager;
	if(not child)then return end
		local root_scene = self.GetRootScene(child);
		if(root_scene)then
			local render_container = root_scene.render_container;
			local root_sprite = root_scene.child_sprite;
			if(render_container)then
				local type = child:GetRenderType();
				local _this;
				if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Bitmap2D)then
					self.Build_Bitmap2D(child,render_container,root_sprite)
				elseif(type == CommonCtrl.Display2D.DisplayObject2DEnums.TextField2D)then
					self.Build_TextField2D(child,render_container,root_sprite)
				end
		end
	end
end
function Scene2DManager.Build_Bitmap2D(child,render_container)
	local self = Scene2DManager;
	if(not child or not render_container)then return end
	local isBuilded = child.isBuilded;
	if(not isBuilded)then
		child.isBuilded = true;
		local name = child:GetUID();
		local rect = child:GetRect();
		local left,top,width,height = rect:GetLTWH();
		local background = child:GetBG();
		_this = ParaUI.CreateUIObject("container", name, "_lt", left,top,width,height);
		_this.background = background;
		render_container:AddChild(_this);
		self.UpdateNode(child);
	end
end
function Scene2DManager.Build_TextField2D(child,render_container)
	local self = Scene2DManager;
	if(not child or not render_container)then return end
	local isBuilded = child.isBuilded;
	if(not isBuilded)then
		child.isBuilded = true;
		local name = child:GetUID();
		local rect = child:GetRect();
		local left,top,width,height = rect:GetLTWH();
		local text = child:GetText();
		_this = ParaUI.CreateUIObject("text", name, "_lt", left,top,width,height);
		_this.text = text;
		render_container:AddChild(_this);
		self.UpdateNode(child);
	end
end
function Scene2DManager.DestroyNode(child)
	local self = Scene2DManager;
	if(not child)then return end
	local uid = child:GetUID();
	child.isBuilded = false;
	ParaUI.Destroy(uid);
end
function Scene2DManager.UpdateNode(child)
	local self = Scene2DManager;
	local root_scene = self.GetRootScene(child);
	
	if(root_scene)then
		local _name = child:GetUID();
		local entity;
		local params = child:GetUpdateablePropertys();
		local type = child:GetRenderType();
		if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Bitmap2D or type == CommonCtrl.Display2D.DisplayObject2DEnums.TextField2D)then
			entity = ParaUI.GetUIObject(_name);
			if(entity and entity:IsValid())then
				if(params.visible == nil or params.visible == false)then
					entity.visible = false;
					return
				end
				entity.visible = true;
				if(tonumber(params.x))then
					entity.x = params.x;
				end
				if(tonumber(params.y))then
					entity.y = params.y;
				end
				if(tonumber(params.scalex))then
					entity.scalex = params.scalex;
				end
				if(tonumber(params.scaley))then
					entity.scaley = params.scaley;
				end
				if(tonumber(params.rotation))then
					entity.rotation = params.rotation;
				end	
				if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Bitmap2D)then	
					--Bitmap2D 特有的属性
					local color = string.format("%s %d",params.color or "255 255 255",math.floor( (params.alpha or 1) * 255));
					entity.color = color;
					if(tostring(params.bg))then
						entity.background = params.bg;
					end
				elseif(type == CommonCtrl.Display2D.DisplayObject2DEnums.TextField2D)then
					--TextField2D 特有的属性
					local text = params.text;
					if(tostring(text))then
						entity.text = text;
					end
				end
			end		
		end
	end
end
function Scene2DManager.SetMouseEnabled(sceneName,enabled)
	local self = Scene2DManager;
	self.enableMouseEventNodes[sceneName] = enabled;
end
function Scene2DManager.AllMouseEnabled(enabled)
	local self = Scene2DManager;
	local sceneName,v;
	for sceneName,v in pairs(self.enableMouseEventNodes) do
		self.enableMouseEventNodes[sceneName] = enabled;
	end
	if(enabled)then
		self.RegHook();
	else
		self.UnHook();
	end
end
function Scene2DManager.RegHook()
	local self = Scene2DManager;
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "Scene2DManager_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = Scene2DManager.OnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "Scene2DManager_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = Scene2DManager.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "Scene2DManager_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = Scene2DManager.OnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook(o);
end
function Scene2DManager.UnHook()
	local self = Scene2DManager;
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Scene2DManager_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Scene2DManager_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Scene2DManager_mouse_up_hook", hookType = hookType});
end
--[[
msg = {
  IsComboKeyPressed=false,
  IsMouseDown=true,
  MouseDragDist={ x=0, y=0 },
  dragDist=0,
  lastMouseDown={ x=583, y=492 },
  lastMouseUpTime=0,
  lastMouseUp_x=0,
  lastMouseUp_y=0,
  mouse_button="left",
  mouse_x=583,
  mouse_y=492,
  virtual_key=150,
  wndName="mouse_down" 
}
--]]
function Scene2DManager.OnMouseDown(nCode, appName, msg)
	local self = Scene2DManager;
	local name,v
	local point = {x = msg.mouse_x, y = msg.mouse_y};
	if(self.stage)then
		self.stage:OnMouseDown(msg);
	end
	for name,v in pairs(self.nodes) do
		if(self.enableMouseEventNodes[name])then
			local node = v;
			if(node and node.child_sprite)then
				local root_sprite = node.child_sprite;
				local new_captured,new_captured_list = self.GetChildAtPoint(point,root_sprite);
				node.capturedByMouse = new_captured;
				node.captured_list = new_captured_list;
				if(new_captured)then
					self.BeepMouseEvent(new_captured_list,"OnMouseDown",msg)
				end
			end
		end
	end
	return nil;
end
function Scene2DManager.OnMouseMove(nCode, appName, msg)
	local self = Scene2DManager;
	local name,v
	local point = {x = msg.mouse_x, y = msg.mouse_y};
	if(self.stage)then
		self.stage:OnMouseMove(msg);
		local _root = ParaUI.GetUIObject("root");
		local x, y, width, height = _root:GetAbsPosition();
		local isover = self.stage.isover;
		if(point.x < 0 or point.y < 0 or point.x > width or point.y > height)then
			if(isover)then
				self.stage:OnMouseOut(msg);
				self.stage.isover = false;
			end
		elseif(point.x >= 0 and point.y >= 0 and point.x <= width and point.y <= height)then
			if(not isover)then
				self.stage:OnMouseOver(msg);
				self.stage.isover = true;
			end
		end
	end
	for name,v in pairs(self.nodes) do
		if(self.enableMouseEventNodes[name])then
			local node = v;
			if(node and node.child_sprite)then
				local root_sprite = node.child_sprite;
				local old_captured = node.capturedByMouse;
				local new_captured,new_captured_list = self.GetChildAtPoint(point,root_sprite);
				node.capturedByMouse = new_captured;
				
				local old_captured_list = node.captured_list;
				node.captured_list = new_captured_list;
				
				if(old_captured and new_captured ~= old_captured)then
					old_captured:OnMouseOut(msg);
					
					self.BeepMouseEvent(old_captured_list,"OnMouseOut",msg)
				end
				if(new_captured and new_captured ~= old_captured)then
					--new_captured:OnMouseOver(msg);
					self.BeepMouseEvent(new_captured_list,"OnMouseOver",msg)
				end
				if(new_captured)then
					--new_captured:OnMouseMove(msg);
					--self.BeepMouseEvent(new_captured_list,"OnMouseMove",msg)
				end
			end
		end
	end
	return nil;
end
function Scene2DManager.BeepMouseEvent(result,type,msg)
	if(not result)then return end
	local k,node;
	for k,node in ipairs(result) do
		if(type == "OnMouseOut")then
			node:OnMouseOut(msg);
		elseif(type == "OnMouseOver")then
			node:OnMouseOver(msg);
		elseif(type == "OnMouseDown")then
			node:OnMouseDown(msg);
		elseif(type == "OnMouseUp")then
			node:OnMouseUp(msg);
		end
	end
end
function Scene2DManager.OnMouseUp(nCode, appName, msg)
	local self = Scene2DManager;
	local name,v
	local point = {x = msg.mouse_x, y = msg.mouse_y};
	if(self.stage)then
		self.stage:OnMouseUp(msg);
	end
	for name,v in pairs(self.nodes) do
		if(self.enableMouseEventNodes[name])then
			local node = v;
			if(node and node.child_sprite)then
				--local root_sprite = node.child_sprite;
				--local new_captured = node.capturedByMouse;
				--if(new_captured)then
					--new_captured:OnMouseUp(msg);
				--end
				
				local root_sprite = node.child_sprite;
				local new_captured,new_captured_list = self.GetChildAtPoint(point,root_sprite);
				node.capturedByMouse = new_captured;
				node.captured_list = new_captured_list;
				if(new_captured)then
					self.BeepMouseEvent(new_captured_list,"OnMouseUp",msg)
				end
			end
		end
	end
	return nil;
end
function Scene2DManager.OnEnterFrame(sName)
	local self = Scene2DManager;
	local mouse_x, mouse_y = ParaUI.GetMousePosition();
	local msg = {
		mouse_x = mouse_x,
		mouse_y = mouse_y,
	}
	if(self.stage)then
		self.stage:OnEnterFrame(msg);
	end
	for name,v in pairs(self.nodes) do
		local node = v;
		if(node and node.child_sprite and name == sName)then
			local root_sprite = node.child_sprite;
			if(root_sprite)then
				root_sprite:OnEnterFrame(msg);
			end
		end
	end
end
--point 是一个全局坐标
--找出最上层的child
function Scene2DManager.GetChildAtPoint(point,sprite)
	if(not point or not sprite)then return end
	local result = {};
	sprite:GetObjectsUnderPoint(point,result);
	return result[1],result
end
function Scene2DManager.ReBuildCursor(name)
	local self = Scene2DManager;
	local cursor_sprite = self.nodes[name].cursor_sprite;
	if(self.cursor_bitmap and cursor_sprite)then
		cursor_sprite:RemoveChild(self.cursor_bitmap);
	end
	self.cursor_bitmap = CommonCtrl.Display2D.Bitmap2D:new{
			x = 250,
			y = 0,
			width = 20,
			height = 20,
			alpha = 1,
			rotation = 0,
			bg = "Texture/Aries/Inventory/MainPanel.png",
		}
	cursor_sprite:AddChild(self.cursor_bitmap);
end