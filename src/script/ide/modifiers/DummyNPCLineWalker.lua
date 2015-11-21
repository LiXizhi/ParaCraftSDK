--[[
Title: DummyNPCLineWalker modifier class
Author(s): Liuweili
Date: 2006/6/20
Desc: This modifier makes the current NPC a dummy NPC walking between two points, and wait a few seconds at the two ends of the line.
	It's based on the CSampleModifier;
Use Lib:
-------------------------------------------------------

-------------------------------------------------------
]]
NPL.load("(gl)script/ide/modifier_items.lua");

NPL.load("(gl)script/ide/modifiers/sampleModifier.lua");

-- default member attributes
local DummyNPCLineWalkerModifier=CommonCtrl.ModifierCtrl.GetModifier("CSampleModifier"):new{
	-- the object which is being modified.
	binding = nil,
	title = "DummyNPCLineWalker",
	-- modifier name, this is read-ony
	name = "DummyNPCLineWalkerModifier",

	facing=0,
	radius=20,
	waitlength=4,
	-- the ModifierItems object to store the values of this modifier, inheritance need to initialize this value
	-- this field stores setting which DoModifer() function will apply to the current object.
	items = CommonCtrl.ModifierItems:new{
		items={
		},
	values={
		}
	},
	-- this field stores the old settings which UnDoModifer() function will apply to the current object to restore it to an old state.
	olditems = nil,
	UnDoModifier=nil,
	-- this is a identifier, always true
	ismodifier = true
}
-- this modifier will automatically register itself in the modifier control when it is loaded. 
CommonCtrl.ModifierCtrl.RegisterModifier(DummyNPCLineWalkerModifier.name, DummyNPCLineWalkerModifier);
if(not _IDE_Modifiers) then _IDE_Modifiers={}; end
_IDE_Modifiers.DummyNPCLineWalkerModifier = DummyNPCLineWalkerModifier;


-- [static] it is used to build a sub set of modifier which can be applied to a selected object. 
-- @return: return true if it can modify the given object; and return nil if otherwise,
function DummyNPCLineWalkerModifier.CanModify(o)
	if(o.GetAttributeObject~=nil) then
		local att = o:GetAttributeObject();
		local className = att:GetClassName();
		if(className == "RPG Character") then
			return true;
		end
	end
end

function DummyNPCLineWalkerModifier:DoModifier(o)
	if(not o) then 
		o = self.binding;
	else 
		self.binding = o;
	end
	if(not o or not self.CanModify(o)) then return end
	
	if(o.GetAttributeObject~=nil) then
		local att=o:GetAttributeObject();
		local sFunc = string.format([[NPL.load("(gl)script/ide/commonfunctions.lua");DummyNPCLineWalker_func("%s",%f,%f,%f);]], self.binding:GetName(),self.facing,self.radius,self.waitlength);
		att:SetField("OnLoadScript",";"..sFunc);
		-- do it right away
		NPL.DoString(sFunc);
		return true;
	end
end

-- draws the GUI of this modifier
--
function DummyNPCLineWalkerModifier:OwnerDraw(__parent)
	-- create all sub control items.
	local __this;
	local ctrl_x,ctrl_y = 2,0;
	local cellspacing = 3;
	local width,height = __parent.width-cellspacing, 25;
	local labelWidth = 100;
	local valueWidth = width - labelWidth - cellspacing*3 - 20;
	local valueLeft = ctrl_x+labelWidth+cellspacing;
	local att = self:GetAttributeObject();

	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth,height);
	__parent:AddChild(__this);
	__this.text="facing";
	__this.autosize=false;

	__this=ParaUI.CreateUIObject("editbox",self.name..1, "_lt",valueLeft,ctrl_y,valueWidth,height);
	__parent:AddChild(__this);
	__this.text=tostring(self.facing);
	__this.background="Texture/box.png;";
	__this.onchange = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.OwnerUpdate~=nil)then _mod.OwnerUpdate("%s");end;]],self.name,self.name);
	ctrl_y = ctrl_y + height + cellspacing;
	
	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth+100,height);
	__parent:AddChild(__this);
	__this.text="Radius";
	__this.autosize=false;
	
	__this=ParaUI.CreateUIObject("editbox",self.name..2, "_lt",valueLeft,ctrl_y,valueWidth,height);
	__parent:AddChild(__this);
	__this.text=tostring(self.radius);
	__this.background="Texture/box.png;";
	__this.onchange = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.OwnerUpdate~=nil)then _mod.OwnerUpdate("%s");end;]],self.name,self.name);
	ctrl_y = ctrl_y + height + cellspacing;
	
	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth+100,height);
	__parent:AddChild(__this);
	__this.text="WaitLength";
	__this.autosize=false;
	
	__this=ParaUI.CreateUIObject("editbox",self.name..3, "_lt",valueLeft,ctrl_y,valueWidth,height);
	__parent:AddChild(__this);
	__this.text=tostring(self.waitlength);
	__this.background="Texture/box.png;";
	__this.onchange = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.OwnerUpdate~=nil)then _mod.OwnerUpdate("%s");end;]],self.name,self.name);
	ctrl_y = ctrl_y + height + cellspacing;
end

-- updates the values of this modifier
function DummyNPCLineWalkerModifier.OwnerUpdate(sCtrlName)
	local self = CommonCtrl.ModifierCtrl.GetModifier(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting modifier %s
		]],sCtrlName));
		return;
	end
	local att=self:GetAttributeObject();
	local __this;
	__this=ParaUI.GetUIObject(self.name..1);
	if(__this:IsValid())then
		self.facing=tonumber(__this.text);
		__this.text=tostring(self.facing);
	end
	__this=ParaUI.GetUIObject(self.name..2);
	if(__this:IsValid())then
		self.radius=tonumber(__this.text);
		__this.text=tostring(self.radius);
	end
	__this=ParaUI.GetUIObject(self.name..3);
	if(__this:IsValid())then
		self.waitlength=tonumber(__this.text);
		__this.text=tostring(self.waitlength);
	end
end
