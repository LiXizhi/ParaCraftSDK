--[[
Title: SpriteAnimation
Author(s): SunLingfeng @ paraengine.com
Date: 2008/1/29
Desc: SpriteAnimation is a sprite sheet player,
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/SpriteAnimation_control.lua");
------------------------------------------------------------
]]

local SpriteAnimation = {
	name = "spAnimPlayer",
	prent = nil,
	
	spriteSheet = nil,
	bInvertAanimation = false,
	bRepeat = false,
	
	frames = {},
	totalFrame = 16,
	activeFrame = 1,
	textureSize = 512,
	frameSize = 256,
	playSpeed = 2,
	startFrame = 1,
	defaultFrame = 1,
	
	playState = 1,  --1 play,2 pause,3 stop
	
	onAnimEnd = nil,
};
	
function SpriteAnimation:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	CommonCtrl.AddControl(o.name,o);
	return o;
end

function SpriteAnimation:Show(bShow)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		else
			self:CreateUI();
		end
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
	
	if(_this.visible == false)then
		self:Stop();
	end
end

function SpriteAnimation:Play()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid()==false)then
		return;
	end
	
	_this.onframemove = string.format(";CommonCtrl.SpriteAnimation.OnFrameMove(%q)",self.name);
	_this.background = self.spriteSheet;
	self:SetFrameByIndex(1);
end

function SpriteAnimation:Stop()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		--cancel updating
		_this.onframemove = nil;
	end
	--set play state
	self.playState = 3;
end

function SpriteAnimation:Pause()
	if(self.playState == 1)then
		self.playState = 2;
	end	
end

function SpriteAnimation:SetSpriteSheet(fileName)
	self.spriteSheet = fileName;
end

function SpriteAnimation:CreateFrames(texWidth,texHeight,frameWidth,frameHeight,frameCount)
	local frameCountX = texWidth/frameWidth;
	local frameCountY = texHeight/frameHeight;
	for i = 0,(frameCount-1) do
		self.frames[i+1] = math.mod(i,frameCountX)*frameWidth.." "..math.floor(i/frameCountY)*frameHeight..
			frameWidth.." "..frameHeight;
	end	
end

function SpriteAnimation:SetPlaySpeed(playSpeed)

end

--@frameIndex: int;
function SpriteAnimation:ShowFrameByIndex(frameIndex)
	if(self.frames[frameIndex] == nil)then
		return;
	end
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end
	
	_this:GetTexture("background").rect = self.frames[frameIndex];
end

--update frame
function SpriteAnimation:ShowNextFrame()
	if(self.bInvertAanimation)then
		self.activeFrame = self.activeFrame - 1;
		if(self.activeFrame < 1)then
			self.activeFrame = self.totalFrame;
		end
	else
		self.activeFrame = math.mode(self.activeFrame,self.totalFrame) + 1;
	end
	self:ShowFrameByIndex(self.activeFrame);
end

--set default frame index, default frame will be display before and after play,default is 1;
--@frameIndex: int;
function SpriteAnimation:SetDefaultFrame(frameIndex)
	self.defaultFrame = frameIndex;
end

--set animation start frame index,default value is 1;
--@frameIndex: int;
function SpriteAnimation:SetStartFrame(frameIndex)
	self.startFrame = frameIndex;
end

--set parent control
 --@param parent: paraUIObject;
function SpriteAnimation:SetParent(parent)
	self.parent = parent;
end

--============private======================
function SpriteAnimation:CreateUI()
	local _this = ParaUI.CreateUIObject("container",self.name,"_fi",0,0,0,0);
	_this.enabled = false;
	if(self.parent == nil)then
		_this:AttachToRoot()
	else
		self.parent:AddChild(_this);
	end
end

function SpriteAnimation.OnFrameMove(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	--return if play state is pause
	if(self.playState == 2)then
		return;
	end
	
	self:ShowNextFrame();
end
