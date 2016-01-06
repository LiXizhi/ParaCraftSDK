--[[
Title: mob entity actor
Author(s): LiXizhi
Date: 2014/3/30
Desc: for recording and playing back of mob and NPC
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorNPC.lua");
local ActorNPC = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorNPC");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/Actor.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorBlock.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerAssetFile.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/MultiAnimBlock.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CmdParser.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/BonesVariable.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local BonesVariable = commonlib.gettable("MyCompany.Aries.Game.Movie.BonesVariable");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");
local MultiAnimBlock = commonlib.gettable("MyCompany.Aries.Game.Common.MultiAnimBlock");
local PlayerAssetFile = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerAssetFile")
local ActorBlock = commonlib.gettable("MyCompany.Aries.Game.Movie.ActorBlock");
local EntityNPC = commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityNPC")
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");


local Actor = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Movie.Actor"), commonlib.gettable("MyCompany.Aries.Game.Movie.ActorNPC"));

Actor.class_name = "ActorNPC";

-- recommended to set to true to use script to calculate pose for each frame precisely. 
local animate_by_script = true;
			

-- keyframes that can be edited from UI keyframe. 
local selectable_var_list = {
	"anim", "bones", "assetfile", "skin", "blockinhand",
	"pos", -- multiple of x,y,z
	"facing", 
	"rot", -- multiple of "roll", "pitch", "facing"
	"head", -- multiple of "HeadUpdownAngle", "HeadTurningAngle"
	"scaling", "speedscale", "gravity", "opacity", "blocks"
};


function Actor:ctor()
	self.actor_block = ActorBlock:new();
end

function Actor:GetMultiVariable()
	if(self.multi_variable) then
		return self.multi_variable;
	else
		self.multi_variable = MultiAnimBlock:new();
		self.multi_variable:AddVariable(self:GetVariable("x"));
		self.multi_variable:AddVariable(self:GetVariable("y"));
		self.multi_variable:AddVariable(self:GetVariable("z"));
		self.multi_variable:AddVariable(self:GetVariable("facing")); -- facing is yaw, actually
		self.multi_variable:AddVariable(self:GetVariable("pitch"));
		self.multi_variable:AddVariable(self:GetVariable("roll"));
		self.multi_variable:AddVariable(self:GetVariable("anim"));
		self.multi_variable:AddVariable(self:GetVariable("skin"));
		self.multi_variable:AddVariable(self:GetVariable("blockinhand"));
		self.multi_variable:AddVariable(self:GetVariable("assetfile"));
		self.multi_variable:AddVariable(self:GetVariable("scaling"));
		return self.multi_variable;
	end
end

-- get position multi variable
function Actor:GetPosVariable()
	if(self.pos_variable) then
		return self.pos_variable;
	else
		self.pos_variable = MultiAnimBlock:new({name="pos"});
		self.pos_variable:AddVariable(self:GetVariable("x"));
		self.pos_variable:AddVariable(self:GetVariable("y"));
		self.pos_variable:AddVariable(self:GetVariable("z"));
		return self.pos_variable;
	end
end

-- get rotate multi variable
function Actor:GetRotateVariable()
	if(self.rot_variable) then
		return self.rot_variable;
	else
		self.rot_variable = MultiAnimBlock:new({name="rot"});
		self.rot_variable:AddVariable(self:GetVariable("roll"));
		self.rot_variable:AddVariable(self:GetVariable("pitch"));
		self.rot_variable:AddVariable(self:GetVariable("facing"));
		return self.rot_variable;
	end
end

function Actor:GetBlocksVariable()
	return self.actor_block.blocks;
end

-- get position multi variable
function Actor:GetHeadVariable()
	if(self.head_variable) then
		return self.head_variable;
	else
		self.head_variable = MultiAnimBlock:new({name="head"});
		self.head_variable:AddVariable(self:GetVariable("HeadTurningAngle"));
		self.head_variable:AddVariable(self:GetVariable("HeadUpdownAngle"));
		return self.head_variable;
	end
end

-- load bone animations if not loaded before, this function does nothing if no bones are in the time series. 
function Actor:CheckLoadBonesAnims()
	if(not self.bones_variable) then
		local bones = self:GetTimeSeries():GetChild("bones");
		if(bones) then
			self:GetBonesVariable();
		end
	end
end

function Actor:GetSelectionName()
	local name = self:GetDisplayName() or "";
	local var = self:GetEditableVariable();

	if(var) then
		name = format("%s::%s", name, var.name);
		if(var.name == "bones") then
			local bone_name = var:GetSelectedBoneName();
			if(bone_name) then
				name = format("%s::%s", name, bone_name);
			else
				name = format("%s::[all]", name);
			end
		end
	end
	return name;
end

function Actor:GetBonesVariable()
	if(not self.bones_variable) then
		self.bones_variable = BonesVariable:new():init(self);
		self:Connect("dataSourceChanged", self.bones_variable, self.bones_variable.LoadFromActor)
	end
	return self.bones_variable;
end

function Actor:BindItemStackToTimeSeries()
	-- needs to clear all multi variable, otherwise undo function will not work properly. 
	self.multi_variable = nil;
	self.pos_variable = nil;
	self.head_variable = nil;
	local res = Actor._super.BindItemStackToTimeSeries(self);
	return res;
end

function Actor:Init(itemStack, movieclipEntity)
	self.actor_block:Init(itemStack, movieclipEntity);
	-- base class must be called last, so that child actors have created their own variables on itemStack. 
	if(not Actor._super.Init(self, itemStack, movieclipEntity)) then
		return;
	end

	local timeseries = self.TimeSeries;
	timeseries:CreateVariableIfNotExist("x", "Linear");
	timeseries:CreateVariableIfNotExist("y", "Linear");
	timeseries:CreateVariableIfNotExist("z", "Linear");
	timeseries:CreateVariableIfNotExist("facing", "LinearAngle");
	timeseries:CreateVariableIfNotExist("pitch", "LinearAngle");
	timeseries:CreateVariableIfNotExist("roll", "LinearAngle");
	timeseries:CreateVariableIfNotExist("HeadUpdownAngle", "Linear");
	timeseries:CreateVariableIfNotExist("HeadTurningAngle", "Linear");
	timeseries:CreateVariableIfNotExist("anim", "Discrete");
	timeseries:CreateVariableIfNotExist("assetfile", "Discrete");
	timeseries:CreateVariableIfNotExist("speedscale", "Discrete");
	timeseries:CreateVariableIfNotExist("gravity", "Discrete");
	timeseries:CreateVariableIfNotExist("scaling", "Linear");
	timeseries:CreateVariableIfNotExist("name", "Discrete");
	timeseries:CreateVariableIfNotExist("skin", "Discrete");
	timeseries:CreateVariableIfNotExist("blockinhand", "Discrete");
	timeseries:CreateVariableIfNotExist("opacity", "Linear");
	
	self:AddValue("position", self.GetPosVariable);

	-- get initial position from itemStack, if not exist, we will use movie clip entity's block position. 
	local movieClip = self:GetMovieClip();
	if(movieClip) then
		local x = self:GetValue("x", 0);
		local y = self:GetValue("y", 0);
		local z = self:GetValue("z", 0);
		if(not x or not y or not z) then
			x, y, z = movieClip:GetOrigin();
			y = y + BlockEngine.blocksize;
			self:AddKey("x", 0, x);
			self:AddKey("y", 0, y);
			self:AddKey("z", 0, z);
		end

		local HeadUpdownAngle, HeadTurningAngle, anim, facing,skin, opacity, name;
		HeadUpdownAngle = self:GetValue("HeadUpdownAngle", 0);
		HeadTurningAngle = self:GetValue("HeadTurningAngle", 0);
		anim = self:GetValue("anim", 0);
		facing = self:GetValue("facing", 0);
		skin = self:GetValue("skin", 0);
		opacity = self:GetValue("opacity", nil);
		name = self:GetValue("name", 0);

		self.entity = EntityNPC:Create({x=x,y=y,z=z, facing=facing, 
			opacity = opacity, item_id = block_types.names.TimeSeriesNPC, 
			});
		if(self.entity) then
			self.entity:SetActor(self);
			self.entity:SetPersistent(false);
			self.entity:SetDummy(true);
			if(skin) then
				self.entity:SetSkin(skin);
			end
			self.entity:SetCanRandomMove(false);
			self.entity:SetDisplayName(name);
			self.entity:EnableAnimation(not animate_by_script);
			self.entity:Attach();
			self:CheckLoadBonesAnims();
		end
		return self;
	end
end

function Actor:OnRemove()
	self.actor_block:OnRemove();
	
	Actor._super.OnRemove(self);
end

function Actor:SetItemStack(itemStack)
	self.actor_block:SetItemStack(itemStack);
	-- base class must be called last, so that child actors have initialized their own variables on itemStack. 
	Actor._super.SetItemStack(self, itemStack);
end

-- @return nil or a table of variable list. 
function Actor:GetEditableVariableList()
	return selectable_var_list;
end

-- @param selected_index: if nil,  default to current index
-- @return var
function Actor:GetEditableVariable(selected_index)
	selected_index = selected_index or self:GetCurrentEditVariableIndex();
	
	local name = selectable_var_list[selected_index];
	local var;
	if(name == "pos") then
		var = self:GetPosVariable();
	elseif(name == "rot") then
		var = self:GetRotateVariable();
	elseif(name == "head") then
		var = self:GetHeadVariable();
	elseif(name == "bones") then
		var = self:GetBonesVariable();
	elseif(name == "blocks") then
		var = self:GetBlocksVariable();
	else
		var = self.TimeSeries:GetVariable(name);
	end
	return var;
end

function Actor:CreateKeyFromUI(keyname, callbackFunc)
	local curTime = self:GetTime();
	local h,m,s = commonlib.timehelp.SecondsToHMS(curTime/1000);
	local strTime = string.format("%.2d:%.2d", m,math.floor(s));
	local old_value = self:GetValue(keyname, curTime);

	if(keyname == "anim") then
		local title = format(L"起始时间%s, 请输入动画ID或名称:", strTime);

		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			local EntityAnimation = commonlib.gettable("MyCompany.Aries.Game.Effects.EntityAnimation");
			if(result) then
				result = EntityAnimation.CreateGetAnimId(result);	
				if( type(result) == "number") then
					self:AddKeyFrameByName(keyname, nil, result);
					self:FrameMovePlaying(0);
					if(callbackFunc) then
						callbackFunc(true);
					end
				end
			end
		end,old_value)
	elseif(keyname == "assetfile") then
		local title = format(L"起始时间%s, 请输入模型路经或名称(默认default)", strTime);

		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/OpenFileDialog.lua");
		local OpenFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.OpenFileDialog");
		OpenFileDialog.ShowPage(title, function(result)
			if(result and result~="") then
				local filepath = PlayerAssetFile:GetValidAssetByString(result);
				if(filepath) then
					-- PlayerAssetFile:GetNameByFilename(filename)
					self:AddKeyFrameByName(keyname, nil, result);
					self:FrameMovePlaying(0);
					if(callbackFunc) then
						callbackFunc(true);
					end
				end
			end
		end,old_value, L"选择模型文件", "model");

	elseif(keyname == "blockinhand") then
		local title = format(L"起始时间%s, 请输入手持物品ID(空为0)", strTime);

		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			result = tonumber(result);
			if(result) then
				self:AddKeyFrameByName(keyname, nil, result);
				self:FrameMovePlaying(0);
				if(callbackFunc) then
					callbackFunc(true);
				end
			end
		end,old_value)
	elseif(keyname == "skin") then
		local title = format(L"起始时间%s, 请输入皮肤ID或名称", strTime);

		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/OpenFileDialog.lua");
		local OpenFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.OpenFileDialog");
		OpenFileDialog.ShowPage(title, function(result)
			if(result and result~="") then
				if(result:match("^%d+$")) then
					NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerSkins.lua");
					local PlayerSkins = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerSkins");
					result = PlayerSkins:GetSkinByString(result);
				end
				-- trim strings
				result = result:gsub("%s+$", "")
				result = result:gsub("^%s+", "")
				self:AddKeyFrameByName(keyname, nil, result);
				self:FrameMovePlaying(0);
				if(callbackFunc) then
					callbackFunc(true);
				end
			end
		end,old_value, L"贴图文件", "texture");

	elseif(keyname == "scaling") then
		local title = format(L"起始时间%s, 请输入放大系数(默认1)", strTime);

		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			result = tonumber(result);
			if(result) then
				self:AddKeyFrameByName(keyname, nil, result);
				self:FrameMovePlaying(0);
				if(callbackFunc) then
					callbackFunc(true);
				end
			end
		end,old_value)
	elseif(keyname == "opacity") then
		local title = format(L"起始时间%s, 请输入透明度[0,1](默认1)", strTime);

		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			result = tonumber(result);
			if(result and result>=0 and result<=1) then
				self:AddKeyFrameByName(keyname, nil, result);
				self:FrameMovePlaying(0);
				if(callbackFunc) then
					callbackFunc(true);
				end
			end
		end,old_value)
	elseif(keyname == "facing" or keyname == "HeadUpdownAngle" or keyname=="HeadTurningAngle") then
		local title;
		if(keyname == "facing") then
			title = format(L"起始时间%s, 请输入转身的角度(-3.14, 3.14)", strTime);
		elseif(keyname == "HeadUpdownAngle") then
			title = format(L"起始时间%s, 请输入头部上下运动的角度(-1.57, 1.57)", strTime);
		elseif(keyname == "HeadTurningAngle") then
			title = format(L"起始时间%s, 请输入头部左右运动的角度(-1.57, 1.57)", strTime);
		end

		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			result = tonumber(result);
			if(result) then
				self:AddKeyFrameByName(keyname, nil, result);
				self:FrameMovePlaying(0);
				if(callbackFunc) then
					callbackFunc(true);
				end
			end
		end,old_value)
	elseif(keyname == "head") then
		local title = format(L"起始时间%s, 请输入头部角度(-1.57, 1.57)<br/>左右角度, 上下角度:", strTime);
		old_value = string.format("%f, %f", self:GetValue("HeadTurningAngle", curTime) or 0,self:GetValue("HeadUpdownAngle", curTime) or 0);
		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			if(result and result~="") then
				local vars = CmdParser.ParseNumberList(result, nil, "|,%s");
				if(result and vars[1] and vars[2]) then
					self:BeginUpdate();
					self:AddKeyFrameByName("HeadTurningAngle", nil, vars[1]);
					self:AddKeyFrameByName("HeadUpdownAngle", nil, vars[2]);
					self:EndUpdate();
					self:FrameMovePlaying(0);
					if(callbackFunc) then
						callbackFunc(true);
					end
				end
			end
		end,old_value)
	elseif(keyname == "rot") then
		local title = format(L"起始时间%s, 请输入roll, pitch, yaw (-1.57, 1.57)<br/>", strTime);
		old_value = string.format("%f, %f, %f", self:GetValue("roll", curTime) or 0,self:GetValue("pitch", curTime) or 0,self:GetValue("facing", curTime) or 0);
		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			if(result and result~="") then
				local vars = CmdParser.ParseNumberList(result, nil, "|,%s");
				if(result and vars[1] and vars[2] and vars[3]) then
					self:BeginUpdate();
					self:AddKeyFrameByName("roll", nil, vars[1]);
					self:AddKeyFrameByName("pitch", nil, vars[2]);
					self:AddKeyFrameByName("facing", nil, vars[3]);
					self:EndUpdate();
					self:FrameMovePlaying(0);
					if(callbackFunc) then
						callbackFunc(true);
					end
				end
			end
		end,old_value)
	elseif(keyname == "pos") then
		local title = format(L"起始时间%s, 请输入位置x,y,z:", strTime);
		old_value = string.format("%f, %f, %f", self:GetValue("x", curTime) or 0,self:GetValue("y", curTime) or 0, self:GetValue("z", curTime) or 0);
		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			if(result and result~="") then
				local vars = CmdParser.ParseNumberList(result, nil, "|,%s");
				if(result and vars[1] and vars[2] and vars[3]) then
					self:BeginUpdate();
					self:AddKeyFrameByName("x", nil, vars[1]);
					self:AddKeyFrameByName("y", nil, vars[2]);
					self:AddKeyFrameByName("z", nil, vars[3]);
					self:EndUpdate();
					self:FrameMovePlaying(0);
					if(callbackFunc) then
						callbackFunc(true);
					end
				end
			end
		end,old_value)
	elseif(keyname == "gravity") then
		local title = format(L"起始时间%s, 请输入重力加速度(默认18.36)", strTime);

		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			result = tonumber(result);
			if(result) then
				self:AddKeyFrameByName(keyname, nil, result);
				self:FrameMovePlaying(0);
				if(callbackFunc) then
					callbackFunc(true);
				end
			end
		end,old_value)
	elseif(keyname == "speedscale") then
		local title = format(L"起始时间%s, 请输入运动速度系数(默认1)", strTime);

		-- TODO: use a dedicated UI 
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
		local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
		EnterTextDialog.ShowPage(title, function(result)
			result = tonumber(result);
			if(result) then
				self:AddKeyFrameByName(keyname, nil, result);
				self:FrameMovePlaying(0);
				if(callbackFunc) then
					callbackFunc(true);
				end
			end
		end,old_value)
	elseif(keyname == "bones") then
		local var = self:GetBonesVariable();
		if(var) then
			local bone = var:GetSelectedBone();
			if(bone) then
				local rotVarCpp = bone:GetVariable(1);
				local rotVar = rotVarCpp:CreateGetTimeVar();
				local quat = rotVar:getValue(1, curTime);
				if(quat) then
					local yaw, roll, pitch = Quaternion.ToEulerAngles(quat) 
					local title = format(L"起始时间%s, 请输入roll, pitch, yaw (-1.57, 1.57)<br/>", strTime);
					old_value = string.format("%f, %f, %f", roll or 0,pitch or 0,yaw or 0);
					-- TODO: use a dedicated UI 
					NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EnterTextDialog.lua");
					local EnterTextDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.EnterTextDialog");
					EnterTextDialog.ShowPage(title, function(result)
						if(result and result~="") then
							local vars = CmdParser.ParseNumberList(result, nil, "|,%s");
							if(result and vars[1] and vars[2] and vars[3]) then
								self:BeginUpdate();
								roll, pitch, yaw  = vars[1], vars[2], vars[3];
								self:BeginModify();
								quat = Quaternion.FromEulerAngles(quat, yaw, roll, pitch);
								rotVarCpp:LoadFromTimeVar();
								self:SetModified();
								self:EndModify();
								self:EndUpdate();
								self:FrameMovePlaying(0);
								if(callbackFunc) then
									callbackFunc(true);
								end
							end
						end
					end,old_value)
				end
			end
		end
	end
