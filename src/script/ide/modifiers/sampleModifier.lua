--[[
Title: sample modifier class
Author(s): Liuweili, LiXizhi
Date: 2006/6/16
Desc: A modifier class can be regarded as a controller bound to a certain object. The controller may be reified
through a GUI based dialog or no GUI at all. All modifiers should implement some common functions so that 
the modifier_control can instantiate them automatically at runtime. 
The modifier itself does not have GUI information. The GUI dialog to modify the modifiers are generated automatically
through the ModifierUICtrl or call the ShowGUI() method of the modifier.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/modifiers/sampleModifier.lua");
local dlg = _IDE_Modifiers.CSampleModifier:new {
	binding = obj,
	name = "sample1",
};
dlg.items=CommonCtrl.ModifierItems:new{
	items={
			{
			name="a",
			type="int",
			schematic=":int",
			--max and min are optional
			max=10,
			min=-10,
			--if the field is readonly, optional, if it is nil, it is equal to set it false.
			readonly = true
			},
			{
			name="b1",
			type="string",
			schematic=":script"
			}
		},
	values={
		--here a, b have corresponding definition in items[]
		a=1,b1=""
		}
	};

dlg:ShowGUI();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/modifier_items.lua");

NPL.load("(gl)script/ide/modifier_control.lua");

-- default member attributes
local CSampleModifier = {
	-- the object which is being modified.
	binding = nil,
	title = "Sample Modifier",
	-- modifier name, this is read-ony
	name = "CSampleModifier",

	-- the ModifierItems object to store the values of this modifier, inheritance need to initialize this value
	-- this field stores setting which DoModifer() function will apply to the current object.
	items = CommonCtrl.ModifierItems:new{
		items={
			{
			name="Progress",
			type="int",
			schematic=":int",
			}
		},
	values={
		--here Progress have corresponding definition in items[]
		Progress=1
		}
	},
	-- this field stores the old settings which UnDoModifer() function will apply to the current object to restore it to an old state.
	olditems = nil,
	
	-- this is a identifier, always true
	ismodifier = true
}
-- automatically register itself in the modifier control when it is loaded. 
CommonCtrl.ModifierCtrl.RegisterModifier(CSampleModifier.name, CSampleModifier);
if(not _IDE_Modifiers) then _IDE_Modifiers={}; end
_IDE_Modifiers.CSampleModifier = CSampleModifier;
			
-- [static] it is used to build a sub set of modifier which can be applied to a selected object. 
-- @return: return true if it can modify the given object; and return nil if otherwise,
function CSampleModifier.CanModify(o)
	--[[if(o.GetAttributeObject~=nil) then
		local att = o:GetAttributeObject();
		local className = att:GetClassName();
		if(className == "CSceneObject") then
			return true;
		end
	end]]
end

-- constructor: instantiate a modifier by supplying a object being modified
function CSampleModifier:new (o)
	o = o or {};   -- create object if user does not provide one
	setmetatable(o, self);
	self.__index = self;
	return o;
end

-- Destroy the UI control
function CSampleModifier:Destroy ()
	
end

-- apply the current modifier settings to the current object, and save the last settings for restore
-- @return true if succeed, nil otherwise. 
function CSampleModifier:DoModifier(o)
	if(not o) then 
		o = self.binding;
	else 
		self.binding = o;
	end
	if(not o or not self.CanModify(o)) then return end
	if(o.GetAttributeObject~=nil) then
		local att = o:GetAttributeObject();
		self.olditems=self.items:Copy();
		-- retrieve self.newData from GUI
		self:UpdateData();
		local index,value=next(self.olditems.items);
		while(index~=nil) do
			local fieldname=self.items:GetFieldName(index);
			-- backup old setting
			self.olditems:SetField(fieldname,att:GetField(fieldname,0));
			-- apply current setting to object. 
			att:SetField(fieldname, self.items:GetField(fieldname,0));
			index,value=next(self.olditems.items,index);
		end
		return true;
	end
end 

-- try to restore to the last setting
function CSampleModifier:UnDoModifier(o)
	if(not o) then 
		o = self.binding;
	else 
		self.binding = o;
	end
	if(not o or not self.CanModify(o)) then return end
	-- TODO: add your modifer code here, for example
	if(o.GetAttributeObject~=nil) then
		local att = o:GetAttributeObject();
		if(self.olditems~=nil) then
			-- apply old setting to object to restore it to a previous state  
			local index,value=next(self.olditems.items);
			while(index~=nil) do
				local fieldname=self.items:GetFieldName(index);
				att:SetField(fieldname, self.olditems:GetField(fieldname,0));
				index,value=next(self.olditems.items,index);
			end
			self.olditems = nil;
		end
	end
end

-- retrieve settings from the current GUI and save it to self.newData table
function CSampleModifier:UpdateData()
end

function CSampleModifier:GetAttributeObject()
	return self.items;
end
function CSampleModifier:equals(o)
	return self==o;
end

-- Load data from the binded object to the modifier, so that when the modifier shows up, it shows the recent data of the binded object. 
function CSampleModifier:InitData()
end

--[[bind an object to the modifier. If CanModify() is defined, it will check whether the object can bind to the modifier.
If CanModify() return true, self.binding will be assigned. If CanModify() returns false, self.binding will remain the same.
If CanModify() is not defined, the self.binding will be assigned. 
--]]
function CSampleModifier:Databind (o)
	if(o~=nil)then
		if(self.CanModify~=nil)then
			if(self.CanModify(o)==true) then
				self.binding=o;
				if(self.InitData~=nil)then
					self:InitData();
				end
			end
		else
			self.binding=o;
		end
		CommonCtrl.ModifierCtrl.RegisterModifier(self.name, self);
		return;
	end
	self.binding=o;
end
-- return true, if GUI is shown, or nil if no GUI for this control.
function CSampleModifier:ShowGUI()
	local ctlProperty = CommonCtrl.GetControl("modifierDlg");
	if(ctlProperty == nil) then
		ctlProperty = CommonCtrl.CCtrlProperty:new{
			alignment = "_ct",
			left = 180,
			top = -300
		};
		ctlProperty.name = "modifierDlg";
		ctlProperty.binding = self;
	else
		ctlProperty:DataBind(self);
	end
	ctlProperty:Show(true);
	return true;
end
