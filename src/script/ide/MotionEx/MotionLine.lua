--[[
Title: MotionLine
Author(s): Leio
Date: 2010/06/11
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionLine.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
NPL.load("(gl)script/ide/MotionEx/MotionRender.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
local MotionRender = commonlib.gettable("MotionEx.MotionRender");

NPL.load("(gl)script/ide/MotionEx/MotionLineBase.lua");
local MotionLine = commonlib.inherit(commonlib.gettable("MotionEx.MotionLineBase"), commonlib.gettable("MotionEx.MotionLine"));
function MotionLine:ctor()
	self.keyFrames = {};
	self.memory = {};
end
function MotionLine:__GoToTime(roottime,localtime,local_max_time,delta)
	local curKeyFrame,nextKeyFrame = self:GetRuntimeKeyFrame(localtime);
	delta = delta or 10;
	local state;
	--运算后的结果
	local runnode = nil;
	if(curKeyFrame and nextKeyFrame and curKeyFrame.Duration and nextKeyFrame.Duration)then
		--两个关键帧之间运行的时间 毫秒
		local runtime = localtime - curKeyFrame.Duration;
		local runtime_2 = localtime - nextKeyFrame.Duration;
		--两个关键帧之间运行的 总时间 毫秒
		local duration = nextKeyFrame.Duration - curKeyFrame.Duration;
		local frametype = nextKeyFrame["FrameType"];
		if(runtime <= delta)then
			state = "in";
		elseif(runtime_2 >=-delta)then
			state = "out";
		end
		runnode = {};
		if(frametype == "None" or frametype == "none"  or frametype == ""  or frametype == nil)then
			local frame = curKeyFrame;
			
			if(frame)then
				for prop,v in pairs(frame) do
					if(prop ~= "Duration" or prop ~= "KeyTime" or prop ~= "FrameType")then
						runnode[prop] = v;
					end
				end
			end
		else
			local motion_handler = self:GetMotionHandler(frametype)
			if(motion_handler)then
				for prop,v in pairs(nextKeyFrame) do
					if(prop ~= "Duration" or prop ~= "KeyTime" or prop ~= "FrameType")then
						--只支持数值转换
						v = tonumber(v);
						if(v)then
							local begin = curKeyFrame[prop];
							if(begin)then
								local change = v - begin;
								local value = motion_handler( runtime , begin , change , duration );	
								runnode[prop] = value;--保存计算结果
							end
						else
							runnode[prop] = v;
						end
					end
				end
			end
		end
	else
		--运行到最后一帧
		if(curKeyFrame and not nextKeyFrame and (localtime == curKeyFrame.Duration))then
			runnode = {};
			for prop,v in pairs(curKeyFrame) do
				if(prop ~= "Duration" or prop ~= "KeyTime" or prop ~= "FrameType")then
					runnode[prop] = v;
				end
			end
		end
	end
	--local str = commonlib.timehelp.MillToTimeStr(localtime);
	--commonlib.echo({str = str, curKeyFrame = curKeyFrame, nextKeyFrame = nextKeyFrame,});
	if(self.memory)then
		self.memory.roottime = roottime;
		self.memory.localtime = localtime;
		self.memory.local_max_time = local_max_time;
	end
	self:DoUpdate(runnode,state);
end
function MotionLine:DoUpdate(runnode,state)
	if(not runnode)then return end
	MotionRender.DoUpdate(self:GetType(),self:GetTarget(),self:GetScene(),self:GetOrigin(),runnode,self.memory,state);
end
function MotionLine:GetSpace()
	local len = #self.keyFrames;
	local frame = self.keyFrames[len];
	if(frame)then
		--frame.Duration 最后一帧的时间，也就是MotionLine运行的总时间
		return frame.Duration or 0;
	end
	return 0;
end
function MotionLine:__Reset()
	self.memory = {};	
end
function MotionLine:SetUID(uid)
	self.uid = uid;
end
function MotionLine:GetUID()
	return self.uid;
end
--更新的对象
function MotionLine:SetTarget(target)
	self.target = target;
end
function MotionLine:GetTarget()
	return self.target;
end
--更新的类型
function MotionLine:SetType(type)
	self.type = type;
end
function MotionLine:GetType()
	return self.type;
end
--场景名称
function MotionLine:SetScene(scene)
	self.scene = scene;
end
function MotionLine:GetScene()
	return self.scene;
end
--初始值参照点
function MotionLine:SetOrigin(origin)
	self.origin = origin;
end
function MotionLine:GetOrigin()
	return self.origin;
end
function MotionLine:SetDesc(desc)
	self.desc = desc;
end
function MotionLine:GetDesc()
	return self.desc;
end
----------------
--keyFrame = { Duration = 0, KeyTime = "00:00:01.5", FrameType = "", x = 0}
function MotionLine:AddKeyFrame(keyFrame,bNotSort)
	if(not keyFrame)then return end
	local keyTime = keyFrame.KeyTime;
	keyFrame.Duration = commonlib.timehelp.TimeStrToMill(keyTime);
	table.insert(self.keyFrames,keyFrame);
	if(not bNotSort)then
		self:SortKeyFrames();
	end
end
--按时间排序
function MotionLine:SortKeyFrames()
	table.sort(self.keyFrames,function(a,b)
		if(a.Duration and b.Duration)then
			return a.Duration < b.Duration;
		end
	end);
end
function MotionLine:ClearKeyFrames()
	self.keyFrames = {};
end
function MotionLine:AddKeyFrames(frames)
	if(not frames)then return end
	local k,node;
	for k,node in ipairs(frames) do
		self:AddKeyFrame(node,true);
	end
	self:SortKeyFrames();
end
--默认是"None",仅运行到关键帧的时候才有效果
function MotionLine:GetMotionHandler(motiontype)
	if(not motiontype)then
		motiontype = "None";
	end
	return MotionTypes[motiontype];
end
--获取当前时间的前一个关键帧 和后一个关键帧
function MotionLine:GetRuntimeKeyFrame(time)
	if(not time)then return end
	local k,frame;
	for k,frame in ipairs(self.keyFrames) do
		if(frame)then
			local duration = frame.Duration;
			local next_frame = self.keyFrames[k+1];
			if(next_frame)then
				local next_duration = next_frame.Duration;
				if(time >= duration and time < next_duration)then
					return frame,next_frame;
				end
			else
				return frame;
			end
		end
	end
end
--根据xmlnode生成一个MotionLine instance
function MotionLine.CreateByXmlNode(line_node)
	if(not line_node)then return end
	local motionLine = MotionLine:new();
	local k,line;
	local keyFrames = {};
	local attr = line_node.attr;
	if(attr)then
		local repeatCnt = line_node.attr.repeatCnt;
		repeatCnt = tonumber(repeatCnt) or 0;
		motionLine.repeatCnt = repeatCnt;
	end
	for k,line in ipairs(line_node) do
		local name = line.name;	
		if(name == "KeyFrames")then
			local k,keyFrameNode;
			local frames_node = line;
			--commonlib.echo(frames_node.name);
			if(frames_node)then
				for k,keyFrameNode in ipairs(frames_node) do
					local key_frame = {};
					local __keyframe;
					for __,__keyframe in ipairs(keyFrameNode) do
						local _name = __keyframe.name;
						local _value = __keyframe[1];
						if(_name == "Value")then
							_value =  NPL.LoadTableFromString(_value);
							if(_value)then
								for key,v in pairs(_value) do
									key_frame[key] = v;
								end
							end
						elseif(_name == "KeyTime" or _name == "FrameType")then
							key_frame[_name] = _value;
						end
					end
					table.insert(keyFrames,key_frame);
				end
				motionLine:AddKeyFrames(keyFrames);
			end
		else
			local value = line[1];
			if(name == "UID" or name == "Target" or  name == "Type" or  name == "Scene" or name == "Desc")then
				name = string.lower(name);
				motionLine[name] = value;
			elseif(name == "Origin" )then
				if(value and value ~= "")then
					name = string.lower(name);
					motionLine[name] = NPL.LoadTableFromString(value);
				end
			end
		end
	end
	return motionLine;
end

--转换格式：把duration 转换成KeyTime
--nodes必须已经排序好
function MotionLine.ChageToKeyFrames(nodes)
	if(not nodes)then return end
	local k,node;
	local last_duration = 0;
	for k,node in ipairs(nodes) do
		--注意：duration 是小写
		--KeyFrame 里面有内置属性 Duration,他是运行到这一帧的总时间
		if(node.duration and node.duration >= 0)then
			last_duration = last_duration + node.duration;
			local keyTime = commonlib.timehelp.MillToTimeStr(last_duration);
			node["KeyTime"] = keyTime;
		end 
	end
	return nodes;
end