end


-- clear all record to a given time. if curTime is nil, it will use the current time. 
function Actor:ClearRecordToTime(curTime)
	-- trim all keys to current time
	local curTime = curTime or self:GetTime();

	Actor._super.ClearRecordToTime(self, curTime);
	self.actor_block:ClearRecordToTime(curTime);
end

function Actor:SetControllable(bIsControllable)
	local entity = self:GetEntity()
	if(entity) then
		local obj = entity:GetInnerObject();
		if(obj) then
			obj:SetField("IsControlledExternally", not bIsControllable);
			obj:SetField("EnableAnim", not animate_by_script or bIsControllable);
		end
	end
end

-- whether the actor can create blocks. The camera actor can not create blocks
function Actor:CanCreateBlocks()
	return true;
end

-- this function is called whenver the create block task is called. i.e. the user has just created some block
function Actor:OnCreateBlocks(blocks)
	if(self:IsRecording())then
		self.actor_block:AddKeyFrameOfBlocks(blocks);
	end
end

-- this function is called whenver the destroy block task is called. i.e. the user has just destroyed some blocks
function Actor:OnDestroyBlocks(blocks)
	if(self:IsRecording())then
		self.actor_block:AddKeyFrameOfBlocks(blocks);
	end
end

function Actor:SaveStaticAppearance()
	local curTime = 0;
	local entity = self.entity;
	if(not entity or not curTime) then
		return
	end
	local obj = entity:GetInnerObject();

	if(obj) then
		local assetfile = obj:GetPrimaryAsset():GetKeyName();
		self:AutoAddKey("assetfile", curTime, PlayerAssetFile:GetNameByFilename(assetfile));
	end

	local skin = entity:GetSkin();
	if(skin) then
		self:AutoAddKey("skin", curTime, skin);
	end

	-- name property can not be animated and only save/replace the name key at frame 0. 
	local displayname = entity:GetDisplayName();
	if(displayname and displayname~="") then
		self:AddKey("name", 0, displayname);
		self:GetItemStack():SetTooltip(displayname);
	end
