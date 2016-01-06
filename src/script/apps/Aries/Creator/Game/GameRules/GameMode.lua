--[[
Title: GameMode
Author(s): LiXizhi
Date: 2014/4/4
Desc: handy functions to test if a given function or UI is available at the current mode.
It can be both singleton and instanced. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GameRules/GameMode.lua");
local GameMode = commonlib.gettable("MyCompany.Aries.Game.GameLogic.GameMode");
-------------------------------------------------------
]]
local AllContext = commonlib.gettable("MyCompany.Aries.Game.AllContext");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local GameMode = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Game.GameLogic.GameMode"));

GameMode.mode = "editor";

function GameMode:ctor()
	self:SetInnerMode("editor");
end

-- this is a private function: do not call this explicitly 
function GameMode:SetInnerMode(mode)
	self.mode = mode;
	if(mode == "editor" or mode == "tutorial") then
		self.bIsEditor = true;
	else
		self.bIsEditor = false;
	end
end

function GameMode:GetMode()
	return self.mode;
end

-- whether allow external model files to be placed inside the world
function GameMode:CanPlaceExternalModel()
	-- only haqi version can place 3d models. 
	return not System.options.mc;
end

	
function GameMode:CanClickEmptySlot()
	return self:IsEditor();
end

function GameMode:IsEditor()
	if(self.bIsEditor) then
		return true;
	elseif(self.mode == "movie") then
		return self:CanRightClickToCreateBlock();
	else
		return false;
	end
end

function GameMode:ActivateDefaultContext()
	local context;
	if(self.bIsEditor) then
		if(self.mode == "tutorial") then
			context = AllContext:GetContext("tutorial");
		else
			context = AllContext:GetContext("edit");
		end
	elseif(self.mode == "movie") then
		context = AllContext:GetContext("movie");
	else
		context = AllContext:GetContext("play");
	end
	if(context) then
		return context:activate();
	end
end

function GameMode:CanFly()
	return self.bIsEditor or self.mode == "movie";
end

function GameMode:WillDieWhenFallTooDeep()
	return not (self.bIsEditor or self.mode == "movie");
end

function GameMode:CanCollectItem()
	return not (self.bIsEditor or self.mode == "movie");
end

function GameMode:HasJumpRestriction()
	return not (self.bIsEditor or self.mode == "movie");
end

function GameMode:AllowDoubleClickJump()
	return (self.bIsEditor);
end

-- E key to use creator bag instead of player's inventory
function GameMode:IsUseCreatorBag()
	return self.bIsEditor or self.mode == "movie";
end

function GameMode:IsShowGoalTracker()
	return not (self.mode=="movie");
end

function GameMode:IsMovieMode()
	return (self.mode=="movie");
end

-- if movie mode or desktop is hidden
function GameMode:IsViewMode()
	return self:IsMovieMode() or self.isViewMode;
end

function GameMode:ShouldHideTouchController()
	if(self.mode == "movie") then
		NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieManager.lua");
		local MovieManager = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieManager");
		local movieClip = MovieManager:GetActiveMovieClip()
		if(movieClip) then
			return movieClip:IsPlayingMode();
		else
			return true;
		end
	else
		return false;
	end
end

function GameMode:SetViewMode(bViewMode)
	self.isViewMode = bViewMode;
end

function GameMode:CanShowTimeLine()
	return (self.mode=="movie") or (self.bIsEditor);
end
function GameMode:IsShowExpHPBar()
	return not (self.bIsEditor or self.mode == "movie");
end

function GameMode:IsShowQuickSelectBar()
	return not (self.mode == "movie");
end

function GameMode:IsAllowGlobalEditorKey()
	return (self.bIsEditor or self.mode == "movie");
end

function GameMode:AllowLongHoldToDestoryBlock()
	return not (self.bIsEditor or self.mode == "movie");
end

function GameMode:CanSelect()
	if(self.mode == "movie") then
		NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieManager.lua");
		local MovieManager = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieManager");
		local movieClip = MovieManager:GetActiveMovieClip()
		if(movieClip) then
			return (not movieClip:IsPlayingMode() and MovieManager:IsLastModeEditor() and not MovieManager:IsCapturing());
		end
	else
		return not self:IsViewMode();
	end
end

function GameMode:CanRightClickToCreateBlock(gamemode)
	gamemode = gamemode or self.mode;
	
	if(gamemode == "movie") then
		NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieClipController.lua");
		local MovieClipController = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieClipController");
		local actor = MovieClipController.GetMovieActor()
		if(actor and not actor:CanCreateBlocks()) then
			return false;
		else
			return true;
		end
	else
		return true;
	end
end

function GameMode:CanEditBlock()
	return (self.bIsEditor or self.mode == "movie");
end

-- can show the right bottom dock panel. this area is disabled in movie mode. 
function GameMode:CanShowDock()
	return ( not System.options.mc and (self.mode ~= "movie"));
end

function GameMode:CanDirectClickToActivateItem()
	return self.mode == "game"
end

function GameMode:CanAddToHistory()
	return (self.bIsEditor or self.mode == "movie");
end

function GameMode:CanDropItem()
	return not self:IsEditor();
end

function GameMode:CanDestroyBlock(gamemode)
	gamemode = gamemode or self.mode;
	if((self.bIsEditor or gamemode=="survival")) then
		return true;
	elseif(gamemode == "movie") then
		return self:CanRightClickToCreateBlock(gamemode)
	else
		return false;
	end
end

-- set current tool by name
-- @param toolname: such as "touch_pen", "touch_selector", "touch_eraser", nil. nil is default mode. 
function GameMode:SetCurrentTool(toolname)
	if(self.toolname == toolname) then
		self.toolname = toolname;
		GameLogic.GetEvents():DispatchEvent({type = "SetTool" , toolname = toolname,});
	end
end

-- get current tool name
function GameMode:GetCurrentTool()
	return self.toolname;
end