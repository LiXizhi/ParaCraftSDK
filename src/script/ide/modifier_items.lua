--[[
Title: modifier items
Author(s): Liuweili
Date: 2006/6/16
Desc: CommonCtrl.ModifierItems emulates the attribute field interface for modifiers
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/midifier_items.lua");
items=CommonCtrl.ModifierItems:new{
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
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- default member attributes
local ModifierItems = {
	--the table containing name, type and schematic of the items, numeric index, starting with 1
	items={},
	--the values of a given name, indexed with name
	values={}
}
-- constructor: instantiate a modifier_items by supplying a object being modified
function ModifierItems:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
CommonCtrl.ModifierItems = ModifierItems;

function ModifierItems:GetFieldName (nIndex)
	if(nIndex==nil)then
		log("Nil Index\n");
		return nil;
	end
	if(self.items[nIndex]==nil)then
		return nil;
	end
	if(self.items[nIndex].name==nil)then
		log("Error: Check your code to see if you have correctly initialize the CModifierItems with name\n");
		return nil;
	end
	return self.items[nIndex].name;
end

--[[copies contents of this ModifierItems to a new ModifierItems
--]]
function ModifierItems:Copy()
	local o=ModifierItems:new();
	local index,value=next(self.items);
	while(index~=nil)do
		o.items[index]=value;
		index,value=next(self.items,index);
	end
	index,value=next(self.values);
	while(index~=nil)do
		o.values[index]=value;
		index,value=next(self.values,index);
	end
	return o;
end

function ModifierItems:IsFieldReadOnly (nIndex)
	if(nIndex==nil)then
		log("Nil Index\n");
		return false;
	end
	if(self.items[nIndex]==nil)then
		return false;
	end
	if(self.items[nIndex].readonly==nil)then
		return false;
	end
	return self.items[nIndex].readonly;
end

function ModifierItems:GetFieldNum ()
	return table.getn(self.items);
end

function ModifierItems:GetFieldType (nIndex)
	if(nIndex==nil)then
		log("Nil Index\n");
		return nil;
	end
	if(self.items[nIndex]==nil)then
		return nil;
	end
	if(self.items[nIndex].type==nil)then
		log("Error: Check your code to see if you have correctly initialize the CModifierItems with type \n");
		return nil;
	end
	return self.items[nIndex].type;
	
end
function ModifierItems:GetSchematicsType (nIndex)
	if(nIndex==nil)then
		log("Nil Index\n");
		return nil;
	end
	if(self.items[nIndex]==nil)then
		return nil;
	end
	if(self.items[nIndex].schematic==nil)then
		log("Error: Check your code to see if you have correctly initialize the CModifierItems with schematics\n");
		return nil;
	end
	return self.items[nIndex].schematic;
end
function ModifierItems:GetSchematicsMinMax (nIndex, min, max)
	if(nIndex==nil)then
		log("Nil Index\n");
		return "";
	end
	if(self.items[nIndex]==nil)then
		return nil;
	end
	if(self.items[nIndex].max~=nil)then
		max=self.items[nIndex].max;
	end
	if(self.items[nIndex].min~=nil)then
		min=self.items[nIndex].min;
	end
	return min,max;
end

--Stubs
function ModifierItems:InvokeEditor(index, sParam)
end
function ModifierItems:ResetField(index)
end
function ModifierItems:GetClassName()
	return "CSceneObject";
end
--[[Get field of a given name. 
@param sName: field name you want to get.
@param output: default value to be returned if the field does not exist
--]]
function ModifierItems:GetField (sName,output)
	if(sName==nil)then
		log("Nil name\n");
		return output;
	end
	if(self.values[sName]==nil)then
		log("The given field not found\n");
		return output;
	end
	return self.values[sName];
end

--[[Set field of a given name. 
@param sName: field name you want to set.
@param value: the value you set
--]]
function ModifierItems:SetField (sName,value)
	if(sName==nil)then
		log("Nil name\n");
		return;
	end
	self.values[sName]=value;
end