end

function Actor:FrameMoveRecording(deltaTime)
	local curTime = self:GetTime();
	local entity = self.entity;
	if(not entity or not curTime) then
		return
	end
	entity:UpdatePosition();
	local x,y,z = entity:GetPosition();
	local skin = entity:GetSkin();
	
	self:BeginUpdate();

	self:AutoAddKey("x", curTime, x);
	self:AutoAddKey("y", curTime, y);
	self:AutoAddKey("z", curTime, z);
	if(skin) then
		self:AutoAddKey("skin", curTime, skin);
	end
	
	local obj = entity:GetInnerObject();

	if(obj) then
		obj:SetField("IsControlledExternally", false);
		obj:SetField("EnableAnim", true);

		local yaw = obj:GetField("yaw", 0);
		self:AutoAddKey("facing", curTime, yaw);

		local anim = obj:GetField("AnimID", 0);
		if(anim > 1000) then
			anim = 0;
		end
		self:AutoAddKey("anim", curTime, anim);

		local HeadUpdownAngle = obj:GetField("HeadUpdownAngle", 0);
		self:AutoAddKey("HeadUpdownAngle", curTime, HeadUpdownAngle);

		local HeadTurningAngle = obj:GetField("HeadTurningAngle", 0);
		self:AutoAddKey("HeadTurningAngle", curTime, HeadTurningAngle);

		local speedscale = entity:GetSpeedScale();
		self:AutoAddKey("speedscale", curTime, speedscale);

		local scaling = obj:GetScale();
		self:AutoAddKey("scaling", curTime, scaling);

		local gravity = obj:GetField("Gravity", 9.18);
		self:AutoAddKey("gravity", curTime, gravity);

		local blockinhand = entity:GetBlockInRightHand();
		self:AutoAddKey("blockinhand", curTime, blockinhand or 0);

		local assetfile = obj:GetPrimaryAsset():GetKeyName();
		self:AutoAddKey("assetfile", curTime, PlayerAssetFile:GetNameByFilename(assetfile));
	end
	self:EndUpdate();
