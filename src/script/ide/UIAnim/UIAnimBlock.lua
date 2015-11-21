--[[
Title: UI Animation
Author(s): WangTian
Date: 2007/9/29
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UIAnim/UIAnimBlock.lua");

local ctl = UIAnimBlock:new{
	name = "UIAnimBlock1",
	text = "blarrrr",
	... = 0,
	*** = 300,
	};
ctl:getValue(1, 400);
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/mathlib.lua");
local mathlib = commonlib.gettable("mathlib");
local commonlib = commonlib;
local UIAnimBlock = commonlib.gettable("UIAnimBlock")

local AllObjects = {};
local AutoCounter = 1;

function UIAnimBlock:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	if(o.name ~= nil and type(o.name) == "string") then
		UIAnimBlock.AddObject(o.name, o);
	else
		UIAnimBlock.AddObject("AutoObj_"..AutoCounter, o);
		o.name = "AutoObj_"..AutoCounter;
		AutoCounter = AutoCounter + 1;
	end
	
	o.type = "Linear"; -- or Hermite or "LinearAngle"
	o.used = true;
	o.tableType = "UIAnimBlock";
	
	return o;
end

function UIAnimBlock:Destroy()
	UIAnimBlock.DeleteObject(self.name);
	self = nil; -- TODO: still not nil
end

function UIAnimBlock.AddObject(ObjName, obj)
	AllObjects[ObjName] = obj;
end

function UIAnimBlock.DeleteObject(ObjName)
	local obj = AllObjects[ObjName];
	if(obj~=nil) then
		AllObjects[ObjName] = nil;
	end
end

-- if all animated values equals to the key, this animation will be set unused
function UIAnimBlock:SetConstantKey(key)
	if(self.data) then
		local nSize = #(self.data);
		local i;
		for i = 1, nSize do
			if(self.data[i] ~= key) then
				return;
			end
		end
		self.used = false;
	end
end

-- if all animated values are very close to a given key, this animation will be set unused
function UIAnimBlock:SetConstantKey(key, fEpsilon)
	if(self.data) then
		local nSize = #(self.data);
		local i;
		for i = 1, nSize do
			if(commonlib.Absolute(self.data[i] - key) > fEpsilon) then
				return;
			end
		end
		self.used = false;
	end
end

-- default value
function UIAnimBlock:getDefaultValue()
	return self.data[1];
end

-- get value with motion blending with a specified blending frame.
-- @param nCurrentAnim: current animation sequence ID
-- @param currentFrame: an absolute ParaX frame number denoting the current animation frame. It is always within
--		the range of the current animation sequence's start and end frame number.
-- @param nBlendingAnim: the animation sequence with which the current animation should be blended.
-- @param blendingFrame: an absolute ParaX frame number denoting the blending animation frame. It is always within
--		the range of the blending animation sequence's start and end frame number.
-- @param blendingFactor: by how much the blending frame should be blended with the current frame. 
--		1.0 will use solely the blending frame, whereas 0.0 will use only the current frame.
--		[0,1), blendingFrame*(blendingFactor)+(1-blendingFactor)*currentFrame
function UIAnimBlock:getValue(nCurrentAnim, currentFrame, nBlendingAnim, blendingFrame, blendingFactor)
	if(blendingFactor == 0) then
		return self:getValue(nCurrentAnim, currentFrame);
	elseif(blendingFactor == 1) then
		return self:getValue(nBlendingAnim, blendingFrame);
	else
		local v1 = self:getValue(nCurrentAnim, currentFrame);
		local v2 = self:getValue(nBlendingAnim, blendingFrame);
		
		return self:InterpolateLinear(blendingFactor, v1, v2);
	end
end

-- it accept anim index of both local and external animation
-- rangeID: Index.nIndex
-- time: Index.nCurrentFrame
function UIAnimBlock:getValue(Index)
	return self:getValue(Index.nIndex, Index.nCurrentFrame);
end

-- it accept anim index of both local and external animation
-- rangeID: CurrentAnim.nIndex, BlendingAnim.nIndex
-- time: CurrentAnim.nCurrentFrame, BlendingAnim.nCurrentFrame
function UIAnimBlock:getValue(CurrentAnim, BlendingAnim, blendingFactor)
	
	if(blendingFactor == 0) then
		return self:getValue(CurrentAnim);
	elseif(blendingFactor == 1) then
		return self:getValue(BlendingAnim);
	else
		local v1 = self:getValue(CurrentAnim);
		local v2 = self:getValue(BlendingAnim);

		return self:InterpolateLinear(blendingFactor, v1, v2);
	end
end
	
-- this function will return the interpolated animation vector at the specified anim id and frame number
-- anim: RangeID
-- time: frame number,  1 milsec = 1 frame
function UIAnimBlock:getValue(anim, time)
	local rangesCount = #(self.ranges);
	local timesCount = #(self.times);
	local dataCount = #(self.data);
	if(self.type ~= "NONE" and dataCount > 1) then
		
		local range;

		-- obtain a time value and a data range, and get the range according to the current animation.
		if(anim > 0 and anim <= rangesCount) then
			range = self.ranges[anim];
		else
			-- default value
			return self.data[1];
		end
		
		if(range[1] ~= range[2]) then
			local pos = range[1]; -- this can be 0.
			
			local nStart = range[1];
			local nEnd = range[2];
			
			if(time >= self.times[nEnd]) then
				return self.data[nEnd];
			end
			
			while(true) do
			
				if(nStart >= nEnd) then
					-- if no item left.
					pos = nStart;
					break;
				end
				
				local nMid;
				if( ((nStart + nEnd)%2) == 1 ) then
					nMid = (nStart + nEnd - 1)/2;
				else
					nMid = (nStart + nEnd)/2;
				end
				
				local startP = (self.times[nMid]);
				local endP = (self.times[nMid + 1]);

				if(startP <= time and time < endP ) then
					-- if (middle item is target)
					pos = nMid;
					break;
				elseif(time < startP ) then
					-- if (target < middle item)
					nEnd = nMid;
				elseif(time >= endP) then
					-- if (target >= middle item)
					nStart = nMid+1;
				end
			end -- while(nStart<=nEnd)
			
			
			local t1 = self.times[pos];
			local t2 = self.times[pos + 1];
			
			local r = (time-t1)/(t2-t1);

			if (self.type == "Linear") then
				-- interpolate linear
				return self:InterpolateLinear(r, self.data[pos], self.data[pos+1]);
			elseif (self.type == "LinearAngle") then
				return self:InterpolateLinearAngle(r, self.data[pos], self.data[pos+1]);
			elseif (self.type == "Hermite") then
				-- HERMITE
				log("error: Caution inVal and outVal table are empty right now\r\n");
				return self:InterpolateHermite(r, self.data[pos], self.data[pos+1], self.inVal[pos], self.outVal[pos]);
			end
		else
			return self.data[range[1]];
		end
		
	else
		-- default value
		return self.data[1];
	end
end

-- linear interpolation
function UIAnimBlock:InterpolateLinear(range, v1, v2)
	return  (v1 * (1.0 - range) + v2 * range);
end

-- linear interpolation
function UIAnimBlock:InterpolateLinearAngle(range, v1, v2)
	local delta = mathlib.ToStandardAngle(v2-v1);
	return mathlib.ToStandardAngle(v1 + delta * range);
end


-- blend the two values use linear interpolation
function UIAnimBlock:BlendValues(currentValue, blendingValue, blendingFactor)
	if(blendingFactor == 0) then
		return currentValue;
	elseif(blendingFactor == 1) then
		return blendingValue;
	else
		return self:InterpolateLinear(blendingFactor, currentValue, blendingValue);
	end
end

-- hermite interpolation
function UIAnimBlock:InterpolateHermite(range, v1, v2, inVal, outVal)

	local h1 = 2.0*range*range*range - 3.0*range*range + 1.0;
	local h2 = -2.0*range*range*range + 3.0*range*range;
	local h3 = range*range*range - 2.0*range*range + range;
	local h4 = range*range*range - range*range;
	
	return (v1*h1 + v2*h2 + inVal*h3 + outVal*h4);
end

function UIAnimBlock:SetRangeByIndex(index, rangeFirst, rangeSecond)
	if(not self.ranges[index]) then
		self.ranges[index] = {};
	end
	self.ranges[index] = {rangeFirst, rangeSecond};
end

function UIAnimBlock:AppendKey(time, data)
	local timesCount = #(self.times);
	local dataCount = #(self.data);
	self.times[timesCount + 1] = time;
	self.data[dataCount + 1] = data;
end

function UIAnimBlock:UpdateLastKey(time, data)

	local timesCount = #(self.times);
	local dataCount = #(self.data);
	if(timesCount == dataCount) then
		if(timesCount > 0) then
			self.times[timesCount] = time;
			self.data[timesCount] = data;
		else
			self:AppendKey(time, data)
		end
	else
		log("error: Caution times and data table counts are not equal.\r\n");
	end
end

function UIAnimBlock:GetKeyNum()
	local timesCount = #(self.times);
	local dataCount = #(self.data);
	if(timesCount == dataCount) then
		return dataCount;
	else
		log("error: Caution times and data table counts are not equal.\r\n");
	end
end

function UIAnimBlock:GetRangeTimeInterval(index)
	if(not self.ranges[index]) then
		return 0;
	end
	--log("timetag1: "..self.ranges[index][2].." timetag2:"..self.ranges[index][1].."\r\n");
	--log("time1: "..self.times[self.ranges[index][2]].." time2:"..self.times[self.ranges[index][1]].."\r\n");
	return self.times[self.ranges[index][2]] - self.times[self.ranges[index][1]];
end

function UIAnimBlock:BuildBasicAnimTable()
	local UIAnimFile = {};
	UIAnimFile = {
		["UIAnimation"] = {
			[1] = {
				["ScaleX"] = {
					["ranges"] = {
						[1] = {		1,			2},
						[2] = {					2,			3},
					},
					["times"] = {  [1] = 0,	   [2] = 7,	   [3]= 15,
								 ---|-----------|-----------|-----------|
					},
					["data"] = {   [1] = 0,	   [2] = 1,	   [3]= 0,
								 ---|-----------|-----------|-----------|
					},
				},
				["ScaleY"] = {
					["ranges"] = {
						[1] = {		1,			2},
						[2] = {					2,			3},
					},
					["times"] = {  [1] = 0,	   [2] = 7,	   [3]= 15,
								 ---|-----------|-----------|-----------|
					},
					["data"] = {   [1] = 0,	   [2] = 1,	   [3]= 0,
								 ---|-----------|-----------|-----------|
					},
				},
				["TranslationX"] = {
					["ranges"] = {
						[3] = {		1,			2},
						[4] = {					2,			3},
					},
					["times"] = {  [1] = 0,	   [2] = 7,	   [3]= 15,
								 ---|-----------|-----------|-----------|
					},
					["data"] = {   [1] = 0,	   [2] = 0,    [3]= 0,
								 ---|-----------|-----------|-----------|
					},
				},
				["TranslationY"] = {
					["ranges"] = {
						[3] = {		1,			2},
						[4] = {					2,			3},
					},
					["times"] = {  [1] = 0,	   [2] = 7,	   [3]= 15,
								 ---|-----------|-----------|-----------|
					},
					["data"] = {   [1] = 0,	   [2] = -20,  [3]= 0,
								 ---|-----------|-----------|-----------|
					},
				},
				["Rotation"] = {
					["ranges"] = {
					},
					["times"] = {
					},
					["data"] = {
					},
				},
				["RotateOriginX"] = {
					["ranges"] = {
					},
					["times"] = {
					},
					["data"] = {
					},
				},
				["RotateOriginY"] = {
					["ranges"] = {
					},
					["times"] = {
					},
					["data"] = {
					},
				},
				["Alpha"] = {
					["ranges"] = {
						[1] = {		1,			2},
						[2] = {					2,			3},
					},
					["times"] = {  [1] = 0,	   [2] = 7,	   [3]= 15,
								 ---|-----------|-----------|-----------|
					},
					["data"] = {   [1] = 16,   [2] = 200,  [3]= 16,
								 ---|-----------|-----------|-----------|
					},
				},
				["ColorR"] = {
					["ranges"] = {
					},
					["times"] = {
					},
					["data"] = {
					},
				},
				["ColorG"] = {
					["ranges"] = {
					},
					["times"] = {
					},
					["data"] = {
					},
				},
				["ColorB"] = {
					["ranges"] = {
					},
					["times"] = {
					},
					["data"] = {
					},
				},
			},
		},
		["UIAnimSeq"] = {
			[1] = {
				["Show"] = {
					[1] = 1,
				},
				["Hide"] = {
					[1] = 2,
				},
				["Up"] = {
					[1] = 3,
				},
				["Down"] = {
					[1] = 4,
				},
			},
		},
	};
	
	NPL.load("(gl)script/ide/commonlib.lua");
	local NewTable = commonlib.LoadTableFromFile("script/UIAnimation/Test_UIAnimFile.lua.table");
end

function UIAnimBlock.onclickevent()
	log("click: \r\n");
end