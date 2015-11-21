--[[
Title: UI Object Animation Instance
Author(s): WangTian
Date: 2007/11/1
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UIAnim/UIAnimInstance.lua");
-------------------------------------------------------

--NOTE: currently NOT used

]]

--NPL.load("(gl)script/ide/UIAnim/UIAnimBlock.lua");
NPL.load("(gl)script/ide/UIAnim/UIAnimIndex.lua");

if(not UIObjectAnimInstance) then UIObjectAnimInstance = {}; end

if(not UIObjectAnimInstance.AllObjects) then UIObjectAnimInstance.AllObjects = {}; end

UIObjectAnimInstance.AutoCounter = 1;


function UIObjectAnimInstance:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	--o.UIObjectName = 
	--o.UIObjectParentName = 
	
	o.NewAppendAnimate = true;
	o.ReadyToEnd = false;
	
	o.CurrentAnim = UIAnimIndex:new();
	o.NextAnim = UIAnimIndex:new();
	o.BlendingAnim = UIAnimIndex:new();
	o.nBlendingFactor = 0;
end

function UIObjectAnimInstance:Destroy()
	self.CurrentAnim:Destroy();
	self.CurrentAnim = nil;
	self.NextAnim:Destroy();
	self.NextAnim = nil;
	self.BlendingAnim:Destroy();
	self.BlendingAnim = nil;
	UIObjectAnimInstance.DeleteObject(self.name);
	self = nil; -- TODO: still not nil
end

function UIObjectAnimInstance.AddObject(ObjName, obj)
	UIObjectAnimInstance.AllObjects[ObjName] = obj;
end

function UIObjectAnimInstance.DeleteObject(ObjName)
	local obj = UIObjectAnimInstance.AllObjects[ObjName];
	if(obj ~= nil) then
		UIObjectAnimInstance.AllObjects[ObjName] = nil;
	end
end

function UIObjectAnimInstance:AdvanceTime(dTimeDelta)
	dTimeDelta = dTimeDelta * self.m_fSpeedScale;
	local m_CurrentAnim = self.CurrentAnim;
	local m_NextAnim = self.NextAnim;
	local m_BlendingAnim = self.BlendingAnim;
	local blendingFactor = self.nBlendingFactor;
	
	if(m_CurrentAnim) then
		if(m_CurrentAnim.nCurrentFrame < m_CurrentAnim.nStartFrame) then
			m_CurrentAnim.nCurrentFrame = m_CurrentAnim.nStartFrame;
		end
		if(m_CurrentAnim.nCurrentFrame > m_CurrentAnim.nEndFrame) then
			m_CurrentAnim.nCurrentFrame = m_CurrentAnim.nEndFrame;
		end
		local nToDoFrame = m_CurrentAnim.nCurrentFrame + dTimeDelta;
		
		-- blending factor is decreased
		if(blendingFactor > 0 ) then
			blendingFactor = blendingFactor - (dTimeDelta/100); -- BLENDING_TIME blending time
			if(blendingFactor < 0) then
				blendingFactor = 0;
			end
		end
		-- check if we have reached the end frame of the current animation
		if(nToDoFrame > m_CurrentAnim.nEndFrame) then
			nToDoFrame = nToDoFrame - (m_CurrentAnim.nEndFrame - m_CurrentAnim.nStartFrame); -- wrap to the beginning

			if(m_NextAnim) then
				-- if there is a queued animation, we will play that one.
				self:LoadAnimationByIndex(m_NextAnim);
				----if(m_NextAnim == m_CurrentAnim) then
					------ if the next animation is the same as the current one,force looping on the current animation
					----m_CurrentAnim.nCurrentFrame = nToDoFrame;
				----else
					------ play the next animation with motion blending with the current one.
					------ m_CurrentAnim.nCurrentFrame = m_CurrentAnim.nEndFrame; -- this is not necessary ?
					----self:LoadAnimationByIndex(m_NextAnim);
					------ m_CurrentAnim.nCurrentFrame = m_CurrentAnim.nStartFrame; -- this is not necessary ?
				----end
				---- empty the queue
				--m_NextAnim.MakeInvalid();
			else
				-- if there is NO queued animation, we will pop the animation instance off the animpool.
				
				-- TODO: pop the animation instance off the animation pool
				
				
				---- if there is NO queued animation, we will play the default one.
				--if(not m_CurrentAnim.IsLooping)
					---- non-looping, play the default idle animation
					--AnimIndex IdleAnimIndex = pModel->GetAnimIndexByID(GetIdleAnimationID());
					--if(m_CurrentAnim == IdleAnimIndex) then
						--m_CurrentAnim.nCurrentFrame = nToDoFrame;
					--else
						--LoadAnimationByIndex(IdleAnimIndex);
					--end
				--else
					---- looping on the current animation
					--m_CurrentAnim.nCurrentFrame = nToDoFrame;
				--end
			end
		else
			m_CurrentAnim.nCurrentFrame = nToDoFrame;
		end
	end
	
	
	
	
	
	
	--self.m_fSizeScale;
end