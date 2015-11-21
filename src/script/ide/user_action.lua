--[[
Title: user action
Author(s): LiXizhi
Date: 2006/9/5
Desc: all user actions are kept in a list. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/user_action.lua");
CommonCtrl.user_action:AddAction({id = CommonCtrl.user_action.action_id.Player_Create_Mesh, name="noName", FilePath="XXX", x=10,y=10,z=10});
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/AI.lua");

if(not CommonCtrl) then CommonCtrl={}; end
local user_action = {
	sequence_number = 0,
	nPos = 1,
	max_item_count = 10,
	actions = {},
	-- id of predefined actions, and other fields in the action.E.g. name is the target name; x,y,z is where the action takes place
	action_id = {
		Player_Create_Mesh = 0, -- name, FilePath, x,y,z
		Player_Create_Character = 1, -- name, FilePath, x,y,z
		Player_Translate_Object = 2, -- name, x,y,z, rx,ry,rz
		Player_Rotate_Object = 3, -- name, x,y,z, rx,ry,rz
		Player_Scale_Object = 4, -- name, x,y,z, scale
		Player_Delete_Object = 5, -- name, x,y,z
		NPC_selected = 6, -- name, x,y,z
		Mesh_selected = 7, -- name, x,y,z
	}
};

CommonCtrl.user_action = user_action;

--[[ add a new action to table 
@param act: any table holding the data of the action. It usually contains field called "id", which specifies which type of action it is. 
	For a list of predefined ID, please see user_action definition.
]]
function user_action:AddAction(act)
	if(act == nil) then
		return
	end
	if(self.nPos>=self.max_item_count) then
		self.nPos = 1;
	else
		self.nPos = self.nPos + 1;
	end

	self.sequence_number = self.sequence_number+1;
	act.sequence_number = self.sequence_number;
	
	self.actions[self.nPos] = act;
end

--[[ get an action, by offsetting from the current location. 
@param offset: if nil or 0, it means the current location. this is usually a negative integer value. 
@return: return the action object at the given position. Please note if there is action, nil is returned. ]]
function user_action:GetAction(offset)
	if(offset == nil) then
		offset = 0;
	end
	local nPos = self.nPos + offset;
	
	if(nPos<1) then
		nPos = nPos + self.max_item_count;
	elseif(nPos > self.max_item_count) then
		nPos = nPos - self.max_item_count;
	end
	return self.actions[nPos];
end

-- clear all actions, usually called when a game start.
function user_action:Clear()
	self.actions = {};
	self.nPos = 0;
end