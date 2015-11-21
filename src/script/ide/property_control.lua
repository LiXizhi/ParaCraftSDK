--[[
Title: property control (dialog)
Author(s): LiXizhi, Liuweili
Date: 2006/5/29
Desc: CommonCtrl.CCtrlProperty displays a property dialog for a give object which implements the GetAttributeObject() method, such as ParaObject.
By liuweili: add the updatefield for the script ides such as scripttextbox, vectoreditor, integereditor, fileselector, coloreditor
             add support for modifier.
Use Lib:

-------------------------------------------------------
NPL.load("(gl)script/ide/property_control.lua");
local ctlProperty = CommonCtrl.CCtrlProperty:new {
	binding = obj,
	name = "propertyDlg"
};
ctlProperty:Show(true);
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/coloreditor_control.lua");
NPL.load("(gl)script/ide/vectoreditor_control.lua");
NPL.load("(gl)script/ide/fileselector_control.lua");
NPL.load("(gl)script/ide/integereditor_control.lua");
NPL.load("(gl)script/ide/scripttextbox_control.lua");
NPL.load("(gl)script/ide/modifier_control.lua");
local L = CommonCtrl.Locale("IDE");
-- define a new control in the common control libary

-- default member attributes
local CCtrlProperty = {
	-- normal window size
	alignment = "_ct",
	left = 180,
	top = -100,
	width = 320,
	height = 200,
	-- window height when minimized
	minHeight = 20,
	-- the top level control name
	name = "defaultpropertywindow",
	-- title to be displayed
	title = nil, 
	binding = nil,
	-- whether minimized
	minimized = false,
	-- whether controls has been binded
	controlsbinded = false,
	
	
}
CommonCtrl.CCtrlProperty = CCtrlProperty;

-- constructor
function CCtrlProperty:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlProperty:Destroy ()
	ParaUI.Destroy(self.name);
end

-- show the property control, one may need to set the o.binding member before calling this method. 
function CCtrlProperty:Show (bVisible)
	local UIObject = ParaUI.GetUIObject(self.name);
	if(UIObject:IsValid() == true) then
		UIObject.visible = bVisible;
		if(bVisible == true) then
			if(not self.controlsbinded) then
				-- rebind if not bound yet.
				if(self.binding~=nil) then
					self:DataBind();
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
		
		__this=ParaUI.CreateUIObject("text",self.name.."title", "_lt",5,0,150,18);
		__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
		__this.autosize = false;
		__this.text="";
		
		if(self.title~=nil) then
			__this.text=self.title;
		end
		if(self.binding.title~=nil) then
			__this.text=self.binding.title;
		end
		if(self.binding.ismodifier)then
			__this=ParaUI.CreateUIObject("button",self.name.."undo", "_lt",self.width-120,0,40,18);
			__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
			__this.text=L"undo";
			__this.background="Texture/b_up.png;";
			__this=ParaUI.CreateUIObject("button",self.name.."apply", "_lt",self.width-160,0,40,18);
			__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
			__this.text=L"apply";
			__this.background="Texture/b_up.png;";
		else
			__this=ParaUI.CreateUIObject("button",self.name.."mod", "_lt",self.width-110,0,28,18);
			__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
			__this.text="mod";
			__this.background="Texture/b_up.png;";
			__this.onclick=string.format([[;CommonCtrl.CCtrlProperty.OnOpenModifiers("%s");]], self.name);
			
		end
		__this=ParaUI.CreateUIObject("button",self.name.."updatebutton", "_lt",self.width-80,0,40,18);
		__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
		__this.text="更新";
		__this.background="Texture/b_up.png;";
		__this.onclick=string.format([[;CommonCtrl.CCtrlProperty.UpdateField("%s");]], self.name);
		__this=ParaUI.CreateUIObject("button", self.name.."minmaxbutton", "_lt",self.width-36,0,18,18);
		__parent=ParaUI.GetUIObject(self.name);__parent:AddChild(__this);
		__this.text="-";
		__this.background="Texture/b_up.png;";
		__this.onclick=string.format([[;CommonCtrl.CCtrlProperty.OnMinMaxWindow("%s");]], self.name);
		
		__this=ParaUI.CreateUIObject("button","staticX", "_lt",self.width-18,0,18,18);
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
			self:DataBind();
		end
	end
end

-- change the size
function CCtrlProperty:ReSize(width, height)
	self.width = width;
	self.height = height;
	-- TODO
end

--[[ Unbind the given object. this function should be called before the binded object is released. 
@param obj: obj can be nil, in which case the self.binding will be unbinded. if not only unbind if the obj equals self.binding.]]
function CCtrlProperty:DeleteBinding(obj)
	if(not self.binding) then return end
	if(obj~=nil) then
		if(obj:equals(self.binding) == true) then
			self.binding = nil;
			self:DataBind();
		end
	else
		self.binding = nil;
		self:DataBind();
	end
end

--[[ bind data object to the control 
@param o: it should be a ParaObject or nil. if nil, self.binding object will be used.
]]
function CCtrlProperty:DataBind(o)
	if(o~=nil) then
		if(not self.binding or self.binding:equals(o)==false) then
			self.binding = o;
		else
			-- already binded.
			-- log("rebind detected\r\n")
			return;
		end
	else
		o = self.binding;
	end
	local UIObject = ParaUI.GetUIObject(self.name);
	if(not o) then
		-- unbind 
		if(UIObject:IsValid()==true) then
			-- remove all old child controls from old databinding if any.
			local sCtlName = UIObject.name;
			__parent = ParaUI.GetUIObject(sCtlName.."cont");
			__parent:RemoveAll();
			self.controlsbinded = false;
		end
	elseif(UIObject:IsValid()==true and o.GetAttributeObject~=nil) then
		local __this,__parent,__font,__texture;
		-- remove all old child controls from old databinding if any.
		local sCtlName = UIObject.name;
		__parent = ParaUI.GetUIObject(sCtlName.."cont");
		__parent:RemoveAll();
		self.controlsbinded = false;
		
		
		local function ABCD(__parent, treeNode)
			if(__parent == nil or treeNode == nil) then
				return;
			end
			local used_height = 100;
			-- postpone adding field until it is visible again. 
			if(not self.minimized and UIObject.visible==true) then
				self.controlsbinded = true;
				if(self.binding.OwnerDraw)then
					if(self.binding.ismodifier)then
						__this=ParaUI.GetUIObject(self.name.."undo");
						if(__this:IsValid())then
							if(self.binding~=nil and self.binding.UnDoModifier~=nil)then
								__this.enabled=true;
								__this.onclick=string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.UnDoModifier~=nil)then _mod:UnDoModifier();end;]], self.binding.name);
							else
								__this.enabled=false;
							end
						end
						__this=ParaUI.GetUIObject(self.name.."apply");
						if(__this:IsValid())then
							if(self.binding~=nil and self.binding.DoModifier~=nil)then
								__this.enabled=true;
								__this.onclick=string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.DoModifier~=nil)then _mod:DoModifier();end;]], self.binding.name);
							else
								__this.enabled=false;
							end
						end
					end
					self.binding:OwnerDraw(__parent);
				else
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
					local start,nend;
					__this=ParaUI.GetUIObject(self.name.."title");
					if(self.title~=nil) then
						__this.text=self.title;
					end
					if(self.binding.title~=nil) then
						__this.text=self.binding.title;
					end
					if(self.binding.ismodifier)then
						__this=ParaUI.GetUIObject(self.name.."undo");
						if(__this:IsValid())then
							if(self.binding~=nil and self.binding.UnDoModifier~=nil)then
								__this.enabled=true;
								__this.onclick=string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.UnDoModifier~=nil)then _mod:UnDoModifier();end;]], self.binding.name);
							else
								__this.enabled=false;
							end
						end
						__this=ParaUI.GetUIObject(self.name.."apply");
						if(__this:IsValid())then
							if(self.binding~=nil and self.binding.DoModifier~=nil)then
								__this.enabled=true;
								__this.onclick=string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.DoModifier~=nil)then _mod:DoModifier();end;]], self.binding.name);
							else
								__this.enabled=false;
							end
						end
						start=1;
						nend=nCount;
					else
						start=0;
						nend=nCount-1;
					end
					for nIndex = start, nend do 
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
									OnClickEdit = string.format([[CommonCtrl.CCtrlProperty.OnScriptClickEditHandler("%s", %d);]],sCtlName, nIndex),
									OnReset = string.format([[CommonCtrl.CCtrlProperty.OnScriptResetHandler("%s", %d);]],sCtlName, nIndex)
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
										onchange = string.format([[CommonCtrl.CCtrlProperty.OnFileChangeHandler("%s", %d);]],sCtlName, nIndex)
									};
									ctl:Show();
									height = ctl.height;
								elseif(sSchematics == ":script") then
									local ctl = CommonCtrl.CCtrlScriptTextBox:new{
										name = sCtlName..nIndex,
										parent = __parent,
										left = valueLeft, top = ctrl_y, 
										text = tostring(att:GetField(sName, "")),
										onchange = string.format([[CommonCtrl.CCtrlProperty.OnScriptChangeHandler("%s", %d);]],sCtlName, nIndex),
										OnClickEdit = string.format([[CommonCtrl.CCtrlProperty.OnScriptClickEditHandler("%s", %d);]],sCtlName, nIndex),
										OnReset = string.format([[CommonCtrl.CCtrlProperty.OnScriptResetHandler("%s", %d);]],sCtlName, nIndex)
									};
									ctl:Show();
									height = ctl.height;
								else
									__this=ParaUI.CreateUIObject("editbox",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,valueWidth,height);
									__parent:AddChild(__this);
									__this.text=tostring(att:GetField(sName, ""));
									__this.background="Texture/box.png;";
									__this.onchange = string.format([[;CommonCtrl.CCtrlProperty.OnChangeHandler("%s", %d);]],sCtlName, nIndex);
								end
							elseif(type == "float") then
								__this=ParaUI.CreateUIObject("editbox",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,valueWidth,height);
								__parent:AddChild(__this);
								__this.text=tostring(att:GetField(sName, ""));
								__this.background="Texture/box.png;";
								__this.onchange = string.format([[;CommonCtrl.CCtrlProperty.OnChangeHandler("%s", %d);]],sCtlName, nIndex);
							elseif(type == "int") then
								local ctl = CommonCtrl.CCtrlIntegerEditor:new {
									name = sCtlName..nIndex,
									parent = __parent,
									left = valueLeft, top = ctrl_y, 
									value = att:GetField(sName, 0),
									onchange = string.format([[CommonCtrl.CCtrlProperty.OnIntegerChangeHandler("%s", %d);]],sCtlName, nIndex)
								};
								ctl.minvalue, ctl.maxvalue = att:GetSchematicsMinMax(nIndex, ctl.minvalue, ctl.maxvalue);
								ctl:Show();
								height = ctl.height;
							elseif(type == "bool") then
								__this=ParaUI.CreateUIObject("button",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,50,height);
								__parent:AddChild(__this);
								__this.text=tostring(att:GetField(sName, ""));
								__this.background="Texture/box.png;";
								__this.onclick = string.format([[;CommonCtrl.CCtrlProperty.OnChangeHandler("%s", %d);]],sCtlName, nIndex);
							elseif(type == "vector3") then
								if(sSchematics == ":rgb") then
									local rgb= att:GetField(sName, {0,0,0});
									local ctl = CommonCtrl.CCtrlColorEditor:new {
										name = sCtlName..nIndex,
										parent = __parent,
										left = valueLeft, top = ctrl_y, 
										r = 255*rgb[1],g = 255*rgb[2],b = 255*rgb[3],
										onchange = string.format([[CommonCtrl.CCtrlProperty.OnColorChangeHandler("%s", %d);]],sCtlName, nIndex)
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
										onchange = string.format([[CommonCtrl.CCtrlProperty.OnVectorChangeHandler("%s", %d);]],sCtlName, nIndex)
									}
									ctl:Show(3);
									height = ctl.height;
								end
							elseif(type == "void") then
								__this=ParaUI.CreateUIObject("button",sCtlName..nIndex, "_lt",valueLeft,ctrl_y,50,height);
								__parent:AddChild(__this);
								__this.text="run!";
								__this.background="Texture/box.png;";
								__this.onclick = string.format([[;CommonCtrl.CCtrlProperty.OnChangeHandler("%s", %d);]],sCtlName, nIndex);
							else
								-- Unknown field
							end
							
						end
						ctrl_y = ctrl_y + height + cellspacing;
					end
					used_height = ctrl_y;
				end
			end
			treeNode.NodeHeight = used_height;
		end -- function ...
		CommonCtrl.DeleteControl(sCtlName.."_TreeView");
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl(sCtlName.."_TreeView");
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = sCtlName.."_TreeView",
				alignment = "_fi",
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				parent = __parent,
				--container_bg = "",
				DefaultIndentation = 0,
				DefaultNodeHeight = 24,
				VerticalScrollBarStep = 24,
				VerticalScrollBarPageSize = 24 * 6,
				-- lxz: this prevent clipping text and renders faster
				NoClipping = false,
				HideVerticalScrollBar = false,
				DrawNodeHandler = ABCD,
			};
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({}));
		ctl:Show();
		ctl:Update();
	end
