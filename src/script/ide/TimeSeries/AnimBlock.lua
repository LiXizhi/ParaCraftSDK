--[[
Title: A single anim block
Author(s): LiXizhi
Date: 2007/11/10
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/TimeSeries/AnimBlock.lua");

local ctl = AnimBlock:new{
	name = "AnimBlock1",
	type = "Linear", "Discrete", or "Hermite"
};
ctl:getValue2(1, 400);
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/mathlib.lua");
local mathlib = commonlib.gettable("mathlib");

if(not AnimBlock) then AnimBlock = {}; end

AnimBlock.tableType = "AnimBlock";
-- "Linear "or "Hermite" or "Discrete" or "LinearAngle"
AnimBlock.type = "Linear";
AnimBlock.used = true;

function AnimBlock:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	---------------------------
	-- data keeping and init
	---------------------------
	-- "linear "or "Hermite" or "Discrete"

	o.ranges = o.ranges or {};
	o.times = o.times or {};
	o.data = o.data or {};
	return o;
end


function AnimBlock:Reset()
	self.ranges = {};
	self.times = {};
	self.data = {};
end

-- if all animated values equals to the key, this animation will be set unused
function AnimBlock:SetConstantKey(key)
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
function AnimBlock:SetConstantKey(key, fEpsilon)
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
function AnimBlock:getDefaultValue()
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
function AnimBlock:getValue5(nCurrentAnim, currentFrame, nBlendingAnim, blendingFrame, blendingFactor)
	if(blendingFactor == 0) then
		return self:getValue2(nCurrentAnim, currentFrame);
	elseif(blendingFactor == 1) then
		return self:getValue2(nBlendingAnim, blendingFrame);
	else
		local v1 = self:getValue2(nCurrentAnim, currentFrame);
		local v2 = self:getValue2(nBlendingAnim, blendingFrame);
		
		return self:InterpolateLinear(blendingFactor, v1, v2);
	end
end

-- it accept anim index of both local and external animation
-- rangeID: Index.nIndex
-- time: Index.nCurrentFrame
function AnimBlock:getValue1(Index)
	return self:getValue2(Index.nIndex, Index.nCurrentFrame);
end

-- it accept anim index of both local and external animation
-- rangeID: CurrentAnim.nIndex, BlendingAnim.nIndex
-- time: CurrentAnim.nCurrentFrame, BlendingAnim.nCurrentFrame
function AnimBlock:getValue3(CurrentAnim, BlendingAnim, blendingFactor)
	
	if(blendingFactor == 0) then
		return self:getValue1(CurrentAnim);
	elseif(blendingFactor == 1) then
		return self:getValue1(BlendingAnim);
	else
		local v1 = self:getValue1(CurrentAnim);
		local v2 = self:getValue1(BlendingAnim);

		return self:InterpolateLinear(blendingFactor, v1, v2);
	end
end

-- iterator that returns, all (time, value) pairs between (TimeFrom, TimeTo].  
-- the iterator works fine when there are identical time keys in the animation, like times={0,1,1,2,2,2,3,4}.  for time keys in range (0,2], 1,1,2,2,2, are returned. 
function  AnimBlock:GetKeys_Iter(anim, TimeFrom, TimeTo)
	local i = self:GetNextKeyIndex(anim, TimeFrom);
	--log(tostring(i).." from "..TimeFrom.." to "..TimeTo.."\n")
	return function ()
		if(i~=nil) then
			local time = self.times[i];
			if(time==nil) then
				return
			end
			-- tricky: this skipped equal or smaller key since GetNextKeyIndex() returns the first equal or smaller ones
			while(time<=TimeFrom) do
				i=i+1;
				time = self.times[i];
				if(time==nil) then
					return
				end
			end
			--log(tostring(i).." "..time.."\n")
			if(time>TimeFrom and time<=TimeTo) then
				i = i + 1
				return time, self.data[i-1];
			end	
		end
	end
end

-- private: return the index of the first key whose time is larger than or equal to time. 
-- function may return nil if no suitable index is found. 
function  AnimBlock:GetNextKeyIndex(anim, time)
	local rangesCount = #(self.ranges);
	local timesCount = #(self.times);
	local dataCount = #(self.data);
	if(self.type ~= "NONE" and dataCount > 1) then
		
		local range;

		-- obtain a time value and a data range, and get the range according to the current animation.
		if(anim > 0 and anim <= rangesCount) then
			range = self.ranges[anim];
		else
			return;
		end
		
		if(range[1] ~= range[2]) then
			local pos = range[1]; -- this can be 0.
			
			local nStart = range[1];
			local nEnd = range[2];
			
			if(time > self.times[nEnd]) then
				return nEnd;
			end
			
			while(true) do
				if(nStart >= nEnd) then
					-- if no item left.
					pos = nStart;
					break;
				end
				
				local nMid;
				if( math.mod(nStart + nEnd, 2) == 1 ) then
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
			
			for i=pos-1, range[1], -1 do
				if(self.times[i]>=time) then
					pos = i;
				else
					break;
				end
			end
			return pos;
		else
			if(self.times[range[1]]>=time) then
				return range[1];
			end	
		end
		
	else
		-- default value
		if(self.times[1]~=nil and self.times[1]>=time) then
			return 1;
		end	
	end
end

-- get the first key time containing the time, 
-- @Note duplicated values are merged.  for example, if key1 and key2 both have the same value, their start time is merged key1's time is returned. 
function AnimBlock:getStartTime(anim, time)
	local index = self:GetNextKeyIndex(anim, time);
	if(index) then
		local start_time = self.times[index] or 0;
		if(start_time > time) then
			if(index > 1) then
				index = index - 1;
			end
		end
		local value = self.data[index]
		for i = index-1, 1, -1 do
			if(self.data[i] == value) then
				index = i;
			else
				break;
			end
		end
		return self.times[index] or 0;
	else
		return 0;
	end
end

-- return the key time range that best contains input time. 
-- @return timeFrom, timeTo: so that timeFrom<=time<=timeTo, and that there are key frames at the two ends. 
function AnimBlock:getTimeRange(anim, time)
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
			return 0, time;
		end
		
		if(range[1] ~= range[2]) then
			local pos = range[1]; -- this can be 0.
			
			local nStart = range[1];
			local nEnd = range[2];
			
			if(time >= self.times[nEnd]) then
				return self.times[nEnd], time;
			elseif(time <= self.times[nStart]) then --modified 2007.11.13
				return time, self.times[nStart];
			end
			
			while(true) do
			
				if(nStart >= nEnd) then
					-- if no item left.
					pos = nStart;
					break;
				end
				
				local nMid;
				if( math.mod(nStart + nEnd, 2) == 1 ) then
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
			
			return t1, t2;
		else
			return 0, time;
		end
		
	else
		if(dataCount == 1) then
			local keyframe = self.times[1];
			if(keyframe) then
				return keyframe, keyframe;
			else
				-- default value
				return 0, time;
			end
		else
			-- default value
			return 0, time;
		end
	end
end
	
-- this function will return the interpolated animation vector at the specified anim id and frame number
-- anim: RangeID
-- time: frame number,  1 milsec = 1 frame
function AnimBlock:getValue2(anim, time)
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
			elseif(time <= self.times[nStart]) then --modified 2007.11.13
				return self.data[nStart];
			end
			
			while(true) do
			
				if(nStart >= nEnd) then
					-- if no item left.
					pos = nStart;
					break;
				end
				
				local nMid;
				if( math.mod(nStart + nEnd, 2) == 1 ) then
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
			elseif (self.type == "Discrete") then
				-- the first one is used. 
				return self.data[pos];	
			elseif (self.type == "LinearAngle") then
				-- angle values -pi, pi
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

AnimBlock.getValue = AnimBlock.getValue2;

-- linear interpolation
function AnimBlock:InterpolateLinear(range, v1, v2)
	return  (v1 * (1.0 - range) + v2 * range);
end

-- linear interpolation
function AnimBlock:InterpolateLinearAngle(range, v1, v2)
	local delta = mathlib.ToStandardAngle(v2-v1);
	return mathlib.ToStandardAngle(v1 + delta * range);
end


-- blend the two values use linear interpolation
function AnimBlock:BlendValues(currentValue, blendingValue, blendingFactor)
	if(blendingFactor == 0) then
		return currentValue;
	elseif(blendingFactor == 1) then
		return blendingValue;
	else
		return self:InterpolateLinear(blendingFactor, currentValue, blendingValue);
	end
end

-- hermite interpolation
function AnimBlock:InterpolateHermite(range, v1, v2, inVal, outVal)

	local h1 = 2.0*range*range*range - 3.0*range*range + 1.0;
	local h2 = -2.0*range*range*range + 3.0*range*range;
	local h3 = range*range*range - 2.0*range*range + range;
	local h4 = range*range*range - range*range;
	
	return (v1*h1 + v2*h2 + inVal*h3 + outVal*h4);
end

function AnimBlock:SetRangeByIndex(index, rangeFirst, rangeSecond)
	if(not self.ranges[index]) then
		self.ranges[index] = {};
	end
	self.ranges[index] = {rangeFirst, rangeSecond};
end

-- trim end, so that there are no time value that is smaller than time.
-- currently, it will automatically update animation range for 1 
function AnimBlock:TrimEnd(time)
	local timesCount = #(self.times);
	
	if(timesCount == 1) then
		if(self.times[timesCount]>time) then
			commonlib.resize(self.times, 0);
			commonlib.resize(self.data, 0);
			self.ranges[1] = {};
		end
	elseif(timesCount>1) then	
		if(self.times[timesCount]>time) then
			local i;
			for i=timesCount, 1, -1 do 
				if(self.times[i]<=time) then
					commonlib.resize(self.times, i);
					commonlib.resize(self.data, i);
					self:SetRangeByIndex(1, 1, i);
					return
				end
			end
			commonlib.resize(self.times, 0);
			commonlib.resize(self.data, 0);
			self.ranges[1] = {};
		end	
	end
end

-- append a key intelligently without introducing keys, it will automatically update the range if necessary.
-- currently it only works for range 0. 
-- if type is Linear, it will create a new key only if the last key, the last last key and the new key are all the same. 
-- if type is Discrete, it will always create a new key. 
-- @param time: if time is smaller than the last time, previous time, value will be removed. 
-- @param bForceAppend: always append no matter what. 
-- @return true if appended.
function AnimBlock:AutoAppendKey(time, data, bForceAppend)
	local timesCount = #(self.times);
	local dataCount = #(self.data);
	
	if(not bForceAppend) then
		if(timesCount == 0) then
			self:AppendKey(time, data);
			self:SetRangeByIndex(1, 1, 1);
		elseif(timesCount == 1) then
			if(self.data[dataCount] ~= data) then
				self:AppendKey(time, data);
				self:SetRangeByIndex(1, 1, 2);	
			else
				self.times[timesCount] = time;
				self.data[timesCount] = data;
			end
		else -- if(timesCount >= 2) then	
			if( (self.data[dataCount] == self.data[dataCount-1]) and (self.data[dataCount]==data)) then
				self.times[timesCount] = time;
				self.data[timesCount] = data;
			else
				self:AppendKey(time, data);
				self:SetRangeByIndex(1, 1, timesCount+1);	
			end
		end
	else
		self:AppendKey(time, data);
		self:SetRangeByIndex(1, 1, timesCount+1);	
	end	
	return true;
end

function AnimBlock:AppendKey(time, data)
	local timesCount = #(self.times);
	local dataCount = #(self.data);
	self.times[timesCount + 1] = time;
	self.data[dataCount + 1] = data;
end

-- add a key intelligently, it will automatically update the range if necessary.
-- currently it only works for range 0. 
-- if type is Linear, it will create a new key only if the last key, the last last key and the new key are all the same. 
-- if type is Discrete, it will always create a new key. 
-- @return true if key is modified
function AnimBlock:AutoAddKey(time, data)
	local index = self:GetNextKeyIndex(1, time);
	index = (index or 1);
	local next_time = self.times[index];
	-- local next_data = self.data[index];
	if(next_time) then
		if(next_time == time) then
			if(self.data[index]~=data) then
				self.data[index] = data;
				return true;
			end
		else
			if(next_time < time) then
				index = index + 1;
			end
			if( (index >=3) and (self.data[index-1] == self.data[index-2]) and (self.data[index-1]==data)) then
				-- do nothing, since it is linear
				return;
			else
				-- insert before next_time;
				commonlib.insertArrayItem(self.times, index, time);
				commonlib.insertArrayItem(self.data, index, data);
				self:SetRangeByIndex(1, 1, #(self.times));	
				return true;
			end
		end
	else
		return self:AutoAppendKey(time, data, true);
	end
end

-- add new key at time, data. if there is already a key at the time, we will replace it. 
-- @return true if new key is modified or existing data is modified. 
function AnimBlock:AddKey(time, data)
	local index = self:GetNextKeyIndex(1, time);
	index = (index or 1);
	local next_time = self.times[index];
	if(next_time) then
		if(next_time == time) then
			if(self.data[index]~=data) then
				self.data[index] = data;
				return true;
			end
		else
			if(next_time < time) then
				index = index + 1;
			end
			-- insert before next_time;
			commonlib.insertArrayItem(self.times, index, time);
			commonlib.insertArrayItem(self.data, index, data);
			self:SetRangeByIndex(1, 1, #(self.times));	
			return true;
		end
	else
		return self:AutoAppendKey(time, data, true);
	end
end

-- shifting keyframes from shift_begin_time to end by the amount of offset_time. 
function AnimBlock:ShiftKeyFrame(shift_begin_time, offset_time)
	local begin_index = self:GetNextKeyIndex(1, shift_begin_time) or 1;
	local begin_time = self.times[begin_index];
	if(not begin_time) then
		return
	elseif(begin_time < shift_begin_time) then
		begin_index = begin_index + 1;
		begin_time = self.times[begin_index];
		if(not begin_time) then
			return begin_time;
		end
	end
	if(offset_time < 0) then
		-- check to see if we need to remove some keys first. 
		local to_index = self:GetNextKeyIndex(1, shift_begin_time+offset_time);
		if(to_index) then
			local to_time = self.times[to_index];
			if(not to_time) then
			
			elseif(to_time < (shift_begin_time+offset_time)) then
				to_index = to_index + 1;
			end
		else
			to_index = 1;
		end

		if(to_index < begin_index) then
			for i = to_index, begin_index-1 do
				commonlib.removeArrayItem(self.times, i);
				commonlib.removeArrayItem(self.data, i);
			end
			self:SetRangeByIndex(1, 1, #(self.times));	

			begin_index = to_index;
		end
	end
	-- now offset the time. 
	for i = begin_index, #(self.times) do
		local time = self.times[i] + offset_time;
		self.times[i] = math.max(0, time);
	end
end

-- move keyframe from from_keytime to keytime
function AnimBlock:MoveKeyFrame(key_time, from_keytime)
	local from_index = self:GetNextKeyIndex(1, from_keytime);
	if(from_index) then
		local from_time = self.times[from_index];
		if(from_time == from_keytime) then
			local index = self:GetNextKeyIndex(1, key_time) or 1;
			local time = self.times[index];
			self.times[from_index] = key_time;
			if(index ~= from_index) then
				if(time<key_time and index < #(self.times)) then
					index = index + 1;
				end
				if(index ~= from_index) then
					commonlib.moveArrayItem(self.times, from_index, index);
					commonlib.moveArrayItem(self.data, from_index, index);
				end
			end
			return true;
		end
	end
end

-- move keyframe from from_keytime to keytime
function AnimBlock:CopyKeyFrame(key_time, from_keytime)
	local from_index = self:GetNextKeyIndex(1, from_keytime);
	if(from_index) then
		local from_time = self.times[from_index];
		if(from_time == from_keytime) then
			local index = self:GetNextKeyIndex(1, key_time) or 1;
			local time = self.times[index];
			
			if(time~=key_time and key_time ~= from_keytime) then
				if(time<key_time) then
					index = index + 1;
				end
				commonlib.insertArrayItem(self.times, index, key_time);
				commonlib.insertArrayItem(self.data, index, commonlib.clone(self.data[from_index]));
				self:SetRangeByIndex(1, 1, #(self.times));	
			end
			return true;
		end
	end
end


-- remove the key frame at key_time if there is a key frame. 
-- return true if deleted. 
function AnimBlock:RemoveKeyFrame(key_time)
	local index = self:GetNextKeyIndex(1, key_time) or 1;
	local time = self.times[index];
	if(time == key_time) then
		commonlib.removeArrayItem(self.times, index);
		commonlib.removeArrayItem(self.data, index);
		self:SetRangeByIndex(1, 1, #(self.times));	
		return true;
	end
end

-- remove all keys in the [fromTime, toTime]
function AnimBlock:RemoveKeysInTimeRange(fromTime, toTime)
	local from_index = self:GetNextKeyIndex(1, fromTime) or 1;
	local time = self.times[index];
	if(time) then
		if(time == fromTime) then
		elseif(time<fromTime) then
			from_index = from_index + 1;
		end
		local to_index = self:GetNextKeyIndex(1, toTime) or 1;
		time = self.times[index];
		if(not time) then
			
		end
	end
end
-- return the last data in the animation. 
function AnimBlock:GetLastData()
	local dataCount = #(self.data);
	if(dataCount>0) then
		return self.data[dataCount];
	end
end

function AnimBlock:GetLastTime()
	local timesCount = #(self.data);
	if(timesCount>0) then
		return self.times[timesCount];
	end
end

function AnimBlock:GetFirstTime()
	local timesCount = #(self.data);
	if(timesCount>0) then
		return self.times[1];
	end
end

function AnimBlock:UpdateLastKey(time, data)

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

function AnimBlock:SetKeyValueAt(nIndex, time, data)
	self.times[nIndex] = time;
	self.data[nIndex] = data;
end

function AnimBlock:GetKeyNum()
	local timesCount = #(self.times);
	local dataCount = #(self.data);
	if(timesCount == dataCount) then
		return dataCount;
	else
		log("error: Caution times and data table counts are not equal.\r\n");
	end
	return 0;
end

function AnimBlock:SetKeyNum(num)
	num = num or 0;
	commonlib.resize(self.times, num);
	commonlib.resize(self.data, num);
	self:SetRangeByIndex(1, 1, num);
end


function AnimBlock:GetRangeTimeInterval(index)
	if(not self.ranges[index]) then
		return 0;
	end
	--log("timetag1: "..self.ranges[index][2].." timetag2:"..self.ranges[index][1].."\r\n");
	--log("time1: "..self.times[self.ranges[index][2]].." time2:"..self.times[self.ranges[index][1]].."\r\n");
	return self.times[self.ranges[index][2]] - self.times[self.ranges[index][1]];
end

-- append a new pair of (time, value) at the end of a specified animation range (rangeIndex).
-- if there is no range at rangeIndex, a new one will be created. Please note that after calling this, one can no longer append new pairs to previous ranges
-- @param rangeIndex: range index. if nil, it will default to 1. 
-- function AnimBlock:AppendPairInRange(time, value, rangeIndex)
-- end



-- test function:
function AnimBlock:BuildBasicAnimTable()
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