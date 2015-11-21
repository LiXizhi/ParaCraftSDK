--[[
Title: MovieClipBase
Author(s): Leio Zhang
Date: 2008/10/15
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/MovieClipBase.lua");
------------------------------------------------------------
--]]
local MovieClipBase = {
	_animator = nil,
	_parent = nil,
	_index = 0;
}
commonlib.setfield("CommonCtrl.Animation.Motion.MovieClipBase",MovieClipBase);
function MovieClipBase:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()
	return o
end
function MovieClipBase:Initialization()
	self.name = ParaGlobal.GenerateUniqueID();
	self.LayerList = {};
	
	self._animator = CommonCtrl.Animation.Motion.Animator:new();
	self._animator.MovieClipBase = self;
    self:Animator_AddEventListener();
    self._animator:SetMovieClipBase(self);
end
---------------------------------------------------------
-- public  property
---------------------------------------------------------
function MovieClipBase:GetPath()
	if(not self._parent)then
		return self._index;
	else
		return self._parent:GetPath() .. "/" .. self._index;
	end
end
function MovieClipBase:GetEffectInstance()
	return self.effectInstance;
end
-- this method will be used by EffectInstance
function MovieClipBase:SetEffectInstance(effect)
	if(not effect)then return end
	self.effectInstance = effect;
end
function MovieClipBase:GetRoot()
	local result = self;
	local parent = self._parent;
	while(parent)do
		result = parent;
		parent = parent._parent;
	end
	return result;
end
function MovieClipBase:SetMcPlayer(mcPlayer)
	self.mcPlayer = mcPlayer;
end
function MovieClipBase:GetMcPlayer()
	return self.mcPlayer;
end
---------------------------------------------------------
-- event
---------------------------------------------------------
function MovieClipBase:Animator_AddEventListener()
	 local animator = self._animator;
	 if(not animator)then return; end
     animator.MotionStart = CommonCtrl.Animation.Motion.MovieClipBase.MotionStart;
     animator.MotionPause = CommonCtrl.Animation.Motion.MovieClipBase.MotionPause;
     animator.MotionResume = CommonCtrl.Animation.Motion.MovieClipBase.MotionResume;
     animator.MotionStop = CommonCtrl.Animation.Motion.MovieClipBase.MotionStop;
     animator.MotionEnd = CommonCtrl.Animation.Motion.MovieClipBase.MotionEnd;
     animator.MotionTimeChange = CommonCtrl.Animation.Motion.MovieClipBase.MotionTimeChange;
end
function MovieClipBase.MC_MotionStart(mc)

end
function MovieClipBase.MC_MotionPause(mc)

end
function MovieClipBase.MC_MotionResume(mc)

end
function MovieClipBase.MC_MotionStop(mc)

end
function MovieClipBase.MC_MotionEnd(mc)

end
function MovieClipBase.MC_MotionTimeChange(mc)

end
---------------------------------------------------------
-- private  method
---------------------------------------------------------
function MovieClipBase:UpdateDuration()
	local k,v;
	local maxDuration = 1
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		-- layer's update before below update
		layer:UpdateDuration();
		local d = layer:GetDuration();
		if(d>maxDuration)then
			maxDuration = d;
		end
	end
	if(maxDuration > self:GetDuration())then
		self:SetDuration(maxDuration);
	end
end
---------------------------------------------------------
-- public  method
---------------------------------------------------------
function MovieClipBase:Draw()
	local _this = ParaUI.GetUIObject("container"..self.name);
	if(_this:IsValid())then
		ParaUI.Destroy("container"..self.name);
	end
	_this=ParaUI.CreateUIObject("container","container"..self.name,"_fi",0,0,0,0);
	_this.background = "";
	if(self._uiParent==nil) then
			_this:AttachToRoot();
	else
		self._uiParent:AddChild(_this);
	end
	local _parent = _this;
	local const_width,const_height = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameWidth,
								CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameHeight;	
		local left,top,width,height = 0,
								0,
								const_width,
								const_height;	
	
	for kk,vv in ipairs(self.LayerList) do
				local layer = vv;
				left,top,width,height = left,kk*height,layer:GetDuration()*const_width,const_height;
				_this=ParaUI.CreateUIObject("container","layer"..kk,"_lt",left,top,width,height);
				_this.background = "";
				_parent:AddChild(_this);
				layer._uiParent = _this;
				layer:Draw();
	end		
