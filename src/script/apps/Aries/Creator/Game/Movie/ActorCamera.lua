--[[
Title: camera actor
Author(s): LiXizhi
Date: 2014/3/30
Desc: for recording and playing back of camera creation and editing. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorCamera.lua");
local ActorCamera = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorCamera");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/Actor.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/MultiAnimBlock.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieClipTimeLine.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CmdParser.lua");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");
local MovieClipTimeLine = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieClipTimeLine");
local MultiAnimBlock = commonlib.gettable("MyCompany.Aries.Game.Common.MultiAnimBlock");
local EntityCamera = commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityCamera")
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local CameraController = commonlib.gettable("MyCompany.Aries.Game.CameraController")

local Actor = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Movie.Actor"), commonlib.gettable("MyCompany.Aries.Game.Movie.ActorCamera"));

Actor.class_name = "ActorCamera";
-- default to none-fps mode, the lookat position is more smooth than FPS one. 
local default_fps_mode = 0;
-- take a key frame every 5 seconds. 
Actor.auto_record_interval = 5000;

function Actor:ctor()
end

function Actor:GetMultiVariable()
	if(self.multi_variable) then
		return self.multi_variable;
	else
		self.multi_variable = MultiAnimBlock:new();
		self.multi_variable:AddVariable(self:GetVariable("lookat_x"));
		self.multi_variable:AddVariable(self:GetVariable("lookat_y"));
		self.multi_variable:AddVariable(self:GetVariable("lookat_z"));
		self.multi_variable:AddVariable(self:GetVariable("eye_dist"));
		self.multi_variable:AddVariable(self:GetVariable("eye_liftup"));
		self.multi_variable:AddVariable(self:GetVariable("eye_rot_y"));
		return self.multi_variable;
	end
end

function Actor:BindItemStackToTimeSeries()
	self.multi_variable = nil;
	return Actor._super.BindItemStackToTimeSeries(self);
end

function Actor:Init(itemStack, movieclipEntity)
	if(not Actor._super.Init(self, itemStack, movieclipEntity)) then
		return;
	end

	local timeseries = self.TimeSeries;
	
	timeseries:CreateVariableIfNotExist("lookat_x", "Linear");
	timeseries:CreateVariableIfNotExist("lookat_y", "Linear");
	timeseries:CreateVariableIfNotExist("lookat_z", "Linear");
	timeseries:CreateVariableIfNotExist("eye_dist", "Linear");
	timeseries:CreateVariableIfNotExist("eye_liftup", "Linear");
	timeseries:CreateVariableIfNotExist("eye_rot_y", "LinearAngle");
	timeseries:CreateVariableIfNotExist("is_fps", "Discrete");
	timeseries:CreateVariableIfNotExist("has_collision", "Discrete");
	
	-- get initial position from itemStack, if not exist, we will use movie clip entity's block position. 
	local movieClip = self:GetMovieClip();
	if(movieClip) then
		local x, y, z = movieClip:GetOrigin();
		y = y + BlockEngine.blocksize;

		x = self:GetValue("lookat_x", 0) or x;
		y = self:GetValue("lookat_y", 0) or y;
		z = self:GetValue("lookat_z", 0) or z;

		local att = ParaCamera.GetAttributeObject();

		self.entity = EntityCamera:Create({x=x,y=y,z=z, item_id = block_types.names.TimeSeriesCamera});
		self.entity:SetPersistent(false);
		self.entity:Attach();

		return self;
	end
end

function Actor:IsKeyFrameOnly()
	return true;
end

-- force return nil. 
function Actor:GetEditableVariable()
end

-- @return true if recording. 
function Actor:SetRecording(isRecording)
	if(isRecording~=self.isRecording) then
		self.isRecording = isRecording;

		if(isRecording) then
			self.begin_recording_time = self:GetTime();
			--self:RemoveKeysInTimeRange(self:GetTime(), self:GetCurrentRecordingEndTime());
			self:ClearRecordToTime();
		else
			self.begin_recording_time = nil;
			self.end_recording_time = self:GetTime();
		end
			
		local movieClip = self:GetMovieClip();
		if(movieClip) then
			movieClip:SetActorRecording(self, isRecording);
		end

		-- add key frame at recording switch time. 
		self:AddKeyFrame();
	end
	return self.isRecording;
end

function Actor:OnRemove()
	Actor._super.OnRemove(self);
end

function Actor:FrameMoveRecording(deltaTime)
	local curTime = self:GetTime();
	local entity = self.entity;
	if(not entity or not curTime) then
		return
	end
	
	if( not entity.ridingEntity and deltaTime > 0 and self.begin_recording_time) then
		-- only take a key frame every self.auto_record_interval milliseconds. 
		if ((self.begin_recording_time+self.auto_record_interval) > curTime) then
			-- do nothing if we are not at auto recording interval. 
			return;
		else
			self.begin_recording_time = curTime;
		end
	end

	entity:UpdatePosition();
	local x,y,z = entity:GetPosition();

	self:BeginUpdate();
	self:AutoAddKey("lookat_x", curTime, x);
	self:AutoAddKey("lookat_y", curTime, y);
	self:AutoAddKey("lookat_z", curTime, z);

	local eye_dist, eye_liftup, eye_rot_y = ParaCamera.GetEyePos();
	if(eye_dist) then
		self:AutoAddKey("eye_dist", curTime, eye_dist);
		self:AutoAddKey("eye_liftup", curTime, eye_liftup);
		self:AutoAddKey("eye_rot_y", curTime, eye_rot_y);
	end
	self:AutoAddKey("is_fps", curTime, if_else(CameraController.IsFPSView(), 1,0));

	local has_collision = if_else(self.entity:HasCollision(), 1,0); 
	self:AutoAddKey("has_collision", curTime, has_collision);
	self:EndUpdate();
end

function Actor:IsAllowUserControl()
	local entity = self:GetEntity();
	if(entity) then
		local curTime = self:GetTime();
		return entity:HasFocus() and not self:IsPlayingMode() and self:IsPaused() and 
			-- allow user control when there is no key frames at the end
			-- using OR, we will allow dragging when no key frames. 
			(((self:GetMultiVariable():GetLastTime()+1) <= curTime) or not MovieClipTimeLine.IsDraggingTimeLine());
	end
end

function Actor:FrameMovePlaying(deltaTime)
	local curTime = self:GetTime();
	local entity = self.entity;
	if(not entity or not curTime) then
		return
	end
	
	local eye_dist = self:GetValue("eye_dist", curTime);
	local eye_liftup = self:GetValue("eye_liftup", curTime);
	local eye_rot_y = self:GetValue("eye_rot_y", curTime);

	local allow_user_control;
	if(entity:HasFocus()) then
		local isBehindLastFrame = ((self:GetMultiVariable():GetLastTime()+1) <= curTime);
		allow_user_control = not self:IsPlayingMode() and isBehindLastFrame;
		if( not allow_user_control ) then
			ParaCamera.SetEyePos(eye_dist, eye_liftup, eye_rot_y);
			self:UpdateFPSView(curTime);
		end
		if(isBehindLastFrame) then
			return;
		end
	end
	local obj = entity:GetInnerObject();
	if(obj) then
		obj:SetFacing(eye_rot_y or 0);
		obj:SetField("HeadUpdownAngle", 0);
		obj:SetField("HeadTurningAngle", 0);
		local nx, ny, nz = mathlib.math3d.vec3Rotate(0, 1, 0, 0, 0, -(eye_liftup or 0))
		nx, ny, nz = mathlib.math3d.vec3Rotate(nx, ny, nz, 0, eye_rot_y or 0, 0)
		obj:SetField("normal", {nx, ny, nz});
	end
	

	if(not allow_user_control) then
		local new_x = self:GetValue("lookat_x", curTime);
		local new_y = self:GetValue("lookat_y", curTime);
		local new_z = self:GetValue("lookat_z", curTime);

		if(new_x and new_y and new_z) then
			entity:SetPosition(new_x, new_y, new_z);
			-- due to floating point precision of the view matrix, slowly moved camera may jerk.
			--LOG.std(nil, "debug", "ActorCamera", "x,y,z: %f %f %f", new_x, new_y, new_z);
			--LOG.std(nil, "debug", "ActorCamera", "c pos: %f %f %f", ParaCamera.GetLookAtPos());
		end
	end

	local has_collision = self:GetValue("has_collision", curTime) or 1; 
	-- disable collision if camera is inside a solid block. 
	if(entity:IsInsideObstructedBlock() and not CameraController.HasCameraCollision()) then
		has_collision = false;
	end
	entity:SetCameraCollision(has_collision);

	if(self:IsPlayingMode()) then
		entity:HideCameraModel();
	else
		entity:ShowCameraModel();
	end
end

function Actor:UpdateFPSView(curTime)
	curTime = curTime or self:GetTime();
	local is_fps = self:GetValue("is_fps", curTime) or default_fps_mode; 
	local current_is_fps = if_else(CameraController.IsFPSView(), 1,0);
	if(current_is_fps ~= is_fps) then
		CameraController.ToggleCamera(is_fps == 1);
	end
end

function Actor:SetFocus()
	Actor._super.SetFocus(self);
	self:UpdateFPSView(curTime);
	self:FrameMovePlaying(0);
end

-- select me: for further editing. 
function Actor:SelectMe()
	-- camera actor does not show up anything. 
end

-- get the camera settings before SetFocus is called. this usually stores the current player's camera settings
-- before a movie clip is played. we will usually restore the camera settings when camera is reset. 
function Actor:GetRestoreCamSettings()
	local entity = self.entity;
	if(entity) then
		return entity:GetRestoreCamSettings()
	end
end

function Actor:SetRestoreCamSettings(settings)
	local entity = self.entity;
	if(entity) then
		return entity:SetRestoreCamSettings(settings);
	end
end

function Actor:CreateKeyFromUI(keyname, callbackFunc)
	if(keyname == nil) then
		-- multi-variable
		local curTime = self:GetTime();
		local h,m,s = commonlib.timehelp.SecondsToHMS(curTime/1000);
		local strTime = string.format("%.2d:%.2d", m,math.floor(s));
		local title = format(L"起始时间:%s <br/>lookat_x, lookat_y, lookat_z,<br/>eye_dist, eye_liftup, eye_rot_y", strTime);
		local lookat_x = self:GetValue("lookat_x", curTime);
		local lookat_y = self:GetValue("lookat_y", curTime);
		local lookat_z = self:GetValue("lookat_z", curTime);
		if(not lookat_x) then
			return;
		end
		local eye_dist = self:GetValue("eye_dist", curTime) or 10;
		local eye_liftup = self:GetValue("eye_liftup", curTime) or 0;
		local eye_rot_y = self:GetValue("eye_rot_y", curTime) or 0;

		local old_value = string.format("%f, %f, %f,\n%f, %f, %f", lookat_x,lookat_y,lookat_z,eye_dist,eye_liftup,eye_rot_y);

		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			if(result and result~="") then
				local vars = CmdParser.ParseNumberList(result, nil, "|,%s");

				if(vars[1] == lookat_x and vars[2] == lookat_y and vars[3] == lookat_z and
					vars[4] == eye_dist and vars[5] == eye_liftup and vars[6] == eye_rot_y) then
					-- nothing has changed
				elseif(vars[6]) then
					self:BeginUpdate();
					self:AddKeyFrameByName("lookat_x", nil, vars[1]);
					self:AddKeyFrameByName("lookat_y", nil, vars[2]);
					self:AddKeyFrameByName("lookat_z", nil, vars[3]);
					self:AddKeyFrameByName("eye_dist", nil, vars[4]);
					self:AddKeyFrameByName("eye_liftup", nil, vars[5]);
					self:AddKeyFrameByName("eye_rot_y", nil, vars[6]);
					self:EndUpdate();
					self:FrameMovePlaying(0);	
					if(callbackFunc) then
						callbackFunc(true);
					end
				end
			end
		end,old_value,true); 
	else
		-- TODO: indivdual 
	end
end