--[[
Title: text tips stack 
Author(s): LiXizhi
Date: 2010/11/08
Desc
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/TipsStack.lua");
local ctl = CommonCtrl.TipsStack:new{
	name = "MyTipsStack",
	alignment = "_ctt",
	left = 0,
	top = 80,
	width = 600,
	height = 400,
	font = "System;14",
	spacing = 4,
};
ctl:Show(true);
TipsStack.PushLabel({label = "test3", id="3"});
TipsStack.PushLabel({label = "test1",color = "0 255 0",shadow = false,bold = false,font_size = 14, priority=1}); --priority 1 will appear on the front.
TipsStack.PushLabel({label = "test4"});
TipsStack.PushLabel({label = "test2"}, true); -- push to front, instead of back
TipsStack.PushLabel({label = "test5"});
TipsStack.PushLabel({label = "test3", id="3"}); -- just replace similar id
TipsStack.PushLabel({label = "test6"});
-- The output order of above code is test1 to test5. 
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/STL.lua");

local TipsStack = commonlib.createtable("CommonCtrl.TipsStack", {
	max_size = 7,
	name = "TipsStack_instance",
	timer_interval = 100,
	max_duration = 10000,
	alignment = "_ctt",
	left = 0,
	top = 80,
	width = 600,
	height = 400,
	LineHeight = 32,
	LineWidth = 600,
	font = "System;14",
	zorder = 1,
	font_size = 14,
	spacing = 4,
	ignore_scaling = true,
	parent = nil,
});

function TipsStack:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	o.list = o.list or commonlib.List:new();
	self.__index = self
	return o
end

-- call this function to show or hide
function TipsStack:Show(bShow)
	local parent = ParaUI.GetUIObject(self.name);
	if(parent:IsValid()) then
		parent.visible = (bShow~=false);
	elseif(bShow~=false and not self.is_init) then
		self:OnInit();
	end
end

-- clear all. 
function TipsStack:Reset()
	self.list:clear();
	self.is_init = false;
end


-- multiple calls after Reset() function will not take effect. 
-- it will ensure that timer and UI are created. 
function TipsStack:OnInit()
	if(self.is_init) then return end
	local parent = ParaUI.GetUIObject(self.name);
	if(parent:IsValid() == false) then
		parent = ParaUI.CreateUIObject("container", self.name, self.alignment,self.left,self.top,self.width,self.height);
		parent.background = "";
		parent.zorder = self.zorder;
		parent.enabled = false;

		local _label;
		local k,len = 1,self.max_size;
		for k = 1,len do
			local x,y,width,height = 0,self.LineHeight * (k - 1),self.LineWidth,self.LineHeight;
			_label = ParaUI.CreateUIObject("button", tostring(k), "_lt", x,y,width,height);
			_label.background = "";
			_label.shadow = false;
			_label.enabled = false;
			_label.font = self.font or "System;14";
			
			_label:GetAttributeObject():SetField("TextShadowQuality", 8);

			_label.spacing = self.spacing or 4;
			_guihelper.SetUIFontFormat(_label, 1+256+32) -- center, single line and no clip
			parent:AddChild(_label);
		end
		if(self.parent == nil)then
			parent:AttachToRoot();
		else
			self.parent:AddChild(parent);
		end
	end
	
	if(not self.timer)then
		self.timer = commonlib.Timer:new({callbackFunc = function(timer)
			self:Update();
		end})
	end
	self.timer:Change(0, self.timer_interval)
	self.is_init = true;
end

-- clear all current labels. 
-- @param id: if nil, it will clear all. otherwise it will clear only those with same id. 
function TipsStack:Clear(id)
	-- LOG.std("", "debug", "TipsStack", "clear "..tostring(id));
	local item = self.list:first();
	while(item) do
		if(not id or id == item.id) then
			item = self.list:remove(item)
		else
			item = self.list:next(item)
		end
	end
	self:Update(0,true);
end

-- push a new item. If there are multiple, it will overwrite from the beginning of the list. 
-- @param args: a table like {label = "test2",color = "0 255 0",shadow = false,bold = false,font_size = 14,}
--  priority : larger priority will appear in front of lower priority label. a nil priority value means 0. 
--  id : we will replace item with same id (unless nil), instead of pushing a new one. 
--  max_duration: in milliseconds. if nil, it is 10000(10 seconds)
--  fade_in_time: in milliseconds. if it is not specified. it is 0.3*max_duration
--  fade_out_time: in milliseconds. if it is not specified. it is 0.3*max_duration
--  shadow: boolean
--  bold: boolean
--  color: string of RGB like "255 255 255"
--  scaling: text scaling
-- @param bPushToFront: true to push to the front of other labels with the same priority. default to false, which means push to back.
function TipsStack:PushLabel(args, bPushToFront)
	if(not args)then return end
	if(not args.label) then
		self:Clear(args.id);
		return;
	end
	-- LOG.std("", "debug", "TipsStack_begin", args);
	self:OnInit();
	args.cur_sec = 0;
	args.prev = nil;
	args.next = nil;
	args.max_duration = args.max_duration or self.max_duration;
	if(not args.fade_in_time) then
		args.fade_in_time = args.max_duration*0.3;
		if(args.fade_in_time>1000) then
			args.fade_in_time = 1000;
		end
	end
	if(not args.fade_out_time) then
		args.fade_out_time = args.max_duration*0.3;
		if(args.fade_out_time>1000) then
			args.fade_out_time = 1000;
		end
	end

	local priority = args.priority or 0;
	local item = self.list:first();
	while(item) do
		if(args.id and args.id == item.id) then
			-- if id is the same, we will simply replace it. 
			item.is_updated = false;
			if(args.fade_in_time) then
				if(item.cur_sec < args.fade_in_time) then
					args.cur_sec = item.cur_sec;
				else
					args.cur_sec = args.fade_in_time;
				end
				args.max_duration = args.max_duration + args.cur_sec;
			end
			commonlib.partialcopy(item, args);
			-- LOG.std("", "debug", "TipsStack_end", "ending");
			return;
		end
		if(not bPushToFront) then
			if((item.priority or 0) >= priority) then
				item = self.list:next(item);
			else
				break;
			end
		else
			if((item.priority or 0) > priority) then
				item = self.list:next(item);
			else
				break;
			end
		end
	end
	if(not item) then
		self.list:push_back(args);
	else
		self.list:insert_before(args, item);
	end
	
	if(self.list:size() > self.max_size)then
		-- remove the last one. 
		self.list:remove(self.list:last());
	end
	-- LOG.std("", "debug", "TipsStack_end", "ending");
end

-- update display in a timer. 
-- @param timer_interval: if nil, it is the default interval.
-- @param bUpdateAll: true to update all item slots,including the trailing empty slots. 
function TipsStack:Update(timer_interval, bUpdateAll)
	timer_interval = timer_interval or self.timer_interval;
	local k,v;
	local len = self.list:size();
	if(not bUpdateAll and len == 0)then
		return
	end
	local parent = ParaUI.GetUIObject(self.name);
	if(not parent:IsValid()) then
		if(self.timer) then
			self.timer:Change();
		end
		return;
	end

	local v = self.list:first();
	local k = 0;
	while(v) do
		v.cur_sec = v.cur_sec + timer_interval;
		if(v.cur_sec < v.max_duration)then
			k = k+1;
			local label = v.label;
			local color = v.color or "0 255 0";
			local shadow = tostring(v.shadow) or "false";
			local bold = tostring(v.bold) or "false";
			local font_size = v.font_size or self.font_size;

			local _label = parent:GetChild(tostring(k));
			if(_label:IsValid())then
				_label.visible = true;

				if(not v.is_updated) then
					v.is_updated = false;
					_label.text = label;
					if(shadow == "true")then
						_label.shadow = true;
					else
						_label.shadow = false;
					end
					if(bold == "true")then
						_label.font = string.format("System;%d;bold",font_size);
					else
						_label.font = string.format("System;%d",font_size);
					end
					local scaling = v.scaling or 1;
					if(self.ignore_scaling) then
						scaling = 1;
					end
					_label.scalingx = scaling;
					_label.scalingy = scaling;
					
					_guihelper.SetFontColor(_label, color);

					_label.background = v.background or self.background or "";
					_guihelper.SetUIColor(_label, v.background_color or self.background_color or "#ffffffff");
				end

				local percent = 1;
				if(v.fade_in_time) then
					percent = v.cur_sec / v.fade_in_time;
					if(percent>1) then
						percent = 1
					end
				end
				if(percent>=1 and v.fade_out_time) then
					percent = (v.max_duration - v.cur_sec) / v.fade_out_time;
					if(percent>1) then
						percent = 1
					end
				end
				if(percent<0) then
					percent = 0;
				end
				local alpha = math.floor(percent * 255);
				_label.colormask = "255 255 255 "..alpha;
			end
			v = self.list:next(v)
		else
			bUpdateAll = true;
			v = self.list:remove(v)
		end
	end
	if(bUpdateAll) then
		if((k+1) <= self.max_size) then
			local kk;
			for kk = k+1,self.max_size do
				local _label = parent:GetChild(tostring(kk));
				_label.visible = false;
			end
		end
	end
end