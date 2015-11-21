--[[
Title: mini-keyboard input page
Author(s): WD, refactored by LiXizhi
Date: 2011/08/22
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/MiniKeyboard.lua");

local ctl = CommonCtrl.MiniKeyboard:new({
	name = "abc",
	alignment = "_lt",
	left = 100,
	top = 100,
	parent = _parent,
	onchange = function(value,key) echo(value, key) end,
	maxlength = 10,
	fontsize = 12,
	});
ctl:Show();
-------------------------------------------------------
]]

local MiniKeyboard = 
{
	name = "minikeyboard1",
	alignment = "_lt",
	left = 0,
	top = 0,
	-- left, top is relative to parent_relative's left, top
	parent_relative = nil,
	width = 321,
	height = 126,
	-- the parent container,if nil, a top level _fi container is used. 
	parent = nil,
	value = nil,
	-- function (value, key) end, which is called whenever the text changes
	onchange = nil,
	-- if nil, it means no length limit
	maxlength = nil,
	displaymode = "normal",--support normal and password input ways
	frame_background = "Texture/Aries/Common/ThemeTeen/pane_bg_32bits.png:7 7 7 7",
	panel_background = "Texture/Aries/Common/ThemeTeen/pane_border_32bits.png:7 7 7 7",
	color = "#52dff4", 
	fontsize = 12,
	VK_Table = nil,
	capsLock = false,
};
CommonCtrl.MiniKeyboard = MiniKeyboard;

-- virtual key table
local VK_Table = {
	letter = {
		['q'] = {rect={1,49,21,24},value='q',},
		['w'] = {rect={22,49,21,24},value='w',},
		['e'] = {rect={43,49,21,24},value='e',},
		['r'] = {rect={64,49,21,24},value='r',},
		['t'] = {rect={85,49,21,24},value='t',},

		['y'] = {rect={106,49,21,24},value='y',},
		['u'] = {rect={127,49,21,24},value='u',},
		['i'] = {rect={148,49,21,24},value='i',},
		['o'] = {rect={169,49,21,24},value='o',},
		['p'] = {rect={190,49,21,24},value='p',},

		['a'] = {rect={1,73,21,24},value='a',},
		['s'] = {rect={22,73,21,24},value='s',},
		['d'] = {rect={43,73,21,24},value='d',},
		['f'] = {rect={64,73,21,24},value='f',},
		['g'] = {rect={85,73,21,24},value='g',},

		['h'] = {rect={106,73,21,24},value='h',},
		['j'] = {rect={127,73,21,24},value='j',},
		['k'] = {rect={148,73,21,24},value='k',},
		['l'] = {rect={169,73,21,24},value='l',},
		['z'] = {rect={1,97,21,24},value='z',},

		['x'] = {rect={22,97,21,24},value='x',},
		['c'] = {rect={43,97,21,24},value='c',},
		['v'] = {rect={64,97,21,24},value='v',},
		['b'] = {rect={85,97,21,24},value='b',},
		['n'] = {rect={106,97,21,24},value='n',},

		['m'] = {rect={127,97,21,24},value='m',},
	},

	symbol = {
		['wave'] = {rect={1,1,21,24},value='~',},
		['exclam'] = {rect={22,1,21,24},value='!',},
		['mail'] = {rect={43,1,21,24},value='@',},
		['sharp'] = {rect={64,1,21,24},value='#',},
		['coin'] = {rect={85,1,21,24},value='$',},

		['percent'] = {rect={106,1,21,24},value='%',},
		['xor'] = {rect={127,1,21,24},value='^',},
		['and'] = {rect={148,1,21,24},value='&',},
		['star'] = {rect={169,1,21,24},value='*',},
		['lrbracket'] = {rect={190,1,21,24},value='(',},

		['rrbracket'] = {rect={211,1,21,24},value=')',},
		['underline'] = {rect={232,1,21,24},value='_',},
		['plus'] = {rect={253,1,21,24},value='+',},
		['vline'] = {rect={274,1,21,24},value='|',},
		['subtract'] = {rect={295,1,21,24},value='-',},

		['chinesedot'] = {rect={1,25,21,24},value='`',},
		['equal'] = {rect={232,25,21,24},value='=',},
		['backslash'] = {rect={253,25,21,24},value='\\',},
		['lbrace'] = {rect={274,25,21,24},value='{',},
		['rbrace'] = {rect={295,25,21,24},value='}',},

		['lbracket'] = {rect={211,49,21,24},value='[',},
		['rbracket'] = {rect={232,49,21,24},value=']',},
		['less'] = {rect={253,49,21,24},value='<',},
		['more'] = {rect={274,49,21,24},value='>',},
		['unknown'] = {rect={295,49,21,24},value='?',},

		['tcomma'] = {rect={190,73,21,24},value='\'',},

		['comma'] = {rect={211,73,21,24},value=',',},
		['dot'] = {rect={232,73,21,24},value='.',},
		['slash'] = {rect={253,73,21,24},value='/',},
		['colon'] = {rect={148,97,21,24},value=':',},
		['doublequot'] = {rect={169,97,21,24},value='"',},
		['semicolon'] = {rect={190,97,21,24},value=';',},
		['emptyspace'] = {rect={211,97,21,24},value=' ',},
	},

	digit = {
		{rect={22,25,21,24},value=nil,},
		{rect={43,25,21,24},value=nil,},
		{rect={64,25,21,24},value=nil,},
		{rect={85,25,21,24},value=nil,},
		{rect={106,25,21,24},value=nil,},
		{rect={127,25,21,24},value=nil,},
		{rect={148,25,21,24},value=nil,},
		{rect={169,25,21,24},value=nil,},
		{rect={190,25,21,24},value=nil,},
		{rect={211,25,21,24},value=nil,},
	},

	func = {
		['delete'] = {rect={274,73,42,24},value='删除',},
		['capslock'] = {rect={232,97,84,24},value='切换大/小写',},
	},
};
MiniKeyboard.VK_Table = VK_Table;