end

--[[ [static method] update the given field. 
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the field to be updated. if this is nil, all field will be updated.
]]
function CCtrlProperty.UpdateField(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local att = self.binding:GetAttributeObject();
	--local function UpdateSingleField(sCtrlName, nFieldIndex, att)
	local function UpdateSingleField(nFieldIndex)
		local ctl = ParaUI.GetUIObject(sCtrlName..nFieldIndex);
		if(ctl:IsValid() == true) then
			local sName = att:GetFieldName(nFieldIndex);
			local type = att:GetFieldType(nFieldIndex);
			local sSchematics = att:GetSchematicsType(nFieldIndex);
			if(att:IsFieldReadOnly(nFieldIndex)==true) then
				if(type == "vector3") then
					ctl.text=string.format("%.2f,%.2f,%.2f", unpack(att:GetField(sName, {0,0,0})));
				else
					ctl.text=tostring(att:GetField(sName, ""));
				end
			else
				if(type == "string") then 
					if(sSchematics == ":file") then
						CommonCtrl.CCtrlFileSelector.InternalUpdate(ctl.name,att:GetField(sName, 0));
						
					elseif(sSchematics == ":script") then
						CommonCtrl.CCtrlScriptTextBox.InternalUpdate(ctl.name,att:GetField(sName, 0));
					else
						ctl.text=tostring(att:GetField(sName, ""));
					end
				elseif(type == "float" or type == "bool") then
					ctl.text=tostring(att:GetField(sName, ""));
				elseif( type == "int" ) then
					CommonCtrl.CCtrlIntegerEditor.InternalUpdate(sCtrlName..nFieldIndex,att:GetField(sName, 0));
				elseif(type == "vector3") then
					if(sSchematics == ":rgb") then
						CommonCtrl.CCtrlColorEditor.InternalUpdate(sCtrlName..nFieldIndex,unpack(att:GetField(sName, {0,0,0})));
					else
						CommonCtrl.CCtrlVectorEditor.InternalUpdate(sCtrlName..nFieldIndex,unpack(att:GetField(sName, {0,0,0})));
					end
				else
					-- Unknown field
				end
			end
		end
	end
	if(self.binding.OwnerUpdate)then
		self.binding.OwnerUpdate(self.binding.name,nFieldIndex);
	else
		if(not nFieldIndex) then
			-- iterate all sub control items.
			local nCount = att:GetFieldNum();
			local nIndex;
			for nIndex = 0, nCount-1 do 
				UpdateSingleField(nIndex);
			end
		else
			-- only update a given field (nFieldIndex)
			UpdateSingleField(nFieldIndex);
		end
	end;
end

--[static method]
function CCtrlProperty.OnOpenModifiers(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self) then 
		log("warning: property control not found.\r\n");
		return 
	end
	if(self.binding~=nil)then
		local _this=ParaUI.GetUIObject(sCtrlName.."mod");
		local x,y=_this:GetAbsPosition();
		CommonCtrl.ModifierCtrl:Show(self.binding,x,y);
	end
end

--[[ [static method] the event handler when the value 
@param sCtrlName: the global control name. 
]]
function CCtrlProperty.OnMinMaxWindow(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self) then 
		log("warning: property control not found.\r\n");
		return 
	end
	self.minimized = not self.minimized;
	local ctl = ParaUI.GetUIObject(sCtrlName);
	local cont = ParaUI.GetUIObject(sCtrlName.."cont");
	if(cont:IsValid() == true) then
		local btn = ParaUI.GetUIObject(sCtrlName.."updatebutton");
		btn.visible = not self.minimized;
		cont.visible = not self.minimized;
		
		btn = ParaUI.GetUIObject(sCtrlName.."minmaxbutton");
		if (not self.minimized) then
			btn.text = "-";
			ctl.height  = self.height;
			
			if(not self.controlsbinded) then
				-- rebind if not bound yet.
				if(self.binding~=nil) then
					self:DataBind();
				end
			end
		else
			btn.text = "+";
			ctl.height  = self.minHeight;
		end
	end
end

--[[ [static method] the event handler when the editor of a field should be invoked
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function CCtrlProperty.OnScriptChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	if(ctl ~= nil) then
		local att = self.binding:GetAttributeObject();
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
function CCtrlProperty.OnScriptResetHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	local att = self.binding:GetAttributeObject();
	local sName = att:GetFieldName(nFieldIndex);
	att:ResetField(nFieldIndex);
	ctl.text = tostring(att:GetField(sName,""));
end

--[[ [static method] the event handler when the editor of a field should be invoked
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function CCtrlProperty.OnScriptClickEditHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local att = self.binding:GetAttributeObject();
	att:InvokeEditor(nFieldIndex,"");
end

--[[ [static method] the event handler when the editor of a field should be invoked
@param sCtrlName: the global control name. 
@param nFieldIndex: the index of the caller field]]
function CCtrlProperty.OnIntegerChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	
	local att = self.binding:GetAttributeObject();
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
function CommonCtrl.CCtrlProperty.OnFileChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	
	local att = self.binding:GetAttributeObject();
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
function CCtrlProperty.OnVectorChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	
	local att = self.binding:GetAttributeObject();
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
function CCtrlProperty.OnColorChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..nFieldIndex);
	local color ={ctl.r/255, ctl.g/255, ctl.b/255};
	
	local att = self.binding:GetAttributeObject();
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
function CCtrlProperty.OnChangeHandler(sCtrlName, nFieldIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(not self or not self.binding or not self.binding.GetAttributeObject) then 
		log("warning: property control not bound to a valid object.\r\n");
		return 
	end
	local ctl = ParaUI.GetUIObject(sCtrlName..nFieldIndex);
	if(ctl:IsValid() == true) then
		local att = self.binding:GetAttributeObject();
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
		elseif(type == "void") then
			att:CallField(sName);
		else
			-- Unknown field
		end
	end
end


--[[ Display a default property window for a given object
@param ctlName: control name, if the name already exists, the content will be rebind to the new object. 
@param obj: the object to be bound to the control
@param bShow: nil to use the current setting;otherwise true to show property window, 
@param width, height: nil or initial control size 
]]
function CommonCtrl.ShowObjProperty(ctlName, obj, bShow, left, top, width, height)
	if(obj ~= nil and obj:IsValid()==true) then 
		local ctlProperty = CommonCtrl.GetControl(ctlName);
		if(ctlProperty == nil) then
			ctlProperty = CommonCtrl.CCtrlProperty:new{
				binding = obj, 
				name = ctlName,
				title = "=="..ctlName.."=="
			};
			
			if(left~=nil) then
				ctlProperty.left = left;
			end
			if(top~=nil) then
				ctlProperty.top = top;
			end
			if(width~=nil) then
				ctlProperty.width = width;
			end
			if(height~=nil) then
				ctlProperty.height = height;
			end
		else
			ctlProperty:DataBind(obj);
		end
		if(bShow~=nil) then
			ctlProperty:Show(bShow);
		end
	end
end

NPL.load("(gl)script/ide/modifiers/CharacterSentientField.lua");
NPL.load("(gl)script/ide/modifiers/DummyNPCEmpty.lua");
NPL.load("(gl)script/ide/modifiers/DummyNPCLineWalker.lua");
NPL.load("(gl)script/ide/modifiers/CharacterSentientField.lua");
NPL.load("(gl)script/ide/modifiers/GreatView.lua");
