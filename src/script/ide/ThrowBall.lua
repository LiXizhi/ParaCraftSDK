--[[
Title: ThrowBall
Author(s): Leio Zhang
Date: 2009/4/22
use the lib:
------------------------------------------------------------
-- control throw ball without mouse
NPL.load("(gl)script/ide/ThrowBall.lua");
local x,y,z = ParaScene.GetPlayer():GetPosition();
local dx,dy,dz = 5,0,0;
local throwBall = CommonCtrl.ThrowBall:new{
	startPoint = {x = x,y = 0,z = z},
	endPoint = {x = x + dx,y = 0 + dy,z = z + dz},
}
throwBall:Play();

-- throw ball by mouse
NPL.load("(gl)script/ide/ThrowBall.lua");
local style = "model/06props/shared/pops/barrels.x";
local throwBall = CommonCtrl.ThrowBall.RegHook(style);
if(throwBall)then
	throwBall.OnPlay = function(ball)
		
	end
	throwBall.OnUpdate = function(ball,frame)
		
	end
	throwBall.OnEnd = function(ball)
	
	end
	throwBall.OnHit = function(ball)
		if(ball)then
			local startPoint = ball.startPoint;
			local endPoint = ball.endPoint;
		end
	end
end

-- throw himself
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local baseObject = ParaScene.GetPlayer()
baseObject.isHero = true;
NPL.load("(gl)script/ide/ThrowBall.lua");
local throwBall = CommonCtrl.ThrowBall.RegHook();
throwBall:SetBall(baseObject);
if(throwBall)then
	throwBall.OnPlay = function(ball)
		
	end
	throwBall.OnUpdate = function(ball,frame)
		
	end
	throwBall.OnEnd = function(ball)
	
	end
	throwBall.OnHit = function(ball)
		if(ball)then
			local startPoint = ball.startPoint;
			local endPoint = ball.endPoint;
		end
	end
end
------------------------------------------------------------
--]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Storyboard/Storyboard.lua");
NPL.load("(gl)script/ide/Storyboard/TimeSpan.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/Cursor.lua");

NPL.load("(gl)script/apps/Aries/Inventory/Throwable.lua");
local ThrowablePage = commonlib.gettable("MyCompany.Aries.Inventory.ThrowablePage");

local math_abs = math.abs;
local type = type;
local tostring = tostring
local tonumber = tonumber
local LOG = LOG;
local CommonCtrl = CommonCtrl;
local commonlib = commonlib;
local ParaScene_GetObject = ParaScene.GetObject;

local ThrowBall={
	-- 起始坐标
	startPoint = nil,
	-- 结束坐标
	endPoint = nil,
	-- 球轨迹持续时间
	totalTime = "00:00:01",
	-- 扔球动作持续的时间
	defaultMovementTime = "00:00:00.5",
	-- 重力加速度
	g = 0.025,
	-- 最远射程's sqaure
	maxDisSq = 60*60,
	
	-- 被投掷的物体，ballObj.isHero = true:主角将被投掷
	ballObj = nil,
	-- 被投掷的球的样式,在ballObj = nil 时有效
	ballStyle = "model/06props/shared/pops/barrels.x",
	-- 默认扔球的动作
	defaultAnimationFile = nil,
	-- 驾驭的时候扔球的动作 小龙
	mountAnimationFile_1 = nil,
	-- 驾驭的时候扔球的动作 大龙
	mountAnimationFile_2 = nil,
	--投掷者的状态，是正常还是骑在龙上
	throwerState = "normal",--"normal" or "ride"
	-- 被击中的最小间距
	minVolume = 0.2,
	
	--击中后，播放效果持续的时间
	effectTime = "00:00:01",
	-- 主角
	player = nil,
	--鼠标时候按下
	press = false,
	--event
	--击中物体的事件
	-- onhit 发生在onend之前
	OnHit = nil,
	OnPlay = nil,
	OnUpdate = nil,
	OnEnd = nil,
	-- 扔球动作结束
	OnMovementEnd = nil,
	OnDisabled = nil,--投掷一个无效的点
};
commonlib.setfield("CommonCtrl.ThrowBall",ThrowBall);
function ThrowBall:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function ThrowBall:Init()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local HomeLandConfig = Map3DSystem.App.HomeLand.HomeLandConfig;
	
	self.totalTime = HomeLandConfig.Throwball_Duration or self.totalTime;
	self.defaultMovementTime = HomeLandConfig.Throwball_Movement_Duration or self.defaultMovementTime;
	self.effectTime = HomeLandConfig.Throwball_Effect_Duration or self.effectTime;
	self.defaultAnimationFile = HomeLandConfig.Throwball_Movement_AnimationFile or self.defaultAnimationFile;
	self.mountAnimationFile_1 = HomeLandConfig.Throwball_Movement_Mount_AnimationFile_1 or self.mountAnimationFile_1;
	self.mountAnimationFile_2 = HomeLandConfig.Throwball_Movement_Mount_AnimationFile_2 or self.mountAnimationFile_2;
	if(HomeLandConfig.Throwball_MaxDis) then
		self.maxDisSq = HomeLandConfig.Throwball_MaxDis * HomeLandConfig.Throwball_MaxDis;
	end
	self.minVolume = HomeLandConfig.Throwball_OnHit_MinVolume or self.minVolume;
	self.g = HomeLandConfig.Throwball_G or self.g;
end
--设置是玩家自己投掷 还是触发的投掷消息
-- "myself" or "machine"
function ThrowBall:SetThrowType(type)
	self.throwType = type;
end
--设置 投掷者的状态，是骑在龙身上，还是没有"ride" or 其他
function ThrowBall:SetThrowerState(state)
	self.throwerState = state;
end
--如果人骑在龙上，需要知道龙的等级，是小龙还是大龙，2小龙 3 大龙
function ThrowBall:SetThrowerLevel(level)
	self.throwerLevel = level;
end
--设置被投掷的物品是什么
--[[
local item = {
				style = gsItem.assetfile or "model/06props/shared/pops/barrels.x", 
				hitstyle = hitstyle,
				gsid = gsid,
				item_guid = gsItem.guid,
			}
--]]
function ThrowBall:SetThrowItem(item)
	self.throwItem = item;
end
--设置是谁扔的
function ThrowBall:SetThrower(playerName,nid)
	self.playerName = playerName;
	self.nid = nid;
end
--设置被击中的人物
function ThrowBall:AttackedObject(attackedName)
	self.attackedName = attackedName;
end
-- 播放投掷的动作，它在扔球之前触发
-- 播放完投掷的动作，然后播放球的轨迹
function ThrowBall:DoMovement()
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames(self.defaultMovementTime);
	if(frame <= 0)then return end
	
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	storyboard.OnPlay = function(s)
		local player;
		local animation_file;
		local throwerState = self.throwerState
		local throwerLevel = self.throwerLevel
		--如果是骑在龙身上
		if(throwerState == "ride")then
			if(throwerLevel == 2)then
				animation_file = self.mountAnimationFile_1;
			elseif(throwerLevel == 3)then
				animation_file = self.mountAnimationFile_2;
			end
			player = MyCompany.Aries.Pet.GetUserMountObj(self.nid);
		else
			animation_file = self.defaultAnimationFile;
			if(self.throwType == "machine")then
				player = ParaScene.GetObject(tostring(self.nid));
			else
				player = ParaScene.GetObject(self.playerName);
			end
		end
		
		if(animation_file and animation_file ~="")then
			if(player and player:IsValid())then
				Map3DSystem.Animation.PlayAnimationFile(animation_file, player);
			end
		end
	end
	storyboard.OnUpdate = function(s)
		
	end
	storyboard.OnEnd = function(s)
		local displayObj = self:GetBall();
		self:CreateCurveMotionByScript(displayObj,self.startPoint,self.endPoint,self.totalTime,self.g);
	end
	storyboard:Play();
end
function ThrowBall:Play()
	if(self:CanThrow())then
		self:DoMovement();
	end
end
--检测是否可以投掷
function ThrowBall:CanThrow()
	if(not self.startPoint)then return end
	local end_x,end_y,end_z;
	--如果锁定目标
	if(self.attackedName)then
		local obj = ParaScene.GetObject(self.attackedName);
		if(obj and obj:IsValid())then
			end_x,end_y,end_z = obj:GetPosition();
		end
	else
		if(self.endPoint)then
			end_x,end_y,end_z = self.endPoint.x,self.endPoint.y,self.endPoint.z;
		end
	end
	if(end_x and end_y and end_z)then
		local dis_x = end_x - self.startPoint.x;
		local dis_y = end_y - self.startPoint.y;
		local dis_z = end_z - self.startPoint.z;
		return self:CheckMinDis(dis_x,dis_y,dis_z);
	end
end

function ThrowBall:CheckMinDis(dis_x,dis_y,dis_z)
	local disSq = dis_x * dis_x + dis_z * dis_z
	return not (disSq < 0.25 or disSq > self.maxDisSq);
end

--@param ball_start_x,ball_start_y,ball_start_z:球的初始位置
--@param startPoint:投掷的初始位置
--@param frame:运行的帧数
--@parma g:重力
--@param t运行时间
function ThrowBall:UpdateBallPosition(ball_start_x,ball_start_y,ball_start_z,startPoint,frame,g,t)
	if(not ball_start_x or not ball_start_y or not ball_start_z or not startPoint or not frame)then return end
	g = g or 0.025;
	local end_x,end_y,end_z;
	--如果锁定目标
	if(self.attackedName and self.throwType == "machine")then
		local obj = ParaScene.GetObject(self.attackedName);
		if(obj and obj:IsValid())then
			end_x,end_y,end_z = obj:GetPosition();
		end
	else
		if(self.endPoint)then
			end_x,end_y,end_z = self.endPoint.x,self.endPoint.y,self.endPoint.z;
		end
	end
	if(end_x and end_y and end_z)then
		local dis_x = end_x - startPoint.x;
		local dis_y = end_y - startPoint.y;
		local dis_z = end_z - startPoint.z;
		
		local v_x = dis_x / frame;
		local v_y = dis_y / frame + g * frame / 2;
		local v_z = dis_z / frame;
		
		local x = v_x * t;
		local y = v_y * t - g * t * t /2;
		local z = v_z * t;
		x = x + ball_start_x;
		y = y + ball_start_y;
		z = z + ball_start_z;
		return x,y,z,end_x,end_y,end_z;
	end
end
-- @param displayObj: 被抛掷的对象，它是一个DisplayObject实例
-- @param startPoint: 起始坐标
-- @param endPoint: 结束坐标
-- @param totalTime: 持续时间，默认值为 "00:00:01"
-- @param g: 重力加速度，默认值为0.025
function ThrowBall:CreateCurveMotionByScript(displayObj,startPoint,endPoint,totalTime,g)
	if(not displayObj or not startPoint)then return end
	totalTime = totalTime or "00:00:01";
	g = g or 0.025;
	local obj_x,obj_y,obj_z = displayObj:GetPosition();
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames(totalTime);
	if(frame <= 0)then return end
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	storyboard.OnPlay = function(s)
		--commonlib.echo({"play",s:GetCurFrame()});
		if(self.OnPlay)then
			self.OnPlay(self);
		end
	end
	storyboard.OnUpdate = function(s)
		local t = s:GetCurFrame();
		if(t >=0)then
			if(self.OnUpdate)then
				self.OnUpdate(self,t);
			end
			
			local x,y,z,end_x,end_y,end_z = self:UpdateBallPosition(obj_x,obj_y,obj_z,startPoint,frame,g,t);
			if(x and y and z and end_x and end_y and end_z)then
				--更新ball的位置
				displayObj:SetPosition(x,y,z);
				
				local dx = x - end_x;
				local dy = y - end_y;
				local dz = z - end_z;
				dx =  math_abs(dx);
				dy =  math_abs(dy);
				dz =  math_abs(dz);
				if(dx <= self.minVolume  and dy <= self.minVolume  and dz <= self.minVolume)then
					self:DoResponse();
					if(self.OnHit)then
						self.OnHit(self);
					end
				end
			end
		end
	end
	storyboard.OnEnd = function(s)
		--commonlib.echo({"end",s:GetCurFrame()});
		local scene = CommonCtrl.ThrowBall.GetScene();
		if(displayObj and not displayObj.isHero)then
			scene:RemoveChild(displayObj);
		end
		if(self.OnEnd)then
			self.OnEnd(self);
		end
		if(self.globalInstance)then
			self.globalInstance = nil;
		end
	end
	
	storyboard:Play();
end
----被废除
---- @param displayObj: 被抛掷的对象，它是一个DisplayObject实例
---- @param startPoint: 起始坐标
---- @param endPoint: 结束坐标
---- @param totalTime: 持续时间，默认值为 "00:00:01"
---- @param g: 重力加速度，默认值为0.025
--function ThrowBall:CreateCurveMotionByScript2(displayObj,startPoint,endPoint,totalTime,g)
	--if(not displayObj or not startPoint or not endPoint)then return end
	--totalTime = totalTime or "00:00:01";
	--g = g or 0.025;
	--local obj_x,obj_y,obj_z = displayObj:GetPosition();
	--local dis_x = endPoint.x - startPoint.x;
	--local dis_y = endPoint.y - startPoint.y;
	--local dis_z = endPoint.z - startPoint.z;
	--
	--local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames(totalTime);
	--if(frame <= 0)then return end
	--local v_x = dis_x / frame;
	--local v_y = dis_y / frame + g * frame / 2;
	--local v_z = dis_z / frame;
	--
	--local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	--storyboard:SetDuration(frame);
	--storyboard.OnPlay = function(s)
		----commonlib.echo({"play",s:GetCurFrame()});
		--if(self.OnPlay)then
			--self.OnPlay(self);
		--end
	--end
	--storyboard.OnUpdate = function(s)
		--local t = s:GetCurFrame();
		--if(t >=0)then
			--if(self.OnUpdate)then
				--self.OnUpdate(self,t);
			--end
			--
			--local x = v_x * t;
			--local y = v_y * t - g * t * t /2;
			--local z = v_z * t;
			--x = x + obj_x;
			--y = y + obj_y;
			--z = z + obj_z;
			--displayObj:SetPosition(x,y,z);
			--
			--local dx = x - endPoint.x;
			--local dy = y - endPoint.y;
			--local dz = z - endPoint.z;
			--dx =  math_abs(dx);
			--dy =  math_abs(dy);
			--dz =  math_abs(dz);
			--if(dx <= self.minVolume  and dy <= self.minVolume  and dz <= self.minVolume)then
				--self:DoResponse();
				--if(self.OnHit)then
					--self.OnHit(self);
				--end
				--
			--end
			--
		--end
	--end
	--storyboard.OnEnd = function(s)
		----commonlib.echo({"end",s:GetCurFrame()});
		--local scene = CommonCtrl.ThrowBall.GetScene();
		--if(displayObj and not displayObj.isHero)then
			--scene:RemoveChild(displayObj);
		--end
		--if(self.OnEnd)then
			--self.OnEnd(self);
		--end
		--if(self.globalInstance)then
			--self.globalInstance = nil;
		--end
	--end
	--
	--storyboard:Play();
--end

function ThrowBall:SetBall(ballObj)
	self.ballObj = ballObj;
end
function ThrowBall:GetBall()
	local baseObject;
	local startPoint = self.startPoint;
	if(not startPoint)then return end
	if(not self.ballObj)then
		NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
		baseObject = CommonCtrl.Display.Objects.Building3D:new()
		baseObject:Init();
		local params = baseObject:GetEntityParams();
		params.AssetFile = self.ballStyle;
		baseObject:SetEntityParams(params);
		--local player = ParaScene.GetObject(self.playerName);
		--if(player and player:IsValid())then
			--local x,y,z = player:GetPosition();
			--baseObject:SetPosition(x,y,z);
		--end
	else
		baseObject = self.ballObj;
	end
	local x,y,z = startPoint.x,startPoint.y,startPoint.z;
	baseObject:SetPosition(x,y,z);
	local scene = CommonCtrl.ThrowBall.GetScene();
	if(not baseObject.isHero)then
		scene:AddChild(baseObject);
	end
	return baseObject;
end
--如果锁定目标，优先返回它的坐标
function ThrowBall:GetEndPointByAttackedName()
	if(self.attackedName and self.throwType == "machine")then
		local obj = ParaScene.GetObject(self.attackedName);
		if(obj and obj:IsValid())then
			local endPoint = {
				x = x,
				y = y,
				z = z,
			}
			return endPoint;
		end
	end
	return self.endPoint;
end
function ThrowBall:DoResponse()
	local endPoint = self:GetEndPointByAttackedName();
	--播放投掷完毕后的效果
	-- add a hit object name list to record all hit characters
	local hitObjNameList = {};
	if(self.throwItem and endPoint)then
		local item = self.throwItem;
		local assetFile = item.hitstyle;--炸中显示的模型
		local showpic = item.showpic;--炸中显示的图片
		if(not assetFile or assetFile == "")then return end
		NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
		local tempShowEffect = CommonCtrl.Display.Containers.MiniScene:new();
		tempShowEffect:Init();
		NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
		-- 绑定的效果模型
		local building3D = CommonCtrl.Display.Objects.Building3D:new();
		building3D:Init();
		building3D:SetPosition(endPoint.x,endPoint.y,endPoint.z);
		building3D:SetAssetFile(assetFile);
		tempShowEffect:Clear();
				
		local totalTime = item.effect_time or self.effectTime;
		local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames(totalTime);
		local storyboard = CommonCtrl.Storyboard.Storyboard:new();
		storyboard:SetDuration(frame);
		storyboard.OnPlay = function(s)
			tempShowEffect:AddChild(building3D);
		end
			
		storyboard.OnEnd = function(s)
			tempShowEffect:RemoveChild(building3D);
		end
		storyboard:Play();

		--如果打中对方，播放的效果
		--被击中对象的反映
		--[[
		local item = {
						style = gsItem.assetfile or "model/06props/shared/pops/barrels.x", 
						hitstyle = hitstyle,
						gsid = gsid,
						item_guid = gsItem.guid,
					}
		local msg = {nid = nid, sender = name, item = item,startPoint = startPoint, endPoint = endPoint,}
		--]]
		--local msg = self:GetThrowMsg();
		local obj;
		if(self.attackedName and self.throwType == "machine")then
			obj = ParaScene.GetObject(self.attackedName);
			self.hitObjNameList = {self.attackedName};
		else
			local name = self:GetWillbeAttackedObject(endPoint);
			obj = ParaScene.GetObject(name or "");
			self.hitObjNameList = {name};
		end
		self:DoResponse_PlayAnim(obj,showpic)
		--local fromX,fromY,fromZ = endPoint.x,endPoint.y,endPoint.z;
		--if(not fromX or not fromY or not fromZ)then return end
		--local objlist = {};
		--local radius = Map3DSystem.App.HomeLand.HomeLandConfig.Throwball_OnHit_FindRadius or 1;
		--local nCount = ParaScene.GetObjectsBySphere(objlist, fromX,fromY,fromZ, radius, "anyobject");
		--if(nCount > 0)then
			--local k = 1;
			--for k = 1,nCount do
				--local obj = objlist[k];
				--if(obj and obj:IsValid())then
					--if(obj.name ~= self.playerName)then
						--table.insert(hitObjNameList, obj.name);
						--local str_MCML = string.format("<img style=\"margin-left:6px;width:64px;height:64px;\" src=%q />", showpic);
						--headon_speech.Speek(obj.name, str_MCML, 3);
						--
						--
						--
						--break;
					--end
				--end
			--end
		--end
	end
	
end
--被击中后的反映
function ThrowBall:DoResponse_PlayAnim(obj,showpic)
	if(obj and obj:IsValid())then
		if(showpic and showpic ~= "")then
			local str_MCML = string.format("<img style=\"margin-left:6px;width:64px;height:64px;\" src=%q />", showpic);
			headon_speech.Speek(obj.name, str_MCML, 3);
		end
		-- to Leio: i manually play the animation file once hit by the firecracker gsid:9503
		local msg = self:GetThrowMsg();
		if(msg and msg.throwItem and msg.throwItem.gsid == 9503) then
			local nid = tonumber(obj.name) or tonumber(string.match(obj.name, "^(%d+)+driver"));
			if(nid) then
				
				local isInCombat = false;
				local player_nid = ParaScene_GetObject(tostring(nid));
				if(player_nid:IsValid()) then
					isInCombat = player_nid:GetDynamicField("IsInCombat", false);
				end
				
				-- skip fire cracker hit response
				if(not isInCombat) then
					if(nid == System.App.profiles.ProfileManager.GetNID()) then
						MyCompany.Aries.Player.HitByFireCracker();
					else
						local _player = MyCompany.Aries.Pet.GetUserCharacterObj(nid);
						if(_player and _player:IsValid() == true) then
							if(string.find(_player.name, "driver")) then
								local _mount = MyCompany.Aries.Pet.GetUserMountObj(nid);
								if(_mount and _mount:IsValid() == true) then
									-- temporarily turn off the OPC movement style
									_mount:GetAttributeObject():SetField("MovementStyle", 0);
									_mount:ToCharacter():Stop();
									_mount:ToCharacter():FallDown();
								end
							end
						end
					end
					local _player = MyCompany.Aries.Pet.GetUserCharacterObj(nid);
					if(_player and _player:IsValid() == true) then
						if(string.find(_player.name, "driver")) then
							System.Animation.PlayAnimationFile({
								"character/Animation/v5/ElfFemale_tumble.x", 
								"character/Animation/v5/DefaultMount.x", 
							}, _player);
							-- play mounted pet animation
							local _mount = MyCompany.Aries.Pet.GetUserMountObj(nid);
							if(_mount and _mount:IsValid() == true) then
								-- play the faint animation no matter if the dragon is in minor or major stage
								System.Animation.PlayAnimationFile("character/Animation/v5/dalong/PurpleDragoonMajorFemale_faint.x", _mount);
								local _mount_name = _mount.name;
								local cancelAnim = false;
								UIAnimManager.PlayCustomAnimation(2500, function(elapsedTime)
									if(cancelAnim == false) then
										local _mount = ParaScene.GetCharacter(_mount_name);
										if(_mount and _mount:IsValid() == true) then
											local animID = _mount:GetAnimation();
											if(animID == 0) then
												System.Animation.PlayAnimationFile("character/Animation/v5/dalong/PurpleDragoonMajorFemale_faint.x", _mount);
												cancelAnim = true;
											end
										end
									end
								end);
							end
						else
							System.Animation.PlayAnimationFile("character/Animation/v5/ElfFemale_tumble.x", _player);
						end
					end
				end

			end
		elseif(msg and msg.throwItem and msg.throwItem.gsid == 9504) then
			local nid = tonumber(obj.name) or tonumber(string.match(obj.name, "^(%d+)+driver"));
			if(nid) then
				-- check if user is immune to snow ball hit
				local isImmuneToIceFreeze = false;
				local player = ParaScene.GetObject(tostring(nid));
				if(player:IsValid()) then
					local att = player:GetAttributeObject();
					isImmuneToIceFreeze = att:GetDynamicField("IsImmuneToIceFreeze", false);
				end
				if(nid == System.App.profiles.ProfileManager.GetNID()) then
					if(isImmuneToIceFreeze ~= true) then
						MyCompany.Aries.Player.HitBySnowBall(msg.nid);
						System.Item.ItemManager.RefreshMyself();
					end
				else
					if(isImmuneToIceFreeze ~= true) then
						MyCompany.Aries.Pet.RefreshOPC_CCS(nid, {[35]=1});
					end
					if(msg.nid == System.App.profiles.ProfileManager.GetNID()) then
						MyCompany.Aries.Player.HitOtherWithSnowBall(nid, obj);
					end
				end
			end
		elseif(msg and msg.throwItem and msg.throwItem.gsid == 9502) then
			local nid = tonumber(obj.name) or tonumber(string.match(obj.name, "^(%d+)+driver"));
			if(nid) then
				if(nid == System.App.profiles.ProfileManager.GetNID()) then
					MyCompany.Aries.Player.HitByJelly();
					System.Item.ItemManager.RefreshMyself();
				else
					MyCompany.Aries.Pet.RefreshOPC_CCS(nid, {[35]=0});
				end
			end
		end
		if(msg and msg.throwItem) then
			if(ParaScene.GetPlayer():DistanceTo(obj) < 25) then
				--local name = "Btn2";
				--if(msg.throwItem.gsid == 9501) then
					--name = "Btn2";
				--elseif(msg.throwItem.gsid == 9502) then
					--name = "Btn7";
				--elseif(msg.throwItem.gsid == 9503) then
					--name = "ArcaneExplode";
				--end
				--local dx, dy, dz = obj:GetPosition();
				--ParaAudio.PlayStatic3DSound(name, "HitThrowBall_"..ParaGlobal.GenerateUniqueID(), dx, dy, dz);
				
				--local name = "Audio/Haqi/Button02.wav";
				--if(msg.throwItem.gsid == 9501) then
					--name = "Audio/Haqi/Button02.wav";
				--elseif(msg.throwItem.gsid == 9502) then
					--name = "Audio/Haqi/Button07.wav";
				--elseif(msg.throwItem.gsid == 9503) then
					--name = "Audio/Haqi/ArcaneExplode.wav";
				--end
				--MyCompany.Aries.Scene.PlayGameSound(name);
			end
		end
	end
end
--锁定被击中的对象的名称，空为没有
function ThrowBall:GetWillbeAttackedObject(endPoint)
	if(not endPoint)then return end
	local fromX,fromY,fromZ = endPoint.x,endPoint.y,endPoint.z;
	if(not fromX or not fromY or not fromZ)then return end
	local objlist = {};
	local radius = Map3DSystem.App.HomeLand.HomeLandConfig.Throwball_OnHit_FindRadius or 1;
	NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
	local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
	local ballgsid = self.throwItem.gsid
	--local specificBall = {[9506] = true,[9507] = true,[9508] = true,[9509] = true,}
	local specificBall = {
		[9506] = {19911.64,3.30,20016.66,radius = 20,npcid = 30204,},
		[9508] = {19893.68,-2.46,19759.98,radius = 20,npcid = 30205,},
		[9507] = {19909.67,3.32,20015.87,radius = 40,npcid = 30549,},
		[9509] = {19891.18,-2.45,19757.13,radius = 40,npcid = 30548,},
		--[9507] = {radius = 20,npcid = 30549,},
		--[9509] = {radius = 20,npcid = 30548,},
	}
	if(CommonClientService.IsKidsVersion() and specificBall[ballgsid]) then
		radius = specificBall[ballgsid]["radius"];
	end
	local nCount = ParaScene.GetObjectsBySphere(objlist, fromX,fromY,fromZ, radius, "biped");
	--commonlib.echo("=============objlist");
	--if(nCount > 0)then
		--local k = 1;
		--for k = 1,nCount do
			--local obj = objlist[k];
			--if(obj and obj:IsValid())then
				--local name = obj.name;
				--if(name and name ~= self.playerName)then
					--commonlib.echo(name);
				--end
			--end
		--end
	--end
	--if(nCount > 0)then
		--local k = 1;
		--for k = 1,nCount do
			--local obj = objlist[nCount - k + 1];
			--if(obj and obj:IsValid())then
				--local name = obj.name;
				--if(name and name ~= self.playerName)then
					--return name;
				--end
			--end
		--end
	--end
	local inSepcialArea = false;
	local npcid;
	local gsid,posNode;
	for gsid ,posNode in pairs(specificBall) do
		if(gsid == ballgsid) then
			if(posNode[1] and posNode[3]) then
				local posX ,posZ =  posNode[1] ,posNode[3];
				local radius = posNode.radius;
				if(math.abs(posX - fromX) <= radius and math.abs(posZ - fromZ) <= radius) then
					inSepcialArea = true;
					npcid = posNode.npcid;
				end
			else
				inSepcialArea = true;
				npcid = posNode.npcid;
			end
			
		end	
	end
	local temp = {};
	local player = ParaScene.GetObject(self.playerName or "");
	if(nCount > 0 and player and player:IsValid())then
		local k = 1;
		for k = 1,nCount do
			local obj = objlist[k];
			if(obj and obj:IsValid())then
				local name = obj.name;
				if(name and name ~= self.playerName)then
					local dist = player:DistanceTo(obj);
					--echo("XXXXXXXXXXXX");
					--echo(npcid);
					if(inSepcialArea) then
						if(string.match(name,npcid)) then
							table.insert(temp,{dist = dist,name = name});
						end
					else
						table.insert(temp,{dist = dist,name = name});
					end
				end
			end
		end
		--echo(temp);
		table.sort(temp,function(a, b) return (a.dist < b.dist) end)
		local r = temp[1];
		if(r)then
			return r.name;
		end
	end
end
function ThrowBall:GetThrowMsg()
	local startPoint = self.startPoint;
	local endPoint = self.endPoint;
	local playerName = self.playerName;
	local nid = self.nid;
	local throwItem = self.throwItem;
	local throwerState = self.throwerState;
	local throwerLevel = self.throwerLevel;
	local attackedName = self.attackedName;
	local msg = {
		 playerName = playerName,
		 nid = nid, 
		 throwItem = throwItem, 
		 throwerState = throwerState, 
		 throwerLevel = throwerLevel, 
		 startPoint = startPoint, 
		 endPoint = endPoint,
		 hitObjNameList = self.hitObjNameList,
		 attackedName = attackedName,
	 }
	return msg;
end
-- 存储用于创建动画的displayobject 的专用Scene
function ThrowBall.GetScene()
	if(not ThrowBall._scene)then
		NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
		local scene = CommonCtrl.Display.Containers.MiniScene:new()
		scene:Init();
		ThrowBall._scene = scene;		
	end
	return ThrowBall._scene;
end
function ThrowBall.RegHook(playerName,nid,throwItem,throwerState,throwerLevel)
	if(not playerName or not nid or not throwItem)then return end
	-- 改变鼠标样式
	Map3DSystem.UI.Cursor.LockCursor("throw");

	-- ParaUI.SetCursorFromFile("Texture/Aries/Cursor/fire.tga",16,16);
	--ParaUI.GetUIObject("root").cursor = "Texture/Aries/Cursor/fire.tga";
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "ThrowBall_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = ThrowBall.OnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "ThrowBall_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = ThrowBall.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "ThrowBall_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = ThrowBall.OnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook(o);
	
	local style = style or ThrowBall.ballStyle;
	local throwBall = CommonCtrl.ThrowBall:new{
				playerName = playerName,
				nid = nid,
				throwItem = throwItem,
				throwerState = throwerState,
				throwerLevel = throwerLevel,
				ballStyle =  throwItem.style or ThrowBall.style,
				throwType = "myself",
			}
	ThrowBall.globalInstance = throwBall;
	return throwBall;
end
function ThrowBall.UnHook()
	-- 恢复鼠标样式
	Map3DSystem.UI.Cursor.UnlockCursor();
	-- ParaUI.SetCursorFromFile("Texture/kidui/main/cursor.tga",3,4);
	--ParaUI.GetUIObject("root").cursor = "Texture/kidui/main/cursor.tga";
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "ThrowBall_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "ThrowBall_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "ThrowBall_mouse_up_hook", hookType = hookType});
end
function ThrowBall.OnMouseDown(nCode, appName, msg)
	local self = ThrowBall;
	if(msg.mouse_button == "left")then	
		if(self.press)then
			return 
		end
		self.press = true;
		local obj;
		if(not Map3DSystem.App.HomeLand.HomeLandGateway.IsInCandyHome())then
			obj = ParaScene.MousePick(40, "notplayer");
			if(obj and obj:IsValid() == false) then	
				obj = ParaScene.MousePick(40, "point");
			end
		else
			obj = ParaScene.MousePick(40, "point");
			if(obj and obj:IsValid() == false) then	
				obj = ParaScene.MousePick(40, "notplayer");
			end
		end
		if(obj and obj:IsValid()) then	
			if(self.globalInstance)then
				local throwBall = self.globalInstance;
				local player = ParaScene.GetObject(throwBall.playerName);
				if(player and player:IsValid())then	
					local x,y,z = player:GetPosition();
					local h = player:GetPhysicsRadius();
					local startPoint = {x = x,y = y+h,z = z};
					x,y,z = obj:GetPosition();
					local endPoint = {x = x,y = y,z = z};
					
					--本机投掷的时候在投掷结束后再 发送投掷消息
					--local attackedName = throwBall:GetWillbeAttackedObject(endPoint);
					throwBall.startPoint = startPoint;
					throwBall.endPoint = endPoint;
					--throwBall.attackedName = attackedName;
					if(throwBall:CanThrow())then
						throwBall:Play();
					else
						if(throwBall.OnDisabled)then
							throwBall.OnDisabled(throwBall);
						end
					end
				end
			end
		else
			local throwBall = self.globalInstance;
			if(throwBall and throwBall.OnDisabled)then
				throwBall.OnDisabled(throwBall);
			end
		end	
	end
