--[[
Title: Storyboard
Author(s): Leio Zhang
Date: 2009/3/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/Storyboard.lua");
local storyboard = CommonCtrl.Storyboard.Storyboard:new();
storyboard:SetDuration(50);
storyboard.OnPlay = function(s)
end
storyboard.OnUpdate = function(s)
end
storyboard.OnEnd = function(s)
	storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(50);
	storyboard:Play();
end
storyboard:Play();
------------------------------------------------------------
--]]
local Storyboard={};
commonlib.setfield("CommonCtrl.Storyboard.Storyboard",Storyboard);

local Storyboard = {
    _isPlaying = false,
    _frame = 0,
    _duration = 0, 
    isInit = false,
    _framerate = 33,
    _elapsedtime = 0,
    AllPlaying_Storyboard = {},
    HookDisplayObjs = {},
    _scene = nil,
    
    OnPlay = nil,
    OnUpdate = nil,
    OnEnd = nil,
}
commonlib.setfield("CommonCtrl.Storyboard.Storyboard",Storyboard);

function Storyboard.AddHookObj(name,obj)
	Storyboard.HookDisplayObjs[name] = obj;
end	
function Storyboard.GetHookObj(name)
	return Storyboard.HookDisplayObjs[name];
end	
function Storyboard.CreatEnterFrame()
	local enterFrameBeacon = ParaUI.GetUIObject("Storyboard__enterFrameBeacon__");
	if(not enterFrameBeacon:IsValid()) then 
		enterFrameBeacon = ParaUI.CreateUIObject("container","Storyboard__enterFrameBeacon__","_lt",0,0,0,0);	
		enterFrameBeacon.background="";
		enterFrameBeacon.enabled = false;
		enterFrameBeacon:AttachToRoot();
		enterFrameBeacon.onframemove = ";CommonCtrl.Storyboard.Storyboard.EnterFrameHandler();";
	end	
	Storyboard.enterFrameBeacon = enterFrameBeacon
end
function Storyboard.EnterFrameHandler()
	local AllPlaying_Storyboard = Storyboard.AllPlaying_Storyboard;
	local name, enabled
	for name,enabled in pairs(AllPlaying_Storyboard) do
		if(enabled)then
			local anim = CommonCtrl.GetControl(name);
			if(anim)then
				anim._elapsedtime = anim._elapsedtime + deltatime;
				if(anim._elapsedtime >= 1/anim:GetFramerate() ) then
					anim._elapsedtime = anim._elapsedtime - (1/anim:GetFramerate());
					anim:Update();
				end	
			end
		end
	end	
	local temp = {};
	local name,enabled;
	for name,enabled in pairs(AllPlaying_Storyboard)do
		if(not enabled)then
			table.insert(temp,name);
		end
	end
	local k,_name;
	for k,_name in ipairs(temp) do
		if(AllPlaying_Storyboard[_name])then
			AllPlaying_Storyboard[_name] = nil;
		end
	end
end
-- 存储用于创建动画的displayobject 的专用Scene
function Storyboard.GetScene()
	if(not Storyboard._scene)then
		NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
		local scene = CommonCtrl.Display.Containers.MiniScene:new()
		scene:Init();
		Storyboard._scene = scene;		
	end
	return Storyboard._scene;
end
function Storyboard:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	
	return o
end
function Storyboard:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	self.childrenList = {};
	Storyboard.CreatEnterFrame();
	CommonCtrl.AddControl(self.name,self);
end	
function Storyboard:AddChild(child)
	if(not child)then return; end
	table.insert(self.childrenList,child);
	child._parent = self;
    self:UpdateDuration()
end
function Storyboard:UpdateDuration()
	local k,v;
	local maxDuration = 0;
	for k,v in ipairs(self.childrenList) do
		local child = v;
		-- layer's update before below update
		child:UpdateDuration();
		local d = child:GetDuration();
		if(d>maxDuration)then
			maxDuration = d;
		end
	end
	if(maxDuration > self:GetDuration())then
		self:SetDuration(maxDuration);
	end
end
function Storyboard:SetDuration(d)
	self._duration = d;
end
function Storyboard:GetDuration()
	return self._duration;
end
function Storyboard:GetFramerate()
	return self._framerate;
end
function Storyboard:DoPrePlay()
	local k,v;
	for k,v in ipairs(self.childrenList) do
		local child = v;
		child:DoPrePlay();
	end	
end
function Storyboard:Play()
	self._isPlaying = true;
	self._frame = -1;
	self:DoPrePlay();
	Storyboard.AllPlaying_Storyboard[self.name] = true;
	if(self.OnPlay)then
		self.OnPlay(self);
	end
end 
function Storyboard:End()
	self._isPlaying = false;
	Storyboard.AllPlaying_Storyboard[self.name] = false;
	if(self.OnEnd)then
		self.OnEnd(self);
	end
end 
function Storyboard:Update()
	--commonlib.echo({self._frame,self._duration});
	if(self._frame < self._duration)then
		self._frame = self._frame + 1;
		local k,v;
		for k,v in ipairs(self.childrenList) do
			local child = v;
			child:Update(self._frame);
		end	
		if(self.OnUpdate)then
			self.OnUpdate(self);
		end		
	else
		self._frame = -1;
		self:End();
	end
end
function Storyboard:GetCurFrame()
	return self._frame;
end
function Storyboard:GetEffectInstance()
	return self.effectInstance;
end
-- this method will be used by EffectInstance
function Storyboard:SetEffectInstance(effect)
	if(not effect)then return end
	self.effectInstance = effect;
end
function Storyboard:ReplaceTargetName(oldName,newName)
	if(not oldName or not newName)then return end
	local k,v;
	for k,v in ipairs(self.childrenList) do
		v:ReplaceTargetName(oldName,newName)
	end
end