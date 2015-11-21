--[[
Title: modifier ui
Author(s): Liuweili
Date: 2006/6/16
Desc: CommonCtrl.ModifierUICtrl displays an GUI dialog to show and modify a given modifier.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/modifierui_control.lua");
d=CommonCtrl.ModifierCtrl:new();
d.items=CommonCtrl.ModifierItems:new{
	items={
			{
			name="a",
			type="int",
			schematic="int",
			max=10,
			min=-10,
			--if the field is readonly, optional, if it is nil, it is equal to set it false.
			readonly = true
			},
			{
			name="b",
			type="string",
			schematic=":script"
			}
		},
	values={
		a=1,b=""
		}
	};
--this is a early created modifierui control, you can reuse it. if UIObject is nil, it will create a new modifierui when you call ShowGUI();
d.UIObject=someModifierUI;
d:ShowGUI();

-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/coloreditor_control.lua");
NPL.load("(gl)script/ide/vectoreditor_control.lua");
NPL.load("(gl)script/ide/fileselector_control.lua");
NPL.load("(gl)script/ide/integereditor_control.lua");
NPL.load("(gl)script/ide/scripttextbox_control.lua");
NPL.load("(gl)script/ide/modifier_control.lua");
NPL.load("(gl)script/ide/modifier_items.lua");
-- default member attributes
local ModifierUICtrl={
	-- the modifier control object which is being modified.
	binding = nil,
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 310,
	height = 150,
	-- the displayed title of this modifier
	title = "Default Modifier",
	name = "defaultmodifierui",
	controlsbinded = false,
	-- parent UI object, nil will attach to root.
	parent = nil,
}; 
CommonCtrl.ModifierUICtrl = ModifierUICtrl;
-- constructor
function ModifierUICtrl:new (o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end

function ModifierUICtrl:Destroy ()
	ParaUI.Destroy(self.name);
end
-- show the property control, one may need to set the o.binding member before calling this method. 
function ModifierUICtrl:Show (bVisible)
	local UIObject = ParaUI.GetUIObject(self.name);
	if(UIObject:IsValid() == true) then
		UIObject.visible = bVisible;
		if(bVisible == true) then
			if(not self.controlsbinded) then
				-- rebind if not bound yet.
				if(self.binding~=nil) then
					self:Databind();
				end
			end
		end
	else	
		local __this,__parent,__font,__texture;
		
		-- add to global control table
		CommonCtrl.AddControl(self.name, self);
		
		UIObject = ParaUI.CreateUIObject("container",self.name, self.alignment,self.left,self.top,self.width,self.height);
		UIObject:AttachToRoot();
		UIObject.background="Texture/box.png;";
		UIObject.candrag=true;
		UIObject.visible = bVisible;
		__texture=UIObject:GetTexture("background");
		__texture.transparency=128;--[0-255]
		
		if(self.title~=nil) then
			__this=ParaUI.CreateUIObject("text",self.name.."title", "_lt",5,0,150,18);
			__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
			__this.autosize = false;
			__this.text=self.title;
		end
		
		__this=ParaUI.CreateUIObject("button","static", "_lt",self.width-58,0,36,18);
		__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
		__this.text="应用";
		__this.background="Texture/b_up.png;";
		if(self.binding~=nil)then
			__this.onclick=string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.DoModifier~=nil)then _mod:DoModifier();end;]], self.binding.name);
		else
			__this.onclick=";NPL.load(\"(gl)script/ide/gui_helper.lua\");_guihelper.MessageBox(\"Nothing is bound to this modifier.\");";
		end
		
		__this=ParaUI.CreateUIObject("button","static", "_lt",self.width-18,0,18,18);
		__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
		__this.text="X";
		__this.background="Texture/b_up.png;";
		__this.onclick=string.format([[;CommonCtrl.DeleteControl("%s");]], self.name);
		
		__this = ParaUI.CreateUIObject("container",self.name.."cont", "_lt",3,20,self.width-3,self.height-25);
		__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
		__this.scrollable=true;
		__texture=__this:GetTexture("background");
		__texture.transparency=0;--[0-255]
		
		if(self.binding~=nil) then
			self:Databind();
		end
	end
end