end
function ThrowBall.OnMouseMove(nCode, appName, msg)
	local self = ThrowBall;
	local pt = ParaScene.MousePick(70, "point");
	if(pt:IsValid() and not self.press)then
		local x, y, z = pt:GetPosition();
		Map3DSystem.Animation.SendMeMessage({type = Map3DSystem.msg.ANIMATION_Character, animationName = "",facingTarget = {x=x, y=y, z=z},});
	end
end
function ThrowBall.OnMouseUp(nCode, appName, msg)
	local self = ThrowBall;
	if(msg.mouse_button == "left")then	
		self.press = false;
		local throwBall = self.globalInstance;
		if(throwBall)then
			self.UnHook();
		end
	end
end
--[[
local msg = {
		 playerName = playerName,
		 nid = nid, 
		 throwItem = throwItem, 
		 throwerState = throwerState, 
		 throwerLevel = throwerLevel, 
		 startPoint = startPoint, 
		 endPoint = endPoint,
	 }
NPL.load("(gl)script/ide/ThrowBall.lua");
local msg = {
	  endPoint={ x=20064.72265625, y=0.22082607448101, z=19823.283203125 },
	  nid=16344,
	  playerName="leio",
	  startPoint={ x=20065.27734375, y=0.49730199575424, z=19817.572265625 },
	  throwItem={
		gsid=9503,
		hitstyle="model/07effect/v5/Firecracker/Firecracker1.x",
		style="model/06props/shared/pops/box.x" 
	  },
	  throwerLevel=3,
	  throwerState="home" 
}
NPL.load("(gl)script/ide/ThrowBall.lua");
local msg ={
  endPoint={ x=20075.271484375, y=0.40352022647858, z=19822.4921875 },
  nid=16344,
  playerName="leio",
  startPoint={ x=20073.041015625, y=0.96261250972748, z=19818.970703125 },
  throwItem={
    gsid=9502,
    hitstyle="model/07effect/v5/Jelly/Jelly1.x",
    style="model/07effect/v5/Jelly/Jelly.x" 
  },
  throwerLevel=1,
  throwerState="home" 
}
CommonCtrl.ThrowBall.HandleMessage(msg);
--]]
function ThrowBall.HandleMessage(msg)
	local self = ThrowBall;
	--LOG.debug("Before ThrowBall.HandleMessage");
	--LOG.debug(msg);
	if(not msg)then return end;
	if(type(msg) == "string")then
		msg = NPL.LoadTableFromString(msg);
	end
	--commonlib.echo("=====LoadTableFromString");
	--commonlib.echo(msg);
	if(type(msg) ~= "table")then
		LOG.error("ThrowBall.HandleMessage==== not table");
		return
	end
	msg = ThrowBall.msg_decoder(msg)
	
	--commonlib.echo("ThrowBall.HandleMessage");
	--commonlib.echo(msg);
	if(not msg)then return end
	
	local playerName = msg.playerName;
	local nid = msg.nid;
	local throwItem = msg.throwItem;
	local throwerState = msg.throwerState;
	local throwerLevel = msg.throwerLevel;
	local startPoint = msg.startPoint;
	local endPoint = msg.endPoint;
	local attackedName = msg.attackedName;
	local ballStyle;
	if(throwItem)then
		if(throwItem.gsid) then
			if(ThrowablePage.ballList[throwItem.gsid]) then
				local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(throwItem.gsid);
				ballStyle = gsItem.assetfile or throwItem.style;
			elseif(throwItem.gsid == 0) then
				LOG.std(nil, "System", "ThrowBall", "the %d throw a fish net.", nid or "");
				ballStyle = throwItem.style;
			else
				LOG.std(nil, "error", "ThrowBall", "the throw gsid %d is not valid. nid %s!", throwItem.gsid or 0, nid or "");
				return;
			end
		else
			ballStyle = throwItem.style;
		end
	end
	
	local name = msg.name;
	--local host_player = ParaScene.GetPlayer();
	--if(host_player.name == playerName)then return end
	if(startPoint)then
		-- 如果投掷的起始点 距离自己 大于 50 米 不接受投掷消息
		local x,y,z = ParaScene.GetPlayer():GetPosition();
		local _x,_y,_z = startPoint.x,startPoint.y,startPoint.z;
		local dis_x = x - _x;
		local dis_z = z - _z;
		local disSq = dis_x * dis_x + dis_z * dis_z
		if(disSq <self.maxDisSq)then
			local throwBall = CommonCtrl.ThrowBall:new{
					startPoint = startPoint,
					endPoint = endPoint,
					ballStyle =  ballStyle or ThrowBall.style,
					playerName = playerName,
					nid = nid,
					throwItem = throwItem,
					throwerState = throwerState,
					throwerLevel = throwerLevel,
					throwType = "machine",
					attackedName = attackedName,
				}
			local player = ParaScene.GetObject(tostring(nid));
			if(not player)then
				LOG.error("没有找到投掷者[%s][%s],投掷停止",tostring(nid),tostring(playerName));
				return
			end
			throwBall:Play();
		end
	end
