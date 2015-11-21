--[[
Title: TweenLite
Author(s): Leio Zhang
Date: 2009/9/1
Desc: Based on Flash Tweener Actionscript library 

use the lib:
------------------------------------------------------------
-----------------------2d test
local instance_id = "test";
local c = ParaUI.CreateUIObject("container",instance_id,"_lt",100,100,100,100);
local btn = ParaUI.CreateUIObject("button","","_lt",0,0,100,100);
c:AddChild(btn);
c:AttachToRoot();

NPL.load("(gl)script/ide/Transitions/TweenLite.lua");
local tween=CommonCtrl.TweenLite:new{
	instance_id = instance_id,
	type = "2d",-- "2d" or "3d" or "3dd"
	direction = "to", -- "to" or "from",default is "to"
	duration = 500,-- millisecond
	delay = 0,-- millisecond
	props = {
		--translationx = 200,
		--translationy = 200,
		scalingx = 2,
		scalingy = 2,
		--width = 300,
		--height = 300,
		alpha = 0.1,
		--rotation = 10,
	},
	OnStartFunc = function(self)
		
	end,
	OnUpdateFunc = function(self)
	
	end,
	OnEndFunc = function(self)
	
	end,
	ease_func = CommonCtrl.TweenEquations.easeInQuad,
}
tween:Start();
--tween:Stop();
tween:End();
-----------------------3d test
local x,y,z = ParaScene.GetPlayer():GetPosition();
local obj = ObjEditor.CreateObjectByParams({
	name = "test_obj",
	AssetFile = "model/06props/shared/pops/muzhuang.x",
	x = x,
	y = y,
	z = z,
});
ParaScene.Attach(obj)

local instance_id = obj:GetID();
NPL.load("(gl)script/ide/Transitions/TweenLite.lua");
local tween=CommonCtrl.TweenLite:new{
	instance_id = instance_id,
	type = "3d",-- "2d" or "3d" or "3dd"
	direction = "to", -- "to" or "from",default is "to"
	duration = 500,-- millisecond
	delay = 0,-- millisecond
	props = {
		x = 200,
		y = 2,
		z = 300,
		scaling = 2,
		facing = 0.1,
	},
	OnStartFunc = function(self)
	
	end,
	OnUpdateFunc = function(self)
	
	end,
	OnEndFunc = function(self)
	
	end,
	ease_func = CommonCtrl.TweenEquations.easeInQuad,
}
tween:Start();
-----------------------3d node test
local x,y,z = ParaScene.GetPlayer():GetPosition();

NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local scene = CommonCtrl.Display3D.SceneManager:new();
local rootNode = CommonCtrl.Display3D.SceneNode:new{
	root_scene = scene,
}
local container_node = CommonCtrl.Display3D.SceneNode:new{
	node_type = "container",
	x = x,
	y = y,
	z = z,
};
local node_1 = CommonCtrl.Display3D.SceneNode:new{
	x = 0,
	y = 0,
	z = 0,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
local node_2 = CommonCtrl.Display3D.SceneNode:new{
	x = 0,
	y = 2,
	z = 0,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
container_node:AddChild(node_1);
container_node:AddChild(node_2);
rootNode:AddChild(container_node);

NPL.load("(gl)script/ide/Transitions/TweenLite.lua");
local tween=CommonCtrl.TweenLite:new{
	node = container_node,
	type = "3dd",-- "2d" or "3d" or "3dd"
	direction = "to", -- "to" or "from",default is "to"
	duration = 500,-- millisecond
	delay = 0,-- millisecond
	props = {
		--x = 255,
		--y = 2,
		--z = 255,
		--scaling = 2,
		facing = 2,
	},
	OnStartFunc = function(self)
	
	end,
	OnUpdateFunc = function(self)
	
	end,
	OnEndFunc = function(self)
	
	end,
	ease_func = CommonCtrl.TweenEquations.easeInQuad,
}
tween:Start();
-----------------------only a time line
NPL.load("(gl)script/ide/Transitions/TweenLite.lua");
local tween=CommonCtrl.TweenLite:new{
	duration = 500,-- millisecond
	OnStartFunc = function(self)
		commonlib.echo({"OnStartFunc",self:GetRunTime()});
	end,
	OnUpdateFunc = function(self)
		commonlib.echo({"OnUpdateFunc",self:GetRunTime()});
	end,
	OnEndFunc = function(self)
		commonlib.echo({"OnEndFunc",self:GetRunTime()});
	end,
}
tween:Start();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/Transitions/TweenEquations.lua");
NPL.load("(gl)script/ide/Transitions/TweenUtil.lua");
if(not CommonCtrl )then CommonCtrl={};end
local	TweenLite = {
	type = "2d", --"2d" or "3d" or "3dd"
	instance_id = nil,-- 在type = "2d"  or type = "2d" 时候有效
	node = nil,-- 在type = "3dd" 时候有效
	direction = "to",
	duration = 500,--毫秒
	delay = 0,
	AllPlaying_TweenLite = {},
	TweenLite_Map = {},
	ApplyAnim = nil,
	ease_func = CommonCtrl.TweenEquations.easeNone,
	}
CommonCtrl.TweenLite = TweenLite;
function TweenLite.CreatEnterFrame()
	local enterFrameBeacon = ParaUI.GetUIObject("TweenLite__enterFrameBeacon__");
	if(not enterFrameBeacon:IsValid()) then 
		enterFrameBeacon = ParaUI.CreateUIObject("container","TweenLite__enterFrameBeacon__","_lt",0,0,0,0);	
		enterFrameBeacon.background="";
		enterFrameBeacon.enabled = false;
		enterFrameBeacon:AttachToRoot();
		enterFrameBeacon.onframemove = ";CommonCtrl.TweenLite.EnterFrameHandler();";
	end	
end
function TweenLite.EnterFrameHandler()
	local AllPlaying_TweenLite = TweenLite.AllPlaying_TweenLite;
	local temp = {};
	local name,enabled;
	for name,enabled in pairs(AllPlaying_TweenLite)do
		if(not enabled)then
			table.insert(temp,name);
		end
	end
	local k,_name;
	for k,_name in ipairs(temp) do
		if(AllPlaying_TweenLite[_name])then
			AllPlaying_TweenLite[_name] = nil;
		end
	end
	
	local name, enabled
	for name,enabled in pairs(AllPlaying_TweenLite) do
		if(enabled)then
			local anim = TweenLite.TweenLite_Map[name];
			if(anim)then
				anim:Update();
			end
		end
	end	
	
end
function TweenLite:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function TweenLite:Init()
	self.name = ParaGlobal.GenerateUniqueID();
end
function TweenLite:Start()
	self.tween_prop = {};
	if(self.props)then
		local p,target
		for p,target in pairs(self.props) do
			if(p and type(p) == "string" and target)then
				-- create a instance of TweenProperty 
				local a = CommonCtrl.TweenProperty:new{
					instance_id = self.instance_id,
					node = self.node,
					type = self.type,
					prop = p,
					target = target,
					direction = self.direction,
					ApplyAnim = self.ApplyAnim,
				}
				table.insert(self.tween_prop,a);
			end
		end
	end
	TweenLite.AllPlaying_TweenLite[self.name] = true;	
	TweenLite.TweenLite_Map[self.name] = self;
	self.pause = false;
	self.timer = ParaGlobal.GetGameTime();	
	TweenLite.CreatEnterFrame();
	--start
	if(self.OnStartFunc)then
		self.OnStartFunc(self);
	end
end
function TweenLite:GetRunTime()
	local t = math.min(self.duration, math.max(0, ParaGlobal.GetGameTime() - self.timer - self.delay));
	return t;
end
function TweenLite:IsStarted()
	return self.timer and (self:GetRunTime() > 0);
end
function TweenLite:IsPlaying()
	return (self:IsStarted() and not self.pause and not self:IsFinished());
end
function TweenLite:IsFinished()
	return self.timer and (self.duration == self:GetRunTime());
end
function TweenLite:Update()
	if(self:IsPlaying())then
		 self:_Update();
		 --update
		 if(self.OnUpdateFunc)then
			self.OnUpdateFunc(self);
		end
	elseif(self:IsFinished())then
		 self:_Update();
		TweenLite.AllPlaying_TweenLite[self.name] = false;	
		TweenLite.TweenLite_Map[self.name] = nil;
		--end
		if(self.OnEndFunc)then
			self.OnEndFunc(self);
		end
	end
end
function TweenLite:_Update()
	if(self.tween_prop)then
			local k,p;
			for k,p in ipairs(self.tween_prop) do
				if(p and p.Update)then
					p:Update(self.ease_func,self:GetRunTime(),self.duration);
				end
			end
	end
end
-- stop at first frame
function TweenLite:Stop()
	TweenLite.AllPlaying_TweenLite[self.name] = false;	
	TweenLite.TweenLite_Map[self.name] = nil;
	self:Pause();
	if(self.tween_prop)then
		local k,p;
		for k,p in ipairs(self.tween_prop) do
			if(p and p.Update)then
				p:Update(self.ease_func,0,self.duration);
			end
		end
	end
end
-- stop at last frame
function TweenLite:End()
	TweenLite.AllPlaying_TweenLite[self.name] = false;	
	TweenLite.TweenLite_Map[self.name] = nil;
	self:Pause();
	if(self.tween_prop)then
		local k,p;
		for k,p in ipairs(self.tween_prop) do
			if(p and p.Update)then
				p:Update(self.ease_func,self.duration,self.duration);
			end
		end
	end
	if(self.OnEndFunc)then
		self.OnEndFunc(self);
	end
end
function TweenLite:Pause()
	self.pause = true;
end

function TweenLite:IsPaused()
	return self.pause;
end

function TweenLite:Resume()
	self.pause = false;
end
--------------------------------------------------
--TweenProperty
--------------------------------------------------
local	TweenProperty = {
	type = "2d", --"2d" or "3d" or "3dd"
	instance_id = nil,-- 在type = "2d"  or type = "2d" 时候有效
	node = nil,-- 在type = "3dd" 时候有效
	direction = "to", -- "to" or "from"
	prop = nil,
	initial = nil,
	target = nil,
	change = nil,
	duration = nil,
	ApplyAnim = nil,
}
CommonCtrl.TweenProperty = TweenProperty;
function TweenProperty:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end
function TweenProperty:Update(ease_func,runtimed,duration)
	if(not self.initial)then
		self.initial = self:GetValue();
		if(self.direction == "from")then
			--互换初始值和结束值
			local temp = self.initial;
			self.initial = self.target;
			self.target = temp;
		end
		if(self.initial)then
			self.change = self.target - self.initial;
		else
			--commonlib.echo(self.prop);
		end
	end
	if(not ease_func or not runtimed or not self.initial or not self.change or not duration)then return end
	if(runtimed == duration)then
		self:SetValue(self.target);
	else
		local v = ease_func( runtimed , self.initial , self.change , duration );
		self:SetValue(v);
	end
end
function TweenProperty:GetValue()
	if(self.type == "2d")then
		local obj = ParaUI.GetUIObject(self.instance_id);
		if(obj and obj:IsValid())then
			if(self.prop == "alpha")then
				local color = obj.colormask;
				local color_t = {};
				local i = 1;
				for c in string.gfind(color,"[^%s+]+")do
					color_t[i] = tonumber(c);
					i = i + 1;
				end
				local a = color_t[4] or 255
				return a/255;
			else
				return obj[self.prop];
			end
		end
	elseif(self.type == "3d")then
		local obj = ParaScene.GetObject(self.instance_id);
		if(obj and obj:IsValid())then
			if(self.prop == "x" or self.prop == "y" or self.prop == "y")then
				local x,y,z = obj:GetPosition();
				local t = {
					x = x,y = y,z = z,
				};
				return t[self.prop];
			elseif(self.prop == "facing")then
				return obj:GetFacing();
			elseif(self.prop == "scaling")then
				return obj:GetScale();
			end
		end
	elseif(self.type == "3dd")then
		local node = self.node;
		if(not node)then return end
			return node[self.prop];
	end
end
function TweenProperty:SetValue(v)
	if(self.type == "2d")then
		local obj = ParaUI.GetUIObject(self.instance_id);
		if(obj and obj:IsValid())then
			if(self.prop == "alpha")then
				local color = obj.colormask;
				local color_t = {};
				local i = 1;
				for c in string.gfind(color,"[^%s+]+")do
					color_t[i] = tonumber(c);
					i = i + 1;
				end
				color = string.format("%d %d %d %d",color_t[1],color_t[2],color_t[3],v * 255);
				-- commonlib.echo({setcolor = color})
				obj.colormask = color;
			else
				obj[self.prop] = v;
			end
			if(self.ApplyAnim == true) then
				obj:ApplyAnim();
			end
		end
	elseif(self.type == "3d")then
		local obj = ParaScene.GetObject(self.instance_id);
		if(obj and obj:IsValid())then
			if(self.prop == "x" or self.prop == "y" or self.prop == "y")then
				local x,y,z = obj:GetPosition();
				local t = {
					x = x,y = y,z = z,
				};
				t[self.prop] = v;
				obj:SetPosition(t.x,t.y,t.z);
			elseif(self.prop == "facing")then
				obj:SetFacing(v);
			elseif(self.prop == "scaling")then
				obj:SetScale(v);
			end
		end
	elseif(self.type == "3dd")then
		local node = self.node;
		if(not node or not node.UpdateEntity)then return end
		node[self.prop] = v;
		node:UpdateEntity();
	end
end