end
function MovieClipBase:AddChild(clip)
	if(not clip)then return; end
	local layer = self:GetLayer(1);
	if(not layer)then
		layer = CommonCtrl.Animation.Motion.LayerManager:new();
		self:AddLayer(layer,nil);
	end
	layer:AddChild(clip,nil);
	-- update again,because this layer now know clip's duration
    self:UpdateDuration()
end
function MovieClipBase:AddLayer(layer,index)
	if(not layer)then return; end
	local len = #self.LayerList + 1;
	if(index == nil or index > len)then
		index = len;
	end
	commonlib.insertArrayItem(self.LayerList, index, layer)
	layer._parent = self;
	layer._parentName = self.name;
    self:ResetIndex()
    self:UpdateDuration()
end
function MovieClipBase:ResetIndex()
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer._index = k - 1;
	end
end
-- no test
function MovieClipBase:RemoveLayer(layer)
	if(not layer)then return; end
	local k,v;
	for k,v in ipairs(self.LayerList) do
		if(layer == v)then
			self:RemoveLayerByIndex(k)
		end
	end
end
-- no test
function MovieClipBase:RemoveLayerByIndex(index)
	if(not index)then return; end
	local len = table.getn(self.LayerList);
	if(index>len)then return ; end
	table.remove(self.LayerList,index);
	
    self:ResetIndex()
end
function MovieClipBase:GetLayer(index)
	if(not index)then return; end
	return self.LayerList[index];
end
function MovieClipBase:GetPlayInfo(state)
	local result = "";
	local s = string.format("clip:%s %s ,%s,%s",self:GetPath(),state,self:GetFrame(),self:GetDuration());
	result = result .. s.."\r\n";
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		s = layer:GetPlayInfo(state);
		result = result .. s.."\r\n";
	end
	return result;
end
function MovieClipBase:GetAllChildInfo()
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		local path = layer:GetPath();
		commonlib.echo(path);
		commonlib.echo("------------");
		for kk,vv in ipairs(layer.ClipList) do
			local clip = vv;
			local clip_path = clip:GetPath();
			commonlib.echo(clip_path);
			commonlib.echo("++++++++++++++");
			clip:GetAllChildInfo();
		end
	end
end
--------------------------------------------------------------------------------------
-- below is implement IAnimator
--------------------------------------------------------------------------------------
---------------------------------------------------------
-- event
---------------------------------------------------------
function MovieClipBase.MotionStart(animator)
	if(not animator)then return; end;
	local self = animator.MovieClipBase;
	if(not self)then return; end	
	self:Debug("MotionStart");
	
	self.MC_MotionStart(self);
end
function MovieClipBase.MotionPause(animator)
	if(not animator)then return; end;
	local self = animator.MovieClipBase;
	if(not self)then return; end
	self:Debug("MotionPause");
	
	self.MC_MotionPause(self);
end
function MovieClipBase.MotionResume(animator)
	if(not animator)then return; end;
	local self = animator.MovieClipBase;
	if(not self)then return; end
	self:Debug("MotionResume");
	
	self.MC_MotionResume(self);
end
function MovieClipBase.MotionStop(animator)
	if(not animator)then return; end;
	local self = animator.MovieClipBase;
	if(not self)then return; end
	self:Debug("MotionStop");
	local frame = self._animator:GetFrame();
	self:SetFrame(frame);
	
	self.MC_MotionStop(self);
end
function MovieClipBase.MotionEnd(animator)
	if(not animator)then return; end;
	local self = animator.MovieClipBase;
	if(not self)then return; end
	self:Debug("MotionEnd");
	local frame = self._animator:GetFrame();
	self:SetFrame(frame);
	
	self.MC_MotionEnd(self);
