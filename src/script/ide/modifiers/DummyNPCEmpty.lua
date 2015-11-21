--[[
Title: DummyNPCEmpty modifier class
Author(s): Liuweili
Date: 2006/6/20
Desc: This modifier makes the current NPC empty (to its initial states)
	It's based on the CSampleModifier;You can't undo this modifier
Use Lib:
Test OK!
-------------------------------------------------------

-------------------------------------------------------
]]
NPL.load("(gl)script/ide/modifier_items.lua");
NPL.load("(gl)script/ide/modifiers/sampleModifier.lua");
-- default member attributes
local DummyNPCEmptyModifier=CommonCtrl.ModifierCtrl.GetModifier("CSampleModifier"):new{
	-- the object which is being modified.
	binding = nil,
	title = "DummyNPCEmpty",
	-- modifier name, this is read-ony
	name = "DummyNPCEmptyModifier",

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
	
	-- this is a identifier, always true
	ismodifier = true
}
-- this modifier will automatically register itself in the modifier control when it is loaded. 
DummyNPCEmptyModifier.UnDoModifier=nil;
CommonCtrl.ModifierCtrl.RegisterModifier(DummyNPCEmptyModifier.name, DummyNPCEmptyModifier);
if(not _IDE_Modifiers) then _IDE_Modifiers={}; end
_IDE_Modifiers.DummyNPCEmptyModifier = DummyNPCEmptyModifier;

-- apply the current modifier settings to the current object, and save the last settings for restore
-- @return true if succeed, nil otherwise. 
function DummyNPCEmptyModifier:DoModifier(o)
	if(not o) then 
		o = self.binding;
	else 
		self.binding = o;
	end
	if(not o or not self.CanModify(o)) then return end
	
	if(o.GetAttributeObject~=nil) then
		local att=o:GetAttributeObject();
		att:SetField("On_Attached","");
		att:SetField("On_Detached","");
		att:SetField("On_EnterSentientArea","");
		att:SetField("On_LeaveSentientArea","");
		att:SetField("On_Click","");
		att:SetField("On_Event","");
		att:SetField("On_Perception","");
		att:SetField("On_FrameMove","");
		att:SetField("On_Net_Send","");
		att:SetField("On_Net_Receive","");
		att:SetField("OnLoadScript","");
		return true;
	end
end 

-- @return: return true if it can modify the given object; and return nil if otherwise,
function DummyNPCEmptyModifier.CanModify(o)
	if(o.GetAttributeObject~=nil) then
		local att = o:GetAttributeObject();
		local className = att:GetClassName();
		if(className == "RPG Character") then
			return true;
		end
	end
end