end
--[[
echo:return {
  endPoint={ x=20057.67, y=0.46, z=19725.46 },
  hitObjNameList={  },
  nid=86657270,
  playerName="86657270",
  startPoint={ x=20052.63, y=1.36, z=19726.86 },
  throwItem={
    gsid=9501,
    hitstyle="model/07effect/v5/WaterBalloon/WaterBalloon1.x",
    showpic="Texture/Aries/Smiley/animated/face10_32bits_fps10_a005.png",
    style="model/07effect/v5/WaterBalloon/WaterBalloon.x" 
  },
  throwerLevel=1,
  throwerState="home" 
}
--]]
function ThrowBall.InitEncoderMap()
	local self = ThrowBall;
	if(not self.throw_stringmap)then
		NPL.load("(gl)script/ide/stringmap.lua");
		local throw_stringmap = commonlib.stringmap:new()
		throw_stringmap:add("home");
		throw_stringmap:add("model/07effect/v5/WaterBalloon/WaterBalloon.x");
		throw_stringmap:add("model/07effect/v5/WaterBalloon/WaterBalloon1.x");
		throw_stringmap:add("model/07effect/v5/Jelly/Jelly.x");
		throw_stringmap:add("model/07effect/v5/Jelly/Jelly1.x");
		throw_stringmap:add("model/07effect/v5/Firecracker/Firecracker.x");
		throw_stringmap:add("model/07effect/v5/Firecracker/Firecracker1.x");
		throw_stringmap:add("model/07effect/v5/SnowBalloon/SnowBalloon.x");
		throw_stringmap:add("model/07effect/v5/SnowBalloon/SnowBalloon1.x");
		throw_stringmap:add("Texture/Aries/Smiley/animated/face10_32bits_fps10_a005.png");
		throw_stringmap:add("Texture/Aries/Smiley/face15_32bits.png");
		
		self.throw_stringmap = throw_stringmap;
		
	end
	if(not self.encoder_map)then
		local encoder_map = 
		{
			{key="nid"},
			{key="playerName"},
			{key="throwerLevel"},
			{key="hitObjNameList"},
			{key="throwerState", type="string", stringmap = self.throw_stringmap},
			{key="startPoint.x", type="pos", origin=20000, },
			{key="startPoint.y", type="pos", origin=0, },
			{key="startPoint.z", type="pos", origin=20000, },
			{key="endPoint.x", type="pos", origin=20000, },
			{key="endPoint.y", type="pos", origin=0, },
			{key="endPoint.z", type="pos", origin=20000, },
			
			{key="throwItem.gsid", type="pos", origin=0, },
			{key="throwItem.hitstyle", type="string", stringmap = self.throw_stringmap},
			{key="throwItem.showpic", type="string", stringmap = self.throw_stringmap},
			{key="throwItem.style", type="string", stringmap = self.throw_stringmap},
		}
		self.encoder_map = encoder_map;
	end