end
function MovieClipBase.MotionTimeChange(animator)
	if(not animator)then return; end;
	local self = animator.MovieClipBase;
	if(not self)then return; end
	self:Debug("MotionTimeChange");
	local frame = self._animator:GetFrame();
	-- need to call self.LayerList which child will play
	self:SetFrame(frame);
	
	self.MC_MotionTimeChange(self);
end
function MovieClipBase:Debug(state)
	--local s = string.format("%s,%s,%s",self:GetFrame(),self:GetDuration(),state);
	--local s = self:GetPlayInfo(state);
	--commonlib.echo(s);
end
---------------------------------------------------------
-- public  property
---------------------------------------------------------
function MovieClipBase:UpdateTime(frame)

end
function MovieClipBase:GetLastFrame()
	return self._animator:GetLastFrame();
end
function MovieClipBase:SetFrame(frame)
	if(not frame)then return; end
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:SetFrame(frame);
	end
	
	self:UpdateTime(frame)
end
function MovieClipBase:GetFrame()
	return self._animator:GetFrame();
end
function MovieClipBase:SetDuration(d)
	self._animator:SetDuration(d)
end
function MovieClipBase:GetDuration()
	return self._animator:GetDuration()
end
function MovieClipBase:SetRepeatCount(d)
	self._animator:SetRepeatCount(d)
end
function MovieClipBase:GetRepeatCount()
	return self._animator:GetRepeatCount();
end
function MovieClipBase:SetIsPlaying(d)
	self._animator:SetIsPlaying(d)
end
function MovieClipBase:GetIsPlaying()
	return self._animator:GetIsPlaying()
end
function MovieClipBase:SetAutoRewind(d)
	self._animator:SetAutoRewind(d)
end
function MovieClipBase:GetAutoRewind()
	return self._animator:GetAutoRewind()
end
function MovieClipBase:SetTimer(d)
	self._animator:SetTimer(d)
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:SetTimer(d);
	end
end
function MovieClipBase:GetTimer()
	return self._animator:GetTimer()
end
function MovieClipBase:SetFramerate(d)
	self._animator:SetFramerate(d)
end
function MovieClipBase:GetFramerate()
	return self._animator:GetFramerate()
end      
---------------------------------------------------------
-- public  method
---------------------------------------------------------
function MovieClipBase:ReSet()
	self._animator:ReSet()
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:ReSet();
	end
end
-- Begins the animation. Call the <code>end()</code> method 
-- before you call the <code>play()</code> method to ensure that any previous 
-- instance of the animation has ended before you start a new one.
function MovieClipBase:Play()
	self:ReSet();
	self._animator:Play()	
end        
-- Pauses the animation until you call the <code>resume()</code> method.
function MovieClipBase:Pause()
	self._animator:Pause()
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:Pause();
	end
end
-- Resumes the animation after it has been paused.
function MovieClipBase:Resume()
	self._animator:Resume()
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:Resume();
	end
end
-- Stops the animation and Player goes back to the first frame in the animation sequence.
function MovieClipBase:Stop()
	self._animator:Stop()
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:Stop();
	end
end
-- Stops the animation and Player goes immediately to the last frame in the animation sequence. 
-- If the AutoRewind property is set to true, Player goes to the first
function MovieClipBase:End()
	self._animator:End()
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:End();
	end
end
function MovieClipBase:GotoAndPlay(frame)
	self._animator:GotoAndPlay(frame)
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:GotoAndPlay(frame);
	end
end
function MovieClipBase:GotoAndStop(frame)
	self._animator:GotoAndStop(frame)
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:GotoAndStop(frame);
	end
end       
   
function MovieClipBase:AddTimerListener()
	 --  needn't to AddTimerListener here,beacuse all animators will auto AddTimerListener when are play
end
function MovieClipBase:RemoveTimerListener()
	-- make sure all animators is stop
	this._animator:RemoveTimerListener();
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:RemoveTimerListener();
	end
end
function MovieClipBase:ReplaceTargetName(oldName,newName)
	if(not oldName or not newName)then return end
	local k,v;
	for k,v in ipairs(self.LayerList) do
		local layer = v;
		layer:ReplaceTargetName(oldName,newName)
	end
end