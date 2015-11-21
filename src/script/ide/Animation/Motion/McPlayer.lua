--[[
Title: McPlayer
Author(s): Leio Zhang
Date: 2008/10/20
Desc: give a power to a MovieClip and control its playing state
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/McPlayer.lua");
------------------------------------------------------------
--]]
local McPlayer  = {
	Clip = nil,
	enterFrameBeacon = nil,
	Player = nil,
	McPlayerPool = {},
}
commonlib.setfield("CommonCtrl.Animation.Motion.McPlayer",McPlayer);
function McPlayer:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()
	return o
end
function McPlayer:Initialization()
	self.name = ParaGlobal.GenerateUniqueID();
	self:CreatEnterFrame();
end
function McPlayer:CreatEnterFrame()
	local enterFrameBeacon = ParaUI.GetUIObject(self.name.."McPlayer__enterFrameBeacon__");
	if(not enterFrameBeacon:IsValid()) then 
		enterFrameBeacon = ParaUI.CreateUIObject("container",self.name.."McPlayer__enterFrameBeacon__","_lt",0,0,0,0);	
		enterFrameBeacon.background="";
		enterFrameBeacon.enabled = false;
		enterFrameBeacon:AttachToRoot();
	end	
	self.enterFrameBeacon = enterFrameBeacon
end
function McPlayer:SetClip(clip)
	if(not clip)then return; end;
	if(self.Clip)then
		self:Stop()
	end
	clip:UpdateDuration();	
	self.Clip = clip;	
	clip:SetMcPlayer(self);
end
function McPlayer:Destroy()
	if(self.Clip)then
		self:Stop()
	end
	ParaUI.Destroy(self.name.."McPlayer__enterFrameBeacon__");
end
function McPlayer.EnterFrameHandler(mcPlayerName)
	-- see CommonCtrl.Animation.Motion.Animator
	--local AnimatorPool = CommonCtrl.Animation.Motion.AnimatorPool;
	--local name, anim
	--for name,anim in pairs(AnimatorPool) do
		--if(anim)then
			--anim._elapsedtime = anim._elapsedtime + deltatime;
			--if(anim._elapsedtime >= 1/anim:GetFramerate() ) then
				--anim._elapsedtime = anim._elapsedtime - (1/anim:GetFramerate());
				--anim:NextFrame();
			--end	
		--end
	--end		
	local mcPlayer = CommonCtrl.Animation.Motion.McPlayer.McPlayerPool[mcPlayerName];
	if(mcPlayer and mcPlayer.Clip and mcPlayer.Clip._animator)then
		local anim = mcPlayer.Clip._animator;
		anim._elapsedtime = anim._elapsedtime + deltatime;
		if(anim._elapsedtime >= 1/anim:GetFramerate() ) then
			--commonlib.echo({mcPlayerName,anim._elapsedtime});
			anim._elapsedtime = anim._elapsedtime - (1/anim:GetFramerate());
			anim:NextFrame();
		end	
	end
end
function McPlayer:Play()
	if(not self.Clip) then return; end
	self:TurnOnPower();
	self.Clip:Play();
end
function McPlayer:Pause()
	if(not self.Clip) then return; end
	self:TurnOffPower();
	self.Clip:Pause();
end
function McPlayer:Resume()
	if(not self.Clip) then return; end
	self:TurnOnPower();
	self.Clip:Resume();
end
function McPlayer:Stop()
	if(not self.Clip) then return; end
	self:TurnOffPower();
	self.Clip:Stop();
end
function McPlayer:End()
	if(not self.Clip) then return; end
	self:TurnOffPower();
	self.Clip:End();
end
function McPlayer:TurnOffPower()
	local enterFrameBeacon = ParaUI.GetUIObject(self.name.."McPlayer__enterFrameBeacon__");
	if(enterFrameBeacon:IsValid()) then
		self.enterFrameBeacon.onframemove = nil;
	else
		self:CreatEnterFrame();
		commonlib.echo("the mcplayer enterFrameBeacon not be found!");
	end
end
function McPlayer:TurnOnPower()
	local enterFrameBeacon = ParaUI.GetUIObject(self.name.."McPlayer__enterFrameBeacon__");
	if(enterFrameBeacon:IsValid()) then 
		self.enterFrameBeacon.onframemove = string.format(";CommonCtrl.Animation.Motion.McPlayer.EnterFrameHandler(%q);",self.name);
	else
		self:CreatEnterFrame();
		commonlib.echo("the mcplayer enterFrameBeacon not be found!");
	end
	CommonCtrl.Animation.Motion.McPlayer.McPlayerPool[self.name] = self;
end
function McPlayer:GotoAndStop(frame)
	if(not self.Clip) then return; end
	self:TurnOffPower();
	self.Clip:GotoAndStop(frame);
end