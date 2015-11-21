--[[
Title: Target
Author(s): Leio Zhang
Date: 2009/3/26
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/Target.lua");
------------------------------------------------------------
]]
local Target = {
	params = {
		bindObjName = "",
		X = 0,
		Y = 0,
		Z = 0,
		Alpha = 1,
		Facing = 1,
		Scaling = 1,
		Visible = true,
		Animation = "",
		Dialog = "",
	},
}
commonlib.setfield("CommonCtrl.Storyboard.Target",Target);
function Target:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()
	return o
end
function Target:Initialization()
	--self.name = ParaGlobal.GenerateUniqueID();
	
end
function Target:SetParent(v)
	self.parent = v;
end
function Target:GetParent()
	return self.parent;
end
function Target:GetBindObjName()
	local parent = self:GetParent();
	if(parent)then
		parent = parent:GetParent();
		if(parent)then
			return parent:GetTargetName();
		end
	end
end
function Target:GetParams()
	local params = commonlib.deepcopy(self.params)
	params.bindObjName = self:GetBindObjName();
	return params;
end
function Target:SetParams(params)
	if(type(params)~="table")then return end
	self.params = params;
end
function Target.CheckValue(params)
	if(not params)then return end
	params.Facing = tonumber(params.Facing) or 1;
	params.X = tonumber(params.X) or 255;
	params.Y = tonumber(params.Y) or 0;
	params.Z = tonumber(params.Z) or 255;
	params.Scaling = tonumber(params.Scaling) or 1;
	params.Facing = tonumber(params.Facing) or 1;
	params.Alpha = tonumber(params.Alpha) or 1;
	if(params.Visible == nil)then
		params.Visible = true;
	end
end
function Target.Update(params,curKeyframe)
	if(not params)then return end
	local name = params.bindObjName;
	if(not name)then return end
	Target.CheckValue(params);
	if(name == "sender" or name == "receiver")then	
				local player = ParaScene.GetPlayer();
				if(player:IsValid())then
					player:SetVisible(params.Visible);
					if(params.Visible)then	
						local _x,_y,_z = player:GetPosition();
						_x = params.X + _x;
						_y = params.Y + _y;
						_z = params.Z + _z;
						player:SetPosition(_x,_y,_z);		
						player:SetFacing(params.Facing);
						player:SetScale(params.Scaling);
					end
					-- update special value
					if(not curKeyframe)then return; end
					local isActivate = curKeyframe:GetActivate();		
					if(isActivate)then
						player:ToCharacter():Stop();
				
						Map3DSystem.Animation.PlayAnimationFile(params.Animation, player);
						if(params.Dialog ~="")then
							headon_speech.Speek(player.name, params.Dialog, math.random(4));
						end
					end
				end			
	else	
		local obj = CommonCtrl.Storyboard.Storyboard.GetHookObj(name)
		if(not obj)then return; end	
		obj:SetVisible(params.Visible);
		if(params.Visible)then	
			obj:SetPositionDelta(params.delta_X,params.delta_Y,params.delta_Z);	
			--obj:SetPosition(params.X,params.Y,params.Z);		
			obj:SetFacing(params.Facing);
			obj:SetScaling(params.Scaling);
			obj:SetAlpha(params.Alpha);
		end
	end
end
function Target:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = {};
	self:__GetDifference("Facing",result,curTarget,nextTarget);
	self:__GetDifference("X",result,curTarget,nextTarget);
	self:__GetDifference("Y",result,curTarget,nextTarget);
	self:__GetDifference("Z",result,curTarget,nextTarget);
	self:__GetDifference("Alpha",result,curTarget,nextTarget);
	self:__GetDifference("Scaling",result,curTarget,nextTarget);
	return result;
end
function Target:__GetDifference(pro,result,curTarget,nextTarget)
	if(not pro or not result or not curTarget or not nextTarget)then return; end
	local cur = curTarget["params"][pro];
	local next = nextTarget["params"][pro];
	if( cur and type(cur)=="number" and next and type(next)=="number")then
		self:FormatNumberValue(cur);
		self:FormatNumberValue(next);
		result[pro] = {begin = cur,change = (next - cur)};
	end
end
function Target:FormatNumberValue(v)
	if( v and type(v) == "number")then
		v = string.format("%.2f",v);
		v = tonumber(v);
		return v;
	end
	return v;
end

function Target:GetEffectInstance()
	local owner = self:GetParent();
	if(owner)then
		local keyFrames = owner:GetParent();
		if(keyFrames)then
			local root = keyFrames:GetRoot();
			if(root)then
				return root:GetEffectInstance();
			end
		end
	end
end