--[[
Title: a progress bar control
Author(s): LiXizhi
Date: 2007/4/6
use the lib:
There are a number of ways to modify the value displayed by the ProgressBar other than 
changing the Value property directly. You can use the Step property to specify a specific 
value to increment the Value property by, and then call the PerformStep method to increment 
the value. To vary the increment value, you can use the Increment method and specify a value 
with which to increment the Value property.
------------------------------------------------------------
NPL.load("(gl)script/ide/progressbar.lua");
local ctl = CommonCtrl.progressbar:new{
	name = "progressbar1",
	alignment = "_lt",
	left=0, top=0,
	width = 300,
	height = 30,
	parent = nil,
	block_overlay_bg = "Texture/arr_r.png", 
};
ctl:Show();
ctl:SetValue(50)
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local progressbar = {
	-- the top level control name
	name = "progressbar1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0, 
	width = 300, 
	height = 24, 
	parent = nil,
	-- properties
	Minimum = 0, -- The Maximum and Minimum properties define the range of values to represent the progress of a task
	Maximum = 100,
	Value = 0, -- represents the progress that the application has made toward completing the operation
	Step = 10,
	Style = "Blocks",
	isshowtooltip = false, -- show mouse over tooltip
	-- how many pixel to display for the first block. 
	miniblockwidth = 21,
	-- appearance
	container_bg = nil,-- background texture
	block_bg = "Texture/whitedot.png", -- texture of the progress blocks 
	block_color = "0 255 0", -- the color of the blocks used for displaying the progress bar
	-- a texture that is uv animated from one direction to another. This must be a tilable texture of 2^n size. 
	block_overlay_bg = nil, 
	-- margin of overlay image
	overlay_margin_left=5, overlay_margin_top=2, overlay_margin_right=5, overlay_margin_bottom=2, 
	-- private: block_overlay_bg offset in pixel
	tex_u = 0,
	-- private: block_overlay_bg offset in pixel
	tex_v = 0,
	-- pixel per second. 
	uv_speed = 30,
	-- automatically use portions of image as the block length increases. This allows us to diplay fixed length (non-strentching) images. 
	-- if this is true, the block_bg is usually same size as the control or it contains sub region string like ";0 0 100 20"
	block_bg_autosize = false,
	-- if true, progress bar will go from bottom to up, otherwise it is from left to right(default)
	is_vertical = false,
	-- string or function (step) end, where step is (0-1]
	onstep = nil,
	lastStep = 0,
}
CommonCtrl.progressbar = progressbar;

-- constructor
function progressbar:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function progressbar:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function progressbar:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("progressbar instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		if(self.container_bg~=nil) then
			_this.background=self.container_bg;
		end
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);

		-- for tooltip
		_this=ParaUI.CreateUIObject("button","tooltip", "_fi",0,0,0,0);
		_this.background = "";
		_parent:AddChild(_this);
		
		-- for blocks		
		_this=ParaUI.CreateUIObject("button","Blocks", "_lt",0,0,0,0);
		_this.background=self.block_bg;
		_guihelper.SetUIColor(_this, self.block_color)
		_parent:AddChild(_this);
		
		-- for block overlay
		if(self.block_overlay_bg) then
			_this=ParaUI.CreateUIObject("button","BlockUV", "_lt",self.overlay_margin_left or 0,self.overlay_margin_top or 0,0,0);
			_this.background="";
			_this:GetAttributeObject():SetField("UVWrappingEnabled", true);
			_this:SetScript("onframemove", function(uiobj)
				self:AnimateOverlay(deltatime or 0.033);
			end)
			_parent:AddChild(_this);
		end

		-- update the value for first use
		self:SetValue(self.Value);
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end	
end

-- public: Advances the current position of the progress bar by the amount of the Step property.
function progressbar:PerformStep()
	self:Increment(self.Step);
end

-- public: Advances the current position of the progress bar by the specified amount. 
function progressbar:Increment(deltaValue)
	self.SetValue(self.Value + deltaValue)
end

-- this function is called to animated the overlay
-- @param fDelta: in seconds. if nil it means 0.
-- @param _parent: the parent control. if nil, it will be fetched dynamically. 
function progressbar:AnimateOverlay(fDelta, _parent)
	if(self.block_overlay_bg and self.blockwidth and self.blockwidth>0 and self.blockheight>0) then
		_parent = _parent or ParaUI.GetUIObject(self.name);
		local blockUV = _parent:GetChild("BlockUV");
		if(blockUV:IsValid()) then
			local width = self.blockwidth - (self.overlay_margin_left or 0) - (self.overlay_margin_right or 0);
			local height = self.blockheight - (self.overlay_margin_top or 0) - (self.overlay_margin_bottom or 0);
				
			fDelta = fDelta or 0;
			if(fDelta > 0) then
				if(fDelta>0.3) then
					fDelta = 0.3;
				end
				if(not self.is_vertical) then
					self.tex_v = 0;
					self.tex_u = self.tex_u - self.uv_speed * fDelta;
					if(self.tex_u >= 128) then
						self.tex_u = self.tex_u - 128;
					elseif(self.tex_u <= -128) then
						self.tex_u = self.tex_u + 128;
					end
				else
					self.tex_u = 0;
					self.tex_v = self.tex_v - self.uv_speed * fDelta;
					if(self.tex_v > 128) then
						self.tex_v = self.tex_v - 128;
					elseif(self.tex_v <= -128) then
						self.tex_v = self.tex_v + 128;
					end
				end
			else
				-- only update height when delta is 0, meaning from SetValue. 
				if(width<0) then
					width = 0;
				end
				if(height<0) then
					height = 0;
				end

				blockUV.width = width;
				blockUV.height = height;
			end
			local u, v = math.floor(self.tex_u), math.floor(self.tex_v);
			-- echo({deltatime,u,v, self.tex_u, self.tex_v})
				
			blockUV.background = format("%s;%d %d %d %d", self.block_overlay_bg, u, v, width, height);
		end
	end
end

-- public: set the current progress
function progressbar:SetValue(Value)
	self.Value = Value;
	if (self.Value>self.Maximum)  then self.Value = self.Maximum end
	if (self.Value<self.Minimum)  then self.Value = self.Minimum end

	local percentage;
	if(self.Maximum <= self.Minimum)then
		percentage = 0;
	else
		percentage = (self.Value-self.Minimum)/(self.Maximum-self.Minimum);
	end
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		local left, top, width, height = _this:GetAbsPosition();		
		local blockCtl = _this:GetChild("Blocks");
		if (blockCtl:IsValid()) then
			if(not self.is_vertical) then
				-- horizontal progress bar from left to right
				local width = math.floor(width*percentage);
				
				local bHide;
				if(self.miniblockwidth) then
					if(width== 0) then
						bHide = true;
					else
						width = math.max(self.miniblockwidth, width);
						blockCtl.width = width;
					end	
				else
					blockCtl.width = width;
				end	
				
				self.blockwidth = width;
				self.blockheight = height;
				
				-- now update background
				if(self.block_bg_autosize and self.block_bg) then
					if(self.block_bg:match(":")) then
						-- if the background can stretch ,we don't need chang its size;
						blockCtl.background = self.block_bg;
					else
						-- automatically change the background according to size. 
						local filename, left, top, img_width, img_height = self.block_bg:match("^([^;]+);%w?(%d+) (%d+) (%d+) (%d+)$");
						if(img_height) then
							left = tonumber(left);
							top = tonumber(top);
							img_width = math.floor(tonumber(img_width)* percentage);
							img_height = tonumber(img_height);
							blockCtl.background = string.format("%s;%d %d %d %d", filename, left, top, img_width, img_height);
						else
							blockCtl.background = string.format("%s;%d %d %d %d", filename, 0, 0, width, height);
						end
					end
					--local filename, left, top, img_width, img_height = self.block_bg:match("^([^;]+);%w?(%d+) (%d+) (%d+) (%d+)$");	
					--if(img_height) then
						--left = tonumber(left);
						--top = tonumber(top);
						--img_width = math.floor(tonumber(img_width)* percentage);
						--img_height = tonumber(img_height);
						--blockCtl.background = string.format("%s;%d %d %d %d", filename, left, top, img_width, img_height);
					--else
						--blockCtl.background = string.format("%s;%d %d %d %d", filename, 0, 0, width, height);
					--end
				end

				blockCtl.height = height;
				blockCtl.visible = not bHide;
			else
				local full_height = height;
				-- vertical progress bar from bottom to up
				local height = math.floor(height*percentage);
				local bHide;
				if(self.miniblockwidth) then
					if(width== 0) then
						bHide = true;
					else
						height = math.max(self.miniblockwidth, height);
						blockCtl.height = height;
					end	
				else
					blockCtl.height = height;
				end	
				if(self.block_bg_autosize and self.block_bg) then
					-- automatically change the background according to size. 
					local filename, left, top, img_width, img_height = self.block_bg:match("^([^;]+);%w?(%d+) (%d+) (%d+) (%d+)$");
					if(img_height) then
						left = tonumber(left);
						top = tonumber(top);
						img_width = tonumber(img_width);
						local full_img_height = img_height;
						img_height = math.floor(tonumber(img_height)* percentage);
						blockCtl.background = string.format("%s;%d %d %d %d", filename, left, top+full_img_height-img_height, img_width, img_height);
					else
						blockCtl.background = string.format("%s;%d %d %d %d", filename, 0, 0, blockCtl.width, blockCtl.height);
					end
				end
				self.blockwidth = width;
				self.blockheight = height;

				blockCtl.visible = not bHide;
				blockCtl.height = height;

				blockCtl:Reposition("_lt", 0, full_height -  height, width, height)
			end

			if(self.isshowtooltip == true) then
				blockCtl.tooltip = Value.."/"..self.Maximum;
			end
		end
		local tooltipCtl = _this:GetChild("tooltip");
		if (tooltipCtl:IsValid()) then
			if(self.isshowtooltip == true) then
				tooltipCtl.tooltip = Value.."/"..self.Maximum;
			end
		end
		self:AnimateOverlay(0, _this);
	end
	
	if(type(self.onstep) == "function") then
		local step = self.step;
		if(not step or step<1)then step = 1; end
		local temp = math.floor(self.Value/step);
		if(temp>self.lastStep)then
			self.lastStep = temp;
			local percentage;
			if(self.Maximum <= self.Minimum)then
				percentage = 0;
			else
				percentage = (self.Value-self.Minimum)/(self.Maximum-self.Minimum);
			end
			self.onstep(percentage);
		end	
	end
	if(self.Value == self.Maximum or self.Value == self.Minimum )then
		self.lastStep = 0;
	end
end
