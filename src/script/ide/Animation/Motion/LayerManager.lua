--[[
Title: LayerManager
Author(s): Leio Zhang
Date: 2008/10/15
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/LayerManager.lua");
------------------------------------------------------------
--]]
local LayerManager = {
	_parent = nil,
	_index = 0,
	_frame = 0,
	_duration = 1,
	_curMovieClip = nil,
}
commonlib.setfield("CommonCtrl.Animation.Motion.LayerManager",LayerManager);
function LayerManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()
	return o
end
function LayerManager:Initialization()
	self.name = ParaGlobal.GenerateUniqueID();
	self.ClipList = {};
end
---------------------------------------------------------
-- public  property
---------------------------------------------------------
function LayerManager:GetPath()
	if(not self._parent)then
		return self._index;
	else
		return self._parent:GetPath() .. "#" .. self._index;
	end
end
---------------------------------------------------------
-- private  method
---------------------------------------------------------
function LayerManager:UpdateDuration()
	local k,v;
	self:SetDuration(1);
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		if(clip)then
			-- clip's update before below update
			clip:UpdateDuration();
			local d = self:GetDuration();
			d = d + clip:GetDuration();
			self:SetDuration(d);
		end
	end
end
---------------------------------------------------------
-- public  method
---------------------------------------------------------
function LayerManager:AddChild(clip,index)
	if(not clip)then return; end
	local len = #self.ClipList + 1;
	if(index == nil or index > len)then
		index = len;
	end
	commonlib.insertArrayItem(self.ClipList, index, clip)
	clip._parent = self;
	clip._parentName = self.name;
	self:ResetIndex();
    self:UpdateDuration();
end
-- no test
function LayerManager:RemoveChild(clip)
	if(not clip)then return; end
	local k,v;
	for k,v in ipairs(self.ClipList) do
		if(clip == v)then
			self:RemoveLayerByIndex(k)
		end
	end
end
-- no test
function LayerManager:RemoveChildByIndex(index)
	if(not index)then return; end
	local len = table.getn(self.ClipList);
	if(index>len)then return ; end
	table.remove(self.ClipList,index);
	
    self:ResetIndex()
    self:UpdateDuration();
end
function LayerManager:ResetIndex()
	local k,v;
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		clip._index = k - 1;
	end
end
function LayerManager:GetChild(index)
	if(not index)then return; end
	return self.ClipList[index];
end
-- return clip,gotoFrame :gotoFrame is clip will play
function LayerManager:GetCurMovieClip()
	local k,v;
	local frame = self:GetFrame();
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		local d = clip:GetDuration();
		frame = frame - d;
		if(frame < 0)then		
			local gotoFrame = d + frame;
			return clip,gotoFrame;
		end
	end
end
-- @param checkIsPlaying: if checkIsPlaying is true that only return clips which are playing
function LayerManager:GetMaybeLivingMovieClips(checkIsPlaying)
	local result = {};
	local frame = 0;
	local k,v;
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		if(frame <=self:GetFrame())then
			if(checkIsPlaying)then
				if(clip:GetIsPlaying())then
					table.insert(result,clip);
				end
			else	
				table.insert(result,clip);
			end
		end
		frame = frame + clip:GetDuration();
	end
	return result;
end
function LayerManager:GetPlayInfo(state)
	local result = "";
	local s = "";
	local k,v;
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		s = clip:GetPlayInfo(state);
		result = result .. s.."\r\n";
	end
	return result;
end
function LayerManager:Draw()
	local _this = ParaUI.GetUIObject("container"..self.name);
	if(_this:IsValid())then
		ParaUI.Destroy("container"..self.name);
	end
	_this=ParaUI.CreateUIObject("container","container"..self.name,"_fi",0,0,0,0);
	if(self._uiParent==nil) then
			_this:AttachToRoot();
	else
		self._uiParent:AddChild(_this);
	end
	_this.background = "";
	local _parent = _this;
	local const_width,const_height = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameWidth,
								CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameHeight;	
	local left,top,width,height = 0,
								0,
								const_width,
								const_height;
								
	local len = table.getn(self.ClipList);
	for kk,vv in ipairs(self.ClipList) do
				local clip = vv;
				local i= 1;
				local dur = 0;
				if(kk>1)then
					for i=1,kk-1 do
						local _tempCLip = self.ClipList[i];
						dur = dur + _tempCLip:GetDuration();
					end
				end
				left,top,width,height = dur*const_width,top,clip:GetDuration()*const_width,const_height;
				_this=ParaUI.CreateUIObject("container","clip"..kk,"_lt",left,top,width,height);
				_this.background = "";
				_parent:AddChild(_this);
				clip._uiParent = _this;
				clip.MovieClipEditorName = self.MovieClipEditorName;
				clip:Draw();
	end		