end
--初始化编码
ThrowBall.InitEncoderMap();
-- return a compressed table array 
function ThrowBall.msg_encoder(input)
	local self = ThrowBall;
	if(not input)then return end
	-- the compressed table array
	local output = {};
	local index, codec
	for index, codec in ipairs(self.encoder_map) do
		local value = commonlib.getfield(codec.key, input);
		if(not codec.type) then
		elseif(codec.type == "pos") then
			if(codec.origin) then
				value = value - codec.origin
				value = ThrowBall.Float2(value);
			end	
		elseif(codec.type == "string") then	
			if(codec.stringmap) then
				value = codec.stringmap(value) or value;
			end
		end
		output[index] = value;
	end
	return output;
end

function ThrowBall.msg_decoder(input)
	local self = ThrowBall;
	if(not input)then return end
	-- the compressed table array
	local output = {};
	local index, value
	for index, value in ipairs(input) do
		local codec = self.encoder_map[index];
		if(not codec) then
			break;
		end
		if(not codec.type) then
		elseif(codec.type == "pos") then
			if(codec.origin) then
				value = value + codec.origin
				value = ThrowBall.Float2(value);
			end	
		elseif(codec.type == "string") then	
			if(codec.stringmap) then
				if(type(value) == "number") then
					value = codec.stringmap(value);
				end	
			end
		end
		commonlib.setfield(codec.key, value, output);
	end
	return output;
end
function ThrowBall.Float2(data)
	if(type(data) == "number") then
		local v = string.format("%.2f", data);
		v = tonumber(v);
		return v;
	end	
end