--[[
Title: 
Author(s): Leio
Date: 2009/6/26
Note: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/AutoCompleteList.lua");
local ctl = CommonCtrl.AutoCompleteList:new{
	name = "AutoCompleteList1",
	alignment = "_lt",
	left=0, top=0,
	width = 300,
	height = 26,
	parent = nil,
	items = {
		{Text = "d"},
		{Text = "abc"},
		{Text = "ad"},
		{Text = "a"},
		{Text = "a"},
	},
};
ctl:Show();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/AutoCompleteBox.lua");

local AutoCompleteList = commonlib.inherit(CommonCtrl.AutoCompleteBox,{
});  
CommonCtrl.AutoCompleteList = AutoCompleteList;
function AutoCompleteList:Show(bShow)
	self:__Show(bShow);
	self:ShowList();
end
function AutoCompleteList:FilterItems()
	local txt = self:GetText();
	txt = tostring(txt);
	if(not txt or txt == "")then
			local result = self.items;
			return result;
	else
			local result = {};
			local low_txt = string.lower(txt);
			local k,item;
			for k,item in ipairs(self.items) do
				local label = item["Text"];
				local low_label = string.lower(label);
				if(string.find(low_label,low_txt))then
					table.insert(result,item);
				end
			end
			return result;
	end
end
function AutoCompleteList:CloseList()
	
end
