--[[
Title: binding npl data table (members) to other IDE controls or ParaUIObject. it is a two way binding. 
Author(s): LiXizhi
Date: 2008/2/1
Note: I wrote this class using similar API in .NET v2 forms databinding.
Desc: Data binding provides a way for developers to create a read/write link between the controls and the data in their application (their data model).
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/DataBinding.lua");
local bindingContext = commonlib.BindingContext:new();
@param dataSource: it can be a table (1) or a binding function (2): 
bindingContext:AddBinding(dataSource, dataMember, ControlName,ControlType, ControlPropertyName, DataSourceUpdateMode, NullValue);
commonlib.Binding.ControlTypes = {
	ParaUI_editbox = 1, -- bindable fields:"text"
	ParaUI_text = 2,-- bindable fields:"text"
	ParaUI_button = 3,-- bindable fields:"text"
	ParaUI_container = 4,-- bindable fields:"text"
	ParaUI_listbox = 5,-- bindable fields:"text"
	IDE_checkbox = 6,-- bindable fields:"text", "value"
	IDE_radiobox = 7,-- bindable fields:"text", "value", "SelectedIndex"
	IDE_dropdownlistbox = 8,-- bindable fields:"text", "value", TODO: "SelectedIndex"
	IDE_treeview = 9,-- bindable fields: "text", TODO: "value", "SelectedIndex"
	IDE_sliderbar = 10,-- bindable fields: "value"
	IDE_canvas3d = 11,-- bindable fields: "model", "image" are readonly 
	IDE_coloreditor = 12,-- bindable fields: "text" as rgb "255 255 255"
	IDE_editbox = 13,-- bindable fields: "text"  multiline editbox
	IDE_numeric = 14,-- bindable fields: "value"  numeric updown control
	MCML_node = 20,-- bindable fields: SetUIValue and GetUIValue
}
-- e.g. 
	local bindingContext = commonlib.BindingContext:new();
	bindingContext:AddBinding(package, "text", "AssetManager.NewAsset#editboxPackageName", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(package, "Category", "AssetManager.comboBoxCategory", commonlib.Binding.ControlTypes.IDE_dropdownlistbox, "text", commonlib.Binding.DataSourceUpdateMode.ReadOnly)
	bindingContext:AddBinding(package, "bDisplayInMainBar", "AssetManager.checkBoxShowInMainbar", commonlib.Binding.ControlTypes.IDE_checkbox, "value", commonlib.Binding.DataSourceUpdateMode.Manual, true)
	bindingContext:AddBinding(treeNode.asset, "filename", "AssetManager.treeViewAssetAttributes", commonlib.Binding.ControlTypes.IDE_treeview, "RootNode#filename<Text>")
	bindingContext:AddBinding(package, "RadioIndex", "radioButton1", commonlib.Binding.ControlTypes.IDE_radiobox, "SelectedIndex")
	bindingContext:AddBinding(package, "Volume", "settings.trackBarVolume", commonlib.Binding.ControlTypes.IDE_sliderbar, "value")			
	bindingContext:AddBinding(function (dataMember, bIsWriting, value)
			-- one needs to ensure that the ParaObject is a valid object. 
			-- usually we bind normal 3d object by getting it dynamically from the scene using ObjEditor.GetObjectByParams(param)
			local att = ParaScene.GetAttributeObject();
			if(not bIsWriting) then
				-- reading from data source
				return att:GetField(dataMember, value or "");
			else
				-- writing to data source
				att:SetField(dataMember, value);
			end
		end, 
		"ClassName", "textBox1", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(values, "filepath", "page root name", commonlib.Binding.ControlTypes.MCML_node, "filepath")
	
	
-- call following to pull/push data
bindingContext:UpdateDataToControls()
bindingContext:UpdateControlsToData()
-------------------------------------------------------
]]
if(not commonlib) then commonlib={}; end
----------------------------------------------------------
-- BindingContext: Manages a collection of BindingManager(PropertyManager or CurrencyManager) objects
----------------------------------------------------------
local BindingContext = {
	-- Gets a value indicating whether the collection is read-only. 
	IsReadOnly = false, 
	-- private: the collection of PropertyManager or CurrencyManager objects
	BindingManagers = {},
};

commonlib.BindingContext = BindingContext;

-- create a new binding context
function BindingContext:new(o)
	o = o or {}   -- create object if user does not provide one
	o.BindingManagers = o.BindingManagers or {};
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Call this function to add a new binding to the binding context. 
-- @param dataSource
-- @param dataMember
-- @param binding: commonlib.Binding object, specifying which control to bind to. 
-- When constructing a Binding instance, you must specify three items:
--  (1) The name of the control property to bind to.
--  (2) The data source.
--  (3) The navigation path that resolves to a list or property in the data source. A period-delimited navigation path is required when the data source is set to an object that contains multiple DataTable objects 
function BindingContext:AddBindingObject(dataSource, dataMember, binding)
	local bindingManager = BindingContext:GetItem(dataSource, dataMember);
	if(bindingManager == nil) then
		-- create binding manager if not exist
		bindingManager = commonlib.BindingManager:new({dataSource = dataSource, dataMember=dataMember});
		self:Add(bindingManager);
	end
	bindingManager:Add(binding);
end

-- sample binding function (data source) for binding with attribute object field of any ParaObject. 
function BindingContext.ParaSceneBindingFunc(dataMember, bIsWriting, value)
	-- one needs to ensure that the ParaObject is a valid object. 
	-- usually we bind normal 3d object by getting it dynamically from the scene using ObjEditor.GetObjectByParams(param)
	local att = ParaScene.GetAttributeObject();
	if(not bIsWriting) then
		-- reading from data source
		return att:GetField(dataMember, value or "");
	else
		-- writing to data source
		att:SetField(dataMember, value);
	end
end

--[[ same as AddBindingObject except that multiple calls with the same input will not update the old binding. 
@param dataSource: it can be a table (1) or a binding function (2): 
	(1) npl table to which this binding manager is associated. 
	(2) a function (dataMember, bIsWriting, value) end, where
		@param dataMember: the self.dataMember is passed to the function. 
		@param bIsWriting: if true, the function should write the value parameter to the data source. otherwise, it should read and return the value of the data member in the datasource. 
		@param value: when bIsWriting is true, it denotes the value to be written to the data source. otherwise, it means the default value returned.
		@return: if bIsWriting is nil, it returns the value of the datamember in the datasource. 
		@see: BindingContext.ParaSceneBindingFunc() for an example.
@param dataMember: string value. it can be something like "level2.level3" to bind to a deep member. 
@param ControlName: string: the control name. It may contain # to concartinate parent name with child name. 
@param ControlType: type of commonlib.Binding.ControlTypes.
@param ControlPropertyName: if nil, it will bind to the control, and let the control decide how to display data. If it is a IDE control, the binding object will be assigned to the IDE control's databinding field.
	databinding field in IDE controls, such as TreeNode, will allow the control to dynamically read and write data from data source. 
@param DataSourceUpdateMode: type of commonlib.Binding.ControlTypes. 
@param NullValue: default value. 
@return: the Binding object created is returned. 
]]
function BindingContext:AddBinding(dataSource, dataMember, ControlName, ControlType, ControlPropertyName, DataSourceUpdateMode, NullValue)
	local bindingManager = BindingContext:GetItem(dataSource, dataMember);
	local binding;
	if(bindingManager == nil) then
		-- create binding manager if not exist
		bindingManager = commonlib.BindingManager:new({dataSource = dataSource, dataMember=dataMember});
		self:Add(bindingManager);
	else
		binding = bindingManager:GetBinding(ControlName, ControlType, ControlPropertyName)	
	end
	if(binding == nil) then
		binding = commonlib.Binding:new({ControlName=ControlName, ControlType=ControlType, ControlPropertyName=ControlPropertyName, UpdateMode = DataSourceUpdateMode, NullValue = NullValue});
		bindingManager:Add(binding);
	end
	return binding;
end

-- Pulls data from the data-bound control into the data source, returning no information.  
function BindingContext:UpdateDataToControls()
	local i, bm;
	for i, bm in ipairs(self.BindingManagers) do
		bm:PushData();
	end
end

-- Pushes data from the data source into the data-bound control, returning no information 
function BindingContext:UpdateControlsToData()
	local i, bm;
	for i, bm in ipairs(self.BindingManagers) do
		bm:PullData();
	end
end

-- Gets a value indicating whether the BindingContext contains the BindingManager associated with the specified data source (and data member). 
-- @param dataSource: the data source object to search for. Currently only lua table is supported. 
--	TODO: may support db, xml, file in future
-- @param dataMember: [optional] if nil, it will only search for existance of dataSource. If it is a string, both the dataSource and dataMember is searched. 
--  A data member is string name of a sub field or table in the dataSource. 
-- @return: true if the BindingManager is found
function BindingContext:Contains(dataSource, dataMember)
	local i, bm;
	for i, bm in ipairs(self.BindingManagers) do
		if(bm.dataSource == dataSource) then
			if(dataMember == nil or dataMember==bm.dataMember) then
				return true;
			end	
		end
	end
end

-- Gets a BindingManager that is associated with the specified data source and data member.  
-- @param dataSource: the data source object to search for. Currently only lua table is supported. 
--	TODO: may support db, xml, file in future
-- @param dataMember: [optional] if nil, it will only search for existance of dataSource. If it is a string, both the dataSource and dataMember is searched. 
--  A data member is string name of a sub field or table in the dataSource. 
-- @return: BindingManager is returned otherwise nil. 
function BindingContext:GetItem (dataSource, dataMember)
	local i, bm;
	for i, bm in ipairs(self.BindingManagers) do
		if(bm.dataSource == dataSource) then
			if(dataMember == nil or dataMember==bm.dataMember) then
				return bm;
			end	
		end
	end  
end
 

-- Adds the BindingManager associated with a specific data source to the collection. 
-- it will always create add new one, so it is better to check using Contains() before adding
function BindingContext:Add(BindingManager)
	commonlib.insertArrayItem(self.BindingManagers, nil, BindingManager);
end

-- Clears the collection of any BindingManager objects
function BindingContext:Clear()
	self.BindingManagers = {};
end

-- Delete any BindingManager(s) associated with the specified data source. 
function BindingContext:Remove(dataSource)
	local nIndex;
	for nIndex = 1, table.getn(self.BindingManagers) do
		if(self.BindingManagers[nIndex]~=nil and self.BindingManagers[nIndex].dataSource==dataSource) then
			commonlib.removeArrayItem(self.BindingManagers, nIndex);
		end
	end
end

----------------------------------------------------------
-- BindingManager: Manages all Binding objects that are bound to the same data source and data member. 
----------------------------------------------------------

local BindingManager = {
	--[[ it can be a table (1) or a function (2): 
		(1) npl table to which this binding manager is associated. 
		(2) a function (dataMember, bIsWriting, value) end, where
			@param dataMember: the self.dataMember is passed to the function. 
			@param bIsWriting: if true, the function should write the value parameter to the data source. otherwise, it should read and return the value of the data member in the datasource. 
			@param value: only used when bIsWriting is true, which denotes the value to be written to the data source. 
			@return: if bIsWriting is nil, it returns the value of the datamember in the datasource. 
	]]
	dataSource = nil,
	-- a member name (string) in the dataSource to which all binding objects of this manager is associated. 
	-- it can also be a function (dataSource, bIsWriting, value) end
	dataMember = nil,
	-- if the data member in the dataSource is an array, this is the current position (1-based index) in the array. 
	-- this parameter has no effect if the dataMember is a property field, rather than an array. 
	Position = 1,
	-- the collection of all Binding objects 
	Bindings = {},
};

commonlib.BindingManager = BindingManager;

-- create a new BindingManager
function BindingManager:new(o)
	o = o or {}   -- create object if user does not provide one
	o.Bindings = o.Bindings or {};
	setmetatable(o, self)
	self.__index = self
	return o
end

-- get the current object at current position. The dataMember itself is returned if it is not an array table. 
function BindingManager:GetCurrentValue()
	if(type(self.dataSource) == "table") then
		local data = commonlib.getfield(self.dataMember, self.dataSource);
		if(type(data) == "table" and table.getn(data)<=self.Position) then
			return data[self.Position];
		else
			if(type(data) == "function") then
				return data(self.dataSource); -- reading
			else
				return data;	
			end
		end
	elseif(type(self.dataSource) == "function") then
		return self.dataSource(self.dataMember);
	end		
end

-- set the current object at current position. The dataMember itself is returned if it is not an array table. 
function BindingManager:SetCurrentValue(value)
	if(type(self.dataSource) == "table") then
		local data = commonlib.getfield(self.dataMember, self.dataSource);
		if(type(data) == "table" and table.getn(data)<=self.Position) then
			data[self.Position] = value;
		else
			if(type(data) == "function") then
				return data(self.dataSource, true, value); -- writing
			else
				commonlib.setfield(self.dataMember, value, self.dataSource);
			end
		end
	elseif(type(self.dataSource) == "function") then
		self.dataSource(self.dataMember, true, value);
	end	
end

-- Adds a binding to the bindings collection. 
-- it will always create add new one, so it is better to check using Contains() before adding
function BindingManager:Add(binding)
	binding.BindingManager = self;
	commonlib.insertArrayItem(self.Bindings, nil, binding);
end

-- whether the manager contains a given binding
function BindingManager:Contains(ControlName, ControlType, ControlPropertyName)
	local i, binding;
	for i, binding in ipairs(self.Bindings) do
		if(binding.ControlName == ControlName and binding.ControlType == ControlType and binding.ControlPropertyName == ControlPropertyName) then
			return true;
		end
	end
end

-- return a binding 
function BindingManager:GetBinding(ControlName, ControlType, ControlPropertyName)
	local i, binding;
	for i, binding in ipairs(self.Bindings) do
		if(binding.ControlName == ControlName and binding.ControlType == ControlType and binding.ControlPropertyName == ControlPropertyName) then
			return binding;
		end
	end
end

-- Pulls data from the data-bound control into the data source, returning no information.  
function BindingManager:PullData()
	local i, binding;
	for i, binding in ipairs(self.Bindings) do
		binding:WriteValue();
	end
end

-- Pushes data from the data source into the data-bound control, returning no information 
function BindingManager:PushData()
	local i, binding;
	for i, binding in ipairs(self.Bindings) do
		binding:ReadValue();
	end
end

--
-- for array type dataMember
--
function BindingManager:AddNew()
	-- TODO: 
end
function BindingManager:CancelCurrentEdit()
	-- TODO: 
end
function BindingManager:EndCurrentEdit()
	-- TODO: 
end
function BindingManager:RemoveAt()
	-- TODO: 
end
--
-- TODO: event handlers: PositionChanged, CurrentChanged, DataError 
--

--------------------------------------------------
-- Binding: Represents the simple binding between the property value of an NPL table(or the property of the current object in an array) and the property value of an IDE control or ParaUIObject. 
-- e.g. you can bind the text property of an EditBox control to the FirstName property of a Customer table.
--------------------------------------------------
local Binding = {
	-- string: Set/Get the IDE control name (it may also be the control itself) or ParaUIObject name(it may be childname#childname) that the binding belongs to.
	ControlName = nil,
	-- type of control in commonlib.Binding.ControlTypes 
	ControlType = nil,
	-- string: Gets or sets the name of the control's data-bound property. 
	ControlPropertyName = nil, 
	-- how data source is updated. type of commonlib.Binding.DataSourceUpdateMode. It defaults to Manual update. 
	UpdateMode = nil,
	-- values provided to the control if the dataMember is nil. 
	NullValue = nil,
	-- the parent BindingManager object
	BindingManager = nil, 
};
commonlib.Binding = Binding;

-- supported control types
commonlib.Binding.ControlTypes = {
	ParaUI_editbox = 1, -- bindable fields:"text"
	ParaUI_text = 2,-- bindable fields:"text"
	ParaUI_button = 3,-- bindable fields:"text"
	ParaUI_container = 4,-- bindable fields:"text"
	ParaUI_listbox = 5,-- bindable fields:"text"
	IDE_checkbox = 6,-- bindable fields:"text", "value"
	IDE_radiobox = 7,-- bindable fields:"text", "value", "SelectedIndex"
	IDE_dropdownlistbox = 8,-- bindable fields:"text", TODO: "SelectedIndex"
	-- bindable fields(TreeNode or treenode property): "RootNode#SubNode", "RootNode#SubNode<propertyName>", TODO: "value", "SelectedNodePath"
	-- Note: Please note that the root node name must begins with "Root"
	-- bind a table(dataMember needs to be a table) to a treenode like this "RootNode#SubNode", it uses partial copy when updating. i.e. it only updates fields inside the data member with the treenode. 
	-- bind a property dataMember to a treenode propery like this "RootNode#SubNode<propertyName>"
	-- Note: the treeview is not immediately updated when update controls on binding context, one needs to manually call update. 
	IDE_treeview = 9,
	IDE_sliderbar = 10, -- bindable fields:"value"
	IDE_canvas3d = 11,-- bindable fields: "model", "image"
	IDE_coloreditor = 12,-- bindable fields: "text" as rgb "255 255 255"
	IDE_editbox = 13,-- bindable fields: "text"  multiline editbox
	IDE_numeric = 14,-- bindable fields: "value"  numeric updown control
	
	MCML_node = 20,-- bindable fields: SetUIValue  and GetUIValue
}

-- Specifies when a data source is updated when changes occur in the bound control. 
commonlib.Binding.DataSourceUpdateMode  = {
	-- [default]: Data source is manually updated by calling the push/pull data or update functions on binding or binding context level.
	Manual = nil,
	-- Data source is never updated and values entered into the control are not parsed, validated or re-formatted.  
	ReadOnly = 1,
	-- Data source is updated whenever the value of the control property changes.
	OnPropertyChanged = 2,
	-- Data source is updated when the control property is validated,  After validation, the value in the control property will also be re-formatted.
	OnValidation = 3,
}

-- create a new BindingManager
function Binding:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- convert to string. mostly for logging debugging info. 
function Binding:ToString()
	return string.format("Binding: ctl name=%s, ctl property=%s", tostring(self.ControlName), self.ControlPropertyName);
end

-- get the current value
function Binding:GetValue()
	return self.BindingManager:GetCurrentValue() or self.NullValue;
end

-- Sets the control property to the value read from the data source.  
function Binding:ReadValue()
	--log("reading: "..self:ToString().." value: "..tostring(value).."\n")	
	if(self.ControlType >= Binding.ControlTypes.ParaUI_editbox and self.ControlType<=Binding.ControlTypes.ParaUI_listbox) then
		local _this = commonlib.GetUIObject(self.ControlName);
		if(_this~=nil and _this:IsValid()) then
			if(self.ControlPropertyName == "text") then
				_this.text = self:GetValue();
			elseif(self.ControlPropertyName == "background") then
				local filename = self:GetValue();
				if(filename~=nil and ParaIO.DoesFileExist(string.gsub(filename, ":.*$", ""), true) or string.find(filename,"^http")~=nil) then	
					_this.background = filename; -- file must exist
				else
					_this.background = self.NullValue or "";
				end
			else
				-- TODO: other types
				log("warning: supported binding types for "..self:ToString().."\n")		
			end	
		else
			log("warning: unable to get control from databinding "..self:ToString().."\n")	
		end
	else
		local ctl;
		if(type(self.ControlName) == "string") then
			ctl = CommonCtrl.GetControl(self.ControlName);
		elseif(type(self.ControlName) == "table") then
			ctl = self.ControlName;
		end	
		if(ctl~=nil) then
			if(self.ControlType == Binding.ControlTypes.IDE_checkbox) then
				if(self.ControlPropertyName == "text") then
					ctl:SetText(self:GetValue());
				elseif(self.ControlPropertyName == "value") then
					ctl:SetCheck(self:GetValue());
				end
			elseif(self.ControlType == Binding.ControlTypes.IDE_dropdownlistbox) then
				if(self.ControlPropertyName == "text") then
					ctl:SetText(self:GetValue());
				elseif(self.ControlPropertyName == "value") then
					ctl:SetValue(self:GetValue());
				end
			elseif(self.ControlType == Binding.ControlTypes.IDE_radiobox) then
				if(self.ControlPropertyName == "value") then
					ctl:SetCheck(self:GetValue());
				elseif(self.ControlPropertyName == "SelectedIndex") then
					ctl:SetSelectedIndex(self:GetValue());
				end
			elseif(self.ControlType == Binding.ControlTypes.IDE_sliderbar) then
				if(self.ControlPropertyName == "value") then
					ctl:SetValue(self:GetValue());
				end
			elseif(self.ControlType == Binding.ControlTypes.IDE_numeric) then
				if(self.ControlPropertyName == "value") then
					ctl:SetValue(self:GetValue());
				end	
			elseif(self.ControlType == Binding.ControlTypes.IDE_canvas3d) then
				if(self.ControlPropertyName == "image") then
					ctl:ShowImage(self:GetValue());
				elseif(self.ControlPropertyName == "model") then	
					ctl:ShowModel(self:GetValue());
				end	
			elseif(self.ControlType == Binding.ControlTypes.IDE_coloreditor) then
				if(self.ControlPropertyName == "text") then
					ctl:SetRGBString(self:GetValue());
				end		
			elseif(self.ControlType == Binding.ControlTypes.IDE_editbox) then
				if(self.ControlPropertyName == "text") then
					ctl:SetText(self:GetValue());
				end			
			elseif(self.ControlType == Binding.ControlTypes.IDE_treeview) then
				if(string.sub(self.ControlPropertyName, 1, 4) == "Root") then
					-- It is bind to a sub node or a property of subnode
					local parent = ctl.RootNode;
					local nDepth = 0;
					local bProcessed;
					local childname;
					for childname in string.gfind(self.ControlPropertyName,"[^#]+") do
						local nodeName = string.gsub(childname, "<.*$", "");
						local _,_, propertyName = string.find(childname, "<(.+)>");
						nDepth = nDepth+1;
						if(nDepth>1) then
							if(parent~=nil) then
								parent = parent:GetChildByName(nodeName);
							end
						end
						if(parent~=nil and propertyName~=nil) then
							-- it is bind to a property of a treenode
							commonlib.setfield(propertyName, self:GetValue(), parent);
							bProcessed = true;
						end
					end
					
					if(not bProcessed and parent~=nil) then
						-- it is bind to the treenode itself
						-- assign the binding to the databinding field of the tree node. 
						parent.databinding = self;
						
						--local value = self:GetValue();
						--if(type(value) == "table") then
							---- Note:data member must be a table to be bind to a treenode. Otherwise, please bind to a treenode property
							---- only copy fields in value
							--commonlib.partialcopy(parent, value);
						--end
						bProcessed = true;
					end
					-- parent.TreeView.Update(); -- Note: one needs to manually update 
					
				elseif(self.ControlPropertyName == "SelectedNodePath") then
					-- TODO: 
				end	
			elseif(self.ControlType == Binding.ControlTypes.MCML_node) then
				if(ctl.SetUIValue) then
					ctl:SetUIValue(self.ControlPropertyName, self:GetValue());	
				else
					log("warning: SetUIValue is not found with mcml node data binding "..self:ToString().."\n")
				end
			else
				-- TODO: other types:
				log("warning: supported binding types for "..self:ToString().."\n")		
			end
		else
			log("warning: unable to get control of binding "..self:ToString().."\n")		
		end	
	end
end

-- Reads the current value from the control property and writes it to the data source.  
function Binding:WriteValue()
	if(self.UpdateMode == commonlib.Binding.DataSourceUpdateMode.ReadOnly) then
		-- return immediately if binding is read only. 
		return 
	end
	if(self.ControlType >= Binding.ControlTypes.ParaUI_editbox and self.ControlType<=Binding.ControlTypes.ParaUI_listbox) then
		local _this = commonlib.GetUIObject(self.ControlName);
		if(_this~=nil and _this:IsValid()) then
			if(self.ControlPropertyName == "text") then
				self.BindingManager:SetCurrentValue(_this.text);
			elseif(self.ControlPropertyName == "background") then
				self.BindingManager:SetCurrentValue(_this.background);
			else	
				-- TODO: other types
				log("warning: supported binding types for "..self:ToString().."\n")		
			end	
		else
			log("warning: unable to get control from databinding "..self:ToString().."\n")	
		end
	else
		local ctl;
		if(type(self.ControlName) == "string") then
			ctl = CommonCtrl.GetControl(self.ControlName);
		elseif(type(self.ControlName) == "table") then
			ctl = self.ControlName;
		end	
		if(ctl~=nil) then
			if(self.ControlType == Binding.ControlTypes.IDE_checkbox) then
				if(self.ControlPropertyName == "text") then
					self.BindingManager:SetCurrentValue(ctl:GetText());
				elseif(self.ControlPropertyName == "value") then
					self.BindingManager:SetCurrentValue(ctl:GetCheck());
				end
			elseif(self.ControlType == Binding.ControlTypes.IDE_dropdownlistbox) then
				if(self.ControlPropertyName == "text") then
					self.BindingManager:SetCurrentValue(ctl:GetText());
				elseif(self.ControlPropertyName == "value") then
					self.BindingManager:SetCurrentValue(ctl:GetValue());
				end
			elseif(self.ControlType == Binding.ControlTypes.IDE_radiobox) then
				if(self.ControlPropertyName == "value") then
					self.BindingManager:SetCurrentValue(ctl:GetCheck());
				elseif(self.ControlPropertyName == "SelectedIndex") then
					self.BindingManager:SetCurrentValue(ctl:GetSelectedIndex());
				end	
			elseif(self.ControlType == Binding.ControlTypes.IDE_sliderbar) then
				if(self.ControlPropertyName == "value") then
					self.BindingManager:SetCurrentValue(ctl:GetValue());
				end	
			elseif(self.ControlType == Binding.ControlTypes.IDE_numeric) then
				if(self.ControlPropertyName == "value") then
					self.BindingManager:SetCurrentValue(ctl:GetValue());
				end		
			elseif(self.ControlType == Binding.ControlTypes.IDE_coloreditor) then
				if(self.ControlPropertyName == "text") then
					self.BindingManager:SetCurrentValue(ctl:GetRGBString());
				end		
			elseif(self.ControlType == Binding.ControlTypes.IDE_editbox) then
				if(self.ControlPropertyName == "text") then
					self.BindingManager:SetCurrentValue(ctl:GetText());
				end	
			elseif(self.ControlType == Binding.ControlTypes.IDE_treeview) then
				if(string.sub(self.ControlPropertyName, 1, 4) == "Root") then
					-- It is bind to a sub node or a property of subnode
					local parent = ctl.RootNode;
					local nDepth = 0;
					local bProcessed;
					for childname in string.gfind(self.ControlPropertyName,"[^#]+") do
						local nodeName = string.gsub(childname, "<.*$", "");
						local _,_, propertyName = string.find(childname, "<(.+)>");
						nDepth = nDepth+1;
						if(nDepth>1) then
							if(parent~=nil) then
								parent = parent:GetChildByName(nodeName);
							end
						end
						if(parent~=nil and propertyName~=nil) then
							-- it is bind to a property of a treenode
							self.BindingManager:SetCurrentValue(commonlib.getfield(propertyName, parent));
							bProcessed = true;
						end
					end
					
					if(not bProcessed and parent~=nil) then
						-- it is bind to the treenode itself
						local value = self.BindingManager:GetCurrentValue();
						if(type(value) == "table") then
							-- only copy fields in value
							commonlib.mincopy(value, parent);
						end
						bProcessed = true;
					end
					-- parent.TreeView.Update(); -- Note: one needs to manually update 
					
				elseif(self.ControlPropertyName == "SelectedNodePath") then
					-- TODO: 
				end
			elseif(self.ControlType == Binding.ControlTypes.MCML_node) then
				if(ctl.GetUIValue) then
					self.BindingManager:SetCurrentValue(ctl:GetUIValue(self.ControlPropertyName));
				else
					log("warning: GetUIValue is not found with mcml node data binding "..self:ToString().."\n")
				end	
			else
				-- TODO: other types:
				log("warning: supported binding types for "..self:ToString().."\n")		
			end
		else
			log("warning: unable to get control of binding "..self:ToString().."\n")		
		end	
	end
end 