-- create the object. 
function MiniKeyboard:new(o)
	local o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o.value = o.value or "";
	return o;
end

-- private: randomize layout. This is called each time the keyboard is displayed. 
function MiniKeyboard:Randomize()
	--generate random number layout 
	local digit = self.VK_Table.digit;
	local temp = {};
	local i,t;
	for i,t in ipairs(digit) do
		t.value = math.random(0,9);
		while temp[t.value] ~= nil do
			t.value = math.random(0,9);
		end
		temp[t.value] = 0;
	end
end

-- private: create UI components
function MiniKeyboard:Create()
	local _frame,_parent,_panel;
	_frame =ParaUI.GetUIObject(self.id or self.name);
	
	if(not _frame:IsValid()) then
		self:Randomize();

		local offset_x,offset_y = 0, 0;
		if(self.parent_relative) then
			offset_x,offset_y = self.parent_relative:GetAbsPosition();
		end

		_frame = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left+offset_x,self.top+offset_y,self.width,self.height);
		_frame.background = self.frame_background;
		_parent = _frame;
		
		if(self.parent == nil)then
			_frame:SetTopLevel(true);
			_frame:SetScript("onmouseup", function()
				self:Destroy(); -- if the user clicks anywhere outside. it will close the window. 
			end)
			_frame:AttachToRoot();
		else
			_frame.zorder = 1000;
			self.parent:AddChild(_frame);
		end
		
		self.id = _frame.id;

		--panel
		_panel = ParaUI.CreateUIObject("container","panel","_lt",2,2,self.width - 4,self.height -4);
		_panel.background = self.panel_background;
		_frame:AddChild(_panel);
	end

	local i,t;
	local _i,_j;
	local ctrls = self.VK_Table.digit;
	local vktable = self.VK_Table;

	for i,t in pairs(vktable) do
		if(i ~= "digit") then
			for _i,_j in pairs(t) do
				local ctrl = ParaUI.CreateUIObject("button","button" .. _i,"_lt",_j.rect[1],_j.rect[2],_j.rect[3],_j.rect[4]);
				if(ctrl ~= nil) then
					ctrl.text = _j.value;
					-- ctrl.tooltip = _j.value;
					ctrl:SetScript("onclick", function()
						self:OnClickBtn(_i, i);
					end);
					_panel:AddChild(ctrl);
				end
			end
		else
			for _i,_j in ipairs(ctrls) do
				local ctrl = ParaUI.CreateUIObject("button","button" .. _i,"_lt",_j.rect[1],_j.rect[2],_j.rect[3],_j.rect[4]);
				if(ctrl ~= nil) then
					ctrl.text = tostring(_j.value);
					ctrl:SetScript("onclick", function()
						self:OnClickBtn(_j, i);
					end);
					_panel:AddChild(ctrl);
				end	
			end
		end
	end
end

function MiniKeyboard:Destroy()
	self.capsLock = false;
	ParaUI.Destroy(self.id or self.name); 
end

-- toggle show/hide. it will be created on first use. 
-- @param bShow;
function MiniKeyboard:Show(bShow)
	local _this = ParaUI.GetUIObject(self.id or self.name); 
	if(not _this:IsValid()) then
		if(bShow ~= false) then
			self:Create();
		end
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
end

-- set the initial value
function MiniKeyboard:SetValue(value)
	self.value = value;
end

-- get the current data value
function MiniKeyboard:GetValue(value)
	return self.value;
end

-- refresh all UI text
function MiniKeyboard:ToggleCapital()
	local _parent= ParaUI.GetUIObject(self.id or self.name):GetChild("panel");
	if(_parent:IsValid()) then
		local filter_func; 
		if(self.capsLock) then
			filter_func = string.upper;
		else
			filter_func = string.lower;
		end
		local _i, _j;
		for _i,_j in pairs(self.VK_Table.letter) do
			local ctrl = _parent:GetChild("button" .. _i);
			if(ctrl:IsValid()) then
				ctrl.text = filter_func(tostring(_j.value));
			end	
		end
	end
end

-- user clicks a button. 
function MiniKeyboard:OnClickBtn(_arg,opt)
	local key;

	if(opt == "letter") then
		if(self.capsLock) then
			key = string.upper((self.VK_Table[opt])[_arg].value);
		else
			key = string.lower((self.VK_Table[opt])[_arg].value);
		end
	elseif(opt == "symbol") then
		key = (self.VK_Table[opt])[_arg].value;
	elseif(opt == "digit") then
		if(type(_arg) == "table") then
			key = tostring(_arg.value) or "";
		elseif(type(_arg) == "string") then
			key = _arg;
		end;
	elseif(opt == "func") then
		if(_arg == "capslock") then
			if(not self.capsLock) then
				self.capsLock = true;
			else
				self.capsLock = false;
			end
			-- modify the UI
			self:ToggleCapital();
			return;
		elseif(_arg == "delete") then
			key = "del";
		end
	end

	local text_length = #(self.value);
	if(key =="del") then
		self.value = self.value:sub(1, text_length-1);
	elseif(#key==1 and (not self.maxlength or text_length < self.maxlength)) then
		self.value = self.value..key;
	end

	if(type(self.onchange) == "function") then
		self.onchange(self.value, key);
	end
end