--[[
Title: modifier control
Author(s): Liuweili, LiXizhi
Date: 2006/6/16
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/modifier_control.lua");
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/dropdownlistbox_control.lua");

NPL.load("(gl)script/ide/modifier_items.lua");
NPL.load("(gl)script/ide/property_control.lua");
local L = CommonCtrl.Locale("IDE");

-- default member attributes
local ModifierCtrl={
	-- the non-modifier object which is being modified.
	binding = nil,
	-- name of the modifier
	name = "defaultmodifier",
	width = 170,
	height = 170,
}; 
CommonCtrl.ModifierCtrl = ModifierCtrl;

--a global list of modifiers from which modifiers are instanced.Once a object is selected, the SDK will try to build a subset of applicable modifiers from all registered and active modifiers.
if(not ModifierCtrl._modifiers) then ModifierCtrl._modifiers={}; end

--[[register a new modifier plug-in]]
function ModifierCtrl.RegisterModifier(name, modifierObject)
	--log(name.." registered\r\n")
	ModifierCtrl._modifiers[name] = modifierObject;
end

--[[unregister a modifier plug-in]]
function ModifierCtrl.UnRegisterModifier(name)
	local ctl = ModifierCtrl._modifiers[name];
	if(ctl~=nil) then
		ModifierCtrl._modifiers[name] = nil;
	end
end
			
--[[ get modifier by name. return nil if control not found]]
function ModifierCtrl.GetModifier(sName)
	return ModifierCtrl._modifiers[sName];
end

-- constructor
function ModifierCtrl:new (o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end

function ModifierCtrl:Destroy ()
	
end


--[[show all the modifiers that are available for the object. 
calling this function twice with the same object will hide the controller instead of showing it twice.]]
function ModifierCtrl:Show(o,left,top)
	if(not o) then 
		o = self.binding;
	else
		self.binding = o;
	end
	if(not o) then return end
	
	-- hide control if it already exists
	local list_box_name = self.name.."mod_list";
	if(ParaUI.GetUIObject(list_box_name):IsValid() == true) then
		ParaUI.Destroy(list_box_name);
		return;
	end
	
	-- build a list of modifiers which can modifer the given object. 
	local modlist={};
	local modName, modObject;
	local i=1;
	for modName, modObject in pairs(CommonCtrl.ModifierCtrl._modifiers) do
		if(modObject.CanModify~=nil and modObject.CanModify(o)==true) then
			log("modifier added\r\n");
			modlist[i]=modName;
			i=i+1;
		end
	end
	local cwidth,cheight=ParaEngine.GetClientSize();
	if(not top) then
		top=0;
	end
	if(not left)then
		left=0;
	end
	top=top-self.height;
	if(top<0)then
		top=0;
	end
	if(top+self.height>=cheight)then
		top=cheight-1-self.height;
	end
	if(left<0)then 
		left=0;
	end
	if(left+self.width>=cwidth)then
		left=cwidth-1-self.width;
	end
	if(i>1) then
		local _this,a;
		_this=ParaUI.CreateUIObject("listbox",list_box_name,"_lt",left,top,self.width,self.height);
		_this:AttachToRoot();
		_this.visible=true;
		_this.onselect=string.format([[;CommonCtrl.ModifierCtrl.OnSelectModifier("%s","%s");]], self.name, self.name);
		_this:AddTextItem(L"None");
		for a=1,i-1 do
			_this:AddTextItem(modlist[a]);
		end
	end
end

--[[ [static method] the event handler a user selected a modifier to apply
@param sCtrlName: the global control name. ]]
function ModifierCtrl.OnSelectModifier(sCtrlName, sModCtrlName)
	log("modifier selected\r\n");
	local ctl = ParaUI.GetUIObject(sCtrlName.."mod_list");
	if(ctl ~= nil) then
		local modname = ctl.text;
		if(modname~=nil and modname ~= "") then
			local modObject = CommonCtrl.ModifierCtrl.GetModifier(modname);
			if(modObject~=nil and modObject.ShowGUI~=nil ) then
				local dlg = modObject:new();
				--TODO: get mod control by sModCtrlName, we will use the binding object of the default mod controller
				dlg:Databind(CommonCtrl.ModifierCtrl.binding);
				dlg:ShowGUI();
			end
		end
		ParaUI.Destroy(sCtrlName.."mod_list");
	end
end