end
--------------------------------------------------------------------------------------
-- below is implement IAnimator
--------------------------------------------------------------------------------------
---------------------------------------------------------
-- public  property
---------------------------------------------------------
function LayerManager:GetLastFrame()
	return self._lastFrame;
end
function LayerManager:SetFrame(frame)
	self._frame = frame;
	local clip,gotoFrame = self:GetCurMovieClip();
	local k,v;
	if(self._curMovieClip ~= clip and clip and gotoFrame and clip:GetIsPlaying()==false)then	
		self._curMovieClip = clip;
		--clip:Play();
		--commonlib.echo(gotoFrame);
		clip:GotoAndPlay(gotoFrame);
		self._curMovieClip = clip;
	end
	--self:GotoAndStop(frame)
	self._lastFrame = frame;
end
function LayerManager:GetFrame()
	return self._frame;
	
end
function LayerManager:SetDuration(d)
	self._duration = d;
end
function LayerManager:GetDuration()
	return self._duration;
end
--function LayerManager:SetRepeatCount(d)
	--self._repeatCount = d;
--end
--function LayerManager:GetRepeatCount()
	--return self._repeatCount;
--end
--function LayerManager:SetIsPlaying(d)
	--self._isPlaying = d;
--end
--function LayerManager:GetIsPlaying()
	--return self._isPlaying;
--end
--function LayerManager:SetAutoRewind(d)
	--self._autoRewind = d;
--end
--function LayerManager:GetAutoRewind()
	--return self._autoRewind;
--end
function LayerManager:SetTimer(d)
	self._timer = d;
end
function LayerManager:GetTimer()
	return self._timer;
end
function LayerManager:SetFramerate(d)
	self._framerate = d;
end
function LayerManager:GetFramerate()
	return self._framerate;
end
---------------------------------------------------------
-- private  method
---------------------------------------------------------

---------------------------------------------------------
-- public  method
---------------------------------------------------------
function LayerManager:ReSet()
	self._curMovieClip = nil;
	self._lastFrame = 0;
	local k,v;
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		clip:ReSet();
	end
end
function LayerManager:Pause()
	local clips = self:GetMaybeLivingMovieClips(true);
	self.Temp_clips = clips;
	 for k,v in ipairs(clips) do
		local clip = v;
		clip:Pause();
	 end
end
function LayerManager:Resume()
	if(self.Temp_clips)then
		for k,v in ipairs(self.Temp_clips) do
			local clip = v;
			clip:Resume();
		end
		self.Temp_clips = nil;
	end
end
-- Stops the animation and Player goes back to the first frame in the animation sequence.
function LayerManager:Stop()
	local k,v;
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		s = clip:Stop();
	end
	self.Temp_clips = nil;
end
-- Stops the animation and Player goes immediately to the last frame in the animation sequence. 
-- If the AutoRewind property is set to true, Player goes to the first
function LayerManager:End()
	local k,v;
	for k,v in ipairs(self.ClipList) do
		local clip = v;
		s = clip:End();
	end
	self.Temp_clips = nil;
end
function LayerManager:GotoAndPlay(frame)
	 if (frame < 0) then return; end
	 self.Temp_clips = nil;
	 self._frame = frame;
	 local clips = self:GetMaybeLivingMovieClips(true);
	 local len = table.getn(clips);
	 if(len==0)then return; end
	 self._curMovieClip = nil;
	 local k,v;
	 for k,v in ipairs(clips) do
		local clip = v;
		local d = clip:GetDuration();
		local gotoFrame;
		if(d<=0)then
			gotoFrame = 0;
		else
			gotoFrame = math.mod(frame,d);
		end
		clip:GotoAndPlay(gotoFrame);
	 end
end
function LayerManager:GotoAndStop(frame)
	if (frame < 0) then return; end
	self.Temp_clips = nil;
	self._frame = frame;
	 local clips = self:GetMaybeLivingMovieClips(false);
	 local len = table.getn(clips);
	 if(len==0)then return; end
	 self._curMovieClip = nil;
	 local k,len = 1,table.getn(clips);
	 for k=1,len-1 do
		local clip = clips[k];
		if(clip)then
			clip:End();
		end
	 end
	 local clipLast,gotoFrame = self:GetCurMovieClip();
	 if(clipLast and gotoFrame)then
		clipLast:GotoAndStop(gotoFrame);
	 end
end  
function LayerManager:AddTimerListener()
	
end
function LayerManager:RemoveTimerListener()
	 for k,v in ipairs(self.ClipList) do
		local clip = v;
		clip:RemoveTimerListener();
	 end
end
function LayerManager:ReplaceTargetName(oldName,newName)
	if(not oldName or not newName)then return end
	local k,v;
	for k,v in ipairs(self.ClipList) do
		v:ReplaceTargetName(oldName,newName)
	end
end