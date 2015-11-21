--[[
Title: ControlTarget
Author(s): Leio Zhang
Date: 2008/11/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/ControlTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local ControlTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "ControlTarget",
	Owner = nil,
	Type = nil,
	ID = nil,
	Alignment = nil,
	X = nil,
	Y = nil,
	Width = nil,
	Height = nil,
	Rot = nil,
	ScaleX = nil,
	ScaleY = nil,
	Alpha = nil,
	Visible = nil,
	Bg = nil,
	Text = nil,	
});
commonlib.setfield("CommonCtrl.Animation.Motion.ControlTarget",ControlTarget);
function ControlTarget:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = CommonCtrl.Animation.Motion.ControlTarget:new();
	result["Owner"] = curTarget.Owner;
	result["Type"] = curTarget.Type;
	result["Visible"] = curTarget.Visible;
	self:__GetDifference("X",result,curTarget,nextTarget);
	self:__GetDifference("Y",result,curTarget,nextTarget);
	self:__GetDifference("Rot",result,curTarget,nextTarget);
	self:__GetDifference("ScaleX",result,curTarget,nextTarget);
	self:__GetDifference("ScaleY",result,curTarget,nextTarget);
	self:__GetDifference("Alpha",result,curTarget,nextTarget);
	return result;
end

function ControlTarget:GetDefaultProperty(obj_params)
	if(obj_params)then
		self["Alignment"] = obj_params["Alignment"];
		self["X"] = self:FormatNumberValue(obj_params["X"]);
		self["Y"] = self:FormatNumberValue(obj_params["Y"]);
		self["Width"] = self:FormatNumberValue(obj_params["Width"]);
		self["Height"] = self:FormatNumberValue(obj_params["Height"]);
		self["ScaleX"] = self:FormatNumberValue(obj_params["ScaleX"]);
		self["ScaleY"] = self:FormatNumberValue(obj_params["ScaleY"]);
		self["Alpha"] = self:FormatNumberValue(obj_params["Alpha"]);
		self["Rot"] = self:FormatNumberValue(obj_params["Rot"]);
		self["Visible"] = obj_params["Visible"];
		self["Bg"] = obj_params["Bg"];
		self["Text"] = obj_params["Text"];	
	else
		self["Alignment"] = "_lt";
		self["X"] = 0;
		self["Y"] = 0;
		self["Width"] = 0;
		self["Height"] = 0;
		self["ScaleX"] = 1;
		self["ScaleY"] = 1;
		self["Alpha"] = 1;
		self["Rot"] = 0;
		self["Visible"] = true;
		self["Bg"] = "";
		self["Text"] = "";	
	end
end
function ControlTarget:GetName()
	local owner = self.Owner;
	if(owner)then
		local keyFrames = owner:GetParent();
		if(keyFrames)then
			local name = keyFrames.TargetName or keyFrames.TargetProperty;
			return name;
		end
	end
end
function ControlTarget:Update(curKeyframe,lastFrame,frame)
	
	local name = self:GetName();
	if(not name)then return; end
	local object;
	
	-- NOTE by Andy:
	-- Get object from a full path if the name begins with an "@"
	if(string.byte(name, 1) == "@") then
		-- get the ui object from object path string
		-- path string format: [@name][@index][@index][@index][@index]..
		-- @param string: object path string
		local function GetUIObjectFromPathString(path)
			local name;
			local first = true;
			local _obj;
			for ID in string.gfind(path, "([^@]+)") do
				if(first == true) then
					_obj = ParaUI.GetUIObject(ID);
					first = false;
				else
					_obj = _obj:GetChildByID(tonumber(ID));
				end
			end
			
			return _obj;
		end
		object = GetUIObjectFromPathString(name);
	else
		object = ParaUI.GetUIObject(name);
	end

	if(object:IsValid())then
		self:CheckValue();	
		
		object.translationx = self.X;
		object.translationy = self.Y;
		object.scalingx = self.ScaleX;
		object.scalingy = self.ScaleY;
		object.rotation = self.Rot * (math.pi/180);
		object.visible = self.Visible;
		self:SetAlpha(object,self.Alpha)
		-- update special value
		if(not curKeyframe or not lastFrame or not frame)then return; end
		local isActivate = curKeyframe:GetActivate();		
		if(isActivate)then
			local curTarget = curKeyframe:GetValue();
			object.visible = curTarget.Visible;
			if(self.Text ~="")then
				
			end
			if(self.Bg)then
				local bg = object.background;
				if(bg ~= self.Bg)then
					object.background = self.Bg;
				end
			end
		end
	end
end
function ControlTarget:SetAlpha(object,v)
	if(not object:IsValid() or not v)then return end;
	local uiType = self.Type;
	local color;
	if(uiType == "text")then
		color = object:GetFont("text").color.." 255";		
	else
		color = object.color;
	end
	local _,_,r,g,b,a =string.find(color,"%s-(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s-");
			r = self:ChecColorkNum(r)
			g = self:ChecColorkNum(g)
			b = self:ChecColorkNum(b)
			a = self:ChecColorkNum(a)	
			local  new_a = tonumber(v);
			new_a = new_a * 255;
			new_a = math.floor(new_a);
			new_a = self:ChecColorkNum(new_a);
			color = r.." "..g.." "..b.." "..new_a;
	if(uiType == "text")then
		object:GetFont("text").color = color ;
	else
		object.color = color;
	end
end
function ControlTarget:ChecColorkNum(n)
	if(not n ) then n = 255; end
	n = tonumber(n);
	if( n<0)then
		n = 0;
	 elseif( n>255)then
		n=255;
	end
	return n;
end
function ControlTarget:CheckValue()
	self.X = tonumber(self.X) or 0;
	self.Y = tonumber(self.Y) or 0;
	self.Rot = tonumber(self.Rot) or 0;
	self.Alpha = tonumber(self.Alpha) or 1;
	self.ScaleX = tonumber(self.ScaleX) or 1;
	self.ScaleY = tonumber(self.ScaleY) or 1;
	if(self.Visible == nil)then
		self.Visible = true;
	end
	self.Bg = self.Bg or "";
	self.Text = self.Text or "";
end
function ControlTarget:ReverseToMcml()
	local mcmlTitle = self.Property;
	local k,v;
	local result = "";
	for k,v in pairs(self) do
		if(self.NoOutPut[k] ~= 0)then
			v = tostring(v) or "";
			local s = string.format('%s="%s" ',k,v);
			result = result .. s;
		end
	end
	local Text;
	if(self.Text and self.Text  ~= "")then
		Text = "<![CDATA["..self.Text.."]]>"
	else
		Text = "";
	end
	local str = string.format([[<%s %s>%s</%s>]],
			mcmlTitle,result,Text,mcmlTitle);
	return str;
end