end

function Actor:FrameMovePlaying(deltaTime)
	local curTime = self:GetTime();
	local entity = self.entity;
	if(not entity or not curTime) then
		return
	end
	-- allow adding keyframe while playing during the last segment. 
	local allow_user_control = self:IsAllowUserControl() and
		((self:GetMultiVariable():GetLastTime()+1) <= curTime);

	if(allow_user_control) then
		local obj = entity:GetInnerObject();
		if(obj) then
			obj:SetField("IsControlledExternally", false);
			obj:SetField("EnableAnim", true);
		end
		if(deltaTime ~= 0) then
			return;
		end
	end

	local new_x = self:GetValue("x", curTime);
	local new_y = self:GetValue("y", curTime);
	local new_z = self:GetValue("z", curTime);

	if(new_x) then
		entity:SetPosition(new_x, new_y, new_z);
	end

	local HeadUpdownAngle, HeadTurningAngle, anim, yaw, roll, pitch, skin, speedscale, scaling, gravity, opacity, blockinhand, assetfile;
	HeadUpdownAngle = self:GetValue("HeadUpdownAngle", curTime);
	HeadTurningAngle = self:GetValue("HeadTurningAngle", curTime);
	anim = self:GetValue("anim", curTime);
	yaw = self:GetValue("facing", curTime);
	roll = self:GetValue("roll", curTime);
	pitch = self:GetValue("pitch", curTime);
	skin = self:GetValue("skin", curTime);
	speedscale = self:GetValue("speedscale", curTime);
	scaling = self:GetValue("scaling", curTime);
	gravity = self:GetValue("gravity", curTime);
	opacity = self:GetValue("opacity", curTime);
	assetfile = self:GetValue("assetfile", curTime);
	blockinhand = self:GetValue("blockinhand", curTime);

	local obj = entity:GetInnerObject();
	if(obj) then
		-- in case of explicit animation
		obj:SetField("Time", curTime); 
		obj:SetField("IsControlledExternally", true);
		obj:SetField("EnableAnim", not animate_by_script);

		obj:SetField("yaw", yaw or 0);
		obj:SetField("roll", roll or 0);
		obj:SetField("pitch", pitch or 0);
		
		local bNeedRefreshModel;
		if(entity:SetMainAssetPath(PlayerAssetFile:GetFilenameByName(assetfile))) then
			bNeedRefreshModel = true;
		end
		
		entity:SetSkin(skin);
		entity:SetBlockInRightHand(blockinhand);

		if(bNeedRefreshModel) then
			entity:RefreshClientModel();
		end
		
		if(anim) then
			if(anim~=obj:GetField("AnimID", 0)) then
				obj:SetField("AnimID", anim);
			end
			if(animate_by_script) then
				local var = self:GetVariable("anim");
				if(var) then
					-- get the time when model assetfile just takes effect. 
					local start_time = 0;
					local varAssetFile = self:GetVariable("assetfile");
					if(varAssetFile and varAssetFile:GetKeyNum()>1) then
						start_time = varAssetFile:getStartTime(1, curTime);
						if(varAssetFile:GetFirstTime() == start_time) then
							start_time = 0;
						end
					end
					-- get the time, when the animation is first started
					local fromTime = var:getStartTime(1, curTime);
					local localTime = curTime;
					if(var:GetFirstTime() == fromTime) then
						-- force looping from first frame
						fromTime = start_time;
					elseif(fromTime < start_time) then
						-- in case the asset model is changed, the start time is relative to the asset model. 
						fromTime = start_time;
					end

					localTime = curTime - fromTime;
					-- calculate speedscale? 
					local varSpeed = self:GetVariable("speedscale");
					if(varSpeed and varSpeed:GetKeyNum()>1) then
						local fromTimeSpeed, toTimeSpeed = varSpeed:getTimeRange(1, fromTime);
						if(toTimeSpeed >= curTime) then
							localTime = localTime * (speedscale or 1);
						else
							-- we need more calculations, here:  localtime = Sigma_sum{delta_time*speedscale(time)}
							local totalScaledTime = 0;
							local calculatedTime = fromTime;
							local lastTime, lastValue;
							for time, v in varSpeed:GetKeys_Iter(1, fromTimeSpeed-1, curTime) do
								local dt = time - calculatedTime;
								if(dt > 0) then
									totalScaledTime = totalScaledTime + dt * (lastValue or v);
									calculatedTime = time;
								end
								lastTime = time;
								lastValue = v;
							end
							if(curTime > calculatedTime) then
								totalScaledTime = totalScaledTime + (curTime - calculatedTime) * speedscale;
							end
							localTime = totalScaledTime;
						end
					else
						localTime = localTime * (speedscale or 1);
					end
					obj:SetField("AnimFrame", localTime);
					local default_blending_time = 250;
					if( localTime < default_blending_time and 
						-- if this the first animation, set it without using a blending factor. 
						fromTime ~= 0) then
						obj:SetField("BlendingFactor", 1 - localTime / default_blending_time);
					else
						-- this is actually already set in obj:SetField("AnimFrame", localTime); so no need to set again. 
						-- obj:SetField("BlendingFactor", 0);
					end
				end
			else
				if(curTime < 500) then
					-- if this the first animation, set it without using a blending factor. 
					obj:SetField("BlendingFactor", 0);
				end
			end
		end

		obj:SetField("HeadUpdownAngle", HeadUpdownAngle or 0);
		obj:SetField("HeadTurningAngle", HeadTurningAngle or 0);
		
		entity:SetSpeedScale(speedscale or 1);
		obj:SetField("Speed Scale", speedscale or 1);
		obj:SetScale(scaling or 1);
		
		if(gravity) then
			obj:SetField("Gravity", gravity);
		end
		obj:SetField("opacity", opacity or 1);
	end

	self.actor_block:FrameMovePlaying(deltaTime);
end

-- select me: for further editing. 
function Actor:SelectMe()
	local entity = self:GetEntity();
	if(entity) then
		local editmodel = entity:GetEditModel();
		editmodel:Connect("EndEdit", self, "OnEndEdit");
		Actor._super.SelectMe(self);	
	end
end

function Actor:OnEndEdit()
	local entity = self:GetEntity();
	if(entity) then
		local displayname = entity:GetDisplayName();
		if(displayname and displayname~="") then
			self:AddKey("name", 0, displayname);
			self:GetItemStack():SetTooltip(displayname);
		end
	end
end

-- bone selection changed in editor
function Actor:OnChangeBone(bone_name)
	local var = self:GetBonesVariable();
	if(var) then
		var:SetSelectedBone(bone_name);
		-- signal
		self:keyChanged();
	end
end