function ModifierUICtrl:Databind (o)
	if(o~=nil) then
		if(not self.binding or self.binding~=o) then
			self.binding = o;
		else
			return;
		end
	else
		o = self.binding;
	end
	local UIObject = ParaUI.GetUIObject(self.name);
	local __this,__parent,__font,__texture;
	if(not o) then
		-- unbind 
		if(UIObject:IsValid()==true) then
			-- remove all old child controls from old databinding if any.
			local sCtlName = UIObject.name;
			__parent = ParaUI.GetUIObject(sCtlName.."cont");
			__parent:RemoveAll();
			self.controlsbinded = false;
		end
	elseif(UIObject:IsValid()==true and o:GetAttributeObject()~=nil) then
		-- remove all old child controls from old databinding if any.
		local sCtlName = UIObject.name;
		__parent = ParaUI.GetUIObject(sCtlName.."cont");
		__parent:RemoveAll();
		self.controlsbinded = false;
		
		-- postpone adding field until it is visible again. 
		if(UIObject.visible==true) then
			self.controlsbinded = true;
			-- create all sub control items.
			local att = o:GetAttributeObject();
			local nCount = att:GetFieldNum();
			local nIndex;
			
			local ctrl_x,ctrl_y = 2,0;
			local cellspacing = 3;
			local width,height = self.width-cellspacing, 25;
			local labalWidth = 100;
			local valueWidth = width - labalWidth - cellspacing*3 - 20;
			local valueLeft = ctrl_x+labalWidth+cellspacing;
			
			for nIndex = 1, nCount do 
				local sName = att:GetFieldName(nIndex);
				local type = att:GetFieldType(nIndex);
				local sSchematics = att:GetSchematicsType(nIndex);
				
				height = 25;
				
				__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labalWidth,height);
				__parent:AddChild(__this);
				__this.text=sName;
				__this.autosize=true;
				
				if(att:IsFieldReadOnly(nIndex)==true) then
					if(type == "string" and sSchematics == ":script") then
						local ctl = CommonCtrl.CCtrlScriptTextBox:new{
							name = sCtlName..nIndex,
							parent = __parent,
							left = valueLeft, top = ctrl_y, 
							text = tostring(att:GetField(sName, "")),
							IsReadOnly = true,
							onchange = string.format([[CommonCtrl.CCtrlProperty.OnScriptChangeHandler("%s", %d);]],sCtlName, nIndex),
							--OnClickEdit = string.format([[CommonCtrl.CCtrlProperty.OnScriptClickEditHandler("%s", %d);]],sCtlName, nIndex),
							--OnReset = string.format([[CommonCtrl.CCtrlProperty.OnScriptResetHandler("%s", %d);]],sCtlName, nIndex)
						};
						ctl:Show();
						height = ctl.height;
					else
						__this=ParaUI.CreateUIObject("text",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,valueWidth,height);
						__parent:AddChild(__this);
						if(type == "vector3") then
							__this.text=string.format("%.2f,%.2f,%.2f", unpack(att:GetField(sName, {0,0,0})));
						else
							__this.text=tostring(att:GetField(sName, ""));
						end
						__this.autosize=true;
					end
				else
					if(type == "string") then
						if(sSchematics == ":file") then
							local ctl = CommonCtrl.CCtrlFileSelector:new{
								name = sCtlName..nIndex,
								parent = __parent,
								left = valueLeft, top = ctrl_y, 
								filename = tostring(att:GetField(sName, "")),
								onchange = string.format([[CommonCtrl.ModifierUICtrl.OnFileChangeHandler("%s", %d);]],sCtlName, nIndex)
							};
							ctl:Show();
							height = ctl.height;
						elseif(sSchematics == ":script") then
							local ctl = CommonCtrl.CCtrlScriptTextBox:new{
								name = sCtlName..nIndex,
								parent = __parent,
								left = valueLeft, top = ctrl_y, 
								text = tostring(att:GetField(sName, "")),
								onchange = string.format([[CommonCtrl.ModifierUICtrl.OnScriptChangeHandler("%s", %d);]],sCtlName, nIndex),
								--OnClickEdit = string.format([[CommonCtrl.ModifierUICtrl.OnScriptClickEditHandler("%s", %d);]],sCtlName, nIndex),
								--OnReset = string.format([[CommonCtrl.ModifierUICtrl.OnScriptResetHandler("%s", %d);]],sCtlName, nIndex)
							};
							ctl:Show();
							height = ctl.height;
						else
							__this=ParaUI.CreateUIObject("editbox",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,valueWidth,height);
							__parent:AddChild(__this);
							__this.text=tostring(att:GetField(sName, ""));
							__this.background="Texture/box.png;";
							__this.onchange = string.format([[;CommonCtrl.ModifierUICtrl.OnChangeHandler("%s", %d);]],sCtlName, nIndex);
						end
					elseif(type == "float") then
						__this=ParaUI.CreateUIObject("editbox",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,valueWidth,height);
						__parent:AddChild(__this);
						__this.text=tostring(att:GetField(sName, ""));
						__this.background="Texture/box.png;";
						__this.onchange = string.format([[;CommonCtrl.ModifierUICtrl.OnChangeHandler("%s", %d);]],sCtlName, nIndex);
					elseif(type == "int") then
						local ctl = CommonCtrl.CCtrlIntegerEditor:new {
							name = sCtlName..nIndex,
							parent = __parent,
							left = valueLeft, top = ctrl_y, 
							value = att:GetField(sName, 0),
							onchange = string.format([[CommonCtrl.ModifierUICtrl.OnIntegerChangeHandler("%s", %d);]],sCtlName, nIndex)
						};
						ctl.minvalue, ctl.maxvalue = att:GetSchematicsMinMax(nIndex, ctl.minvalue, ctl.maxvalue);
						ctl:Show();
						height = ctl.height;
					elseif(type == "bool") then
						__this=ParaUI.CreateUIObject("button",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,50,height);
						__parent:AddChild(__this);
						__this.text=tostring(att:GetField(sName, ""));
						__this.background="Texture/box.png;";
						__this.onclick = string.format([[;CommonCtrl.ModifierUICtrl.OnChangeHandler("%s", %d);]],sCtlName, nIndex);
					elseif(type == "vector3") then
						if(sSchematics == ":rgb") then
							local rgb= att:GetField(sName, {0,0,0});
							local ctl = CommonCtrl.CCtrlColorEditor:new {
								name = sCtlName..nIndex,
								parent = __parent,
								left = valueLeft, top = ctrl_y, 
								r = 255*rgb[1],g = 255*rgb[2],b = 255*rgb[3],
								onchange = string.format([[CommonCtrl.ModifierUICtrl.OnColorChangeHandler("%s", %d);]],sCtlName, nIndex)
							};
							ctl:Show();
							height = ctl.height;
						else
							local xyz= att:GetField(sName, {0,0,0});
							local ctl= CommonCtrl.CCtrlVectorEditor:new {
								name = sCtlName..nIndex,
								parent = __parent,
								left = valueLeft, top = ctrl_y, 
								x = xyz[1],y = xyz[2],z = xyz[3],
								onchange = string.format([[CommonCtrl.ModifierUICtrl.OnVectorChangeHandler("%s", %d);]],sCtlName, nIndex)
							}
							ctl:Show(3);
							height = ctl.height;
						end
					else
						-- Unknown field
					end
				end
				ctrl_y = ctrl_y + height + cellspacing;
			end
		end
	end
	
