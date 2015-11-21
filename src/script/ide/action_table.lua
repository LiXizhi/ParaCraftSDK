--[[
Title: character actions in ParaEngine. 
Author(s): 
Date: 2006/12/5
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/action_table.lua");
action_table.ActionSymbols.S_ACTIONKEY
-------------------------------------------------------
]]
local i=0;
local function AutoEnum()
	i=i+1;
	return i;
end
local function LastEnum()
	return i;
end
local function BeginEnum()
	i=0;
	return i;
end

if(not action_table) then action_table={}; end

-- prefined ActionSymbols
action_table.ActionSymbols = {
	S_STANDING = BeginEnum(),		-- ensure the biped has no speed
	S_IN_WATER = AutoEnum(),			-- make sure that the biped is in water
	S_ON_FEET = AutoEnum(),			-- make sure that the biped is on land and on its feet
	S_ON_WATER_SURFACE = AutoEnum(),			-- make sure that the biped is on land and on its feet
	POP_ACTION = AutoEnum(), -- pop the current action
	S_STAND = AutoEnum(),
	S_WALK_FORWORD = AutoEnum(),
	S_RUN_FORWORD = AutoEnum(),
	S_WALK_LEFT = AutoEnum(),
	S_WALK_RIGHT = AutoEnum(),
	S_WALK_POINT = AutoEnum(),		-- walking to a point
	S_TURNING = AutoEnum(),
	S_WALK_BACKWORD = AutoEnum(),
	S_SWIM_FORWORD = AutoEnum(),
	S_SWIM_LEFT = AutoEnum(),
	S_SWIM_RIGHT = AutoEnum(),
	S_SWIM_BACKWORD = AutoEnum(),
	S_JUMP_START = AutoEnum(),
	S_JUMP_IN_AIR = AutoEnum(),	-- not used.
	S_JUMP_END = AutoEnum(),
	S_MOUNT = AutoEnum(),
	S_FALLDOWN = AutoEnum(),
	S_ATTACK = AutoEnum(),
	S_ATTACK1 = AutoEnum(),
	S_ATTACK2 = AutoEnum(),
	S_DANCE = AutoEnum(),
	S_ACTIONKEY = AutoEnum(),  -- perform the action in the action key, immediately.
	S_FLY_DOWNWARD = AutoEnum(),
	S_NONE= AutoEnum(),
};

-- prefined action key
action_table.ActionKeyID ={
	TOGGLE_TO_WALK = BeginEnum(),
	TOGGLE_TO_RUN = AutoEnum(),
	JUMP = AutoEnum(),
	MOUNT = AutoEnum(), -- mount on the nearest object
	NONE = AutoEnum(),
};

-- play a given animation file on character (player). It will only load the animation file once on first call
-- filename: such as "character/Animation/hs/victory.x"
function action_table.PlayAnimationFile(filename, player)
	local nAnimID = ParaAsset.CreateBoneAnimProvider(-1, filename, filename, false);
	if(nAnimID>0) then
		if(not player) then
			player = ParaScene.GetPlayer();
		end
		player:ToCharacter():PlayAnimation(nAnimID);
	end
end

-- open a file dialog that allows a user to select an animation file to play for the current character
-- please note that the current character model must support external animation and matches the initial bone animation in the animation file.
function action_table.TestExternalAnimation()
	-- allows a user to select an animation file to play for the current character
	
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialogAnim",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		fileextensions = {"all files(*.x)" },
		folderlinks = {
			{path = "character/Animation/", text = "动作库"},
			{path = "character/Animation/hs/", text = "HS测试"},
		},
		showSubDirLevels = 1,
		onopen = function(sCtrlName, filename) 
			action_table.PlayAnimationFile(filename);
		end,
	};
	ctl:Show(true);
end
