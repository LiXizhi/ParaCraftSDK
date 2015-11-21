--[[
Title: Greate View modifier 
Author(s): LiXizhi
Date: 2006/6/29
Desc: This modifier makes the camera far plane and fog end range to a large value, so that we can have a greater view of the scene
Register the modifier:
-------------------------------------------------------
NPL.load("(gl)script/ide/modifiers/GreatView.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/modifier_items.lua");
NPL.load("(gl)script/ide/integereditor_control.lua");
NPL.load("(gl)script/ide/modifiers/sampleModifier.lua");

-- default member attributes
local GreatViewModifier=CommonCtrl.ModifierCtrl.GetModifier("CSampleModifier"):new{
	-- the object which is being modified.
	binding = nil,
	title = "Great View",
	-- modifier name, this is read-ony
	name = "GreatViewModifier",

	-- the ModifierItems object to store the values of this modifier, inheritance need to initialize this value
	-- this field stores setting which DoModifer() function will apply to the current object.
	items = CommonCtrl.ModifierItems:new{
		items={
		},
	values={
		}
	},
	NearPlane = 0.5,
	FarPlane = 200,
	FOV = 1,
	-- this field stores the old settings which UnDoModifer() function will apply to the current object to restore it to an old state.
	olditems = nil,
	
	-- this is a identifier, always true
	ismodifier = true
}
-- this modifier will automatically register itself in the modifier control when it is loaded. 
CommonCtrl.ModifierCtrl.RegisterModifier(GreatViewModifier.name, GreatViewModifier);
if(not _IDE_Modifiers) then _IDE_Modifiers={}; end
_IDE_Modifiers.GreatViewModifier = GreatViewModifier;

-- apply the current modifier settings to the current object, and save the last settings for restore
-- @return true if succeed, nil otherwise. 
function GreatViewModifier:DoModifier(o)
	
	ParaScene.GetAttributeObject():SetField("FogEnd", self.FarPlane);
	
	local att = ParaCamera.GetAttributeObject();
	att:SetField("FarPlane", self.FarPlane);
	att:SetField("NearPlane", self.NearPlane);
	att:SetField("FieldOfView", self.FOV);
end 

function GreatViewModifier:UnDoModifier(o)
	
	ParaScene.GetAttributeObject():SetField("FogEnd", 150);
	
	local att = ParaCamera.GetAttributeObject();
	att:SetField("FarPlane", 150);
	att:SetField("NearPlane", 0.5);
	att:SetField("FieldOfView", 1.047);
end 

-- @return: return true if it can modify the given object; and return nil if otherwise,
function GreatViewModifier.CanModify(o)
	if(o.GetAttributeObject~=nil) then
		local att = o:GetAttributeObject();
		local className = att:GetClassName();
		if(className == "CSceneObject" or className == "CAutoCamera" ) then
			return true;
		end
	end
end


-- draws the GUI of this modifier
--
function GreatViewModifier:OwnerDraw(__parent)
	-- create all sub control items.
	local __this;
	local ctrl_x,ctrl_y = 2,0;
	local cellspacing = 3;
	local width,height = __parent.width-cellspacing, 25;
	local labelWidth = 100;
	local valueWidth = width - labelWidth - cellspacing*3 - 20;
	local valueLeft = ctrl_x+labelWidth+cellspacing;
	local att = self:GetAttributeObject();

	-- Far Plane Control
	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth,height);
	__parent:AddChild(__this);
	__this.text="FarPlane";
	__this.autosize=false;
	
	local ctl = CommonCtrl.CCtrlIntegerEditor:new{
		name = self.name.."FarPlane",
		left=valueLeft, top=ctrl_y,width = 190,
		maxvalue=400, minvalue=150,
		value = self.FarPlane,
		parent = __parent,
		onchange = string.format([[_IDE_Modifiers.GreatViewModifier.OnChange("%s", "%s");]],self.name, "FarPlane"),
		UseSlider = true,
	};
	ctl:Show();
	ctrl_y = ctrl_y + height + cellspacing;
	
	-- Near Plane Control
	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth,height);
	__parent:AddChild(__this);
	__this.text="NearPlane";
	__this.autosize=false;
	
	local ctl = CommonCtrl.CCtrlIntegerEditor:new{
		name = self.name.."NearPlane",
		left=valueLeft, top=ctrl_y,width = 190,
		maxvalue=3, minvalue=0.1, 
		value = self.NearPlane,
		parent = __parent,
		onchange = string.format([[_IDE_Modifiers.GreatViewModifier.OnChange("%s", "%s");]],self.name, "NearPlane"),
		UseSlider = true,
	};
	ctl:Show();
	ctrl_y = ctrl_y + height + cellspacing;
	
	-- FOV Control
	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth,height);
	__parent:AddChild(__this);
	__this.text="FieldOfView";
	__this.autosize=false;
	
	local ctl = CommonCtrl.CCtrlIntegerEditor:new{
		name = self.name.."FOV",
		left=valueLeft, top=ctrl_y, width = 190,
		maxvalue=2, minvalue=0.6, 
		value = self.FOV,
		parent = __parent,
		onchange = string.format([[_IDE_Modifiers.GreatViewModifier.OnChange("%s", "%s");]],self.name, "FOV"),
		UseSlider = true,
	};
	ctl:Show();
	ctrl_y = ctrl_y + height + cellspacing;
	
end

--[static] handler
function GreatViewModifier.OnChange(sCtrlName, sItemName)
	local self = CommonCtrl.ModifierCtrl.GetModifier(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting modifier %s]],sCtrlName));
		return;
	end
	if(sItemName == "FarPlane") then
		local ctl = CommonCtrl.GetControl(self.name.."FarPlane");
		self.FarPlane = ctl.value;
		self:DoModifier();
	elseif(sItemName == "NearPlane") then
		local ctl = CommonCtrl.GetControl(self.name.."NearPlane");
		self.NearPlane = ctl.value;
		self:DoModifier();
	elseif(sItemName == "FOV") then
		local ctl = CommonCtrl.GetControl(self.name.."FOV");
		self.FOV = ctl.value;
		self:DoModifier();
	end
end