end

--[[ [static method] the event handler when the editor of a field should be invoked
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function ModifierUICtrl.OnScriptChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.items) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	if(ctl ~= nil) then
		local att = self.binding.items;
		local sName = att:GetFieldName(nFieldIndex);
		local type = att:GetFieldType(nFieldIndex);
		if(type == "string") then
			att:SetField(sName, ctl.text);
		end
	end
end

--[[ [static method] the event handler when the editor of a field should be invoked
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function ModifierUICtrl.OnIntegerChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.items) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	
	local att = self.binding.items;
	local sName = att:GetFieldName(nFieldIndex);
	local type = att:GetFieldType(nFieldIndex);
	local sSchematics = att:GetSchematicsType(nFieldIndex);
	if(type == "int") then
		att:SetField(sName, ctl.value);
	end
end

--[[ [static method] the event handler when the value of a field changes
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function CommonCtrl.ModifierUICtrl.OnFileChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.items) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	
	local att = self.binding.items;
	local sName = att:GetFieldName(nFieldIndex);
	local type = att:GetFieldType(nFieldIndex);
	local sSchematics = att:GetSchematicsType(nFieldIndex);
	if(type == "string") then
		att:SetField(sName, ctl.filename);
	end
end

--[[ [static method] the event handler when the value of a field changes
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function ModifierUICtrl.OnVectorChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.items) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	
	local att = self.binding.items;
	local sName = att:GetFieldName(nFieldIndex);
	local type = att:GetFieldType(nFieldIndex);
	local sSchematics = att:GetSchematicsType(nFieldIndex);
	if(type == "vector3") then
		att:SetField(sName, {ctl.x, ctl.y, ctl.z});
	end
end

--[[ [static method] the event handler when the value of a field changes
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function ModifierUICtrl.OnColorChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.items) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	local color ={ctl.r/255, ctl.g/255, ctl.b/255};
	
	local att = self.binding.items;
	local sName = att:GetFieldName(nFieldIndex);
	local type = att:GetFieldType(nFieldIndex);
	local sSchematics = att:GetSchematicsType(nFieldIndex);
	if(type == "vector3") then
		att:SetField(sName, color);
	end
end

--[[ [static method] the event handler when the value of a field changes
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function ModifierUICtrl.OnChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.items) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = ParaUI.GetUIObject(sCtrlName..nFieldIndex);
	if(ctl:IsValid() == true) then
		local att = self.binding.items;
		local nCount = att:GetFieldNum();
		
		local sName = att:GetFieldName(nFieldIndex);
		local type = att:GetFieldType(nFieldIndex);
		local sSchematics = att:GetSchematicsType(nFieldIndex);
		if(type == "string") then
			-- TODO: validate by schematics
			att:SetField(sName, ctl.text);
		elseif(type == "float" or type == "int") then
			-- TODO: validate by schematics
			local number = tonumber(ctl.text);
			if(not number) then
				_guihelper.MessageBox("Please input a valid number.");
			else
				att:SetField(sName, number);
			end
		elseif(type == "bool") then
			-- TODO: validate by schematics
			if(ctl.text == "true") then
				ctl.text = "false";
				att:SetField(sName, false);
			else
				ctl.text = "true";
				att:SetField(sName, true);
			end
		elseif(type == "vector3") then
			-- TODO: validate by schematics
		else
			-- Unknown field
		end
	end
end
