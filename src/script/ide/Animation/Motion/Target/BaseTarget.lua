--[[
Title: BaseTarget
Author(s): Leio Zhang
Date: 2008/10/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua");
------------------------------------------------------------
]]
local BaseTarget = {
	Property = "BaseTarget",
	NoOutPut = {Property = 0,ID = 0,Owner = 0},
}
commonlib.setfield("CommonCtrl.Animation.Motion.BaseTarget",BaseTarget);
function BaseTarget:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()
	return o
end
function BaseTarget:Initialization()
	--self.name = ParaGlobal.GenerateUniqueID();
end
function BaseTarget:GetDefaultProperty()
end
function BaseTarget:Update()
end
function BaseTarget:FormatNumberValue(v)
	if( v and type(v) == "number")then
		v = string.format("%.2f",v);
		v = tonumber(v);
		return v;
	end
	return v;
end
function BaseTarget:GetName()
	local owner = self.Owner;
	if(owner)then
		local keyFrames = owner:GetParent();
		if(keyFrames)then
			local name = keyFrames.TargetName or keyFrames.TargetProperty;
			return name;
		end
	end
end
function BaseTarget:GetEffectInstance()
	local owner = self.Owner;
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

function BaseTarget:GetParentKeyFrames()
	local owner = self.Owner;
	if(owner)then
		local keyFrames = owner:GetParent();
		if(keyFrames)then
			return keyFrames;
		end
	end
end
function BaseTarget:UpdatParentFrames(TargetName,TargetProperty)
	local keyFrames = self:GetParentKeyFrames()
	if(keyFrames)then
		keyFrames.TargetName = TargetName;
		keyFrames.TargetProperty = TargetProperty;
	end
end
function BaseTarget:__GetDifference(pro,result,curTarget,nextTarget)
	if(not pro or not result or not curTarget or not nextTarget)then return; end
	local cur = curTarget[pro];
	local next = nextTarget[pro]
	if( cur and type(cur)=="number" and next and type(next)=="number")then
		self:FormatNumberValue(cur);
		self:FormatNumberValue(next);
		result[pro] = {begin = cur,change = (next - cur)};
	end
end
function BaseTarget:ReverseToMcml()
	local mcmlTitle = self.Property;
	local k,v;
	local result = "";
	for k,v in pairs(self) do
		if(self.CanOutPut)then
			if(self.CanOutPut[k] == 0)then
				v = self:FormatNumberValue(v);
				v = tostring(v) or "";
				local s = string.format('%s="%s" ',k,v);
				result = result .. s;
			end
		else
			if(self.NoOutPut[k] ~= 0)then
				v = self:FormatNumberValue(v);
				v = tostring(v) or "";
				local s = string.format('%s="%s" ',k,v);
				result = result .. s;
			end
		end		
	end
	local str = string.format([[<%s %s/>]],
			mcmlTitle,result);
	return str;
end